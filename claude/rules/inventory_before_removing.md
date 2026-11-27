---
name: Inventory dependents before removing a mechanism
description: Before writing a plan item that removes or retires something, check what currently depends on it from the consumption side
type: feedback
---

Before writing a plan item that removes a mechanism (generated field, script behaviour, convention, injection step), inventory everything that currently depends on it — look at the consumption side (manifests, callers, external repos), not just the authoring side.

**Why:** In CORE-588, plan item 5 ("remove global.registry generation") was written after reasoning only from the authoring side — `hello-world` was the only chart we were building, so it seemed like the only chart to worry about. Three HelmRelease manifests for external `corero-eng/corelet-*` charts were invisible from that angle because this repo doesn't build them. A grep for `global.registry` in the gitops tree revealed them immediately once the question was asked — but the question almost wasn't asked.

**How to apply:** When a plan item says "remove X" or "retire X", ask: "what in the consumption layer currently depends on X?" Check manifests, callers, external repos. The authoring side is never the full picture. For a live object in a cluster, remove it only after every consumer has stopped reading it, and through the hook the common workflows expose (for example a pre-reconcile hook), so every environment gets the same removal, never by hand. User, about the old `corelet-shell-bootstrap` Secret: "We'd not delete by hand anyway. Instead we'd use a pre-reconcile hook or something like that the common workflows expose to us so the same thing gets done correctly across all environments. But such a deletion is not something that would be appropriate to do until all users of that secret has transitioned away from using it."
