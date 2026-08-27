import requests


OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "gemma3:1b"


def generate_ai_response(prompt):
    """
    Send a prompt to Ollama and return the generated AI response.
    """

    print("🔵 AI SERVICE STARTED")
    print("📝 Prompt:", prompt)
    print("🤖 Model:", OLLAMA_MODEL)
    print("🔗 Ollama URL:", OLLAMA_URL)

    try:

        print("📡 Sending request to Ollama...")

        response = requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False
            },
            timeout=60
        )

        print("📥 Ollama HTTP Status:", response.status_code)

        response.raise_for_status()

        data = response.json()

        print("📦 Ollama response received")

        ai_response = data.get("response", "").strip()

        print("✅ AI response:", ai_response)

        if not ai_response:
            raise Exception("Ollama returned an empty response.")

        return ai_response

    except requests.exceptions.ConnectionError as e:

        print("❌ Ollama connection error:", e)

        raise Exception(
            "Unable to connect to Ollama. "
            "Make sure Ollama is running on port 11434."
        )

    except requests.exceptions.Timeout as e:

        print("⏰ Ollama timeout:", e)

        raise Exception(
            "Ollama took too long to respond."
        )

    except requests.exceptions.RequestException as e:

        print("❌ Ollama request error:", e)

        raise Exception(
            f"Ollama request failed: {str(e)}"
        )

    except Exception as e:

        print("❌ AI service error:", e)

        raise