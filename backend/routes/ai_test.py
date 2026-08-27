from flask import Blueprint, jsonify, request
from services.ai_service import generate_ai_response

ai_test = Blueprint("ai_test", __name__)


@ai_test.route("/test-ollama", methods=["GET"])
def test_ollama():

    try:
        response = generate_ai_response(
            "Reply with exactly: Flask to Ollama connection successful"
        )

        return jsonify({
            "success": True,
            "response": response
        }), 200

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


@ai_test.route("/ask-ai", methods=["POST"])
def ask_ai():

    try:
        data = request.get_json()

        question = data.get("question", "").strip()

        if not question:
            return jsonify({
                "success": False,
                "message": "Question is required"
            }), 400

        response = generate_ai_response(question)

        return jsonify({
            "success": True,
            "response": response
        }), 200

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500