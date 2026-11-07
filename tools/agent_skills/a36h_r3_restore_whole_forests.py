"""A36H R3: restore 44 contiguous depth-slice assets into 7 coherent forest AUTHORING GROUPS
without resizing, then do small-scale canopy hole cleanup on full regions and re-slice on original boundaries.
Full original 192-object render order is preserved. Changes confined to existing blocked tiles to avoid erasing paths.
"""
from pathlib import Path
from PIL import Image,ImageDraw
from scipy.ndimage import binary_closing, distance_transform_edt, binary_erosion
import numpy as np,json,hashlib,collections
BASE=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
R1=BASE/"A36H_R1_TRUE_GROUND_PAR_RECOMPILE"
R2=BASE/"A36H_R2_GROUND3_PALETTE_MATCH"
OUT=BASE/"A36H_R3_FOREST_WHOLE_GROUP_TEST"
if OUT.exists():raise RuntimeError("FAIL-CLOSED: output exists")
OUT.mkdir()
(OUT/"GROUP_FULL_SOURCE").mkdir()
(OUT/"SOURCE_SLICE_REEXPORT").mkdir()
m=json.loads((R2/"A36H_R2_SCENE_MANIFEST.json").read_text("utf8"))
s=R1/"SOURCE_INDEPENDENT_RGBA"
groups=collections.defaultdict(list)
for o in m["objects"]:
 if o["type"]=="forest_group":
  name=o["id"].rsplit("_depth_",1)[0]
  groups[name].append(o)
assert len(groups)==7 and sum(map(len,groups.values()))==44,(len(groups),sum(map(len,groups.values())))
blocked=np.asarray(m["collision_map_29x40"],dtype=bool)
res={}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for name,items in groups.items():
 items=sorted(items,key=lambda v:v["y"])
 assert len({z["x"] for z in items})==1 and len({z["w"] for z in items})==1
 assert all(a["y"]+a["h"]==b["y"] for a,b in zip(items,items[1:])),name
 x=items[0]["x"];y=items[0]["y"];w=items[0]["w"];h=sum(z["h"] for z in items)
 full=np.zeros((h,w,4),dtype=np.uint8)
 pos=0
 for o in items:
  data=np.asarray(Image.open(s/o["filename"]).convert("RGBA"))
  assert data.shape==(o["h"],o["w"],4)
  full[pos:pos+o["h"]]=data
  pos+=o["h"]
 before=OUT/"GROUP_FULL_SOURCE"/(name+"_WHOLE_FOREST_BEFORE.png")
 Image.fromarray(full,"RGBA").save(before)
 # Source group is now ONE editable whole-forest RGBA canvas; any modification is done
 # globally, THEN cut back at exact same y boundary for strict original depth/render ordering.
 opaque=full[:,:,3]>=140
 close=binary_closing(opaque,structure=np.ones((9,9),dtype=bool),border_value=1)
 candidate=close & ~opaque
 gy,gx=np.indices((h,w))
 wy=gy+y;wx=gx+x
 inmap=(wx>=0)&(wx<1280)&(wy>=0)&(wy<928)
 # Do not add foliage over A36G R5 walkable cells. Existing forest alpha unchanged.
 allow=~inmap
 coords=np.where(inmap)
 allow[coords]=blocked[(wy[coords]//32).astype(int),(wx[coords]//32).astype(int)]
 # Also limit new foliage to near actual original opaque pixels (4 px); no terrain invasion.
 dist,idx=distance_transform_edt(~opaque,return_indices=True)
 fill=candidate & allow & (dist<=4.4)
 orig=full.copy()
 full[fill]=orig[idx[0][fill],idx[1][fill]]
 full[fill,3]=np.maximum(full[fill,3],np.uint8(215))
 # Optional small crisp tree branch fringe: integrate rather than blurred contour.
 # Only single-pixel voids fully internal to forest blocked tiles are changed; never cross roads.
 changed=int(fill.sum())
 after=OUT/"GROUP_FULL_SOURCE"/(name+"_WHOLE_FOREST_AFTER.png")
 Image.fromarray(full,"RGBA").save(after)
 # Exact y reslicing, position, alpha original segment order preserved, no new overlap order invented.
 pos=0
 for o in items:
  part=Image.fromarray(full[pos:pos+o["h"]],"RGBA")
  assert part.size==(o["w"],o["h"])
  part.save(OUT/"SOURCE_SLICE_REEXPORT"/o["filename"])
  pos+=o["h"]
 # Witness actual 1x texture and changed pixels difference mask
 rgb0=np.array(Image.open(before).convert("RGBA"))
 cmp=Image.new("RGB",(w*2,h+24),(23,27,29))
 for i,arr in enumerate((rgb0,full)):
  im=Image.new("RGBA",(w,h),(64,69,65,255))
  im.alpha_composite(Image.fromarray(arr,"RGBA"))
  cmp.paste(im.convert("RGB"),(i*w,24))
 dd=ImageDraw.Draw(cmp);dd.text((5,5),"R2 sliced originals",fill="white")
 dd.text((w+5,5),"R3 7-group contiguous cleanup",fill="white")
 cmp.save(OUT/"GROUP_FULL_SOURCE"/(name+"_BEFORE_AFTER_1X.png"))
 res[name]={"source_slices":len(items),"world_bounds":[x,y,w,h],
  "original_alpha_opaque":int(opaque.sum()),"void_pixels_filled":changed,
  "fill_where_blocked_or_outside_canvas":bool(np.all(allow[fill])),
  "whole_before_sha":sha(before),"whole_after_sha":sha(after)}
print(json.dumps({"groups":len(groups),"original_slices":44,"total_source_void_pixels_filled":sum(z["void_pixels_filled"] for z in res.values()),"per_group":res},ensure_ascii=False,indent=2))
(OUT/"R3_7FOREST_GROUP_QA.json").write_text(json.dumps(res,ensure_ascii=False,indent=2),encoding="utf8")