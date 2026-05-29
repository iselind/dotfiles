from collections import defaultdict, deque
from typing import List
from orchestrator.issue import Issue


class CycleError(Exception):
    pass


def compute_phases(issues: List[Issue]) -> List[List[Issue]]:
    """
    Topologically sort issues using Kahn's algorithm, grouping into BFS phases.
    Each phase contains issues that are unblocked given all prior phases are complete.
    Raises CycleError if the DAG contains a cycle.
    """
    by_id = {issue.id: issue for issue in issues}
    in_degree = {issue.id: 0 for issue in issues}
    dependents = defaultdict(list)

    for issue in issues:
        for blocker in issue.blocked_by:
            if blocker.id not in by_id:
                # Blocker has been cleaned up (completed and deleted) — treat as satisfied
                continue
            dependents[blocker.id].append(issue.id)
            in_degree[issue.id] += 1

    queue = deque(
        issue_id for issue_id, degree in in_degree.items() if degree == 0
    )
    phases = []
    visited = 0

    while queue:
        phase = list(queue)
        queue.clear()
        phases.append([by_id[issue_id] for issue_id in phase])
        visited += len(phase)
        for issue_id in phase:
            for dependent_id in dependents[issue_id]:
                in_degree[dependent_id] -= 1
                if in_degree[dependent_id] == 0:
                    queue.append(dependent_id)

    if visited != len(issues):
        raise CycleError("Issue DAG contains a cycle")

    return phases
