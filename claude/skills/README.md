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

Haiku is the main target, since it's what I use for most of my work. Sonnet is
for when I need that little extra. Skills are written with Haiku as the floor
and checked against Sonnet for regressions. Findings are labelled with the model
they were observed on and a date, since behaviour changes between releases.
Anything not measured is a hypothesis, and is called one.

## My Rules

All skills need to conform to the prescribed rules unless deliberately commented
in the skill why it deviates.

A valid skill conform to [the
specification](https://agentskills.io/specification).

Other than that, the following rules apply on top of the specification.

- **Description** (front matter): Field describes the task the user asks for and
  the specific context it applies in (system, repo, tool). Shape: "Use when
  [task] in [context]". Worded with the words a request for that task would use,
  and pushy about the contexts it covers. No instructions about *how* to use;
  pure *when*. The docs say a description covers what the skill does and when to
  use it, so "pure *when*" is my stricter choice. It is untested.
- **Body** (after front matter): Explains system response steps when that
  situation occurs; may reference tools, endpoints, conventions—but no
  instructional prose like "invoke `/review`" or "run the fix-pr-comments
  skill". Document style: file paths (``~/.claude/skills/*``,
  `docs/prds/<slug>.md`), shell command substitutions in back-ticks (``!ls
  ...``), API endpoint patterns (`/repos/{owner}/pulls`).
- **Don't explicitly invoke other skills** in prose (e.g., "use `/skill-name`")
  — describe the workflow naturally instead. We're not building workflows! (My
  own preference. The docs endorse procedures, checklists and validation loops
  inside a skill.)

My experience so far is that skills following these rules were not invoked at
the right time. That was mostly observed on Haiku and never measured, so treat
it as a hypothesis (see [triggering.md](triggering.md)).

## The shape of a skill

- **Description** = the task and the context it applies in. A skill loads when a
  task matches, so the description has to name something a user would ask for.
- **Body** starts as a list of gotchas: concrete facts that defy reasonable
  assumptions. "Be careful with the Jira custom field" is advice.
  "`customfield_10032` takes `{"value": "CORE", "child": {"value":
  "Platform"}}`" is a gotcha.
- **Procedure** (steps, a template, a checklist, a validation loop) is added
  only where an observed failure on Haiku demands it. Gotchas alone work when
  the model knows how to do the task and only misses specifics. They won't carry
  a task the model doesn't know how to approach.
- **The error is never the trigger.** The agent doesn't know it's about to make
  an error, so there is nothing to match on. The task during which the error
  happens is the trigger, and the error becomes a line in that skill's body.

### The confidence paradox

A gotchas-only skill covers tasks the agent thinks it can do alone, which are the
tasks where it is least likely to consult a skill. The docs' counter is to be
specific in the description: name the system, repo or tool where the gotchas
apply. "Use when creating or updating Jira tickets in the CORE project" gives a
signal that "Use when creating tickets" does not.

### Where a correction goes

| Where the error lives | Where the fix goes |
|---|---|
| Happens during one recurring task | A gotcha in that task's skill. With no such skill, that's a reason to create one. |
| Happens in any task (naming, commit format, don't touch X) | `~/.claude/rules/` or a CLAUDE.md. The docs say instructions for every conversation belong there, not in a skill. |
| Mechanically checkable (formatting, a forbidden file, a failing test) | A hook, a linter or a test. A validator beats an instruction. |
| About reasoning quality (jumped to a conclusion, didn't check the repo) | Probably not a skill. Task, guardrails and DoD in the prompt (see below). |

The last row is where `act`, `choose` and `reconcile` lived, and a skill is the
weakest tool for those errors. They never got invoked, so they were retired. The
recording half of `correction`, `choose` and `reconcile` moved to the
[knowledge-extraction plugin](../plugins/knowledge-extraction/README.md), whose
Stop hook triggers it deterministically; `act` was dropped.

### One set of skills, or one per model

One set, written for Haiku, checked on Sonnet. Split a skill per model only
when there's a recorded measurement of it failing on Haiku and a fix that
measurably hurts Sonnet. The order of escalation:

1. One set, Haiku as the floor, Sonnet checked for regressions.
2. Same set, model-specific wording in a few skills where a measurement shows a
   gap.
3. Two sets. Every correction would then need to land in both, and a wrong set
   loading would be hard to spot.

An explicitly invoked skill (`/skill-name`) doesn't depend on triggering, so
model differences there are mostly about how well the body is followed.

## Triggering skills

Details, doc quotes, the hook idea and how to measure it are in
[triggering.md](triggering.md). In short: the docs describe matching on the
user's task, skills for things the model does unaided are expected to trigger
rarely, and my "skills don't fire at the right time" experience is an
unmeasured, mostly-Haiku hypothesis.

## Observations

### Modeling skills as corporate roles

An architect or a tech-lead is not a skill!

Any role is composed of a multitude of capabilities, which could be regarded as
skills. Looking at companies and what their role X does I've found they differ
vastly. Companies reuse the role titles but roles also use different subsets of
the available capabilities.

Take a junior developer and a tech-lead as an example. The junior role is a
fairly stable set of capabilities from one company to the next: write code, test
it, review a colleague's change. A tech-lead sits far closer to a CTO and varies
much more. One company's tech-lead mostly designs and reviews, another's mostly
manages people and delivery. The higher the seniority, the less the title tells
you about which capabilities are involved.

What we try to mimic with skills is not corporate roles as such, but the
capabilities they use. Those capabilities vary far less than roles do.

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
