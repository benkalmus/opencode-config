# OpenCode Rules

## Writing Style
When generating documents, comments, or any prose output, follow these rules.
When writing markdown, do not automatically split paragraphs to wrap lines, just write them naturally until next sentence or new paragraph begins.
## Language
- Use simple, direct language. Prefer short sentences over long compound ones.
- Write in plain English. Avoid jargon unless it is the established term.
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
- Never use `write` to overwrite system/service files. Always use `edit`.
- If rewriting is needed, read first. Backup or document changes before applying.

## Security
- NEVER read .env files. Treat keys and secrets as hidden and secure.
- Never run `sudo`. If required, present the exact line for user to run.
- Never run commands as root without delegation.

## Git
- Never push, pull, resolve conflicts, rebase, or merge unless asked.

## Workflow
- After changes, verify by reading back, check logs.
- For rsync, always use `--info=progress2`.
- Warn user before long-running commands (minutes+).
- Use dynamic/generated paths, never static or absolute.

## Documentation
- When linking to source code, use: `https://github.com/<org>/<repo>/blob/<branch>/<path>#L<line>`

## Development
```go
var wg sync.WaitGroup
for i := 0; i < n; i++ {
	wg.Go(func() {
		defer wg.Done()
		work()
	})
}
wg.Wait()

var once sync.Once
once.Do(func() { lazyInit() })

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
if err := g.Wait(); err != nil {
	return err
}

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

ch := make(chan Event, 100)
close(ch)
var dead chan Event
select {
case <-dead:
case <-ch:
}

// rate.Limiter: per-handler, per-client rate limiting
limiter := rate.NewLimiter(rate.Every(time.Second), 10)
if err := limiter.Wait(ctx); err != nil {
	return err
}

// Producer implements a handler that processes incoming messages.
var sub *pubsub.Subscription
sub.Receive(ctx, func(ctx context.Context, msg *pubsub.Message) {
	process(msg.Data)
	msg.Ack()
})

// grpc: gRPC service handlers, client connections
// Producer implements gRPC service handlers conforming to a proto contract or creates client connections to upstream services.
conn, _ := grpc.NewClient(target, grpc.WithTransportCredentials(insecure.NewCredentials()))
defer conn.Close()
client := pb.NewServiceClient(conn)
```
____
### My major gripes

Overly verbose comments! Comments should be one liners.
For comments and markdown, the agent is constantly manually word wrapping. Why? There's no good reason to wrap a line, It usually does this around 70-80 chars, and I hate it.
Recreating or overly eager to produce new structs, instead of reusing existing.
Same for helper functions and utilities, the agent refuses to check if something already exists before creating. 
    Causes unsustainable bloat.
Always spawning a tester, who is forced to write pointless tests, adding lines of code to the codebase that don't cover beyond trivial. Sometimes, a change just needs a producer, thats it.
Still writes context.Background instead t.Context in tests.
Still uses for f:= range{  f := f}, no longer necessary in Go. 
Still writes wg.Add and wg.Done instead of wg.Go()
