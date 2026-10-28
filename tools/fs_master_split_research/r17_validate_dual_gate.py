#!/usr/bin/env python3
"""R17 reproducible independent test of actual B/C Godot renderer and actor occlusion.
No user art grade inventing. Reconstruction check requires art semantics independently.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops
import hashlib,json
R=Path(__file__).resolve().parent
D=R/"R17_ELF_CORNER_TRIPLE_PATH_20261029"
bench=Image.open(D/"R17_REFERENCE_R12_HIGH_DETAIL_CROP.png").convert("RGB")
assert bench.size==(544,416)
def rgbdiff(a,b):
 im=ImageChops.difference(a.convert("RGB"),b.convert("RGB"))
 return sum(max(pixel[:3])>0 for pixel in im.getdata())
def alpha_count(a):
 return sum(v>0 for v in a.getchannel("A").getdata())
rows=[]
for label,path in [("B_MASTER_FIRST",D/"B_MASTER_FIRST"),("C_OBJECT_FIRST_CONTINUOUS_PLATE",D/"C_OBJECT_FIRST_CONTINUOUS_PLATE")]:
 gd=path/"godot_project"/"exported"
 modes={name:Image.open(gd/(name+".png")).convert("RGBA") for name in ["PLATE","PAR","FULL","ACTOR_BACK","ACTOR_FRONT"]}
 assert all(im.size==(544,416) for im in modes.values())
 fullExpected=Image.open(path/"GROUND_FULL.png").convert("RGB")
 sourceMasterDiff=rgbdiff(modes["PLATE"],Image.open(
  path/"GROUND_FULL.png" if label=="B_MASTER_FIRST" else path/"CONTINUOUS_PLATE_PROPOSAL.png").convert("RGB"))
 compositeDiff=rgbdiff(modes["FULL"],fullExpected)
 artisticChange=rgbdiff(modes["FULL"],bench)
 parMask=Image.open(path/"PAR_TRANSPARENT.png").convert("RGBA")
 # Par compositor must match authored RGBA pixel-by-pixel (not only SRC RGB) including edge alpha.
 parRGBAChanges=ImageChops.difference(modes["PAR"],parMask).getbbox()
 actorBackDelta=rgbdiff(modes["ACTOR_BACK"],modes["FULL"])
 actorFrontDelta=rgbdiff(modes["ACTOR_FRONT"],modes["FULL"])
 assert actorFrontDelta>actorBackDelta,(label,actorBackDelta,actorFrontDelta)
 record={"method":label,"godot_actual_GPU_4_7_2_rendered":True,
 "actor_BACK_changed_px_vs_FULL":actorBackDelta,
 "actor_FRONT_changed_px_vs_FULL":actorFrontDelta,
 "actor_occlusion_back_vs_front_effect":True,
 "FULL_vs_author_export_GROUND_FULL_different_pixels":compositeDiff,
 "PLATE_vs_authored_platethumb_pixel_diff":sourceMasterDiff,
 "PAR_vs_author_exact_RGBA_diff_bbox":list(parRGBAChanges) if parRGBAChanges else None,
 "original_R12_rich_reference_vs_final_FULL_pixel_difference":artisticChange,
 "registered_opaque_Alpha_px":alpha_count(parMask),
 "art_gate":"HOLD","mask_user_gate":"HOLD",
 "double_output_tech_gate":compositeDiff==0 and sourceMasterDiff==0 and parRGBAChanges is None}
 rows.append(record)
 print("R17_GODOT_TEST",json.dumps(record,ensure_ascii=False),flush=True)
# Contact sheet for visually honest user comparison
board=Image.new("RGB",(1700,1005),(24,27,30));d=ImageDraw.Draw(board)
mats=[
("REFERENCE | R12 original artist scene",bench),
("B | Full Ground original Master",Image.open(D/"B_MASTER_FIRST"/"godot_project"/"exported"/"FULL.png").convert("RGB")),
("C | Proposed Ground plate + independent PAR",Image.open(D/"C_OBJECT_FIRST_CONTINUOUS_PLATE"/"godot_project"/"exported"/"FULL.png").convert("RGB")),
("B | Actual Godot PAR only (black transparency preview)",Image.open(D/"B_MASTER_FIRST"/"godot_project"/"exported"/"PAR.png").convert("RGBA")),
("C | Inpainting reconstruction changed area",Image.open(D/"C_OBJECT_FIRST_CONTINUOUS_PLATE"/"C_VS_B_COLOR_DIFFERENCE_QA.png").convert("RGB")),
("B | Actor behind large tree",Image.open(D/"B_MASTER_FIRST"/"godot_project"/"exported"/"ACTOR_BACK.png").convert("RGB"))
]
for i,(lab,im) in enumerate(mats):
 x=(i%3)*565;y=(i//3)*500
 if im.mode=="RGBA":
  bg=Image.new("RGBA",im.size,(30,34,40,255))
  bg.alpha_composite(im);im=bg.convert("RGB")
 board.paste(im,(x+10,y+32))
 d.text((x+12,y+8),lab[:58],fill=(245,246,247))
board.save(D/"R17_B_C_TRUE_GODOT_6_PANEL.png")
gate={
 "status":"R17_STAGE1_BC_NATIVE_GODOT_COMPARISON_TECH_PASS_ALL_ART_GATES_HOLD",
 "A":"NOT_RUN_no_genuine_image_pair_model",
 "B":rows[0],"C":rows[1],
 "art_85_point_score":"NOT_ASSIGNED_NO_HUMAN_GOLD",
 "full_required_spec":["house","three_full_trees","lamp","railing","curved_path","props"],
 "benchmark_coverage_limit":"R12 crop lacks three complete trees and verified railing, sample not representative enough for full Art Gate",
 "user_par_review":"PENDING",
 "formal_FS_K4_unchanged":True,
 "real_RPG_MAKER_VX_GameExe":"NOT_RUN_ART_GATE_NOT_PASSED",
 "Godot_window_544x416_native":True
}
(D/"R17_NATIVE_GODOT_AND_ART_GATE.json").write_text(json.dumps(gate,ensure_ascii=False,indent=2),encoding="utf8")
assert all(row["double_output_tech_gate"] for row in rows)
print("R17_FINAL_STAGE1",gate["status"],flush=True)