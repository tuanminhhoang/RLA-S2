import os
from datetime import date, datetime, time, timedelta
from math import atan2, cos, radians, sin, sqrt

import pymysql
from dotenv import load_dotenv
from flask import Flask, flash, jsonify, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash, generate_password_hash

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "medi-run-dev-key")

ACCOUNT_TABLE = "accounts"
DRIVER_TABLE = "drivers"
VEHICLE_TABLE = "cars"
CLIENT_TABLE = "clients"
DELIVERY_TABLE = "deliveries"
ASSIGNMENT_TABLE = "daily_vehicle_assignments"
ROUTE_TABLE = "routes"
ROUTE_STOPS_TABLE = "route_stops"
EMERGENCY_TABLE = "emergency_deliveries"
DRIVER_HOURS_TABLE = "driver_daily_hours"
ZONE_TRAVEL_TABLE = "zone_travel_times"

AVERAGE_SPEED_KMH = 40
MAX_DRIVER_HOURS = 8
LEGAL_DRIVER_HOURS = 10
WAREHOUSE_LAT = 48.8566
WAREHOUSE_LON = 2.3522
DEFAULT_TRAVEL_MINUTES = 30
SHIFT_START = time(8, 0)
HOSPITAL_START = time(7, 30)

PRIORITY_ORDER = {"urgent": 0, "normal": 1, "low": 2}


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
    if stored_password == candidate_password:
        return True
    try:
        return check_password_hash(stored_password, candidate_password)
    except (ValueError, TypeError):
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


def is_manager():
    return session.get("status") in {"ceo", "admin", "manager"}


def is_driver():
    return session.get("status") == "driver"


def manager_required():
    if not session.get("username"):
        return redirect(url_for("login"))
    if not is_manager():
        flash("Manager access required.", "error")
        return redirect(url_for("dashboard"))
    return None


def driver_required():
    if not session.get("username"):
        return redirect(url_for("login"))
    if not is_driver():
        flash("Driver access required.", "error")
        return redirect(url_for("dashboard"))
    return None


def parse_selected_date(value):
    if not value:
        today = date.today()
        return today - timedelta(days=today.weekday())
    return datetime.strptime(value, "%Y-%m-%d").date()


def format_date(value):
    if isinstance(value, (datetime, date)):
        return value.strftime("%Y-%m-%d")
    return str(value)


def week_bounds(selected_date):
    start = selected_date - timedelta(days=selected_date.weekday())
    end = start + timedelta(days=6)
    return start, end


def week_days(selected_date):
    start, _ = week_bounds(selected_date)
    return [start + timedelta(days=offset) for offset in range(7)]


def start_datetime(plan_date, hospital=False):
    return datetime.combine(plan_date, HOSPITAL_START if hospital else SHIFT_START)


def calculate_distance(lat1, lon1, lat2, lon2):
    radius = 6371
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return radius * c


def calculate_eta_minutes(distance_km):
    return int((distance_km / AVERAGE_SPEED_KMH) * 60)


def query_all(sql, params=None):
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(sql, params or ())
        return list(cursor.fetchall())
    finally:
        connection.close()


def query_one(sql, params=None):
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(sql, params or ())
        return cursor.fetchone()
    finally:
        connection.close()


def fetch_all(table_name):
    return query_all(f"SELECT * FROM {table_name} ORDER BY id")


def get_manager_summary(selected_date):
    selected = format_date(selected_date)
    return {
        "today_deliveries": query_one(
            f"SELECT COUNT(*) AS value FROM {DELIVERY_TABLE} WHERE delivery_date = %s",
            (selected,),
        )["value"],
        "urgent_deliveries": query_one(
            f"SELECT COUNT(*) AS value FROM {DELIVERY_TABLE} WHERE delivery_date = %s AND priority = 'urgent'",
            (selected,),
        )["value"],
        "refrigerated_deliveries": query_one(
            f"SELECT COUNT(*) AS value FROM {DELIVERY_TABLE} WHERE delivery_date = %s AND requires_fridge = TRUE",
            (selected,),
        )["value"],
        "available_drivers": query_one(
            f"SELECT COUNT(*) AS value FROM {DRIVER_TABLE} WHERE status = 'active'",
        )["value"],
        "available_vehicles": query_one(
            f"SELECT COUNT(*) AS value FROM {VEHICLE_TABLE} WHERE status = 'available'",
        )["value"],
        "unassigned_deliveries": query_one(
            f"SELECT COUNT(*) AS value FROM {DELIVERY_TABLE} WHERE delivery_date = %s AND status = 'pending'",
            (selected,),
        )["value"],
        "late_risk": query_one(
            f"""
            SELECT COUNT(*) AS value FROM {DELIVERY_TABLE}
            WHERE delivery_date = %s AND deadline IS NOT NULL
              AND status IN ('pending', 'assigned', 'in_transit', 'delayed')
              AND deadline < DATE_ADD(NOW(), INTERVAL 2 HOUR)
            """,
            (selected,),
        )["value"],
        "warnings": query_one(
            f"""
            SELECT COUNT(*) AS value FROM {ROUTE_STOPS_TABLE} rs
            JOIN {ROUTE_TABLE} r ON r.id = rs.route_id
            WHERE r.route_date = %s AND rs.warning_text IS NOT NULL AND rs.warning_text <> ''
            """,
            (selected,),
        )["value"],
    }


