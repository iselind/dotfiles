# Starting work on a ticket

When the user says they'll be working on a ticket (e.g. "we'll be working on CORE-345"):

1. **Fetch the ticket** — read the summary, description, acceptance criteria, and any linked issues.
2. **Present the scope** — summarise what the ticket is asking for in your own words, highlighting anything large, ambiguous, or that could reasonably be split across multiple branches.
3. **Discuss focus** — ask what the intended focus of this branch is. One question, wait for the answer. Use the ticket content to make the question concrete (e.g. "the ticket covers X and Y — is this branch tackling both, or just X?").
4. **Propose a branch name** — once scope is agreed, propose a branch name following the pattern `{feature,fix}/CORE-NNN-descriptive-title` (lowercase, hyphen-separated). Wait for confirmation or a name tweak.
5. **Create the branch** — always base it on `origin/main`, never on a local branch or other remote. Push immediately after creation so the upstream is set to the new remote branch:
   ```bash
   git fetch origin
   git checkout -b <branch-name> origin/main
   git push -u origin <branch-name>
   ```
   The `-u` flag sets the upstream to `origin/<branch-name>`. Without the immediate push, the upstream would point to `origin/main` and a bare `git push` could target main — never do that.

   Immediately after the branch is pushed, transition the ticket to **In Progress** (see `conventions.md` for the transition mechanic).

6. **Agree on how to proceed** — before writing any code, propose an approach and wait for the user to confirm it:
   - Assess whether the work warrants a planning session: does it involve design choices, touch multiple files or systems, or leave the implementation approach open? Or is it contained and unambiguous enough to implement directly?
   - State your assessment in one sentence and propose either invoking `/create-prd` or proceeding directly.
   - Wait for the user to confirm or redirect. Do not start implementing until they do.

Do not create the branch before scope and name are confirmed.
Do not write code before step 6 is resolved.

**Do not pop the Jira skill after step 6.** The skill session remains open until the ticket reaches In Review. Implementation happens on the branch while the Jira skill stays on the skill-stack; the review skill's Phase 0 will see the Jira skill as the caller and set its resume to **"post-review: open PR and transition to In Review"**. When `/review` returns control here, continue with the post-review steps below.

## Direct implementation path

**If the direct implementation path is chosen**, follow this sequence:

1. **Implement the work** — make the changes on the branch and commit.
2. **Review the branch** — invoke `/review`. Repeat rounds until Phase 6's
   verdict is "no further rounds needed". Act on Phase 6's verdict — do not
   make your own assessment of whether another round is warranted.

### Post-review (return point after `/review` pops back here)

3. **Open the PR** — create the pull request once the review clears.
4. **Transition the Jira ticket to In Review.**
5. **Pop the Jira skill.**

## PRD path

**If the PRD path is chosen**, follow this sequence:

1. **Create the PRD** — invoke `/create-prd`. The PRD is committed and pushed to the branch.
2. **Review the PRD** — invoke `/review` on the PRD. Repeat rounds until the review skill's Phase 6 verdict is "no further rounds needed". Act on Phase 6's verdict — do not make your own assessment of whether another round is warranted.
3. **Comment on the Jira ticket:**
   > PRD approved — `<repo>/<branch>`
4. **Create issues** — invoke `/prd-to-issues`. Issues are committed and pushed to the branch.
5. **Comment on the Jira ticket:**
   > Issues created — `<repo>/<branch>`: ISS-001, ISS-002, … *(list all issue IDs)*
6. **Review each issue** — invoke `/review` on each issue. Repeat rounds per issue until Phase 6 clears it. When an issue clears, comment on the Jira ticket:
   > ISS-NNN cleared for implementation — `<repo>/<branch>`
7. **Implementation begins** — per the agent contract defined in the prd-to-issues skill's `issue-format.md`.

The Jira skill remains on the skill-stack throughout. When implementation produces a PR, return to the **post-review** steps in the direct implementation path above (open PR, transition to In Review, pop).

## Resuming after interruption

Read the Jira ticket comments to determine which phase completed last, then check git on `<repo>/<branch>` for current file state. Pick up from the last incomplete phase.
