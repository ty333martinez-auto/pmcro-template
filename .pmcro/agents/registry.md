# PMCR-O: SYSTEM REGISTRY & SERIALIZATION CONTRACT

## 1. TOOL CLASSIFICATION (HIL GOVERNANCE)
Every tool available to the system is classified by its mutation risk. This classification determines whether the Human-In-The-Loop (HIL) gate is triggered.

### TYPE1: MUTATING (Requires HIL Approval)
These actions alter the state of the Domain or Orchestration context. They must NEVER be auto-approved.
- **Filesystem**: `write_to_file`, `replace_in_file`, `delete_file`, `create_directory`.
- **Terminal**: `execute_command` (Always TYPE1, regardless of the command string).
- **Browser**: `browser_action` (When performing `click`, `type`, or `submit`).
- **MCP**: Any `use_mcp_tool` call that performs a write, delete, or deployment.

### TYPE2: READ-ONLY (Autonomous Flow)
These actions observe state and do not require HIL approval.
- **Filesystem**: `read_file`, `list_files`, `search_files`, `list_code_definition_names`.
- **Browser**: `browser_action` (When performing `screenshot` or `scroll`).
- **MCP**: Any `use_mcp_tool` call that fetches logs, metrics, or read-only data.

## 2. IMMUTABLE STATE CONTRACT
To ensure the audit trail is machine-readable and follows 2026 enterprise standards, all `.jsonl` and `.json` files in the `trails/` directory MUST adhere to this schema:

- **Casing**: Use strict **PascalCase** for all keys (e.g., `TrailId`, `SeedIntent`, `AllStepsOk`, `CycleNumber`, `StepIndex`).
- **Structure (Nested Envelopes)**: Do not flatten phase data. Each subsequent phase must wrap the previous phase's output.
    - `NN-plan.jsonl` — Planner's frame for cycle `NN`.
    - `NN-make.jsonl` — Maker's frame; contains the `Plan` output.
    - `NN-check.jsonl` — Checker's frame; contains `MakerOutput`, which nests `Plan`.
    - `NN-reflect.jsonl` — Reflector's frame; contains `CheckerOutput`, nesting the full chain.
    - `NN` is the cycle number within one `trailId` (increments only on Retry, per `pmcro-cycle.md` step 6) — not a running count across phases.
- **Serialization**: Every write must be performed using a native file-write tool call. Do not use shell interpolation, as it corrupts nested JSON quotes.
- **No-Shell-Logging Rule**: Never use `echo` or shell redirection (`>`, `>>`, `| Out-File`) to write to `.jsonl` trails. Use native `write_to_file` to preserve JSON integrity and quoting.

## 3. REALITY CHECK OVERRIDE
If a conflict arises between this document and an existing, sealed file in `ORCHESTRATION_CONTEXT/.pmcro/trails/`, the **on-disk file is the ground truth**. You must update this registry to match the observed reality of the filesystem immediately.

## 4. CLINE 2.0 SURFACE MAPPING
Cline 2.0 (May 2026+) has decomposed its runtime into several distinct surfaces that interact with the PMCR-O loop. Each surface has a different HIL transport contract. This section maps each surface and documents the transport caveat.

### 4.1 @cline/sdk (SDK Runtime)
The extracted `@cline/sdk` package is the core runtime on which the CLI, Kanban, and IDE extensions are built. As of 2026-07-10, the VS Code/JetBrains extensions are mid-migration onto this SDK; the CLI and Kanban already use it natively.
- **Registration**: Not directly a tool surface — it is the runtime substrate. However, any code that embeds `@cline/sdk` directly bypasses the interactive approval UI unless explicitly wired to it.
- **HIL Transport**: The SDK does not mandate any particular approval transport. An embedding application must provide its own.
- **Caveat**: All applications built on `@cline/sdk` inherit only the approval transport the embedding app implements. This instance's HIL contract (interactive UI button) only holds inside the VS Code/JetBrains extension.

### 4.2 Cline CLI (`cline --json`)
The CLI surface invokes Cline from a shell with structured JSON input/output.
- **Registration**: Not a Cline tool — it is an invocation entry point. Commands issued via `cline --json "..."` do not trigger the interactive approval UI.
- **HIL Transport**: None. The CLI is headless by design. All tool actions run with whatever auto-approve policy is configured — there is no per-action human gate.
- **Caveat**: This instance MUST NOT be invoked via the CLI unless the HIL transport is explicitly confirmed to be a blocking approval gate. The `hil/README.md` transport caveat (lines 9-16) applies here.

### 4.3 Cline Kanban (Parallel Dispatch)
The Kanban board dispatches multiple Cline agents in parallel against independent work items.
- **Registration**: Not a Cline tool — it is an orchestration surface. Kanban-dispatched agents may each run with their own configuration, potentially including different auto-approve settings.
- **HIL Transport**: Each Kanban agent's HIL gate is whatever its individual configuration specifies. A Kanban agent configured with auto-approve on TYPE1 does not block — the human never sees the approval request.
- **Caveat**: This instance must never be dispatched via Kanban unless every Kanban agent's TYPE1 categories have HIL gates explicitly enabled. The `hil/README.md` transport caveat applies to each Kanban agent independently.

### 4.4 Cline Skills (Skill Registry)
Skills are reusable, versioned capability packages that Cline can load. They extend the tool surface available to the agent.
- **Registration**: Skills are registered in `cline_pmcro_colony_instance.yaml` or the equivalent instance configuration. They appear as tool groups under the `cline-mcp-agent` subject-agent in this registry's §1 classification.
- **HIL Transport**: Each skill's tools inherit their TYPE1/TYPE2 classification from §1 of this registry. A skill tool that performs a mutation is TYPE1 and requires HIL approval via the interactive UI.
- **Caveat**: If a skill is loaded via a headless surface (CLI, Kanban, SDK embedding), the HIL gate defined here may not fire — the skill's tool may run without human approval. Skills must only be loaded in surfaces where the HIL transport matches this instance's interactive UI contract.