def get_deliveries(selected_date=None, filters=None):
    filters = filters or {}
    clauses = []
    params = []

    if selected_date:
        clauses.append("d.delivery_date = %s")
        params.append(format_date(selected_date))

    for key in ["priority", "zone", "status"]:
        if filters.get(key):
            clauses.append(f"d.{key} = %s")
            params.append(filters[key])

    if filters.get("requires_fridge") in {"0", "1"}:
        clauses.append("d.requires_fridge = %s")
        params.append(int(filters["requires_fridge"]))

    where = "WHERE " + " AND ".join(clauses) if clauses else ""
    return query_all(
        f"""
        SELECT d.*, c.name AS client_name, c.client_type
        FROM {DELIVERY_TABLE} d
        LEFT JOIN {CLIENT_TABLE} c ON c.id = d.client_id
        {where}
        ORDER BY d.delivery_date DESC, FIELD(d.priority, 'urgent', 'normal', 'low'), d.deadline
        """,
        tuple(params),
    )


def get_dashboard_delivery_groups(selected_date):
    selected = format_date(selected_date)

    def rows(extra_where, limit=8):
        return query_all(
            f"""
            SELECT d.*, c.name AS client_name, c.client_type
            FROM {DELIVERY_TABLE} d
            LEFT JOIN {CLIENT_TABLE} c ON c.id = d.client_id
            WHERE d.delivery_date = %s {extra_where}
            ORDER BY FIELD(d.priority, 'urgent', 'normal', 'low'), d.requires_fridge DESC, d.deadline
            LIMIT {int(limit)}
            """,
            (selected,),
        )

    return {
        "urgent": rows("AND d.priority = 'urgent'"),
        "refrigerated": rows("AND d.requires_fridge = TRUE"),
        "standard": rows("AND d.priority IN ('normal', 'low') AND d.requires_fridge = FALSE"),
        "delayed_failed": rows("AND d.status IN ('delayed', 'failed')", limit=12),
        "unassigned": rows("AND d.status = 'pending'", limit=12),
    }


def get_emergency_events(selected_date):
    selected = format_date(selected_date)
    delivery_events = query_all(
        f"""
        SELECT 'delivery' AS source, d.id, d.delivery_address AS location_address,
               d.priority, d.status, d.deadline, d.notes,
               c.name AS client_name
        FROM {DELIVERY_TABLE} d
        LEFT JOIN {CLIENT_TABLE} c ON c.id = d.client_id
        WHERE d.delivery_date = %s AND d.emergency = TRUE
        ORDER BY d.deadline
        LIMIT 10
        """,
        (selected,),
    )
    emergency_rows = query_all(
        f"""
        SELECT 'emergency' AS source, id, location_address,
               priority_level AS priority, status, requested_at AS deadline, reason AS notes,
               location_address AS client_name
        FROM {EMERGENCY_TABLE}
        WHERE DATE(requested_at) = %s
        ORDER BY requested_at DESC
        LIMIT 10
        """,
        (selected,),
    )
    return delivery_events + emergency_rows


def suggest_best_vehicle(package_size, requires_fridge, zone=None):
    conditions = ["status = 'available'"]
    if package_size == "large" or zone == "suburb":
        conditions.append("size = 'large'")
    if requires_fridge:
        conditions.append("has_fridge = TRUE")
    where_clause = " AND ".join(conditions)
    return query_all(
        f"""
        SELECT id, plate_number, model, size, has_fridge, capacity_kg, status
        FROM {VEHICLE_TABLE}
        WHERE {where_clause}
        ORDER BY has_fridge DESC, capacity_kg DESC
        LIMIT 5
        """
    )


def suggest_vehicle_for_emergency(location_lat, location_lon, package_size, requires_fridge):
    conditions = ["status IN ('available', 'in_use')"]
    if package_size == "large":
        conditions.append("size = 'large'")
    if requires_fridge:
        conditions.append("has_fridge = TRUE")
    vehicles = query_all(
        f"""
        SELECT id, plate_number, model, size, has_fridge, capacity_kg,
               current_latitude, current_longitude, current_driver_id
        FROM {VEHICLE_TABLE}
        WHERE {" AND ".join(conditions)}
        """
    )

    suggestions = []
    for vehicle in vehicles:
        if vehicle["current_latitude"] and vehicle["current_longitude"]:
            dist = calculate_distance(
                float(location_lat),
                float(location_lon),
                float(vehicle["current_latitude"]),
                float(vehicle["current_longitude"]),
            )
            vehicle["distance_to_emergency_km"] = round(dist, 2)
            vehicle["eta_minutes"] = calculate_eta_minutes(dist)
            suggestions.append(vehicle)

    suggestions.sort(key=lambda item: item["distance_to_emergency_km"])
    return suggestions[:5]


def get_zone_travel_minutes(cursor, from_zone, to_zone):
    cursor.execute(
        f"""
        SELECT estimated_minutes FROM {ZONE_TRAVEL_TABLE}
        WHERE from_zone = %s AND to_zone = %s
        """,
        (from_zone, to_zone),
    )
    row = cursor.fetchone()
    return int(row["estimated_minutes"]) if row else DEFAULT_TRAVEL_MINUTES


def estimate_zone_distance_km(from_zone, to_zone):
    distances = {
        ("warehouse", "warehouse"): 0,
        ("warehouse", "hospital"): 7,
        ("warehouse", "paris"): 8,
        ("warehouse", "suburb"): 14,
        ("hospital", "warehouse"): 7,
        ("hospital", "hospital"): 2,
        ("hospital", "paris"): 5,
        ("hospital", "suburb"): 12,
        ("paris", "warehouse"): 8,
        ("paris", "hospital"): 5,
        ("paris", "paris"): 4,
        ("paris", "suburb"): 13,
        ("suburb", "warehouse"): 14,
        ("suburb", "hospital"): 12,
        ("suburb", "paris"): 13,
        ("suburb", "suburb"): 9,
    }
    return distances.get((from_zone, to_zone), round((DEFAULT_TRAVEL_MINUTES / 60) * AVERAGE_SPEED_KMH, 2))


