import sys

from dumpers.dumpers import dump_data
from formatters.datastructures import merge_multi_level
from loaders.loaders import load_file, load_string

debug_file = "/tmp/json_formatting.log"


def log_trace(prefix: str, msg: str) -> None:
    with open(debug_file, "a") as f:
        f.write(f"{prefix}: {msg}\n")


def log_debug(msg: str) -> None:
    log_trace("DEBUG", msg)


def main():
    try:
        if len(sys.argv) != 2:
            print("File path argument missing")
            sys.exit(1)

        input_file = sys.argv[1]
        if input_file == "-":
            data = load_string(sys.stdin.read())
            log_debug("Got input from stdin")
            log_debug(f"Received: {data}")
        else:
            log_debug(f"Got input from file: {input_file}")
            data = load_file(input_file, format='json')

        # Process data
        nested_data = merge_multi_level(data)
        log_debug("after merge_multi_level")

        # Output formatted JSON
        print(dump_data(nested_data, format='json'))

    except Exception as e:
        log_trace("Exception", f"{e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
