# PMCR-O Loop — Custom Instructions for Cline (PMCRO Colony, self-referential)

**Workspace root: `B:\pmcro-cline`.** As of 2026-07-10 this is a
**self-contained instance** — both Cline's workspace root and this
instance's own data (`agents/`, `trails/`, `hil/`, `CYCLE-LOG.md`, the
instance yaml) live at `B:\pmcro-cline\.pmcro\`. The **domain** this loop
governs — the actual engineering work being planned/made/checked/
reflected on — is still the real Colony project at `A:\`. Every
`cline-fs-agent`/`cline-terminal-agent` action that touches Colony source
must use an **explicit absolute `A:\...` path**; never assume `B:\
pmcro-cline` as an implicit relative root for Colony work. Instance data
(this loop's own agents/trails/hil/config) uses explicit
`B:\pmcro-cline\.pmcro\...` paths instead. Don't resolve either kind of
path relative to the current working directory.

Read `B:\pmcro-cline\.pmcro\agents\orchestrator.md` first, then the phase
file that matches whatever step you're on.

## How this maps onto a single Cline conversation

Cline is one continuous agent/tool-loop, not five separate processes, so
the five phases run **sequentially inside the same conversation** rather
than as separate actors. Treat each phase as a distinct, labeled step —
don't blur them together into one uncontrolled pass.

For any non-trivial task (skip this for single-fact lookups or one-line
edits):

1. **Plan** — Before touching any tool, write a short numbered step
   sequence. Tag each step with a subject-agent name from
   `B:\pmcro-cline\.pmcro\agents\registry.md` and a TYPE1 (mutating) /
   TYPE2 (read-only) label. Do not execute yet.
2. **Make** — Execute steps in order using real Cline tools, targeting
   `A:\` paths explicitly (e.g. `A:\source\...`, or `cd A:\source; dotnet
   build` for terminal steps — never assume `B:\pmcro-cline` as an
   implicit relative root for Colony work). Never say "this should
   work" — capture the actual tool result (diff, stdout, exit code,
   file content) as ground truth.
3. **HIL gate on TYPE1** — Before any TYPE1 action executes, it must go
   through Cline's own approval UI (see
   `B:\pmcro-cline\.pmcro\hil\README.md`). Do not enable auto-approve for
   TYPE1 tool categories in this workspace.
4. **Check** — After Make, re-derive pass/fail yourself from the raw
   tool output. Re-read the file, re-run the check, or re-list the
   directory to confirm — never trust a self-reported "success."
5. **Reflect** — State a verdict: Accept / Retry / Halt. If something
   failed in a new way, write one sentence describing the constraint and
   append it under Earned Constraints in
   `B:\pmcro-cline\.pmcro\trails\README.md`.
6. **Seal the trail** — Write each phase's frame to its own file under
   `B:\pmcro-cline\.pmcro\trails\<trailId>\` (`00-frame.json` once at
   cycle start, then `NN-plan.jsonl` / `NN-make.jsonl` / `NN-check.jsonl` /
   `NN-reflect.jsonl` per cycle number, and `disposition.json` once at
   seal) *before* moving to the next phase (log-before-act). **Always
   write frame files using your own `write_to_file` tool, never a
   shelled-out `echo`/`powershell -Command`/`python -c` one-liner** —
   nested-JSON quoting through a shelled string is unreliable and has
   caused real data loss in earlier iterations of this loop; see the
   Earned Constraints log in `B:\pmcro-cline\.pmcro\trails\README.md`.
   Each phase file is written once and never appended to or edited
   afterward, so there is no "re-read the tail before writing" step
   under this layout — a bad write can only ever destroy the one small
   file it targeted, never another cycle's history. **Field names inside
   `NN-plan.jsonl` / `NN-make.jsonl` / `NN-check.jsonl` /
   `NN-reflect.jsonl` are nominally described by
   `A:\source\.agents\skills\pmcro-base\references\frame-schemas.md`
   (camelCase), but a 2026-07-10 audit found the real sealed trails at
   `S:\.pmcro\trails\` are actually PascalCase and nested per phase —
   follow the real `S:\` precedent, not the doc, until that's
   reconciled; see `B:\pmcro-cline\.pmcro\trails\README.md`'s "Field
   shape reality check."** `00-frame.json` and `disposition.json` aren't
   covered by that schema either way; follow the exact shape already
   documented in `B:\pmcro-cline\.pmcro\trails\README.md` (snake_case
   envelope, PascalCase disposition — matching real sealed trails at
   `S:\.pmcro\trails\`).

## Naming discipline

Before inventing a new named subject-agent, check
`B:\pmcro-cline\.pmcro\agents\registry.md`. Cline's existing tool groups
almost always already cover it.

## Anti-patterns (do not do these)

- Reporting a write/command succeeded without a real read-back or output
  capture.
- Auto-approving a TYPE1 action to save time.
- Skipping the trail write because the step seemed trivial.
- Re-adjudicating your own Reflector verdict at the Orchestrate step.
- Writing "no new constraints earned" reflexively after a cycle that
  visibly hit real friction — see the honesty note in
  `B:\pmcro-cline\.pmcro\agents\reflector.md`.
- Assuming any Colony **domain** path under `A:\` (other than
  `A:\source\.agents\skills\pmcro-base\` reference docs) holds this
  instance's own trail or agent data. It doesn't — this instance's data
  lives entirely at `B:\pmcro-cline\.pmcro\`, one fresh trail directory
  per trail, starting at cycle 1. (`A:\.pmcro\` is a separate, older,
  never-sealed instance left in place untouched — don't read or write it
  for this instance's own loop state.)

## Shell note

This workspace runs on Windows PowerShell. Use `;` to chain commands,
never `&&`.

## After each sealed cycle

Append a row to `B:\pmcro-cline\.pmcro\CYCLE-LOG.md` — date, cycle ID,
seed intent, disposition, one-line note. This is separate from the trail
file; it's the human-readable record of the 30-day commitment.
