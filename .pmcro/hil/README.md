# HIL (Human-in-the-Loop) Gate — PMCRO Colony (self-contained Cline instance)

Per `references/resource-access.md` §3 in the base template: transport is
an instantiation detail, the contract only requires that a TYPE1 action
genuinely blocks until a real human decision is made. In this instance,
the transport is **Cline's own native tool-approval UI** — no separate
system to build.

## What this means concretely, in the real Colony project

1. In Cline's settings, under auto-approve, **leave these OFF**:
   - `write_to_file`
   - `replace_in_file`
   - `execute_command` (this includes `dotnet build`, `dotnet test`,
     `dotnet run`, `git`, `aspire`, `ollama` — all of it, every time)
   - any mutating `use_mcp_tool` call (per `agents/registry.md`'s
     `cline-mcp-agent` row)
   - `browser_action.click`, `browser_action.type`
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
