---
name: pmcro-partner-onboarding
description: Use this skill to onboard partners or coworkers to the PMCR-O (Plan-Make-Check-Reflect) system. It guides them through repo cloning, environment setup, and running Proving Prompts to verify the loop is functioning correctly.
---

# PMCR-O Partner Onboarding Skill

Use this skill whenever a human partner, coworker, or new team member needs to be introduced to the PMCR-O Strange Loop.

## Onboarding Workflow

### 1. Introduction
Explain the PMCR-O loop (Plan → Make → Check → Reflect) and how agents self-correct through recursive frames.

### 2. Setup
Guide the partner through:
- Cloning the `pmcro-template` repository  
- Running the setup script  
- Initializing `.pmcro` directories  
- Opening the workspace in VS Code with Cline enabled  

### 3. Verification
Provide the “Smoke Test” prompt:
> /pmcro-cycle SeedIntent: Run a smoke test. Create a file called 'ONBOARDING_SUCCESS.md'. Verify it exists. Seal the trail.

Explain the HIL gate and why TYPE1 actions require approval.

### 4. Proving Prompts
Offer deeper proving prompts:
- Lawn-Mowing Test  
- Adversarial Test  
- Domain Bootstrap  

These demonstrate the loop’s ability to handle logic, detect misclassification, and audit real project structure.

## Triggering Contexts
- “I’m new here, how do I start.”
- “Help my coworker set this up.”
- “What is a proving prompt.”
- “Let’s test the HIL gate.”

## References
- `references/quickstart.md` — step-by-step setup guide  
- `references/onboarding-checklist.md` — partner success list  
- `references/proving-prompts.md` — proving prompt library  

## Constraints
- **HIL Focus**: TYPE1 actions always require human approval.  
- **No YOLO**: YOLO mode is forbidden during onboarding.  
- **Safety First**: Adversarial tests must be run only after the partner understands TYPE1/TYPE2 classification.  
