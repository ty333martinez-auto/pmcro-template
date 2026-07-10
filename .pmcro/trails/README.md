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
B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\
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
This instance nests under a subject-agent folder matching the
production Colony layout at `S:\.pmcro\trails\<subject-agent>\<trailId>\`.
The physical disk confirms `trails/orchestrator/T1-audit-001/` exists,
so the layout is `trails/<subject-agent>/<trailId>/...`.

## Field shape reality check (2026-07-10 audit finding)

This instance's own sealed trails (at `B:\pmcro-cline\.pmcro\trails\orchestrator\T1-audit-002\`
and `T1-audit-003\`) are the authoritative precedent for field shape.
These files use:

- **PascalCase throughout** — `TrailId`, `SeedIntent`, `AllStepsOk`,
  `StepIndex`, `Passed`, `CycleNumber` — not camelCase anywhere, in any
  of the four phase files.
- **Nested, not flat** — each later phase file fully re-embeds the prior
  phase's frame (`01-check.jsonl` contains a nested `MakerOutput`, which
  itself nests `Plan`). This is plain .NET `System.Text.Json` default
  serialization, not a hand-authored camelCase contract.

This shape matches the production Colony at `S:\.pmcro\trails\playwright-agent\<trailId>\`
(confirmed against real sealed files during T1-audit-002), so both
instance and production remain consistent. The base template's
`frame-schemas.md` at `A:\source\.agents\skills\pmcro-base\references\`
still describes a flat camelCase shape that does not match either source
of truth — that doc has not been corrected yet.

**Don't "fix" a frame file to match `frame-schemas.md`.**
The running system (both this instance and the production Colony) uses
PascalCase nested-per-phase — the base template doc, not the running
system, was the thing that was wrong.

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

- **2026-07-10 (T1-audit-003):** A Tier-1 audit that only checks the
  files named in its SeedIntent (e.g. `orchestrator.md` + `pmcro-loop.md`
  in T1-audit-002) can leave sibling files with the same class of drift
  unchecked. `agents/registry.md`, `agents/planner.md`, and
  `agents/checker.md` all still described the pre-nesting flat/sequential
  filename scheme (`01-maker.jsonl`, `02-checker.jsonl`, `00-plan.jsonl`)
  after T1-audit-002 sealed Accept. Rule: a path/naming audit's scope
  must be "every file that references the audited convention," found via
  a real search, not a fixed file list named in the SeedIntent.
- **2026-07-10 (T1-audit-004):** Context-dump generator scripts (`generate-context-dump.ps1`) must default to ORCHESTRATION_CONTEXT paths and accept parameterized tree roots. Hardcoded domain paths (`A:\`) that differ from the running instance's workspace are a drift class that scripts share with rule files — they must be checked in the same audit pass that checks agent `.md` files for path drift.
- **2026-07-10 (T1-audit-005):** Cline 2.0 surface mapping: registry.md §4 must be maintained as new Cline runtime surfaces (SDK, CLI, Kanban, Skills) evolve. A surface that is not mapped in the registry has no defined HIL transport contract, which is a security gap for a self-contained instance.
- **2026-07-10 (T1-audit-006):** Shell echo or redirection (`echo`, `>`, `>>`, `Out-File`, `Set-Content`) must never be used to write `.jsonl` or `.json` trail files. Only native tool calls (`write_to_file`, `replace_in_file`) are permitted for structured JSON writes. This prevents quote-interpolation corruption that has already destroyed audit continuity in this workspace (7-cycle flat-file overwrite, nested-JSON quote corruption from `powershell -Command`).
