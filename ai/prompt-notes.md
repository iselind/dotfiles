Right now the prompt is:
```
Refactor this
<file content>
```
For instruct models, it’s better to explicitly frame the task. Replace:
```
FULL_PROMPT="$PROMPT
$INPUT"
```
with
```
FULL_PROMPT="You are a senior software engineer performing a code review.

Task:
$PROMPT

Code:
$INPUT

Response:"
```
This dramatically improves smaller models.

Another option might be
```
You are a deterministic code reviewer.

File: foo.ts
Focus lines: 40-80

--- FILE START ---
<entire file here>
--- FILE END ---

Instructions:
Explain only the focus lines.
Use surrounding context when necessary.
Do not speculate about missing files.
Be concise.
```
