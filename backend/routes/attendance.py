from flask import Blueprint, jsonify, request
from database import get_connection

attendance = Blueprint("attendance", __name__)

# GET all attendance records
@attendance.route("/attendance", methods=["GET"])
def get_attendance():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM attendance")
        attendance_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(attendance_list)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ADD attendance
@attendance.route("/attendance", methods=["POST"])
def add_attendance():
    try:
        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO attendance
        (student_id, teacher_id, attendance_date, status)
        VALUES (%s, %s, %s, %s)
        """

        values = (
            data["student_id"],
            data["teacher_id"],
            data["attendance_date"],
            data["status"]
        )

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Attendance added successfully"
        }), 201

    except Exception as e:
        return jsonify({
            "success": False,
            "message": str(e)
        }), 500