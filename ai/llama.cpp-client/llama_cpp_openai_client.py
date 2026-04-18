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


def pick_model(models):
    if not models:
        raise RuntimeError("No models available")
    return models[0]["id"]


# Tool implementation (local)
def generate_random_number():
    return random.randint(0, 100)


def call_completion(model, prompt):
    """
    Use llama.cpp's simpler completion-style endpoint instead of Responses API.
    """
    url = f"{BASE_URL}/chat/completions"

    resp = requests.post(url, json={
        "model": model,
        "messages": [
            {"role": "system", "content": "You can call tools by returning JSON."},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0
    })

    resp.raise_for_status()
    return resp.json()


def run_agent(model):
    """
    Simple manual agent loop using JSON-based tool calling.
    """

    prompt = """
You have access to this tool:

- generate_random_number(): returns integer 0-100

Instructions:
1. First call the tool
2. Then double the result

If calling a tool, respond ONLY with JSON like:
{"tool": "generate_random_number", "arguments": {}}

Otherwise return final answer as plain text.
"""

    # Step 1: ask model what to do
    response = call_completion(model, prompt)

    content = response["choices"][0]["message"]["content"]
    print("Model response:", content)

    # Step 2: try to parse tool call
    try:
        data = json.loads(content)
    except json.JSONDecodeError:
        print("Model did not return JSON, aborting")
        return content

    if data.get("tool") == "generate_random_number":
        result = generate_random_number()
        print("Tool generated:", result)

        # Step 3: send result back
        followup_prompt = f"""
The tool returned: {result}

Now double it and return the final answer.
"""

        final = call_completion(model, followup_prompt)
        final_content = final["choices"][0]["message"]["content"]
        return final_content

    return content


def main():
    models = list_models()
    print("Available models:", models)

    model_id = pick_model(models)
    print("Using model:", model_id)

    final_response = run_agent(model_id)

    print("Final response:")
    print(final_response)


if __name__ == "__main__":
    main()
