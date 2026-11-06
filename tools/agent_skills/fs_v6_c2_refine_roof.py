"""A36G V6 per-object manual semantic mask prototype: one integrated house roof and one tree canopy.
No paid image generation, no guessed forest_group footpoint masks.
The explicit polygons are per-object draft annotations and MUST get visual signoff.
"""
from pathlib import Path
from PIL import Image,ImageDraw
from scipy.ndimage import binary_closing,binary_fill_holes,binary_opening
import json,numpy as np,hashlib,shutil
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
M=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
OUT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_V6_C2_REFINED_ROOF_MASK_20261107")
if OUT.exists():raise SystemExit("FAIL CLOSED: dest exists")
OUT.mkdir(parents=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
master=R5/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"
ground=R5/"A36G_R5_GROUND_1280x928.png"
complete=R5/"A36G_R5_PAR50_RGBA_1280x928.png"
srcdir=R5/"SOURCE_INDEPENDENT_RGBA"
rgb=np.array(Image.open(master).convert("RGB"))
W,H=1280,928
mask=np.zeros((H,W),dtype=np.uint8)
objects={}
config={
"A36G_ELF_HOUSE_AND_WORKSHOP":{
"roi_type":"roof surfaces of coherent house/workshop, not walls/windows",
"polygons":[
 [(110,14),(166,35),(229,61),(272,115),(264,133),(231,110),(207,96),(180,91),(166,128),(146,172),(132,190),(113,180),(97,125),(91,102)],
 [(8,157),(31,135),(96,91),(149,116),(163,149),(144,177),(127,188),(107,175),(88,147),(49,168),(24,186),(13,178)]
 ]},
"tree_003":{"roi_type":"leaf-canopy based on HSV green chroma + source alpha, not trunk", "polygons":[]}
}
source_witnesses=[]
for ident,conf in config.items():
 o=next(z for z in M["objects"] if z["id"]==ident)
 p=srcdir/o["filename"]
 assert p.is_file() and sha(p)==o["sha256"]
 src=Image.open(p).convert("RGBA")
 sw,sh=src.size
 assert [sw,sh]==[o["w"],o["h"]]
 alpha=np.array(src.getchannel("A"))>=128
 if ident.startswith("A36G"):
  layer=Image.new("L",(sw,sh),0)
  draw=ImageDraw.Draw(layer)
  for points in conf["polygons"]:draw.polygon(points,fill=255)
  local=np.array(layer)>0
  # semantic polygon gives upper spatial authority, plus material evidence:
  # remove obvious wooden window/wall pixels, keep roof dark grooves and woody eaves.
  hsv=np.asarray(src.convert("HSV"))
  hue=hsv[:,:,0];sat=hsv[:,:,1];value=hsv[:,:,2]
  moss=(hue>=33)&(hue<=94)&(sat>=60)&(value>=9)
  # retain broad roof surface but exclude clearly non-roof amber/red wood outside textured moss.
  local=local & alpha & (moss | ((value<22) & (hue>=31) & (hue<=85)))
 else:
  hsv=np.array(src.convert("HSV"))
  # semantic *color* segmentation of foliage, masked by true source Alpha.
  green=((hsv[:,:,0]>=38)&(hsv[:,:,0]<=112)&(hsv[:,:,1]>=65)&(hsv[:,:,2]>27))
  local=binary_closing(green & alpha,structure=np.ones((3,3)),iterations=1)
  local=binary_fill_holes(local) & alpha
  local=binary_opening(local,structure=np.ones((2,2)),iterations=1)
 if not local.any():raise RuntimeError("empty "+ident)
 x,y=int(o["x"]),int(o["y"]);xx=max(0,x);yy=max(0,y)
 ex=min(W,x+sw);ey=min(H,y+sh)
 part=local[yy-y:ey-y,xx-x:ex-x]
 assert part.shape==(ey-yy,ex-xx)
 mask[yy:ey,xx:ex]|=part.astype(np.uint8)
 raw=np.zeros((sh,sw,4),dtype=np.uint8)
 source=np.asarray(src)
 raw[local]=source[local]
 maskfile=OUT/(ident+"_SEMANTIC_SOURCE_RGBA.png")
 Image.fromarray(raw,"RGBA").save(maskfile)
 overlay=np.zeros((sh,sw,4),dtype=np.uint8);overlay[local]=[247,59,32,116]
 witness=Image.alpha_composite(src,Image.fromarray(overlay))
 witness_path=OUT/(ident+"_MASK_WITNESS.png")
 witness.save(witness_path)
 info={"id":ident,"type":o["type"],"source_file":o["filename"],"source_sha256":sha(p),
       "source_canvas":[sw,sh],"world_xy":[x,y],"original_source_nonzero_alpha":int(alpha.sum()),
       "selected_semantic_alpha_pixels":int(local.sum()),
       "fraction_of_source":round(float(local.sum()/max(alpha.sum(),1)),5),
       "extraction":conf["roi_type"],
       "mask_annotated_by":"per-asset polygons" if conf["polygons"] else "per-asset HSV foliage region",
       "human_art_acceptance":"UNVERIFIED"}
 objects[ident]=info
 source_witnesses.append(witness_path)
# runtime Ground from R5 whole master; authoring Ground and Full PAR preserved unchanged
for src,dest in ((master,"RUNTIME_FULL_SCENE_GROUND50.png"),
                 (ground,"AUTHORING_GROUND_ONLY.png"),
                 (complete,"AUTHORING_COMPLETE_PAR.png")):
 shutil.copy2(src,OUT/dest)
runtime=np.zeros((H,W,4),dtype=np.uint8)
keep=mask>0
runtime[keep,:3]=rgb[keep]
runtime[keep,3]=255
par=OUT/"RUNTIME_PAR50_ROOF_TREE_ONLY.png"
Image.fromarray(runtime,"RGBA").save(par)
assert np.all(runtime[keep,:3]==rgb[keep])
assert sha(OUT/"RUNTIME_FULL_SCENE_GROUND50.png")==sha(master)
assert sha(OUT/"AUTHORING_COMPLETE_PAR.png")==sha(complete)
assert sha(OUT/"AUTHORING_GROUND_ONLY.png")==sha(ground)
# preview from SOURCE assets, not just synthetic orange heat.
vis=Image.fromarray(rgb).convert("RGBA")
h=np.zeros((H,W,4),dtype=np.uint8);h[keep]=[249,57,35,130]
vis=Image.alpha_composite(vis,Image.fromarray(h))
vis.resize((640,464),Image.Resampling.NEAREST).save(OUT/"RUNTIME_PAR50_2OBJECT_HEATMAP_640.png")
# sample nominal player tiles based on source-local mask; verify actual screen before any PASS.
positions=[]
for ty in range(29):
 for tx in range(40):
  x=tx*32+16;y=ty*32+32
  body=keep[y-32:y,x-12:x+12]
  if body.shape==(32,24):
   positions.append((round(float(body.mean()),5),tx,ty))
target={}
for ident,ob in objects.items():
 x0,y0=ob["world_xy"];sw,sh=ob["source_canvas"]
 lst=[(f,x,y) for f,x,y in positions if (x0+20)<x*32+16<(x0+sw-20) and y0+32<y*32+32<(y0+sh-10)]
 lst.sort(reverse=True)
 print(ident,"TOP",lst[:6])
 if not lst or lst[0][0]<.3:raise RuntimeError("no viable in object "+ident)
 target[ident]={"tile":[lst[0][1],lst[0][2]],"actor_mask_overlap":lst[0][0]}
report={"stage":"A36G_V6_C2_ROOF_AND_TREE_SOURCE_SEMANTIC_DRAFT",
"source_r5_manifest_sha256":sha(R5/"A36G_R5_SCENE_MANIFEST.json"),
"source_r5_master_sha256":sha(master),
"selected_objects":objects,"actor_test_targets":target,
"full_scene_pixel_registration":True,
"runtime_overlay_opaque_pixel_count":int(keep.sum()),
"runtime_overlay_canvas_fraction":round(float(keep.mean()),6),
"authoring_complete_par_preserved":True,
"runtime_rgb_exact_source":True,
"new_art_generated":False,"forest_group_heuristics_used":False,
"native_VX_verified":False,"user_art_approved":False,"formal_seal":"NO"}
(OUT/"V6_2OBJECT_SEMANTIC_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V6_2OBJ",json.dumps({"test_tiles":target,"coverage":report["runtime_overlay_canvas_fraction"],
"objects":objects},ensure_ascii=False),flush=True)