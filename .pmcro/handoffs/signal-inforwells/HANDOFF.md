# Signal InfoWells — PMCR-O Autonomous Handoff

**Status:** Experimental. Repository artifacts exist; effectiveness is not established.  
**Purpose:** Give a coding agent enough grounded context to inspect the project, create a root `AGENTS.md`, run appropriate checks, and record discrepancies without inventing evidence.

## 1. Canonical repository references

- Repository: https://github.com/ty333martinez-auto/pmcro-template
- Product folder: https://github.com/ty333martinez-auto/pmcro-template/tree/master/products/signal-inforwells-pmcro
- Product README: https://github.com/ty333martinez-auto/pmcro-template/blob/master/products/signal-inforwells-pmcro/README.md
- Website source: https://github.com/ty333martinez-auto/pmcro-template/tree/master/docs/signal-inforwells
- InfoWells test workflow: https://github.com/ty333martinez-auto/pmcro-template/actions/workflows/test-signal-inforwells.yml
- Pages workflow: https://github.com/ty333martinez-auto/pmcro-template/actions/workflows/pages-signal-inforwells.yml
- Previously reported test run (must re-check before describing as current): https://github.com/ty333martinez-auto/pmcro-template/actions/runs/38031048632
- Expected Pages URL only if enabled and a deployment succeeds: https://ty333martinez-auto.github.io/pmcro-template/

## 2. Shared conversation sources — not yet content-verified

- Claude shared conversation: https://claude.ai/share/4ccd3374-c49b-495b-816f-e5d6bc2c3532
- ChatGPT shared conversation: https://chatgpt.com/s/cx_6ac9dad757708191a1ab51f16dd6a341

The shared conversation contents were not retrievable during the earlier handoff preparation. That is an access limitation, not proof that either link is broken and not evidence of what the conversations contain. Attempt access through an appropriate browser or ask the user to export/paste content if still inaccessible. Record exactly what was and was not inspected.

## 3. Signal InfoWells core contract

Signal InfoWells is a reasoning framework designed to examine reality without allowing any single mode of thought to define it alone.

**Foundational principle:** No single pillar is allowed to define reality by itself.

**Architecture:** Awareness → Six Pillars ↔ Recognition → Action → Experience → Reflection → Awareness.

Six pillars:
1. **Perception — Outer World:** What is actually here?
2. **Imagination — Possibilities:** What else could be possible?
3. **Empathy — Connection:** What may another person be experiencing or seeing?
4. **Introspection — Inner World:** What is happening within me?
5. **Emotion — Movement / Signal:** What is moving within me, and what might that signal? Emotion is a signal, not a directive.
6. **Reason — Logic.**

Recognition integrates and cross-checks information and formalizes the current state of knowing: **Know / Believe / Suspect / Don’t Know Yet**.

### Open research question — do not silently resolve
Recognition's status as a distinct mechanism is unresolved. In Test 6 (Recognition Gap), Recognition appeared to occur during Phase A, before the explicit Recognition phase; Run 1 was therefore inconclusive. Preserve this uncertainty. Do not rewrite a hypothesis as a confirmed fact. A paired baseline comparison has been proposed as Test 7, but must not be reported as completed unless evidence confirms it.

## 4. Layers and operations

Keep the reasoning-framework core separate from governance, skills, operations, deep investigation, and orchestration.

Known layers:
- **Signals:** what triggers work.
- **Skills:** reusable capabilities.
- **Protocols:** how skills are sequenced or activated.
- **PMCR-O:** planning, making, checking, reflecting, and preserving the audit trail.

Operations loop:
**Receive → Identify → Gather → Apply → Test → Resolve → Refine → Record.**

Known signal-to-response examples:
- Evidence gap → evidence gathering.
- Assumption → assumption testing.
- Contradiction → conflict resolution.
- Limitation → limitation analysis.
- Ambiguity and bias checks may be candidate extensions; verify implementation before calling them active.

