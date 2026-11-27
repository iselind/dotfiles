A branch never crosses the PR boundary, the point where changes have to be deployed before work can continue. Stop the branch there and continue on a new one once the change is deployed. Call it the branch, not a "round".

The boundary falls where:
- something running has to consume what the branch creates, such as a generator, a tool or a consumer in another repository that needs the data to be deployed before it reads it;
- the implementation is complete.

**Why:** User said, in a CORE-955 session: "In this repo we need to be very careful with the PR-boundary, that it's not crossed while working on a branch. That's the point where changes have to be deployed before work can continue." When the rule was first phrased as "a round never crosses it", the user said: "it might actually be illadvised to call it a round. It's probably more safe to call it what it is, the branch". "Round" is vague and invites stretching; the branch is the unit that becomes a PR. Later the user asked for the rule to apply to the other repositories they work with as well.

**How to apply:** When planning or working on a branch, check whether a step depends on something that is only true once earlier changes are deployed. If so, stop at that step, say the branch has reached the PR boundary, and leave the rest for a later branch. Do not build, verify or hand over work (see [[one_session_per_repo]]) against data that is not yet deployed. Also stop when the implementation is complete instead of starting the next piece on the same branch. A repository may document where its boundary falls, as core-platform does in `CONVENTIONS.md`; follow that.
