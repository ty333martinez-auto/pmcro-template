# Subject-Agent Registry — PMCRO Colony (self-contained Cline instance)

Maps a subject-agent **name** to Cline's real tool surface, per
`references/resource-access.md` §1 in the base `pmcro-base` template
(`A:\source\.agents\skills\pmcro-base\`). The Orchestrator resolves names
against this file at dispatch time. It never holds a flat tool list of
its own — this file is the single source of truth for that mapping.

`resolve(name)` = look the name up in the table below. Not found ->
return none / stop and say so. **Never guess a fallback silently.**

**The Orchestrator itself is never a registrable name** — see
`agents/orchestrator.md` for why.

## Registry table

| name | real Cline tools | TYPE1 (mutating — HIL required) | TYPE2 (read-only — no gate) |
|---|---|---|---|
| `cline-fs-agent` | file tools, working root `A:\` (domain work) or `B:\pmcro-cline\.pmcro\` (this instance's own trail/config writes) | `write_to_file`, `replace_in_file` | `read_file`, `list_files`, `search_files`, `list_code_definition_names` |
| `cline-terminal-agent` | shell (PowerShell) — `dotnet build`, `dotnet test`, `dotnet run`, `git`, `aspire`, `ollama` | `execute_command` | *(none — no safe read-only subset; always TYPE1)* |
| `cline-browser-agent` | Playwright/Patchright browser automation | `browser_action.click`, `browser_action.type` | `browser_action.launch`, `browser_action.scroll`, `browser_action.screenshot` |
| `cline-mcp-agent` | any connected MCP server (Filesystem, Atlassian Rovo, Postman, etc.) | any mutating `use_mcp_tool` call (e.g. `Filesystem:write_file`, `Atlassian Rovo:createJiraIssue`, `Atlassian Rovo:editJiraIssue`) | read-only `use_mcp_tool` calls (e.g. `Filesystem:read_file`, `Atlassian Rovo:getJiraIssue`, `Atlassian Rovo:search`) + `access_mcp_resource` |

This table must match `subject_agents:` in `cline_pmcro_colony_instance.yaml`.

## Domain-specific note

This instance is now **self-contained**: Cline's workspace root and this
instance's own data both live at `B:\pmcro-cline\`. The **domain** of
actual engineering work is still the real Colony project at `A:\` — every
`cline-fs-agent` and `cline-terminal-agent` action targeting Colony work
must use an **explicit absolute `A:\...` path**, never a bare relative
path (which would resolve against `B:\pmcro-cline` instead). For
`cline-terminal-agent`, that means either a full path per command or a
leading `cd A:\...;` (PowerShell `;`, not `&&`) before the real command.
Writes to this instance's own trail/config data use explicit
`B:\pmcro-cline\.pmcro\...` paths instead.

`cline-terminal-agent` steps here can affect the actual .NET solution,
Aspire resources, and running Ollama models — treat every TYPE1 terminal
step with the same weight as an fs-agent write, even for commands that
look read-only (`dotnet test` can still mutate build artifacts, touch
ports, etc.).

## Naming discipline check (Core Mechanic 7)

Before adding a new row: is this a genuinely new capability, or an
existing tool group (fs / terminal / browser / mcp) pointed at a new
target? Don't add e.g. a `skill-loader-agent` — that's `cline-fs-agent`
reading/writing under `A:\source\.agents\skills\`, not a new capability.
