# Skill: skill-creator

## Overview

The `skill-creator` is an **Agent Skill** that enables Cline to create, test, and optimize new Cline Agent Skills following the **Anthropic Skill Creator** specification. This bootstrapping skill serves as the foundational mechanism for the entire agent skills ecosystem within a PMCR-O colony instance.

---

## Capture Intent

Before constructing any new skill, capture and validate the user's intent.

1. **Identify the capability gap** — Determine what specific task the user needs to perform that requires a dedicated skill. A skill should encapsulate one discrete, reusable capability.
2. **Extract the skill name** — Derive a `kebab-case` name from the user's request (e.g., "create a skill for code review" → `code-review`).
3. **Define purpose** — Write a one-sentence description of what the skill does. Use action verbs: "Creates", "Tests", "Optimizes", "Validates", "Generates".
4. **Confirm scope** — Ensure the skill's purpose does not overlap with an existing indexed skill. Check `.agents/skills/index.json` for conflicts.

### Verification Prompt

> "I understood your request to create a skill for **[purpose]**. The skill will be named **[skill-name]** and will **[action description]**. Shall I proceed?"

---

## Draft SKILL.md

Each skill requires a SKILL.md operational guide. Follow this structure:

### Required Sections

1. **# Skill: {name}** — Title header with the skill's name in PascalCase.
2. **## Overview** — 2-3 sentences explaining the skill's purpose and when to use it.
3. **## Capture Intent** — How to gather and validate the user's request before execution (see above for reference).
4. **## Trigger Definitions** — Table of trigger patterns with descriptions. Each pattern must be a natural language string or regex.
5. **## Execution Guide** — Step-by-step numbered instructions for performing the skill's task.
6. **## Optimization Guidelines** — Rules for improving the skill's clarity, trigger matching, and description.
7. **## Quality Rules** — Must include (see Quality Rules section below).

### Markdown Standards

- Use ATX headers (`#`, `##`, `###`) for all headings.
- Use `{backtick}` code fences for file paths, code blocks, and JSON examples.
- Use tables for structured data (trigger definitions, evaluation criteria).
- Use numbered lists for sequential instructions.
- Use bullet lists for non-sequential items and criteria.

---

## Create manifest.json

Every skill requires a manifest.json file with the following fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | kebab-case unique name within the instance |
| `version` | string | yes | Semantic version or date-based version (YYYY.MM.DD) |
| `description` | string | yes | One-line summary under 120 characters |
| `triggers` | array | yes | Array of natural language trigger strings or regex patterns |
| `type` | string | yes | Must be `"agent-skill"` |

### Example manifest.json

```json
{
  "name": "skill-creator",
  "version": "2026.07.10",
  "description": "Creates, tests, and optimizes new Cline Agent Skills.",
  "triggers": [
    "create skill",
    "skill creator",
    "optimize skill",
    "draft skill"
  ],
  "type": "agent-skill"
}
```

### Directory Structure

```
.agents/skills/{skill-name}/
├── manifest.json
└── SKILL.md
```

---

## Test & Eval

After drafting a skill, evaluate it against the following criteria:

### Evaluation Criteria

| Criterion | Description | Score (1-5) |
|-----------|-------------|-------------|
| **Clarity** | Does the SKILL.md clearly explain what the skill does and how to use it? | 1-5 |
| **Completeness** | Does the skill address all trigger patterns and edge cases? | 1-5 |
| **Correctness** | Does the skill follow best practices and avoid errors? | 1-5 |

### Evaluation Process

1. Construct a sample input matching each trigger pattern.
2. Simulate skill execution against the sample input.
3. Score each criterion (1-5, where 3 = minimum acceptable).
4. If any criterion scores below 3, revise the skill and re-test.
5. Record evaluation results to `.pmcro/trails/evaluations/{skill-name}-eval.jsonl`.

---

## Optimize Triggers and Description

### Description Optimization

1. Review the current description in `manifest.json`. Is it under 120 characters?
2. Remove jargon: avoid "utilize", "leverage", "facilitate". Use direct verbs.
3. Add specificity: include the output format or deliverable.
4. Apply the **output contract** principle: describe exactly what the skill produces.

### Trigger Optimization

1. Ensure each trigger string is distinctive and unlikely to match unintended requests.
2. Prefer short, natural phrases over complex regex patterns when possible.
3. If a single trigger matches multiple distinct intents, split it into separate triggers.
4. Order triggers from most specific to most general.

---

## Quality Rules

### Imperative Voice

Write all instructions, execution steps, and evaluation criteria in **imperative mood**. Use direct commands: "Create the directory", "Write manifest.json", "Verify the file exists", "Test the skill", "Record the result". Avoid passive constructions like "the file should be created" or "the skill is tested".

### Progressive Disclosure

Structure information from **general to specific**:

1. **Overview** — High-level purpose first.
2. **Capture Intent** — How to scope the task before acting.
3. **Step-by-step details** — Procedural knowledge.
4. **Optimization and edge cases** — Advanced guidance.
5. **Reference material** — Schemas, examples, tables.

Each section should make sense when read in isolation while building on the previous section.

### Theory of Mind

Anticipate the reader's state of knowledge at each step:

- **New users** — Provide complete commands, full file contents, and explicit directory paths.
- **Intermediate users** — Offer optimization guidelines and trigger refinement patterns.
- **Advanced users** — Include evaluation criteria, versioning conventions, and index registration details.

Signal context shifts explicitly: "If you are creating a new skill, follow Section A. If you are optimizing an existing skill, skip to Section B."

### Output Contracts

Every skill must specify its **output contract** — the precise deliverable the skill produces:

- **File paths**: List every file the skill creates or modifies.
- **File formats**: Specify JSON structure, Markdown sections, or YAML schema.
- **Content requirements**: Minimum required fields, naming conventions, and formatting rules.
- **Side effects**: Note any index updates, trail entries, or registry changes.

Example output contract for this skill:

| Deliverable | Path | Format | Required Content |
|-------------|------|--------|-----------------|
| Skill manifest | `.agents/skills/{name}/manifest.json` | JSON | name, version, description, triggers, type |
| Skill guide | `.agents/skills/{name}/SKILL.md` | Markdown (ATX) | Overview, Capture Intent, Trigger Definitions, Execution Guide, Optimization Guidelines, Quality Rules |
| Index entry | `.agents/skills/index.json` | JSON | Skill name, version, manifest path, triggers, installed timestamp |

---

## Skill Index Registration

Upon successful creation, register the skill in the instance's skill index. The index lives at `.agents/skills/index.json`.

### Index Entry Format

```json
{
  "name": "skill-creator",
  "version": "2026.07.10",
  "manifestPath": ".agents/skills/skill-creator/manifest.json",
  "triggers": [
    "create skill",
    "skill creator",
    "optimize skill",
    "draft skill"
  ],
  "installedAt": "2026-07-10T14:08:00Z"
}