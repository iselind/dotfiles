import json
from typing import Any

import toml
import yaml


def load_data(input_file: str, format: str) -> Any:
    """
    Load data from a file in the specified format (JSON, YAML, TOML).

    If format is None, then an autodiscovery is attempted based on the
    input_file's extension.
    """
    with open(input_file, 'r') as file:
        if format is None:
            # Auto discovery
            print("Automatic discovery of type attempted")
            # Use the extension of file as the format
            format = input_file.split(".")[-1].lower()

        if format == 'json':
            return json.load(file)
        elif format == 'yaml':
            return yaml.safe_load(file)
        elif format == 'toml':
            return toml.load(file)
        else:
            raise ValueError(f"Unsupported format: {format}")
