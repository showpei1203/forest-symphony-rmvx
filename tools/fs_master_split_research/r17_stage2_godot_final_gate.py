#!/usr/bin/env python3
"""R17 Stage2 real new generated village master -> 11 separate SAM2 candidate masks -> Godot.
Strict compositor/sources, but weak semantic ground negative checks flagged; ART F HOLD.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageChops
import json,hashlib,cv2,numpy as np
R=Path(__file__).resolve().parent;D=R/"R17_STAGE2_NEW_ART_20261029"
G=D/"godot_project"/"exported"
orig=Image.open(D/"MASTER_STAGE2_NEW_GENERATED.png").convert("RGBA")
i={name:Image.open(G/("R17_STAGE2_"+name+".png")).convert("RGBA") for name in ["MASTER","PAR","FULL","ACTOR_BACK","ACTOR_FRONT"]}
mask=Image.open(D/"R17_STAGE2_PAR_11_OBJECT_SOURCE_CANDIDATE.png").convert("RGBA")
r1=json.loads((D/"R17_STAGE2_NEW_ART_SAM2_GATE.json").read_text(encoding="utf8"))
r2=json.loads((D/"R17_STAGE2_R2_11OBJECT_GATE.json").read_text(encoding="utf8"))
assert all(a.size==(544,416) for a in i.values())
def count_rgbdiff(a,b):
 dif=ImageChops.difference(a.convert("RGB"),b.convert("RGB"))
 return sum(int(any(px[:3])) for px in dif.getdata())
def count_alphadiff(a,b):
 aa=np.asarray(a.convert("RGBA"),dtype=np.int16)
 bb=np.asarray(b.convert("RGBA"),dtype=np.int16)
 return int(np.any(aa!=bb,axis=2).sum())
master_diff=count_rgbdiff(orig,i["MASTER"])
full_diff=count_rgbdiff(orig,i["FULL"])
par_diff=count_alphadiff(mask,i["PAR"])
base=np.asarray(orig.convert("RGB"))
alpha=np.asarray(mask.getchannel("A"))>0
rgba=np.asarray(mask)
source_rgb_exact=bool(np.array_equal(base[alpha],rgba[alpha,:3]))
assert master_diff==full_diff==par_diff==0 and source_rgb_exact
back_diff=count_rgbdiff(i["ACTOR_BACK"],i["FULL"])
front_diff=count_rgbdiff(i["ACTOR_FRONT"],i["FULL"])
assert front_diff>0 and back_diff==0
ground_violations=[]
for reg in r1["ground_only_rois"]:
 sel=np.zeros((416,544),np.uint8)
 cv2.fillPoly(sel,[np.array(reg["polygon"],np.int32)],1)
 n=int(((sel>0)&alpha).sum())
 ground_violations.append({"ground_only_candidate":reg["name"],"PAR_alpha_overlap_px":n})
# Individually review alpha semantics: not all 11 have prompt-point PASS, and ground-only three ROIs are sparse.
num_prompts_pass=(sum(x["mask_seed_gate"]=="PASS" for x in r1["candidate_objects"])
   - (1 if r2["old_bridge_refine_accepted"] else 0)
   +sum(x["prompt_gate"]=="PASS" for x in r2["objects_new"])
   +(1 if r2["old_bridge_refine_accepted"] else 0))
# simplify mathematically: R1 orig four passes, bridge improved one, R2 4 passes => nine
num_prompts_pass=sum(x["mask_seed_gate"]=="PASS" for x in r1["candidate_objects"])+sum(x["prompt_gate"]=="PASS" for x in r2["objects_new"])+int(r2["old_bridge_refine_accepted"])
# preview grid from truly Godot rendered output
board=Image.new("RGB",(1116,936),(27,30,34));pen=ImageDraw.Draw(board)
for index,(name,description) in enumerate([
("MASTER","01 NEW Master image, original image-generation artwork"),
("FULL","02 Godot full render, source exact"),
("PAR","03 Independent transparent PAR11 from source RGB"),
("ACTOR_FRONT","04 Actual Godot front-of-tree actor")]):
 x= (index%2)*558;y=(index//2)*467
 scene=i[name]
 bg=Image.new("RGBA",scene.size,(29,34,39,255))
 bg.alpha_composite(scene)
 board.paste(bg.convert("RGB"),(x+6,y+32))
 pen.text((x+8,y+9),description,fill="white")
board.save(D/"R17_STAGE2_TRUE_GODOT_4PANEL.png")
# Crop sampled object + edge/road to visualize 2x preserving pixel coords, no fake prettification
review=Image.new("RGB",(1088,848),(25,27,30))
rects=[
((0,0,272,208),"Roof details 2x"),
((272,0,544,208),"Trees / lamp 2x"),
((0,208,272,416),"Stairs / fences 2x"),
((272,208,544,416),"Market / bridge / tree 2x")]
draw=ImageDraw.Draw(review)
for k,(bounds,name) in enumerate(rects):
 x=(k%2)*544;y=(k//2)*424
 piece=orig.convert("RGB").crop(bounds).resize((544,416),Image.Resampling.NEAREST)
 review.paste(piece,(x,y+8))
 draw.text((x+8,y+1),name,fill="white")
review.save(D/"R17_STAGE2_DETAIL_2X_4_PANEL.png")
# Fail closed new art / semantics: current master is from illustration collage crop; house top goes off-map, tree objects edges clipped.
report={
 "status":"R17_STAGE2_NEW_ART_GODOT_11OBJECT_TECH_PASS_ART_HOLD",
 "real_Godot_4_7_2_GPU":True,
 "art_master_path":"MASTER_STAGE2_NEW_GENERATED.png",
 "art_master_origin":"Generated illustration board; cropped its master panel at 544x416, NOT original R12 art",
 "new_master_sha256":hashlib.sha256((D/"MASTER_STAGE2_NEW_GENERATED.png").read_bytes()).hexdigest(),
 "canvas":[544,416],"registered_objects":11,
 "PAR_alpha_opaque_pixels":int(alpha.sum()),
 "PAR_rgb_exact_from_master":source_rgb_exact,
 "Godot_MASTER_vs_new_MASTER_RBG_difference_count":master_diff,
 "Godot_FULL_vs_new_MASTER_RGB_difference_count":full_diff,
 "Godot_PAR_vs_selected_RGBA_pixel_difference":par_diff,
 "actor_back_delta_pixels":back_diff,"actor_front_delta_pixels":front_diff,
 "SAM2_prompt_seeds_pass_count":int(num_prompts_pass),
 "SAM2_prompt_seeds_candidate_count":11,
 "ground_only_negative_ROI_overlap":ground_violations,
 "all_3_distinct_trees_complete_in_frame":False,
 "house_full_building_unclipped":False,
 "source_master_art_at_pixel_native_scale_approved":False,
 "candidate_alpha_all_objects_complete":False,
 "artist_par_pixel_edges_human_approved":False,
 "R17_hard_art_gate":"HOLD",
 "R17_hard_PAR_semantic_gate":"HOLD",
 "FS_VX_original_native_test_done":False,
 "formal_Seal":False,
 "known_limitations":[
 "Generated collage panel was converted into a standalone 544x416 Master candidate, not an approved pixel-art asset",
 "Two thin fence candidates have missed positive seeds and their contours may overlap floor",
 "Complete house and all three trees are cropped by frame; must regenerate camera composition",
 "Godot compositing 0px alone cannot validate ground-contamination or object coverage",
 "Missing non-registered foliage, rail segments, tiny light posts, and environmental details"],
 "original_FS_K4_untouched":True}
(D/"R17_STAGE2_GODOT_FINAL_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_STAGE2_FINAL",json.dumps({k:report[k] for k in ["status","PAR_alpha_opaque_pixels","Godot_FULL_vs_new_MASTER_RGB_difference_count","Godot_PAR_vs_selected_RGBA_pixel_difference","actor_back_delta_pixels","actor_front_delta_pixels","SAM2_prompt_seeds_pass_count","ground_only_negative_ROI_overlap"]},ensure_ascii=False),flush=True)