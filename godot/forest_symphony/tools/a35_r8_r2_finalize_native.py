#!/usr/bin/env python3
"""Forest Symphony A35 R8 R2: full, owner-only native Godot release.

Seals corrected source, original 4 real GPU PNGs, QA logs, benchmark and
source-preserving failure/Handoff. Never uploads private game art to GitHub.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image
GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
R8="27aad890c0c6c8d7f770070738550f0a84fe278c275ae67ce9c94844cdb6d3ad"
SOURCE="FS_A35_R8_R2_BALANCE_SOURCE_PRIVATE_20261116.zip"
OUT="FS_A35_R8_R2_BALANCE_NATIVE_QA_PRIVATE_20261116.zip"
SHOTS=[
"A35_R8_R2_R8_HARD_BASELINE_NATIVE.png",
"A35_R8_R2_R2_ZERO_FILL_NATIVE.png",
"A35_R8_R2_R2_CANOPY_FILL_NATIVE.png",
"A35_R8_R2_R2_TWO_LIGHTS_NATIVE.png"
]
LOGS={
"R2_SOURCE_FIX_OUT.log":"A35 R8 R2 GODOT NATIVE PASS",
"R2_NAV_OUT.log":"A35 R8 R2 NATIVE PHYSICAL NAV PASS 8/8",
"R2_GPU_FIX_OUT.log":"A35 R8 R2 four real Godot source/fill/two-light GPU captures 4/4 PASS",
"R2_BENCH_OUT.log":"A35 R8 R2 real Godot wall-frame benchmark PASS"
}
def sha(b):return hashlib.sha256(b).hexdigest()
def logtext(path):
    a=path.read_bytes()
    if a.startswith((b"\xff\xfe",b"\xfe\xff")):return a.decode("utf-16",errors="replace")
    return a.decode("utf-8-sig",errors="replace")
def seal(root,work):
    project=work/"godot_project"
    source_zip=root/SOURCE
    with zipfile.ZipFile(source_zip) as z:
        if z.testzip():raise ValueError("Corrected R8 R2 candidate CRC invalid")
        files={n:z.read(n) for n in z.namelist()}
    if sha(files["private_assets/ground_only.png"])!=GROUND:
        raise ValueError("Ground mutated")
    if sha(files["scenes/a35_r8_canopy_shadow_scene.tscn"])!=R8:
        raise ValueError("Original R8 scene changed")
    corrected=(project/"scripts/a35_r8_r2_light_balance.gd").read_bytes()
    if files["scripts/a35_r8_r2_light_balance.gd"]!=corrected:
        raise ValueError("CORRECTED script not present inside release")
    if b"secondary_key.enabled = active" not in corrected:
        raise ValueError("R8 R2 off-mode ghost-light fix missing")
    for n,t in LOGS.items():
        raw=logtext(work/n)
        if t not in raw:raise ValueError("Native Godot PASS evidence missing: "+n)
        files["qa_a35/logs/"+n]=raw.encode()
    for n in SHOTS:
        p=project/"qa_a35"/n
        with Image.open(p) as im:
            if im.size!=(1280,928):raise ValueError("Wrong original Godot GPU size: "+n)
        files["qa_a35/"+n]=p.read_bytes()
    pixel_file=project/"qa_a35"/"A35_R8_R2_GPU_LIGHT_QA.json"
    qa=json.loads(pixel_file.read_text(encoding="utf-8"))
    if qa["zero_fill_vs_original_R8"]["changed_pixels"]!=0:
        raise ValueError("OFF not identical to R8")
    if qa["fill_24pct_vs_no_fill"]["outside_light_roi"]!=0 or not qa["fill_locally_visible"]:
        raise ValueError("Canopy fill outside first lamp")
    if qa["second_light_vs_single"]["outside_light_roi"]!=0 or not qa["second_light_locally_visible"]:
        raise ValueError("Second light outside east lamp")
    files["qa_a35/A35_R8_R2_GPU_LIGHT_QA.json"]=pixel_file.read_bytes()
    benchmark=json.loads((project/"qa_a35"/"A35_R8_R2_GODOT_WALL_BENCH.json").read_text(encoding="utf-8"))
    if len(benchmark["samples"])!=6 or benchmark["tree_trunks"]!=175 or benchmark["tree_canopies"]!=175:
        raise ValueError("R2 benchmark insufficient")
    files["qa_a35/A35_R8_R2_GODOT_WALL_BENCH.json"]=(json.dumps(benchmark,indent=2)+"\n").encode()
    for p in ("tests/test_a35_r8_r2_native.gd","tests/test_a35_r8_r2_navigation.gd",
              "tests/capture_a35_r8_r2_native.gd","tests/a35_r8_r2_native_bench.gd"):
        files[p]=(project/p).read_bytes()
    for f in ("a35_r8_r2_build.py","a35_r8_r2_gpu_qa.py","a35_r8_r2_finalize_native.py"):
        files["tools/"+f]=(work/f).read_bytes()
    files["qa_a35/A35_R8_R2_NATIVE_SUMMARY.json"]=(
        json.dumps({
           "phase":"FS A35 R8 R2 balanced canopy transmission approximation",
           "engine":"Godot 4.7.2 stable AMD RX 6700 XT OpenGL Compatibility",
           "source_zip_sha256":sha(source_zip.read_bytes()),
           "Ground_sha256":GROUND,"original_R8_scene_sha256":R8,
           "physics":"187 PAR original + 175 trunk +175 canopy masks; nav 8/8; 4/4 routes",
           "native_gpu":"4 original 1280x928 GPU frames",
           "control":"0 modified pixels with new lights switched OFF vs original R8",
           "canopy_fill":qa["fill_24pct_vs_no_fill"],
           "secondary_grove":qa["second_light_vs_single"],
           "benchmark":benchmark,
           "aesthetic":"HOLD; fill mimics foliage light leaks but does not calculate true alpha shadow"
         },ensure_ascii=False,indent=2)+"\n"
    ).encode()
    files["docs/A35_R8_R2_NATIVE_HANDOFF.md"]=(
        "# FS A35 R8 R2 | Official Godot QA release\n"
        "Four native frames: R8 original, R2 zero-fill, R2 24% fill, R2 fill + northeast light.\n"
        "Native source and 8/8 navigation, 4/4 routes PASS. Under zero fill control image equals R8 pixel-for-pixel.\n"
        "A 24% unshadowed PointLight2D at original location approximates partial foliage transmission. Independent northeast second key/fill at 1090,280.\n"
        "Original R8 scene, Ground, old PAR and all physical collisions immutable. Art remains HOLD.\n"
        "Source QA, original GPU PNGs, logs, benchmark, corrected script and pixel results are all inside this owner-only ZIP.\n"
    ).encode()
    files["docs/A35_R8_R2_FAILURE_LOG.md"]=(
        "# FS A35 R8 R2 | Failure Log\n"
        "Initial zero-fill R8 comparison FAILED: 16,633 changed pixels all near northeast second PointLight2D, despite energy set 0. Godot renderer still produced light contribution from zero-energy node.\n"
        "Fix: explicitly disable secondary key/fill PointLight2D nodes with enabled=false when not active, and similarly disable primary fill at 0 strength.\n"
        "Re-ran official Godot source and GPU. Control 0 pixels changed; fill 131,758 pixels within original lamp ROI only; second light 122,464 within northeast ROI only.\n"
        "This is a physically plausible artistic approximation via two light passes, NOT genuine alpha-attenuated shadow transmission. Shadow softness and tree art require human review; ART HOLD.\n"
    ).encode()
    out=root/OUT
    with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n,b in files.items():z.writestr(n,b)
    with zipfile.ZipFile(out) as z:
        if z.testzip():raise ValueError("R2 sealed native ZIP CRC failed")
        if sha(z.read("private_assets/ground_only.png"))!=GROUND or sha(z.read("scenes/a35_r8_canopy_shadow_scene.tscn"))!=R8:
            raise ValueError("R8 original changed in final seal")
    print(json.dumps({"native_file":str(out),"members":len(files),"bytes":out.stat().st_size,
        "sha256":sha(out.read_bytes()),"QA":json.loads(files["qa_a35/A35_R8_R2_NATIVE_SUMMARY.json"])},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True);p.add_argument("--work",required=True)
    a=p.parse_args();seal(Path(a.root),Path(a.work))
