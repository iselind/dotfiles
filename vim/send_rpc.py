import json
import sys


def send_rpc(method, params=None, id=1):
    message = {
        "jsonrpc": "2.0",
        "id": id,
        "method": method,
        "params": params or {}
    }
    if id is None:  # Notifications exclude 'id'
        del message["id"]
    message_json = json.dumps(message)
    content_length = len(message_json)
    sys.stdout.write(f"Content-Length: {content_length}\r\n\r\n")
    sys.stdout.write(message_json)
    sys.stdout.flush()


# Step 1: Initialize the server
send_rpc("initialize", {
    "processId": None,
    "rootPath": "/path/to/your/project",
    "rootUri": "file:///path/to/your/project",
    "capabilities": {},
    "trace": "verbose"
})

# Step 2: Send 'initialized' notification (optional)
send_rpc("initialized", id=None)

# Step 3: Simulate opening a JSON file
send_rpc("textDocument/didOpen", {
    "textDocument": {
        "uri": "file:///path/to/config.json",
        "languageId": "json",
        "version": 1,
        "text": "{\n  \"key1\": \"value1\",\n  \"key2\": value2,\n  \"key3\": \"value3\"\n}"
    }
})

# Step 4: Simulate saving the file
send_rpc("textDocument/didSave", {
    "textDocument": {
        "uri": "file:///path/to/config.json"
    }
})
