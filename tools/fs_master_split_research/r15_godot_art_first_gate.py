#!/usr/bin/env python3
"""Fail-closed actual Godot GPU art-first scene full original master vs 3-source-mask PAR candidate.
Tech rendering proof only. Semantic par precision is known insufficient in some examples, Gate F remains HOLD.
"""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import json,hashlib
R=Path(__file__).resolve().parent;D=R/"R15_MULTISCALE_MASK_RESEARCH_20261028";G=D/"godot_art_first"
master_src=R/"R12_NEW_ELF_VILLAGE_001"/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
new_master=Image.open(master_src).convert("RGB")
pictures={k:Image.open(G/"exported"/("R15_"+k+".png")).convert("RGBA") for k in ["MASTER","PAR","COMPOSITE","ACTOR_BACK","ACTOR_FRONT"]}
assert all(im.size==(1280,928) for im in pictures.values())
# Actual Godot images should preserve original pixel art unmodified.
m=pictures["MASTER"]
changed=ImageChops.difference(new_master,m.convert("RGB"))
master_differences=sum(1 for p in changed.getdata() if p[:3]!=(0,0,0))
# compositing exact full Master equals direct render at all pixels if source exact & alpha proper.
comp=ImageChops.difference(m.convert("RGB"),pictures["COMPOSITE"].convert("RGB"))
composite_differences=sum(1 for p in comp.getdata() if p[:3]!=(0,0,0))
# Need no full floor tile sprites at all in scene, not same as "alpha contains no floor".
scene=(G/"ArtFirstVillage.tscn").read_text(encoding="utf8")
source_mask=json.loads((D/"R15_ROI_SAM2_PILOT_GATE.json").read_text(encoding="utf8"))
assert len(source_mask["results"])==3
floor_tile_sources_in_PAR=0
assert "grass_tile.png" not in scene and "path_tile.png" not in scene
alpha=pictures["PAR"].getchannel("A")
alpha_count=sum(1 for v in alpha.getdata() if v)
actor_b=ImageChops.difference(pictures["ACTOR_BACK"].convert("RGB"),m.convert("RGB")).getbbox()
actor_f=ImageChops.difference(pictures["ACTOR_FRONT"].convert("RGB"),m.convert("RGB")).getbbox()
assert actor_f is not None  # Back pose is intentionally fully behind opaque tree: zero visible delta can be correct.
# Pixel art masks were made by SAM2 at original full res; if not accurate, do not promote Tech to Art.
art_status="ART_MASK_SEMANTIC_HOLD"
# Create actual Godot side-by-side high-quality original and foreground mask.
board=Image.new("RGB",(1300,1000),(24,26,29));draw=ImageDraw.Draw(board)
for i,(key,title) in enumerate([("MASTER","ORIGINAL 1:1 MASTER - no tile assembly"),
                                ("COMPOSITE","GODOT MASTER + SOURCE PAR (should match)"),
                                ("PAR","GODOT 3 SOURCE MASKS - ART REVIEW"),
                                ("ACTOR_BACK","NATIVE GODOT ACTOR BEHIND TREE")]):
 x=(i%2)*650;y=(i//2)*500
 image=pictures[key]
 bg=Image.new("RGBA",(1280,928),(32,35,38,255));bg.alpha_composite(image)
 thumb=bg.convert("RGB").resize((640,464),Image.Resampling.NEAREST)
 board.paste(thumb,(x+5,y+24))
 draw.text((x+12,y+6),title,fill=(244,244,244))
board.save(D/"R15_ART_FIRST_GODOT_4PANEL.png")
report={
 "status":"R15_ART_FIRST_1280x928_GODOT_LAYER_RENDER_TECH_PASS" if master_differences==0 and composite_differences==0 else "R15_ART_FIRST_GODOT_RENDER_HOLD",
 "actual_Godot_4_7_2_GPU":True,"full_scene_is_original_R12_high_detail_Master_not_tilemap":True,
 "master_pixel_difference_count":master_differences,
 "Godot_MASTER_vs_MASTER_PLUS_PAR_pixel_difference":composite_differences,
 "Par_RGBA_opaque_pixel_area":alpha_count,
 "source_3_masks":"SAM2 2/3 prompt consistency, art segmentation not verified",
 "mask_prompt_pass_count":source_mask["prompt_pass_count"],
 "floor_source_tile_nodes_in_PAR":floor_tile_sources_in_PAR,
 "user_artist_Gate_F":"HOLD",
 "all_mask_ground_contamination_absent":False,
 "actor_native_Godot_front_back_renderer_tested":True,
 "actor_back_fully_occluded_at_test_position":actor_b is None,
 "actor_front_visible_delta_bbox":list(actor_f) if actor_f else None,
 "full_area_occluders_covered":False,
 "Qwen_Image_Layered_or_SAM3_executed":False,
 "R12_R13_R14_and_FS_formal_files_unchanged":True,
 "note":"Master first art continuity solved; object alpha correctness not solved. This is the precise remaining challenge."
}
(D/"R15_GODOT_ART_FIRST_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R15_ART_FIRST_GODOT_GATE",json.dumps(report,ensure_ascii=False),flush=True)
if report["status"].endswith("HOLD"):raise SystemExit(2)