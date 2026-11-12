# Triggering skills

How a skill gets loaded at the right time, what the docs say about it, what I
suspect, and how to measure it. Part of the [skills README](README.md).

## What the docs say

From Anthropic's [how-to](https://claude.com/docs/skills/how-to) and
agentskills.io's
[optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions):

- Claude "applies it whenever a request matches the skill's description", and
  "the agent matches against what the user asked for". The design assumes
  matching on the user's task.
- "Agents typically only consult skills for tasks that require knowledge or
  capabilities beyond what they can handle alone."
- Descriptions should use imperative phrasing ("Use this skill when..."), focus
  on user intent, "err on the side of being pushy", and include "the words a
  request for that task would use".
- Nothing on either page says a skill can't be loaded mid-task. Nothing says
  how any of this differs between models.

## What I take from it

Hypotheses, not measured:

- Skills that encode generic reasoning (`act`, `choose`, `reconcile`) describe
  things the model does unaided, so they would rarely trigger by design,
  whatever the wording.
- A situation that only emerges mid-work is the least likely to be noticed. I
  think of this as salience, not a ban. The docs hint at it for reference files:
  "the agent may not recognize the trigger".
- A description like "when observations conflict" contains none of the words a
  request would use.
- The experiments behind my earlier "skills only fire on user request" claim
  were mostly on Haiku, which may invoke skills less reliably than Sonnet.

That would suggest that I either need to

- reformat my way of working, somehow, to accommodate this design (name the
  task, or invoke by `/<skill name>`), or
- figure out some other means by which the agent would trigger the appropriate
  skill when the situation matches, without the user invoking the skill.

The former is interesting but might lead to me having to either find or develop
an alternate harness. Let's explore the latter first...

## A hook as the trigger

We can add a hook to `.claude/settings.json`, something like:

```json

{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check the descriptions of the skills available. If any match, group the relevant input into each and invoke those skills. Skills that don't require user interaction can be started as a subagent."
          }
        ]
      }
    ]
  }
}
```

> **NOTE:** Such an addition would be something we'd like the `dotfiles`
> repository's setup.sh to maintain.

We'll most likely need an amendment to the skill rules, not sure which though.
Somehow the agent will need to know if a skill requires user interaction or not.
Perhaps we can prefix the skills' names somehow to help the hook target the
skills of interest. Then the additional rule might be that skills having that
prefix may not require user interaction, which would conflict with running that
skill in a subagent.

I'm not sure which hook event would be the most accurate/useful one to pick.
Current thinking, unverified: `Stop` fires after the work is done, so it is
retroactive, and an event before the work (`UserPromptSubmit`) fits better. A
prompt hook also costs a model call on every turn. Instructions meant for every
conversation belong in `~/.claude/rules/`, not in a skill or a hook.

> **NOTE:** At this point, this describes an idea more than a tried and true
> solution.

Additional notes on Claude's hooks can be found
[here](https://code.claude.com/docs/en/hooks#hook-locations). Among those the
available hook events and hook return values that control the continuation of
the flow.

## Measuring it

The method is documented on the optimizing-descriptions page and is scripted
there:

- About 20 realistic queries per skill: 8-10 that should trigger (including ones
  that don't name the domain) and 8-10 near-miss negatives.
- 3 runs per query, a trigger rate per query, 0.5 as the pass threshold.
- A 60/40 train/validation split so a revised description is not overfitted.
- Detection by checking `claude -p --output-format json` output for `Skill` tool
  calls (the page's `jq` snippet is untested here).

The model is the variable that matters for me: run the same set on Haiku and
Sonnet. Before trusting any run, check that `--model` overrides
`ANTHROPIC_MODEL`, otherwise every run may silently use the same model. Start
with one concrete skill (`fix-pr-comments`) and one abstract one (`reconcile`).

Record results as: model, date, skill, query set, trigger rate. A finding
without those is a hypothesis.

## Outcome for `correction`, `choose`, `reconcile`, `act`

The hook idea was implemented as a plugin instead of a `settings.json` entry:
[knowledge-extraction](../plugins/knowledge-extraction/README.md). Its Stop hook
fires at every turn end and re-prompts the main agent to record corrections,
clarifications, decisions and discrepancies in `.task/`. That sidesteps skill
matching entirely, at the cost of one extra model turn per turn. Whether Haiku
follows the re-prompt reliably is not yet measured.
