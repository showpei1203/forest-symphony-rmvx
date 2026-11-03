from pathlib import Path
import json,hashlib,shutil,math
import numpy as np
from PIL import Image,ImageDraw
from scipy.ndimage import binary_dilation,distance_transform_edt,label
G=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
F=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103")
S=G/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
original_provider=S/"A36G_PIXELLAB_WEST_FOREST_CONTIGUOUS_FULL_R3B_RGBA.png"
assert original_provider.exists(),"Provider source is not finished. Never fabricate it."
im=Image.open(original_provider).convert("RGBA")
assert im.size==(464,576),im.size
m=json.loads((G/"A36G_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_PIXELLAB_HOUSE_R2_WEST_FOREST_R2_CANDIDATE"
backup=G/"HOUSE_R2_WEST_FOREST_R2_ARCHIVE"
backup.mkdir(exist_ok=True)
for n in ("A36G_SCENE_MANIFEST.json","A36G_PAR50_RGBA_1280x928.png","A36G_TRUE_GROUND_PLUS_PAR_1280x928.png","A36G_PREVIEW_640.png"):
 p=G/n
 if not (backup/n).exists():shutil.copy2(p,backup/n)
ox,oy=-112,-110
rw,rh=im.size
r2_ids=set(m["forest_removed_individual_ids"])
f0=json.loads((F/"A36F_SCENE_MANIFEST.json").read_text("utf8"))
orig_obj=[o for o in f0["objects"] if o["id"] in r2_ids]
assert len(orig_obj)>40
road=np.asarray(Image.open(G/"A36F_NATURAL_PATH_MASK.png").convert("L"))>127
protected=binary_dilation(road,iterations=21)
# Mask actual road corridor, preserve the native RGBA forest as independent source.
arr=np.array(im)
alpha=arr[:,:,3].astype(np.float32)
mask=np.zeros((rh,rw),bool)
for y in range(rh):
 wy=y+oy
 if not(0<=wy<928):continue
 left=max(0,ox);right=min(1280,ox+rw)
 mask[y,left-ox:right-ox]=protected[wy,left:right]
dist=distance_transform_edt(~mask).astype(np.float32)
clearance=np.clip((dist-0.5)/4.5,0.0,1.0)
# True original alpha times road clear mask, no RGB pixels left on fully transparent region.
arr[:,:,3]=np.clip(alpha*clearance,0,255).astype(np.uint8)
arr[arr[:,:,3]==0,:3]=0
layer=Image.fromarray(arr,"RGBA")
filename="A36G_PIXELLAB_WEST_FOREST_R3B_ROAD_SAFE_RGBA.png"
layer.save(S/filename,optimize=True)
# Restore individual A36F sprites not inside the new physical region, no holes from shrinking the source.
restored=[]
omitted=[]
for o in orig_obj:
 fx,fy=o["foot"];x,y=round(fx-ox),round(fy-oy)
 if not(0<=x<rw and 0<=y<rh) or int(arr[y,x,3])<160:
  restored.append(o)
 else:omitted.append(o)
cur=[o for o in m["objects"] if o["type"]!="forest_group"]
current_ids={o["id"] for o in cur}
for o in restored:
 assert o["id"] not in current_ids
 cur.append(o);current_ids.add(o["id"])
cuts=[(-110,0),(0,75),(75,155),(155,240),(240,330),(330,466)]
groups=[]
for j,(y0,y1) in enumerate(cuts,1):
 sub=layer.crop((0,y0-oy,rw,y1-oy))
 if not sub.getbbox():continue
 n=f"A36G_PIXELLAB_FOREST_WEST_DEPTH_{j:02d}_RGBA.png"
 sub.save(S/n,optimize=True)
 groups.append({"id":f"a36g_pixellab_west_depth_{j:02d}","type":"forest_group",
   "x":ox,"y":y0,"w":rw,"h":y1-y0,
   "foot":[ox+rw//2,y1],"filename":n,"sha256":sha(S/n),
   "blocking":False,"alpha_isolated":True,"continuous_source":filename,
   "native_provider_source":original_provider.name,"depth_interval":[y0,y1]})
m["objects"]=sorted(cur+groups,key=lambda o:(o["foot"][1],o["id"]))
# Retain source blueprint and differentiate visual source from real footprint collision.
old_blueprint=m.get("forest_region_blueprint")
m["forest_region_blueprint"]={
 "id":"A36G_PIXELLAB_WEST_FOREST_R3B","kind":"one_native_provider_contiguous_woodland_source",
 "bbox":[ox,oy,ox+rw,oy+rh],
 "source_file":original_provider.name,"source_SHA256":sha(original_provider),
 "compiled_alpha_file":filename,"compiled_SHA256":sha(S/filename),
 "depth_strips":cuts,"source_original_A36F_reference":"A36G_PIXEL_STYLE_WEST_FOREST_A36F_REFERENCE.png",
 "road_clearance_px":21,"root_anchors":[o["foot"] for o in omitted if o["type"]=="tree" and o.get("blocking")],
 "restored_A36F_sprites_outside_region":len(restored),
 "omitted_A36F_sprites_under_forest":len(omitted),
 "original_r2_blueprint":old_blueprint}
m["forest_removed_individual_ids"]=[o["id"] for o in omitted]
m["stage"]="A36G_PIXELLAB_HOUSE_R2_WEST_FOREST_R3B_CANDIDATE"
m["source_stage"]="A36F_R1"
m["forest_art_gate"]="PIXELLAB_GENERATED_PENDING_VISUAL_REVIEW"
m["house_art_gate"]="PIXELLAB_GENERATED_PENDING_VISUAL_REVIEW"
m["collision_gate"]="STATIC_COLLISION_A36F_ROOTS_PENDING_ART_FOOT_REVIEW"
m["formal_seal"]="NO"
W,H=1280,928
par=Image.new("RGBA",(W,H),(0,0,0,0))
for o in m["objects"]:
 p=S/o["filename"]
 assert p.exists() and sha(p)==o["sha256"],o["id"]
 z=Image.open(p).convert("RGBA")
 assert z.size==(o["w"],o["h"]),(o["id"],z.size)
 par.alpha_composite(z,(o["x"],o["y"]))
par.save(G/"A36G_PAR50_RGBA_1280x928.png",optimize=True)
gr=Image.open(G/"A36G_GROUND_1280x928.png").convert("RGBA")
gr.alpha_composite(par)
cf=G/"A36G_TRUE_GROUND_PLUS_PAR_1280x928.png"
gr.convert("RGB").save(cf,optimize=True)
gr.convert("RGB").resize((640,464),Image.Resampling.NEAREST).save(G/"A36G_PREVIEW_640.png",optimize=True)
old=Image.open(F/"A36F_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
panel=Image.new("RGB",(800,520),(28,28,28))
panel.paste(old.crop((0,0,400,520)),(0,0))
panel.paste(gr.convert("RGB").crop((0,0,400,520)),(400,0))
panel.save(G/"A36F_VS_A36G_PIXELLAB_FOREST_R3B_NATIVE_BEFORE_AFTER.png",optimize=True)
newmap=np.array(layer.getchannel("A"))>127
components,n=label(newmap)
largest=max(np.bincount(components[newmap])) if np.any(newmap) else 0
qa={"stage":m["stage"],"native_pixellab_png_sha256":sha(original_provider),
    "native_pixellab_dim":list(im.size),"native_pixellab_alpha_bbox":im.getbbox(),
    "compiled_alpha_sha256":sha(S/filename),"compiled_source_dim":list(layer.size),
    "offscreen_origin":[ox,oy],"road_pixels_protected":int(mask.sum()),
    "alpha_area_pixels":int(newmap.sum()),"connected_component_count":n,
    "largest_connected_fraction":round(largest/max(int(newmap.sum()),1),4),
    "restored_old_sprites":len(restored),"actually_removed_old_sprites":len(omitted),
    "roots_inside_source":len(m["forest_region_blueprint"]["root_anchors"]),
    "scene_objects":len(m["objects"]),"forest_depth_slices":len(groups),
    "ground_sha256":sha(G/"A36G_GROUND_1280x928.png"),
    "par_sha256":sha(G/"A36G_PAR50_RGBA_1280x928.png"),
    "composite_sha256":sha(cf),"art_gate":"PENDING_REVIEW","vx_gate":"NOT_YET_REBUILT",
    "godot_gate":"NOT_YET_REBUILT","formal_seal":"NO"}
(G/"A36G_PIXELLAB_FOREST_R3B_INTEGRATION_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),"utf8")
(G/"A36G_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),"utf8")
print(json.dumps(qa,ensure_ascii=False,indent=2),flush=True)