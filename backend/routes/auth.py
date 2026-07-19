from flask import Blueprint, jsonify, request

auth = Blueprint("auth", __name__)


@auth.route("/login", methods=["POST"])
def login():

    data = request.json

    email = data.get("email")
    password = data.get("password")

    if email == "admin@gmail.com" and password == "12345":
        return jsonify({
            "message": "Login successful",
            "role": "admin"
        })

    return jsonify({
        "message": "Invalid email or password"
    }), 401