# /pmcro-cycle.md — Run one full PMCR-O cycle (PMCRO Colony, self-contained on B:\pmcro-cline)

Invoke with `/pmcro-cycle.md` followed by the task description, e.g.:
`/pmcro-cycle.md <real Colony task>`

**Workspace root: `B:\pmcro-cline`.** As of the 2026-07-10 self-contained
migration, this instance's own data (`agents/`, `trails/`, `hil/`,
`CYCLE-LOG.md`) lives at `B:\pmcro-cline\.pmcro\`. The **domain** this
loop governs — the actual engineering work being planned/made/checked/
reflected on — is the real Colony project at `A:\`. Use explicit
`A:\...` paths for Colony domain work and explicit
`B:\pmcro-cline\.pmcro\...` paths for this instance's own loop state.
Never resolve either kind of path relative to the current working
directory, and never assume `B:\pmcro-cline` as an implicit relative
root for Colony work.

This workflow forces the complete loop for the task that follows,
regardless of how small it looks. Do not skip any numbered step below.

## Steps

1. **Read context.** Read `B:\pmcro-cline\.pmcro\agents\orchestrator.md`,
   `B:\pmcro-cline\.pmcro\agents\registry.md`, and
   `B:\pmcro-cline\.pmcro\trails\README.md` if you haven't already this
   session.

2. **Plan.** Before touching any tool, write a numbered step sequence
   for the task. Tag each step with a subject-agent name from
   `B:\pmcro-cline\.pmcro\agents\registry.md` and TYPE1/TYPE2. Do not
   execute anything yet. Mint a fresh `trailId` (GUID) if this is cycle
   1 of a new seed intent; reuse the existing `trailId` if this is a
   Retry. Write `B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\00-frame.json`
   (cycle 1 only), then
   `B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\NN-plan.jsonl` — PascalCase,
   nested-per-phase shape, per the real sealed-trail precedent at
   `S:\.pmcro\trails\` (see "Field shape reality check" in
   `B:\pmcro-cline\.pmcro\trails\README.md`), not the aspirational
   camelCase in `A:\source\.agents\skills\pmcro-base\references\
   frame-schemas.md` — before moving on.

3. **Make.** Execute the steps in order using real Cline tools, against
   real `A:\` paths for Colony domain work. For every TYPE1 action, wait
   for Cline's own approval UI to fire and be answered — never assume
   approval. Capture the actual tool-call/tool-result — never a
   narrated "this should work." Write
   `B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\NN-make.jsonl` (one write,
   `MakerFrame` shape) before moving to Check.

4. **Check.** Independently re-derive pass/fail from raw evidence for
   each step. Write
   `B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\NN-check.jsonl` (`CheckerFrame`
   shape).

5. **Reflect.** State an explicit verdict: Accept / Retry / Halt. If
   something failed in a genuinely new way, write one sentence and
   append it under Earned Constraints in
   `B:\pmcro-cline\.pmcro\trails\README.md`. Write
   `B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\NN-reflect.jsonl`
   (`ReflectorFrame` shape).

6. **Seal.** Write `B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\disposition.json`
   with the terminal verdict (PascalCase fields — see
   `B:\pmcro-cline\.pmcro\trails\README.md` for the exact shape). This is
   the last action of the cycle. On Retry, go back to step 2 with the
   same `trailId` and `NN` incremented — do not seal until the final
   disposition is known.

7. **Log it.** Append one row to `B:\pmcro-cline\.pmcro\CYCLE-LOG.md` for
   today.

## Reminders

- Windows PowerShell — use `;` to chain shell commands, never `&&`.
- Each phase writes its own new file under
  `B:\pmcro-cline\.pmcro\trails\<subject-agent>\<trailId>\` — written once, before
  moving to the next phase. There's nothing to re-read before writing
  since these files are never appended to (unlike the old flat-file
  format).
- If this task is genuinely a single-fact lookup or one-line edit, say
  so and skip the full loop — but default to running it when in doubt.
- `A:\.pmcro\` is a separate, older, never-sealed instance left in place
  untouched — don't read or write it for this instance's own loop
  state; only use `A:\` for the actual Colony domain files being worked
  on.