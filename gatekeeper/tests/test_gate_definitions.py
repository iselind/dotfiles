"""Tests for gate definitions in iteration 1."""


from typing import Set, Optional, Dict


class GateKeeper:
    """GateKeeper that checks required sections exist in .task/ files."""
    
    def __init__(self, task_path_or_dirname=".task"):
        self._task_path = task_path_or_dirname