Bounded recursion:
- Default maximum: three refinement cycles.
- Repeat only when a test criterion fails or new evidence arrives.
- Maker must not be the sole checker.
- Record unresolved gaps instead of forcing convergence.
- Consequential external actions require explicit authorization.
- Do not treat orchestration as proof of correctness.

## 5. CapCut validation context

The user is working with **CapCut Desktop on Windows** and requested a manual, evidence-based **CapCut Guided Validation Loop — test session 001** to generate or edit a video using a prompt.

Rules:
- Guide the user manually and request screenshots when useful.
- Do not claim direct computer access.
- Do not claim that a video was generated, edited, exported, or posted unless evidence demonstrates that exact action.
- Record app state, user action, visible result, errors, expected behavior, and next step.
- Distinguish not-run, blocked, failed, and passed.
- The CapCut prompt is located at `products/signal-inforwells-pmcro/examples/capcut-signal-inforwells-prompt.md`; inspect the current file rather than relying on memory.

## 6. Known repository status to re-verify

The product README currently says:
- Automated scaffold tests: 5 passed locally in the generated package.
- Independent reviewer: not yet run.
- Live CapCut execution: not performed.
- General effectiveness: not established.
- GitHub Pages deployment must be verified after Actions runs.

Earlier conversation context reported a successful five-test GitHub Actions run and a Pages setup failure at `configure-pages` with `Resource not accessible by integration`. These are historical leads, not current verified status. Re-check workflow runs and logs before using them as current findings.

The repository's test workflow runs:
`python -m unittest discover -s tests -p 'test_signal_inforwells.py' -v`
on qualifying pushes, pull requests, and manual workflow dispatch. Use the repository's current workflow file as the authority.

## 7. Autonomous review sequence

1. **Receive:** Confirm this handoff and the user's current objective.
2. **Identify:** Enumerate source files, shared links, workflow status, CapCut requirements, and evidence gaps.
3. **Gather:** Inspect repository files and live workflow results. Try the shared links through available authorized means. Keep an access ledger.
4. **Apply:** Compare the framework contract with product assets, agent instructions, test assertions, and workflow behavior.
5. **Test:** Run relevant automated checks where the environment permits. For GUI work, use screenshots and manual evidence. Never label an unrun test as passed.
6. **Resolve:** Reproduce and classify discrepancies. Avoid unrelated changes.
7. **Refine:** Make the smallest justified fix; rerun only checks affected by the fix. Default to at most three cycles.
8. **Record:** Save findings and run evidence in a traceable artifact; include commit, workflow, or screenshot references where available.

### Finding classifications
- **Confirmed:** Direct evidence reproduces or proves the discrepancy.
- **Suspected:** Plausible, but evidence is incomplete.
- **Unknown / Not verifiable:** Source or required environment is unavailable.
- **Not an error:** The observed behavior matches the documented contract.

Each finding should include:
- ID and severity (Critical / High / Medium / Low / Info)
- Classification
- Source and evidence reference
- Reproduction steps
- Expected vs observed behavior
- Impact
- Fix hypothesis (not a claim of fix)
- Validation performed and remaining unknowns

## 8. Required deliverables

- Source-access ledger: accessible / inaccessible / partial.
- Error and discrepancy register with evidence and severity.
- Test report separating passed / failed / blocked / not run.
- CapCut session trail, if a live session is actually conducted.
- Short next-actions list.
- Links to any committed changes and workflow runs.

## 9. Accuracy and permission guardrails

- No fabricated source contents, logs, screenshots, test outcomes, or actions.
- Separate observations from inferences and recommendations.
- If independent validation is unavailable, mark it incomplete.
- Do not claim deployment without a successful deployment run and a verified URL.
- Do not claim the shared chats were inspected unless their contents were actually accessed.
- Do not claim CapCut was operated by the agent unless the available environment actually provided that access and evidence.
- Do not change credentials, repository settings, or external services as part of this review without explicit authorization.
- GitHub Issues are currently reported by the API as disabled for this repository; do not claim an issue was created. Use a committed handoff artifact unless repository settings change.
