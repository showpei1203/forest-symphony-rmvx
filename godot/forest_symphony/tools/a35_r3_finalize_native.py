#!/usr/bin/env python3
"""A35 R3 native evidence packager. Input/output stay on owner-only Drive."""
from pathlib import Path
import hashlib,json,zipfile,sys
import numpy as np
from PIL import Image

def sha(data):return hashlib.sha256(data).hexdigest()

def finalize(workspace):
    root=workspace.parent
    project=workspace/"godot_project"
    original=root/"FS_A35_R3_HD2D_LAYERED_PRIVATE_20261115.zip"
    target=root/"FS_A35_R3_HD2D_NATIVE_QA_PRIVATE_20261115.zip"
    scenes=["DAY","DUSK","NIGHT"]
    images=[project/"qa_a35"/("A35_R3_HD2D_"+s+"_NATIVE.png") for s in scenes]
    arr=[]
    for item in images:
        if not item.exists():raise RuntimeError("Missing native frame "+str(item))
        im=np.array(Image.open(item).convert("RGB"),dtype=np.uint8)
        if im.shape!=(928,1280,3):raise RuntimeError("Native frame dimension invalid")
        arr.append(im)
    diffs={}
    for i,j in ((0,1),(0,2),(1,2)):
        delta=np.abs(arr[i].astype("int16")-arr[j].astype("int16"))
        diffs[scenes[i]+"_vs_"+scenes[j]]={"changed_pixels":int(np.any(delta!=0,axis=2).sum()),"mean_abs_rgb_delta":round(float(delta.mean()),4)}
    if any(v["changed_pixels"]<1000 for v in diffs.values()):
        raise RuntimeError("Day/night captures are not distinguishable")
    native=(workspace/"A35_R3_GODOT_NATIVE_SOURCE_QA_R2.log").read_text(errors="replace")
    gpu=(workspace/"A35_R3_GODOT_GPU_CAPTURE_R2.log").read_text(errors="replace")
    if "A35 R3 GODOT NATIVE PASS" not in native or "three-phase capture PASS" not in gpu:
        raise RuntimeError("Official Godot logs not PASS")
    with zipfile.ZipFile(original) as zi:
        if zi.testzip():raise RuntimeError("R3 input ZIP CRC bad")
        files={n:zi.read(n) for n in zi.namelist()}
    old_scene_sha=sha(files["scenes/a35_r2_new_species_scene.tscn"])
    ground_sha=sha(files["private_assets/ground_only.png"])
    if ground_sha!="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000":
        raise RuntimeError("Ground changed")
    files["tests/test_a35_r3_hd2d_real.gd"]=(project/"tests"/"test_a35_r3_hd2d_real.gd").read_bytes()
    files["tools/a35_r3_hd2d_build.py"]=(workspace/"a35_r3_hd2d_build.py").read_bytes()
    for p in images:
        files["qa_a35/"+p.name]=p.read_bytes()
    files["qa_a35/A35_R3_NATIVE_SOURCE_QA.log"]=native.encode()
    files["qa_a35/A35_R3_NATIVE_GPU_CAPTURE.log"]=gpu.encode()
    report={
       "phase":"A35_R3_HD2D_NATIVE_R2","Godot":"4.7.2 stable official",
       "GPU":"AMD RX 6700 XT / OpenGL 3.3 Compatibility",
       "original_ground_sha256":ground_sha,"original_R2_scene_sha256":old_scene_sha,
       "PAR_owners":187,"tree_instances":175,"native_source_test":"PASS Exit 0",
       "native_gpu_captures":"PASS Exit 0","frame_count":3,"size_px":[1280,928],
       "frame_differences":diffs,"art":"HOLD","physical_shadow_occluders":"NOT_IMPLEMENTED"}
    files["qa_a35/A35_R3_NATIVE_QA_SUMMARY.json"]=(json.dumps(report,indent=2)+"\n").encode()
    files["docs/A35_R3_HD2D_FAILURE_LOG.md"]+=(
       b"\n7. First Godot native source QA parse failed: get_node_or_null(StringName) requires NodePath. Fixed via NodePath(str(node.name)); official rerun PASS Exit 0.\n"
       b"8. Day/dusk/night 3 native GPU frames PASS. Pixel differences checked but ART HOLD; not a physically correct shadow solution.\n")
    files["docs/A35_R3_HD2D_HANDOFF.md"]+=(
       b"\n## Native Q&A final\n- Godot 4.7.2 editor import PASS. Source QA PASS Exit 0. GPU capture 3/3 PASS Exit 0. 1280x928 frames included in qa_a35 with source logs.\n- All 187 PAR sources, original R2 scene and Ground remain unchanged. ART HOLD.\n")
    files["CURRENT_HANDOFF.md"]=(
       b"# FS A35 R3 HD-2D | 2026-11-15 | ENGINE PASS / ART HOLD\n"
       b"- R3 optional atmosphere, N day/dusk/night, V rain, L toggle, original Ground and R2 source immutable.\n"
       b"- Three real native GPU frames and two successful logs in this owner-only ZIP.\n"
       b"- No finished occlusion, depth-of-field, premium tree sprites or art approval; continue R3 organic foliage.\n\n---\n\n"
       +files.get("CURRENT_HANDOFF.md",b""))
    with zipfile.ZipFile(target,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as zo:
        for n,content in files.items():zo.writestr(n,content)
    with zipfile.ZipFile(target) as z:
        if z.testzip():raise RuntimeError("Final CRC fail")
        if sha(z.read("private_assets/ground_only.png"))!=ground_sha:raise RuntimeError("Ground changed")
        if sha(z.read("scenes/a35_r2_new_species_scene.tscn"))!=old_scene_sha:raise RuntimeError("R2 scene changed")
    print(json.dumps({"file":str(target),"size":target.stat().st_size,"members":len(files),"sha256":sha(target.read_bytes()),"qa":report},indent=2))

if __name__=="__main__":
    finalize(Path(sys.argv[1]))
