import importlib.util
import tempfile
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def load(name,path):
    spec=importlib.util.spec_from_file_location(name,ROOT/path); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); return module
harness=load("harness",Path("products/signal-inforwells-pmcro/skills/signal-inforwells-harness/harness.py"))
registry=load("registry",Path("products/signal-inforwells-pmcro/skills/signal-inforwells-registry/registry.py"))
class HarnessTests(unittest.TestCase):
    def test_seal_digest_is_deterministic(self):
        args=("r1","baseline","s1",{"recognition_state":"know"},[],[])
        self.assertEqual(harness.Run(*args).seal().digest,harness.Run(*args).seal().digest)
    def test_invalid_recognition_state_fails(self):
        self.assertTrue(harness.validate_run(harness.Run("r","base","s",{"recognition_state":"certain"},[],[])))
    def test_pair_is_descriptive_not_causal(self):
        a=harness.Run("a","baseline","s",{"recognition_state":"believe"},[],[]).seal()
        b=harness.Run("b","framework","s",{"recognition_state":"dont_know_yet"},[],[]).seal()
        result=harness.compare_runs(a,b)
        self.assertEqual(result["status"],"descriptive_pair")
        self.assertIn("cannot establish",result["interpretation_limit"])
class RegistryTests(unittest.TestCase):
    def record(self):
        return {"run_id":"R1","scenario_id":"S1","condition":"baseline","status":"experimental","recognition_state":"Don't Know Yet","evidence":["fixture"],"limitations":["single case"],"provenance":{"source":"fixture","method":"manual"}}
    def test_append_valid_record(self):
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/"runs.jsonl"; registry.append_record(path,self.record())
            self.assertEqual(len(path.read_text().splitlines()),1)
    def test_missing_provenance_rejected(self):
        record=self.record(); del record["provenance"]
        self.assertTrue(registry.validate_record(record))
if __name__=="__main__": unittest.main()
