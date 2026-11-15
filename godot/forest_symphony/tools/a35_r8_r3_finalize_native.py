#!/usr/bin/env python3
"""A35 R8 R3: seal full owner-only native Godot QA release.

4 original 1280x928 GPU frames + real source/nav/GPU logs, exact pixel
regression, entire reproducible Godot scene, old scenes/sprites unchanged.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image

BASE="FS_A35_R8_R3_GROVE_SOURCE_PRIVATE_20261116.zip"
FINAL="FS_A35_R8_R3_GROVE_NATIVE_QA_PRIVATE_20261116.zip"
GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
SHOTS=[
"A35_R8_R3_R2_FILL_ONLY_NATIVE.png",
"A35_R8_R3_R3_OFF_CONTROL_NATIVE.png",
"A35_R8_R3_R3_GROVE_ON_NATIVE.png",
"A35_R8_R3_R2_HOUSE_GLARE_NATIVE.png"
]
LOGS={
"R3_SOURCE_STDOUT.log":"A35 R8 R3 GODOT NATIVE PASS",
"R3_NAV_STDOUT.log":"A35 R8 R3 NATIVE PHYSICAL NAV PASS 8/8",
"R3_GPU_STDOUT.log":"A35 R8 R3 four original Godot GPU controls 4/4 PASS"
}
def sha(b):return hashlib.sha256(b).hexdigest()
def readlog(path):
    data=path.read_bytes()
    if data.startswith((b"\xff\xfe",b"\xfe\xff")):
        return data.decode("utf-16",errors="replace")
    return data.decode("utf-8-sig",errors="replace")
def finalize(root:Path,workspace:Path):
    project=workspace/"godot_project"
    with zipfile.ZipFile(root/BASE) as z:
        if z.testzip() is not None:raise RuntimeError("R8 R3 source ZIP CRC fail")
        members={n:z.read(n) for n in z.namelist()}
    preserved=[
        "private_assets/ground_only.png",
        "scenes/a35_r8_canopy_shadow_scene.tscn",
        "scenes/a35_r8_r2_light_balance_scene.tscn"
    ]
    hashes={n:sha(members[n]) for n in preserved}
    if hashes[preserved[0]]!=GROUND:raise RuntimeError("Original Ground hash mismatch")
    for file,phrase in LOGS.items():
        text=readlog(workspace/file)
        if phrase not in text:raise RuntimeError("Native Godot test incomplete: "+file)
        members["qa_a35/A35_R8_R3_"+file]=text.encode("utf-8")
    for shot in SHOTS:
        path=project/"qa_a35"/shot
        with Image.open(path) as png:
            if png.size!=(1280,928):raise RuntimeError("Original GPU size mismatch: "+shot)
        members["qa_a35/"+shot]=path.read_bytes()
    qa_path=project/"qa_a35"/"A35_R8_R3_GPU_COTTAGE_GROVE_QA.json"
    qa=json.loads(qa_path.read_text(encoding="utf-8"))
    bad=[name for name,passed in qa["gates"].items() if not passed]
    if bad:raise RuntimeError("R8 R3 GPU regressions: "+repr(bad))
    if qa["east_cottage"]["R8_R3_RELOCATED_LIGHT_CHANGED_COTTAGE_PIXELS"]!=0:
        raise RuntimeError("R3 still brightens cottage")
    members["qa_a35/A35_R8_R3_GPU_COTTAGE_GROVE_QA.json"]=qa_path.read_bytes()
    for test in ("tests/test_a35_r8_r3_native.gd",
                 "tests/test_a35_r8_r3_navigation.gd",
                 "tests/capture_a35_r8_r3_native.gd"):
        members[test]=(project/test).read_bytes()
    for source in ("a35_r8_r3_build.py",
                   "a35_r8_r3_gpu_qa.py",
                   "a35_r8_r3_finalize_native.py"):
        members["tools/"+source]=(workspace/source).read_bytes()
    members["scripts/a35_r8_r3_grove_light.gd"]=(workspace/"a35_r8_r3_grove_light.gd").read_bytes()

    report={
      "phase":"A35 R8 R3 natural forest lamp, right-cottage glare fixed",
      "engine":"Godot 4.7.2 official / AMD RX 6700 XT / OpenGL 3.3 Compatibility",
      "original_ground_sha256":GROUND,
      "unaltered_historical_scene_sha256":hashes,
      "source_ZIP_sha256":sha((root/BASE).read_bytes()),
      "native_import":"PASS Exit 0",
      "native_source":"PASS Exit 0, 187 original PAR, 175 trunk and 175 canopy occluders",
      "native_nav":"PASS Exit 0, 8/8 gates and 4/4 routes",
      "native_gpu":"PASS Exit 0, four original 1280x928 frames",
      "pixel_control":"PASS 0 changed pixels when new secondary lamp OFF",
      "new_forest_light":"45608 changed pixels localized in 190px radius, 43667 within upper forest, zero outside",
      "east_cottage":"R8 R2 old light changed 65972 house ROI pixels; R8 R3 new light changed 0",
      "art":"HOLD, improved lighting correction not overall HD-2D art seal",
      "qa":qa
    }
    members["qa_a35/A35_R8_R3_NATIVE_QA_SUMMARY.json"]=(json.dumps(report,ensure_ascii=False,indent=2)+"\n").encode()
    handoff=members["docs/A35_R8_R3_SOURCE_HANDOFF.md"].decode()
    handoff+=("\n## Official Godot 4.7.2 QA\n"
      "- Real native import/source/nav/GPU PASS. 187 PAR, 175 trunk/canopy pairs untouched; eight protected nav gates, four roads PASS.\n"
      "- Four original GPU frames packed into qa_a35. R2 fill-only vs R3 secondary OFF: 0 changed pixels.\n"
      "- R3 grove light: 45,608 native pixels changed within 190px lamp radius and 0 outside; 43,667 forest pixels lit.\n"
      "- East cottage unchanged: 0 pixels affected vs R2 old lamp 65,972. ART HOLD pending 1:1 owner aesthetic review.\n"
      "- Full private ZIP contains original image frames and source/QA, historical R8/R2 scenes remain untouched.\n")
    members["docs/A35_R8_R3_SOURCE_HANDOFF.md"]=handoff.encode()
    fail=members["docs/A35_R8_R3_FAILURE_LOG.md"].decode()
    fail+=("\n- Verified actual old R2 second light lit 65,972 pixels in east cottage ROI, excessive glare. New relocated smaller R3 accent: zero pixels in cottage, 43,667 in upper forest; native 4/4 GPU. RESOLVED for tested fixed night view.\n"
      "- Original R8 R2 zero-energy ghost-light problem guarded: R3 light physically disabled; pixel-for-pixel OFF control 0 difference.\n"
      "- Tests only fixed scene camera, phase=night and study light geometry. Day/dusk color/overall art approval not established. R6 conifer pixel edge spikes and dynamic weather still ART HOLD.\n"
      "- GPU light fill is an artistic unshadowed-light approximation, not true semitransparent material shadow or volumetric 3D lighting.\n")
    members["docs/A35_R8_R3_FAILURE_LOG.md"]=fail.encode()
    prev=members.get("CURRENT_HANDOFF.md",b"").decode()
    members["CURRENT_HANDOFF.md"]=(
      "# FS A35 R8 R3 | VERIFIED NATIVE QA / ART HOLD | 2026-11-16\n"
      "- New separate R3 scene, lower-energy forest canopy accent at (805,90), no right house light pollution.\n"
      "- R8/R2 sources and Ground preserved; 187 PAR + 175 real canopy and 175 trunk blockers; Godot nav 8/8, roads 4/4 PASS.\n"
      "- 4 actual GPU: zero-fill control=0 pixel delta; forest changes=45608 localized; right house changed=0 (old R2=65972).\n"
      "- Owner-only full native ZIP: "+FINAL+". Confirm Drive provider file ID before linking.\n"
      "- ART HOLD and follow-ups: extend day/dusk native captures, refine R6 conifer jagged sprites, then Ground3 additive layer after art gate.\n\n---\n"
      +prev).encode()
    output=root/FINAL
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for name,data in members.items():z.writestr(name,data)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:raise RuntimeError("R8 R3 final ZIP CRC fail")
        for name,digest in hashes.items():
            if sha(z.read(name))!=digest:raise RuntimeError("R8 R3 ancestor changed "+name)
    print(json.dumps({"release":str(output),"members":len(members),"bytes":output.stat().st_size,
       "sha256":sha(output.read_bytes()),"qa_summary":{
        "Godot_source_nav":report["native_nav"],
        "Godot_original_gpu":report["native_gpu"],
        "zero_control":report["pixel_control"],
        "forest":report["new_forest_light"],
        "east_cottage":report["east_cottage"],
        "ART":"HOLD"}},ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True);p.add_argument("--work",required=True)
    a=p.parse_args()
    finalize(Path(a.root),Path(a.work))
