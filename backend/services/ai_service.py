import os
import requests


# ---------------------------------------------------------
# Local Ollama configuration
# ---------------------------------------------------------
OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "gemma3:1b"


# ---------------------------------------------------------
# Cloud Groq configuration
# ---------------------------------------------------------
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "openai/gpt-oss-20b"


def generate_ai_response(prompt):
    """
    Generate an AI response.

    Local development:
        Uses Ollama.

    Render/cloud deployment:
        Uses Groq when GROQ_API_KEY is available.
    """

    groq_api_key = os.environ.get("GROQ_API_KEY")

    # =====================================================
    # CLOUD: GROQ
    # =====================================================
    if groq_api_key:
        print("🟢 AI SERVICE: GROQ")
        print("📝 Prompt:", prompt)
        print("🤖 Groq Model:", GROQ_MODEL)

        try:
            print("📡 Sending request to Groq...")

            response = requests.post(
                GROQ_URL,
                headers={
                    "Authorization": f"Bearer {groq_api_key}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": GROQ_MODEL,
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": 0.3
                },
                timeout=120
            )

            print("📥 Groq HTTP Status:", response.status_code)

            response.raise_for_status()

            data = response.json()

            print("📦 Groq response received")

            ai_response = (
                data.get("choices", [{}])[0]
                .get("message", {})
                .get("content", "")
                .strip()
            )

            print("✅ Groq AI response:", ai_response)

            if not ai_response:
                raise Exception("Groq returned an empty response.")

            return ai_response

        except requests.exceptions.ConnectionError as e:
            print("❌ Groq connection error:", e)
            raise Exception(
                "Unable to connect to Groq."
            )

        except requests.exceptions.Timeout as e:
            print("⏰ Groq timeout:", e)
            raise Exception(
                "Groq took too long to respond."
            )

        except requests.exceptions.RequestException as e:
            print("❌ Groq request error:", e)

            try:
                print("📄 Groq error response:", response.text)
            except Exception:
                pass

            raise Exception(
                f"Groq request failed: {str(e)}"
            )

        except Exception as e:
            print("❌ Groq AI service error:", e)
            raise


    # =====================================================
    # LOCAL: OLLAMA
    # =====================================================
    print("🔵 AI SERVICE: OLLAMA")
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

        print("✅ Ollama AI response:", ai_response)

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