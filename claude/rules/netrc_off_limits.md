---
name: netrc-off-limits
description: Never read or access ~/.netrc under any circumstances
metadata:
  type: feedback
---

**Rule:** Do not read, access, or reference ~/.netrc under any circumstances whatsoever.

**Why:** User has a PAT in ~/.netrc for Jira authentication — it's sensitive credentials that must remain private.

**How to apply:** If auth setup is needed, work with environment variables or other credential-passing mechanisms. Assume the user has .netrc configured and working; never try to verify or read it.
