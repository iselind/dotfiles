# Engineering Workflow — Destination

> A working vision for a pattern-oriented approach to LLM-assisted software engineering.
>
> **Status:** Exploratory. This document captures the current thinking, not a finalized specification. Ideas, structures and decisions are expected to change through practical experience.

## 1. Purpose

The purpose of this project is to develop an engineering workflow that makes effective use of LLMs while reducing reliance on individual model capabilities, training knowledge and context-window size.

The central hypothesis is that LLMs are particularly good at recognizing, understanding and applying patterns. We should exploit that capability by building an engineering process around reusable, documented patterns.

Rather than simply asking an LLM to implement a task, the process should help it:

1. Understand the task and its desired outcome.
2. Understand the current state of the system.
3. Identify gaps between the current and desired states.
4. Break those gaps into manageable engineering tasks.
5. Identify applicable patterns.
6. Establish new patterns where necessary.
7. Execute tasks using appropriate models and instructions.
8. Verify the result against the original requirements.

The intention is not to build an elaborate multi-agent framework for its own sake. The intention is to improve the quality, predictability and efficiency of AI-assisted engineering.

The methodology should be developed through actual use, starting with relatively simple repositories and progressing towards more specialized and challenging domains.

## 2. Guiding principles

### 2.1 Patterns as a foundation

A pattern is a documented, repeatable process for solving a particular class of engineering problems.

Patterns are not necessarily traditional software design patterns. They may describe:

- How to introduce an API endpoint.
- How to introduce a background worker.
- How to modify an existing Terraform configuration.
- How to investigate and resolve a particular class of defect.
- How to introduce a new technology into an existing system.

Patterns should capture not only what to do, but also applicability, constraints, verification and known limitations.

The intention is to accumulate reusable engineering experience rather than repeatedly rediscovering solutions.

### 2.2 Knowledge should be externalized

We should not assume that a model knows something simply because it claims to know it.

Domain knowledge should be made available independently of the model being used.

For relevant technologies and domains, identify authoritative documentation and make it accessible through the repository's knowledge documentation.

This should happen regardless of the model's perceived familiarity with the technology.

For example, when working with Terraform:

- Identify the Terraform version.
- Identify the relevant providers and their versions.
- Identify authoritative documentation sources.
- Record useful references in the repository.
- Make relevant information available to subsequent tasks and agents.

If an agent cannot identify the appropriate authoritative sources, it should request human assistance.

We should generally link to authoritative online documentation rather than maintain private copies of material that already exists and is maintained elsewhere.

### 2.3 Preserve accumulated experience

Authoritative documentation does not necessarily contain everything developers need to know.

Our own knowledge base should capture:

- Gotchas.
- Undocumented or poorly documented behavior.
- Misleading or incomplete documentation.
- Compatibility issues.
- Practical tips.
- Useful workarounds.
- Unexpected behavior discovered through implementation.

This accumulated experience is potentially one of the most valuable assets of the methodology.

The guiding principle:

**Link to what others know; preserve what we've learned.**

### 2.4 Context is a resource

Context windows have finite capacity, and useful information competes for the model's attention.

The precise point at which additional context produces diminishing returns is unknown and likely varies between models and over time.

We should assume diminishing returns exist rather than depend on finding a universal threshold.

The methodology should therefore:

- Avoid unnecessarily loading irrelevant information.
- Make information discoverable and selectively accessible.
- Delegate work with focused instructions and relevant context.
- Externalize important information instead of relying on conversation history.
- Support recovery after context compaction or session interruption.

A large context window does not eliminate the need for context management.

Likewise, a smaller context window does not necessarily limit the total amount of work that can be performed. Tools such as OpenCode can compact and recycle context during longer tasks. However, compaction introduces the risk of losing important details.

The goal is to preserve the information necessary to continue working, not preserve every conversation.

### 2.5 Model selection should follow the work

Different models have different capabilities, costs and context limits.

A stronger model may be useful for:

- Understanding ambiguous requirements.
- Architectural reasoning.
- Discovering and establishing patterns.
- Decomposing complex tasks.
- Resolving unexpected situations.

A less expensive or smaller model may be suitable for:

- Implementing well-specified tasks.
- Applying established patterns.
- Performing bounded changes.
- Running clearly defined verification procedures.

Model selection should depend on uncertainty and consequences, rather than rigidly assigning models to workflow phases.

A lightweight execution agent should not improvise when it encounters unresolved architectural decisions. It should escalate the issue for further reasoning.

