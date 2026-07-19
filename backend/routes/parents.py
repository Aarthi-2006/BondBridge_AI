from flask import Blueprint, jsonify, request

parents = Blueprint("parents", __name__)


@parents.route("/parents", methods=["GET"])
def get_parents():
    return jsonify({
        "message": "Parents list"
    })


@parents.route("/parents", methods=["POST"])
def add_parent():
    data = request.json

    return jsonify({
        "message": "Parent added successfully",
        "data": data
    })