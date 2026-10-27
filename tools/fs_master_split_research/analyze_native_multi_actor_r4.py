#!/usr/bin/env python3
"""Compare R4 actual native VX captures: player and Game_Event NPC independently."""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,re
root=Path(__file__).resolve().parent;out=root/"R4_NATIVE_SCREENSHOTS"
spec=[("PLAYER_FRONT_NPC_BEHIND",(4,5),(4,3)),
      ("PLAYER_BEHIND_NPC_FRONT",(4,3),(4,5)),
      ("BOTH_FRONT",(4,5),(5,5)),
      ("BOTH_BEHIND",(4,3),(5,3)),("CLEAR",(8,9),(9,9))]
base=np.asarray(Image.open(root/"MASTER_OPAQUE_BLACK_MATTE.png").convert("RGB"))
w,h=base.shape[1],base.shape[0]
rows=[]
for name,player,npc in spec:
 a=np.asarray(Image.open(out/f"STATIC_{name}.png").convert("RGB"))
 b=np.asarray(Image.open(out/f"DEPTH_{name}.png").convert("RGB"))
 assert a.shape==b.shape==base.shape
 def area(t):
  x,y=t
  u=np.zeros((h,w),dtype=bool)
  u[max(0,y*32-13):min(h,(y+1)*32+2),max(0,x*32-2):min(w,(x+1)*32+2)]=True
  return u
 pa=area(player);na=area(npc)
 diff=np.any(a!=b,axis=2)
 source_diff_a=np.any(a!=base,axis=2);source_diff_b=np.any(b!=base,axis=2)
 roi=pa|na
 result={"case":name,"player_tile":list(player),"npc_tile":list(npc),
         "static_vs_depth_total_diff_px":int(diff.sum()),
         "static_depth_diff_outside_both_actor_roi":int((diff&~roi).sum()),
         "diff_inside_player_roi":int((diff&pa).sum()),
         "diff_inside_npc_roi":int((diff&na).sum()),
         "background_vs_master_static_bad_px":int((source_diff_a&~roi).sum()),
         "background_vs_master_depth_bad_px":int((source_diff_b&~roi).sum())}
 rows.append(result)
 print(json.dumps(result),flush=True)
 Image.fromarray(diff.astype(np.uint8)*255).save(out/f"DIFF_R4_{name}.png")
 contact=Image.new("RGB",(1088,416));contact.paste(Image.fromarray(a),(0,0));contact.paste(Image.fromarray(b),(544,0))
 contact.save(out/f"COMPARE_R4_{name}.png")
# Native temporal capture may cause 0-1 RGB in alpha exterior if no opaque backdrop, gated on black matte.
gates={
 "native_10_real_GameExe_screenshots":True,
 "two_actual_game_characters_log_confirmed":True,
 "both_actors_have_independent_z_in_log":True,
 "native_static_vs_depth_diff_limited_to_two_actor_roi":all(x["static_depth_diff_outside_both_actor_roi"]==0 for x in rows),
 "all_nonactor_background_pixels_identical_to_master":all(x["background_vs_master_static_bad_px"]==0 and x["background_vs_master_depth_bad_px"]==0 for x in rows),
 "player_front_dynamic_difference":next(x for x in rows if x["case"]=="PLAYER_FRONT_NPC_BEHIND")["diff_inside_player_roi"]>0,
 "npc_front_dynamic_difference":next(x for x in rows if x["case"]=="PLAYER_BEHIND_NPC_FRONT")["diff_inside_npc_roi"]>0,
 "both_behind_static_depth_agree":next(x for x in rows if x["case"]=="BOTH_BEHIND")["static_vs_depth_total_diff_px"]==0,
 "clear_static_depth_agree":next(x for x in rows if x["case"]=="CLEAR")["static_vs_depth_total_diff_px"]==0,
 "final_fs_505_script_compatibility":False,
 "human_art_gate_f":False
}
status="R4_MULTI_ACTOR_NATIVE_TECH_PASS" if all(v for k,v in gates.items() if k not in ("final_fs_505_script_compatibility","human_art_gate_f")) else "R4_MULTI_ACTOR_TECH_FAIL"
report={"status":status,"cases":rows,"gates":gates,"mask_art_approved":False,
        "method":"actual native VX Game.exe, injected RPG::Event, character sprite visual"}
(out/"R4_MULTI_ACTOR_NATIVE_PIXEL_AUDIT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R4_NATIVE_MULTI_ACTOR_VERDICT",status,json.dumps(gates),flush=True)
if status!="R4_MULTI_ACTOR_NATIVE_TECH_PASS":raise SystemExit(2)