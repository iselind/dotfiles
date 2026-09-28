---
name: doc_file_organization
description: Capital-letter files (CLAUDE.md, ARCHITECTURE.md) are navigational indices with 150-line soft limit; lowercase files are deep-dive reference material
metadata:
  type: feedback
---

**Pattern:** Documentation is organized in two tiers to prevent kitchen-sink files and keep navigation clear.

**Tier 1: Capital-letter files** (CLAUDE.md, ARCHITECTURE.md, README.md, etc.)
- **Purpose:** Navigational and orientation — guide readers (human and agent) to where information lives
- **Soft limit:** ~150 lines; once beyond that, serious consideration should go into refactoring
- **Content:** High-level guidance, project overview, cross-references to detailed docs, quick-start instructions
- **Audience:** Both humans and agents — written to be equally useful to either
- **Handling overflow:** Break into lowercase deep-dive files (guides, ADRs, plans) and link from here

**Tier 2: Lowercase-letter files** (guides, plans, adr-*.md, reference-*.md, etc.)
- **Purpose:** Deep dives and reference material — can be comprehensive without worrying about size
- **Content:** Detailed explanations, decision records, implementation guides, thorough examples, troubleshooting
- **Audience:** Both humans and agents — same philosophy, but free from size constraints
- **Naming convention:** Use descriptive names (e.g., `deployment-strategy.md`, `adr-001-gitops-architecture.md`)

**Why:** Keeps files scannable and navigational (`CLAUDE.md` won't be a 500-line kitchen sink), but allows proper depth where needed. Explicitly writing for both agents and humans avoids creating agent-specific documentation that humans can't use effectively.

**How to apply:**
- When a capital-letter file approaches 150 lines, ask: "Can any of this become a standalone deep-dive file that I link from here?"
- When adding documentation, default to human+agent audience — avoid agent-only patterns or agent-specific instruction hiding
- See [[change_support_evidence]] for how to decide what documentation should exist in the first place.
