from __future__ import annotations
from pathlib import Path
from PIL import Image
import numpy as np,hashlib,json,collections,sys,io
ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def image(p):return Image.open(p).convert("RGBA")
def diff(a,b):
 a=np.asarray(a.convert("RGBA"))
 b=np.asarray(b.convert("RGBA"))
 return -1 if a.shape!=b.shape else int(np.count_nonzero(np.any(a!=b,axis=2)))
log=[];errors=[]
def test(key,ok,meta=None):
 log.append({"gate":key,"status":"PASS" if ok else "FAIL","evidence":meta})
 if not ok:errors.append(key)
doc=json.loads((ROOT/"fs_scene/scene_manifest.json").read_text(encoding="utf-8"))
bundle=json.loads((ROOT/"bundle/map-bundle.json").read_text(encoding="utf-8"))
assert doc["canvas"]==[544,416] and doc["tile_size"]==32
assert len(doc["objects"])==8
ground=image(ROOT/"fs_scene/build/Ground.png")
par=image(ROOT/"fs_scene/build/PAR_COMPLETE.png")
master=image(ROOT/"fs_scene/build/Recomposed.png")
test("COMPOSE",diff(Image.alpha_composite(ground,par),master)==0)
canvas=image(ROOT/"bundle/art/ground.png")
for o in sorted(bundle["objects"],key=lambda t:t["sortY"]):
 prop=bundle["props"][o["prop"]]
 path=ROOT/"bundle"/prop["image"]
 test("ASSET_SHA:"+o["id"],sha(path)==prop["sha256"])
 pic=image(path)
 xy=(int(o["x"]-o["anchor_px"][0]),int(o["y"]-o["anchor_px"][1]))
 canvas.alpha_composite(pic,dest=xy)
test("BUNDLE_RECOMPOSE",diff(canvas,master)==0)
for key,file in [
 ("ASF_COMPILE",ROOT/"asf_reference_render.png"),
 ("GODOT_NATIVE_GPU",ROOT/"godot_export/F1R1_REAL_GPU_RENDER.png"),
 ("TILED_NATIVE_RASTERIZER",ROOT/"tiled/F1R1_TILED_NATIVE.png")]:
 value=diff(image(file),master)
 test(key,value==0,{"rgba_diff_pixels":value})
original=image(ROOT/"training_reference/FS_V21_Approved_Ground.png")
new=image(ROOT/"fs_scene/build/Ground.png")
new_pixels=diff(original,new)
test("GROUND_IS_NEW",new_pixels>100000,{"changed_pixels":new_pixels,"total":544*416})
blocked={tuple(x) for x in doc["collision"]["blocked_tiles"]}
collision={(x//32,y//32) for x,y,w,h in bundle["collision"]["rects"] if w==32 and h==32}
test("BLOCKED_PARITY",len(blocked)==18 and blocked==collision)
spawn=tuple(v//32 for v in doc["spawn_world"])
seen={spawn};queue=collections.deque([spawn])
while queue:
 x,y=queue.popleft()
 for dx,dy in ((0,1),(0,-1),(1,0),(-1,0)):
  p=(x+dx,y+dy)
  if 0<=p[0]<17 and 0<=p[1]<13 and p not in blocked and p not in seen:
   seen.add(p);queue.append(p)
test("ALL_FREE_REACHABLE",len(seen)==203,{"free_cells":203,"reachable":len(seen),"spawn_tile":spawn})
tiled=json.loads((ROOT/"tiled/map.runtime_hidden_meta.tmj").read_text(encoding="utf-8-sig"))
metadata={l["name"]:l for l in tiled["layers"]}
test("METADATA_PRESERVED_HIDDEN",not metadata["interactions"]["visible"] and
 not metadata["collision"]["visible"] and
 len(metadata["collision"]["objects"])==18 and len(metadata["interactions"]["objects"])>=1)
def magenta(path):
 v=np.asarray(image(path),np.uint8)
 return int(np.count_nonzero(np.all(v[:,:,:3]==[255,0,255],axis=2)))
back=magenta(ROOT/"godot_playable/F1R1_YSORT_BACK.png")
front=magenta(ROOT/"godot_playable/F1R1_YSORT_FRONT.png")
test("Y_SORT_GPU",back<front and front==384,{"back_visible":back,"front_visible":front})
raw=(ROOT/"reports/F1R1_NATIVE_ALL_TILE_PHYSICS_V4.log").read_bytes()
phys=raw.decode("utf-16") if raw.startswith(bytes([255,254])) else raw.decode("utf-8-sig",errors="replace")
test("REAL_GODOT_PHYSICS_SIGNED",("F1R1_NATIVE_PHYSICS_221_221_PASS" in phys and "ERROR:" not in phys),{"checked_tiles":221})
# Negative gates: deterministic one-pixel shift, altered hash and missing one 32px collision, no source edits.
item=image(ROOT/"bundle/props/tree_west.png")
raw=np.asarray(item).copy()
loc=np.argwhere(raw[:,:,3]>0)[0]
raw[loc[0],loc[1],0]=(int(raw[loc[0],loc[1],0])+1)%256
buffer=io.BytesIO()
Image.fromarray(raw).save(buffer,format="PNG")
test("NEGATIVE_SHA_ALTERATION",hashlib.sha256(buffer.getvalue()).hexdigest()!=sha(ROOT/"bundle/props/tree_west.png"))
one_shift=Image.new("RGBA",item.size)
one_shift.alpha_composite(item,dest=(1,0))
test("NEGATIVE_1PX_SHIFT",diff(item,one_shift)>0)
test("NEGATIVE_MISSING_COLLISION",len(blocked-set([next(iter(blocked))]))==17 and blocked-set([next(iter(blocked))])!=collision)
state={"scene":"FS-F1R1 New Procedural Ground candidate","dimensions":[544,416],"human_visual":"PENDING","vx_native":"PENDING","tech_gates":log,"errors":errors,"overall":"TECH_PASS_HUMAN_PENDING" if not errors else "TECH_FAIL"}
(ROOT/"VERIFY_RESULT.json").write_text(json.dumps(state,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"gates":len(log),"pass":len(log)-len(errors),"fail":errors,"overall":state["overall"]},ensure_ascii=False))
if errors:sys.exit(1)
