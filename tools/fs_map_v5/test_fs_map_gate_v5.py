import json, copy
from pathlib import Path
from fs_map_gate_v5 import audit, GATE_ORDER, make_current
r=Path(__file__).resolve().parent
stage={"stage_id":"SYNTHETIC_CONTRACT_TEST_ONLY","engine":"RPG Maker VX (RGSS2)",
 "ground_default_walkable":True,"separate_terrain_exceptions":True,
 "single_source_manifest":True,"sealed_original_untouched":True,
 "ground_source_mode":"coherent_ground_new_source","object_integrity":"SOURCE_COMPLETE",
 "gates":{x:{"status":"PASS","evidence":["synthetic_fixture_only_NOT_REAL_APPROVAL"]} for x in GATE_ORDER}}
results={}
def test(name,obj,expect):
    actual=audit(obj)
    assert actual["state"]==expect,(name,actual)
    results[name]={"state":actual["state"],"pass":True,"errors":actual["errors"]}
test("contract_declaration_only_not_art_pass",stage,"DECLARED_COMPLETE_AWAITING_REAL_HUMAN_AND_ENGINE_EVIDENCE")
s=copy.deepcopy(stage);s["gates"]["P2_ground_only_visual"]["status"]="FAIL"
test("art_fail_not_overridden_by_native_pass",s,"BLOCKED")
s=copy.deepcopy(stage);s["gates"]["P7_user_human_visual"]["evidence"]=[]
test("fake_human_without_evidence",s,"BLOCKED")
s=copy.deepcopy(stage);s["ground_default_walkable"]=False
test("road_only_collision_forbidden",s,"BLOCKED")
s=copy.deepcopy(stage);s["single_source_manifest"]=False
test("independent_layer_authority_forbidden",s,"BLOCKED")
s=copy.deepcopy(stage);s["object_integrity"]="ROI_ONLY"
test("ROI_not_complete_flora_object",s,"BLOCKED")
s=copy.deepcopy(stage);s["engine"]="Godot"
test("do_not_migrate_VX_to_Godot",s,"BLOCKED")
real=make_current()
assert real["state"]=="BLOCKED_VISUAL"
results["real_80tile_9flag_actorscale_regression"]={"state":real["state"],"pass":True}
out=r/"V5_REGRESSION_TESTS.json"
out.write_text(json.dumps({"passed":len(results),"expected":8,"tests":results,"disclaimer":"Contract logic only. Synthetic pass is not real art approval."},indent=2,ensure_ascii=False),encoding="utf-8")
print(f"V5_REGRESSION_PASS={len(results)}/8")
