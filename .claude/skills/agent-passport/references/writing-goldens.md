<!-- Agent Passport managed skill file: agentia passport setup -->

# Writing golden conversations

A golden conversation is a test chat that proves one acceptance criterion. `goldens init` writes the expectation
(which subagent or topic the chat must reach, which actions must or must not run); you write what the customer says.

## The file

`passport/goldens/<agent>.json`:

```json
{
  "agent": "CustomerServiceAgent",
  "bundle": "CustomerServiceAgent",
  "passThreshold": 1,
  "runsPerConversation": 3,
  "schemaVersion": 1,
  "conversations": [
    {
      "id": "AC-1",
      "criterion": "A refund request routes to the resolution subagent.",
      "story": "US-0000025",
      "needsReview": ["Write the customer message (utterance) that tests this criterion."],
      "turns": [{"utterance": null, "expect": {"inputsResolved": true, "topic": "resolution"}}]
    }
  ]
}
```

## Utterances

- Write what a real customer would type: first person, plain words, one request. For the criterion above:
  `"I was charged twice for my last order and I want a refund"`.
- Do not name the subagent, topic or action (no "route me to resolution"). The test is whether the agent gets there.
- Include the details the action needs to run for real (an order number, a product), or the agent will only ask a
  follow-up question. For a follow-up, add a second turn: `{"utterance": "It was order 1042", "expect": {...}}`.
- Use made-up data only. No real customer names, emails or record Ids.
- After writing, remove the `needsReview` entry you resolved. Leave entries you could not resolve and tell the user.

## Expectations

| Field | Checks |
|---|---|
| `topic` | the turn reached this subagent (Agent Script) or topic (classic) |
| `actionsInclude` | these actions ran in the turn |
| `actionsExclude` | these actions did not run (for "must not" criteria) |
| `replyMatches` / `replyNotMatches` | the reply matches / does not match this case-insensitive regular expression |
| `inputsResolved` | no action received an unfilled merge field such as `{!state.issue_type}` (default true; keep it) |

Use only names that exist in the agent: `goldens plan` refuses unknown subagents, topics and actions. Add a
`replyMatches` pattern when a criterion is about what the agent says, for example `"case (number|#)\\s*\\d+"` for
"tells the customer the case number".

## Why each conversation runs several times

Agent routing comes from a language model and can vary between runs. `runsPerConversation` (default 3) and
`passThreshold` (default 1, meaning every run) make a stamp mean "passes reliably", not "passed once".
