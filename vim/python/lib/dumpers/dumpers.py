import json
from typing import Any

import toml
import yaml


def dump_data(data: Any, format: str) -> str:
    """
    Convert data into the specified format (JSON, YAML, TOML).
    """
    if format == 'json':
        return json.dumps(data, indent=4)
    elif format == 'yaml':
        return yaml.dump(data, default_flow_style=False)
    elif format == 'toml':
        return toml.dumps(data)
    else:
        raise ValueError(f"Unsupported format: {format}")
