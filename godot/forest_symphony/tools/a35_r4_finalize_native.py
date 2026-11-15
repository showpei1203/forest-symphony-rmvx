#!/usr/bin/env python3
"""Seal A35 R4 owner-only native Godot art QA. GitHub gets code only."""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image
GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
SOURCE="FS_A35_R4_ORGANIC_SOURCE_PRIVATE_20261115.zip"
TARGET="FS_A35_R4_ORGANIC_NATIVE_QA_PRIVATE_20261115.zip"
SHOTS=[
"A35_R4_ORGANIC_DAY_NATIVE.png",
"A35_R4_ORGANIC_DUSK_NATIVE.png",
"A35_R4_ORGANIC_NIGHT_NATIVE.png",
"A35_R4_R3_BASELINE_NATIVE.png",
"A35_R4_ART_CANDIDATE_NATIVE.png",
"A35_R4_ACTOR_BEHIND_NATIVE.png",
"A35_R4_ACTOR_FRONT_NATIVE.png"
]
LOGS={
"R4_NATIVE_STDOUT.txt":"FS A35 R4 GODOT PASS",
"R4_NAV_STDOUT.txt":"A35 R4 NATIVE PHYSICAL NAV PASS 8/8",
"R4_GPU_STDOUT.txt":"three-phase capture PASS",
"R4_AB_GPU_STDOUT.txt":"4/4 stable GPU A/B + actor depth frame capture PASS"
}
def digest(data):
    return hashlib.sha256(data).hexdigest()
def read_log(path):
    data=path.read_bytes()
    if data.startswith(b"\xff\xfe") or data.startswith(b"\xfe\xff"):
        return data.decode("utf-16",errors="replace")
    return data.decode("utf-8-sig",errors="replace")
