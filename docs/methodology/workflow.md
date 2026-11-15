# Engineering Workflow

This document describes the pattern-oriented methodology for LLM-assisted engineering.

## Core Idea

LLMs excel at recognizing and applying patterns. This methodology externalizes patterns and domain knowledge to reduce reliance on individual model capabilities.

## Eight-Step Process

1. **Understand** - Clarify requirements, constraints, technologies
2. **Domain** - Identify authoritative documentation for relevant technologies
3. **Gap analysis** - Compare current state vs desired outcome
4. **Decompose** - Break gaps into manageable tasks
5. **Discover patterns** - Find applicable existing patterns
6. **Establish patterns** - Create new patterns when none exist
7. **Prepare tasks** - Write execution instructions with all necessary context
8. **Execute & Verify** - Delegate to models and verify results

See [step-by-step guide](workflow.md) for detailed instructions on each phase.

## Key Principles

- **Patterns as foundation** - Document repeatable processes, not just code snippets
- **Externalize knowledge** - Don't assume models know domain information
- **Preserve experience** - Capture gotchas and workarounds
- **Manage context** - Avoid overloading with irrelevant information
- **Right model for the job** - Match task complexity to model capabilities