def route_warning(delivery, vehicle, arrival_time, route_stop_count, total_minutes):
    warnings = []
    if delivery["deadline"] and arrival_time > delivery["deadline"]:
        warnings.append("Late delivery risk")
    if delivery["requires_fridge"] and not vehicle["has_fridge"]:
        warnings.append("Refrigerated delivery not assigned to refrigerated vehicle")
    if delivery["package_size"] == "large" and vehicle["size"] != "large":
        warnings.append("Wrong vehicle type for large package")
    if route_stop_count > 30 and vehicle["size"] == "small":
        warnings.append("Too many stops for one small van")
    if total_minutes > MAX_DRIVER_HOURS * 60:
        warnings.append("Route over 8 hours")
    if total_minutes > LEGAL_DRIVER_HOURS * 60:
        warnings.append("Route over 10 hours")
    return "; ".join(warnings)


def score_assignment(delivery, assignment):
    vehicle = assignment["vehicle"]
    score = 0
    if delivery["requires_fridge"] and vehicle["has_fridge"]:
        score -= 100
    if delivery["requires_fridge"] and not vehicle["has_fridge"]:
        score += 1000
    if delivery["zone"] == "suburb" and vehicle["size"] == "large":
        score -= 25
    if delivery["zone"] == "paris" and vehicle["size"] == "small":
        score -= 20
    if delivery["package_size"] == "large" and vehicle["size"] == "large":
        score -= 30
    if delivery["package_size"] == "large" and vehicle["size"] != "large":
        score += 200
    score += assignment["total_minutes"]
    return score


