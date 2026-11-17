# Concerns

Open concerns about how Claude is set up to work: things felt to be missing or wrong that are not yet a rule, a skill change or a plan. Each entry says what the concern is and what has been tried, so that it can be picked up as a piece of work later. When one is resolved, remove it and point to where the resolution lives.

## No stated ways of working that starts with understanding the task (2026-11-17)

**Concern:** The ways of working are not described as a whole. Skills and rules cover individual phases (review, refine, commit points), but nothing says how a task starts. LLMs tend to jump into solving rather than first understanding the task and breaking it down.

User, 2026-11-17: "I have been feeling quite a lack in how to express a proper ways of working. LLMs tend to just jump into solving rather than trying to understand and decomposing the problem first."

**Idea:** Starting any task, whether it comes from Jira or not, would begin by establishing an understanding of it and recording that in something like `.task/description.md`. Later work would test itself against it: the `review` skill would take the purpose from there, and `consolidate-docs` would know what the task was.

User, 2026-11-17: "It's conceivable that starting a new task, regardless if coming from Jira or not, would begin by establishing an understanding for the task, and get that into something like `.task/description.md`. But doing such rework is not suitable here."

**Why it came up:** While reviewing CORE-1039, review findings misjudged what the branch was for twice, and the purpose had no stable place to be read from (tickets vary in quality, and there was no plan file). The `review` skill got a local fix, Step 2b, which establishes and confirms the purpose, and the `refine` skill now asks for a purpose in ticket descriptions. Both are patches around the missing standing step, not a replacement for it.

**Not decided:** where the description lives and who writes it, whether it replaces or sits beside the knowledge-extraction `.task/` files, and which skills would read it. Whether `.task/description.md` suits a directory that `consolidate-docs` deletes at the end is also open.
