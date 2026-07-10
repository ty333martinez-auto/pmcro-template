# Reusable PMCR-O Cycle Prompt

Copy the block below and paste it into a new `/pmcro-cycle` message. Replace the
placeholder text in `[BRACKETS]` with your real task details. Everything else is
fixed PMCR-O protocol — do not alter the section headers.

---

```text
/pmcro-cycle SeedIntent: [One-sentence statement of the goal and the trail id to seal, e.g. "Install the acme skill. Verify it. Seal as T1-acme-001."]

Plan:
- Analyze the user's intent and split it into discrete steps.
- Define success criteria for each step.
- Record the plan in the immutable 01-plan.jsonl trail frame.

Maker:
- Execute each planned step using native tools (write_to_file, replace_in_file, execute_command).
- For every TYPE1 (mutating) action, surface it through the Cline UI for explicit Human-In-The-Loop approval. Do not enable auto-approve.
- Never use shell redirection (echo >, >>) to write .jsonl trail frames — use native write_to_file only.
- Record executed steps and artifacts in 01-make.jsonl.

Checker:
- Verify each artifact exists on disk (use execute_command / read_file as evidence).
- Verify syntax/validity claims against real files, not assumptions.
- Record checks (C001, C002, ...) with Result and Evidence in 01-check.jsonl.
- Set AllStepsOk = true only if every check passed.

Reflector:
- Review the Checker output and decide Accept / Retry / Halt.
- If Retry, state the RetryContext precisely. If Halt, state the HaltReason.
- Summarize quality and suggest concrete improvements.
- Record the verdict in 01-reflect.jsonl.

Trail Seal:
- TrailId: T1-[short-name]-[NNN]
- Write disposition.json with Disposition, FinalOutput, RetryContext, HaltReason, EarnedConstraints, CycleNumber.
- The trail is immutable once sealed: no further edits to any frame in this directory.
```

---

## How to use this template

1. Paste the fenced block above into a fresh `/pmcro-cycle` message.
2. Edit only the `[BRACKETS]` text — keep `SeedIntent:`, `Plan:`, `Maker:`,
   `Checker:`, `Reflector:`, and `Trail Seal:` headers verbatim.
3. Send the message. The orchestrator will create
   `.pmcro/trails/orchestrator/<TrailId>/` and append one frame per phase.