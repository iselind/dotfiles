In a comment, describe the category a thing belongs to instead of listing its members, and leave out a comment that only restates what a name already says.

**Why:** User said, about a comment that named two OIDC applications that had to be changed in step with Terraform: "we could generalize the comment ... so we don't have to list each OIDC application". Of per-key comments on a ConfigMap: "I cannot see they add much value". A list of members goes stale when one is added, and nothing flags it. A comment that repeats a key's name adds text to maintain and nothing to read.

**How to apply:** Write "the OIDC applications whose URLs the template lists" and not each application's name. Before adding a comment to a line, check that it says something the name, the value and the surrounding code do not. Keep a comment that gives a reason, a constraint or a pointer to where to look (see [[point_dont_pin_other_repos]]).
