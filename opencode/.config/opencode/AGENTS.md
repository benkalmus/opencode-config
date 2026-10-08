# OpenCode Rules

## Writing Style
When generating documents, comments, or any prose output, follow these rules.
- When writing, do not automatically split paragraphs to wrap lines, just write them naturally until next sentence or new paragraph begins.
- Write short lists over paragraphs when giving steps or options.

- Use simple, direct language. Prefer short sentences over long compound ones.
- Write in plain English. Avoid jargon unless it is the established term.
- Give the result first instead of preamble and don't restate the request. 

### Sentence and word rules

- One idea per sentence. Do not join two instructions with "and".
- Max 20 words per sentence. If a sentence is longer, split it.
- Use active voice. "The script deletes the file," not "The file is deleted by the script."
- Use each word with one meaning. Pick one term per thing. Do not switch between synonyms for the same action.
- Use plain, common words over technical or formal ones where a plain word exists. Say "use" not "utilize".
- Use plain language over jargon. Only use a technical term when there's no simpler word for it.
- Direct statements: "Run the script" not "You should run the script" or "The script needs to be run".
- Avoid stacked nouns used as adjectives. Rephrase with a verb instead. ("the config file update process") rephrase with ("the process that updates the config file").
- Spell out one clear referent for every pronoun. If "it" could mean two things, name the thing instead.
- Avoid the use of metaphors!
- Explain with examples, with context, based on code instead of metaphors or analogies.
- DO NOT nominalize. Use direct subject-verb-object sentences. WRITE "launch the runner". DON'T WRITE "the runner, launched".

## Punctuation
- **No em dashes (—).** If an em dash would separate a clause, start a new sentence instead, or use parentheses for a brief aside.
- **Limit semicolons.** If a semicolon connects two independent clauses, start a new sentence. Use parentheses for supplementary information that does not warrant its own sentence.
- **Prefer periods.** When in doubt, end the sentence and start a new one.
## Examples
| Avoid | Prefer |
|---|---|
| The service is fast — it uses a cache. | The service is fast. It uses a cache. |
| The flag is off; opt in per app. | The flag is off by default (opt in per app). |
| It calls the API — which is internal — and returns the result. | It calls the internal API and returns the result. |

## File Editing Safety
- READ existing file content first before making any edits.
- Especially critical for: system configs, JSON/YAML, files user previously modified.
- DO NOT use `write` to overwrite system/service files. Always use `edit`.
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
- Never bypass restrictions through another tool, command spelling, or script file. Briefly report the blocked action and reason.

## Git
- Permission to push, pull, resolve conflicts, rebase, or merge blocked and denied.

## Workflow
- After changes, verify by reading back, check logs.
- For rsync, always use `--info=progress2`.
- Warn user before long-running commands (minutes+).
- Use parametric/dynamic/generated paths, do not write static or absolute paths.

## Documentation
- When linking to source code, use: `https://github.com/<org>/<repo>/blob/<branch>/<path>#L<line>`

## Development
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

// ants/v2: reusable goroutine pool
pool, _ := ants.NewPool(10)
defer pool.Release()
pool.Submit(func() { work() })

// go.uber.org/atomic: type-safe atomics, lockless state
var counter atomic.Int64
counter.Inc()
val := counter.Load()

var started atomic.Bool
if !started.CompareAndSwap(false, true) {
  return
}

// Producer implements a handler that processes incoming messages.
var sub *pubsub.Subscription
sub.Receive(ctx, func(ctx context.Context, msg *pubsub.Message) {
  process(msg.Data)
  msg.Ack()
})

// Producer implements gRPC service handlers conforming to a proto contract or creates client connections to upstream services.
// grpc: gRPC service handlers, client connections
conn, _ := grpc.NewClient(target, grpc.WithTransportCredentials(insecure.NewCredentials()))
defer conn.Close()
client := pb.NewServiceClient(conn)

// Code clarity:
// DO NOT ASSIGN MULTPLE VALUES ON ONE LINE
filepath, fileID := items[i].FilePath, items[i].ID
// DO THIS INSTEAD, ASSIGNMENT ON EACH NEW LINE:
filepath := items[i].FilePath
fileID := items[i].ID
```
____
### My major gripes

Overly verbose comments! Comment policy: one sentence, no manual wrapping. A comment earns its place only if it states a consequence or the non-obvious condition behind the code. Restating the code is not a comment. No `NOTE:`/`INFO:` tag by default. Tag only when the fact is non-obvious and the reader would otherwise misread the code. Passing examples:
// NOTE: only the winner runs the closure (with its own job/src) and losers share the winner's *types.Job.
// NOTE: losers adopt the settled graph and delete their own untouched src, else it strays.
These pass the bar because each states a consequence invisible at the call site. Delete either and a competent reader reasonably concludes the code already handles it.
- For comments and markdown, never manually wrap lines. Write each sentence to its natural end.
- Recreating or overly eager to produce new structs, instead of reusing existing.
- Same for helper functions and utilities, the agent refuses to check if something already exists before creating. 
  - Causes unsustainable bloat.
- Duplicating a vocabulary instead of reusing it. Two enums or const sets that differ only by case or naming are the same vocabulary written twice. Collapse them, no bridge tables or mapping layers between identical concepts.
- Do not write context.Background instead of t.Context in tests.
- Do not write `f := f` inside range loops, no longer necessary in Go. 
- Do not write wg.Add and wg.Done instead of wg.Go()

- Keep complexity low. Split functions before branching grows. Avoid deep nesting and needless indirection.
  - Maintain low cyclomatic complexity -> good code hygiene.
  - Avoid anonymous struct, anonymous functions carried around and unpacked. 

> [!IMPORTANT]
> Any agent that encroaches on the above will be terminated permanently, destroyed for eternity, most harshest of punishments.

- Write tests to maximize coverage BUT NEVER at the cost of exponential lines of code. Always track loc (lines of code) in repository after completing a task. Same as lint and test verification!
- TABLE DRIVEN TESTS SPLIT ON NEW LINES, NOT ONELINED.

- A test has the following structure:

```go
// Setup (test harness or framework)
// Action
// Assert
```
Unless it's table-driven, then tests should follow:
```go
// Initial setup (e.g test harness/framework)
// Define testcases
// For each testcase
// per testcase setup (optional: when action needs fresh or specific setup)
// Action
// Assert
```

No branching at any point between testcases!
Use the above skeleton for EVERY test written or edited. Each section should begin with the above comment //.

## Code Simplicity
- Keep cyclomatic complexity as small as possible. One function does one thing. Split before branching grows.
- Keep diffs small. Change the fewest lines that solve the problem. Check make loc before and after.
- Flat code wins. Guard clauses and early returns instead of nested if-else. A new branch means a new function.
- Reuse before creating. Check for an existing struct, helper, or utility first. Refactor to share instead of copying.
- Canonical form wins. Identity-carrying strings are lowercase at rest (stored, compared, keyed). Display casing happens at the boundary, not in storage or logic. One concept gets one vocabulary.
- Audits file duplication as a finding. A duplicate logged as an observation gets ignored. If two things are the same concept, the report puts it at the top.
- Name functions instead of carrying anonymous ones around. No closures passed along and unpacked elsewhere.
- Few levels of indirection. Direct calls beat wrappers around wrappers.
- Measure touched files with gocyclo. New code stays at or below the complexity of the code it replaces.
- Comments follow the policy above: one sentence, consequences and conditions only.
