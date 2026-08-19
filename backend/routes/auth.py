from flask import Blueprint, request, jsonify
from database import get_connection

auth = Blueprint("auth", __name__)


@auth.route("/login", methods=["POST"])
def login():

    try:

        data = request.get_json()

        email = data.get("email")
        password = data.get("password")

        conn = get_connection()

        cursor = conn.cursor(dictionary=True)

        query = """
        SELECT
        u.user_id,
        u.full_name,
        u.email,
        u.role,
        t.teacher_id
        FROM users u
        LEFT JOIN teachers t
        ON u.user_id = t.user_id
        WHERE u.email=%s
        AND u.password=%s
        """

        cursor.execute(query, (email, password))

        user = cursor.fetchone()

        cursor.close()
        conn.close()


        if user:

            return jsonify({

                "success": True,

                "message": "Login successful",

                "role": user["role"],

                "user": user

            })


        return jsonify({

            "success": False,

            "message": "Invalid Email or Password"

        }), 401



    except Exception as e:

        return jsonify({

            "success": False,

            "message": str(e)

        }), 500
@auth.route("/admin/profile", methods=["GET"])
def admin_profile():

    try:

        conn = get_connection()

        cursor = conn.cursor(dictionary=True)

        query = """
        SELECT
            user_id,
            full_name,
            email,
            role,
            created_at
        FROM users
        WHERE role = 'Admin'
        LIMIT 1
        """

        cursor.execute(query)

        admin = cursor.fetchone()

        cursor.close()
        conn.close()

        if admin:

            return jsonify({
                "success": True,
                "admin": admin
            })

        return jsonify({
            "success": False,
            "message": "Admin not found"
        }), 404


    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500