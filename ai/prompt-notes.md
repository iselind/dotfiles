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
