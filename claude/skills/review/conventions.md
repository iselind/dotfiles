# Review conventions

Apply these throughout Phase 2.

## Finding issues

- **Never skip an item without explaining why.** If an item turns out to be a non-issue on closer inspection, update the plan to `✅ Accepted — <reason>` rather than silently skipping it. Then ask: could this same trigger recur? If a small, low-risk clarification would make the correct interpretation obvious without changing the substance, make it.

- **Missing sections:** Before logging, test whether the absent content would add information a reader could not derive from what is already present. If the document already conveys the substance, it is a structural preference, not a real gap.

- **Migration concerns:** Before logging an external caller migration concern, verify the affected behaviour exists on `main`. If it was introduced on the current branch, no external caller has adopted it — the concern does not apply.

- **Code behavior classified as Bug:** Before logging, check whether a code comment acknowledges or explains that behavior. A comment citing future work ("X replaces this", "transitional until Y") signals intent, not oversight. The real finding is typically a documentation gap — redirect to Cleanup if the plan doesn't explain the transitional design clearly.

- **Implicit architectural assumptions:** When assessing severity, do not default to "nice-to-have flexibility". Ask: for which deployment contexts does this assumption fail? If it fails for an entire class (air-gapped, on-prem, data-sovereign), severity is high regardless of how natural the assumption feels.

- **Contradicting claims:** When two claims in the same document contradict each other, investigate before proposing a fix. Ask what architectural assumption would need to be true for both to hold; if none exists, the fix belongs at the design level. The author may hold relevant context not yet in the text.

- **Plan language:** Preserve the hedging actually present in the text. Plans use tentative language ("expected", "likely", "would follow") — do not paraphrase into categorical claims. Overstating what a plan commits to or rejects deflects the initial engagement before the user can confirm the inference.

## Fixing issues

- **Keep fixes minimal** — this is a review pass, not a refactor. Flag any fix with meaningful risk or side effects before proceeding.

- **After editing a sentence**, re-read the full paragraph — a local edit often reveals adjacent issues (wrong names, unclear pronouns, stale phrasing) that were masked by the original problem.

- **Before marking a fix complete**, check whether it should apply consistently to all sibling or parallel instances (e.g. if fixing one of four symmetric steps, verify the other three).

- **For terminology, naming, or reference fixes**, search across all documents in scope — a symptom in one file often has counterparts in others. Check both directions: existing references are accurate AND new content is reachable from the relevant context.

- **When writing new content** (descriptions, sentences, sections), verify it against relevant ADRs and design documents. A fix that resolves the tracked issue while re-introducing a different class of error is not complete.

- **When fixing a Premature design item**, the replacement text can silently reintroduce the same error. Watch for: readiness claims about unimplemented work ("already designed to accommodate this", "already stubs X"), pre-commitments to a specific approach, assumptions about undefined interfaces. When in doubt, drop the forward reference entirely.

- **After any fix that moves or removes content**, compare removed lines against the replacement to confirm no substance was silently dropped. Check line by line.

- **Partial descriptions:** When removing a count, name, or qualifier from a larger phrase, verify the remaining text is still accurate. The removed element may not have been the only thing wrong.

- **Ambiguous terms:** Before proposing a substitution, investigate what the term actually refers to across the full document set. An ambiguous term may signal a conceptual gap — something genuinely underdefined — not a poor word choice. If so, the fix is a concept clarification, not a name substitution.

- **Data-flow or behavioral descriptions:** Establish the correct conceptual framing before suggesting a substitution — ask what intent is being described, not just which term is imprecise. Replacing one imprecise term with another is not an improvement.
