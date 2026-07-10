# PMCR-O Template for Cline

**The autonomous agent loop that plans, executes, verifies, and learns — all with a human in the loop.**

A production-ready **Plan-Make-Check-Reflect** (PMCR-O) template repository that transforms Cline from a single-query assistant into a self-governing, auditable, multi-agent system. Every significant task becomes a structured cycle with traceable decisions, verifiable outputs, and a sealed audit trail.

---

## Why This Template?

| Problem | How PMCR-O Solves It |
|---|---|
| **Unstructured agent output** — Cline guesses, writes, and moves on with no verification. | Every cycle runs Plan &rarr; Make &rarr; Check &rarr; Reflect. Nothing ships unchecked. |
| **No audit trail** — You have no idea what changed or why. | Immutable `.jsonl` trail per cycle with full phase evidence. Trace any decision back to its raw output. |
| **Accidental mutations** — A tool call runs without approval. | TYPE1 actions (file writes, terminal commands) gate on explicit human approval. No silent changes. |
| **Context confusion** — Files get written to the wrong workspace root. | Two rigid context roots: **Domain** (code) vs **Orchestration** (agent state & trails). Never cross the streams. |
| **Learning lost** — The same mistakes repeat across sessions. | Reflector captures **Earned Constraints** — lessons crystallized into rules that tighten the system over time. |
| **No scalability** — One agent, one shot, one file. | Five specialized agents (Planner/Maker/Checker/Reflector/Orchestrator) with clear boundaries. Scales to parallel dispatch. |

---

## Quick Start

### 1. Clone & Initialize

```bash
git clone https://github.com/ShawnDelaineBellazanLoop/pmcro-template.git
cd pmcro-template
```

### 2. Configure Cline

Open this directory as your Cline workspace root. The `.clinerules/pmcro-loop.md` file loads automatically as Cline's custom instructions.

**Critical: Disable auto-approve for TYPE1 tools:**
- `write_to_file`, `replace_in_file`, `execute_command`
- Any mutating `use_mcp_tool` calls
- `browser_action.click`, `browser_action.type`
- **Never enable YOLO mode** — it bypasses every human gate.

TYPE2 tools (read-only) are safe to auto-approve.

### 3. Run Your First Cycle

Open a new Cline conversation and type:

```
/pmcro-cycle SeedIntent: <describe one scoped, verifiable piece of work>
```

For example:

```
/pmcro-cycle SeedIntent: Add a CHANGELOG.md documenting the last 3 repository changes
```

Cline will execute the full loop:
1. **Plan** &mdash; Decompose intent into step-by-step strategy with success criteria
2. **Make** &mdash; Execute each step (every mutation requires your approval)
3. **Check** &mdash; Verify results against criteria using raw tool evidence
4. **Reflect** &mdash; Decide **Accept**, **Retry**, or **Halt** & log Earned Constraints

After each cycle, inspect `.pmcro/trails/<trailId>/` for the sealed evidence.

---

## Key Features

### Loop Protocol (`/pmcro-cycle`)
A single command triggers the full autonomous pipeline. The loop never skips a phase and never conflates the two context roots.

### Five Specialized Agents
Each agent has a strict role, owns specific artifacts, and *cannot* drift into another agent's territory:

| Agent | Role | Owns |
|---|---|---|
| **Orchestrator** | Mission Commander | Trail initialization, cycle dispatch, state management |
| **Planner** | Strategic Architect | Task decomposition, tool selection, success criteria |
| **Maker** | Technical Implementer | Code generation, file modification, command execution |
| **Checker** | Quality Auditor | Verification, raw evidence collection, pass/fail verdict |
| **Reflector** | Decision Authority | Final verdict, Earned Constraints, trail sealing |

### Immutable Audit Trails
Every phase writes a separate file to `.pmcro/trails/<subject-agent>/<trailId>/`:
```
00-frame.json       — trail metadata (trail_id, seed_intent, timestamp)
01-plan.jsonl       — Planner's strategy
01-make.jsonl       — Maker's execution evidence
01-check.jsonl      — Checker's raw verification output
01-reflect.jsonl    — Reflector's verdict
02-plan.jsonl ...   — only on Retry (cycle number increments)
disposition.json    — final sealed outcome
```

Each file uses PascalCase keys with nested envelopes (later phases embed prior phase output). Written once per phase — never appended, never overwritten.

### Human-in-the-Loop Security
TYPE1 actions cannot run without interactive approval. This holds for every `write_to_file`, `replace_in_file`, `execute_command`, and mutating MCP call — every time, regardless of trust score.

### Earned Constraints
When a cycle fails, the Reflector doesn't just log the symptom. It identifies the root cause pattern and crystallizes a new **Earned Constraint** — a rule added to the trail contract that prevents the same failure class from recurring. Over time, the system becomes more robust without manual intervention.

### Context Segregation
- **Domain Context** — your real project; code, builds, artifacts
- **Orchestration Context** — `.pmcro/` — agent definitions, registries, immutable trails

