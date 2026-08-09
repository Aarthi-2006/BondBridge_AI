from flask import Blueprint, jsonify, request
from database import get_connection

homework = Blueprint("homework", __name__)

# GET all homework
@homework.route("/homework", methods=["GET"])
def get_homework():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        teacher_id = request.args.get("teacher_id")
        class_name = request.args.get("class")
        section = request.args.get("section")
        subject = request.args.get("subject")

        query = """
        SELECT *
        FROM homework
        WHERE 1=1
        """

        params = []

        if teacher_id:
            query += " AND teacher_id=%s"
            params.append(teacher_id)

        if class_name:
            query += " AND class=%s"
            params.append(class_name)

        if section:
            query += " AND section=%s"
            params.append(section)

        if subject:
            query += " AND subject=%s"
            params.append(subject)

        query += " ORDER BY created_at DESC"

        cursor.execute(query, params)
        homework_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "homework": homework_list
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "message": str(e)
        }), 500

# ADD homework
@homework.route("/homework", methods=["POST"])
def add_homework():
    try:
        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO homework
        (teacher_id, class, section, subject, title, description, assigned_date, due_date, status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            data["teacher_id"],
            data["class"],
            data["section"],
            data["subject"],
            data["title"],
            data["description"],
            data["assigned_date"],
            data["due_date"],
            data.get("status", "Active")
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