## 3. The engineering workflow

The following workflow is a starting point, not a rigid process specification.

### 3.1 Understand the task

Establish:

- Desired outcome.
- Functional requirements.
- Constraints.
- Relevant technologies.
- Existing system behavior.
- Acceptance criteria.

Ambiguities and missing information should be identified rather than silently resolved through assumptions.

### 3.2 Identify the domain and authoritative sources

Identify the technologies, frameworks, providers and versions relevant to the task.

Locate authoritative documentation and record references in the repository knowledge base.

This is a deterministic part of the process: domain knowledge should be externalized regardless of the model's confidence.

### 3.3 Perform gap analysis

Compare the desired outcome with the current state.

Identify what is missing, what must change and what already exists.

A gap describes a difference between the current and desired states. It is not necessarily an implementation task.

### 3.4 Decompose gaps into tasks

Break the identified gaps into manageable engineering tasks.

One gap may require several tasks. One task may address several gaps.

Tasks should have sufficiently clear boundaries that they can be independently understood, delegated and verified where practical.

### 3.5 Discover and select patterns

Identify existing patterns that may apply to each task.

Pattern discovery and pattern selection are separate activities:

- Discovery finds potentially relevant patterns.
- Selection determines whether a pattern actually applies.

An existing pattern should not be forced onto a task merely because its description looks similar.

### 3.6 Establish missing patterns

When no suitable pattern exists, establish an initial experimental pattern.

This can be an MVP 0.1 version: sufficient to guide the current implementation, without pretending to be universally applicable or fully validated.

Patterns should evolve through experience.

A possible maturity classification is:

- Experimental.
- Validated.
- Established.

Successful implementation is evidence of usefulness, but does not automatically prove that a pattern is generally applicable.

### 3.7 Prepare execution tasks

Execution instructions should provide enough information to make implementation predictable.

They should include, as appropriate:

- Task scope and boundaries.
- Expected outcome.
- Relevant requirements.
- Applicable patterns.
- Relevant knowledge references.
- Acceptance criteria.
- Dependencies.
- Verification instructions.
- Instructions for unexpected situations.

If a task still requires an unresolved architectural decision, it is not ready for straightforward execution.

### 3.8 Execute

Delegate appropriately sized tasks to suitable models or agents.

Agents should receive focused instructions and the information relevant to their responsibilities.

Unexpected conditions, discoveries and unresolved decisions should be recorded and escalated where appropriate.

### 3.9 Verify

Verify both individual tasks and the overall desired outcome.

Verification should not be limited to whether the implementation appears successful.

It should consider:

- Acceptance criteria.
- Original requirements.
- Regression risks.
- Relevant constraints.
- Whether the implementation actually follows the intended patterns.

## 4. Patterns and their documentation

Patterns should be stored as individual Markdown documents.

A possible initial structure:

```text
docs/
  patterns/
    README.md
    add-api-endpoint.md
    introduce-background-worker.md
```

The `README.md` provides navigation and discovery.

Individual pattern documents can evolve organically.

Potential pattern attributes include:

- Name.
- Intent.
- Problem being solved.
- Applicability.
- Preconditions and constraints.
- Process or steps.
- Expected outcome.
- Verification.
- Limitations.
- Maturity.

These attributes are suggestions, not a mandatory schema for MVP 0.1.

The most important characteristic is that a pattern describes a repeatable process for a recognizable class of tasks.

## 5. Knowledge documentation

Knowledge documentation and patterns serve different purposes.

Knowledge documentation describes facts, references and accumulated experience about technologies or domains.

Patterns describe how to solve recurring engineering problems.

A possible structure:

```text
docs/
  knowledge/
    README.md
    terraform/
      README.md
      providers.md
      version-compatibility.md
      gotchas.md
```

Authoritative sources should be linked with their applicable versions and relevant sections.

Our own findings should preserve enough context to make them useful to future work.

For example:

> While introducing a background worker using library X, we discovered that graceful shutdown behaves unexpectedly when jobs are still pending. The official documentation does not adequately cover this scenario.

Such a finding might eventually belong in:

- General knowledge about library X.
- A background-worker pattern.
- Both, if it describes a general limitation and a practical solution.

The task in which a discovery occurred provides valuable context for deciding where it belongs.

## 6. Task-specific working state

The `.task/` directory is intended to provide persistent working state for the task at hand.

It is more than a temporary scratch-pad.

