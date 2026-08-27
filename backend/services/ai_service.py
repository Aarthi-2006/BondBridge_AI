import requests


OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "gemma3:4b"


def generate_ai_response(prompt):
    """
    Send a prompt to Ollama and return the generated AI response.
    """

    try:
        response = requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False
            },
            timeout=300
        )

        response.raise_for_status()

        data = response.json()

        return data.get("response", "").strip()

    except requests.exceptions.ConnectionError:
        raise Exception(
            "Unable to connect to Ollama. Make sure Ollama is running."
        )

    except requests.exceptions.Timeout:
        raise Exception(
            "Ollama request timed out."
        )

    except requests.exceptions.RequestException as e:
        raise Exception(
            f"Ollama request failed: {str(e)}"
        )