# Trail — PMCRO Colony (self-contained Cline instance)

The sealed trail is the only source of truth for this instance (Core
Mechanic 2 in the base `SKILL.md`). A phase is not complete until its
frame is written here — **log-before-act**: write the frame *before*
moving to the next phase, so a crashed cycle still leaves a diagnostic
record of what was attempted.

## Layout — one directory per trailId, one file per phase-per-cycle

This matches the proven layout already running in the real Colony at
`S:\.pmcro\trails\<subject-agent>\<trailId>\` — adopted here specifically
because it's immune to two real failure modes already hit in this
project: the flat-file overwrite that lost 7 cycles in this same
workspace's sandbox era, and the git-merge collision risk of two people
appending to one growing file.

```
B:\pmcro-cline\.pmcro\trails\<trailId>\
    00-frame.json     — {"trail_id", "seed_intent", "started_utc"}
    01-plan.jsonl      — cycle 1 Planner frame
    01-make.jsonl      — cycle 1 Maker frame
    01-check.jsonl      — cycle 1 Checker frame
    01-reflect.jsonl     — cycle 1 Reflector frame
    02-plan.jsonl  ...    — cycle 2+ only if Reflector said Retry
    disposition.json      — final sealed verdict, written once, last
```

`trailId` is a fresh GUID (or any collision-proof unique string) minted
by Planner at the start of a cycle — **never reused, never guessed.**
This instance does not nest under a subject-agent folder like the
production Colony does (that split exists there because each subject
agent runs its own independent loop; here Cline runs one loop per
cycle), so the layout is simply `trails/<trailId>/...` directly.

## Field shape reality check (2026-07-10 audit finding)

`A:\source\.agents\skills\pmcro-base\references\frame-schemas.md`
describes a flat, camelCase field shape (`stepId`, `subjectAgent`,
`allStepsOk`, etc.) and earlier versions of this README claimed that
shape "matches real sealed trails at `S:\.pmcro\trails\`." **That claim
was checked against the actual files and is false.** The real sealed
trails at `S:\.pmcro\trails\playwright-agent\<trailId>\` are:

- **PascalCase throughout** — `TrailId`, `SeedIntent`, `AllStepsOk`,
  `StepIndex`, `Passed`, `CycleNumber` — not camelCase anywhere, in any
  of the four phase files.
- **Nested, not flat** — each later phase file fully re-embeds the prior
  phase's frame (`01-check.jsonl` contains a nested `MakerOutput`, which
  itself nests `Plan`). This is plain .NET `System.Text.Json` default
  serialization, not a hand-authored camelCase contract.

Until `frame-schemas.md` is corrected or a deliberate decision is made to
diverge from the production Colony's real shape, **this instance follows
the real `S:\` precedent** (PascalCase, nested-per-phase) for
`NN-plan.jsonl` / `NN-make.jsonl` / `NN-check.jsonl` / `NN-reflect.jsonl`,
not the camelCase names in `frame-schemas.md`. Don't "fix" a frame file
to match `frame-schemas.md` without checking a real `S:\` trail first —
the doc, not the running system, was the thing that was wrong.

## Envelope files — `00-frame.json` and `disposition.json`

These two are **not** covered by `frame-schemas.md` — it explicitly
leaves physical trail-envelope format open. For these two, follow the
precedent already sealed in the real Colony trails at
`S:\.pmcro\trails\<subject-agent>\<trailId>\` (confirmed correct against
real files):

```json
// 00-frame.json — snake_case
{"trail_id": "...", "seed_intent": "...", "started_utc": "..."}
```

```json
// disposition.json — PascalCase (matches the .NET Orchestrator's own
// serialized shape in the real Colony — do not camelCase these)
{
  "TrailId": "...", "SeedIntent": "...", "Disposition": "Accept|Retry|Halt",
  "FinalOutput": "...", "RetryContext": null, "HaltReason": null,
  "EarnedConstraints": [], "CycleNumber": 1
}
```

Note that the phase-frame files above (`NN-plan.jsonl` etc.) also turn
out to be PascalCase per the reality check — so in practice this
instance's whole trail directory is PascalCase end-to-end, with only
`00-frame.json` breaking that pattern with snake_case. That's the real,
already-running precedent, not an inconsistency introduced here — don't
normalize it away.

## Why this replaces the old flat-file format

The original design here (`_deprecated-flat-format.pmcro-colony.jsonl`,
kept for the record, not read by anything) appended every phase of every
cycle as one line each to a single growing file. Two real problems came
from that shape, not from this template's rules:

1. **A single bad write can destroy unrelated history.** A
   `replace_in_file` call built against a stale read of the whole file
   overwrote it — 7 sealed cycles gone in one call, in this same
   workspace, before this rework.
2. **Two people writing concurrently collide by construction.** Any two
   people (or two Cline sessions) appending to the same file's end at
   the same time produce a git merge conflict, or worse, a race outside
   git entirely.

Because every cycle now gets its own fresh `trailId` directory, neither
failure mode is structurally possible anymore. A bad write can only ever
destroy the one small file it targeted. Two people's cycles never touch
the same path, so there is nothing to merge.

## Still write using the right tool

Even though whole-file overwrite risk is gone, the same discipline
applies to writing *any* frame file: use `write_to_file` directly, never
a shelled-out `echo`/`powershell -Command`/`python -c` one-liner. Each
`NN-phase.jsonl` file is written once and not touched again — so this is
a plain "create the file" operation per phase, not an append, which
removes the "re-read before appending" risk entirely as a side effect.

## Fail loudly, not silently

If a write to any trail file fails (disk full, permissions, path
missing), that failure must be surfaced to the human immediately — do
not swallow it and continue as if the phase completed.

## Earned Constraints log

New constraints crystallized by the Reflector (per `agents/reflector.md`)
get appended here as they're earned — this is what moves this instance
up the quality gradient from Tier 0 (see the base template's
`references/quality-gradient.md`). Don't invent a constraint that's
already listed; check here first.

*(none yet — this instance has no earned history. Don't claim any
constraint, or a "shrinking HIL surface," until a real sealed
`disposition.json` in `B:\pmcro-cline\.pmcro\trails\<trailId>\` actually
backs it up.)*
