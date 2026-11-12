
## 2026-11-12 — Stop hook output: "error" label and full prompt in the UI are unwanted
The user reported two concerns with the knowledge-extraction Stop hook: "the hook having executed and found stuff in .task/ would show up as a stop hook error. Calling it an error seem strange to me" and "the prompt produced on that 'error' is displayed in full in the CLI UI, which kind of obscures the UI's 'useful' output forcing me to scroll to see it."
Preference: hook output should not flood the CLI UI; the extraction prompt (currently sent whole as `reason` in `scripts/extract-on-stop.sh`) should be short or hidden. Claude Code labels any Stop block "Stop hook error", which the hook cannot change. A short `reason` pointing at `prompts/extract.md` was proposed; not yet decided or implemented.
