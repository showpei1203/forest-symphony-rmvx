#!/usr/bin/env python3
"""Compare ACTUAL two separately authored layers vs false precomposited ground+cut PAR.
No SAM, no cropping, no collision, no VX script edits. Ground/Par previews only, fail closed.
"""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import json,hashlib
ROOT=Path(__file__).resolve().parent
D=ROOT/"R17_DIRECT_DUAL_OUTPUT_CORRECTION_20261029"
D.mkdir(exist_ok=True)
R14=ROOT/"R14_GODOT_LAYER_AUTHORING_20261028"/"godot_project"/"exported"
R17=ROOT/"R17_STAGE2_NEW_ART_20261029"
cases=[
 {"id":"R14_GENUINE_LAYERED_SOURCE_TECH_BASELINE",
  "ground":R14/"GODOT_BASE.png","par":R14/"GODOT_PAR.png",
  "reference_full":R14/"GODOT_FULL.png","source_method":"Godot original layer source sprites",
  "independently_authored":True,"ground_has_baked_raised_objects":False,
  "ground_art_grade":"FAIL_221_FLOOR_TILES_ONLY_2_UNIQUE_ASSETS",
  "known_ground_only_test_tiles":[(0,0),(8,12),(9,12),(16,12),(14,0)],
  "status_expected":"DIRECT_LAYER_TECH_PASS_ART_FAIL"},
 {"id":"R17_STAGE2_BAKED_MASTER_NOT_ACCEPTABLE_AS_GROUND",
  "ground":R17/"MASTER_STAGE2_NEW_GENERATED.png",
  "par":R17/"R17_STAGE2_PAR_11_OBJECT_SOURCE_CANDIDATE.png",
  "reference_full":R17/"MASTER_STAGE2_NEW_GENERATED.png",
  "source_method":"Art Master already contains all raised objects + SAM2 segmented partial PAR",
  "independently_authored":False,"ground_has_baked_raised_objects":True,
  "ground_art_grade":"HOLD_ILLUSTRATION_CROPPED_BUILDING_AND_TREES",
  "known_ground_only_test_tiles":[],
  "status_expected":"DIRECT_LAYER_PROVENANCE_FAIL"}]
