from pathlib import Path
from PIL import Image
import numpy as np,json
root=Path(__file__).resolve().parent
dir=root/"R5_FORMAL_ADAPTER_ISOLATED"/"NATIVE_CAPTURE"
cases=[("PLAYER_FRONT_NPC_BEHIND",(4,5),(4,3)),
       ("PLAYER_BEHIND_NPC_FRONT",(4,3),(4,5)),
       ("BOTH_FRONT",(4,5),(5,5)),
       ("BOTH_BEHIND",(4,3),(5,3)),("CLEAR",(8,9),(9,9))]
master=np.asarray(Image.open(root/"MASTER_OPAQUE_BLACK_MATTE.png").convert("RGB"))
h,w=master.shape[:2]
rows=[]
for name,pa,np_ in cases:
 A=np.asarray(Image.open(dir/"HK_STATIC"/(name+".png")).convert("RGB"))
 B=np.asarray(Image.open(dir/"DYNAMIC_ADAPTER"/(name+".png")).convert("RGB"))
 d=np.any(A!=B,axis=-1)
 regions={}
 def area(tile):
  x,y=tile
  mask=np.zeros((h,w),dtype=bool)
  mask[max(0,y*32-22):min(h,y*32+41),max(0,x*32-7):min(w,x*32+40)]=True
  return mask
 p=area(pa);n=area(np_)
 res={"case":name,"comparison_diff_total_px":int(d.sum()),"comparison_diff_nonactor_px":int((d&~(p|n)).sum()),"comparison_diff_actor_px":int((d&(p|n)).sum()),
 "static_vs_ground_nonactor_px":int((np.any(A!=master,axis=-1)&~(p|n)).sum()),
 "dynamic_vs_ground_nonactor_px":int((np.any(B!=master,axis=-1)&~(p|n)).sum()),
 "region_actor_static_avg_rgb":np.round(A[p].mean(axis=0),1).tolist(),
 "region_actor_depth_avg_rgb":np.round(B[p].mean(axis=0),1).tolist()}
 rows.append(res)
 Image.fromarray((d*255).astype(np.uint8)).save(dir/(name+"_DIFF.png"))
 combo=Image.new("RGB",(1088,416));combo.paste(Image.fromarray(A),(0,0));combo.paste(Image.fromarray(B),(544,0))
 combo.save(dir/(name+"_COMPARE.png"))
 print(json.dumps(res,ensure_ascii=False),flush=True)
report={"status":"R5_505_SCRIPT_RUNTIME_BOOTED_BOTH_VARIANTS_BUT_VISUAL_GATE_UNRESOLVED",
"metadata":{"original_505_count":505,"isolated_modified_original_page":480,"extra_r5_test_adapter":1,
            "actual_HK_UOM_and_ISS_ParaPassa_original_byte_identical":True,"full_scripts_unmodified_tested":False},
"cases":rows,"visual_notices":["Native full FS 505 minus regression page has additional UI and dark tones unlike isolated B1 benchmark","Potential player sprite visibility and unintended effect overlays need independent check","Do not interpret source color differences as parallax geometry errors until tone/UI isolation"]}
(dir/"R5_REAL505_VISUAL_COMPARISON_AUDIT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")