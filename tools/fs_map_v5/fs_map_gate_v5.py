#!/usr/bin/env python3
# V5 gate checker: READ ONLY. Does not modify any FS game or test project.
import argparse, json, hashlib, sys
from pathlib import Path
from datetime import datetime, timezone

GATE_ORDER = [
  "P0_authority_source_rights",
  "P1_actor_style_layout",
  "P2_ground_only_visual",
  "P3_independent_objects_complete",
  "P4_ownership_contact_collision",
  "P5_deterministic_compile",
  "P6_native_vx_and_godot",
  "P7_user_human_visual",
]

def audit(stage):
    errors, gates = [], {}
    if not isinstance(stage.get("gates"), dict):
        return {"state":"BLOCKED","errors":["missing gates object"],"gates":{}}
    for gate in GATE_ORDER:
        value = stage["gates"].get(gate)
        if not isinstance(value, dict):
            gates[gate] = "BLOCKED_NO_RECORD"
            errors.append(f"{gate}: missing status/evidence")
            continue
        status = value.get("status", "PENDING")
        evidence = value.get("evidence", [])
        evidence_ok = isinstance(evidence, list) and bool(evidence) and all(isinstance(v,str) and v.strip() for v in evidence)
        # This is a declaration validator, never a substitute for native screenshots or the user's review.
        if status != "PASS":
            gates[gate] = status
            errors.append(f"{gate}: {status} (requires PASS)")
        elif not evidence_ok:
            gates[gate] = "BLOCKED_NO_EVIDENCE"
            errors.append(f"{gate}: PASS without evidence is forbidden")
        else: gates[gate] = "PASS"
    if stage.get("engine") != "RPG Maker VX (RGSS2)":
        errors.append("Engine mismatch: preserve original VX; Godot is isolated adapter only")
    if stage.get("ground_default_walkable") is not True:
        errors.append("Ground must be walkable by default; exceptions water/holes/void specified separately")
    if stage.get("separate_terrain_exceptions") is not True:
        errors.append("Terrain exceptions and PAR contact must be separate collision layers")
    if stage.get("single_source_manifest") is not True:
        errors.append("Ground/PAR/occlusion/collision must compile from one canonical manifest")
    if stage.get("sealed_original_untouched") is not True:
        errors.append("sealed original preservation not confirmed")
    if stage.get("ground_source_mode") not in ("coherent_ground_new_source", "verified_clean_existing_ground_source"):
        errors.append("No coherent or verified clean Ground provenance; donor quilt cannot be promoted")
    if stage.get("object_integrity") != "SOURCE_COMPLETE":
        errors.append("Source object has not passed complete-silhouette boundary/attachment verification")
    return {"schema":"fs-map-v5-gates","stage_id":stage.get("stage_id","unknown"),
            "state":"DECLARED_COMPLETE_AWAITING_REAL_HUMAN_AND_ENGINE_EVIDENCE" if not errors else "BLOCKED",
            "gates":gates,"errors":errors,"verified_at_utc":datetime.now(timezone.utc).isoformat()}

def make_current():
    root = Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
    task = root/"COLD_F2_G5R3_ACTOR_SCALE_20261026"
    src = task/"F2_G5R3_ACTOR_SCALE_TILE_MANIFEST.json"
    rep = root/"reports"/"F2_G5R3_ACTOR_SCALE_RELEASE.json"
    m=json.loads(src.read_text(encoding="utf-8"))
    r=json.loads(rep.read_text(encoding="utf-8"))
    assert m["tile_count"] == len(m["records"]) == 80
    assert m["actor_visible_size"] == [28,32]
    assert m["flagged_flora_tile_count"] == 9
    assert m["flagged_is_screening_roi_not_pixel_matted_object"] is True
    assert m["not_final_PAR_flora"] is True
    assert r["ground_ART"] == "FAIL" and r["human_visual"] == "PENDING"
    checks={
      "actual_vx_actor_verified":True, "source_tile_recompose_zero_diff":m["source_contiguity_pixels_different"]==0,
      "oversized_flora_9_tiles_identified":True, "ground_art_pass":False,
      "actual_semantic_flora_alpha_mask":False, "full_object_untruncated":False,
      "coherent_ground_repair_completed":False,"user_visual_approved":False}
    return {"mode":"read_only_current","project":"FS F2 G5R3","state":"BLOCKED_VISUAL", "checks":checks,
       "next":"F2 G5R4: original full flower source and tight semantic alpha ownership; create coherent clean Ground, actor-scale proof, then GROUND-ONLY Gate before compile",
       "manifest_sha256":hashlib.sha256(src.read_bytes()).hexdigest(),
       "report_sha256":hashlib.sha256(rep.read_bytes()).hexdigest(),
       "unchanged_files":[str(src),str(rep)]}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--current", action="store_true")
    ap.add_argument("--candidate", type=Path)
    ap.add_argument("--out",type=Path,required=True)
    a=ap.parse_args()
    if bool(a.current)==bool(a.candidate):ap.error("choose exactly --current or --candidate")
    try: result=make_current() if a.current else audit(json.loads(a.candidate.read_text(encoding="utf-8")))
    except Exception as e: result={"state":"BLOCKED_ERROR","errors":[type(e).__name__+": "+str(e)]}
    a.out.parent.mkdir(parents=True,exist_ok=True)
    a.out.write_text(json.dumps(result,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print(json.dumps({"state":result["state"],"report":str(a.out),"errors":result.get("errors",[])},ensure_ascii=False))
    return 0 if result["state"]=="DECLARED_COMPLETE_AWAITING_REAL_HUMAN_AND_ENGINE_EVIDENCE" else 2
if __name__=="__main__":sys.exit(main())
