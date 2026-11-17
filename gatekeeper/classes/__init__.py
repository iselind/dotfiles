#!/usr/bin/env python3
"""GateDefinition and GateKeeper classes for gate evaluation."""


from typing import List, Set, Optional, Dict, Tuple


class GateDefinition:
    """Defines what a gate expects from .task/ files.

    Attributes:
        file_name: Relative path to markdown file within .task/.
        required_sections_marked: Set of marker strings like ['[objective]'].
        all_section_names: Sorted list of clean names without brackets for deterministic output.

    Example usage:
      GateDefinition("description.md", ["objective"])  # requires [objective] section

    Section markers are matched case-insensitively, stored lowercased internally.
    """

    DEFAULT_GUIDANCE = {
        "objective": "single sentence of achievement target",  
        "current-state": "existing system/code/infrastructure as-is",  
        "desired-state": "target configuration or behavior after change",
        "constraints": "limits, standards, compatibility (e.g. no breaking changes)",
        "gap-analysis": "bullet list decomposing differences into verifiable unit tasks",
    }
    def __init__(self, file_name: str, *, sections=None, guidance=None):
        self._file_name = file_name
            
        if sections:
            # Normalize section names and build set of markers like [objective]
            normalized = [s.strip().lower() for s in (sections or []) if s.strip()]
            markers: Set[str] = {f"[{name}]" for name in normalized}
            
        else:
            self.required_sections_marked = set()
            markers = set()  # Avoid unbound variable

        self._markers_dict = markers.copy() if isinstance(markers, (set, list)) else None
        
        self.required_sections_marked = markers if sections else set()


    @property
    def file_name(self):
        """Relative path to markdown file."""
        return self._file_name if self._file_name else ""

    @property
    def all_section_names(self) -> List[str]:
        """Sorted list of clean names without brackets for deterministic output."""
        if not self._file_name:
            return []
        
        markers = sorted(list(self.required_sections_marked), key=lambda s: (len(s), s))
        return [m[1:-1].strip() for m in markers]


class GateKeeper:
    """Evaluates gates by checking required sections exist in .task/ files.

    Args:
        task_path_or_dirname: Path to .task/ directory or None for test mode.
                              Pass TestTaskState fixture instead of string for tests.
    """

    def __init__(self, task_path_or_dirname=".task"):
        self._task_path_str: str = task_path_or_dirname
    
    @property
    def task_dir(self) -> str:
        return self._task_path_str or ""

    def _read_task_file(self, filename: str) -> Optional[str]:
        """Read file content or return None if simulated test mode."""
        path_str = self._task_path_str
        
        # If no actual .task/ directory specified (test mode), skip reading.
        if not path_str or path_str == "nonexistent":
            return None
            
        full_path = f"{path_str}/{filename}"
        try:
            with open(full_path, 'r') as f:
                return f.read()
        except FileNotFoundError:
            return None

    def _extract_sections_from_content(self, content: str) -> Set[str]:
        """Extract section markers present in markdown content."""
        if not content:
            return set()
        
        import re
        # Find all [sectionname] patterns - simple extraction
        sections = re.findall(r'\[(.*?)\]', content)
        return {s.strip().lower() for s in sections if s and s[0] != '['}

    def check_gate(self, gate: GateDefinition) -> Tuple[bool, str]:
        """Check single gate; return (success, guidance_message).
        
        Args:
            gate: GateDefinition instance describing file and required sections.
          
        Returns:
          Tuple where success=True + "" means writes allowed.
                  False + non-empty string lists missing sections with descriptions.

        Example (no .task/ directory):
          False + "[task not initialized] create .task/description.md..."

        Example (file exists, all sections present):
          True, ""
        
        Example (partial sections in file):
          False + "Write '[objective]' with: description..."
        
        """
        
        import os
            
        # Check if .task/ directory exists or is simulated state  
        task_dir = self.task_dir
        
        # If directory doesn't exist on real filesystem, check for no-read mode.
        # In test mode (no actual .task/), gate returns failure with guidance to create it.
        
        # Try to read the file - this reveals if file exists or needs creation.
        full_path = f"{task_dir}/{gate.file_name}"
        try:
            os_stat = os.stat(full_path)  # Raises FileNotFoundError if missing
            
        except FileNotFoundError:
            # File doesn't exist yet
            return False, f"[no {gate.file_name} in .task/] create it with guidance text\n    e.g. '[objective]' for single-sentence achievement target"
        
        try:
            content = self._read_task_file(gate.file_name)
            
            # Extract sections currently present in file
            present_sections = self._extract_sections_from_content(content) if content else set()
            
            # Get required markers from gate definition
            requested_markers = gate.required_sections_marked
            
            # Check which markers are satisfied (file has section marker but not all gates pass.)
            missing = requested_markers - present_sections
            
            if not missing:
                # All required sections present in file - success.
                return True, ""
            else:
                # Generate guidance message for each missing section.
                lines = [""]
                
                for marker in sorted(missing):
                    clean_name = marker.lstrip("[]").lower()
                    desc = GateDefinition.DEFAULT_GUIDANCE.get(clean_name, f"description for {clean_name}")
                    
                    lines.append(f"    Write '{marker}' with: {desc}")
                
                return False, "\n".join(lines)
        
        except Exception as e:  # type: ignore
            import traceback
            
            # Default to failure if any exception occurs during gate check.
            return False, f"[error checking gate] {e}"


class TestTaskState:
    """Test fixture providing simulated .task/ directory state."""

    def __init__(self):
        self._simulated_files = {}  # filename -> {path, readable_bool, sections_present_set}
    
    @property
    def task_dir(self) -> str:
        return "nonexistent"  # Signal test mode to GateKeeper
    
    def register_file(self, filename: str, *, is_readable=True, section_names=None):
        """Register a file with optional sections present for gate evaluation."""
        clean_name = filename.strip("/") if "/" in filename else filename
        self._simulated_files[clean_name] = {
            "path": f"nonexistent/{clean_name}",
            "is_readable": is_readable,
            "sections_present": set(section_names) if section_names else None,
        }
    
    def get_file_content(self, filename: str) -> Optional[str]:
        """Return simulated file content with section markers for test evaluation."""
        clean_name = filename.strip("/") if "/" in filename else filename
        
        file_info = self._simulated_files.get(clean_name, {})
        
        if not file_info.get("is_readable", True):
            return None
        
        sections_present = file_info.get("sections_present")
        output_lines = []
        
        for marker in sorted(sections_present or []):
            clean_name_no_brackets = marker[1:-1].strip() if len(marker) > 2 else ""
            desc = GateDefinition.DEFAULT_GUIDANCE.get(clean_name_no_brackets.lower(), f"description of {clean_name_no_brackets}")
            output_lines.append(f"{marker}\n{desc} placeholder")
        
        return "\n".join(output_lines) if output_lines else None
    
    def list_available_files(self) -> Dict[str, dict]:
        """Return dict of files registered for simulation."""
        return self._simulated_files

