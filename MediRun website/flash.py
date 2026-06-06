import os
import json
from datetime import datetime, timedelta
from math import radians, sin, cos, sqrt, atan2

import pymysql
from dotenv import load_dotenv
from flask import Flask, flash, redirect, render_template, request, session, url_for, jsonify
from werkzeug.security import check_password_hash, generate_password_hash

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "medi-run-dev-key")

ACCOUNT_TABLE = "accounts"
DRIVER_TABLE = "drivers"
VEHICLE_TABLE = "cars"
DELIVERY_TABLE = "deliveries"
ROUTE_TABLE = "routes"
ROUTE_STOPS_TABLE = "route_stops"
EMERGENCY_TABLE = "emergency_deliveries"
DRIVER_HOURS_TABLE = "driver_daily_hours"

# Constants
AVERAGE_SPEED_KMH = 40  # km/h for ETA calculation
MAX_DRIVER_HOURS = 8
WAREHOUSE_LAT = 40.7128
WAREHOUSE_LON = -74.0060


def get_db_connection():
    return pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "medirun_db"),
        cursorclass=pymysql.cursors.DictCursor,
    )


def password_matches(stored_password, candidate_password):
    if not stored_password:
        return False
    try:
        # Try to verify using Werkzeug's check_password_hash for common hash formats
        return check_password_hash(stored_password, candidate_password)
    except (ValueError, TypeError):
        # If the stored hash is malformed (seed data) or unsupported,
        # fall back to plain-text comparison for legacy records.
        return stored_password == candidate_password


def fetch_account(username):
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"SELECT id, username, password, status FROM {ACCOUNT_TABLE} WHERE username = %s",
            (username,),
        )
        return cursor.fetchone()
    finally:
        connection.close()


def fetch_all(table_name):
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(f"SELECT * FROM {table_name} ORDER BY id DESC")
        return cursor.fetchall()
    finally:
        connection.close()


def is_ceo():
    return session.get("status") == "ceo"


def is_driver():
    return session.get("status") == "driver"


def ceo_only():
    if not session.get("username"):
        return redirect(url_for("login"))
    if not is_ceo():
        flash("CEO access required.", "error")
        return redirect(url_for("dashboard"))
    return None


