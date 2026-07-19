from flask import Blueprint, jsonify, request

marks = Blueprint("marks", __name__)


@marks.route("/marks", methods=["GET"])
def get_marks():
    return jsonify({
        "message": "Marks list"
    })


@marks.route("/marks", methods=["POST"])
def add_marks():
    data = request.json

    return jsonify({
        "message": "Marks added successfully",
        "data": data
    })