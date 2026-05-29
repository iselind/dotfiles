import pytest
from pathlib import Path
from orchestrator.issue import Issue, BlockedBy
from orchestrator.dag import compute_phases, CycleError


def make_issue(id: str, blocked_by=None) -> Issue:
    return Issue(
        id=id,
        title=f"Issue {id}",
        status="not-started",
        prd_slug="test-prd",
        branch="",
        failure_reason="",
        blocked_by=blocked_by or [],
        body="",
        path=Path(f"issues/{id}.md"),
    )


def test_no_dependencies_all_in_phase_one():
    issues = [make_issue("ISS-001"), make_issue("ISS-002"), make_issue("ISS-003")]
    phases = compute_phases(issues)
    assert len(phases) == 1
    assert {i.id for i in phases[0]} == {"ISS-001", "ISS-002", "ISS-003"}


def test_linear_chain_produces_one_issue_per_phase():
    issues = [
        make_issue("ISS-001"),
        make_issue("ISS-002", [BlockedBy("ISS-001", "needs 001")]),
        make_issue("ISS-003", [BlockedBy("ISS-002", "needs 002")]),
    ]
    phases = compute_phases(issues)
    assert len(phases) == 3
    assert phases[0][0].id == "ISS-001"
    assert phases[1][0].id == "ISS-002"
    assert phases[2][0].id == "ISS-003"


def test_diamond_dependency():
    issues = [
        make_issue("ISS-001"),
        make_issue("ISS-002", [BlockedBy("ISS-001", "needs 001")]),
        make_issue("ISS-003", [BlockedBy("ISS-001", "needs 001")]),
        make_issue("ISS-004", [BlockedBy("ISS-002", "needs 002"), BlockedBy("ISS-003", "needs 003")]),
    ]
    phases = compute_phases(issues)
    assert len(phases) == 3
    assert {i.id for i in phases[0]} == {"ISS-001"}
    assert {i.id for i in phases[1]} == {"ISS-002", "ISS-003"}
    assert {i.id for i in phases[2]} == {"ISS-004"}


def test_actual_check_issues_dag():
    issues = [
        make_issue("ISS-001"),
        make_issue("ISS-002"),
        make_issue("ISS-003"),
        make_issue("ISS-004"),
        make_issue("ISS-005", [
            BlockedBy("ISS-001", "r"), BlockedBy("ISS-002", "r"),
            BlockedBy("ISS-003", "r"), BlockedBy("ISS-004", "r"),
        ]),
        make_issue("ISS-006", [BlockedBy("ISS-005", "r")]),
    ]
    phases = compute_phases(issues)
    assert len(phases) == 3
    assert {i.id for i in phases[0]} == {"ISS-001", "ISS-002", "ISS-003", "ISS-004"}
    assert {i.id for i in phases[1]} == {"ISS-005"}
    assert {i.id for i in phases[2]} == {"ISS-006"}


def test_cycle_raises():
    issues = [
        make_issue("ISS-001", [BlockedBy("ISS-002", "r")]),
        make_issue("ISS-002", [BlockedBy("ISS-001", "r")]),
    ]
    with pytest.raises(CycleError):
        compute_phases(issues)


def test_missing_blocker_treated_as_satisfied():
    # ISS-999 has been cleaned up (completed) — ISS-001 should be unblocked
    issues = [
        make_issue("ISS-001", [BlockedBy("ISS-999", "already done and deleted")]),
    ]
    phases = compute_phases(issues)
    assert len(phases) == 1
    assert phases[0][0].id == "ISS-001"
