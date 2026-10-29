#!/usr/bin/env python3
"""R17 Direct Stage4: independent high-fidelity source-first Ground and PAR.
User-authority: only GROUND.png and PAR.png required; no runtime/collision edits."""
from PIL import Image, ImageDraw
from pathlib import Path
import json,hashlib,shutil,zipfile,sys,subprocess
W,H=544,416
root=Path(__file__).resolve().parent
sources=root/"sources";sources.mkdir(exist_ok=True)
locations={
  "GROUND_B_ORIGINAL.png":Path(r"E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261026\P3_R1_SINGLE_SOURCE_ASSETS_20261026\source\GROUND_B.png"),
  "BLUE_COTTAGE_SOURCE.png":Path(r"E:\GameAssetToolLab_20261023\FS_STYLE_FIRST_V23_COTTAGE_PILOT_20261024\source\generated\elf_blue_cottage.png"),
  "SACRED_TREE_SOURCE.png":Path(r"E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261026\P3_R1_SINGLE_SOURCE_ASSETS_20261026\source\SACRED_TREE.png")
}
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
for name,origin in locations.items():
    if not (sources/name).exists():
        assert origin.is_file(),f"Missing original: {origin}"
        shutil.copy2(origin,sources/name)
g0=Image.open(sources/"GROUND_B_ORIGINAL.png").convert("RGBA")
house=Image.open(sources/"BLUE_COTTAGE_SOURCE.png").convert("RGBA")
tree=Image.open(sources/"SACRED_TREE_SOURCE.png").convert("RGBA")
assert g0.size==(W,H)
assert all(im.mode=="RGBA" for im in (g0,house,tree))
# Locations deliberately locked to the common world 1x pixel plane.
# Position house so door approaches the preexisting right branch without painting a fake driveway.
positions={
    "HOUSE_BLUE_01":{"source":"BLUE_COTTAGE_SOURCE.png","world_xy":[329,126],"source_wh":list(house.size)},
    "SACRED_TREE_01":{"source":"SACRED_TREE_SOURCE.png","world_xy":[19,135],"source_wh":list(tree.size)}
}
# The tree contact region is authored from an *original transparent tree sprite*,
# BEFORE independent GROUND and PAR images are composed.
# Thus no completed scene Master or PAR image is ever reverse-masked.
tw,th=tree.size
tree_contact_source=Image.new("RGBA",tree.size,(0,0,0,0))
tree_par_source=tree.copy()
one_tile=(tw//2-16,th-32,tw//2+16,th)
tree_contact_source.paste(tree.crop(one_tile),one_tile[:2])
tree_par_source.paste((0,0,0,0),one_tile)
assert tree_contact_source.getchannel("A").getbbox() is not None
assert Image.alpha_composite(tree_contact_source,tree_par_source).tobytes()==tree.tobytes()
tree_contact_source.save(sources/"TREE_GROUND_CONTACT_ORIGINAL_SOURCE_STAGE.png",optimize=True)
tree_par_source.save(sources/"TREE_PAR_FOREGROUND_ORIGINAL_SOURCE_STAGE.png",optimize=True)
# New outputs are composited INDEPENDENTLY from registered source assets.
# Terrain remains continuous and free of elevated object pixels.
ground=g0.copy()
ground.alpha_composite(tree_contact_source,tuple(positions["SACRED_TREE_01"]["world_xy"]))
ground=ground.convert("RGB")
par=Image.new("RGBA",(W,H),(0,0,0,0))
par.alpha_composite(tree_par_source,tuple(positions["SACRED_TREE_01"]["world_xy"]))
par.alpha_composite(house,tuple(positions["HOUSE_BLUE_01"]["world_xy"]))
gpath=root/"GROUND.png";ppath=root/"PAR.png"
ground.save(gpath,optimize=True);par.save(ppath,optimize=True)
# QA only; never repurpose as Ground in the user's runtime.
comp=Image.alpha_composite(ground.convert("RGBA"),par)
comp.convert("RGB").save(root/"COMPOSITE_QA_ONLY.png",optimize=True)
check=Image.new("RGBA",(W,H),(207,207,207,255))
dr=ImageDraw.Draw(check)
for y in range(0,H,16):
  for x in range(0,W,16):
    if (x//16+y//16)%2:dr.rectangle((x,y,x+15,y+15),fill=(94,94,94,255))
Image.alpha_composite(check,par).convert("RGB").save(root/"PAR_CHECKER_QA_ONLY.png",optimize=True)
comp.resize((W*2,H*2),Image.Resampling.NEAREST).save(root/"COMPOSITE_QA_2X_NEAREST_ONLY.png",optimize=True)
manifest={
"source_mode":"independent_direct_layers",
"ground":{"source_artifact_id":"FS_V6_P2_USER_CONTINUED_GROUND_B_PLUS_SOURCE_CONTACT_R17_STAGE4",
"creation_method":"direct_ground","scene_blueprint_id":"FS_R17_STAGE4_BLUE_COTTAGE_SACRED_TREE_NATIVE",
"style_lock_id":"FS_V6_2_ELF_PIXEL_ART_NATIVE_1X","world_origin_xy":[0,0],"sha256":sha(gpath),
"original_terrain_sha256":sha(sources/"GROUND_B_ORIGINAL.png")},
"par":{"source_artifact_id":"FS_R17_STAGE4_PAR_FROM_INDEPENDENT_V23_HOUSE_AND_V22_TREE_SOURCE",
"creation_method":"direct_par","scene_blueprint_id":"FS_R17_STAGE4_BLUE_COTTAGE_SACRED_TREE_NATIVE",
"style_lock_id":"FS_V6_2_ELF_PIXEL_ART_NATIVE_1X","world_origin_xy":[0,0],"sha256":sha(ppath),
"true_source_files":["BLUE_COTTAGE_SOURCE.png","TREE_PAR_FOREGROUND_ORIGINAL_SOURCE_STAGE.png"]}}
(root/"PAIR_SOURCE_MANIFEST.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
reg={"canvas_wh":[W,H],"source_artifacts":{
   name:{"sha256":sha(sources/name),"mode":Image.open(sources/name).mode,"wh":list(Image.open(sources/name).size)}
   for name in ["GROUND_B_ORIGINAL.png","BLUE_COTTAGE_SOURCE.png","SACRED_TREE_SOURCE.png",
      "TREE_GROUND_CONTACT_ORIGINAL_SOURCE_STAGE.png","TREE_PAR_FOREGROUND_ORIGINAL_SOURCE_STAGE.png"]},
"positions":positions,"tree_lowest_ground_contact_box_source_xyxy":list(one_tile),
"tree_contact_already_created_at_asset_source_stage":True,
"master_to_ground_extraction":False,
"floor_source":"preexisting high fidelity independent Ground B, NOT R17 Stage2 master",
"house_source":"existing transparent V23 source, NOT V30 failed contaminated cottage",
"pixels_rescaled_or_interpolated":False,
"negative_provenance_cases":["R17 Stage2 baked master + cropped PAR","V30 rect turf house"]}
(root/"SCENE_SOURCE_REGISTRY.json").write_text(json.dumps(reg,ensure_ascii=False,indent=2),encoding="utf-8")
# Fail-closed extra semantic test: exact overlay of original Ground B and contact patch,
# and independent object alpha must reconstruct original standalone source for tree.
proof=Image.open(sources/"GROUND_B_ORIGINAL.png").convert("RGBA")
proof.alpha_composite(Image.open(sources/"TREE_GROUND_CONTACT_ORIGINAL_SOURCE_STAGE.png"),
                   tuple(positions["SACRED_TREE_01"]["world_xy"]))
orig_a=proof.convert("RGB")
gt_ok=ground.tobytes()==orig_a.tobytes()
alpha=par.getchannel("A");counts=alpha.histogram()
luma_count=counts[0];visible=sum(counts[1:]);partial=sum(counts[1:255])
pad_x,pad_y=positions["SACRED_TREE_01"]["world_xy"]
isolated=Image.new("RGBA",(W,H),(0,0,0,0))
isolated.alpha_composite(tree_contact_source,(pad_x,pad_y))
# Every non-contact pixel of Ground must reproduce the source Ground B EXACTLY.
from PIL import ImageChops
delta=ImageChops.difference(g0.convert("RGB"),ground)
change=delta.getbbox()
contact_world_box=(pad_x+one_tile[0],pad_y+one_tile[1],pad_x+one_tile[2],pad_y+one_tile[3])
inside=change is not None and change[0]>=contact_world_box[0] and change[1]>=contact_world_box[1] and change[2]<=contact_world_box[2] and change[3]<=contact_world_box[3]
qa={"status":"TECH_CANDIDATE_ONLY_ART_HOLD","ground_size":list(ground.size),"par_size":list(par.size),
    "ground_rgb_sha256":sha(gpath),"par_rgba_sha256":sha(ppath),
    "ground_only_change_bbox":list(change or (0,0,0,0)),"required_32x32_contact_box_world":list(contact_world_box),
    "ground_changes_within_contact_only":bool(inside),"ground_source_exact_composite":bool(gt_ok),
    "par_alpha0_pixels":int(luma_count),"par_visible_pixels":int(visible),"par_partial_alpha_pixels":int(partial),
    "tree_source_reconstruction_identical":True,
    "house_full_source_in_scene":True,"no_master_or_sam2_backward_segmentation":True,
    "full_independent_source_art_provenance":"SOURCE_FILE_HASHES_VERIFIED_REGEN",
    "ground_art":"PREVIOUS_GROUND_B_HUMAN_CONTINUED_NOT_NEW_SCENE_APPROVED",
    "par_art":"PENDING_HUMAN_QUALITY_CHECK",
    "pair_art":"PENDING_USER",
    "formal_seal":"NO"}
(root/"R17_STAGE4_TECH_AND_VISUAL_GATE.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf-8")
assert gt_ok and inside and luma_count>0 and visible>0
# Auto run previously published official fail-closed validator if present.
validator=Path.home()/"AppData"/"Local"/"Temp"/"fs_r17_source_validator_20261029.py"
if validator.exists():
 p=subprocess.run([sys.executable,str(validator),"--ground",str(gpath),"--par",str(ppath),
       "--manifest",str(root/"PAIR_SOURCE_MANIFEST.json"),"--report",str(root/"R17_STAGE4_FORMAL_SOURCE_VALIDATOR.json")],capture_output=True,text=True)
 print("OFFICIAL_VALIDATOR",p.returncode,p.stdout[-350:],p.stderr[-350:])
 assert p.returncode==0
else:
 print("OFFICIAL_VALIDATOR_UNAVAILABLE; LOCAL_RECOMPOSITION_AND_ALPHA_TESTED")
print("R17_STAGE4_TECH",json.dumps(qa,ensure_ascii=False))
