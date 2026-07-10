# /pmcro-cycle.md — Run one full PMCR-O cycle

Invoke with `/pmcro-cycle.md` followed by the task description, e.g.:
`/pmcro-cycle.md Add error handling to the login form`

This workflow forces the complete loop for the task that follows,
regardless of how small it looks. Do not skip any numbered step below.

## Steps

1. **Read context.** Read `agents/orchestrator.md` and
   `agents/registry.md` if you haven't already this session.

2. **Plan.** Before touching any tool, write a numbered step sequence
   for the task. Tag each step with:
   - a subject-agent name from `agents/registry.md`
   - TYPE1 (mutating) or TYPE2 (read-only)
   Do not execute anything yet. Append this as a `planner` frame to
   `trail/pmcro-cline.jsonl` before moving on.

3. **Make.** Execute the steps in order using real Cline tools. For
   every mutating (TYPE1) action, wait for Cline's own approval UI to
   fire and be answered — never assume approval. Capture the actual
   tool-call/tool-result (diff, stdout, exit code, file content) — never
   a narrated "this should work." Append a `maker` frame per step to
   `trail/pmcro-cline.jsonl` before moving to Check.

4. **Check.** Independently re-derive pass/fail from raw evidence for
   each step — re-read the file, re-run the check, re-list the
   directory. Do not trust a self-reported "success" flag from Make.
   Append a `checker` frame per step to `trail/pmcro-cline.jsonl`.

5. **Reflect.** State an explicit verdict: Accept / Retry / Halt. If
   something failed in a genuinely new way, write one sentence
   describing the constraint and append it under "Earned Constraints"
   in `trail/README.md`. Append a `reflector` frame to
   `trail/pmcro-cline.jsonl`.

6. **Seal.** Append the final `orchestrator` frame to
   `trail/pmcro-cline.jsonl` with the terminal verdict. This is the last
   action of the cycle — do not do anything else after this frame.

## Reminders

- This workspace is Windows PowerShell — use `;` to chain shell
  commands, never `&&`.
- Every phase gets its own real line in `trail/pmcro-cline.jsonl`,
  written before moving to the next phase (log-before-act). A cycle
  with a missing phase line did not actually happen — go back and add
  it truthfully, don't backfill it as if it were seamless.
- If this task is genuinely a single-fact lookup or one-line edit, say
  so and skip the full loop — but default to running it when in doubt.