reports=[]
for case in cases:
 ground=Image.open(case["ground"]).convert("RGBA")
 par_original=Image.open(case["par"])
 assert par_original.mode=="RGBA",f"{case['id']} must truly be RGBA"
 par=par_original.convert("RGBA")
 assert ground.size==par.size==(544,416)
 alpha=par.getchannel("A")
 zero=sum(v==0 for v in alpha.getdata())
 nonzero=sum(v>0 for v in alpha.getdata())
 assert zero>0 and nonzero>0
 preview=Image.alpha_composite(ground,par)
 target=Image.open(case["reference_full"]).convert("RGBA")
 pixel_diff=ImageChops.difference(preview,target).convert("RGB")
 diff_count=sum(any(rgb) for rgb in pixel_diff.getdata())
 is_pixels_aligned=diff_count==0
 floors={}
 for tx,ty in case["known_ground_only_test_tiles"]:
  floor_px=sum(v!=0 for v in alpha.crop((tx*32,ty*32,(tx+1)*32,(ty+1)*32)).getdata())
  floors[f"{tx},{ty}"]=floor_px
 floor_negative_test=all(x==0 for x in floors.values())
 # Truthful FAIL: reusing a pretty complete Master as Ground is NOT a separately authored ground layer.
 provenance_pass=case["independently_authored"] and not case["ground_has_baked_raised_objects"]
 structural_pass=provenance_pass and is_pixels_aligned and floor_negative_test
 art_pass=False # actual original R14 has tile seams; R17 not correctly split
 prefix=case["id"]
 for input_path, name in [(case["ground"],"GROUND_LAYER.png"),(case["par"],"PAR_LAYER.png")]:
  import shutil
  shutil.copy2(input_path,D/(prefix+"_"+name))
 preview.save(D/(prefix+"_COMPOSITE_QA_ONLY.png"))
 # Checkerboard only for on-screen review; alpha truth still in PAR source PNG.
 tile=16
 chk=Image.new("RGBA",par.size,(255,255,255,255))
 draw=ImageDraw.Draw(chk)
 for y in range(0,416,tile):
  for x in range(0,544,tile):
   if ((x//tile)+(y//tile))%2==0:
    draw.rectangle((x,y,x+tile-1,y+tile-1),fill=(174,178,185,255))
 chk.alpha_composite(par)
 chk.convert("RGB").save(D/(prefix+"_PAR_CHECKER_REVIEW_ONLY.png"))
 reports.append({
  "id":prefix,"ground_file_original":str(case["ground"].relative_to(ROOT)),
  "par_file_original":str(case["par"].relative_to(ROOT)),
  "both_width_height":[544,416],
  "PAR_true_RGBA_alpha0_pixels":zero,"PAR_alpha_nonzero_pixels":nonzero,
  "PAR_only_illustration_checkerboard":False,
  "composite_preview_vs_existing_complete_RGB_different_pixels":diff_count,
  "independent_layer_provenance_verified":provenance_pass,
  "ground_prebaked_with_raised_objects":case["ground_has_baked_raised_objects"],
  "floor_only_5_sample_par_alpha_px":floors,
  "floor_only_samples_zero":floor_negative_test,
  "dual_layer_technical_pass":structural_pass,
  "art_quality_pass":art_pass,
  "final_pair_user_accepted":False,
  "status":case["status_expected"],
  "note":"Composite 0px is NOT enough: BAKED master+PAR can also return 0px because identical source art. Require separate Ground source and PAR source provenance.",
  "source_method":case["source_method"],
  "art_status":case["ground_art_grade"]})
# User review: both examples demonstrate distinct failure reasons. Equal 0 pixel compositor does not prove dual layers.
board=Image.new("RGB",(1676,964),(25,28,31));draw=ImageDraw.Draw(board)
for row,case in enumerate(cases):
 p=case["id"]
 for col,name in enumerate(("GROUND_LAYER.png","PAR_CHECKER_REVIEW_ONLY.png","COMPOSITE_QA_ONLY.png")):
  im=Image.open(D/(p+"_"+name)).convert("RGBA")
  bg=Image.new("RGBA",im.size,(27,30,35,255));bg.alpha_composite(im)
  x=col*558+7;y=row*480+27
  board.paste(bg.convert("RGB"),(x,y))
  draw.text((x,y-19),("R14 SOURCE FIRST" if row==0 else "R17 BAKED GROUND FAIL")+" | "+["Ground","PAR real alpha","Preview only"][col],fill="white")
board.save(D/"R17_USER_CORRECTION_TRUE_LAYER_VS_PREBAKED_6PANEL.png")
out={"authority":"R17_DIRECT_GROUND_PAR_AUTHORITY.md",
 "status":"R17_USER_DIRECT_DUAL_OUTPUT_RULE_VERIFIED_ON_TWO_HISTORICAL_BASELINES",
 "ground_Pair_art_pass_count":0,
 "R14_structural_technical_pass_R17_prebaked_provenance_fail":True,
 "only_required_outputs":["GROUND.png","PAR.png"],
 "user_merges_into_new_ground_themselves":True,
 "user_sets_collision_in_FS_by_self":True,
 "model_SAM_par_cutting_is_not_default_production":True,
 "Godot_and_VX_actor_tests_are_not_required_by_user":True,
 "note":"Historical test inputs; no claim new high quality image pair has been generated.",
 "cases":reports}
(D/"R17_DIRECT_PAIR_PROVENANCE_GATE.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_CORRECTED",json.dumps({x["id"]:{"tech_dual":x["dual_layer_technical_pass"],"art":x["art_quality_pass"],"diff":x["composite_preview_vs_existing_complete_RGB_different_pixels"],"transparent":x["PAR_true_RGBA_alpha0_pixels"]} for x in reports},ensure_ascii=False),flush=True)