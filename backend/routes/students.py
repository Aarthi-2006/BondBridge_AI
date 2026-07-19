from flask import Blueprint, jsonify, request

students = Blueprint("students", __name__)


@students.route("/students", methods=["GET"])
def get_students():
    return jsonify({
        "message": "Students list"
    })


@students.route("/students", methods=["POST"])
def add_student():
    data = request.json

    return jsonify({
        "message": "Student added successfully",
        "data": data
    })