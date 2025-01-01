import sys

from dumpers.dumpers import dump_data
from formatters.datastructures import merge_multi_level
from loaders.loaders import load_file, load_string


def main():
    try:
        if len(sys.argv) != 2:
            print("string input")
            data = load_string(sys.stdin.read())
        else:
            print("file input")
            input_file = sys.argv[1]
            data = load_file(input_file, format='json')

        # Process data
        nested_data = merge_multi_level(data)

        # Output formatted JSON
        print(dump_data(nested_data, format='json'))

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
