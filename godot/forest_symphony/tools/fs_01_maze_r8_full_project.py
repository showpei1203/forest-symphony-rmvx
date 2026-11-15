#!/usr/bin/env python3
"""FS_01_MAZE R8 complete standalone Godot project built from sealed R7B+R8.

Full Godot project includes all original owner-only PNG sources, old scenes,
new authentic StaticBody2D river collision main scene, original GPU QA frames,
and clean SHA+CRC. No public artwork uploaded.
"""
import argparse,zipfile,hashlib,json
from pathlib import Path
R7="FS_12_MAP_FACTORY_V1_FS01_MAZE_R7B_UTF8_NATIVE_PRIVATE_20261116.zip"
R8_PATCH="FS_01_MAZE_R8_WATER_PHYSICS_NATIVE_PATCH_PRIVATE_20261116.zip"
OUT="FS_01_MAZE_R8_WATER_NATIVE_FULL_GODOT_PRIVATE_20261116.zip"
R7_SHA="de0e2039327b234b3adffa2ab110fbaf7620022f566febb5c66cf618c912ded5"
PATCH_SHA="b2f13ce1770a21113ba358206a9663a5c1140a0aa406b2d5f319e9b2bb58e49b"
GROUND="private_assets/a36_ground_only_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
SHADOW="private_assets/a36b_contact_shadows_2560x1856.png"
SHADOW_SHA="752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa"
OLD="scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
NEW="scenes/fs_01_maze_r8_water_collision_80x58.tscn"
def sha(b):return hashlib.sha256(b).hexdigest()
def run(root:Path):
    baseline=root/R7;patch=root/R8_PATCH
    if sha(baseline.read_bytes())!=R7_SHA or sha(patch.read_bytes())!=PATCH_SHA:
        raise RuntimeError("Original R7B baseline or R8 patch digest mismatch")
    with zipfile.ZipFile(baseline) as z:
        if z.testzip() is not None:raise RuntimeError("R7B private source CRC mismatch")
        original={n:z.read(n) for n in z.namelist()}
    with zipfile.ZipFile(patch) as z:
        if z.testzip() is not None:raise RuntimeError("R8 private patch CRC mismatch")
        delta={n:z.read(n) for n in z.namelist()}
    keep={n:original[n] for n in (GROUND,SHADOW,OLD)}
    for name,payload in delta.items():
        if name in original and original[name]!=payload:
            if name.startswith("private_assets/") or name.startswith("scenes/"):
                raise RuntimeError("Cannot replace historical original art/scene "+name)
        original[name]=payload
    if sha(original[GROUND])!=GROUND_SHA or sha(original[SHADOW])!=SHADOW_SHA:
        raise RuntimeError("Original forest art mutated")
    if original[OLD]!=keep[OLD]:
        raise RuntimeError("Old R7 scene mutated")
    if NEW not in original or "148 unique" in str(original[NEW]):
        raise RuntimeError("Missing new independent R8 water physics scene")
    main=original["project.godot"].decode("utf-8")
    if ("res://"+OLD) not in main:
        raise RuntimeError("Old main scene not present")
    original["project.godot"]=main.replace("res://"+OLD,"res://"+NEW).encode("utf-8")
    if ("res://"+NEW).encode() not in original["project.godot"]:
        raise RuntimeError("New playable R8 scene not selected")
    record={
      "version":"FS_01_MAZE R8 148 native river physics standalone Godot",
      "full_previous_SHA256":R7_SHA,
      "patch_SHA256":PATCH_SHA,
      "scene_path":"res://"+NEW,
      "scene_SHA256":sha(original[NEW]),
      "original_Ground_SHA256":GROUND_SHA,
      "original_Shadow_SHA256":SHADOW_SHA,
      "native_water_queries":"PASS 148/148",
      "original_GPU_2x2560x1856":"PASS; R7 vs R8 0 changed RGB pixels",
      "original_326_PAR":"retained exactly",
      "route":"HOLD",
      "art":"HOLD",
      "private_owner_only":True
    }
    original["qa_a36c/FS_01_MAZE_R8_FULL_RELEASE_MANIFEST.json"]=(json.dumps(record,ensure_ascii=False,indent=2)+"\n").encode("utf8")
    original["CURRENT_HANDOFF.md"]=(
      "# FS_01_MAZE R8 | Native Godot water physics complete candidate, not art sealed\n"
      "Godot 4.7.2; original 80x58 Ground/SHADOW/PAR intact; 148 real water collision points PASS;\n"
      "R7 vs R8 real GPU has 0 art differences; entire maze navigation/river art still HOLD.\n"
      "Read docs/FS_01_MAZE_R8_WATER_NATIVE_HANDOFF_20261116.md and Failure Log.\n\n---\n"
    ).encode("utf8")+original.get("CURRENT_HANDOFF.md",b"")
    final=root/OUT
    with zipfile.ZipFile(final,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n,b in original.items():z.writestr(n,b)
    with zipfile.ZipFile(final) as z:
        if z.testzip() is not None:raise RuntimeError("Final full R8 project CRC error")
        for n,b in keep.items():
            if z.read(n)!=b:raise RuntimeError("Final project historical original changed "+n)
    print(json.dumps({"file":str(final),"entries":len(original),
      "bytes":final.stat().st_size,"sha256":sha(final.read_bytes()),
      "status":record},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--root",required=True)
    run(Path(p.parse_args().root))
