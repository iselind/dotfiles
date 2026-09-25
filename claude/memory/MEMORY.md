# Memory index

| File | Type | Summary |
|------|------|---------|
| [skills_location.md](skills_location.md) | reference | ~/.claude/skills is a symlink into a dotfiles repo; follow it to find the real path |
| [commit_at_stable_points.md](commit_at_stable_points.md) | feedback | Stable point = tests pass/change coherent; workflow: implement one change → review in IDE → commit → ask before next |
| [fix_the_trigger.md](fix_the_trigger.md) | feedback | After resolving any finding, consider whether the ambiguity triggering it is still present — if so, propose a clarifying change |
| [inventory_before_removing.md](inventory_before_removing.md) | feedback | Before removing a mechanism, inventory the consumption side (manifests, callers, external repos) — the authoring side is never the full picture |
| [write_before_review.md](write_before_review.md) | feedback | Write files immediately; user reviews via IDE diff — don't show drafts in chat first |
| [home_no_nvidia_gpu.md](home_no_nvidia_gpu.md) | user | Home laptops lack NVIDIA GPUs; LLM inference uses Vulkan via llama.cpp on Windows host, aider in WSL2 connects over OpenAI-compat shim |
| [no_test_plan_in_prs.md](no_test_plan_in_prs.md) | feedback | Do not include a test plan section in PR descriptions |
| [promote_memory_to_highest_level.md](promote_memory_to_highest_level.md) | feedback | Save memories at the most general scope that applies — global unless genuinely repo-specific |
| [skill_launch_failure.md](skill_launch_failure.md) | feedback | When a skill fails to launch, stop and say so — never substitute inline work or misrepresent a skill as having run |
| [jira_core_project.md](jira_core_project.md) | reference | CORE Jira project = primary work source; shared across many teams; always scope to currentUser() by default |
| [git_branch_from_origin_main.md](git_branch_from_origin_main.md) | feedback | New branches must be created from origin/main; branch tracks itself, not origin/main |
| [netrc_off_limits.md](netrc_off_limits.md) | feedback | Never read or access ~/.netrc — user has PAT for Jira auth there |
| [document_patterns_globally_and_locally.md](document_patterns_globally_and_locally.md) | feedback | When you disagree with agent's choice, repo docs were incomplete — update to cover verification, conventions, constraints, gotchas |
| [change_support_evidence.md](change_support_evidence.md) | feedback | Prefer domain-specific evidence (tests, kubectl explain, terraform tools) over documentation; use docs when it's the honest answer |
| [doc_file_organization.md](doc_file_organization.md) | feedback | Capital-letter files are navigational with 150-line soft limit; lowercase files are deep-dive reference material written for both humans and agents |
| [code_testing_principles.md](code_testing_principles.md) | feedback | Three test tiers by purpose: e2e (behavior with mocked externals), integration (real external system interaction), unit (surgical targeting/examples) |
