from flask import Blueprint, jsonify, request

teachers = Blueprint("teachers", __name__)


@teachers.route("/teachers", methods=["GET"])
def get_teachers():
    return jsonify({
        "message": "Teachers list"
    })


@teachers.route("/teachers", methods=["POST"])
def add_teacher():
    data = request.json

    return jsonify({
        "message": "Teacher added successfully",
        "data": data
    })