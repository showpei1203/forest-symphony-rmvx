from pathlib import Path
from PIL import Image
import numpy as np,json
lab=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
base=lab/"A13_KEYPOSE_RIG"/"T2_moss_antler"
cfg=json.loads((base/"rig_authority.json").read_text(encoding="utf8"))
master=Image.open(lab/"A10_ONE_MASTER_RIG"/"T2_moss_antler"/"master.png").convert("RGBA")
tests=[]
for name in ("front_near","back_near"):
  src=cfg["source_leg_patches"][name]
  box=src["box"];x0,y0,x1,y1=box
  patch=np.asarray(master.crop(tuple(box)).convert("RGBA"))
  for f in cfg["semantic_frames"]:
    if f["contacts"][name]!=1:continue
    dx,dy=f["root_offset"]; fx,fy=f["foot_targets"][name]
    # Exact roundtrip of A13 R3 compositor
    xx=round(fx-(src["anchor"][0]-x0))
    yy=round(fy-(60-y0))
    dest=np.asarray(Image.open(base/"frames"/f"attack_{f['frame']:02d}.png").convert("RGBA"))
    rows=[]
    for y in range(max(0,patch.shape[0]-4),patch.shape[0]):
      for x in range(patch.shape[1]):
        p=patch[y,x]
        if p[3]<250:continue
        X=int(xx+x);Y=int(yy+y)
        if X<0 or Y<0 or X>=dest.shape[1] or Y>=dest.shape[0]:continue
        rows.append(np.array_equal(p,dest[Y,X]))
    tests.append({"leg":name,"frame":f["frame"],"target":f["foot_targets"][name],"real_pixel_count":len(rows),"matching":int(sum(rows)),"ratio":round(sum(rows)/len(rows),3) if rows else None})
r={"purpose":"Verify actual A13 final RGBA output pixels, not only semantic JSON foot targets","tests":tests}
(lab/"A14_OCCLUSION_RIG"/"A14_A13_RENDERED_HOOF_AUDIT.json").write_text(json.dumps(r,indent=2))
print(json.dumps(r,indent=2))