#!/usr/bin/env python3
"""FS T-A source provenance gate: do not fake a layered-paper-doll actor.

This tool is deliberately *not* an art scorer. It blocks generation based on
a single head crop plus programmatically redrawn polygon torso/pants/fists.
The actual permitted 45-degree source image/layer PNG bytes stay owner-private.
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path

REQ=("approved_head","base_body","torso_outfit","near_arm_outfit",
     "far_arm_outfit","legs_pants","feet_boots")

def validate(contract: dict) -> dict:
    layers=contract.get("source_layers")
    checks=[]
    if not isinstance(layers,dict):
        layers={}
        checks.append("MISSING_SOURCE_LAYER_MANIFEST")
    for slot in REQ:
        layer=layers.get(slot)
        if not isinstance(layer,dict):
            checks.append("MISSING_LAYER:"+slot)
            continue
        for prop in ("source_path","source_sha256","frame_index",
                     "source_view","pixel_mapping","layer_alpha_sha256"):
            if not layer.get(prop) and layer.get(prop)!=0:
                checks.append("LAYER_PROVENANCE_MISSING:"+slot+":"+prop)
        if layer.get("source_view")!="SE_3Q_45":
            checks.append("LAYER_WRONG_VIEW:"+slot)
    if not contract.get("reference_full_body_sha256"):
        checks.append("MISSING_APPROVED_FULL_BODY_IDENTITY_SOURCE")
    # A top-level output/body SHA does not prove source-part authenticity.
    if contract.get("generated_by") in ("standalone_polygons","procedural_skeleton_only"):
        checks.append("FORBIDDEN_BODY_RECREATION")
    if contract.get("uses_source_native_attack") is True and contract.get("source_kind")=="LPC_8DIR_DIAGONAL_WALK":
        checks.append("FALSE_WALK_AS_ATTACK_CLAIM")
    if contract.get("weapon_in_body") or contract.get("fx_in_body"):
        checks.append("WEAPON_OR_FX_EMBEDDED")
    # Static declarations cannot substitute on-device image-by-image proof.
    return {"source_schema_complete":not checks,"production_allowed":False,
            "status":"SOURCE_LAYER_BLOCKED" if checks else "STRUCTURE_ONLY_PENDING_PIXEL_AND_ART_QA",
            "missing_or_invalid":checks,
            "requires":["actual owner-private layer files SHA readback",
                        "source-to-pose RGB/alpha ownership map per part",
                        "45-degree A62 full-body 1x artistic review",
                        "separate weapon/FX runtime proof",
                        "native engine and user ART PASS after image review"]}

def reject_r19(manifest: dict) -> dict:
    # Keep the original historical manifest immutable. The audit is a
    # *superseding assessment*, not a rewrite of source history.
    source_claim={
      "source_layers":manifest.get("source_layers"),
      "reference_full_body_sha256":manifest.get("reference_full_body_sha256"),
      "generated_by":"standalone_polygons",
      "source_kind":"A62_HEAD_ONLY_PLUS_NEW_POLYGON_BODY",
      "weapon_in_body":False,
      "fx_in_body":False
    }
    outcome=validate(source_claim)
    assert not outcome["source_schema_complete"]
    assert "MISSING_LAYER:torso_outfit" in outcome["missing_or_invalid"]
    assert "FORBIDDEN_BODY_RECREATION" in outcome["missing_or_invalid"]
    outcome.update({"rejected_revision":"R19A_R19B",
                    "art_status":"ART_REJECTED",
                    "original_R19_source_head_sha256":manifest.get("source_A62_sha256"),
                    "original_R19_sheet_sha256":manifest.get("sheet_sha256"),
                    "explanation":"R19 used approved A62 HEAD crop and drew original-looking torso/waist/arms/boots using Pillow polygon primitives. Its head SHA and empty Weapon/FX do not establish an LPC modular clothing source. It is not the agreed actor paper-doll workflow."})
    return outcome

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--r19-manifest",required=True)
    ap.add_argument("--out")
    args=ap.parse_args()
    record=json.loads(Path(args.r19_manifest).read_text(encoding="utf-8"))
    outcome=reject_r19(record)
    payload=json.dumps(outcome,ensure_ascii=False,indent=2)+"\n"
    if args.out:Path(args.out).write_text(payload,encoding="utf-8")
    print(payload)
    return 0
if __name__=="__main__":
    raise SystemExit(main())
