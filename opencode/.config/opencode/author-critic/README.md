# Author-Critic

One author writes code and tests. A structure critic and a behavior critic review it. A subtractor removes what the structure critic marks for removal, and may refactor the surviving code to serve both callers.

## Loop

```text
user ◄──► implementer          phase 0: design partnership, blockers, questions
              ├── 1 ──► criteria
              ├── 2 ──► reuse report
              ├── 3 ──► implementation
              ├── 4 ──► critic-structure ──► items
              ├── 5 ──► subtractor, when items the subtractor owns exist; may reach outside the diff
              ├── 6 ──► critic-structure on the subtractor diff only
              └── 7 ──► critic-behavior ──► GO or NO-GO; 8 re-check on NO-GO; 9 report
```

The implementer dispatches each review in order.

Phase 6 exists because the subtractor edits files the phase 4 diff never contained. The implementer resolves those items itself and does not dispatch the subtractor twice.

## Agents

| Agent | Mode | Access | Job |
|---|---|---|---|
| `implementer` | primary | Edits code and tests, runs shell | Questions the request, settles criteria, writes the change, routes reviews |
| `critic-structure` | subagent | Read-only | Verifies reuse claims, returns removal and structure items, verdict `CLEAN` or `ITEMS` |
| `critic-behavior` | subagent | Read-only, runs tests | Re-derives the criteria, reproduces every evidence row, returns breaks, verdict `GO` or `NO-GO` |
| `subtractor` | subagent | Edits code and tests | Deletes, inlines, merges, renames, and refactors the survivor, including outside the diff |

## Review posture

Both critics treat the handoff as a claim.

- `critic-structure` re-runs the reuse search itself. The implementer's report is the claim under test.
- `critic-behavior` re-derives the criteria from the user's request before reading the handed list. It opens each cited line and runs each cited test by name.

Silence costs the same as speech. A verdict for and a verdict against carry the same artifact.

| Verdict | Artifact |
|---|---|
| `CLEAN` | Check log with one row per priority: the check run and its result. |
| `ITEMS` | One row per item: class, action, location, proof fragment. |
| `GO` | Evidence table with every row reproduced and a falsifier per row. |
| `NO-GO` | One row per break: class, location, reproduction. |

A rejection of a finding needs a refutation of the same kind as the finding. A one-line dismissal is overruled and the item stands. An unfinished review is dispatched again. It is not a pass.

The implementer is a design partner, not a request executor. It restates the request, names the assumptions that would cost most to get wrong, lists blockers with file and line, names the smallest viable change and one rejected alternative, and asks every question that would change the design. Its reuse report records the search command for every new name. A claim with no command is not a reuse claim.

## Inputs

Each critic receives the original request, the criteria, and the change set. The implementer's reasoning and report are excluded, so a weak claim cannot carry a review.

## Wiring

`agents/` holds one symlink per agent.

From `opencode/.config/opencode`, with `agents/` present:

```sh
ln -sf ../author-critic/agents/implementer.md agents/implementer.md
ln -sf ../author-critic/agents/critic-structure.md agents/critic-structure.md
ln -sf ../author-critic/agents/critic-behavior.md agents/critic-behavior.md
ln -sf ../author-critic/agents/subtractor.md agents/subtractor.md
```

Add one agent with the same pattern:

```sh
ln -sf ../author-critic/agents/<agent>.md agents/<agent>.md
```

## Shared rules

Language, naming, comment, test, and code rules live in `~/.config/opencode/AGENTS.md`. Each agent cites the section name. No agent restates a global rule.
