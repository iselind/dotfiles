# Skills

Anthropic documents how to create a skill [here](https://claude.com/docs/skills/how-to). That should be a good starting point.

## Rules

All skills need to conform to the prescribed rules unless deliberately commented
in the skill why it deviates.

A valid skill conform to [the specificaton](https://agentskills.io/specification).

Other than that, the following rules apply on top of the specification.

- **Description (front matter)**: Field describes the situation where this skill is applicable. Shape: "Use when [scenario]". No instructions about *how* to use; pure *when*.
- **Body** (after front matter): Explains system response steps when that situation occurs; may reference tools, endpoints, conventions—but no instructional prose like "invoke `/review`" or "run the fix-pr-comments skill". Document style: file paths (``~/.claude/skills/*``, `docs/prds/<slug>.md`), shell command substitutions in backticks (``!ls ...``), API endpoint patterns (`/repos/{owner}/pulls`).
- **Don't explicitly invoke other skills** in prose (e.g., "use `/skill-name`") — describe the workflow naturally instead.