Absolute paths enforce this boundary. Agents operate on the Domain; orchestration data lives in its own root. Never cross the streams.

---

## Onboarding for Partners & New Users

If you're new to PMCR-O or autonomous agent systems, here's how to get oriented:

1. **Read the architecture docs** — Start with `.clinerules/pmcro-loop.md` (24 lines). It defines the loop protocol, context segregation, and security gates in plain language.
2. **Understand the agents** — Browse `.pmcro/agents/`. Each agent's `.md` file is short (20-30 lines) and states exactly what it owns and cannot do.
3. **See a real trail** — Inspect `.pmcro/trails/orchestrator/T1-audit-005/`. Open `00-frame.json` first for the seed intent, then `01-plan.jsonl` through `disposition.json` in order. This is exactly what every cycle produces.
4. **Run a read-only cycle** — Start with `/pmcro-cycle SeedIntent: Inspect the .pmcro/trails/ directory and report which audits passed and which constraints were earned.` This runs the full loop with zero TYPE1 mutations — you'll see every phase without approving write operations.
5. **Escalate gradually** — Try a cycle with one small file write (e.g., adding a line to an existing markdown document). Approve the write when prompted. Then check the trail to see how the Checker verified your change.

**Non-technical partners** can participate by reviewing trail files — each frame is written in plain English with clear verdicts (`AllStepsOk: true/false`, `FinalVerdict: Accept/Retry/Halt`). The human-in-the-loop gate also means no action happens without your explicit sign-off.

---

## Using the Onboarding Skill

The fastest way to get set up is the **pmcro-partner-onboarding** skill. It walks you through cloning, environment configuration, and verifying your first cycle end-to-end.

1. **Open the repo in VS Code with Cline** — load this directory as your Cline workspace root.
2. **Type `onboard me`** — Cline activates the `pmcro-partner-onboarding` skill automatically.
3. **Follow the guided flow** — the skill leads you through setup and first-cycle verification, confirming the PMCR-O loop is working before you do anything else.

No manual reading required — the skill is the canonical onboarding path.

---

## Folder Structure

```
├── .clinerules/
│   └── pmcro-loop.md            # Governance rules — loaded automatically by Cline
├── .pmcro/
│   ├── agents/
│   │   ├── orchestrator.md      # Mission Commander (dispatches, state-keeps)
│   │   ├── planner.md           # Strategic Architect (task decomposition)
│   │   ├── maker.md             # Technical Implementer (code & commands)
│   │   ├── checker.md           # Quality Auditor (verification)
│   │   ├── reflector.md         # Decision Authority (verdict & constraints)
│   │   └── registry.md          # Tool classification & HIL governance
│   ├── hil/
│   │   └── README.md            # Human-in-the-Loop gate contract
│   ├── trails/
│   │   ├── README.md            # Trail contract & Earned Constraints log
│   │   └── orchestrator/        # Sealed audit trails by subject agent
│   ├── cline_pmcro_colony_instance.yaml  # Instance configuration
│   ├── CYCLE-LOG.md             # Human-readable cycle index
│   └── project-context-dump.md  # Generated context snapshot
├── scripts/
│   ├── generate-context-dump.ps1   # PowerShell context dumper
│   └── sourcedump.ps1              # Source dump utility
├── LICENSE.txt                  # MIT License
└── README.md                    # This file
```

---

## Key Files Reference

| File | Purpose |
|---|---|
| [.clinerules/pmcro-loop.md](.clinerules/pmcro-loop.md) | Core governance — loop protocol, context segregation, HIL gates |
| [.pmcro/agents/planner.md](.pmcro/agents/planner.md) | Task decomposition & success criteria |
| [.pmcro/agents/maker.md](.pmcro/agents/maker.md) | Code generation & execution discipline |
| [.pmcro/agents/checker.md](.pmcro/agents/checker.md) | Independent verification contract |
| [.pmcro/agents/reflector.md](.pmcro/agents/reflector.md) | Decision authority & constraint logging |
| [.pmcro/agents/registry.md](.pmcro/agents/registry.md) | Tool TYPE1/TYPE2 classification + Cline 2.0 surface mapping |
| [.pmcro/hil/README.md](.pmcro/hil/README.md) | Human-in-the-Loop configuration & transport caveats |
| [.pmcro/trails/README.md](.pmcro/trails/README.md) | Trail format, Earned Constraints log, schema precedent |
| [.pmcro/CYCLE-LOG.md](.pmcro/CYCLE-LOG.md) | Running log of all completed cycles |
| [scripts/generate-context-dump.ps1](scripts/generate-context-dump.ps1) | Context snapshot generator for planning phases |

---

## License

MIT — see [LICENSE.txt](LICENSE.txt) for the full text.

---

## Status

**Production-ready template.** The repository includes 5 sealed audit trails (T1-audit-001 through T1-audit-005) that validate the architecture against itself — each cycle audited a portion of the PMCR-O system and tightened its rules. New instances start from this template with zero drift.

For questions, issues, or contributions, open a GitHub issue or reach out to the maintainer.