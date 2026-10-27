#!/usr/bin/env python3
"""Per-object dynamic occlusion simulation on full flattened ground. Concept QA only."""
from PIL import Image
from pathlib import Path
import numpy as np,json
root=Path(__file__).resolve().parent
src=root/"SCENE21_GUIDED_SAM2_CANDIDATE"
out=root/"OCCLUSION_GRID_R1_20261027"
meta=json.loads((out/"OCCLUSION_GRID_R1_METRICS.json").read_text(encoding="utf-8"))
M=np.asarray(Image.open(src/"MASTER_RGBA.png").convert("RGBA"))
files=["house_SAM2_RAW.png","left_tree_SAM2_RAW.png","right_tree_prompt_v2_variant1.png"]
o=meta["selected_objects"]; masks=[]
for obj,f in zip(o,files):
 m=(np.asarray(Image.open(src/f).convert("L"))>0)
 m=m & (np.arange(M.shape[0])[:,None]<obj["upper_occlusion_y_exclusive"])
 masks.append(m)
char_dir=Path("/mnt/e/GameAssetToolLab_20261023/FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE/Graphics/Characters")
im=Image.open(char_dir/"$001.png").convert("RGBA"); actor=np.asarray(im.crop((32,0,64,32)))
def render(x,y,par_flags):
 result=Image.fromarray(M,"RGBA")
 result.alpha_composite(Image.fromarray(actor),(x-16,y-32))
 occlude=np.logical_or.reduce([a for a,b in zip(masks,par_flags) if b]) if any(par_flags) else np.zeros(M.shape[:2],dtype=bool)
 fg=np.zeros_like(M);fg[occlude]=M[occlude];fg[:,:,3]=occlude.astype(np.uint8)*255
 result.alpha_composite(Image.fromarray(fg))
 return np.asarray(result),occlude
results=[]
for idx,(x,y) in enumerate([[160,168],[160,197],[342,214],[471,240]]):
 static,_=render(x,y,[True]*len(o))
 front_flags=[y < ob["foot_estimate"][1] for ob in o]
 dynamic,_=render(x,y,front_flags)
 isfront=[name["name"] for name,en in zip(o,front_flags) if not en]
 difference=int(np.any(static!=dynamic,axis=2).sum())
 Image.fromarray(static).save(out/f"R2_ACTOR_{idx}_STATIC.png")
 Image.fromarray(dynamic).save(out/f"R2_ACTOR_{idx}_FOOT_SORTED_SIMULATION.png")
 compare=Image.new("RGBA",(1088,416));compare.paste(Image.fromarray(static),(0,0));compare.paste(Image.fromarray(dynamic),(544,0))
 compare.save(out/f"R2_ACTOR_{idx}_STATIC_vs_DYNAMIC.png")
 results.append({"actor_foot":[x,y],"objects_behind_actor_by_foot":isfront,
                 "pixel_diffs_between_static_and_dynamic":difference,"per_object_front_flags":dict(zip([z["name"] for z in o],front_flags))})
(out/"R2_DYNAMIC_DEPTH_SIMULATION.json").write_text(json.dumps({"status":"SIMULATION_ONLY_NOT_REAL_NATIVE_VX","results":results,
  "note":"Global PAR toggling is NOT multi-character correct. A real engine would sort each foreground object against each player/NPC by foot depth; source Ground remains untouched."},ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps(results))