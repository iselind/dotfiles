import argparse
import io
import json
import os
import shlex
import subprocess
import sys
import threading


def log_message(log_file, prefix, message):
    """Log a message with a prefix to the specified file."""
    with open(log_file, "a") as f:
        f.write(f"{prefix} {message}\n")


def log_debug(log_file, message):
    """Send debug messages to stderr."""
    with open(log_file, "a") as f:
        f.write(f"DEBUG: {message}\n")


def read_and_forward(source, destination, log_file, prefix):
    """Read messages from source, log them, and forward them to destination."""
    log_debug(log_file, f"destination type: {type(destination)}")
    while True:
        # Read header line
        header = source.readline()
        if not header:
            break  # EOF
        blank_line = source.readline()  # Read the blank line
        if not blank_line:
            break  # EOF

        # Decode header and blank_line to string if they are in bytes
        if isinstance(header, bytes):
            header = header.decode("utf-8")
        if isinstance(blank_line, bytes):
            blank_line = blank_line.decode("utf-8")

        # Parse Content-Length
        if header.lower().startswith("content-length:"):
            content_length = int(header.split(":")[1].strip())
            body = source.read(content_length)

            # Decode body to string if it's in bytes
            if isinstance(body, bytes):
                body = body.decode("utf-8")

            # Attempt to parse and pretty-print the JSON body if it's valid
            try:
                parsed_body = json.loads(body)
                formatted_body = json.dumps(parsed_body, indent=2)
            except json.JSONDecodeError:
                # If body isn't valid JSON, leave it raw
                formatted_body = body.strip()

            # Log header, blank line, and formatted body
            log_message(log_file, prefix, header.strip())
            log_message(log_file, prefix, blank_line.strip())
            log_message(log_file, prefix, formatted_body.strip())

            # Check if destination is a byte stream or text stream
            if isinstance(destination, io.BufferedWriter):
                # Encode and write as bytes
                destination.write(header.encode())  # Write header as bytes
                # Write blank line as bytes
                destination.write(blank_line.encode())
                destination.write(body.encode())  # Write body as bytes
            elif isinstance(destination, io.TextIOWrapper):
                # Write directly as strings
                destination.write(header)  # Write header as string
                destination.write(blank_line)  # Write blank line as string
                destination.write(body)  # Write body as string
            destination.flush()
    log_debug(log_file, "EOF reached")


def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="LSP proxy with logging.")
    parser.add_argument("-c", "--command", required=True,
                        help="Full command to start the LSP.")
    parser.add_argument("-f", "--file", required=True,
                        help="File to log communication.")
    args = parser.parse_args()
    log_debug(args.file, args)

    # Wipe the log file if it exists
    if os.path.exists(args.file):
        log_debug(args.file, f"Log file {args.file} exists, wiping it.")
        os.remove(args.file)

    # Split the command string into a list of arguments
    # This will split the full command string into a list
    command = shlex.split(args.command)
    log_debug(args.file, f"Running command: {command}")

    # Start the language server process
    lsp_process = subprocess.Popen(
        command,  # The command passed as a list
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=sys.stderr
    )

    log_debug(args.file, "LSP Process started")

    # Thread to forward messages from coc to LSP
    threading.Thread(
        target=read_and_forward,
        args=(sys.stdin, lsp_process.stdin, args.file, "from Coc:"),
        daemon=True
    ).start()

    # Thread to forward messages from LSP to coc
    threading.Thread(
        target=read_and_forward,
        args=(lsp_process.stdout, sys.stdout, args.file, "to Coc:"),
        daemon=True
    ).start()

    log_debug(args.file, "Waiting for LSP Process to complete")
    # Wait for the LSP process to finish
    lsp_process.wait()
    log_debug(args.file, "LSP process is done")


if __name__ == "__main__":
    try:
        log_debug("/tmp/lsp_communication_main.log", "Starting")
        main()
    except Exception as e:
        log_debug("/tmp/lsp_communication_main.log", e)
