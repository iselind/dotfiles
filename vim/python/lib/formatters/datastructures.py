"""
Module: datastructures.py

Provides utilities for working with nested data structures, such as those
parsed from for example JSON, YAML, or other serialized data formats like TOML.
"""

import json
import sys


def merge_dicts(d1, d2):
    """
    Recursively merges d2 into d1.
    """
    for key, value in d2.items():
        if key in d1 and isinstance(d1[key], dict) and isinstance(value, dict):
            merge_dicts(d1[key], value)
        else:
            d1[key] = value


def merge_multi_level(d):
    """
    >>> merge_multi_level({"q": {"a.b": "c"}, "d":"e"})
    {'q': {'a': {'b': 'c'}}, 'd': 'e'}
    >>> merge_multi_level(["a", "b"])
    ['a', 'b']
    >>> merge_multi_level({"a": "b"})
    {'a': 'b'}
    >>> merge_multi_level([])
    []
    >>> merge_multi_level({})
    {}
    >>> merge_multi_level(None)
    """
    if isinstance(d, dict):
        d = merge_one_level(d)

        result = {}

        for k, v in d.items():
            merge_dicts(result, merge_multi_level(v))

        return result
    elif isinstance(d, list):
        return [merge_multi_level(x) for x in d]
    else:
        return d


def merge_one_level(d):
    """
    >>> merge_one_level({"a.b": "c", "d":"e"})
    {'a': {'b': 'c'}, 'd': 'e'}
    >>> merge_one_level({"a.b.c": "e", "a.b.d": "f"})
    {'a': {'b': {'c': 'e', 'd': 'f'}}}
    >>> merge_one_level({"a": "b"})
    {'a': 'b'}
    >>> merge_one_level({})
    {}
    >>> merge_one_level(None)
    """
    if not isinstance(d, dict):
        return d

    result = {}

    for k, v in d.items():
        if '.' in k:
            tmp = create_nested_dict(k.split('.'), v)
            merge_dicts(result, tmp)
        else:
            result[k] = v

    return result


def create_nested_dict(keys, value):
    """
    >>> create_nested_dict(['a', 'b'], 'c')
    {'a': {'b': 'c'}}
    >>> create_nested_dict(['a'], None)
    {'a': None}
    >>> create_nested_dict(['a'], 'b')
    {'a': 'b'}
    >>> create_nested_dict([], '')
    {}
    >>> create_nested_dict(None, None)
    {}
    """

    result = {}

    if keys:
        # Iterate over the list of keys to create the nested dictionary
        current_dict = result
        last = None
        for key in keys:
            current_dict[key] = {}  # Add an inner dictionary for each key
            # Move deeper into the nested structure
            last = current_dict
            current_dict = current_dict[key]

        if last:
            last[keys[-1]] = value

    return result


if __name__ == "__main__":
    # Check if the input file is provided as an argument
    if len(sys.argv) != 2:
        print("Usage: python3 nest_json.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]

    try:
        # Read the input JSON from the file
        with open(input_file, 'r') as file:
            data = json.load(file)

        # Convert to the nested structure
        nested_data = merge_multi_level(data)

        # Output the nested JSON to stdout
        print(json.dumps(nested_data, indent=4))

    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Failed to parse JSON from '{input_file}'.")
        sys.exit(1)
