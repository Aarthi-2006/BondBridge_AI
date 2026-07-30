from flask import Blueprint, jsonify, request
from database import get_connection

announcements = Blueprint("announcements", __name__)

# GET all announcements
@announcements.route("/announcements", methods=["GET"])
def get_announcements():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM announcements")
        announcement_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(announcement_list)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ADD announcement
@announcements.route("/announcements", methods=["POST"])
def add_announcement():
    try:
        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO announcements
        (teacher_id, title, message)
        VALUES (%s, %s, %s)
        """

        values = (
            data["teacher_id"],
            data["title"],
            data["message"]
        )

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Announcement added successfully"
        }), 201

    except Exception as e:
        return jsonify({
            "success": False,
            "message": str(e)
        }), 500