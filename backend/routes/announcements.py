from flask import Blueprint, jsonify, request
from database import get_connection

announcements = Blueprint("announcements", __name__)

# =====================================================
# GET ALL ANNOUNCEMENTS
# =====================================================

@announcements.route("/announcements", methods=["GET"])
def get_announcements():

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT *
            FROM announcements
            ORDER BY created_at DESC
        """)

        data = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "total": len(data),
            "announcements": data
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


# =====================================================
# GET SINGLE ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements/<int:announcement_id>", methods=["GET"])
def get_single_announcement(announcement_id):

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT *
            FROM announcements
            WHERE announcement_id=%s
        """, (announcement_id,))

        announcement = cursor.fetchone()

        cursor.close()
        conn.close()

        if not announcement:

            return jsonify({
                "success": False,
                "message": "Announcement not found"
            }), 404

        return jsonify({
            "success": True,
            "announcement": announcement
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


# =====================================================
# ADD ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements", methods=["POST"])
def add_announcement():

    try:

        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO announcements
            (
                teacher_id,
                title,
                message,
                target_audience,
                created_by
            )
            VALUES
            (
                %s,%s,%s,%s,%s
            )
        """, (

            None,
            data["title"],
            data["message"],
            data["target_audience"],
            "Admin"

        ))

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({

            "success": True,
            "message": "Announcement added successfully"

        }),201

    except Exception as e:

        return jsonify({

            "success": False,
            "message": str(e)

        }),500


# =====================================================
# UPDATE ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements/<int:announcement_id>", methods=["PUT"])
def update_announcement(announcement_id):

    try:

        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""

            UPDATE announcements

            SET

            title=%s,
            message=%s,
            target_audience=%s

            WHERE announcement_id=%s

        """,(

            data["title"],
            data["message"],
            data["target_audience"],
            announcement_id

        ))

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({

            "success": True,
            "message": "Announcement updated successfully"

        })

    except Exception as e:

        return jsonify({

            "success": False,
            "message": str(e)

        }),500


# =====================================================
# DELETE ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements/<int:announcement_id>", methods=["DELETE"])
def delete_announcement(announcement_id):

    try:

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""

            DELETE FROM announcements

            WHERE announcement_id=%s

        """,(announcement_id,))

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({

            "success": True,
            "message": "Announcement deleted successfully"

        })

    except Exception as e:

        return jsonify({

            "success": False,
            "message": str(e)

        }),500