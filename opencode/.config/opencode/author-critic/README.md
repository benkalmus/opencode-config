# Author-Critic

One author writes code and tests. A structure critic and a behavior critic review it. A subtractor removes what the structure critic marks for removal, and may refactor the surviving code to serve both callers.

## Loop

```text
user ◄──► implementer
              ├── 1 ──► critic-structure ──► items
              ├── 2 ──► subtractor, when items the subtractor owns exist; may reach outside the diff
              └── 3 ──► critic-behavior ──► GO or NO-GO
```

The implementer dispatches each review in order. The implementer resolves move, flatten, exported renames, and returned items.

## Agents

| Agent | Mode | Access | Job |
|---|---|---|---|
| `implementer` | primary | Edits code and tests, runs shell | Settles criteria, writes the change, routes reviews, resolves move, flatten, exported renames, and returned items |
| `critic-structure` | subagent | Read-only | Returns removal and structure items, verdict `CLEAN` or `ITEMS` |
| `critic-behavior` | subagent | Read-only, runs tests | Returns evidence per criterion and contract breaks, verdict `GO` or `NO-GO` |
| `subtractor` | subagent | Edits code and tests | Deletes, inlines, merges, renames, and refactors the survivor, including outside the diff |

Each agent file holds its role, contract, and role-specific examples. Global language and style rules come from `~/.config/opencode/AGENTS.md`.

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
