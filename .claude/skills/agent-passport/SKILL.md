---
name: agent-passport
description: Use when changing, testing, committing, publishing, submitting or promoting an Agentforce agent (Agent Script .agent files, bots, topics, actions, or the Flows, Apex and prompt templates they use) in a Copado project, or when `agentia cicd work test` or `work submit` fails with "PASSPORT NOT VALID".
---

<!-- Agent Passport managed skill file: agentia passport setup -->

# Agent Passport

An Agentforce agent is only safe to promote when three things hold: everything it depends on travels with the story,
it still behaves as the story's acceptance criteria say, and nothing changed after that was proven. Agent Passport
checks all three and records the proof in `passport/`. The project's local quality gate runs
`agentia passport verify`, so `agentia cicd work submit` stops until the passport is valid.

**Division of work:** you run `sf` and Agentia; the plugin only reads files and Git. Add `--json` whenever you parse
output. Prefer Agentia MCP tools (`agentia_*`) for Copado operations when they are available; the CLI is the fallback.

## Workflow

`story → scan → travel → deployment steps → goldens → previews → stamp → report → commit passport/ → work test → publish → submit`

1. **Story context.** `agentia cicd work get --json` (MCP: `agentia_work_get` without an id). If no story is active,
   tell the user and stop. Do not pick one yourself.
2. **Scan.** `agentia passport scan --agent <Agent> --json`. Fix every `error` finding in the agent or project before
   going on (for example `MISSING_DEPENDENCY`, `UNKNOWN_TARGET`, `NAME_MISMATCH`, `AGENT_USER_HARDCODED`).
3. **Travel.** `agentia passport travel --to <next environment> --agent <Agent> --json`
   (`--to-branch <branch>` when offline). For each `TRAVEL_GAP`, commit the missing file to the story with
   `git add` / `git commit`; `travel` names the file and the reason.
4. **Deployment steps.** Each item in `requirements` has a `proposedStep` for what metadata cannot carry (the agent
   user; publish and activate). First list what the story already has: MCP `agentia_work_deployment_step_list`
   (CLI: `agentia cicd work deployment-step list --json`). Skip steps whose name already exists. Show the user the
   steps you will add, then create each one with MCP `agentia_work_deployment_step_create`, or with the CLI:
   `agentia cicd work deployment-step create --type "Manual Task" --name "<name>" --instructions "<instructions>" --sequence <order> --environment destination --json`
   (`order` is `before` or `after`). Never delete or change steps you did not create.
5. **Golden conversations.** `agentia passport goldens init --agent <Agent> --json` drafts one conversation per
   acceptance criterion in `passport/goldens/<agent>.json`. Write each `utterance` as described in
   [references/writing-goldens.md](references/writing-goldens.md). Add expectations by hand only where `needsReview`
   asks for it.
6. **Previews.** `agentia passport goldens plan --agent <Agent> --target-org <alias> --json` prints the exact
   `sf agent preview` commands. Run them one session at a time, in order, from the project root (Salesforce CLI saves
   the traces there). Use live actions unless the user agreed to `--simulate`.
7. **Stamp.** `agentia passport stamp --agent <Agent> --env <current environment> --json`.
   - `stamped`: go on.
   - `refused`: read the first failing check of each conversation. Fix the **agent** (its script, actions, Flows or
     Apex), not the golden conversation. Then run the plan again and stamp again.
   - `REGRESSION`: something that used to pass now fails. Tell the user.
8. **Report and commit the proof.** `agentia passport report --env <current environment> --travel-to <next environment>`
   writes `passport/report.html`, the readable passport for reviewers. Then `git add passport/` and commit it to the
   story with the change. Stamps and the report travel with the story so reviewers see them.
9. **Gate.** `agentia cicd work test --json` (MCP: `agentia_work_test`). It runs `agentia passport verify`.
   If it says `PASSPORT NOT VALID`, the table says why: no stamp, refused stamp, stale stamp (the agent, a dependency
   or the goldens changed after stamping), scan errors, or travel gaps. Fix that and repeat from the step it names.
10. **Publish and submit.** `agentia cicd work publish --json`, then `agentia cicd work submit --json`. Run
    `submit --deploy` or `--done` only when the user explicitly asks to promote.
11. **Next environment.** After Copado deploys to the next environment, run the same golden conversations against that
    org and stamp it: `agentia passport stamp --env <next environment> --agent <Agent>`.

## Rules

- Never make a failing check pass by weakening it: do not delete or loosen expectations, lower `passThreshold` or
  `runsPerConversation`, or rewrite an utterance until it passes. A changed goldens file makes the stamp stale, and the
  change shows in the story's diff. If a criterion is wrong, tell the user.
- Never write or edit files under `.sfdx/agents/**/sessions/`, `passport/stamps/` or `passport/baselines/` by hand.
  They are evidence. Use `stamp --update-baseline` only when the user agrees the new behaviour is the right one.
- Never use `agentia cicd work submit --skip-local-tests` to get past a failing passport.
- Never print credentials, tokens, OAuth signatures or org usernames from command output.
- `agentia passport setup` manages the gate scripts and this skill. Do not hand-edit the lines between the
  `agent-passport` markers in `.agentia_quality_gates.*`; run setup again instead.

## Report back

Say which agent and environment you checked, the stamp verdict with pass rates, any regressions, the deployment steps
you added, and anything left for the user (for example, a criterion that needs rewording).
