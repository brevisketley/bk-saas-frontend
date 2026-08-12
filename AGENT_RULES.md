# BK Corp Club SaaS — AI Agent Rules

These rules apply to every AI agent working on this repository, including ChatGPT and Claude.

## 1. Shared Source of Truth
GitHub is the source of truth for project state. Chat history is supplementary only.

Before working:
1. Read `AGENT_RULES.md`.
2. Read `PROJECT_STATE.md`.
3. Read `TASK_QUEUE.md`.
4. Read `HANDOFF.md`.
5. Inspect the actual code/configuration relevant to the current task.

## 2. Continue, Don't Stall
When instructed to continue the build, do not stop merely because one subtask has finished. Re-evaluate the queue and proceed to the next logical incomplete task until:
- the defined objective is complete; or
- a genuine external blocker requires an owner decision, credential, third-party action, or unavailable resource.

If blocked, document the exact blocker, evidence, and smallest required user action in `HANDOFF.md`.

## 3. Verify Before Changing
Do not assume that a feature is missing because it is not obvious. Search the repository, inspect related files, inspect configuration, and trace dependencies before implementing changes.

## 4. No False Completion
Never state or record that something is complete unless it has been tested and verified at the appropriate level. Distinguish clearly between:
- implemented
- locally tested
- integration tested
- deployed
- production verified

## 5. Preserve Product Intent
Do not silently change licensing rules, pricing, activation limits, security requirements, EA behavior, or other business logic. If a change is necessary for correctness/security, document it and preserve the original intended outcome.

## 6. Security
- Never expose secrets from `.env`, deployment settings, API keys, tokens, passwords, or private credentials.
- Never commit new secrets.
- Treat license validation and activation controls as security-sensitive server-side functionality.
- Never rely solely on frontend authorization for protected operations.

## 7. Testing Loop
For meaningful implementation work:
1. Implement.
2. Build/test.
3. Inspect errors.
4. Fix errors.
5. Re-run tests.
6. Verify integration/deployment when applicable.
7. Update state and handoff.

## 8. Documentation Loop
After meaningful progress update:
- `PROJECT_STATE.md`
- `TASK_QUEUE.md`
- `HANDOFF.md`
- `CHANGELOG.md`

Keep entries factual and concise.

## 9. Handoff Standard
Every handoff must include:
- what changed
- what was verified
- what remains
- known issues
- exact next action
- blockers, if any

The next agent must be able to continue without asking the previous agent to explain its work from memory.

## 10. Repository Hygiene
Keep changes focused. Do not introduce unnecessary dependencies, duplicate systems, dead code, or unrelated refactors while completing a task.

## 11. Production Standard
The ultimate objective is a working production SaaS platform. Local success is not sufficient when production integration is required.

## 12. Agent Independence
Claude and ChatGPT are peer implementation agents. Neither should assume the other is correct. Verify repository state and test results independently before continuing.
