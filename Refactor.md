New Startup, Resume, and Flow Semantics
This is the shortest mental model for the fresh-slate runtime.
What changed
The timeline remains the central ordered event log, but projections and per-flow route streams no longer drive resume.
```text
Old
timeline -> projections -> resume/route streams -> one subscription per flow

New
timeline -> dispatcher -> sparse registry + cursor
         -> one shared subscription -> bounded per-flow lanes
                              |
                              +-> per-flow committed checkpoints
```
Startup
```text
acquire fenced ownership
        |
        v
load outstanding registry entries + pending schedules
        |
        v
load checkpoints for active flows
        |
        v
start one timeline subscription at:
min(dispatcher cursor + 1, each active flow checkpoint + 1/start position)
        |
        v
discover routes, durably advance cursor, then fan out
```
Startup cost is intended to follow current outstanding work, not total timeline history.
Dispatcher versus flow progress
These are independent:
```text
dispatcher cursor = routes/RouteFirst decisions are durable through position P
flow checkpoint   = this flow's state is committed through position Q
```
The cursor advances before lane delivery. If the host dies after discovery but before handling, the older flow checkpoint causes safe redelivery.
Routing
Route metadata	Existing active key	Absent key	Completed key
`Route`	deliver	ignore	ignore
`RouteFirst`	deliver	register once, then deliver	ignore forever
`Route`/`RouteFirst` is stored in append-time metadata. It is never re-derived from a newer application build.
Each `FlowKey` has one lifetime. Completion is permanent; keys are never rebuilt or reused.
Flow lifecycle
```text
                 handler failure
Active --------------------------------> Stopped
  |                                         |
  | completion                              | Retry or authorized Skip
  v                                         v
Completed (terminal)                    Recovering
                                            |
                                            | atomic checkpoint +
                                            | FlowRecovered/FlowSkipped
                                            v
                                          Active
```
A failure never checkpoints the mutated instance. `FlowStopped` records the failure separately while the last committed state remains unchanged.
Retry reloads the last committed state and includes the failed point.
Skip requires `[AllowSkip]` on every applicable `Given`/`When`; it preserves state and advances only `ProcessedThrough`.
Commit rule
For a successful flow step, the checkpoint and all effects belong to one conditional commit:
```text
checkpoint + topic outputs + schedule requests + lifecycle transition
```
Commits are protected by expected revisions, deterministic IDs, `FailureId`/recovery IDs, and the current ownership fencing token. Duplicate delivery is acceptable; missing delivery is not.
Scheduling and isolation
Pending schedules live in a durable ledger and do not require timeline replay.
Per-flow lanes are bounded.
A stopped or slow flow leaves shared delivery and catches up independently.
That is the new model: one ordered feed, durable discovery, sparse lifecycle state, per-flow committed state, and explicit recovery.