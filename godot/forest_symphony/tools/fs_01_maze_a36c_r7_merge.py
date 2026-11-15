#!/usr/bin/env python3
"""FS_01_MAZE / 幽葉迴廊 A36C R7: provenance-safe A36B + A36C grove MERGE.

Actual conflict discovered: A36C R6 scene reverts 40 A36B R2 sprite sources.
The official forest-dungeon integration MUST preserve A36B R2 full sprite/PNG
identities and original Ground + SHADOW, while importing only coherent grove
footpoint shifts from A36C R6. Does NOT claim biome art acceptance.
"""
import argparse,copy,hashlib,json,re,zipfile
from pathlib import Path

BASE_SCENE="scenes/a36b_large_forest_tree_ecology_80x58.tscn"
INCOMING_SCENE="scenes/a36c_r6_forest_groves_80x58.tscn"
OUT_SCENE="scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
BASE_MAN="data/a36b_ecological_tree_manifest.json"
INCOMING_MAN="data/a36c_r6_forest_groves_manifest.json"
OUT_MAN="data/fs_01_maze_a36c_r7_reconciled_manifest.json"
GROUND="private_assets/a36_ground_only_2560x1856.png"
SHADOW="private_assets/a36b_contact_shadows_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
SHADOW_SHA="752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa"

def sha(b):return hashlib.sha256(b).hexdigest()
def block_positions(scene):
    pat=r'\[node name="([^"]+)" type="Node2D" parent="YSort"\]\s*position = Vector2\(([-0-9]+), ([-0-9]+)\)\s*script = ExtResource\("2_object"\)\s*source_file = "([^"]+)"\s*source_sha256 = "([^"]+)"'
    return {k:{"foot":[int(x),int(y)],"source_file":file,"sha":digest} for k,x,y,file,digest in re.findall(pat,scene)}

def build(root:Path,out:Path):
    base=(root/BASE_SCENE).read_bytes()
    incoming=(root/INCOMING_SCENE).read_bytes()
    a=block_positions(base.decode())
    b=block_positions(incoming.decode())
    if len(a)!=326 or set(a)!=set(b):
        raise RuntimeError("A36B/A36C ownership changed, cannot merge safely")
    art_swaps=[id for id in a if a[id]["source_file"]!=b[id]["source_file"] or a[id]["sha"]!=b[id]["sha"]]
    shifts=[id for id in a if a[id]["foot"]!=b[id]["foot"]]
    if len(art_swaps)!=40 or len(shifts)!=56:
        raise RuntimeError("Unrecognized A36C drift: art="+str(len(art_swaps))+" positions="+str(len(shifts)))
    manifest=json.loads((root/BASE_MAN).read_text(encoding="utf8"))
    other=json.loads((root/INCOMING_MAN).read_text(encoding="utf8"))
    if len(other["a36c_r6"]["changes"])!=39:
        raise RuntimeError("A36C R6 original 39 change records missing")
    if len(manifest["objects"])!=326:
        raise RuntimeError("Original A36B 326 independent owners missing")
    if sha((root/GROUND).read_bytes())!=GROUND_SHA or sha((root/SHADOW).read_bytes())!=SHADOW_SHA:
        raise RuntimeError("Baseline A36B Ground/SHADOW mutated")
    text=base.decode()
    for id in shifts:
        x,y=a[id]["foot"]
        xx,yy=b[id]["foot"]
        pattern=(r'(\[node name="'+re.escape(id)+r'" type="Node2D" parent="YSort"\]\s*position = Vector2\()'
                 +str(x)+r', '+str(y)+r'(\))')
        text,new_count=re.subn(pattern,lambda m:m.group(1)+f"{xx}, {yy}"+m.group(2),text)
        if new_count!=1:
            raise RuntimeError("A36B scene rewrite owner geometry not found "+id)
    text=text.replace('FS_A36B_LargeForest_EcologicalTrees','FS_01_MAZE_A36C_R7_ProvenanceSafeForest',1)
    if text==base.decode():
        raise RuntimeError("No actual new forest scene")
    root.joinpath("scenes").mkdir(exist_ok=True)
    (root/OUT_SCENE).write_text(text,encoding="utf8")
    # Keep original A36B manifest/source asset entries, only change 56 footpoints.
    objects={ob["id"]:ob for ob in manifest["objects"]}
    for id in shifts:
        if id not in objects:raise RuntimeError("Original manifest missing owner "+id)
        objects[id]["foot"]=b[id]["foot"]
    manifest["schema"]="fs-01-maze-a36c-r7-provenance-safe/v1"
    manifest["status"]="GODOT_NATIVE_PENDING_ART_HOLD_COLLISION_HOLD"
    manifest["scene_id"]="FS_01_MAZE"
    manifest["display_name"]="幽葉迴廊"
    manifest["canonical_biome"]="BIOME_01_VERDANT_ELF_FOREST"
    manifest["merge_contract"]={
      "authoritative_art":"A36B R2 original full owner-only PAR sprites",
      "incoming_geometry":"A36C R6 tree positions ONLY",
      "original_A36B_scene_sha256":sha(base),
      "original_A36C_scene_sha256":sha(incoming),
      "ground_sha256":GROUND_SHA,
      "contact_shadow_sha256":SHADOW_SHA,
      "reverted_A36C_asset_swaps_not_accepted":len(art_swaps),
      "incoming_changed_positions":len(shifts),
      "position_changed_ids":sorted(shifts),
      "asset_conflict_ids":sorted(art_swaps),
      "r6_movement_history_records":39,
      "art":"HOLD",
      "river_collision":"HOLD",
      "godot_native":"NOT_RUN"
    }
    (root/OUT_MAN).write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    project=root/"project.godot"
    current=project.read_text(encoding="utf8")
    current=current.replace('run/main_scene="res://'+INCOMING_SCENE+'"','run/main_scene="res://'+OUT_SCENE+'"')
    if ('res://'+OUT_SCENE) not in current:raise RuntimeError("Missing new Godot startup scene")
    project.write_text(current,encoding="utf8")
    qa={
      "scene":"FS_01_MAZE 幽葉迴廊",
      "mode":"source-only, native testing not yet run",
      "A36B_original_art_swaps_preserved":40,
      "A36C_geometry_movements_imported":56,
      "source_art_mismatch_between_prior_branches":40,
      "A36C_R6_history_records":39,
      "Ground_SHA":GROUND_SHA,"SHADOW_SHA":SHADOW_SHA,
      "objects":326,"trees":310,"art":"HOLD","river_navigation":"HOLD"}
    (root/"qa_a36c").mkdir(exist_ok=True)
    (root/"qa_a36c"/"FS_01_MAZE_R7_SOURCE_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2)+"\n")
    print(json.dumps({"scene":OUT_SCENE,"source_qa":qa,"baseline_sha":sha(base),
       "incoming_sha":sha(incoming),"new_scene_sha":sha(text.encode())},ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--project",required=True)
    a=p.parse_args();build(Path(a.project),Path(a.project))
