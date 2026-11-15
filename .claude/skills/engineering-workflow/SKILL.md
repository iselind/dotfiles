# Engineering Workflow Skill

A Claude Code skill that provides guidance and orchestration for the pattern-oriented LLM-assisted engineering methodology.

## What This Is

This skill implements a workflow that helps:

1. Understand tasks and desired outcomes
2. Identify domain knowledge needed
3. Decompose work into manageable pieces
4. Find or establish patterns for implementation
5. Prepare clear execution instructions
6. Delegate tasks to appropriate models
7. Verify results against requirements

## When to Use It

- For complex engineering tasks requiring multi-step coordination
- When pattern discovery would improve implementation quality  
- When domain knowledge should be externalized from model context
- When working on recurring task types that could benefit from patterns

## How to Start

1. Enable this skill in your Claude Code configuration
2. Describe your desired outcome or task
3. The skill will guide you through the workflow steps as needed

## Where Documentation Lives

- Working vision: [/DESTINATION.md](/DESTINATION.md)
- Workflow details: [/docs/methodology/workflow.md](/docs/methodology/workflow.md)
- Available patterns: [/docs/patterns/](/docs/patterns/)
- Domain knowledge: [/docs/knowledge/](/docs/knowledge/)
- Process plans: [/docs/plans/](/docs/plans/)

## How It Orchestrates

The skill does not contain the entire methodology or all patterns. Instead, it:

- Explains the workflow and when phases apply
- Loads relevant patterns from documentation as needed
- Manages context by focusing on task-specific information
- Escalates architectural decisions requiring deeper reasoning

## Supported Models

Works with any model that supports Claude skills, including:

- Claude Code (hosted)
- OpenCode-compatible models
- Other LLM clients supporting the skills protocol

## Workflow Summary

The methodology follows an 8-step process: **Understand → Domain → Gap Analysis → Decompose → Discover Patterns → Establish Patterns → Prepare Tasks → Execute & Verify**.

Each phase has specific guidance, patterns, and knowledge sources as needed.
