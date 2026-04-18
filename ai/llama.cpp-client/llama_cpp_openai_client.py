import requests
import json
import random
import click

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


# ------------------ TOOLS ------------------

def generate_random_number():
    return random.randint(0, 100)


TOOLS = {
    "generate_random_number": generate_random_number
}


def call_completion(model, messages):
    url = f"{BASE_URL}/chat/completions"

    resp = requests.post(url, json={
        "model": model,
        "messages": messages,
        "temperature": 0
    })

    resp.raise_for_status()
    return resp.json()


# ------------------ AGENT LOOP ------------------

def run_agent(model, user_prompt):
    system_prompt = """
You are an agent that can use tools.

Available tools:
- generate_random_number(): returns integer 0-100

Rules:
- If a tool is needed, respond ONLY with JSON:
  {"tool": "tool_name", "arguments": {}}
- Otherwise, respond with the final answer as plain text.
- You may call tools multiple times.
"""

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt}
    ]

    while True:
        response = call_completion(model, messages)
        content = response["choices"][0]["message"]["content"]

        print("Model:", content)

        # Try parse JSON
        try:
            data = json.loads(content)
        except json.JSONDecodeError:
            # Not a tool call → final answer
            return content

        tool_name = data.get("tool")

        if tool_name not in TOOLS:
            print("Unknown tool, stopping")
            return content

        # Execute tool
        result = TOOLS[tool_name]()
        print(f"Tool [{tool_name}] ->", result)

        # Append tool interaction to conversation
        messages.append({
            "role": "assistant",
            "content": content
        })

        messages.append({
            "role": "user",
            "content": f"Tool {tool_name} returned: {result}"
        })


# ------------------ CLI ------------------

@click.command()
@click.option("-p", "--prompt", required=True, help="Prompt for the agent")
def main(prompt):
    models = list_models()
    print("Available models:", models)

    model_id = pick_model(models)
    print("Using model:", model_id)

    result = run_agent(model_id, prompt)

    print("\nFinal response:")
    print(result)


if __name__ == "__main__":
    main()
