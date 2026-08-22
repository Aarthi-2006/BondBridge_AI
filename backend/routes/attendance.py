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

        for record in data["attendance"]:

            values = (
                record["student_id"],
                data["teacher_id"],
                data["attendance_date"],
                record["status"]
            )

            cursor.execute(query, values)

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Attendance saved successfully"
        }), 201


    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500
        # =====================================
# VIEW ATTENDANCE BY CLASS, SECTION & DATE
# =====================================

@attendance.route("/attendance/view", methods=["GET"])
def view_attendance():

    try:

        student_class = request.args.get("class")
        section = request.args.get("section")
        attendance_date = request.args.get("date")

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
        SELECT
            s.student_id,
            u.full_name AS student_name,
            a.status
        FROM students s
        JOIN users u
            ON s.user_id = u.user_id
        LEFT JOIN attendance a
            ON s.student_id = a.student_id
            AND a.attendance_date = %s
        WHERE s.class = %s
        AND s.section = %s
        ORDER BY u.full_name
        """

        cursor.execute(
            query,
            (attendance_date, student_class, section)
        )

        students = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "total": len(students),
            "students": students
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500
# =====================================
# VIEW ATTENDANCE FOR ONE STUDENT
# =====================================

# =====================================
# VIEW STUDENT OWN ATTENDANCE
# =====================================

@attendance.route("/attendance/student/<int:student_id>", methods=["GET"])
def view_student_attendance(student_id):

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
        SELECT
            a.attendance_date,
            a.status
        FROM attendance a
        WHERE a.student_id = %s
        ORDER BY a.attendance_date DESC
        """

        cursor.execute(query, (student_id,))

        attendance_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "total": len(attendance_list),
            "attendance": attendance_list
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "attendance": [],
            "total": 0,
            "message": str(e)
        }), 500