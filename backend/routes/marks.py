from flask import Blueprint, jsonify, request
from database import get_connection

marks = Blueprint("marks", __name__)

# GET all marks
@marks.route("/marks", methods=["GET"])
def get_marks():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM marks")
        marks_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(marks_list)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ADD marks
@marks.route("/marks", methods=["POST"])
def add_marks():
    try:
        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO marks
        (student_id, teacher_id, subject, exam_name, marks_obtained, total_marks)
        VALUES (%s, %s, %s, %s, %s, %s)
        """

        values = (
            data["student_id"],
            data["teacher_id"],
            data["subject"],
            data["exam_name"],
            data["marks_obtained"],
            data["total_marks"]
        )

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Marks added successfully"
        }), 201

    except Exception as e:
        return jsonify({
            "success": False,
            "message": str(e)
        }), 500