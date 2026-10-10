"""Append-only JSONL registry with provenance-aware minimum schema."""
import json
from pathlib import Path
from datetime import datetime, timezone
REQUIRED=("run_id","scenario_id","condition","status","recognition_state","evidence","limitations","provenance")
STATES={"Know","Believe","Suspect","Don't Know Yet"}
def validate_record(record):
    errors=[f"missing required field: {key}" for key in REQUIRED if key not in record]
    if record.get("recognition_state") not in STATES: errors.append("recognition_state must preserve one of the four knowing states")
    if not isinstance(record.get("evidence"),list): errors.append("evidence must be a list")
    if not isinstance(record.get("limitations"),list): errors.append("limitations must be a list")
    if not isinstance(record.get("provenance"),dict): errors.append("provenance must be an object")
    return errors
def append_record(path,record):
    errors=validate_record(record)
    if errors: raise ValueError("; ".join(errors))
    item=dict(record); item.setdefault("recorded_at",datetime.now(timezone.utc).isoformat())
    target=Path(path); target.parent.mkdir(parents=True,exist_ok=True)
    with target.open("a",encoding="utf-8") as stream: stream.write(json.dumps(item,sort_keys=True)+"\\n")
    return item
