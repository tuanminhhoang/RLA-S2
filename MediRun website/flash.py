import os

import pymysql
from dotenv import load_dotenv
from flask import Flask, flash, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash, generate_password_hash

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "medi-run-dev-key")

ACCOUNT_TABLE = "accounts"
DRIVER_TABLE = "drivers"
CAR_TABLE = "cars"


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
    if "$" in stored_password:
        return check_password_hash(stored_password, candidate_password)
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


def is_admin():
    return session.get("status") == "admin"


def admin_only():
    if not session.get("username"):
        return redirect(url_for("login"))
    if not is_admin():
        flash("Admin access required.", "error")
        return redirect(url_for("dashboard"))
    return None


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

        if status not in {"admin", "driver"}:
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
    return render_template(
        "dashboard.html",
        username=session.get("username"),
        status=session.get("status"),
    )


@app.route("/edit")
def edit():
    denied = admin_only()
    if denied:
        return denied

    drivers = fetch_all(DRIVER_TABLE)
    cars = fetch_all(CAR_TABLE)
    return render_template(
        "edit.html",
        username=session.get("username"),
        drivers=drivers,
        cars=cars,
    )


@app.route("/edit/add-driver", methods=["POST"])
def add_driver():
    denied = admin_only()
    if denied:
        return denied

    full_name = request.form.get("full_name", "").strip()
    license_number = request.form.get("license_number", "").strip()
    phone_number = request.form.get("phone_number", "").strip() or None
    status = request.form.get("status", "active")

    if not full_name or not license_number:
        flash("Driver name and license number are required.", "error")
        return redirect(url_for("edit"))

    if status not in {"active", "inactive"}:
        status = "active"

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"INSERT INTO {DRIVER_TABLE} (full_name, license_number, phone_number, status) VALUES (%s, %s, %s, %s)",
            (full_name, license_number, phone_number, status),
        )
        connection.commit()
    except Exception:
        connection.rollback()
        flash("Unable to add driver. Check for duplicate license number.", "error")
        return redirect(url_for("edit"))
    finally:
        connection.close()

    flash("Driver added successfully.", "success")
    return redirect(url_for("edit"))


@app.route("/edit/delete-driver/<int:driver_id>", methods=["POST"])
def delete_driver(driver_id):
    denied = admin_only()
    if denied:
        return denied

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(f"DELETE FROM {DRIVER_TABLE} WHERE id = %s", (driver_id,))
        connection.commit()
    finally:
        connection.close()

    flash("Driver deleted successfully.", "info")
    return redirect(url_for("edit"))


@app.route("/edit/add-car", methods=["POST"])
def add_car():
    denied = admin_only()
    if denied:
        return denied

    plate_number = request.form.get("plate_number", "").strip()
    model = request.form.get("model", "").strip()
    color = request.form.get("color", "").strip() or None
    status = request.form.get("status", "available")

    if not plate_number or not model:
        flash("Plate number and model are required.", "error")
        return redirect(url_for("edit"))

    if status not in {"available", "in_use", "maintenance"}:
        status = "available"

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(
            f"INSERT INTO {CAR_TABLE} (plate_number, model, color, status) VALUES (%s, %s, %s, %s)",
            (plate_number, model, color, status),
        )
        connection.commit()
    except Exception:
        connection.rollback()
        flash("Unable to add car. Check for duplicate plate number.", "error")
        return redirect(url_for("edit"))
    finally:
        connection.close()

    flash("Car added successfully.", "success")
    return redirect(url_for("edit"))


@app.route("/edit/delete-car/<int:car_id>", methods=["POST"])
def delete_car(car_id):
    denied = admin_only()
    if denied:
        return denied

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(f"DELETE FROM {CAR_TABLE} WHERE id = %s", (car_id,))
        connection.commit()
    finally:
        connection.close()

    flash("Car deleted successfully.", "info")
    return redirect(url_for("edit"))


@app.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for("login"))


if __name__ == "__main__":
    app.run(debug=True)