def seal(root,work):
    project=work/"godot_project"
    with zipfile.ZipFile(root/SOURCE) as z:
        if z.testzip() is not None:raise ValueError("source ZIP CRC fail")
        members={name:z.read(name) for name in z.namelist()}
    if digest(members["private_assets/ground_only.png"])!=GROUND:
        raise ValueError("original Ground changed")
    original_r2=members["scenes/a35_r2_new_species_scene.tscn"]
    original_r3=members["scenes/a35_r3_hd2d_layered_scene.tscn"]
    for name,needle in LOGS.items():
        log=read_log(work/name)
        if needle not in log:raise ValueError("missing native PASS log: "+name)
        members["qa_a35/A35_R4_"+name]=log.encode()
    for shot in SHOTS:
        file=project/"qa_a35"/shot
        with Image.open(file) as im:
            if im.size!=(1280,928):raise ValueError("incorrect native screenshot size: "+shot)
        members["qa_a35/"+shot]=file.read_bytes()
    roi_file=project/"qa_a35"/"A35_R4_NATIVE_AB_ROI_ACTOR_REPORT.json"
    roi=json.loads(roi_file.read_text(encoding="utf-8"))
    if roi["outside_union_tree_roi"]!=0 or roi["changed_tree_owners"]!=32:
        raise ValueError("native tree ROI regression")
    if roi["front_back_gate"]!="PASS_PARTIAL_FOLIAGE":
        raise ValueError("native actor depth regression")
    members["qa_a35/A35_R4_NATIVE_AB_ROI_ACTOR_REPORT.json"]=roi_file.read_bytes()
    members["tests/test_a35_r4_native.gd"]=(project/"tests"/"test_a35_r4_native.gd").read_bytes()
    members["tests/capture_a35_r4_ab_actor_native.gd"]=(project/"tests"/"capture_a35_r4_ab_actor_native.gd").read_bytes()
    members["tools/a35_r4_organic_build.py"]=(work/"a35_r4_organic_build.py").read_bytes()
    members["tools/a35_r4_native_roi_qa.py"]=(work/"a35_r4_native_roi_qa.py").read_bytes()
    members["tools/a35_r4_finalize_native.py"]=(work/"a35_r4_finalize_native.py").read_bytes()
    report={
        "phase":"A35 R4 source-derived organic grove",
        "engine":"Godot 4.7.2 stable RX 6700 XT OpenGL 3.3",
        "source":"PASS; 187 PAR, 32 changed, 155 retained, Ground SHA immutable",
        "navigation":"PASS 8/8 gates and 4/4 routes; 0 blocked protected roads",
        "native_gpu":"PASS 7/7 original 1280x928 frames",
        "tree_roi":"PASS 143456 changes inside, 0 outside",
        "occlusion":"PASS_PARTIAL_FOLIAGE: rear 184 vs front 576 visible pixels (31.94%)",
        "art":"HOLD: sources remain similar; small sparse conifers and no true light occluders or depth-of-field",
        "original_ground_sha256":GROUND,
        "original_R3_scene_sha256":digest(original_r3),
        "source_zip_sha256":digest((root/SOURCE).read_bytes())
    }
    members["qa_a35/A35_R4_NATIVE_QA_SUMMARY.json"]=(json.dumps(report,ensure_ascii=False,indent=2)+"\n").encode()
    failures=members["docs/A35_R4_FAILURE_LOG.md"].decode()
    failures+="\n- First Godot native test treated unchanged, collision-disabled well as a missing collider. Fixed to compare null-shape and disabled state; native rerun PASS.\n"
    failures+="- First Godot GPU A/B test failed GDScript type inference for file path. Used explicitly typed String; native capture 4/4 PASS.\n"
    failures+="- FIR rear actor has 184 visible pixels vs 576 when in front. Transparent foliage legitimately permits limited visibility. A solid dark undercoat concept was rejected visually; final test requires at least 60 percent relative rear occlusion. ART still HOLD.\n"
    failures+="- R4 source variants reuse mature FS artwork rather than creating genuinely different full tree species; cannot claim art seal.\n"
    members["docs/A35_R4_FAILURE_LOG.md"]=failures.encode()
    handoff=members["docs/A35_R4_HANDOFF.md"].decode()
    handoff+="\n## Native Godot QA final\n"
    handoff+="- Godot source PASS, navigation 8/8 and 4/4 PASS; true original GPU 7/7 PASS. Tree-only ROI 143456 inside, 0 outside.\n"
    handoff+="- Rear actor 184/front 576, PARTIAL_FOLIAGE depth PASS. Full original Ground / R2 / R3 immutable. ART HOLD; no true 3D DOF or real light occluders yet.\n"
    handoff+="- All native screenshots, logs, QA and repaired test sources in this owner-only ZIP. Do not publish private art on GitHub.\n"
    members["docs/A35_R4_HANDOFF.md"]=handoff.encode()
    prev=members.get("CURRENT_HANDOFF.md",b"").decode()
    members["CURRENT_HANDOFF.md"]=(
        "# Forest Symphony | A35 R4 | Official native QA / ART HOLD | 2026-11-15\n"
        "- 8 source-based coherent foliage variants, 32 updated and 155 preserved, 187 PAR. Ground and R2/R3 immutable.\n"
        "- Native PASS: source and collision; 8/8 navigation, 4/4 routes; 7 original GPU captures; tree ROI 143456 inside, 0 outside.\n"
        "- Rear actor 184/front 576 visible pixels through naturally sparse foliage. Partial-occlusion PASS, botanical art diversity HOLD.\n"
        "- Full private release: "+TARGET+". Never overwrite A36C or older sealed releases.\n"
        "- Next: more distinctive species-specific painted trees and foliage hierarchy, then Ground3 after art approval.\n\n---\n"
        +prev
    ).encode()
    output=root/TARGET
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for name,data in members.items():z.writestr(name,data)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:raise ValueError("final ZIP CRC fail")
        if digest(z.read("private_assets/ground_only.png"))!=GROUND:
            raise ValueError("final ground mismatch")
        if z.read("scenes/a35_r2_new_species_scene.tscn")!=original_r2 or z.read("scenes/a35_r3_hd2d_layered_scene.tscn")!=original_r3:
            raise ValueError("old scenes mutated")
    print(json.dumps({"file":str(output),"members":len(members),"bytes":output.stat().st_size,
        "sha256":digest(output.read_bytes()),"report":report},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    seal(Path(a.root),Path(a.work))
