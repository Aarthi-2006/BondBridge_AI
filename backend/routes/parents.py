from flask import Blueprint, jsonify, request
from database import get_connection

parents = Blueprint("parents", __name__)

# GET all parents
@parents.route("/parents", methods=["GET"])
def get_parents():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM parents")
        parent_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(parent_list)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ADD parent
@parents.route("/parents", methods=["POST"])
def add_parent():
    try:
        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO parents
        (user_id, student_id, relationship, phone, occupation)
        VALUES (%s, %s, %s, %s, %s)
        """

        values = (
            data["user_id"],
            data["student_id"],
            data["relationship"],
            data["phone"],
            data["occupation"]
        )

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Parent added successfully"
        }), 201

    except Exception as e:
        return jsonify({
            "success": False,
            "message": str(e)
        }), 500