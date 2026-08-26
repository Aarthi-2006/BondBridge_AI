from flask import Blueprint, jsonify
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