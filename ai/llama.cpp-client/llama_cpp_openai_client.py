import requests
import json
import random
import click
from typing import Callable, Any

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

def generate_random_number() -> Any:
    return random.randint(0, 100)


readonly_tools: dict[str, Callable] = {
    "generate_random_number": generate_random_number
}

write_tools: dict[str, Callable] = {
    # Add side-effect tools here if needed
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

def run_agent(model, tools, user_prompt):
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
            # Not JSON → final answer
            return content

        # If JSON but not a dict (e.g. number like 54), treat as final answer
        if not isinstance(data, dict):
            return content

        tool_name = data.get("tool")

        if tool_name not in tools:
            print("Unknown tool, stopping")
            return content

        # Execute tool
        result = tools[tool_name]()
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
@click.option("-d", "--debug", is_flag=True, help="Enable debug mode")
@click.option("-ro", "--real-only", is_flag=True,
              help="Only allow read-only tools (no side effects)")
def main(prompt, debug, real_only):
    models = list_models()
    if (debug):
        print("Available models:", models)

    model_id = pick_model(models)
    print("Using model:", model_id)

    tools = readonly_tools if real_only else {**readonly_tools, **write_tools}
    result = run_agent(model_id, tools, prompt)

    if (debug):
        print("\nFinal response:")
    print(result)


if __name__ == "__main__":
    main()