It should help overcome limitations of conversational context, provide shared state between agents and support recovery after interruptions or compaction.

The guiding rule:

**If it matters, put it in `.task/`.**

Information worth preserving includes:

- Corrections.
- Constraints.
- Discoveries.
- Surprises.
- Decisions.
- Relevant observations.
- Outstanding questions.
- Important implementation details.

The exact document structure should remain flexible.

### 6.1 Agent collaboration

Agents may have their own working areas under `.task/`.

For example:

```text
.task/
  README.md
  agents/
    planner/
    executor-01/
    executor-02/
    verifier/
```

The exact organization remains to be determined.

Agents should be able to contribute to shared task knowledge.

An agent completing its work may append its notes to the shared collection rather than requiring a coordinator to selectively approve every observation.

Repeated observations are potentially valuable signals of importance.

For example, if several independent agents encounter the same issue, that repetition may be useful when reconciling the findings into a persistent pattern or knowledge document.

Notes should preserve situational context, such as:

> While doing X, I discovered Y.

The emphasis should be on preserving the circumstances and usefulness of the finding, not merely administrative metadata.

### 6.2 Reconciliation

The task-specific working state should have a defined lifecycle.

Before a pull request is created or updated, the accumulated `.task/` contents should be reviewed.

Valuable findings should be incorporated into persistent documentation, such as:

- Patterns.
- Knowledge documents.
- Conventions.
- Architectural decision records.
- Other relevant documentation.

The review should consider both individual discoveries and repeated observations.

This reconciliation is important enough to be enforced.

An existing experimental Claude Code plugin provides a starting point: it blocks creating or updating pull requests while `.task/` contains outstanding material.

The intention is to make knowledge reconciliation part of the engineering process rather than an optional afterthought.

## 7. Process documentation

Engineering knowledge and process bookkeeping are separate concerns.

Engineering knowledge captures what was learned.

Process documentation captures how the work was performed, including:

- Plans.
- Task decomposition.
- Dependencies.
- Agent assignments.
- Progress.
- Decisions.
- Coordination.
- Outstanding work.

The amount of process documentation should scale with the complexity of the challenge.

A simple task might require only a short plan.

A more complicated undertaking might need substantial decomposition, dependencies and coordination records.

Plans should be individual documents rather than one enormous master plan.

For example:

```text
docs/
  plans/
    README.md
    introduce-pattern-discovery.md
    improve-agent-coordination.md
  adrs/
    README.md
    0001-use-claude-skills-as-initial-package.md
```

Plans describe intended work. ADRs record decisions and their rationale.

A plan may change or be abandoned without erasing the architectural reasoning recorded in an ADR.

## 8. Documentation architecture and conventions

All project documentation should be Markdown.

Documentation should be organized around clear responsibilities, with navigational documents pointing towards more detailed material.

### 8.1 Navigational documents

Markdown files with uppercase filenames are considered navigational documents.

Examples:

- `README.md`
- `CONVENTIONS.md`
- `DESTINATION.md`
- `OPEN_QUESTIONS.md`
- `ARCHITECTURE.md`

Navigational documents explain structure, responsibilities, relationships and where to find information.

They should generally avoid containing extensive deep-dive material when a separate document would be more appropriate.

A navigational document has a soft limit of 150 lines.

When it exceeds that limit, refactoring should be considered.

The intention is to keep navigation concise and useful, not impose an arbitrary hard limit.

### 8.2 Deep-dive documents

Markdown files with more conventional filename casing are considered detailed documentation.

Examples:

- `pattern-discovery.md`
- `agent-coordination.md`
- `terraform-provider-gotchas.md`

They can contain detailed explanations, guides, procedures, references and accumulated knowledge.

There is no arbitrary length limit.

### 8.3 Hierarchical documentation

Navigational documents can exist at any directory level.

For example:

```text
/
  README.md
  CONVENTIONS.md
  DESTINATION.md
  OPEN_QUESTIONS.md

  docs/
    README.md
    CONVENTIONS.md

    patterns/
      README.md
      CONVENTIONS.md

    knowledge/
      README.md
```

A document applies to its directory and descendants unless explicitly scoped otherwise.

More specific documentation can refine general guidance.

Conflicting instructions need a defined resolution mechanism. More specific guidance should not silently override higher-level mandatory constraints.

### 8.4 Controlled navigational vocabulary

We should initially use a deliberately small, closed set of allowed navigational filenames.