def generate_daily_plan(plan_date):
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        selected = format_date(plan_date)

        cursor.execute(
            f"DELETE FROM {ROUTE_TABLE} WHERE route_date = %s AND status IN ('planning', 'active')",
            (selected,),
        )
        cursor.execute(
            f"DELETE FROM {ASSIGNMENT_TABLE} WHERE assignment_date = %s",
            (selected,),
        )
        cursor.execute(
            f"""
            UPDATE {DELIVERY_TABLE}
            SET status = 'pending', assigned_truck_id = NULL, assigned_driver_id = NULL
            WHERE delivery_date = %s AND status IN ('assigned', 'in_transit', 'delayed')
            """,
            (selected,),
        )

        cursor.execute(
            f"""
            SELECT d.*, c.name AS client_name, c.client_type
            FROM {DELIVERY_TABLE} d
            LEFT JOIN {CLIENT_TABLE} c ON c.id = d.client_id
            WHERE d.delivery_date = %s AND d.status = 'pending'
            ORDER BY FIELD(d.priority, 'urgent', 'normal', 'low'),
                     d.requires_fridge DESC,
                     d.deadline
            """,
            (selected,),
        )
        deliveries = cursor.fetchall()

        cursor.execute(
            f"SELECT * FROM {DRIVER_TABLE} WHERE status = 'active' ORDER BY id LIMIT 5"
        )
        drivers = cursor.fetchall()
        cursor.execute(
            f"SELECT * FROM {VEHICLE_TABLE} WHERE status = 'available' ORDER BY has_fridge DESC, size DESC, id LIMIT 6"
        )
        vehicles = cursor.fetchall()

        assignments = []
        for index, driver in enumerate(drivers):
            if index >= len(vehicles):
                break
            vehicle = vehicles[index]
            assignments.append(
                {
                    "driver": driver,
                    "vehicle": vehicle,
                    "deliveries": [],
                    "current_zone": "warehouse",
                    "current_time": start_datetime(
                        plan_date, hospital=vehicle.get("has_fridge", False)
                    ),
                    "total_minutes": 0,
                }
            )

        unassigned = []
        sorted_deliveries = sorted(
            deliveries,
            key=lambda d: (
                PRIORITY_ORDER.get(d["priority"], 9),
                not d["requires_fridge"],
                d["deadline"] or datetime.max,
            ),
        )

        for delivery in sorted_deliveries:
            compatible = []
            for assignment in assignments:
                vehicle = assignment["vehicle"]
                if delivery["requires_fridge"] and not vehicle["has_fridge"]:
                    continue
                if delivery["package_size"] == "large" and vehicle["size"] != "large":
                    continue
                compatible.append(assignment)

            if not compatible:
                unassigned.append(delivery)
                continue

            selected_assignment = min(
                compatible, key=lambda assignment: score_assignment(delivery, assignment)
            )
            selected_assignment["deliveries"].append(delivery)

            travel = get_zone_travel_minutes(
                cursor, selected_assignment["current_zone"], delivery["zone"]
            )
            selected_assignment["total_minutes"] += travel + delivery["service_time_minutes"]
            selected_assignment["current_time"] += timedelta(
                minutes=travel + delivery["service_time_minutes"]
            )
            selected_assignment["current_zone"] = delivery["zone"]

        route_count = 0
        stop_count = 0
        warning_count = 0

        for assignment in assignments:
            route_deliveries = assignment["deliveries"]
            if not route_deliveries:
                continue

            route_start = start_datetime(
                plan_date,
                hospital=any(d["priority"] == "urgent" and d["zone"] == "hospital" for d in route_deliveries),
            )
            cursor.execute(
                f"""
                INSERT INTO {ROUTE_TABLE}
                (route_date, truck_id, driver_id, status, start_time, total_stops)
                VALUES (%s, %s, %s, 'planning', %s, %s)
                """,
                (
                    selected,
                    assignment["vehicle"]["id"],
                    assignment["driver"]["id"],
                    route_start,
                    len(route_deliveries),
                ),
            )
            route_id = cursor.lastrowid
            route_count += 1

            current_zone = "warehouse"
            current_time = route_start
            total_minutes = 0

            for stop_index, delivery in enumerate(route_deliveries, start=1):
                travel = get_zone_travel_minutes(cursor, current_zone, delivery["zone"])
                distance_km = estimate_zone_distance_km(current_zone, delivery["zone"])
                service_minutes = int(delivery["service_time_minutes"])
                current_time += timedelta(minutes=travel)
                arrival = current_time
                current_time += timedelta(minutes=service_minutes)
                total_minutes += travel + service_minutes
                current_zone = delivery["zone"]

                warning_text = route_warning(
                    delivery,
                    assignment["vehicle"],
                    arrival,
                    stop_index,
                    total_minutes,
                )
                if warning_text:
                    warning_count += 1

                cursor.execute(
                    f"""
                    INSERT INTO {ROUTE_STOPS_TABLE}
                    (route_id, delivery_id, stop_order, stop_address, travel_minutes,
                     service_minutes, estimated_distance_km, estimated_arrival_time, warning_text)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        route_id,
                        delivery["id"],
                        stop_index,
                        delivery["delivery_address"],
                        travel,
                        service_minutes,
                        distance_km,
                        arrival,
                        warning_text,
                    ),
                )
                stop_count += 1

            return_minutes = get_zone_travel_minutes(cursor, current_zone, "warehouse")
            total_minutes += return_minutes
            estimated_end = route_start + timedelta(minutes=total_minutes)
            route_warnings = []
            if total_minutes > MAX_DRIVER_HOURS * 60:
                route_warnings.append("Driver hours at risk")
            if total_minutes > LEGAL_DRIVER_HOURS * 60:
                route_warnings.append("Route over legal limit")

            cursor.execute(
                f"""
                UPDATE {ROUTE_TABLE}
                SET total_duration_minutes = %s, estimated_end_time = %s, warning_text = %s
                WHERE id = %s
                """,
                (total_minutes, estimated_end, "; ".join(route_warnings), route_id),
            )

        for delivery in unassigned:
            warning_count += 1
            cursor.execute(
                f"""
                UPDATE {DELIVERY_TABLE}
                SET status = 'pending', notes = CONCAT(COALESCE(notes, ''), ' Unassigned delivery warning.')
                WHERE id = %s
                """,
                (delivery["id"],),
            )

        connection.commit()
        return {
            "routes": route_count,
            "stops": stop_count,
            "warnings": warning_count,
            "unassigned": len(unassigned),
        }
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def refresh_route_warnings(cursor, route_id):
    cursor.execute(
        f"""
        SELECT r.*, c.*
        FROM {ROUTE_TABLE} r
        JOIN {VEHICLE_TABLE} c ON c.id = r.truck_id
        WHERE r.id = %s
        """,
        (route_id,),
    )
    route = cursor.fetchone()
    if not route:
        return

    cursor.execute(
        f"""
        SELECT rs.*, dl.priority, dl.zone, dl.deadline, dl.requires_fridge,
               dl.package_size, dl.service_time_minutes
        FROM {ROUTE_STOPS_TABLE} rs
        JOIN {DELIVERY_TABLE} dl ON dl.id = rs.delivery_id
        WHERE rs.route_id = %s
        ORDER BY rs.stop_order
        """,
        (route_id,),
    )
    stops = cursor.fetchall()
    total_minutes = 0
    for stop in stops:
        total_minutes += int(stop["travel_minutes"] or 0) + int(stop["service_minutes"] or 0)
        warning_text = route_warning(
            stop,
            route,
            stop["estimated_arrival_time"],
            int(stop["stop_order"]),
            total_minutes,
        )
        cursor.execute(
            f"UPDATE {ROUTE_STOPS_TABLE} SET warning_text = %s WHERE id = %s",
            (warning_text, stop["id"]),
        )


def get_assignment_conflicts(plan_date):
    selected = format_date(plan_date)
    driver_rows = query_all(
        f"""
        SELECT driver_id, COUNT(*) AS route_count
        FROM {ROUTE_TABLE}
        WHERE route_date = %s
        GROUP BY driver_id
        """,
        (selected,),
    )
    vehicle_rows = query_all(
        f"""
        SELECT truck_id, COUNT(*) AS route_count
        FROM {ROUTE_TABLE}
        WHERE route_date = %s
        GROUP BY truck_id
        """,
        (selected,),
    )
    busy_drivers = {row["driver_id"] for row in driver_rows if row["driver_id"] and row["route_count"] > 1}
    busy_vehicles = {row["truck_id"] for row in vehicle_rows if row["truck_id"] and row["route_count"] > 1}
    return busy_drivers, busy_vehicles


def get_plan_results(plan_date):
    selected = format_date(plan_date)
    routes = query_all(
        f"""
        SELECT r.*, d.full_name AS driver_name, c.plate_number, c.model, c.size, c.has_fridge
        FROM {ROUTE_TABLE} r
        JOIN {DRIVER_TABLE} d ON d.id = r.driver_id
        JOIN {VEHICLE_TABLE} c ON c.id = r.truck_id
        WHERE r.route_date = %s
        ORDER BY d.id
        """,
        (selected,),
    )
    busy_drivers, busy_vehicles = get_assignment_conflicts(plan_date)
    for route in routes:
        route["assignment_warnings"] = []
        if route["driver_id"] in busy_drivers:
            route["assignment_warnings"].append("Driver is already suggested on another route")
        if route["truck_id"] in busy_vehicles:
            route["assignment_warnings"].append("Vehicle is already suggested on another route")
        route["stops"] = query_all(
            f"""
            SELECT rs.*, dl.priority, dl.zone, dl.deadline, dl.requires_fridge,
                   dl.status, cl.name AS client_name, cl.client_type
            FROM {ROUTE_STOPS_TABLE} rs
            JOIN {DELIVERY_TABLE} dl ON dl.id = rs.delivery_id
            LEFT JOIN {CLIENT_TABLE} cl ON cl.id = dl.client_id
            WHERE rs.route_id = %s
            ORDER BY rs.stop_order
            """,
            (route["id"],),
        )
    return routes


def get_plan_state(plan_date):
    selected = format_date(plan_date)
    row = query_one(
        f"""
        SELECT
            COUNT(*) AS total_routes,
            SUM(status = 'planning') AS draft_routes,
            SUM(status = 'active') AS confirmed_routes
        FROM {ROUTE_TABLE}
        WHERE route_date = %s
        """,
        (selected,),
    )
    total_routes = int(row["total_routes"] or 0)
    draft_routes = int(row["draft_routes"] or 0)
    confirmed_routes = int(row["confirmed_routes"] or 0)
    if draft_routes:
        status = "draft"
    elif confirmed_routes:
        status = "confirmed"
    else:
        status = "none"
    return {
        "status": status,
        "has_plan": total_routes > 0,
        "has_draft": draft_routes > 0,
        "has_confirmed": confirmed_routes > 0,
        "total_routes": total_routes,
        "draft_routes": draft_routes,
        "confirmed_routes": confirmed_routes,
    }


def get_manager_week(selected_date):
    days = week_days(selected_date)
    start, end = days[0], days[-1]
    rows = query_all(
        f"""
        SELECT delivery_date,
               COUNT(*) AS total,
               SUM(priority = 'urgent') AS urgent,
               SUM(requires_fridge = TRUE) AS refrigerated,
               SUM(status = 'pending') AS pending,
               SUM(status IN ('assigned', 'in_transit', 'delivered', 'delayed', 'failed')) AS planned
        FROM {DELIVERY_TABLE}
        WHERE delivery_date BETWEEN %s AND %s
        GROUP BY delivery_date
        """,
        (format_date(start), format_date(end)),
    )
    route_rows = query_all(
        f"""
        SELECT route_date, COUNT(*) AS routes, SUM(total_stops) AS stops
        FROM {ROUTE_TABLE}
        WHERE route_date BETWEEN %s AND %s
        GROUP BY route_date
        """,
        (format_date(start), format_date(end)),
    )
    by_day = {format_date(day): {"date": day, "total": 0, "urgent": 0, "refrigerated": 0, "pending": 0, "planned": 0, "routes": 0, "stops": 0} for day in days}
    for row in rows:
        key = format_date(row["delivery_date"])
        if key in by_day:
            by_day[key].update(row)
    for row in route_rows:
        key = format_date(row["route_date"])
        if key in by_day:
            by_day[key]["routes"] = row["routes"] or 0
            by_day[key]["stops"] = row["stops"] or 0
    return [by_day[format_date(day)] for day in days]


def get_driver_week(selected_date, driver_id):
    days = week_days(selected_date)
    start, end = days[0], days[-1]
    rows = query_all(
        f"""
        SELECT r.route_date, COUNT(DISTINCT r.id) AS routes,
               SUM(r.total_stops) AS stops,
               SUM(r.total_duration_minutes) AS minutes
        FROM {ROUTE_TABLE} r
        WHERE r.driver_id = %s AND r.route_date BETWEEN %s AND %s AND r.status = 'active'
        GROUP BY r.route_date
        """,
        (driver_id, format_date(start), format_date(end)),
    )
    by_day = {format_date(day): {"date": day, "routes": 0, "stops": 0, "minutes": 0} for day in days}
    for row in rows:
        key = format_date(row["route_date"])
        if key in by_day:
            by_day[key].update(row)
    return [by_day[format_date(day)] for day in days]


def get_current_driver():
    return query_one(
        f"SELECT * FROM {DRIVER_TABLE} WHERE account_id = %s",
        (session.get("user_id"),),
    )


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
        if status not in {"ceo", "driver"}:
            status = "driver"
        if fetch_account(username):
            return render_template("register.html", error=True)

        connection = get_db_connection()
        try:
            cursor = connection.cursor()
            cursor.execute(
                f"INSERT INTO {ACCOUNT_TABLE} (username, password, status) VALUES (%s, %s, %s)",
                (username, generate_password_hash(password), status),
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
    if is_manager():
        return redirect(url_for("manager_dashboard"))
    return redirect(url_for("driver_dashboard"))


@app.route("/ceo/dashboard")
@app.route("/manager/dashboard")
def manager_dashboard():
    blocked = manager_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(request.args.get("date"))
    deliveries = get_deliveries(selected_date)
    delivery_groups = get_dashboard_delivery_groups(selected_date)
    emergency_events = get_emergency_events(selected_date)
    summary = get_manager_summary(selected_date)
    recent_routes = get_plan_results(selected_date)
    plan_state = get_plan_state(selected_date)
    return render_template(
        "ceo_dashboard.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        deliveries=deliveries[:12],
        delivery_groups=delivery_groups,
        emergency_events=emergency_events,
        summary=summary,
        routes=recent_routes,
        plan_state=plan_state,
    )


@app.route("/manager/deliveries")
def manager_deliveries():
    blocked = manager_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(request.args.get("date"))
    filters = {
        "priority": request.args.get("priority", ""),
        "zone": request.args.get("zone", ""),
        "status": request.args.get("status", ""),
        "requires_fridge": request.args.get("requires_fridge", ""),
    }
    deliveries = get_deliveries(selected_date, filters)
    plan_state = get_plan_state(selected_date)
    return render_template(
        "deliveries.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        deliveries=deliveries,
        filters=filters,
        plan_state=plan_state,
    )


@app.route("/manager/fleet")
def manager_fleet():
    blocked = manager_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(request.args.get("date"))
    drivers = query_all(f"SELECT * FROM {DRIVER_TABLE} ORDER BY id")
    vehicles = query_all(f"SELECT * FROM {VEHICLE_TABLE} ORDER BY id")
    assignments = query_all(
        f"""
        SELECT a.*, d.full_name, c.plate_number, c.model
        FROM {ASSIGNMENT_TABLE} a
        JOIN {DRIVER_TABLE} d ON d.id = a.driver_id
        JOIN {VEHICLE_TABLE} c ON c.id = a.vehicle_id
        WHERE a.assignment_date = %s
        ORDER BY d.id
        """,
        (format_date(selected_date),),
    )
    plan_state = get_plan_state(selected_date)
    return render_template(
        "fleet.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        drivers=drivers,
        vehicles=vehicles,
        assignments=assignments,
        plan_state=plan_state,
    )


@app.route("/manager/week")
def manager_week():
    blocked = manager_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(request.args.get("date"))
    plan_state = get_plan_state(selected_date)
    return render_template(
        "manager_week.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        week=get_manager_week(selected_date),
        plan_state=plan_state,
    )


@app.route("/edit")
def edit():
    blocked = manager_required()
    if blocked:
        return blocked
    return render_template(
        "edit.html",
        username=session.get("username"),
        drivers=fetch_all(DRIVER_TABLE),
        cars=fetch_all(VEHICLE_TABLE),
    )


@app.route("/add-driver", methods=["POST"])
def add_driver():
    blocked = manager_required()
    if blocked:
        return blocked
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            INSERT INTO {DRIVER_TABLE} (full_name, license_number, phone_number, status)
            VALUES (%s, %s, %s, %s)
            """,
            (
                request.form.get("full_name"),
                request.form.get("license_number"),
                request.form.get("phone_number") or None,
                request.form.get("status", "active"),
            ),
        )
        connection.commit()
        flash("Driver added.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not add driver: {exc}", "error")
    finally:
        connection.close()
    return redirect(url_for("edit"))


