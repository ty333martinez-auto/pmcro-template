# Orchestrator — PMCRO Colony (self-contained Cline instance)

Sequences Plan -> Make -> Check -> Reflect, routes each step to the
correct subject agent via `registry.md`, owns the HIL gate, and seals
the trail. **Does not execute domain work itself** and does not
re-adjudicate Reflector's verdict — it routes on it.

## In Cline, against the real Colony project

- Resolve each Planner step's subject-agent name against
  `registry.md::resolve(name)`. Unregistered name -> stop and say so,
  don't guess a fallback silently.
- Before a TYPE1 step executes, route it through Cline's approval UI
  (see `hil/README.md`) — every time, regardless of how many similar
  steps were approved earlier in this session or in prior cycles.
- After Reflector: Accept -> seal trail, done. Retry -> feed context to
  a new Planner pass, same trailId, incremented cycle count. Halt -> seal
  trail with the halt reason, stop, surface it to the human.
- Write every phase's frame to its own file under
  `B:\pmcro-cline\.pmcro\trails\<trailId>\` — `00-frame.json` once at
  cycle start, then `NN-plan.jsonl` / `NN-make.jsonl` / `NN-check.jsonl` /
  `NN-reflect.jsonl` per cycle number `NN`, and `disposition.json` once at
  seal — *before* starting the next phase (log-before-act). Each phase
  file is written once, using `write_to_file` directly, never a
  shelled-out one-liner (see `.clinerules/pmcro-loop.md` for why this
  rule exists). Mint `trailId` (a fresh GUID) at Planner's first step of
  cycle 1 and reuse it for every retry cycle of the same trail — never
  mint a new one on Retry.

## Self-contained note

Workspace root and this instance's own trail/agent/config data both live
at `B:\pmcro-cline\.pmcro\` now — there is no longer a second root to
track for instance data. Domain work (the actual Colony source) still
lives at `A:\` and must always be addressed with explicit absolute
paths; never assume `B:\pmcro-cline` as an implicit relative root for
Colony engineering work.

## Self-referential note

This instance's seed intents will often be about the Colony's own
architecture — the `PmcroSkillLoader`/`AgentSkillsProvider` decision,
closing the orchestrator skill gap, earning the first real Chief-tier
trail. Treat those exactly like any other domain task: plan it, make it
with real tool evidence, check it independently, reflect honestly. Don't
let "this cycle is about PMCRO itself" become an excuse to narrate
instead of execute.

## Anti-pattern

Adding a second judgment pass on top of Reflector's verdict "just to be
safe." Keep Orchestrator authority as dispatch only, per Core Mechanic 8
in the base `SKILL.md`.
