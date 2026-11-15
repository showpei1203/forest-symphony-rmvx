#!/usr/bin/env python3
"""Seal the A35 R6 owner-only complete Godot-native candidate and its QA.

Source remains a reproducible ZIP from R5. Include original 7 actual Godot GPU
screens, 5 source/nav/render logs, generated QA, immutable ancestor hash evidence.
Never publish private PNGs or this full ZIP on public GitHub.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image

BASE="FS_A35_R6_CONIFER_SOURCE_PRIVATE_20261115.zip"
FINAL="FS_A35_R6_CONIFER_NATIVE_QA_PRIVATE_20261115.zip"
GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
SCENES=[
"scenes/a35_r2_new_species_scene.tscn",
"scenes/a35_r3_hd2d_layered_scene.tscn",
"scenes/a35_r4_organic_groves_hd2d_scene.tscn",
"scenes/a35_r5_botanical_forest_hd2d_scene.tscn"
]
SHOTS=[
"A35_R6_CANOPY_DAY_NATIVE.png",
"A35_R6_CANOPY_DUSK_NATIVE.png",
"A35_R6_CANOPY_NIGHT_NATIVE.png",
"A35_R6_R5_BASELINE_NATIVE.png",
"A35_R6_ART_CANDIDATE_NATIVE.png",
"A35_R6_ACTOR_BEHIND_NATIVE.png",
"A35_R6_ACTOR_FRONT_NATIVE.png"
]
LOGS={
"R6_SOURCE_STDOUT_FINAL.log":"FS A35 R6 GODOT PASS: 13 replaced, 174 retained",
"R6_NAV_STDOUT.log":"A35 R6 NATIVE PHYSICAL NAV PASS 8/8",
"R6_GPU_STDOUT.log":"A35 R6 Godot native three-phase capture PASS",
"R6_AB_STDOUT.log":"A35 R6 4/4 stable GPU A/B + actor depth frame capture PASS"
}
def sha(data):return hashlib.sha256(data).hexdigest()
def read_log(path):
    data=path.read_bytes()
    if data.startswith((b"\xff\xfe",b"\xfe\xff")):return data.decode("utf-16",errors="replace")
    return data.decode("utf-8-sig",errors="replace")

def build(root,work):
    project=work/"godot_project"
    with zipfile.ZipFile(root/BASE) as z:
        if z.testzip() is not None:raise RuntimeError("SOURCE CRC FAIL")
        files={p:z.read(p) for p in z.namelist()}
    original_paths=["private_assets/ground_only.png"]+SCENES
    old_hashes={p:sha(files[p]) for p in original_paths}
    if old_hashes["private_assets/ground_only.png"]!=GROUND:
        raise RuntimeError("Old Ground SHA mismatch")
    for log,phrase in LOGS.items():
        text=read_log(work/log)
        if phrase not in text:raise RuntimeError("Missing real native success: "+log)
        files["qa_a35/A35_R6_"+log]=text.encode("utf-8")
    files["qa_a35/A35_R6_IMPORT_STDOUT.log"]=read_log(work/"R6_IMPORT_STDOUT.log").encode("utf-8")
    all_sizes={}
    for name in SHOTS:
        file=project/"qa_a35"/name
        with Image.open(file) as im:
            if im.size!=(1280,928):raise RuntimeError("GPU screenshot dimension invalid "+name)
        all_sizes[name]=file.stat().st_size
        files["qa_a35/"+name]=file.read_bytes()
    roi=json.loads((project/"qa_a35"/"A35_R6_REAL_GPU_ROI.json").read_text(encoding="utf-8"))
    if (roi["modified_owners"]!=13 or roi["retained_PAR"]!=174
        or roi["inside_union_tree_roi"]<1000 or roi["outside_union_tree_roi"]!=0
        or not roi["occlusion_pass_at_test_point"]):
        raise RuntimeError("Native R6 ROI/actor regression")
    files["qa_a35/A35_R6_REAL_GPU_ROI.json"]=(
        json.dumps(roi,ensure_ascii=False,indent=2)+"\n").encode()
    for source in (
       "a35_r6_conifer_art.py","a35_r6_build.py","a35_r6_roi_qa.py",
       "a35_r6_finalize_native.py"
    ):
        files["tools/"+source]=(work/source).read_bytes()
    files["tests/test_a35_r6_native.gd"]=(project/"tests"/"test_a35_r6_native.gd").read_bytes()
    for source in ("tests/test_a35_r6_navigation.gd",
                   "tests/capture_a35_r6_native.gd",
                   "tests/capture_a35_r6_ab_actor_native.gd"):
        files[source]=(project/source).read_bytes()
    report={
      "phase":"A35 R6 conifer detail, botanical native QA",
      "engine":"Official Godot 4.7.2 / AMD RX 6700 XT / OpenGL 3.3 Compatibility",
      "source":"PASS native 13/174 PAR; original total=187 trees=175, Ground immutable",
      "physical_navigation":"PASS 8/8, 4/4 main routes; zero newly blocked protected roads",
      "real_gpu_capture":"PASS 7 original 1280x928 frames, FX-on 3 and FX-off A/B+actor 4",
      "tree_roi":"37,535 native changed pixels all inside 13-tree ROI, 0 outside",
      "occlusion":{
         "rear":roi["actor_rear_pixels_visible"],
         "front":roi["actor_front_pixels_visible"],
         "visible_ratio":roi["rear_visible_ratio"],
         "qa":"PASS one-point partial foliage, not complete blackout"
      },
      "original_scene_ground_sha256":old_hashes,
      "source_zip_sha256":sha((root/BASE).read_bytes()),
      "screenshots":all_sizes,
      "art":"HOLD. Conifer edge needles may appear too regularly spiky at 1x, not formally accepted",
      "hd2d":"Scene retains R3 atmosphere (day/dusk/night); no physical LightOccluder2D or genuine 3D DOF claim."
    }
    files["qa_a35/A35_R6_NATIVE_QA_SUMMARY.json"]=(
        json.dumps(report,ensure_ascii=False,indent=2)+"\n").encode("utf-8")
    files["docs/A35_R6_HANDOFF.md"]+=(
        "\n## Godot original native QA release\n"
        "- Godot 4.7.2 editor import and real source 13/174, navigation 8/8 & 4/4, GPU captures 7/7 all PASS Exit 0.\n"
        "- FX-off R5-to-R6 pixel diff 37535 changed within 13 source tree union ROI; 0 changed outside.\n"
        "- Fixed actor test at tree behind: 53 visible px vs front 576 (9.20%). R5 had rear 0, so R6 refines needles but allows more light gaps. ART HOLD.\n"
        "- 3 conifer asset canvases and rooted final 19px remain unchanged. Original R2/R3/R4/R5 scenes and Ground SHA checked byte-for-byte.\n"
        "- Owner-only complete ZIP contains all 7 original native frame PNGs, QA reports, logs, source and tests.\n"
    ).encode()
    files["docs/A35_R6_FAILURE_LOG.md"]+=(
        "\n1. Godot first source QA success line was stale R5 text saying 32 changed /155 retained even though guard correctly tested 13/174. Fixed generated test text and reran official Godot native PASS with accurate 13/174. Final release includes corrected script and log.\n"
        "2. R6 1px sprite needle algorithm adds a more jagged conifer rim, but may overproduce symmetrical/thorn-like branch tips. Pixel ROI and engine validation do NOT certify visual acceptance. ART HOLD.\n"
        "3. At the same sampled actor point, R5 had rear=0px; R6 rear=53px vs front=576px. This is only a sparse leaf-alpha tradeoff accepted by partial-foliage threshold (<=40%), NOT improvement in absolute opacity. Requires visual checking and broader spatial occlusion QA.\n"
        "4. Godot 4.7.2 source/nav/GPU/ROI PASS, 37,535 R5-to-R6 modified pixels all confined to 13 tree bounds. Need dynamic shadow casters and actual HD-2D DOF later.\n"
        "5. Never publish 170MB ZIP/private PNGs on GitHub; owner-only Drive only.\n"
    ).encode()
    prev=files.get("CURRENT_HANDOFF.md",b"").decode()
    files["CURRENT_HANDOFF.md"]=(
        "# Forest Symphony | A35 R6 conifer native pixel art | 2026-11-15\n"
        "- ENGINE PASS / NAV PASS / ORIGINAL GPU 7/7 PASS / ROI PASS / ART HOLD. Godot 4.7.2, not VX; no modifications to separate A36C.\n"
        "- 13 replaced conifer tree instances (cypress 3/fir 5/needle 5), 174 retained, total 187 PAR/175 trees. No changes Ground, historical R2-R5 scenes, collision and original root pixels.\n"
        "- Native NAV 8/8 and route 4/4. Native screenshot A/B R5 vs R6 shows 37,535 pixels inside 13-tree ROI and 0 outside; actor rear/front=53/576 partial leaf occlusion (R5 rear=0).\n"
        "- Private ZIP "+FINAL+" contains all 7 actual Godot captures and logs. ART remains HOLD due jagged needle edges and absent real tree light occluders/DOF.\n"
        "- Next: inspect 1:1 R5/R6 conifer appearance and polish spike edge frequencies; A35 R7 dynamic shadow caster experiment then Ground3 once art approves.\n"
        "- GitHub only code/Handoff/Failure Log; private PNG/ZIP strictly Drive.\n\n---\n"+prev
    ).encode("utf-8")
    output=root/FINAL
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for path,data in files.items():z.writestr(path,data)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:raise RuntimeError("Final CRC FAIL")
        for p,h in old_hashes.items():
            if sha(z.read(p))!=h:raise RuntimeError("Ancestor Ground/scene changed "+p)
    print(json.dumps({
        "output":str(output),"members":len(files),
        "bytes":output.stat().st_size,"sha256":sha(output.read_bytes()),
        "native":report
    },ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    build(Path(a.root),Path(a.work))