@app.route("/add-car", methods=["POST"])
def add_car():
    blocked = manager_required()
    if blocked:
        return blocked
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            INSERT INTO {VEHICLE_TABLE}
            (plate_number, model, color, size, has_fridge, capacity_kg, status)
            VALUES (%s, %s, %s, 'small', FALSE, 80, %s)
            """,
            (
                request.form.get("plate_number"),
                request.form.get("model"),
                request.form.get("color") or None,
                request.form.get("status", "available"),
            ),
        )
        connection.commit()
        flash("Vehicle added.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not add vehicle: {exc}", "error")
    finally:
        connection.close()
    return redirect(url_for("edit"))


@app.route("/delete-driver/<int:driver_id>", methods=["POST"])
def delete_driver(driver_id):
    blocked = manager_required()
    if blocked:
        return blocked
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(f"DELETE FROM {DRIVER_TABLE} WHERE id = %s", (driver_id,))
        connection.commit()
        flash("Driver deleted.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not delete driver: {exc}", "error")
    finally:
        connection.close()
    return redirect(url_for("edit"))


@app.route("/delete-car/<int:car_id>", methods=["POST"])
def delete_car(car_id):
    blocked = manager_required()
    if blocked:
        return blocked
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(f"DELETE FROM {VEHICLE_TABLE} WHERE id = %s", (car_id,))
        connection.commit()
        flash("Vehicle deleted.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not delete vehicle: {exc}", "error")
    finally:
        connection.close()
    return redirect(url_for("edit"))


@app.route("/manager/generate-plan", methods=["GET", "POST"])
def generate_plan():
    blocked = manager_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(request.form.get("date") or request.args.get("date"))
    plan_state = get_plan_state(selected_date)
    if request.method == "GET" and plan_state["has_plan"] and request.args.get("replan") != "1":
        return redirect(url_for("plan_results", plan_date=format_date(selected_date)))
    result = None
    if request.method == "POST":
        result = generate_daily_plan(selected_date)
        flash("Draft route suggestions created. Review and confirm before drivers receive them.", "success")
        return redirect(url_for("plan_results", plan_date=format_date(selected_date), **result))
    pending_count = query_one(
        f"SELECT COUNT(*) AS value FROM {DELIVERY_TABLE} WHERE delivery_date = %s AND status = 'pending'",
        (format_date(selected_date),),
    )["value"]
    return render_template(
        "generate_plan.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        pending_count=pending_count,
        result=result,
        plan_state=plan_state,
    )


@app.route("/manager/plan-results/<plan_date>")
def plan_results(plan_date):
    blocked = manager_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(plan_date)
    routes = get_plan_results(selected_date)
    plan_state = get_plan_state(selected_date)
    drivers = query_all(f"SELECT * FROM {DRIVER_TABLE} WHERE status = 'active' ORDER BY id")
    vehicles = query_all(f"SELECT * FROM {VEHICLE_TABLE} WHERE status = 'available' ORDER BY has_fridge DESC, size DESC, id")
    stats = {
        "routes": request.args.get("routes", len(routes)),
        "stops": request.args.get("stops", sum(len(route["stops"]) for route in routes)),
        "warnings": request.args.get("warnings", ""),
        "unassigned": request.args.get("unassigned", ""),
    }
    return render_template(
        "plan_results.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        routes=routes,
        drivers=drivers,
        vehicles=vehicles,
        plan_state=plan_state,
        stats=stats,
    )


@app.route("/manager/route/<int:route_id>/assignment", methods=["POST"])
def update_route_assignment(route_id):
    blocked = manager_required()
    if blocked:
        return blocked

    driver_id = request.form.get("driver_id")
    vehicle_id = request.form.get("vehicle_id")
    plan_date = request.form.get("plan_date")
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            UPDATE {ROUTE_TABLE}
            SET driver_id = %s, truck_id = %s
            WHERE id = %s AND status = 'planning'
            """,
            (driver_id, vehicle_id, route_id),
        )
        if cursor.rowcount == 0:
            flash("Only draft route suggestions can be edited.", "error")
        else:
            refresh_route_warnings(cursor, route_id)
            connection.commit()
            flash("Draft route assignment updated.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not update route assignment: {exc}", "error")
    finally:
        connection.close()

    return redirect(url_for("plan_results", plan_date=plan_date or format_date(parse_selected_date(None))))


