#!/usr/bin/env python3
"""Forest Symphony T-B: PMD sequential source / anatomy gate (offline, zero provider calls).

Verifies private, real original PMD southeast-45-degree source pixels and prior
derivative comparison images. Candidate plans cannot skip source IDs, change
species body plans, or claim owner art acceptance from pixel checks.
This tool NEVER generates art or contacts PixelLab.
"""
from __future__ import annotations
import argparse, hashlib, io, json, re, zipfile
from pathlib import Path
from PIL import Image

G11_SHA = "47fbdaa5c7088c5612c4e53d262a70e64017e965160bd50e55fcf5c12dfe921f"
REQUIRED_LOCKS = frozenset((
    "pmd_number", "base_species_quadruped", "relative_body_head_proportion",
    "limb_count_and_attachment", "growth_rank", "original_SE45_view",
    "relative_size_rank", "foot_anchor"))
MANDATORY_PLAN_KEYS = (
    "pmd_id", "original_pmd_source_sha256", "native_direction_row",
    "body_plan", "limb_count", "retain_structural_features", "new_attribute",
    "new_color_design", "remodeled_back_feature",
    "owner_art_approved", "generation_job_id")

def sha(data: bytes) -> str: return hashlib.sha256(data).hexdigest()

def rgba(data: bytes) -> Image.Image:
    return Image.open(io.BytesIO(data)).convert("RGBA")

def verify_sources(catalog: dict, archive: Path, derivatives_dir: Path) -> dict:
    assert catalog["schema"] == "FS_TB_PMD_SEQUENTIAL_REDESIGN_SOURCE_CONTRACT_V1"
    verified = catalog["verified_ids"]
    completed = catalog.get("completed_ids", [])
    assert completed == verified[:len(completed)], "Out-of-order PMD completion"
    if len(completed) < len(verified):
        assert catalog["next_id"] == verified[len(completed)], "PMD next ID must advance one-by-one"
    else:
        assert catalog["next_id"] == f"PMD{int(verified[-1][3:])+1:04d}", "Next unverified PMD ID pending source"
    assert archive.is_file() and sha(archive.read_bytes()) == G11_SHA
    species = catalog["species"]
    assert len(species) == 3
    assert [s["pmd_id"] for s in species] == ["PMD0001","PMD0002","PMD0003"]
    sizes = []
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None and len(z.namelist()) == 742
        direction = json.loads(z.read("KEYFRAME_45DEGREE_MAP.json"))
        assert json.loads(z.read("G11_SE45_QA.json"))["new_correct"]["direction_row"] == 1
        for i, spec in enumerate(species,1):
            old = spec["source"]; prev = spec["prior_derivative"]
            n = spec["pmd_id"]
            assert old["path"] == f"SE45_KEYFRAMES/{n}/Idle/ORIGINAL_{n}_Idle_1.png"
            pixel = z.read(old["path"])
            assert sha(pixel) == old["sha256"]
            im = rgba(pixel)
            assert list(im.size) == old["frame_size"]
            assert list(im.getchannel("A").getbbox()) == old["rgba_bbox"]
            assert old["native_direction_row"] == 1 and old["facing"] == "SE45"
            assert any(m["species"] == f"{i:04d}" and m["action"]=="Idle"
                and m["direction_row"]==1 and m["direction_angle_degrees"]==45
                for m in direction)
            assert REQUIRED_LOCKS.issubset(set(spec["locked"]))
            f = derivatives_dir / prev["path"]
            assert f.is_file() and sha(f.read_bytes())==prev["sha256"]
            canvas = rgba(f.read_bytes())
            bbox = canvas.getchannel("A").getbbox()
            assert list(canvas.size)==[64,64] and list(bbox)==prev["rgba_bbox"]
            sizes.append((bbox[2]-bbox[0],bbox[3]-bbox[1]))
    assert [x[0] for x in sizes] == sorted(x[0] for x in sizes)
    assert [x[1] for x in sizes] == sorted(x[1] for x in sizes)
    return {"result":"SOURCE_AND_ORDER_PASS","original_G11_sha256":G11_SHA,
            "verified_ids":catalog["verified_ids"],"reference_body_sizes_64px":sizes,
            "generations":0,"new_art":"NONE"}

def check_candidate_plan(plan: dict, catalog: dict, expected_id: str) -> dict:
    """Pure preflight: checks identity locks, NOT perceptual similarity."""
    assert re.fullmatch(r"PMD[0-9]{4}",expected_id)
    assert expected_id in catalog["verified_ids"], "PMD number source unverified; STOP"
    assert expected_id == catalog["next_id"], "PMD numbering gap/out-of-order"
    assert all(k in plan for k in MANDATORY_PLAN_KEYS)
    assert plan["pmd_id"] == expected_id
    source = next(s for s in catalog["species"] if s["pmd_id"]==expected_id)
    assert plan["original_pmd_source_sha256"]==source["source"]["sha256"]
    assert plan["native_direction_row"]==1
    assert plan["body_plan"]=="quadruped" and plan["limb_count"]==4
    assert set(("head","torso","four_legs","dorsal_mass","tail_or_source_rear_outline")).issubset(
        set(plan["retain_structural_features"]))
    assert plan["new_attribute"] and plan["new_color_design"] and plan["remodeled_back_feature"]
    assert plan["owner_art_approved"] is False
    assert plan["generation_job_id"] is None
    return {"result":"PLAN_ONLY_PREGEN_SOURCE_LOCK_PASS","art_qa":"NOT_RUN",
            "godot_native":"NOT_RUN","paid_provider_jobs":0,"pmd_id":expected_id}

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--catalog",type=Path,required=True)
    p.add_argument("--native-zip",type=Path,required=True)
    p.add_argument("--derivatives-dir",type=Path,required=True)
    p.add_argument("--plan",type=Path)
    p.add_argument("--expected-id",default="PMD0001")
    a=p.parse_args()
    catalog=json.loads(a.catalog.read_text(encoding="utf-8"))
    result=verify_sources(catalog,a.native_zip,a.derivatives_dir)
    if a.plan:
        plan=json.loads(a.plan.read_text(encoding="utf-8"))
        result["plan"]=check_candidate_plan(plan,catalog,a.expected_id)
        # Harden critical negative cases before any paid generation.
        broken=dict(plan);broken["pmd_id"]="PMD0002"
        try:check_candidate_plan(broken,catalog,a.expected_id)
        except AssertionError:pass
        else:raise AssertionError("PMD ID skip bypassed gate")
        broken=dict(plan);broken["limb_count"]=2
        try:check_candidate_plan(broken,catalog,a.expected_id)
        except AssertionError:pass
        else:raise AssertionError("anatomy gate bypassed")
        try:check_candidate_plan(plan,catalog,"PMD0004")
        except AssertionError:pass
        else:raise AssertionError("unknown next source bypassed")
        result["negative_gate_tests"]="3/3 PASS"
    print("FS_TB_PMD_SEQUENTIAL_REAL_SOURCE_GATE_PASS",json.dumps(result,ensure_ascii=False))

if __name__ == "__main__": main()