import requests
import json
import random
import click
import inspect
import textwrap
from typing import Callable, Any

"""
Find IP of llama.cpp when it's running on Windows and this script is in WSL:
```bash
ip route | awk '/default/ {print $3}'
```
"""

BASE_URL = "http://172.30.48.1:8080/v1"


# ------------------ Tool chest ------------------

def generate_random_number() -> Any:
    """
    Returns a random integer between 0 and 100. A new, potentially different,
    number is generated on each call.
    """
    return random.randint(0, 100)


def read_file(filename: str) -> Any:
    """
    filename: absolute path to the file to read

    Returns all lines in the file. Use read_file_range for line range
    selection.
    """
    return read_file_range(filename, -1, -1)


def read_file_range(filename: str, startline: int, endline: int) -> Any:
    """
    filename: absolute path to the file to read
    startline: starting line number (1-indexed)
    endline: ending line number (1-indexed)

    Returns lines from startline to endline (inclusive).
    """
    try:
        with open(filename, 'r') as f:
            content = f.read()
            lines = content.splitlines()
            if startline < 1:
                startline = 1
            if endline > len(lines) or endline < 1:
                endline = len(lines)
            selected_lines = lines[startline - 1:endline]
            return "\n".join(selected_lines)
    except Exception as e:
        return f"Error reading file: {e}"


readonly_tools: dict[str, Callable] = {
    "generate_random_number": generate_random_number,
    "read_file": read_file,
    "read_file_range": read_file_range
}

write_tools: dict[str, Callable] = {
    # Add side-effect tools here if needed
}


def tool_docs(debug, tools) -> str:
    tool_descriptions = "\n\n".join(
        [
            "- {name}\n"
            "  {sig}\n"
            "{doc}"
            .format(
                name=name,
                sig=inspect.signature(func),
                doc=textwrap.indent(
                        textwrap.dedent(func.__doc__ or "").strip(),
                        "  "
                )
            )
            for name, func in tools.items()
        ]
    )

    if (debug):
        print("Available tools:")
        print(tool_descriptions)
    return tool_descriptions

# ------------------ API CALL ------------------


def list_models():
    resp = requests.get(f"{BASE_URL}/models")
    resp.raise_for_status()
    return resp.json().get("data", [])


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

def run_agent(debug, model, tools, user_prompt):
    tool_descriptions = tool_docs(debug, tools)
    system_prompt = f"""
You are an agent that can use tools.

Available tools:
{tool_descriptions}

Rules:
- If a tool is needed, respond ONLY with JSON:
  {{"tool": "tool_name", "arguments": {{}}}}
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

        if (debug):
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
            print(f"Unknown tool '{tool_name}', stopping")
            return content

        # Execute tool
        # Apply arguments if provided, otherwise call with no arguments
        if "arguments" in data and isinstance(data["arguments"], dict):
            try:
                result = tools[tool_name](**data["arguments"])
            except Exception as e:
                result = f"Error executing tool: {e}"
        else:
            result = tools[tool_name]()

        print(f"Tool '{tool_name}' called")
        if debug:
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

def pick_model(debug):
    models = list_models()
    if (debug):
        print("Available models:", models)
    if not models:
        raise RuntimeError("No models available")
    return models[0]["id"]


@click.command()
@click.option("-p", "--prompt", required=True, help="Prompt for the agent")
@click.option("-d", "--debug", is_flag=True, help="Enable debug mode")
@click.option("-ro", "--real-only", is_flag=True,
              help="Only allow read-only tools (no side effects)")
def main(prompt, debug, real_only):
    model_id = pick_model(debug)
    print("Using model:", model_id)

    tools = readonly_tools if real_only else {**readonly_tools, **write_tools}
    result = run_agent(debug, model_id, tools, prompt)

    if (debug):
        print("\nFinal response:")
    print(result)


if __name__ == "__main__":
    main()
