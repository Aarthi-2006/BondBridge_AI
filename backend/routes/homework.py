from flask import Blueprint, jsonify, request

homework = Blueprint("homework", __name__)


@homework.route("/homework", methods=["GET"])
def get_homework():
    return jsonify({
        "message": "Homework list"
    })


@homework.route("/homework", methods=["POST"])
def add_homework():
    data = request.json

    return jsonify({
        "message": "Homework added successfully",
        "data": data
    })