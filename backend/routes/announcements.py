from flask import Blueprint, jsonify, request

announcements = Blueprint("announcements", __name__)


@announcements.route("/announcements", methods=["GET"])
def get_announcements():
    return jsonify({
        "message": "Announcements list"
    })


@announcements.route("/announcements", methods=["POST"])
def add_announcement():
    data = request.json

    return jsonify({
        "message": "Announcement added successfully",
        "data": data
    })