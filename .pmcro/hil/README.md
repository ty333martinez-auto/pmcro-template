# HIL (Human-in-the-Loop) Gate — PMCRO Colony (self-contained Cline instance)

Per `references/resource-access.md` §3 in the base template: transport is
an instantiation detail, the contract only requires that a TYPE1 action
genuinely blocks until a real human decision is made. In this instance,
the transport is **Cline's own native tool-approval UI** — no separate
system to build.

**Transport caveat (2026-07-10):** as of Cline 2.0 / `@cline/sdk` (May
2026), "Cline's tool-approval UI" is no longer one single surface. The
CLI and Kanban board already run on the extracted `@cline/sdk` runtime;
VS Code/JetBrains are mid-migration onto it. Headless CLI invocation
(`cline --json ...`) and Kanban-dispatched parallel agents do not
necessarily block on the same interactive approval UI this instance
assumes. **This instance's HIL contract only holds when run inside the
VS Code/JetBrains extension with the interactive approval UI visible.**
If this loop is ever invoked via the CLI, SDK embedding, or Kanban, stop
and confirm the actual approval transport in use before running any
TYPE1 step — do not assume the same gate applies.

## What this means concretely, in the real Colony project

1. In Cline's settings, under auto-approve, **leave these OFF**:
   - `write_to_file`
   - `replace_in_file`
   - `execute_command` (this includes `dotnet build`, `dotnet test`,
     `dotnet run`, `git`, `aspire`, `ollama` — all of it, every time)
   - any mutating `use_mcp_tool` call (per `agents/registry.md`'s
     `cline-mcp-agent` row)
   - `browser_action.click`, `browser_action.type`
   - **YOLO mode** — this is a global override that bypasses the
     approval UI entirely for all tool categories, TYPE1 included. Never
     enable it for this instance, not even "just to test something."
   - **Lazy Teammate Mode** — reduces how often Cline asks for
     clarification/confirmation mid-task; must not be treated as
     covering the TYPE1 approval requirement, which is a separate gate.
   - The **Spend Limit Reached** dialog is a cost control, not a HIL
     gate — staying under a spend limit says nothing about whether a
     given action was safe to auto-run. Don't treat "spend limit not
     hit" as any kind of approval signal.
2. Fine to auto-approve TYPE2: `read_file`, `list_files`,
   `search_files`, `list_code_definition_names`,
   `Filesystem:read_file`, `Filesystem:list_directory`,
   `Filesystem:get_file_info`, `access_mcp_resource`,
   `browser_action.launch/scroll/screenshot`.
3. **Fires every time, regardless of trust score.** A TYPE1 action gates
   even if ten similar actions were approved earlier — including across
   different days of the 30-day window. Don't turn on auto-approve for a
   TYPE1 category just because it's been reliable so far.
4. **A denial is signal, not just a stop.** A rejected TYPE1 action on
   the real Colony project (e.g. a proposed change to `AppHost.cs`, a
   destructive git command) should be captured as retry context and
   handed to Reflector — it's exactly the kind of first-time-failure
   pattern that can become a new `EarnedConstraint`.
5. **No default-approve on timeout.** If left unattended, keep waiting /
   halt the cycle — never auto-approve.

## What does *not* count as a HIL gate

- Cline narrating "I'll go ahead and make this change" and proceeding
  without the approval UI actually firing.
- Treating a previously-approved similar action as blanket approval for
  a new one, even within the same cycle.
- Any auto-approve toggle left on for a TYPE1 category "temporarily" —
  turn it back off before the next task.
- YOLO mode, Lazy Teammate Mode, or a headless/CLI/Kanban invocation
  with no visible approval UI attached — these skip or weaken the same
  mechanism this contract depends on, regardless of what they're called
  in Cline's settings.