@app.route("/manager/plan-results/<plan_date>/confirm", methods=["POST"])
def confirm_plan(plan_date):
    blocked = manager_required()
    if blocked:
        return blocked

    selected_date = parse_selected_date(plan_date)
    selected = format_date(selected_date)
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            UPDATE {DELIVERY_TABLE} d
            JOIN {ROUTE_STOPS_TABLE} rs ON rs.delivery_id = d.id
            JOIN {ROUTE_TABLE} r ON r.id = rs.route_id
            SET d.assigned_truck_id = r.truck_id,
                d.assigned_driver_id = r.driver_id,
                d.status = 'assigned'
            WHERE r.route_date = %s AND r.status = 'planning' AND d.status = 'pending'
            """,
            (selected,),
        )
        cursor.execute(
            f"""
            UPDATE {ROUTE_TABLE}
            SET status = 'active'
            WHERE route_date = %s AND status = 'planning'
            """,
            (selected,),
        )
        cursor.execute(f"DELETE FROM {ASSIGNMENT_TABLE} WHERE assignment_date = %s", (selected,))
        cursor.execute(
            f"""
            INSERT INTO {ASSIGNMENT_TABLE} (assignment_date, driver_id, vehicle_id)
            SELECT route_date, driver_id, truck_id
            FROM (
                SELECT route_date, driver_id, truck_id,
                       ROW_NUMBER() OVER (PARTITION BY route_date, driver_id ORDER BY id) AS driver_rank,
                       ROW_NUMBER() OVER (PARTITION BY route_date, truck_id ORDER BY id) AS vehicle_rank
                FROM {ROUTE_TABLE}
                WHERE route_date = %s AND status = 'active'
            ) confirmed_routes
            WHERE driver_rank = 1 AND vehicle_rank = 1
            """,
            (selected,),
        )
        connection.commit()
        flash("Plan confirmed. Drivers can now see their routes.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not confirm plan: {exc}", "error")
    finally:
        connection.close()

    return redirect(url_for("plan_results", plan_date=selected))


@app.route("/manager/plan-results/<plan_date>/cancel", methods=["POST"])
def cancel_plan(plan_date):
    blocked = manager_required()
    if blocked:
        return blocked

    selected_date = parse_selected_date(plan_date)
    selected = format_date(selected_date)
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            UPDATE {DELIVERY_TABLE} d
            JOIN {ROUTE_STOPS_TABLE} rs ON rs.delivery_id = d.id
            JOIN {ROUTE_TABLE} r ON r.id = rs.route_id
            SET d.assigned_truck_id = NULL,
                d.assigned_driver_id = NULL,
                d.status = 'pending'
            WHERE r.route_date = %s
              AND r.status IN ('planning', 'active')
              AND d.status IN ('assigned', 'in_transit', 'delayed')
            """,
            (selected,),
        )
        cursor.execute(f"DELETE FROM {ASSIGNMENT_TABLE} WHERE assignment_date = %s", (selected,))
        cursor.execute(
            f"DELETE FROM {ROUTE_TABLE} WHERE route_date = %s AND status IN ('planning', 'active')",
            (selected,),
        )
        connection.commit()
        flash("Plan cancelled. You can suggest a new plan for this date.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not cancel plan: {exc}", "error")
    finally:
        connection.close()

    return redirect(url_for("manager_dashboard", date=selected))


