# Skills

Anthropic documents how to create a skill
[here](https://claude.com/docs/skills/how-to). That should be a good starting
point. Essentially a skill should "fix" something the model gets wrong according
to their docs.

Their first step in creating a new skill is to complete the task without a
skill. The information that gets provided repeatedly should be noticed.

What we need to do is leave Claude alone doing its thing until it makes
mistakes, then add the infrastructure and files like skills to give it some
support to get to that final destination.

The Anthropic team actually also say that most of their own best skills began as
just a few lines and a single gotcha that basically corrected something that
Claude can do out of the box. So this treats skills as a list of things that
Claude actually got wrong, not a manual for the whole process anymore.

Some of the insights here come from [this YouTube
video](https://www.youtube.com/watch?v=J9NQTYUP6k0). Other things are my own
thinking and/or findings. They don't always agree.

What you'll see reading through this document is me trying to marry my thoughts
on working on higher-level tasks with reality. "Reality" here is defined as what
we can do with Claude today using Haiku and Sonnet models.

## My Rules

All skills need to conform to the prescribed rules unless deliberately commented
in the skill why it deviates.

A valid skill conform to [the
specification](https://agentskills.io/specification).

Other than that, the following rules apply on top of the specification.

- **Description** (front matter): Field describes the situation where this skill
  is applicable. Shape: "Use when [scenario]". No instructions about *how* to
  use; pure *when*.
- **Body** (after front matter): Explains system response steps when that
  situation occurs; may reference tools, endpoints, conventions—but no
  instructional prose like "invoke `/review`" or "run the fix-pr-comments
  skill". Document style: file paths (``~/.claude/skills/*``,
  `docs/prds/<slug>.md`), shell command substitutions in back-ticks (``!ls
  ...``), API endpoint patterns (`/repos/{owner}/pulls`).
- **Don't explicitly invoke other skills** in prose (e.g., "use `/skill-name`")
  — describe the workflow naturally instead. We're not building workflows!

Experience shows these rules will not have a skill invoked at the right time.

## Triggering skills

There are indications that a skill's description is in fact only matched against
a user specified task. Which suggest that a description matching a situation
alone would not trigger the skill unless the user specifically request it,
either by describing the task matching the skill's description or by doing a
`/<skill name>` invocation.

That would suggest that I either need to

- reformat my way of working, somehow, to accommodate this design, or
- figure out some other means by which the agent would trigger the appropriate
  skill when the situation matches, without the user invoking the skill.

The former is interesting but might lead to me having to either find or develop
an alternate harness. Let's explore the latter first...

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

> **NOTE:** At this point, this describes an idea more than a tried and true
> solution.

Additional notes on Claude's hooks can be found
[here](https://code.claude.com/docs/en/hooks#hook-locations). Among those the
available hook events and hook return values that control the continuation of
the flow.

## Observations

### Modeling skills as corporate roles

An architect or a tech-lead is not a skill!

Any role is composed of a multitude of capabilities, which could be regarded as
skills. Looking at companies and what their role X does I've found they differ
vastly. Companies reuse the role titles but roles also use different subsets of
the available capabilities.

When comparing the variation of capabilities in a junior developer and one far
closer to say a CTO like a tech-lead it's far more stable for the junior
engineer.

What we try to mimic with skills is not corporate roles as such, but the
capabilities they use. Those capabilities do not vary to any significant degree.

I've observed using the skill's description to describe a situation doesn't seem
to trigger the skill. Based on my exploration there are instead suggestions that
skills will only ever be invoked if specifically requested by a user, either by
name or description.

## Working on high-level tasks

I tend to think more in high-level tasks than in the tiny changes that together
compose together to create the solution. That's not really how LLMs tend to
operate.

As most of us, when we have a task to complete we need to know when we're done,
or at least done "enough". So having a high-level task would only act as the
guiding star. We still need to figure out the tiny changes that together compose
the solution. Once we reach that definition of done, that's where we publish the
PR.

A prompt should basically consist of

- Task
- Guardrails
- DoD - Definition of Done

This would mean I need to change a bit in how I work with LLMs. I need to get
better at defining done, creating something that result in a Boolean result.
Important here is that definition of done doesn't have to be executable!

So we should be able to turn a DoD into something that the LLM can check,
for example through Claude's `/goal` feature.

Anthropic says that a good goal has one end state. It says how to prove that end
state and says what mustn't change. And it should also have a turn limit to stop
it running indefinitely.
