"""Dependency-free baseline comparison harness."""
from dataclasses import dataclass
from hashlib import sha256
import json
from typing import Any
VALID_STATES = {"know", "believe", "suspect", "dont_know_yet"}
@dataclass
class Run:
    run_id: str
    condition: str
    scenario_id: str
    output: dict[str, Any]
    evidence: list[str]
    limitations: list[str]
    sealed: bool = False
    digest: str | None = None
    def seal(self):
        payload = {"run_id":self.run_id,"condition":self.condition,"scenario_id":self.scenario_id,"output":self.output,"evidence":self.evidence,"limitations":self.limitations}
        self.digest = sha256(json.dumps(payload,sort_keys=True,separators=(",",":")).encode()).hexdigest()
        self.sealed = True
        return self
def validate_run(run):
    errors=[]
    for key in ("run_id","condition","scenario_id"):
        if not getattr(run,key).strip(): errors.append(f"{key} is required")
    if str(run.output.get("recognition_state","")).lower() not in VALID_STATES: errors.append("invalid recognition_state")
    if not isinstance(run.evidence,list): errors.append("evidence must be a list")
    if not isinstance(run.limitations,list): errors.append("limitations must be a list")
    if run.sealed and not run.digest: errors.append("sealed run must have a digest")
    return errors
def compare_runs(a,b):
    errors=validate_run(a)+validate_run(b)
    if errors: return {"status":"invalid","errors":errors}
    return {"status":"descriptive_pair","same_scenario":a.scenario_id==b.scenario_id,"conditions":[a.condition,b.condition],"recognition_states":[a.output.get("recognition_state"),b.output.get("recognition_state")],"changed_fields":sorted(k for k in set(a.output)|set(b.output) if a.output.get(k)!=b.output.get(k)),"interpretation_limit":"A single pair cannot establish general effectiveness or causality.","sealed_digests":[a.digest,b.digest]}
