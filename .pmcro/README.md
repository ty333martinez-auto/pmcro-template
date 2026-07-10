# PMCR-O for Cline — Self-Contained Colony Instance

This is a filled-in **instance** of the `pmcro-base` Tier-0 template
(`A:\source\.agents\skills\pmcro-base\`), tokenized for **Cline** as the
runtime. As of 2026-07-10 this instance is **self-contained at
`B:\pmcro-cline\`** — workspace root and instance data now live in the
same place. It does not fork or edit the base template — it's a resolved
copy per `references/resource-access.md`'s token-substitution contract.

Domain: **the real Colony project at `A:\`** — this instance's cycles are
about the Colony's own construction (closing the orchestrator skill gap,
earning the first real Chief-tier trail, the `chief_config.schema.json`
work, etc.), not an external product or client task. Cline is now the
tool used to build PMCRO itself — PMCRO building PMCRO.

## What changed from the prior split-root design

Before 2026-07-10, this instance's data (`agents/`, `trails/`, `hil/`,
the instance yaml) lived at `A:\.pmcro\`, while Cline's workspace root
was `B:\pmcro-cline` — two roots, one instance. That split is retired.
`A:\.pmcro\` is left in place, untouched, for now (not migrated, not
deleted) — it holds no sealed trails (confirmed zero `disposition.json`
files existed there before this change), so there is no evidence to
carry forward. This instance starts its own trail at cycle 1, same as
the old one did.

## What's here

| Path | Purpose |
|---|---|
| `B:\pmcro-cline\.clinerules\pmcro-loop.md` | Loaded automatically by Cline as custom instructions. Wires the 5-phase loop into every non-trivial task, operating on `A:\` (the real Colony source) via absolute paths, sealing trail data here at `B:\pmcro-cline\.pmcro\`. |
| `B:\pmcro-cline\.clinerules\workflows\pmcro-cycle.md` | On-demand, invoked with `/pmcro-cycle.md <task>`. Forces the full Plan→Make→Check→Reflect→Seal sequence. |
| `cline_pmcro_colony_instance.yaml` | The filled `cycle-template.schema.yaml` — identity, cadence (incl. the 30-day commitment), evidence definition, trail location, HIL policy, subject-agent registry. |
| `agents/*.md` | Phase contracts (Planner/Maker/Checker/Reflector/Orchestrator), resolved for this instance. |
| `agents/registry.md` | Maps Cline's real tool groups to subject-agent names + TYPE1/TYPE2 classification, scoped to the real Colony repo at `A:\`. |
| `trails/<trailId>/` | Sealed frame files, one directory per trail, one file per phase per cycle (`00-frame.json`, `NN-plan.jsonl`, `NN-make.jsonl`, `NN-check.jsonl`, `NN-reflect.jsonl`, `disposition.json`). |
| `trails/README.md` | Trail contract + Earned Constraints log. |
| `hil/README.md` | How the human-in-the-loop gate works in Cline, for this instance. |
| `CYCLE-LOG.md` | Day-by-day record of the 30-day commitment — which cycles actually ran, which days didn't happen. |

## Quick start

1. Open **`B:\pmcro-cline`** as the Cline workspace root — `.clinerules`
   loads from there automatically. Domain work still targets `A:\` via
   absolute paths; instance data (agents/trails/hil) now resolves
   relative to this workspace instead of out to `A:\.pmcro\`.
2. **Turn off auto-approve** for TYPE1 categories — see `hil/README.md`.
3. Kick off cycle 1 with a real seed intent, e.g.:
   `/pmcro-cycle.md <a real, scoped piece of Colony work>`
4. Inspect `trails/<trailId>/` after each cycle — every phase should
   have a real file, written before the next phase started.

## Reference precedent

The trail directory/file layout here matches the proven format already
running in the real Colony at `S:\.pmcro\trails\<subject-agent>\<trailId>\`
— see `trails/README.md` for the exact field-shape precedent this
instance follows.

## Honesty note

This is a Tier-0 instance the moment this file is written, and stays
Tier-0 until a real cycle actually runs and seals. Don't claim Tier 1+
maturity, a "shrinking HIL surface," or any earned constraint until a
real `trails/<trailId>/disposition.json` actually exists proving it.

## Status

Scaffolded, not yet run. Cycle 1 has not started.
