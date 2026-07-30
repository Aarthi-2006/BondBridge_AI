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
            SELECT user_id, full_name, email, role
            FROM users
            WHERE email=%s AND password=%s
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