# Skills

Anthropic documents how to create a skill [here](https://claude.com/docs/skills/how-to). That should be a good starting point.

## Rules

All skills need to conform to the prescribed rules unless deliberately commented
in the skill why it deviates.

A valid skill conform to [the specificaton](https://agentskills.io/specification).

Other than that, the following rules apply on top of the specification.

- Description: Found in the skill's front matter. Describe the situation in which
  this skill is relevant.
- Body: Found after the skill's front matter in the same file. How should the
  system respond when that situation occurs?
- Don't explicitly invoke other skills.
