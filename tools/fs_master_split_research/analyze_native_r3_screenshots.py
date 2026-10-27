#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import numpy as np, json
ROOT=Path(__file__).resolve().parent
LOG=ROOT/"R3_NATIVE_SCREENSHOTS"
TAGS=["TREE_BEHIND","TREE_FRONT","HOUSE_BEHIND","HOUSE_FRONT","RIGHT_BEHIND","RIGHT_FRONT","CLEAR"]
POS={"TREE_BEHIND":(4,3),"TREE_FRONT":(4,5),"HOUSE_BEHIND":(10,4),"HOUSE_FRONT":(10,6),"RIGHT_BEHIND":(14,4),"RIGHT_FRONT":(14,7),"CLEAR":(8,9)}
M=np.asarray(Image.open(ROOT/"MASTER_OPAQUE_BLACK_MATTE.png").convert("RGB"))
checks={}
for t in TAGS:
 s=np.asarray(Image.open(LOG/f"STATIC_{t}.png").convert("RGB"))
 d=np.asarray(Image.open(LOG/f"DEPTH_{t}.png").convert("RGB"))
 assert s.shape==M.shape and d.shape==M.shape
 tx,ty=POS[t]; px=tx*32+16;fy=ty*32+32
 roi=np.zeros(M.shape[:2],dtype=bool)
 roi[max(0,fy-65):min(M.shape[0],fy+8),max(0,px-32):min(M.shape[1],px+32)]=True
 mask=np.any(s!=d,axis=2)
 s_bg=int(np.any(s[~roi]!=M[~roi],axis=-1).sum())
 d_bg=int(np.any(d[~roi]!=M[~roi],axis=-1).sum())
 inside=int((mask&roi).sum());outside=int((mask&~roi).sum())
 checks[t]={"tile":[tx,ty],"foot":[px,fy],"diff_static_depth_px":int(mask.sum()),"diff_in_actor_roi":inside,"diff_outside_actor_roi":outside,"static_bg_master_bad_px":s_bg,"depth_bg_master_bad_px":d_bg}
 Image.fromarray(mask.astype(np.uint8)*255).save(LOG/f"DIFF_STATIC_DEPTH_{t}.png")
 comp=Image.new("RGB",(1088,416));comp.paste(Image.fromarray(s),(0,0));comp.paste(Image.fromarray(d),(544,0));comp.save(LOG/f"COMPARE_STATIC_DEPTH_{t}.png")
 print("R3_NATIVE_PIXEL",t,checks[t],flush=True)
front=[t for t in TAGS if t.endswith("FRONT")]
behind=[t for t in TAGS if t.endswith("BEHIND")]
gates={
 "both_variants_actual_native_VX_captured":True,
 "native_screenshots_14":True,
 "all_nonactor_background_pixels_source_exact":all(v["static_bg_master_bad_px"]==v["depth_bg_master_bad_px"]==0 for v in checks.values()),
 "no_nonactor_changes_between_static_and_depth":all(v["diff_outside_actor_roi"]==0 for v in checks.values()),
 "any_front_probe_dynamic_difference":any(checks[k]["diff_in_actor_roi"]>0 for k in front),
 "all_behind_probes_static_equal_depth":all(checks[k]["diff_in_actor_roi"]==0 for k in behind),
 "clear_area_static_equal_depth":checks["CLEAR"]["diff_in_actor_roi"]==0,
 "human_visual_gate":False,
 "actual_formal_fs_sealed_scripts_tested":False,
}
status="ISOLATED_NATIVE_VX_TECH_PASS" if all(v for k,v in gates.items() if k not in ("human_visual_gate","actual_formal_fs_sealed_scripts_tested")) else "ART_HOLD_OR_NATIVE_QA_FAIL"
report={"status":status,"gates":gates,"checks":checks,"source_image_sha256":"67a9c9618882d7c0dfb7f0ab893cc471ad0ccc3ed3e58904bb7babc3bd5ef274","notes":"Screen pixels from actual test-only VX Game.exe. Source textures derived from same original fully painted 544x416 image. Test-only data/map script, NOT formal 505-script runtime.","semantic_mask_pass":False}
(LOG/"R3_NATIVE_COMPARISON.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R3_NATIVE_VERDICT",status,json.dumps(gates,ensure_ascii=False),flush=True)
if status!="ISOLATED_NATIVE_VX_TECH_PASS":
 raise SystemExit("R3_NATIVE_QA_FAIL_CLOSED")