def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two coordinates using Haversine formula"""
    R = 6371  # Earth's radius in km
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c


def calculate_eta_minutes(distance_km):
    """Calculate ETA based on distance and average speed"""
    return int((distance_km / AVERAGE_SPEED_KMH) * 60)


def suggest_best_vehicle(package_size, requires_fridge, distance_km):
    """Suggest the best available vehicle for a delivery"""
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # Build query based on requirements
        conditions = ["status = 'available'"]
        
        if package_size == 'large':
            conditions.append("size = 'large'")
        
        if requires_fridge:
            conditions.append("has_fridge = TRUE")
        
        where_clause = " AND ".join(conditions)
        
        cursor.execute(f"""
            SELECT id, plate_number, model, size, has_fridge, capacity_kg
            FROM {VEHICLE_TABLE}
            WHERE {where_clause}
            ORDER BY capacity_kg DESC
            LIMIT 5
        """)
        
        suggestions = cursor.fetchall()
        return suggestions if suggestions else []
    finally:
        connection.close()


def suggest_vehicle_for_emergency(location_lat, location_lon, package_size, requires_fridge):
    """Suggest nearest vehicle for emergency delivery"""
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # Get all active vehicles
        conditions = []
        if requires_fridge:
            conditions.append("has_fridge = TRUE")
        
        where_clause = "status IN ('available', 'in_use')"
        if conditions:
            where_clause += " AND " + " AND ".join(conditions)
        
        cursor.execute(f"""
            SELECT id, plate_number, model, size, has_fridge, capacity_kg,
                   current_latitude, current_longitude, current_driver_id
            FROM {VEHICLE_TABLE}
            WHERE {where_clause}
        """)
        
        vehicles = cursor.fetchall()
        
        # Calculate distance to each vehicle
        suggestions = []
        for vehicle in vehicles:
            if vehicle['current_latitude'] and vehicle['current_longitude']:
                dist = calculate_distance(
                    location_lat, location_lon,
                    vehicle['current_latitude'], vehicle['current_longitude']
                )
                vehicle['distance_to_emergency_km'] = round(dist, 2)
                vehicle['eta_minutes'] = calculate_eta_minutes(dist)
                suggestions.append(vehicle)
        
        # Sort by distance
        suggestions.sort(key=lambda x: x['distance_to_emergency_km'])
        return suggestions[:5]  # Return top 5 suggestions
    finally:
        connection.close()


@app.route("/")
def home():
    if session.get("username"):
        return redirect(url_for("dashboard"))
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        account = fetch_account(username)

        if account and password_matches(account["password"], password):
            session["user_id"] = account["id"]
            session["username"] = account["username"]
            session["status"] = account["status"]
            flash("Login successful.", "success")
            return redirect(url_for("dashboard"))

        return render_template("login.html", error=True)

    return render_template("login.html", error=False)


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        status = request.form.get("status", "driver")

        if not username or not password:
            return render_template("register.html", error=True)

        # Only allow 'ceo' or 'driver'
        if status not in {"ceo", "driver"}:
            status = "driver"

        existing_account = fetch_account(username)
        if existing_account:
            return render_template("register.html", error=True)

        hashed_password = generate_password_hash(password)
        connection = get_db_connection()
        try:
            cursor = connection.cursor()
            cursor.execute(
                f"INSERT INTO {ACCOUNT_TABLE} (username, password, status) VALUES (%s, %s, %s)",
                (username, hashed_password, status),
            )
            connection.commit()
        finally:
            connection.close()

        flash("Account created successfully. Please log in.", "success")
        return redirect(url_for("login"))

    return render_template("register.html", error=False)


@app.route("/dashboard")
def dashboard():
    if not session.get("username"):
        return redirect(url_for("login"))
    
    status = session.get("status")
    username = session.get("username")
    
    if status == "ceo":
        return redirect(url_for("ceo_dashboard"))
    else:
        return redirect(url_for("driver_dashboard"))


@app.route("/ceo/dashboard")
def ceo_dashboard():
    if not is_ceo():
        return redirect(url_for("login"))
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # Get pending deliveries
        cursor.execute(f"""
            SELECT id, pickup_address, delivery_address, package_size, 
                   requires_fridge, package_weight_kg, status
            FROM {DELIVERY_TABLE}
            WHERE status IN ('pending', 'assigned')
            ORDER BY created_at DESC
            LIMIT 20
        """)
        deliveries = cursor.fetchall()
        
        # Get assigned deliveries count
        cursor.execute(f"""
            SELECT COUNT(*) as total FROM {DELIVERY_TABLE}
            WHERE status IN ('pending', 'assigned', 'in_transit')
        """)
        delivery_counts = cursor.fetchone()
        
    finally:
        connection.close()
    
    return render_template(
        "ceo_dashboard.html",
        username=session.get("username"),
        deliveries=deliveries,
        delivery_counts=delivery_counts
    )


@app.route("/driver/dashboard")
def driver_dashboard():
    if not is_driver():
        return redirect(url_for("login"))
    
    # Get driver info
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # Get current assigned deliveries for this driver
        # For now, using a placeholder - in real system would link account to driver
        cursor.execute(f"""
            SELECT id, pickup_address, delivery_address, package_size,
                   requires_fridge, status, assigned_truck_id
            FROM {DELIVERY_TABLE}
            WHERE status IN ('assigned', 'in_transit')
            LIMIT 20
        """)
        deliveries = cursor.fetchall()
        
    finally:
        connection.close()
    
    return render_template(
        "driver_dashboard.html",
        username=session.get("username"),
        deliveries=deliveries
    )


@app.route("/api/deliveries", methods=["GET"])
def get_deliveries():
    """API endpoint to get pending deliveries"""
    if not is_ceo():
        return jsonify({"error": "Unauthorized"}), 403
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(f"""
            SELECT id, pickup_address, delivery_address, package_size,
                   requires_fridge, package_weight_kg, status, distance_km,
                   estimated_duration_minutes, created_at
            FROM {DELIVERY_TABLE}
            WHERE status = 'pending'
            ORDER BY created_at ASC
        """)
        deliveries = cursor.fetchall()
        return jsonify(deliveries)
    finally:
        connection.close()


@app.route("/api/suggest-vehicle", methods=["POST"])
def api_suggest_vehicle():
    """API endpoint to suggest vehicles for a delivery"""
    if not is_ceo():
        return jsonify({"error": "Unauthorized"}), 403
    
    data = request.json
    delivery_id = data.get("delivery_id")
    package_size = data.get("package_size")
    requires_fridge = data.get("requires_fridge")
    distance_km = data.get("distance_km", 50)
    
    suggestions = suggest_best_vehicle(package_size, requires_fridge, distance_km)
    return jsonify(suggestions)


@app.route("/api/assign-delivery", methods=["POST"])
def api_assign_delivery():
    """API endpoint to assign a delivery to a vehicle"""
    if not is_ceo():
        return jsonify({"error": "Unauthorized"}), 403
    
    data = request.json
    delivery_id = data.get("delivery_id")
    truck_id = data.get("truck_id")
    driver_id = data.get("driver_id")
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # Update delivery with assignment
        cursor.execute(f"""
            UPDATE {DELIVERY_TABLE}
            SET assigned_truck_id = %s, assigned_driver_id = %s, status = 'assigned'
            WHERE id = %s
        """, (truck_id, driver_id, delivery_id))
        
        connection.commit()
        return jsonify({"success": True, "message": "Delivery assigned successfully"})
    except Exception as e:
        connection.rollback()
        return jsonify({"error": str(e)}), 400
    finally:
        connection.close()


@app.route("/api/emergency-suggestion", methods=["POST"])
def api_emergency_suggestion():
    """API endpoint to get emergency delivery suggestions"""
    if not is_ceo():
        return jsonify({"error": "Unauthorized"}), 403
    
    data = request.json
    location_lat = float(data.get("latitude", WAREHOUSE_LAT))
    location_lon = float(data.get("longitude", WAREHOUSE_LON))
    package_size = data.get("package_size", "small")
    requires_fridge = data.get("requires_fridge", False)
    
    suggestions = suggest_vehicle_for_emergency(
        location_lat, location_lon, package_size, requires_fridge
    )
    return jsonify(suggestions)


@app.route("/api/create-emergency", methods=["POST"])
def api_create_emergency():
    """API endpoint to create an emergency delivery"""
    if not is_ceo():
        return jsonify({"error": "Unauthorized"}), 403
    
    data = request.json
    location_address = data.get("location_address", "Emergency Location")
    location_lat = float(data.get("latitude", WAREHOUSE_LAT))
    location_lon = float(data.get("longitude", WAREHOUSE_LON))
    package_size = data.get("package_size", "small")
    requires_fridge = data.get("requires_fridge", False)
    package_weight = data.get("package_weight", 10)
    assigned_truck_id = data.get("truck_id")
    assigned_driver_id = data.get("driver_id")
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        cursor.execute(f"""
            INSERT INTO {EMERGENCY_TABLE}
            (location_address, location_latitude, location_longitude, package_size,
             requires_fridge, package_weight_kg, assigned_truck_id, assigned_driver_id, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'assigned')
        """, (location_address, location_lat, location_lon, package_size,
              requires_fridge, package_weight, assigned_truck_id, assigned_driver_id))
        
        connection.commit()
        emergency_id = cursor.lastrowid
        return jsonify({
            "success": True,
            "emergency_id": emergency_id,
            "message": "Emergency delivery created"
        })
    except Exception as e:
        connection.rollback()
        return jsonify({"error": str(e)}), 400
    finally:
        connection.close()


@app.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out.", "success")
    return redirect(url_for("login"))


if __name__ == "__main__":
    app.run(debug=True)
