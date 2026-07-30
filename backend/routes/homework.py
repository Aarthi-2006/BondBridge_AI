from flask import Blueprint, jsonify, request
from database import get_connection

homework = Blueprint("homework", __name__)

# GET all homework
@homework.route("/homework", methods=["GET"])
def get_homework():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM homework")
        homework_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(homework_list)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ADD homework
@homework.route("/homework", methods=["POST"])
def add_homework():
    try:
        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO homework
        (teacher_id, class, section, subject, title, description, due_date)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            data["teacher_id"],
            data["class"],
            data["section"],
            data["subject"],
            data["title"],
            data["description"],
            data["due_date"]
        )

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Homework added successfully"
        }), 201

    except Exception as e:
        return jsonify({
            "success": False,
            "message": str(e)
        }), 500