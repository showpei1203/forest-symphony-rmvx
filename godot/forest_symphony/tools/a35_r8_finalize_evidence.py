#!/usr/bin/env python3
"""Forest Symphony A35 R8 official native 2D canopy-shadow evidence seal.

Artifacts stay owner-only Google Drive. This evidence archive is a compact
verifiable QA companion, NOT an independent replacement for the complete
176 MB R8 Godot source ZIP. Never upload private PNGs to public GitHub.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image

BASE_NAME="FS_A35_R8_CANOPY_SOURCE_PRIVATE_20261116.zip"
EVIDENCE_NAME="FS_A35_R8_CANOPY_NATIVE_EVIDENCE_PRIVATE_20261116.zip"
GROUND_SHA="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
SCREENSHOTS=["A35_R8_CANOPY_SHADOW_OFF_NATIVE.png","A35_R8_CANOPY_SHADOW_ON_NATIVE.png"]
LOGS={
"R8_SOURCE_FINAL_STDOUT.log":"A35 R8 GODOT NATIVE PASS",
"R8_NAV_FINAL_STDOUT.log":"A35 R8 NATIVE PHYSICAL NAV PASS 8/8",
"R8_GPU_FINAL_STDOUT.log":"A35 R8 REAL GODOT CANOPY GPU 2/2 PASS",
"R8_BENCH_STDOUT.log":"A35 R8 native wall-frame probe PASS"
}
ORIGINALS=[
 "scenes/a35_r7_shadow_study_scene.tscn",
 "scenes/a35_r8_canopy_shadow_scene.tscn",
 "scripts/a35_r7_shadow_study.gd",
 "scripts/a35_r8_canopy_shadow.gd",
 "data/a35_r8_canopy_profiles.json",
 "tests/test_a35_r8_native.gd",
 "tests/test_a35_r8_navigation.gd",
 "tests/capture_a35_r8_canopy_native.gd",
 "qa_a35/A35_R8_SOURCE_QA.json"
]
TOOLS=[
"a35_r8_canopy_extract.py",
"a35_r8_build.py",
"a35_r8_pixel_qa.py",
"a35_r8_finalize_evidence.py"
]
DOCS=["A35_R8_NATIVE_HANDOFF_20261116.md",
      "A35_R8_FAILURE_LOG_20261116.md",
      "CURRENT_HANDOFF.md"]
def sha(b):return hashlib.sha256(b).hexdigest()
def decode(path:Path):
    b=path.read_bytes()
    if b.startswith((b"\xff\xfe",b"\xfe\xff")):return b.decode("utf-16",errors="replace")
    return b.decode("utf-8-sig",errors="replace")

def package(root:Path,work:Path):
    project=work/"godot_project"
    base=root/BASE_NAME
    with zipfile.ZipFile(base) as z:
        if z.testzip():raise ValueError("Original R8 ZIP CRC FAIL")
        members={k:z.read(k) for k in ORIGINALS}
        ground=sha(z.read("private_assets/ground_only.png"))
        r7_sha=sha(z.read("scenes/a35_r7_shadow_study_scene.tscn"))
    if ground!=GROUND_SHA or r7_sha!="45553197527883088bde69d11b8210d5d6fc94f6632378be36353c9378b05e14":
        raise ValueError("Ground or sealed R7 scene altered")
    for file,needle in LOGS.items():
        val=decode(work/file)
        if needle not in val:raise ValueError("Missing native Godot test proof: "+file)
        members["qa_a35/logs/"+file]=val.encode("utf-8")
    for file in SCREENSHOTS:
        p=project/"qa_a35"/file
        with Image.open(p) as img:
            if img.size!=(1280,928):raise ValueError("Not native 1280x928 image "+file)
        members["qa_a35/original_gpu/"+file]=p.read_bytes()
    qa=json.loads((project/"qa_a35"/"A35_R8_CANOPY_GPU_PIXEL_QA.json").read_text(encoding="utf-8"))
    perf=json.loads((project/"qa_a35"/"A35_R8_GODOT_WALL_FRAME_BENCH.json").read_text(encoding="utf-8"))
    if qa["changed_pixels"]!=122342 or qa["changed_outside_lamp"]!=0 or not qa["canopy_shadow_visible"]:
        raise ValueError("R8 original GPU shadow proof invalid")
    if perf["tree_canopy_nodes"]!=175 or perf["tree_trunk_nodes"]!=175 or len(perf["samples"])!=6:
        raise ValueError("R8 actual benchmark incomplete")
    members["qa_a35/A35_R8_CANOPY_GPU_PIXEL_QA.json"]=(json.dumps(qa,indent=2)+"\n").encode()
    members["qa_a35/A35_R8_GODOT_WALL_FRAME_BENCH.json"]=(json.dumps(perf,indent=2)+"\n").encode()
    for name in TOOLS:
        members["tools/"+name]=(work/name).read_bytes()
    members["tests/a35_r8_native_frame_bench.gd"]=(project/"tests"/"a35_r8_native_frame_bench.gd").read_bytes()
    for name in DOCS:
        members["docs/"+name]=(work/name).read_bytes()
    status={
      "phase":"FS A35 R8 source-derived canopy shadow, Godot native QA",
      "engine":"Official Godot 4.7.2, AMD RX 6700 XT, OpenGL 3.3",
      "full_private_R8_zip":BASE_NAME,
      "full_private_R8_zip_SHA256":sha(base.read_bytes()),
      "R7_scene_SHA256":r7_sha,"Ground_SHA256":ground,
      "tree_sprite_source_profiles":29,
      "tree_trunks":175,"canopy_occluders":175,"total_canopy_vertices":5378,
      "source":"PASS, 187 independent PAR, 175 trunks+175 canopy, original scene+collision SHA unchanged",
      "physics_nav":"PASS 8/8, 4/4 routes, 0 protected road newly blocked",
      "original_native_gpu":"PASS 2 original 1280x928 frames OFF/ON, 122342 altered inside lamp radius, 0 outside",
      "wall_frame_ms_off":perf["off_average_wall_ms"],
      "wall_frame_ms_on":perf["on_average_wall_ms"],
      "wall_frame_limit":"only indicative engine wall-frame, not GPU-alone profiling",
      "art":"HOLD; exact source-inspired polygons, not complete 3D DOF/volumetric/leaf-transmission",
      "privacy":"private user Drive only; GitHub text source/docs only"
    }
    members["R8_QA_RELEASE_MANIFEST.json"]=(json.dumps(status,ensure_ascii=False,indent=2)+"\n").encode()
    members["README_NOT_STANDALONE.txt"]=(
       "This is native QA evidence from the R8 Godot project, not the standalone full project.\n"
       "Full owner-only R8 project: "+BASE_NAME+"\n"
       "Original source ZIP SHA256: "+status["full_private_R8_zip_SHA256"]+"\n"
       "Use that ZIP to play/inspect. All private source art stays in owner-only Drive.\n"
    ).encode()
    out=root/EVIDENCE_NAME
    with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for path,b in members.items():z.writestr(path,b)
    with zipfile.ZipFile(out) as z:
        if z.testzip():raise ValueError("R8 final evidence CRC failure")
        if z.read("qa_a35/original_gpu/"+SCREENSHOTS[1])!=members["qa_a35/original_gpu/"+SCREENSHOTS[1]]:
            raise ValueError("Original Godot GPU picture changed")
    print(json.dumps({"file":str(out),"members":len(members),
         "bytes":out.stat().st_size,"sha256":sha(out.read_bytes()),"QA":status},ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True);p.add_argument("--work",required=True)
    a=p.parse_args()
    package(Path(a.root),Path(a.work))
