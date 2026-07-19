from flask import Blueprint, jsonify, request

attendance = Blueprint("attendance", __name__)


@attendance.route("/attendance", methods=["GET"])
def get_attendance():
    return jsonify({
        "message": "Attendance list"
    })


@attendance.route("/attendance", methods=["POST"])
def add_attendance():
    data = request.json

    return jsonify({
        "message": "Attendance added successfully",
        "data": data
    })