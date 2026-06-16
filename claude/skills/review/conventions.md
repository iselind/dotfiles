# Review conventions

This file guides code review. Apply these patterns when reviewing a branch.

---

## Phase 1–3a: Environmental anchoring

When reading the diff cold, traverse outward through the codebase graph: start from the branch changes, understand context by examining related patterns/resources, and stop when signal-to-noise drops (typically within 2–3 steps).

**Missing documentation is NOT a stop criterion** — if something is hard to verify due to missing docs, that's a gap to report. **DO stop at hypotheticals** — if you're making assumptions about behavior you can't verify even with available information, that's noise.

**Also verify:** Are conventions documented at the appropriate level in the directory hierarchy? A convention buried too deep or too high won't be discoverable when it matters.

---

## Phase 2: Pattern verification

Review against these patterns when examining changed code, tests, comments, and documentation.

### Finding issues

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

---

## Phase 3b: Pattern categories

When reviewing changed files, look for these patterns:

### Missing test-cases

Untested edge cases, missing assertions, or insufficient coverage:
- When a branch adds a new code path, check that it is covered by tests — not just exercised, but actually asserted against.
- When a branch adds a new test file, check that it covers edge cases and failure modes, not just the happy path.
- When a branch adds a new test assertion, check that it is not redundant with existing assertions and that it meaningfully tightens the test's verification of the target behaviour.

### Comment quality

Inaccurate, misleading, or stale comments:
- Comments should avoid reiterating the "what" and instead focus on the "why".
- Fixing a "what" comment is done in one of two ways: remove it or replace it with a proper "why" comment. The latter is for cases when the why is less obvious.

### Bug

Code that is incorrect or could fail:
- **CI and test scripts:** Check for fixed paths used as temporary state. Two concurrent runs on the same runner will collide.
- **PromQL expressions:** Verify that both sides of a vector join using `on(...)` are aggregated to the same label set as the join key — extra labels on either side not named in `on()` cause silent fan-out (left) or silently dropped series (right).
- **Non-deterministic sources:** When code collects items from a non-deterministic source (any unordered collection) and serializes or compares the result for idempotency, verify the items are sorted or otherwise canonicalized before serialization — without this, the same logical state can produce different bytes across calls.
- **Migration/replacement:** When a branch replaces X with Y (migrating frameworks, converting tests, swapping libraries, rewriting a component), read the deleted content alongside the additions and verify every behaviour or capability of X is covered by Y — migration gaps are silent by definition.

### Security

Credentials, injection risk, over-permissive access.

### Gap

Unspecified mechanism or missing prerequisite that forces an undocumented design decision on the implementer.

### Suggestion

Correct but improvable patterns or inconsistencies:
- **CI and test scripts:** Flag package installs into global environments (prefer isolated venvs or temp dirs to avoid runner pollution and ensure reproducibility).
- **Guards and filters:** When a filter, label selector, or guard is present on some items in a file, read the **full file** and verify it is applied to all analogous items — not just those in the diff. This applies equally to new files and modified files.
- **Consistency across representations:** When the same component is described in more than one place (different config profiles, deployment paths, packaging formats), verify that identity and configuration fields are consistent across all representations — not just the one touched by the diff.
- **Test assertion consistency:** When a test assertion is tightened or a guard is added, scan the full test file for other assertions of the same form and apply the same tightening consistently — don't stop at the diff boundary.
- **Relocation guidance:** When a branch moves code or tests from one directory to another, check whether CLAUDE.md guidance co-located with the source location is still relevant there — it may belong at a higher level or closer to the new location.

### Verification

Things that must be confirmed before merge.

### Cleanup

Dead code, stale comments, misleading names:
- When a diff changes the default value or activation condition of an input (e.g. empty string → real value, opt-in → always-active), check that the input's description doesn't use conditional framing that has become stale — phrases like "when provided", "if set", "callers adopting X", or "callers on the Y path" that imply the feature is optional when it is no longer so.

### Overlap

Unwarranted duplication between plans, ADRs, and OPENs (e.g. a plan section restating rationale that an ADR now captures, or an OPEN repeating context already settled elsewhere).

### Premature design

Detailed design content for work that is explicitly deferred, out of scope, or multiple stages removed from the current work:
- Look for: design notes for components marked as future or optional, detailed requirements or options for infrastructure that depends on unresolved prerequisites, work items that describe deferred steps at the same level of detail as immediate ones.

### Minor

Low-impact observations worth recording.

---

## ADR and OPEN scrutiny

**Branch-introduced ADRs/OPENs — full quality review:**

*Classification:*
- An ADR whose rationale depends on an unresolved question is premature — propose an OPEN instead.
- An OPEN whose question is already answerable from context should be promoted.

*Cross-reference discipline:*
- ADRs must not reference documents with shorter expected lifespans (OPENs, plans).
- Such references become dangling when the shorter-lived document is deleted.
- If an ADR's rationale depends on an unresolved OPEN or an in-flight plan, the ADR itself is likely premature.

*Section discipline:*
- **Context** must not preview or argue for options.
- **Options** must be complete with no missing failure modes or language that pre-empts the decision, and must describe approaches at the conceptual level (CRD names, API names, implementation artifacts belong in Design, not Options).
- **Rationale** must not repeat Options content.

*Framing (OPENs):*
- Is the question well-posed?
- Is context factually accurate — no false implementation claims, no assertions about what "currently" exists unless verified?
- Are all options at comparable depth?
- Are analogies grounded by properties established in the document? An analogy that imports an assumption never stated in the document should be flagged regardless of whether it seems plausible.

**Topically related ADRs/OPENs not on the branch — coherence check:**
- Do new additions conflict with, duplicate, or leave gaps relative to existing documents?
- Does the whole set tell a coherent story now that new documents have been added?
- Flag tensions and inconsistencies.
- Do not propose rewriting settled documents — surface the issue and let the user decide.

---

## Plan work items scrutiny

For each work item:
- **What would a developer need to know or decide** that is not documented? If implementation would force an undocumented design decision, that is a Gap.
- **Check dependencies on open questions.** An unresolved OPEN affecting a work item without a stated dependency is a Gap — implicit dependencies are decided under implementation pressure, not deliberately.
- **Flag descriptions that name an outcome without a mechanism** ("scoped by label selector", "X is injected", "configured with the correct Y"). If the how is unspecified and the implementer would have to invent it, that is a Gap.
- **Distinguish plan-level contract from implementation detail.** A plan should state *what* contract must hold (e.g. "the tenant ID must be readable by the sync operator") without prescribing *how* it is satisfied (label, field, annotation). Flag items that over-specify implementation detail or under-specify the contract to the point the implementer cannot know what is required.
- **Verify work items are consistent with relevant ADRs** — both pre-existing and branch-introduced. A contradiction is a Bug, not a wording issue.
