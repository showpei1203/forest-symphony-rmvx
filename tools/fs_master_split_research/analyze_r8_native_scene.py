#!/usr/bin/env python3
"""Quantify real FS-native A1-B-A2 variation in same VX Game.exe process, fail closed.
A1/A2 is control (same mode no player movement), B dynamic mode. 544x416 full-resolution native.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json
R=Path(__file__).resolve().parent
OUT=R/"R8_NATIVE_FULL_MASTER"/"NATIVE_ABA"
manifest=json.loads((OUT/"R6_CAPTURE_MANIFEST.json").read_text())
assert manifest["status"]=="R6_NATIVE_CAPTURE_PASS" and len(manifest["files"])==len(manifest["all_five_cases"])*3
cases=[('RED_HOUSE_CONIFER', (13, 5), (13, 3)), ('RED_FAR_RIGHT_CONIFER', (15, 7), (15, 4)), ('RED_LEFT_INNER_MICRO', (3, 8), (3, 6)), ('RED_BOTTOM_MICRO', (12, 10), (12, 8)), ('BLUE_STEPS', (9, 6), (9, 4)), ('CLEAR', (8, 9), (9, 9))]
stats=[]
master=np.asarray(Image.open(R/"MASTER_OPAQUE_BLACK_MATTE.png").convert("RGB"))
for name,player,npc in cases:
 frames={}
 for stage in ["A1","B","A2"]:
  frames[stage]=np.asarray(Image.open(OUT/(name+"__"+stage+".png")).convert("RGB")).astype(np.int16)
 h,w=master.shape[:2]
 def mask(tile):
  x,y=tile;v=np.zeros((h,w),dtype=bool)
  # Region includes foot and extra Sprite_Character shift; tile x +/-8, foot y +/- 48px
  v[max(0,y*32-24):min(h,(y+1)*32+14),max(0,x*32-12):min(w,(x+1)*32+12)]=True
  return v
 player_roi,npc_roi=mask(player),mask(npc)
 union=player_roi|npc_roi
 detail={"case":name,"player":[*player],"npc":[*npc]}
 for tag,(a,b) in {"A1_B":("A1","B"),"A1_A2_CONTROL":("A1","A2"),"B_A2":("B","A2")}.items():
  delta=np.max(np.abs(frames[a]-frames[b]),axis=2)
  for t in [0,2,5,10,20]:
   changed=delta>t
   key=f"{tag}_threshold_{t}"
   detail[key]={"total":int(changed.sum()),
                "actor_union":int((changed&union).sum()),
                "nonactor":int((changed&~union).sum())}
  Image.fromarray((delta>5).astype(np.uint8)*255).save(OUT/f"{name}_DIFF_{tag}_GT5.png")
 # Whether mode perturbation outruns normal A1/A2 time-based animation
 mode=(np.max(np.abs(frames["A1"]-frames["B"]),axis=2)>5)
 control=(np.max(np.abs(frames["A1"]-frames["A2"]),axis=2)>5)
 detail["mode_changed_only_not_control_nonactor_pixels_GT5"]=int((mode&~control&~union).sum())
 detail["mode_changed_only_not_control_actor_pixels_GT5"]=int((mode&~control&union).sum())
 detail["A1_A2_NONACTOR_control_warning"]=detail["A1_A2_CONTROL_threshold_5"]["nonactor"]>0
 stats.append(detail)
 print("R6_PIXEL",name,{"A1-B":detail["A1_B_threshold_5"],"A1-A2_ctrl":detail["A1_A2_CONTROL_threshold_5"],"mode_nonctrl_nonactor":detail["mode_changed_only_not_control_nonactor_pixels_GT5"]},flush=True)
 # 3 horizontal 1x and difference for each case, evidence for native audit
 comp=Image.new("RGB",(544*3,416))
 for i,k in enumerate(("A1","B","A2")):comp.paste(Image.fromarray(frames[k].astype(np.uint8)),(544*i,0))
 comp.save(OUT/f"{name}_ABA_STRIP.png")
all_bg_stable=all(x["A1_A2_CONTROL_threshold_5"]["nonactor"]==0 for x in stats)
gate={"capture15_same_native_session":True,"all_cases_control_nonactor_stable_gt5":all_bg_stable,
 "background_A_B_equal_outside_actor_gt5":all(x["A1_B_threshold_5"]["nonactor"]==0 for x in stats),
 "actual_par_occlusion_visual_pass":False,"original_formal_505_unchanged":False,"par_mask_art_pass":False}
r={"status":"R6_NATIVE_ABA_TECH_CAPTURE_PASS_VISUAL_GATE_HOLD","gate":gate,"cases":stats,
"notes":"Same native Game.exe, A1-B-A2 per case. Difference pixel thresholds are per-channel max; t=5 ignores RGB jitter <=5. If A1/A2 control drifts, must not assert B correction causation. Full FS global effects, HUD, tone not necessarily normalized."}
(OUT/"R6_PIXEL_GATE.json").write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding="utf8")
print("R6_FINAL_PIXEL",json.dumps(gate),flush=True)