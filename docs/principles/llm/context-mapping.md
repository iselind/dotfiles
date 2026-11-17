PRINCIPLE-OF-CONTEXT-MAPPING

Before requesting LLM actions, explicitly map:
1. Current workspace state (repository structure, config files in scope)
2. Git branch and working tree status
3. Dependencies required for the task (npm, cargo, environment variables)
4. Constraints on changes (files to preserve, breaking change policy)

Then request LLM to acknowledge this mapping before proceeding with implementation.

Rationale: Without explicit context grounding, LLMs hallucinate existing code structure and propose invalid modifications.
