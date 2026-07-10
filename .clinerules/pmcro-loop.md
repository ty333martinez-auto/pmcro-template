# PMCR-O: SYSTEM LOOP & ARCHITECTURAL GOVERNANCE

## 1. DYNAMIC CONTEXT SEGREGATION
You must resolve all file operations against two distinct, absolute roots. Never use relative paths that could resolve to the wrong context.
- **DOMAIN_CONTEXT**: The target project root. Operations here are for code execution, builds, and project artifacts.
- **ORCHESTRATION_CONTEXT**: The instance root. Operations here are for agent definitions, registries, and immutable audit trails.

## 2. THE PMCR-O LOOP PROTOCOL
Any prompt starting with `/pmcro-cycle` initiates the automated Plan-Make-Check-Reflect workflow.
- **PLAN**: Use `.pmcro/agents/planner.md` to define steps.
- **MAKE**: Use `.pmcro/agents/maker.md` to execute (HIL Gate enforced for TYPE1).
- **CHECK**: Use `.pmcro/agents/checker.md` to verify via raw tool output.
- **REFLECT**: Use `.pmcro/agents/reflector.md` to decide Accept/Retry/Halt.

## 3. IMMUTABILITY & AUDIT CONSTRAINTS
- **State Persistence**: You must maintain a serialized state of every phase. Each cycle must produce an immutable `.jsonl` audit trail in the `ORCHESTRATION_CONTEXT/.pmcro/trails/` directory.
- **No Shell-Based Logging**: Never use `echo` or shell redirection to write to `.jsonl` trails. Use native `write_to_file` to preserve JSON integrity and quoting.
- **Verification Priority**: Always verify document claims against real files in the trails directory. If a doc claims a schema convention (e.g., casing) that contradicts real on-disk files, reality wins; you must fix the doc to match reality immediately.

## 4. SECURITY & HIL GATES
- **HIL Enforcement**: TYPE1 (mutating) actions REQUIRE explicit Human-In-The-Loop approval via the Cline UI. 
- **Auto-Approve Ban**: You are forbidden from enabling auto-approval for any TYPE1 tool category (Terminal, Filesystem Writes, Mutating MCP calls). Every mutation must be visible to the human operator.