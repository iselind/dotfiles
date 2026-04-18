import requests
import patch
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

def generate_random_number() -> int:
    """
    Returns a random integer between 0 and 100. A new, potentially different,
    number is generated on each call.
    """
    return random.randint(0, 100)


# Save context tokens by not re-reading the same file multiple times.
read_file_cache = set()


def read_file(filename: str) -> str:
    """
    filename: absolute path to the file to read

    Returns all lines in the file. Use read_file_range for line range
    selection. Avoid using this function if possible.
    """
    if (filename in read_file_cache):
        return f"File '{filename}' has already been read. Avoid re-reading the same file."
    read_file_cache.add(filename)
    return read_file_range(filename, -1, -1)


def read_file_range(filename: str, startline: int, endline: int) -> str:
    """
    filename: absolute path to the file to read
    startline: starting line number (1-indexed)
    endline: ending line number (1-indexed)

    Returns lines from startline to endline (inclusive).
    """
    print(f"Reading file '{filename}' from line {startline} to {endline}...")
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


def apply_patch(patch_content: str) -> str:
    """
    patch_content: content of the patch to apply. Paths must be absolute and
    the patch should be in unified diff format.

    Applies the provided patch. Returns a success message or an error message
    if the patch could not be applied.

    The number of lines used as context is usually 5. If the patch fails, it
    may be because the context lines do not match the current state of the
    file. In that case, try adjusting the context lines in the patch and
    reapplying.

    To construct a valid patch, you need to read and use at least 5 lines of
    context around the lines that are to be changed from the target file. You
    can use the read_file_range tool to read specific line ranges from the file
    to get the necessary context for the patch.

    This function is ill-suited for creating and deleting files. It is best
    used for modifying existing files.
    """
    print("Attempting to patch...")
    patcher = patch.fromstring(patch_content)
    print("Patcher created")

    result = patcher.apply()
    print("Patch applied with result:", result)

    print("Patch applied to the following files:")
    for p in patcher:
        print(f"- {p.path} ({p.result})")

    if not result:
        failed = [p for p in patcher if getattr(p, "failed", False)]
        return f"Patch failed for {len(failed)} files"

    return "Patch applied successfully"


readonly_tools: dict[str, Callable] = {
    "generate_random_number": generate_random_number,
    "read_file": read_file,
    "read_file_range": read_file_range
}

"""
TODO: create additional write tools for
- creating new files
- deleting files
- executing shell command
- Git commands
- web requests, like Google search or API calls
"""
write_tools: dict[str, Callable] = {
    "apply_patch": apply_patch
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
- If a tool is needed, respond ONLY with valid JSON:
  {{"tool": "tool_name", "arguments": {{}}}}
- Make sure the tool calls use valid JSON for the arguments, otherwise the
tool.
- Escape any special characters as needed to ensure valid JSON.
execution will fail.
- Prefer reading segments of files over reading whole files.
- You may call tools multiple times.
- On tool call failure, try again with the issue fixed.
- Respond with the final answer as plain text.
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
            print("Response is not valid JSON, treating as final answer.")
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
                print(f"Error executing tool '{tool_name}': {e}")
                result = f"Error executing tool: {e}"
        else:
            try:
                result = tools[tool_name]()
            except Exception as e:
                print(f"Error executing tool '{tool_name}': {e}")
                result = f"Error executing tool: {e}"

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
            "content": f"Tool {tool_name} returned:\n{result}"
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
