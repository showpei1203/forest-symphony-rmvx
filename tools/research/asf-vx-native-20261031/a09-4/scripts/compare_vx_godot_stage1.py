from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
qa=root/"vx_real_actor_20261031"/"a09_4"
native=root/"VX_A09_4_N5_RUNTIME"/"ASF_A094_NATIVE_PROOFS"
render=Image.open(root/"vx_real_actor_20261031"/"a09_2_actor_poses"/"engine"/"godot"/"A094_GODOT_12_TILES_NATIVE_VALUES.png").convert("RGB")
assert render.size==(360,315)
stats=[]
diag=Image.new("RGB",(4*90,3*105))
for i in range(3):
 for t in range(4):
  actual=np.asarray(Image.open(native/f"weapon_{i}_tick_{t}.ppm").convert("RGB"),dtype=np.int16)
  emitted=np.asarray(render.crop((t*90,i*105,(t+1)*90,(i+1)*105)),dtype=np.int16)
  assert actual.shape==emitted.shape==(105,90,3)
  delta=np.abs(actual-emitted)
  mask1=np.any(actual!=[237,242,246],axis=2)
  mask2=np.any(emitted!=[237,242,246],axis=2)
  intersection=int((mask1&mask2).sum());union=int((mask1|mask2).sum())
  stat={"profile":i,"tick":t,"mae_rgb":round(float(delta.mean()),5),
   "diff_pixels":int(np.any(delta!=0,axis=2).sum()),
   "max_color_delta":int(delta.max()),"native_foreground":int(mask1.sum()),"godot_foreground":int(mask2.sum()),
   "occupancy_iou":round(intersection/union,5) if union else 1.0}
  stats.append(stat)
  viz=np.minimum(delta*2,255).astype(np.uint8)
  diag.paste(Image.fromarray(viz),(t*90,i*105))
assert len(stats)==12
diag.save(qa/"A094_GODOT_VX_DIFF_12.png")
report={"render":"Godot 4.7.2 GPU A094_GODOT_12_TILES_NATIVE_VALUES.png","native":"Actual VX Sprite_Weapon frame snapshots at N5 stage1","stats":stats,
"mean_mae":sum(x["mae_rgb"] for x in stats)/12,"mean_iou":sum(x["occupancy_iou"] for x in stats)/12,
"all_exact":all(x["diff_pixels"]==0 for x in stats)}
(qa/"stage1_vx_godot_pixel_diff.json").write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2)[:6200])