# Sprints

The CORE Platform board uses three permanent sprints as a **priority signal** — not time-boxes.

| Sprint | Meaning |
|--------|---------|
| NOW | Currently being worked on |
| NEXT | Up next once NOW items clear |
| FUTURE | Planned but not imminent |

Sprint field: `customfield_10020`. Board ID: `181`. (Both in `instance.md`.)

## Looking up sprint IDs

Always look up sprint IDs by name rather than hardcoding — IDs can change if sprints are deleted and recreated:

```bash
curl -s --netrc \
     -H "Accept: application/json" \
     "<base-url>/rest/agile/1.0/board/181/sprint" \
  | jq '[.values[] | select(.name == "NOW") | {id: .id, name: .name, state: .state}]'
```

## Field encoding

- **Creating**: pass as a plain integer — `"customfield_10020": 4354`
- **Updating**: same — `{"fields": {"customfield_10020": 4354}}`
- Object form `{"id": 4354}` is rejected with a validation error.

When creating or updating a CORE ticket, ask which sprint it belongs to if not obvious from context.
