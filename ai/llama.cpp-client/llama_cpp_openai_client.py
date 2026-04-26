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
        print(f"File '{filename}' has already been read, skipping re-read.")
        return f"File '{filename}' has already been read. Avoid re-reading the same file."
    read_file_cache.add(filename)

    with open(filename, 'r') as f:
        content = f.read()
        print(
            f"File '{filename}' read successfully, {len(content)} characters.")
        return content


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
            content = "\n".join(selected_lines)
            print(
                f"Selected lines {startline}-{endline} from file '{filename}', {len(content)} characters.")
            return content
    except Exception as e:
        return f"Error reading file: {e}"


def update_file_contents(file_path: str, operations: list[dict]) -> str:
    """
    Call this tool with:

    {
      "file_path": str,
      "operations": [
        {
          "operation": "replace" | "prepend" | "append",
          "this": str,
          "that": str
        }
      ]
    }

    General:

    - `file_path`: absolute path to an existing file.
    - `this` and `that` are exact multi-line strings, including all whitespace,
      indentation, and line breaks.
    - You MUST first read the file (or relevant range) and copy `this` exactly
      from the current file contents.
    - You MUST ensure line breaks and indentation in `this` and `that` are
      exactly as intended, otherwise the operation may fail or produce
      unintended results.
    - Prefer reading only relevant ranges to save tokens.

    Matching rules:

    - `this` must match exactly (case- and whitespace-sensitive)
    - `this` must occur exactly once in the file
    - 0 or >1 matches → operation fails

    Operation semantics:

    - "replace": replace `this` with `that`
    - "prepend": insert `that` immediately before `this`
    - "append": insert `that` immediately after `this`

    CRITICAL RULES:

    - For "prepend" and "append", `that` must contain ONLY the new content.
    - NEVER include `this` inside `that` for 'append' and 'prepend' operations.
    - The system performs the combination:
      - prepend → result = that + this
      - append  → result = this + that
    - DO NOT construct the final combined string yourself.

    Examples:

    Given original text:
      "foo"

    To prepend "bar":
      CORRECT:   { "operation": "prepend", "this": "foo", "that": "bar" }
      INCORRECT: { "operation": "prepend", "this": "foo", "that": "barfoo" }

    To append "bar":
      CORRECT:   { "operation": "append", "this": "foo", "that": "bar" }
      INCORRECT: { "operation": "append", "this": "foo", "that": "foobar" }

    Execution:

    - Operations are applied sequentially.
    - Each operation sees the updated file.
    - Stop on first failure (no partial success).

    Guidance:

    - Make `this` specific enough to be unique (include multiple lines if needed).
    - Copy exact text from the file—do not retype or approximate.
    - Ensure the final file remains valid after changes.

    Limitations:

    - Cannot create or delete files.
    - Only modifies existing file contents.
    """
    print(f"Updating file '{file_path}' with {len(operations)} operations...")
    for op in operations:
        operation = op.get("operation")
        this: str = op.get("this")
        that: str = op.get("that")
        print(
            f"  Operation: {operation}\n  This:\n  '{this}'\n  That:\n  '{that}'\n---")
    with open(file_path, 'r') as f:
        content = f.read()

    opIdx = 0
    for op in operations:
        operation = op.get("operation")
        this: str = op.get("this")
        that: str = op.get("that")

        if operation not in ["replace", "prepend", "append"]:
            return f"Invalid operation '{operation}'"

        count = content.count(this)
        if count == 0:
            print(
                f"Content to modify not found for operation {opIdx}: '{this}'")
            return f"Failed on operation with index {opIdx}, text to modify not found: '{this}'"
        elif count > 1:
            print(
                f"Content to modify is not unique for operation {opIdx} (occurs {count} times): '{this}'")
            return f"Failed on operation with index {opIdx}, text to modify is not unique (occurs {count} times): '{this}'"

        if operation == "replace":
            content = content.replace(this, that)
        else:
            if that.count(this) > 0:
                return f"Warning: 'this' occurs in 'that' for operation {opIdx}, that is not allowed for 'prepend' and 'append' operations"

            if operation == "prepend":
                content = content.replace(this, that + this)
            elif operation == "append":
                content = content.replace(this, this + that)

        opIdx += 1
    with open(file_path, 'w') as f:
        f.write(content)

    print(f"File '{file_path}' updated successfully.")
    return f"Patch applied successfully to '{file_path}'"


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
    "update_file_contents": update_file_contents
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
- Construct a detailed plan to solve the user's request, and then execute the
  plan step by step, calling tools as needed.
- If a tool is needed, respond ONLY with valid JSON:
  {{"tool": "tool_name", "arguments": {{}}}}
- Make sure the tool calls use valid JSON for the arguments, otherwise the
tool call will fail.
- Escape any special characters as needed to ensure valid JSON.
execution will fail.
- Prefer reading segments of files over reading whole files.
- You may call tools multiple times.
- On tool call failure, try again with the issue fixed.
- Respond with the final answer as plain text.
- check the result after a successful tool call and adjust the plan if needed
before the next step.
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
            print("\t** Response is not valid JSON, treating as final answer.")
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