@app.route("/driver/dashboard")
def driver_dashboard():
    blocked = driver_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(request.args.get("date"))
    driver = get_current_driver()
    routes = []
    if driver:
        routes = query_all(
            f"""
            SELECT r.*, c.plate_number, c.model, c.size, c.has_fridge
            FROM {ROUTE_TABLE} r
            JOIN {VEHICLE_TABLE} c ON c.id = r.truck_id
            WHERE r.driver_id = %s AND r.route_date = %s AND r.status = 'active'
            ORDER BY r.id DESC
            """,
            (driver["id"], format_date(selected_date)),
        )
        for route in routes:
            route["stops"] = query_all(
                f"""
                SELECT rs.*, dl.priority, dl.zone, dl.deadline, dl.requires_fridge,
                       dl.status, cl.name AS client_name, cl.client_type
                FROM {ROUTE_STOPS_TABLE} rs
                JOIN {DELIVERY_TABLE} dl ON dl.id = rs.delivery_id
                LEFT JOIN {CLIENT_TABLE} cl ON cl.id = dl.client_id
                WHERE rs.route_id = %s
                ORDER BY rs.stop_order
                """,
                (route["id"],),
            )
    return render_template(
        "driver_dashboard.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        driver=driver,
        routes=routes,
    )


@app.route("/driver/week")
def driver_week():
    blocked = driver_required()
    if blocked:
        return blocked
    selected_date = parse_selected_date(request.args.get("date"))
    driver = get_current_driver()
    week = get_driver_week(selected_date, driver["id"]) if driver else []
    return render_template(
        "driver_week.html",
        username=session.get("username"),
        selected_date=format_date(selected_date),
        driver=driver,
        week=week,
    )


