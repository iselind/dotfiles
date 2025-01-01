import sys

from dumpers.dumpers import dump_data
from formatters.datastructures import merge_multi_level
from loaders.loaders import load_data


def main():
    if len(sys.argv) != 2:
        print("Usage: format_json.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]

    try:
        # Load JSON data
        data = load_data(input_file, format='json')

        # Process data
        nested_data = merge_multi_level(data)

        # Output formatted JSON
        print(dump_data(nested_data, format='json'))

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