The set can be expanded, but introducing new navigational document types should be a deliberate decision and reflected in the conventions.

This helps agents understand where information belongs and avoids accidental proliferation of competing document types.

The initial set is provisional and should be defined in `CONVENTIONS.md`.

## 9. Packaging and integration

The initial target environments are:

- Claude Code CLI, used at work.
- OpenCode, used at home.

The preferred approach is to share the methodology rather than maintain separate implementations.

A Claude-compatible skill is a promising initial packaging mechanism because OpenCode supports Claude-style skills.

The skill should be a relatively small entry point and orchestrator.

It should explain:

- What the workflow is.
- When to use it.
- How to start.
- Where the supporting instructions and documentation live.
- How to invoke or delegate the relevant activities.

It should not necessarily contain the entire methodology.

Supporting material can be loaded as needed.

The approximate 200-line skill guideline is a useful initial design target, not a reason to squeeze the entire methodology into the skill.

Authoritative documentation about Claude Skills and OpenCode's skill support should be collected in the repository's knowledge/reference documentation.

The actual compatibility and loading behavior should be verified rather than assumed.

## 10. Proposed repository structure

The following is an initial proposal, not a mandatory final structure.

```text
engineering-workflow/
  README.md
  DESTINATION.md
  OPEN_QUESTIONS.md
  CONVENTIONS.md

  .claude/
    skills/
      engineering-workflow/
        SKILL.md
        references/

  docs/
    README.md
    CONVENTIONS.md

    methodology/
      README.md
      workflow.md
      pattern-management.md
      context-management.md
      agent-collaboration.md

    patterns/
      README.md

    knowledge/
      README.md

    plans/
      README.md

    adrs/
      README.md

    references/
      README.md
      claude-skills.md
      opencode-skills.md

  .task/
```

If aspects can be achieved using rules or something other than plugins, then that's an avenue worth exploring.

The structure should evolve as actual content and usage demonstrate what is needed.

Directories and their navigational documents should not be created merely to satisfy a predetermined structure.

## 11. Development approach

The methodology should be developed by using it.

We should avoid over-engineering the process before we have practical experience.

Start with a simple repository and relatively straightforward engineering tasks.

Gradually introduce more challenging domains and technologies, such as Terraform and infrastructure-as-code.

This should help expose limitations in:

- Pattern discovery.
- Domain knowledge.
- Task decomposition.
- Model selection.
- Context management.
- Agent collaboration.
- Verification.

Model performance may depend on both methodology and domain knowledge. These should not be confused.

A weaker model with access to well-prepared patterns and authoritative references might perform better than a stronger model given only an original task description.

This is an important hypothesis worth exploring.

The methodology should also be tested with different model combinations, including hosted frontier models and locally hosted models with smaller context windows.

The goal is not to optimize for one particular model or provider.

## 12. Initial development milestones

The first development steps are deliberately simple.

### Step 0.1 — Capture

Convert the current exploratory discussions into one comprehensive Markdown document.

This document is the initial capture of the destination and the reasoning behind it.

At this stage:

- Do not worry about the 150-line navigational-document limit.
- Do not prematurely impose a final document hierarchy.
- Preserve the distinctions and nuances discussed.
- Separate agreements from hypotheses and open questions.
- Avoid silently converting proposals into established decisions.

### Step 0.2 — Refactor

Use the captured document as input for a documentation-refactoring exercise.

The objective is to produce an initial coherent documentation structure suitable for the first operational iteration.

This includes:

- Splitting the destination into focused documents.
- Establishing navigational documents.
- Creating initial conventions.
- Identifying open questions.
- Defining the proposed repository structure.
- Creating the initial Claude-compatible skill.
- Verifying OpenCode compatibility.
- Preparing the first usable workflow.

### MVP 0.1 — First operational iteration

Use the resulting methodology to perform actual engineering work.

The initial repository itself is a suitable first experiment.

This creates a useful recursive relationship: we use the methodology to develop and improve the methodology.

The first operational version does not need to implement every idea in this document.

It needs to be useful enough to expose what works, what doesn't and what should change.

## 13. Evolution

This document describes an intended destination, not a contractual specification.

Ideas and plans are expected to change when they encounter reality.

The project should preserve useful knowledge, not preserve ideas merely because they were once proposed.

Git provides the historical record of how the documentation and implementation evolve.

The authoritative documentation should always represent the current understanding, even when that means substantially changing or replacing earlier ideas.

The most important measure of success is whether the methodology improves real engineering work.
