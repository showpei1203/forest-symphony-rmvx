from pathlib import Path
from PIL import Image
import numpy as np,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
native=root/"VX_A09_4_N5_RUNTIME"/"ASF_A094_NATIVE_PROOFS"
project=root/"vx_real_actor_20261031"/"a09_2_actor_poses"/"engine"/"godot"
out=root/"vx_real_actor_20261031"/"a09_4"
variants={"nearest":project/"A094_GODOT_12_TILES_NATIVE_VALUES.png","linear":project/"A094_GODOT_12_TILES_LINEAR.png"}
results={}
for kind,path in variants.items():
 arr=np.asarray(Image.open(path).convert("RGB"),dtype=np.int16)
 measurements=[]
 for i in range(3):
  for tick in range(4):
   n=np.asarray(Image.open(native/f"weapon_{i}_tick_{tick}.ppm").convert("RGB"),dtype=np.int16)
   v=arr[i*105:(i+1)*105,tick*90:(tick+1)*90]
   delta=np.abs(n-v)
   nmask=np.any(n!=[237,242,246],axis=2)
   vmask=np.any(v!=[237,242,246],axis=2)
   union=int((nmask|vmask).sum());intersection=int((nmask&vmask).sum())
   measurements.append({"i":i,"tick":tick,"mae":float(delta.mean()),"diff_pixels":int(np.any(delta!=0,axis=2).sum()),"iou":intersection/union if union else 1})
 results[kind]={"mean_mae":round(sum(x["mae"] for x in measurements)/12,5),"mean_iou":round(sum(x["iou"] for x in measurements)/12,5),
  "total_diff_pixels":sum(x["diff_pixels"] for x in measurements),"per_profile":[{"mean_mae":round(sum(x["mae"] for x in measurements if x["i"]==i)/4,5),"mean_iou":round(sum(x["iou"] for x in measurements if x["i"]==i)/4,5)} for i in range(3)],"measurements":measurements}
(out/"A094_RENDER_SAMPLER_AB.json").write_text(json.dumps(results,indent=2))
print(json.dumps({k:{z:v[z] for z in ("mean_mae","mean_iou","total_diff_pixels","per_profile")} for k,v in results.items()},indent=2))