# Review conventions

Apply these throughout Phase 2.

## Finding issues

- **Never skip an item without explaining why.** If an item turns out to be a non-issue on closer inspection, update the plan to `✅ Accepted — <reason>` rather than silently skipping it. Then ask: could this same trigger recur? If a small, low-risk clarification would make the correct interpretation obvious without changing the substance, make it.

- **Missing sections:** Before logging, test whether the absent content would add information a reader could not derive from what is already present. If the document already conveys the substance, it is a structural preference, not a real gap.

- **Migration concerns:** Before logging an external caller migration concern, verify the affected behaviour exists on `main`. If it was introduced on the current branch, no external caller has adopted it — the concern does not apply.

- **Code behavior classified as Bug:** Before logging, check whether a code comment acknowledges or explains that behavior. A comment citing future work ("X replaces this", "transitional until Y") signals intent, not oversight. The real finding is typically a documentation gap — redirect to Cleanup if the plan doesn't explain the transitional design clearly.

- **Analysis and testimony conflict on a Bug:** If code analysis clearly indicates a bug but the user says tests pass, do not resolve the conflict by accepting either side without evidence — the analysis may have a flaw, or the tests may not exercise the specific path. Propose an isolating test that directly exercises the suspected behavior. Accept or reject the finding only once the test produces a definitive result. Do not speculate about runtime explanations to reconcile the conflict.

- **Implicit architectural assumptions:** When assessing severity, do not default to "nice-to-have flexibility". Ask: for which deployment contexts does this assumption fail? If it fails for an entire class (air-gapped, on-prem, data-sovereign), severity is high regardless of how natural the assumption feels.

- **Contradicting claims:** When two claims in the same document contradict each other, investigate before proposing a fix. Ask what architectural assumption would need to be true for both to hold; if none exists, the fix belongs at the design level. The author may hold relevant context not yet in the text.

- **Plan language:** Preserve the hedging actually present in the text. Plans use tentative language ("expected", "likely", "would follow") — do not paraphrase into categorical claims. Overstating what a plan commits to or rejects deflects the initial engagement before the user can confirm the inference.

- **Cleanup items with same-named survivors:** When a cleanup item removes one thing but a similarly-named or related thing is intentionally kept, make the distinction explicit in the first sentence of the item description — not buried in the detail. A reader skimming "Dead `foo` output" who then sees "the variable itself is still needed" will experience a contradiction. Lead with the precise scope: "The `foo` *output* in `outputs.tf` is dead — no caller reads it. The `foo` *variable* is kept; it is still used by X."

## Fixing issues

- **Keep fixes minimal** — this is a review pass, not a refactor. Flag any fix with meaningful risk or side effects before proceeding.

- **When implementing a comparison or lookup**, verify the matching key uniquely identifies each item within the relevant scope before writing the implementation. Ask: could two different items have the same key value? If so, the key is incomplete — extend it before proceeding.

- **After editing a sentence**, re-read the full paragraph — a local edit often reveals adjacent issues (wrong names, unclear pronouns, stale phrasing) that were masked by the original problem.

- **Before marking a fix complete**, check whether it should apply consistently to all sibling or parallel instances (e.g. if fixing one of four symmetric steps, verify the other three).

- **When a fix involves asserting what an external function or API sets**, follow any links to authoritative documentation referenced in the surrounding project docs (CLAUDE.md, architecture docs) before concluding the assertion is complete. What those docs enumerate may be a subset of the authoritative source — don't stop at the enumeration.

- **For any content pattern fix** — a phrase, a framing, a section structure, terminology, naming, or references — search across all documents in scope before marking the fix complete. A symptom in one section often has counterparts in others. Check both directions: existing references are accurate AND new content is reachable from the relevant context.

- **When writing new content** (descriptions, sentences, sections), verify it against relevant ADRs and design documents. A fix that resolves the tracked issue while re-introducing a different class of error is not complete.

- **When fixing a Premature design item**, the replacement text can silently reintroduce the same error. Watch for: readiness claims about unimplemented work ("already designed to accommodate this", "already stubs X"), pre-commitments to a specific approach, assumptions about undefined interfaces. When in doubt, drop the forward reference entirely.

- **After any fix that moves or removes content**, compare removed lines against the replacement to confirm no substance was silently dropped. Check line by line.

- **Partial descriptions:** When removing a count, name, or qualifier from a larger phrase, verify the remaining text is still accurate. The removed element may not have been the only thing wrong.

- **Numbers in prose:** When writing a number that characterises adjacent code or a list ("three inputs", "the following four variables"), count the items in the adjacent content directly before writing it. Numbers in prose drift invisibly from the code they describe.

- **Ambiguous terms:** Before proposing a substitution, investigate what the term actually refers to across the full document set. An ambiguous term may signal a conceptual gap — something genuinely underdefined — not a poor word choice. If so, the fix is a concept clarification, not a name substitution.

- **Data-flow or behavioral descriptions:** Establish the correct conceptual framing before suggesting a substitution — ask what intent is being described, not just which term is imprecise. Replacing one imprecise term with another is not an improvement.
