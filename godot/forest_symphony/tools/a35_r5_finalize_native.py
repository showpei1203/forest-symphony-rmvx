#!/usr/bin/env python3
"""Seal Forest Symphony A35 R5 Godot-native candidate in owner-only Drive.

Never mark art sealed from source QA; preserve all historical R2/R3/R4 scenes
and Ground SHA, and include original GPU screenshot files and native logs.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image

GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
SOURCE="FS_A35_R5_BOTANICAL_SOURCE_PRIVATE_20261115.zip"
TARGET="FS_A35_R5_BOTANICAL_NATIVE_QA_PRIVATE_20261115.zip"
SHOTS=[
"A35_R5_BOTANY_DAY_NATIVE.png","A35_R5_BOTANY_DUSK_NATIVE.png","A35_R5_BOTANY_NIGHT_NATIVE.png",
"A35_R5_R4_BASELINE_NATIVE.png","A35_R5_ART_CANDIDATE_NATIVE.png",
"A35_R5_ACTOR_BEHIND_NATIVE.png","A35_R5_ACTOR_FRONT_NATIVE.png"
]
LOGS={
"R5_SOURCE_STDOUT.log":"FS A35 R5 GODOT PASS",
"R5_NAV_STDOUT.log":"A35 R5 NATIVE PHYSICAL NAV PASS 8/8",
"R5_GPU_STDOUT.log":"three-phase capture PASS",
"R5_AB_STDOUT.log":"4/4 stable GPU A/B + actor depth frame capture PASS"
}
def sha(data):return hashlib.sha256(data).hexdigest()
def read_log(p):
    data=p.read_bytes()
    if data.startswith(b"\xff\xfe") or data.startswith(b"\xfe\xff"):
        return data.decode("utf-16",errors="replace")
    return data.decode("utf-8-sig",errors="replace")

def main(root,work):
    project=work/"godot_project"
    with zipfile.ZipFile(root/SOURCE) as z:
        if z.testzip() is not None:raise RuntimeError("Original source ZIP CRC FAIL")
        files={name:z.read(name) for name in z.namelist()}
    preserve={}
    for p in ("private_assets/ground_only.png",
              "scenes/a35_r2_new_species_scene.tscn",
              "scenes/a35_r3_hd2d_layered_scene.tscn",
              "scenes/a35_r4_organic_groves_hd2d_scene.tscn"):
        preserve[p]=sha(files[p])
    if preserve["private_assets/ground_only.png"]!=GROUND:
        raise RuntimeError("GROUND has changed")
    for name,check in LOGS.items():
        raw=read_log(work/name)
        if check not in raw:
            raise RuntimeError("Missing original Godot native success: "+name)
        files["qa_a35/A35_R5_"+name]=raw.encode("utf-8")
    for name in SHOTS:
        png=project/"qa_a35"/name
        with Image.open(png) as im:
            if im.size!=(1280,928):raise RuntimeError("Wrong native GPU frame size "+name)
        files["qa_a35/"+name]=png.read_bytes()
    roi_path=project/"qa_a35"/"A35_R5_NATIVE_AB_ROI_ACTOR_REPORT.json"
    roi=json.loads(roi_path.read_text(encoding="utf-8"))
    if (roi["changed_tree_owners"]!=32 or roi["total_par"]!=187
            or roi["outside_union_tree_roi"]!=0 or roi["front_back_gate"]!="PASS_PARTIAL_FOLIAGE"):
        raise RuntimeError("Godot tree ROI/depth NOT PASS")
    if roi["actor_front_visible_pixel_change"]<400:
        raise RuntimeError("Front actor not visible")
    files["qa_a35/A35_R5_NATIVE_AB_ROI_ACTOR_REPORT.json"]=roi_path.read_bytes()
    test_paths=[
       "tests/test_a35_r5_native.gd","tests/test_a35_r5_navigation.gd",
       "tests/capture_a35_r5_native.gd","tests/capture_a35_r5_ab_actor_native.gd"
    ]
    for path in test_paths:
        files[path]=(project/path).read_bytes()
    for source in ("a35_r5_botanical_sprites.py","a35_r5_build.py",
                   "a35_r5_native_roi_qa.py","a35_r5_finalize_native.py"):
        files["tools/"+source]=(work/source).read_bytes()

    metrics=json.loads(files["qa_a35/A35_R5_SOURCE_QA.json"])["actual_art_dimensions"]
    source_metrics={
       n:{"actual_height_px":v["actual_height_px"],"actual_width_px":v["actual_width_px"]}
       for n,v in metrics.items()
    }
    report={
       "phase":"A35_R5_BOTANICAL_NATIVE_R1",
       "engine":"Godot 4.7.2 official; AMD RX 6700 XT; OpenGL 3.3 Compatibility",
       "godot_editor_import":"PASS Exit 0",
       "godot_native_sources_and_collisions":"PASS 187 PAR; 32 botanical replacements; 155 untouched; Ground immutable",
       "physical_nav":"PASS 8/8 protected gates, 4/4 routes, no newly blocked protected road",
       "native_gpu":"PASS 7/7 1280x928 frames (3 lighting phases, 4 A/B and actor frames)",
       "roi":"PASS "+str(roi["within_union_tree_roi"])+" changed pixels inside, 0 outside",
       "actor_depth":{"behind":roi["actor_behind_visible_pixel_change"],
                      "front":roi["actor_front_visible_pixel_change"],
                      "gate":roi["front_back_gate"]},
       "source_metrics":source_metrics,
       "original_hashes":preserve,
       "art":"HOLD: human-style approval outstanding; species based on approved FS paintings, 3 conifer NEAREST scaling exceptions, no genuine 3D depth or tree light occluders",
       "source_sha256":sha((root/SOURCE).read_bytes())
    }
    files["qa_a35/A35_R5_NATIVE_QA_SUMMARY.json"]=(json.dumps(report,ensure_ascii=False,indent=2)+"\n").encode()
    files["docs/A35_R5_FAILURE_LOG.md"]+=(
       "\n- QA corrected baseline screenshot naming: R4 -> R5 (not R3 -> R5). Re-ran actual 4-frame GPU script Exit 0.\n"
       "- R5 native compositor A/B counted 98,693 changed pixels inside allowed 32-tree ROI, zero outside. Actor rear=0/front=576 pixels. This is occlusion at one sampled position only; do not claim universal spatial correctness.\n"
       "- THREE CONIFER INPUTS REQUIRE nearest-neighbor source enlargement (not strict original 1x). Native pixel grain and needles reconstructed. Broadleaf inputs retain painted 1x.\n"
       "- Initial 8 species composition (ghost tree fragments at top) was rejected visually before R5 source candidate; only revised coherent, one-piece sprite pipeline packaged.\n"
       "- R5 art final approval and true tree light occluders/real 3D DOF remain HOLD.\n"
    ).encode()
    files["docs/A35_R5_HANDOFF.md"]+=(
       "\n## Real Godot QA addendum\n"
       "- Godot 4.7.2 cold import, official 187 PAR/32 changed/155 unchanged and collision/Foot SHA test PASS.\n"
       "- 8/8 navigation gates and 4/4 routes PASS. 7/7 original GPU screenshots produced. Tree-only A/B difference 98,693 inside, zero outside.\n"
       "- Exact tested position: rear actor 0 visible pixels; front actor 576, PASS. Original R4/R3/R2 scenes and Ground unchanged.\n"
       "- Botanical visuals are a meaningful alpha-bbox size correction, but ART HOLD until owner's 1:1 art acceptance. No claims of photoreal volumetric light, pixel art no-repeat certification or complete HD-2D.\n"
       "- Full artifact only owner-only Drive. GitHub has only sources, Handoff and Failure Log.\n"
    ).encode()
    old_handoff=files.get("CURRENT_HANDOFF.md",b"").decode()
    files["CURRENT_HANDOFF.md"]=(
       "# Forest Symphony | A35 R5 botanical trees | 2026-11-15\n"
       "- ENGINE, NAV, GPU, fixed-R4-source ROI PASS. ART HOLD. Godot 4.7.2 map-workstream only, not VX and not parallel A36C.\n"
       "- 8 new botanical source-derived sprite PNGs, 3 previously tiny conifers enlarged with NEAREST. 32 changes, 155 unchanged, 187 PAR / 175 trees, all existing collisions and Ground immutable.\n"
       "- Official native test 8/8 nav 4/4 paths, 7/7 GPU, tree-only delta "+str(roi["within_union_tree_roi"])+" inside / 0 outside; actor behind=0/front=576 at fixed test coordinate.\n"
       "- Owner-only native ZIP: "+TARGET+". Source: tools/a35_r5_build.py + a35_r5_botanical_sprites.py. Next phase R5 visual approval, then Ground3, later HD-2D light occluders.\n"
       "- Preserve and retain original R2/R3/R4 scenes, no publicly accessible private sprites, all revisions have Handoff/Failure Log.\n\n---\n"+old_handoff
    ).encode()
    output=root/TARGET
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for name,data in files.items():z.writestr(name,data)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:raise RuntimeError("Final CRC FAIL")
        for path,h in preserve.items():
            if sha(z.read(path))!=h:raise RuntimeError("Source preservation broken: "+path)
    print(json.dumps({"output":str(output),"members":len(files),"bytes":output.stat().st_size,
         "sha256":sha(output.read_bytes()),"qa":report},ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True);p.add_argument("--work",required=True)
    a=p.parse_args()
    main(Path(a.root),Path(a.work))
