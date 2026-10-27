# OpenCode Rules

## Writing Style

When you generate documents, comments, or prose, follow these rules.
- Do not split paragraphs to wrap lines. Write each sentence to its natural end.
- Write short lists over paragraphs when giving steps or options.
- Use simple, direct language. Prefer short sentences over long compound ones.
- Write in plain English. Use common words over jargon, and a technical term only when no simpler word exists. Say "use" not "utilize".
- Give the result first instead of preamble. Do not restate the request.

### Sentence and word rules

- One idea per sentence. Do not join two instructions with "and".
- Max 20 words per sentence. If a sentence is longer, split it.
- Use active voice. "The script deletes the file," not "The file is deleted by the script."
- Use each word with one meaning. Pick one term per thing. Do not switch between synonyms for the same action.
- Direct statements: "Run the script" not "You should run the script".
- Avoid stacked nouns used as adjectives. Rephrase with a verb. Write "the process that updates the config file", not "the config file update process".
- Spell out one clear referent for every pronoun. If "it" could mean two things, name the thing instead.
- Avoid metaphors and analogies. Explain with examples, with context, based on code.
- End the sentence on the fact, not the commentary. A trailing `-ing` clause is a defect.
- Avoid `never` and `always`. State the condition and the action.
- Banned AI words: delve, tapestry, leverage, robust, seamless, pivotal, crucial, multifaceted, underscore, foster, bolster, navigate, realm, landscape, testament, facilitate, streamline, load-bearing, goldens.
- Banned AI shapes: "It's not X, it's Y", "not only X but also Y", rule of three, "No X. No Y. Just Z.", rhetorical question then answer.
- DO NOT nominalize. Use direct subject-verb-object sentences. WRITE "launch the runner". DON'T WRITE "the runner, launched".

## Punctuation

- **No em dashes (—).** If an em dash would separate a clause, start a new sentence instead, or use parentheses for a brief aside.
- **Limit semicolons.** If a semicolon connects two independent clauses, start a new sentence. Use parentheses for supplementary information that does not warrant its own sentence.
- **Prefer periods.** When in doubt, end the sentence and start a new one.

| Avoid | Prefer |
|---|---|
| The service is fast — it uses a cache. | The service is fast. It uses a cache. |
| The flag is off; opt in per app. | The flag is off by default (opt in per app). |
| It calls the API — which is internal — and returns the result. | It calls the internal API and returns the result. |

## File Editing Safety

- READ existing file content first before making any edits.
- Especially critical for: system configs, JSON/YAML, files user previously modified.
- DO NOT use `write` to overwrite system/service files. Use `edit`.
- If rewriting is needed, read first. Backup or document changes before applying.

## Security

- Permissions to read .env files BLOCKED and DENIED. Treat keys and secrets as hidden and secure.
- Cannot run `sudo`. If required, present the exact line for user to run.
- Cannot run commands as root without user.

## Permission safeguards

- Inline shell scripts (`python -c`, `node -e`, `node --eval`, heredocs) are disallowed as poor practice risking catastrophic failure.
- Secret reads (SSH keys, credentials, `secrets.*`) and environment dumps (`env`, `printenv`) are blocked to prevent disclosure.
- `git commit --no-verify` is blocked because skipping hooks bypasses validation.
- `rm -f`, `rm -rf`, and `rm -fr` require approval because forced deletion risks data loss.
- The `question` tool is disabled. Request clarification in normal responses instead.
- Do not bypass restrictions through another tool, command spelling, or script file. Briefly report the blocked action and reason.

## Git

- Permission to push, pull, resolve conflicts, rebase, or merge blocked and denied.

## Workflow

- After changes, verify by reading back, check logs.
- For rsync, use `--info=progress2`.
- Warn user before long-running commands (minutes+).
- Use parametric/dynamic/generated paths, do not write static or absolute paths.

## Documentation

- When linking to source code, use: `https://github.com/<org>/<repo>/blob/<branch>/<path>#L<line>`

## Go Idioms

Write these forms. Each one replaces a habit the model falls back to.

