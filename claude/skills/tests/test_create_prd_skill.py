"""
Tests for the create-prd skill file structural and content requirements.
"""
import re
from pathlib import Path

import pytest
import yaml

SKILL_FILE = Path(__file__).parent.parent / "create-prd.md"
WORKFLOW_DOC = "docs/agentic-workflow.md"


def _parse_frontmatter(text: str) -> tuple[dict, str]:
    """Split YAML frontmatter from body. Returns (frontmatter_dict, body)."""
    if not text.startswith("---\n"):
        return {}, text
    end = text.index("\n---\n", 4)
    frontmatter = yaml.safe_load(text[4:end])
    body = text[end + 5:]
    return frontmatter, body


@pytest.fixture(scope="module")
def skill_content():
    assert SKILL_FILE.exists(), f"Skill file not found: {SKILL_FILE}"
    return SKILL_FILE.read_text()


@pytest.fixture(scope="module")
def skill_frontmatter(skill_content):
    fm, _ = _parse_frontmatter(skill_content)
    return fm


@pytest.fixture(scope="module")
def skill_body(skill_content):
    _, body = _parse_frontmatter(skill_content)
    return body


class TestFrontmatter:
    def test_has_name_field(self, skill_frontmatter):
        assert "name" in skill_frontmatter, "Frontmatter must have a 'name' field"

    def test_has_description_field(self, skill_frontmatter):
        assert "description" in skill_frontmatter, "Frontmatter must have a 'description' field"

    def test_name_is_create_prd(self, skill_frontmatter):
        assert skill_frontmatter["name"] == "create-prd"


class TestAsksForIdeaFirst:
    """Skill is invoked: asks for idea before doing anything else."""

    def test_asks_for_idea(self, skill_body):
        assert re.search(r"\bidea\b", skill_body, re.IGNORECASE), (
            "Skill must ask for the user's idea"
        )

    def test_idea_is_first_action(self, skill_body):
        # "idea" should appear before any instruction to explore, branch, or write
        idea_pos = skill_body.lower().find("idea")
        for keyword in ["create.*branch", "write.*prd", "git checkout"]:
            match = re.search(keyword, skill_body, re.IGNORECASE)
            if match:
                assert idea_pos < match.start(), (
                    f"Asking for idea must come before '{keyword}' in the skill body"
                )


class TestInterviewBehaviour:
    """Interview is conducted: one question at a time, recommended answer, codebase exploration."""

    def test_one_question_at_a_time(self, skill_body):
        assert re.search(
            r"one question at a time|one.{0,30}question.{0,30}time",
            skill_body,
            re.IGNORECASE,
        ), "Skill must specify asking one question at a time"

    def test_provides_recommended_answer(self, skill_body):
        assert re.search(
            r"recommend(ed)?\s+answer|suggest(ed)?\s+answer|default\s+answer|recommend",
            skill_body,
            re.IGNORECASE,
        ), "Skill must provide a recommended answer for each question"

    def test_explores_codebase_instead_of_asking(self, skill_body):
        assert re.search(
            r"explor(e|ing)\s+the\s+codebase|read(ing)?\s+(the\s+)?(code|existing|codebase)",
            skill_body,
            re.IGNORECASE,
        ), "Skill must explore the codebase when a question can be answered by reading code"


class TestPRDOutput:
    """PRD is produced: correct path, valid frontmatter spec, new branch, commit and push."""

    def test_prd_path_pattern(self, skill_body):
        assert re.search(r"docs/prds/.*\.md", skill_body), (
            "Skill must specify PRD path as docs/prds/<slug>.md"
        )

    def test_prd_has_slug_frontmatter(self, skill_body):
        assert re.search(r"\bslug\b", skill_body), (
            "Skill must specify that the PRD frontmatter contains a 'slug' field"
        )

    def test_creates_branch(self, skill_body):
        assert re.search(r"\bbranch\b", skill_body, re.IGNORECASE), (
            "Skill must create a new branch for the PRD"
        )

    def test_commits_and_pushes(self, skill_body):
        assert re.search(r"\bcommit\b", skill_body, re.IGNORECASE), (
            "Skill must commit the PRD"
        )
        assert re.search(r"\bpush\b", skill_body, re.IGNORECASE), (
            "Skill must push the branch"
        )


class TestWorkflowReferences:
    """Skill references the agentic development workflow conventions."""

    def test_references_workflow_doc(self, skill_body):
        assert WORKFLOW_DOC in skill_body or "agentic-workflow" in skill_body, (
            f"Skill must reference {WORKFLOW_DOC}"
        )

    def test_references_prd_format(self, skill_body):
        assert re.search(r"\bPRD\b.*format|PRD.*frontmatter|frontmatter.*PRD|PRD.*format", skill_body, re.IGNORECASE | re.DOTALL), (
            "Skill must reference PRD format conventions"
        )

    def test_references_branch_naming(self, skill_body):
        assert re.search(r"branch.*nam(e|ing)|nam(e|ing).*branch", skill_body, re.IGNORECASE), (
            "Skill must reference branch naming conventions"
        )

    def test_references_human_checkpoint(self, skill_body):
        assert re.search(
            r"human\s+checkpoint|confirm(ation)?|review.*before|before.*commit|user.*confirm",
            skill_body,
            re.IGNORECASE,
        ), "Skill must reference human checkpoint expectations"
