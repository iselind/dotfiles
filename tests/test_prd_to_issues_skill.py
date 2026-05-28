"""Tests for the /prd-to-issues skill (ISS-002).

These tests verify:
- The skill file exists with correct frontmatter
- The skill references docs/agentic-workflow.md
- The skill covers the required issue format fields and DAG conventions
- The skill requires user confirmation before committing
- Issues in the format the skill would produce are parseable by the orchestrator
"""
from pathlib import Path
import tempfile

import pytest
import yaml

SKILL_PATH = Path(__file__).parent.parent / "claude/skills/prd-to-issues/SKILL.md"
WORKFLOW_DOC_REF = "docs/agentic-workflow.md"
REQUIRED_ISSUE_FIELDS = [
    "id", "title", "status", "prd-slug", "branch", "failure-reason", "blocked-by"
]


def _parse_frontmatter(text: str) -> dict:
    parts = text.split("---", 2)
    assert len(parts) >= 3, "File has no valid YAML frontmatter"
    return yaml.safe_load(parts[1])


class TestSkillFileStructure:
    def test_skill_file_exists(self):
        assert SKILL_PATH.exists(), f"Skill file missing: {SKILL_PATH}"

    def test_skill_frontmatter_name(self):
        content = SKILL_PATH.read_text()
        front = _parse_frontmatter(content)
        assert front.get("name") == "prd-to-issues"

    def test_skill_frontmatter_user_invocable(self):
        content = SKILL_PATH.read_text()
        front = _parse_frontmatter(content)
        assert front.get("user-invocable") is True

    def test_skill_frontmatter_has_description(self):
        content = SKILL_PATH.read_text()
        front = _parse_frontmatter(content)
        assert front.get("description"), "Skill must have a non-empty description"


class TestSkillReferencesWorkflow:
    def test_references_agentic_workflow_doc(self):
        content = SKILL_PATH.read_text()
        assert WORKFLOW_DOC_REF in content, (
            f"Skill must reference '{WORKFLOW_DOC_REF}' as the authoritative guide"
        )


class TestSkillCoversIssueFormat:
    def test_mentions_all_required_frontmatter_fields(self):
        content = SKILL_PATH.read_text()
        for field in REQUIRED_ISSUE_FIELDS:
            assert field in content, (
                f"Skill must mention issue field '{field}' — needed for orchestrator parsing"
            )

    def test_mentions_dag_conventions(self):
        content = SKILL_PATH.read_text()
        assert "DAG" in content or "dag" in content.lower(), (
            "Skill must describe DAG construction"
        )

    def test_mentions_blocked_by_structure(self):
        content = SKILL_PATH.read_text()
        assert "blocked-by" in content
        assert "reason" in content, (
            "Skill must describe blocked-by entries with 'reason' field"
        )

    def test_mentions_issues_directory(self):
        content = SKILL_PATH.read_text()
        assert "issues/" in content, "Skill must reference the issues/ output directory"

    def test_mentions_user_story_format(self):
        content = SKILL_PATH.read_text()
        assert "As a" in content or "As an" in content, (
            "Skill must mention user story format (As a / I want / So that)"
        )

    def test_mentions_given_when_then(self):
        content = SKILL_PATH.read_text()
        assert "Given" in content and "When" in content and "Then" in content, (
            "Skill must mention Given/When/Then acceptance criteria format"
        )


class TestSkillConfirmationBehavior:
    def test_requires_confirmation_before_commit(self):
        content = SKILL_PATH.read_text()
        content_lower = content.lower()
        has_confirm = "confirm" in content_lower
        has_approval = "approv" in content_lower
        assert has_confirm or has_approval, (
            "Skill must require user confirmation before committing"
        )

    def test_mentions_commit_and_push(self):
        content = SKILL_PATH.read_text()
        assert "commit" in content.lower() and "push" in content.lower(), (
            "Skill must commit and push on confirmation"
        )


class TestIssueFormatOrchestratorCompatibility:
    """Validate that the issue format the skill produces is parseable by the orchestrator."""

    def _parse_issue_frontmatter(self, text: str) -> dict:
        parts = text.split("---", 2)
        assert len(parts) >= 3
        front = yaml.safe_load(parts[1])
        required = ["id", "title", "status", "prd-slug", "branch", "failure-reason", "blocked-by"]
        for f in required:
            assert f in front, f"Issue frontmatter missing field: {f}"
        return front

    def test_minimal_issue_is_parseable(self):
        issue = """\
---
id: ISS-001
title: Sample issue
status: not-started
prd-slug: test-prd
branch: ""
failure-reason: ""
blocked-by: []
---

## Story

As a developer
I want to do something
So that I can achieve a goal

## Acceptance Criteria

**Scenario: it works**
Given a context
When I do something
Then something happens
"""
        front = self._parse_issue_frontmatter(issue)
        assert front["id"] == "ISS-001"
        assert front["prd-slug"] == "test-prd"
        assert isinstance(front["blocked-by"], list)
        assert front["blocked-by"] == []

    def test_issue_with_blockers_is_parseable(self):
        issue = """\
---
id: ISS-002
title: Dependent issue
status: not-started
prd-slug: test-prd
branch: ""
failure-reason: ""
blocked-by:
  - id: ISS-001
    reason: requires ISS-001 to complete first
---

## Story

As a developer
I want to build on ISS-001
So that I can ship the feature

## Acceptance Criteria

**Scenario: unblocked after ISS-001**
Given ISS-001 is done
When I start this
Then it succeeds
"""
        front = self._parse_issue_frontmatter(issue)
        assert len(front["blocked-by"]) == 1
        blocker = front["blocked-by"][0]
        assert blocker["id"] == "ISS-001"
        assert "reason" in blocker

    def test_preflight_compatible_issue_set(self):
        """Issues with prd-slug matching the PRD slug satisfy the orchestrator preflight."""
        prd_slug = "my-feature"
        issues_text = [
            f"""\
---
id: ISS-001
title: First step
status: not-started
prd-slug: {prd_slug}
branch: ""
failure-reason: ""
blocked-by: []
---

## Story

As a developer I want X So that Y

## Acceptance Criteria

**Scenario: works**
Given context When action Then result
""",
        ]
        # Replicate orchestrator preflight logic: find issues matching prd_slug
        matched = []
        for text in issues_text:
            parts = text.split("---", 2)
            front = yaml.safe_load(parts[1])
            if front.get("prd-slug") == prd_slug:
                matched.append(front)

        assert len(matched) >= 1, (
            "Preflight requires at least one issue matching the PRD slug"
        )