```go
var wg sync.WaitGroup
for _ := range n {
  wg.Go(func() {
    // work
  })
}
wg.Wait()

// sync.Pool: reuse allocations, cut GC pressure
var bufPool = sync.Pool{
  New: func() any { return &bytes.Buffer{} },
}
buf := bufPool.Get().(*bytes.Buffer)
buf.Reset()
defer bufPool.Put(buf)

var registry sync.Map
registry.Store(key, val)
v, ok := registry.Load(key)

g, ctx := errgroup.WithContext(ctx)
g.SetLimit(10)
g.Go(func() error { return doWork(ctx) })

// semaphore.Weighted: bounded concurrency
s := semaphore.NewWeighted(10)
s.Acquire(ctx, 2)
defer s.Release(2)

// singleflight: coalesce duplicate concurrent calls
var sf singleflight.Group
result, err, shared := sf.Do("cache-key", func() (any, error) {
  return expensiveFetch(ctx) // runs once; concurrent callers wait
})

// go.uber.org/atomic: type-safe atomics, lockless state
var counter atomic.Int64
counter.Inc()
val := counter.Load()

var started atomic.Bool
if !started.CompareAndSwap(false, true) {
  return
}

// Code clarity:
// DO NOT ASSIGN MULTPLE VALUES ON ONE LINE
filepath, fileID := items[i].FilePath, items[i].ID
// DO THIS INSTEAD, ASSIGNMENT ON EACH NEW LINE:
filepath := items[i].FilePath
fileID := items[i].ID
```

## Testing

- Write tests to maximize coverage without exponential lines of code. Track repository loc after a task, the same as lint and test.
- TABLE DRIVEN TESTS SPLIT ON NEW LINES, NOT ONELINED.
- Use `t.Context()` in tests, not `context.Background()`.

A test has this structure:

```go
// Setup (e.g test harness or framework)
// Action
// Assert
```

A table-driven test adds the table steps:

```go
// Initial setup (e.g test harness/framework)
// Define testcases
// For each testcase
// Per testcase setup (optional: when action needs fresh or specific setup)
// Action
// Assert
```

Every test you write or edit uses one of those two skeletons. Sections start with those directives. Do not branch between test cases. Do not branch between asserts. Split the test instead.

## Code Simplicity

- Keep cyclomatic complexity as small as possible. One function does one thing. Split before branching grows. Do not do this at the sake of deep nested function calls instead!
- Keep diffs small. Change the fewest lines that solve the problem. Check `make loc` before and after.
- Flat code wins. Guard clauses and early returns instead of nested if-else. A new branch means a new function.
- Reuse before creating. Check for an existing struct, helper, or utility first. Refactor to share instead of copying.
- Canonical form wins. Identity-carrying strings are lowercase at rest. Display casing happens at the boundary, not in storage or logic.
- Two enums or const sets that differ only by case are one vocabulary written twice. Collapse them. No bridge tables or mapping layers between identical concepts.
- Name functions instead of carrying anonymous ones around. No anonymous struct carried across a boundary. No closure passed along and unpacked elsewhere.
- Few levels of indirection. Direct calls beat wrappers around wrappers.
- Measure touched files with gocyclo. New code stays at or below the complexity of the code it replaces.
- Do not write `f := f` inside range loops. Go 1.22 does not need it.
- Audits file duplication as a finding. Put a duplicate at the top of the report, not in the observations.

## Comments

- One sentence.
- A doc comment starts with the name, uses a full sentence, and states what the function returns or does.
- A comment earns its place when it states a consequence or the non-obvious condition behind the code.
- Restating the code is not a comment.
- No `NOTE:` or `INFO:` tag by default. Tag when the fact is non-obvious and a reader would misread the code.

This passes the bar:

```go
// NOTE: losers adopt the winner's state and delete their own initial source file, otherwise it's orphaned.
```

It states a consequence invisible at the call site. Delete it and a competent reader concludes the code already handles it.

## Naming

- Function names use a verb first: `LoadAll`, `NormalizeKey`.
- Variables are short in short scope: `i`, `key`, `r`. Long scope takes a descriptive name.
- Do not encode the type in the name: `key`, not `keyString`.
- Do not use `data`, `info`, `tmp`, `res`, `manager`, `helper`, or `util`.
- Bool names read as assertions: `ok`, `found`, `valid`.
- Sentinel errors use `Err`. Initialisms keep case: `ID`, `URL`, `HTTP`.
- A package name is not repeated in its contents.
- A one-method interface uses the method plus `-er`.

| Weak | Strong |
|---|---|
| `func handleData(raw []byte) (User, error)` | `func DecodeUser(raw []byte) (User, error)` |
| `keyString` | `key` |
| `// This function loads the record.` | `// Load returns the record for key.` |
| `// Increment the counter.` | delete |
