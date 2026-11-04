"""R4 R2 visual seam fix. MODIFY compiled alpha only. Keep all SIX original PixelLab sources intact."""
from pathlib import Path
import json,hashlib,shutil,math
import numpy as np
from PIL import Image,ImageDraw
R=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R/"A36G_R4_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_R4_FOREST_6REGIONS_ENGINE_CANDIDATE"
plan=json.loads((R/"R4_FOREST_REGION_BLUEPRINT.json").read_text("utf8"))["regions"]
backup=R/"R4_R1_BEFORE_SEAM_REWORK"
backup.mkdir(exist_ok=True)
for n in ("A36G_R4_SCENE_MANIFEST.json","A36G_R4_PAR50_RGBA_1280x928.png",
          "A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png","A36G_R4_PREVIEW_640.png",
          "A36G_R3B_VS_R4_TRUE_GROUND_PAR_BEFORE_AFTER.png"):
 p=R/n
 if not (backup/n).exists():shutil.copy2(p,backup/n)
qa=[]
for reg in plan:
 rid=reg["id"];w,h=reg["w"],reg["h"];ox,oy=reg["x"],reg["y"]
 original=S/f"A36G_R4_{rid}_COMPILED_CLEARING_SAFE_RGBA.png"
 assert original.exists()
 z=Image.open(original).convert("RGBA")
 assert z.size==(w,h)
 arr=np.array(z)
 X=np.arange(w,dtype=np.float32)[None,:]
 Y=np.arange(h,dtype=np.float32)[:,None]
 # Irregular deeply staggered canopy transitions; crucially not a rectangular hard boundary.
 taper=np.ones((h,w),np.float32)
 boundaries=[]
 if ox>0:
  leftj=10+9*np.sin(Y*.054+1.1)+5*np.sin(Y*.16+2.3)
  v=np.clip((X-leftj)/36,0,1)
  taper=np.minimum(taper,np.broadcast_to(v,(h,w)));boundaries.append("left")
 if ox+w<1280:
  rightj=12+11*np.sin(Y*.042+3.4)+6*np.cos(Y*.123+.2)
  v=np.clip(((w-1-X)-rightj)/35,0,1)
  taper=np.minimum(taper,np.broadcast_to(v,(h,w)));boundaries.append("right")
 if oy>0:
  topj=15+12*np.sin(X*.046+2.1)+8*np.cos(X*.105+3.8)
  v=np.clip((Y-topj)/41,0,1)
  taper=np.minimum(taper,np.broadcast_to(v,(h,w)));boundaries.append("top")
 if oy+h<928:
  bottomj=10+11*np.sin(X*.048+4.4)+7*np.cos(X*.126+2.1)
  v=np.clip(((h-1-Y)-bottomj)/36,0,1)
  taper=np.minimum(taper,np.broadcast_to(v,(h,w)));boundaries.append("bottom")
 # Make alpha boundaries organic while keeping native 1:1 pixel source (never resample RGB).
 sm=taper*taper*(3-2*taper)
 arr[:,:,3]=np.uint8(np.rint(arr[:,:,3].astype(np.float32)*sm))
 arr[arr[:,:,3]==0,:3]=0
 new=Image.fromarray(arr,"RGBA")
 name=f"A36G_R4_{rid}_COMPILED_SEAM_TAPER_R2_RGBA.png"
 new.save(S/name,optimize=True)
 # Replace old 91px depth-band source assets with new distinct names. Old R1 assets remain accessible.
 replacements={}
 for o in m["objects"]:
  if o.get("region_id")!=rid:continue
  y0=o["y"]-oy;y1=y0+o["h"]
  sliceimg=new.crop((0,y0,w,y1))
  nm=o["filename"].replace("_DEPTH_","_R2_DEPTH_")
  assert nm!=o["filename"]
  sliceimg.save(S/nm,optimize=True)
  o.update(filename=nm,sha256=sha(S/nm),compiled_source=name)
  replacements[nm]=[y0,y1]
 entry=next(x for x in m["forest_regions_R4"] if x["id"]==rid)
 entry["compiled_source_sha256"]=sha(S/name)
 entry["compiled_alpha_pixels_R2"]=int((arr[:,:,3]>127).sum())
 entry["edge_taper_R2"]=boundaries
 entry["edge_taper_method"]="irregular smoothstep alpha only, RGB untouched; no full-image cut"
 entry["compiled_source_R2"]=name
 entry["depth_files_R2"]=len(replacements)
 qa.append({"id":rid,"source_compiled_R1_sha":sha(original),"source_compiled_R2_sha":sha(S/name),
  "adjusted_edges":boundaries,"alpha_pixels_before":int((np.asarray(z.getchannel("A"))>127).sum()),
  "alpha_pixels_after":int((arr[:,:,3]>127).sum()),"depth_strips":len(replacements)})
m["stage"]="A36G_R4_6REGIONS_SEAM_R2_ENGINE_CANDIDATE"
m["forest_art_gate"]="R2_SEAM_REWORK_PENDING_REVIEW"
m["formal_seal"]="NO"
m["objects"].sort(key=lambda o:(o["foot"][1],o["id"]))
par=Image.new("RGBA",(1280,928),(0,0,0,0))
for o in m["objects"]:
 p=S/o["filename"]
 assert sha(p)==o["sha256"],o["id"]
 img=Image.open(p).convert("RGBA")
 assert img.size==(o["w"],o["h"])
 par.alpha_composite(img,(o["x"],o["y"]))
parfile=R/"A36G_R4_PAR50_RGBA_1280x928.png"
par.save(parfile,optimize=True)
g=Image.open(R/"A36G_R4_GROUND_1280x928.png").convert("RGBA")
g.alpha_composite(par)
cf=R/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png"
g.convert("RGB").save(cf,optimize=True)
g.convert("RGB").resize((640,464),Image.Resampling.NEAREST).save(R/"A36G_R4_PREVIEW_640.png",optimize=True)
m["par_sha256"]=sha(parfile);m["composite_sha256"]=sha(cf)
(R/"A36G_R4_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),"utf8")
o=Image.open(backup/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
panel=Image.new("RGB",(1280,492),(26,27,28));dr=ImageDraw.Draw(panel)
panel.paste(o.resize((640,464),Image.Resampling.NEAREST),(0,28))
panel.paste(g.convert("RGB").resize((640,464),Image.Resampling.NEAREST),(640,28))
dr.text((8,8),"R4 R1 - BEFORE edge repair",fill="white")
dr.text((650,8),"R4 R2 - AFTER irregular forest seam taper",fill="white")
panel.save(R/"A36G_R4_R1_VS_R2_SEAM_COMPARISON.png",optimize=True)
result={"stage":m["stage"],"region_count":len(qa),"seams":qa,
 "par_sha":sha(parfile),"composite_sha":sha(cf),"native_vx":"NOT_RUN",
 "godot":"NOT_RUN","root_art_collision":"PENDING","art_gate":"PENDING","formal_seal":"NO"}
(R/"A36G_R4_R2_SEAM_QA.json").write_text(json.dumps(result,indent=2,ensure_ascii=False),"utf8")
print(json.dumps({"stage":m["stage"],"regions":len(qa),
"source_objects":len(m["objects"]),"par_sha":result["par_sha"],"composite_sha":result["composite_sha"],
"seam_edges":[[x["id"],x["adjusted_edges"]] for x in qa]},indent=2),flush=True)