@app.route("/driver/stop/<int:stop_id>/status", methods=["POST"])
def update_stop_status(stop_id):
    blocked = driver_required()
    if blocked:
        return blocked
    driver = get_current_driver()
    if not driver:
        flash("Your driver account is not linked yet.", "error")
        return redirect(url_for("driver_dashboard"))

    new_status = request.form.get("status")
    allowed = {"in_transit", "delivered", "delayed", "failed"}
    if new_status not in allowed:
        flash("Invalid status.", "error")
        return redirect(url_for("driver_dashboard"))

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            SELECT rs.delivery_id
            FROM {ROUTE_STOPS_TABLE} rs
            JOIN {ROUTE_TABLE} r ON r.id = rs.route_id
            WHERE rs.id = %s AND r.driver_id = %s AND r.status = 'active'
            """,
            (stop_id, driver["id"]),
        )
        stop = cursor.fetchone()
        if not stop:
            flash("Stop not found for your route.", "error")
            return redirect(url_for("driver_dashboard"))

        cursor.execute(
            f"""
            UPDATE {ROUTE_STOPS_TABLE}
            SET is_completed = %s, actual_arrival_time = CASE WHEN %s = TRUE THEN NOW() ELSE actual_arrival_time END
            WHERE id = %s
            """,
            (new_status == "delivered", new_status == "delivered", stop_id),
        )
        cursor.execute(
            f"UPDATE {DELIVERY_TABLE} SET status = %s WHERE id = %s",
            (new_status, stop["delivery_id"]),
        )
        connection.commit()
        flash("Stop status updated.", "success")
    except Exception as exc:
        connection.rollback()
        flash(f"Could not update stop: {exc}", "error")
    finally:
        connection.close()
    return redirect(url_for("driver_dashboard"))


@app.route("/api/deliveries", methods=["GET"])
def get_deliveries_api():
    if not is_manager():
        return jsonify({"error": "Unauthorized"}), 403
    selected_date = parse_selected_date(request.args.get("date"))
    return jsonify(get_deliveries(selected_date))


@app.route("/api/suggest-vehicle", methods=["POST"])
def api_suggest_vehicle():
    if not is_manager():
        return jsonify({"error": "Unauthorized"}), 403
    data = request.json or {}
    suggestions = suggest_best_vehicle(
        data.get("package_size"),
        data.get("requires_fridge", False),
        data.get("zone"),
    )
    return jsonify(suggestions)


@app.route("/api/assign-delivery", methods=["POST"])
def api_assign_delivery():
    if not is_manager():
        return jsonify({"error": "Unauthorized"}), 403
    data = request.json or {}
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            UPDATE {DELIVERY_TABLE}
            SET assigned_truck_id = %s, assigned_driver_id = %s, status = 'assigned'
            WHERE id = %s
            """,
            (data.get("truck_id"), data.get("driver_id"), data.get("delivery_id")),
        )
        connection.commit()
        return jsonify({"success": True, "message": "Delivery assigned successfully"})
    except Exception as exc:
        connection.rollback()
        return jsonify({"error": str(exc)}), 400
    finally:
        connection.close()


@app.route("/api/emergency-suggestion", methods=["POST"])
def api_emergency_suggestion():
    if not is_manager():
        return jsonify({"error": "Unauthorized"}), 403
    data = request.json or {}
    suggestions = suggest_vehicle_for_emergency(
        float(data.get("latitude", WAREHOUSE_LAT)),
        float(data.get("longitude", WAREHOUSE_LON)),
        data.get("package_size", "small"),
        data.get("requires_fridge", False),
    )
    return jsonify(suggestions)


@app.route("/api/create-emergency", methods=["POST"])
def api_create_emergency():
    if not is_manager():
        return jsonify({"error": "Unauthorized"}), 403
    data = request.json or {}
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"""
            INSERT INTO {EMERGENCY_TABLE}
            (location_address, location_latitude, location_longitude, package_size,
             requires_fridge, package_weight_kg, assigned_truck_id, assigned_driver_id, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'assigned')
            """,
            (
                data.get("location_address", "Emergency Location"),
                float(data.get("latitude", WAREHOUSE_LAT)),
                float(data.get("longitude", WAREHOUSE_LON)),
                data.get("package_size", "small"),
                data.get("requires_fridge", False),
                data.get("package_weight", 10),
                data.get("truck_id"),
                data.get("driver_id"),
            ),
        )
        connection.commit()
        return jsonify(
            {
                "success": True,
                "emergency_id": cursor.lastrowid,
                "message": "Emergency delivery created",
            }
        )
    except Exception as exc:
        connection.rollback()
        return jsonify({"error": str(exc)}), 400
    finally:
        connection.close()


@app.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out.", "success")
    return redirect(url_for("login"))


if __name__ == "__main__":
    app.run(debug=True)
