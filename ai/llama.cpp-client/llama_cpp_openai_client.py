import requests
import json
import random

"""
Find IP of llama.cpp when it's running on Windows and this script is in WSL:
    export LLAMA_HOST=$(ip route | awk '/default/ {print $3}')
"""

BASE_URL = "http://172.30.48.1:8080/v1"


def list_models():
    resp = requests.get(f"{BASE_URL}/models")
    resp.raise_for_status()
    return resp.json().get("data", [])


def model_supports_tools(model_obj):
    """
    Heuristic check for tool/function-calling support.
    llama.cpp OpenAI-compatible servers may expose capabilities in different ways.
    We try a few common patterns and fall back to name-based heuristics.
    """
    # 1) Explicit capabilities flags (best case)
    caps = model_obj.get("capabilities") or model_obj.get("metadata") or {}
    if isinstance(caps, dict):
        if caps.get("tool_use") is True or caps.get("function_calling") is True:
            return True

    # 2) Some servers expose a list of supported features
    features = model_obj.get("features") or []
    if isinstance(features, list) and any(f in features for f in ["tools", "function_calling", "tool_use"]):
        return True

    # 3) Fallback: name heuristics (not perfect, but practical)
    mid = (model_obj.get("id") or "").lower()
    if any(k in mid for k in ["instruct", "chat", "function", "tool"]):
        return True

    return False


def pick_model(models):
    if not models:
        raise RuntimeError("No models available")

    if len(models) > 1:
        print("Warning: more than one model found, picking the first one")

    chosen = models[0]

    if not model_supports_tools(chosen):
        raise RuntimeError(
            f"Selected model '{chosen.get('id')}' does not appear to support tool/function calling."
        )

    return chosen["id"]


# Tool implementation (local)
def generate_random_number():
    return random.randint(0, 100)


def run_agent(model):
    url = f"{BASE_URL}/responses"

    # Step 1: ask model, provide tool
    response = requests.post(url, json={
        "model": model,
        "input": "Use the tool to get a random number, then double it and return the result.",
        "tools": [
            {
                "type": "function",
                "function": {
                    "name": "generate_random_number",
                    "description": "Generate a random integer between 0 and 100",
                    "parameters": {
                        "type": "object",
                        "properties": {},
                        "required": []
                    }
                }
            }
        ]
    })

    response.raise_for_status()
    data = response.json()

    # Step 2: check if model wants to call tool
    tool_calls = data.get("output", [])

    for item in tool_calls:
        if item.get("type") == "tool_call":
            name = item["name"]
            call_id = item["id"]

            if name == "generate_random_number":
                result = generate_random_number()
                print("Tool generated:", result)

                # Step 3: send tool result back
                follow_up = requests.post(url, json={
                    "model": model,
                    "input": [
                        {
                            "type": "tool_result",
                            "tool_name": name,
                            "tool_call_id": call_id,
                            "content": str(result)
                        }
                    ]
                })

                follow_up.raise_for_status()
                return follow_up.json()

    return data


def main():
    models = list_models()
    print("Available models:", models)

    model_id = pick_model(models)
    print("Using model:", model_id)

    final_response = run_agent(model_id)

    print("Final response:")
    print(json.dumps(final_response, indent=2))


if __name__ == "__main__":
    main()
