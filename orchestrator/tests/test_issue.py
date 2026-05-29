import pytest
from pathlib import Path
from orchestrator.issue import parse_issue, write_issue, find_issues, parse_prd_slug, Issue, BlockedBy


SIMPLE_ISSUE = """\
---
id: ISS-001
title: Add lint-shell sub-target
status: not-started
prd-slug: check-feedback-loop
branch: ''
failure-reason: ''
blocked-by: []
---

## Story

As a developer
I want something
So that something happens
"""

BLOCKED_ISSUE = """\
---
id: ISS-002
title: Add check aggregator
status: not-started
prd-slug: check-feedback-loop
branch: ''
failure-reason: ''
blocked-by:
- id: ISS-001
  reason: lint-shell must exist first
---

## Story

As a developer
I want something
So that something happens
"""

OTHER_PRD_ISSUE = """\
---
id: ISS-001
title: Some other issue
status: not-started
prd-slug: some-other-prd
branch: ''
failure-reason: ''
blocked-by: []
---

## Story

As a developer
I want something
So that something happens
"""

PRD_WITH_SLUG = """\
---
slug: check-feedback-loop
---

# PRD: Check Feedback Loop

## Goal

Some goal.
"""

PRD_WITHOUT_SLUG = """\
# PRD: No Frontmatter

## Goal

Some goal.
"""


def test_parse_simple_issue(tmp_path):
    p = tmp_path / "ISS-001-lint-shell.md"
    p.write_text(SIMPLE_ISSUE)
    issue = parse_issue(p)
    assert issue.id == "ISS-001"
    assert issue.title == "Add lint-shell sub-target"
    assert issue.status == "not-started"
    assert issue.prd_slug == "check-feedback-loop"
    assert issue.branch == ""
    assert issue.failure_reason == ""
    assert issue.blocked_by == []


def test_parse_blocked_issue(tmp_path):
    p = tmp_path / "ISS-002-check-aggregator.md"
    p.write_text(BLOCKED_ISSUE)
    issue = parse_issue(p)
    assert len(issue.blocked_by) == 1
    assert issue.blocked_by[0].id == "ISS-001"
    assert "lint-shell" in issue.blocked_by[0].reason


def test_branch_name_derived_when_empty(tmp_path):
    p = tmp_path / "ISS-001-lint-shell.md"
    p.write_text(SIMPLE_ISSUE)
    issue = parse_issue(p)
    assert issue.branch_name() == "issue/iss-001-add-lint-shell-sub-target"


def test_branch_name_uses_stored_value(tmp_path):
    content = SIMPLE_ISSUE.replace("branch: ''", "branch: 'issue/iss-001-lint-shell'")
    p = tmp_path / "ISS-001-lint-shell.md"
    p.write_text(content)
    issue = parse_issue(p)
    assert issue.branch_name() == "issue/iss-001-lint-shell"


def test_write_and_reparse(tmp_path):
    p = tmp_path / "ISS-001-lint-shell.md"
    p.write_text(SIMPLE_ISSUE)
    issue = parse_issue(p)
    issue.status = "in-progress"
    issue.branch = "issue/iss-001-add-lint-shell-sub-target"
    write_issue(issue)
    updated = parse_issue(p)
    assert updated.status == "in-progress"
    assert updated.branch == "issue/iss-001-add-lint-shell-sub-target"
    assert updated.prd_slug == "check-feedback-loop"
    assert updated.id == "ISS-001"


def test_write_failure(tmp_path):
    p = tmp_path / "ISS-001-lint-shell.md"
    p.write_text(SIMPLE_ISSUE)
    issue = parse_issue(p)
    issue.status = "failed"
    issue.failure_reason = "shellcheck not installed"
    write_issue(issue)
    updated = parse_issue(p)
    assert updated.status == "failed"
    assert updated.failure_reason == "shellcheck not installed"


def test_find_issues_no_filter(tmp_path):
    (tmp_path / "ISS-001-lint-shell.md").write_text(SIMPLE_ISSUE)
    (tmp_path / "ISS-002-check-aggregator.md").write_text(BLOCKED_ISSUE)
    (tmp_path / "README.md").write_text("not an issue")
    issues = find_issues(tmp_path)
    assert len(issues) == 2
    assert issues[0].id == "ISS-001"
    assert issues[1].id == "ISS-002"


def test_find_issues_filters_by_prd_slug(tmp_path):
    (tmp_path / "ISS-001-lint-shell.md").write_text(SIMPLE_ISSUE)
    (tmp_path / "ISS-002-other.md").write_text(OTHER_PRD_ISSUE)
    issues = find_issues(tmp_path, prd_slug="check-feedback-loop")
    assert len(issues) == 1
    assert issues[0].id == "ISS-001"


def test_find_issues_empty_when_no_match(tmp_path):
    (tmp_path / "ISS-001-lint-shell.md").write_text(SIMPLE_ISSUE)
    issues = find_issues(tmp_path, prd_slug="nonexistent-prd")
    assert issues == []


def test_parse_prd_slug(tmp_path):
    p = tmp_path / "check-feedback-loop.md"
    p.write_text(PRD_WITH_SLUG)
    assert parse_prd_slug(p) == "check-feedback-loop"


def test_parse_prd_slug_missing_raises(tmp_path):
    p = tmp_path / "no-frontmatter.md"
    p.write_text(PRD_WITHOUT_SLUG)
    with pytest.raises(ValueError, match="No frontmatter"):
        parse_prd_slug(p)
