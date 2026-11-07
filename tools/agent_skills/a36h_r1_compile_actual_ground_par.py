"""A36H R1 _ACTUAL_ Forest Symphony 1280x928 art-source compiler.
All 192 original R5 source RGBA with verified SHA -> independent copy, two roof material changes based
on original Ground3 lumber, coherent location-anchored bluegreen leafy color pass (no blur/scale),
single-source authoring GroundOnly/CompletePar, runtime FullMaster/OcclusionPar, same R5 collision.
Stop fail-closed if original R5 recompose differs (source order not recovered) or alpha loses registration.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,shutil,collections,math
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
BASE=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
ART=BASE/"A36H_VISUAL_ART_REPAIR_20261107"
OUTPUT=ART/"A36H_R1_TRUE_GROUND_PAR_RECOMPILE"
SOURCE=OUTPUT/"SOURCE_INDEPENDENT_RGBA"
if OUTPUT.exists():raise RuntimeError("FAIL CLOSED: output exists")
SOURCE.mkdir(parents=True)
M=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
objs=M["objects"]
assert len(objs)==192
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
# Verify original compiler reproduction FROM R5 original sources first, before altering any data.
par_old=Image.new("RGBA",(1280,928),(0,0,0,0))
for o in objs:
 p=R5/"SOURCE_INDEPENDENT_RGBA"/o["filename"]
 assert sha(p)==o["sha256"],("bad source hash",o["id"])
 image=Image.open(p).convert("RGBA")
 assert image.size==(o["w"],o["h"]),(o["id"],image.size)
 par_old.alpha_composite(image,(o["x"],o["y"]))
original=np.asarray(Image.open(R5/"A36G_R5_PAR50_RGBA_1280x928.png").convert("RGBA"))
old_arr=np.asarray(par_old)
diff=original.astype(np.int16)-old_arr.astype(np.int16)
pixels=int(np.any(diff,axis=2).sum())
print("ORIGINAL_RECOMPOSE_DIFFERENT_PIXELS",pixels,flush=True)
assert pixels==0,"R5 original source compiler not exactly reproducible: refuse changes"
# New edited independent sources.
new_manifest=json.loads(json.dumps(M))
modified={};types=collections.Counter();nbytes=0
for o in new_manifest["objects"]:
 src=R5/"SOURCE_INDEPENDENT_RGBA"/o["filename"]
 dst=SOURCE/o["filename"]
 if o["type"]=="house":
  id=o["id"]
  inp=ART/(id+"_WOOD_ROOF_V2_RGBA.png")
  assert inp.exists()
  im=Image.open(inp).convert("RGBA")
  old=Image.open(src).convert("RGBA")
  assert im.size==old.size and np.array_equal(np.asarray(im)[:,:,3],np.asarray(old)[:,:,3])
  im.save(dst)
  o["a36h_art_pass"]="V2_APPROVED_GROUND3_WOOD_TEXTURE_TEST_NOT_USER_APPROVED"
 elif o["type"] in ("tree","forest_group"):
  im=Image.open(src).convert("RGBA")
  arr=np.asarray(im).copy()
  hsv=np.asarray(im.convert("HSV")).copy()
  hue=hsv[:,:,0].astype(np.float32)
  sat=hsv[:,:,1].astype(np.float32)
  val=hsv[:,:,2].astype(np.float32)
  h,w=arr.shape[:2]
  yy,xx=np.indices((h,w))
  xx=xx+int(o["x"]);yy=yy+int(o["y"])
  # Hue is only applied to genuine foliage, never wood trunks, grass flowers, or alpha.
  active=(arr[:,:,3]>130)&(hue>=41)&(hue<=113)&(sat>=54)&(val>=28)
  if o["type"]=="tree":
   import hashlib
   variant=int(hashlib.sha256(o["id"].encode("utf8")).hexdigest()[:2],16)%4
   target=[107,99,111,89][variant]
   degree=[.61,.39,.52,.2][variant]
   saturation=[1.02,.94,.91,1.0][variant]
   brightness=[.88,.95,.9,.98][variant]
  else:
   # Depth slices must share exactly the same world-coordinate transfer function.
   target=106;degree=.35;saturation=.96;brightness=.98
  dist=np.sin((xx+130)/235.0)*np.cos((yy+87)/180.0)
  shift=(degree + dist*.055)
  hue[active]=np.mod(hue[active]*(1-shift[active])+target*shift[active],256)
  sat[active]=np.clip(sat[active]*saturation,0,255)
  val[active]=np.clip(val[active]*brightness,0,255)
  hsv[:,:,0]=np.uint8(hue)
  hsv[:,:,1]=np.uint8(sat)
  hsv[:,:,2]=np.uint8(val)
  recol=np.asarray(Image.fromarray(hsv,"HSV").convert("RGB"))
  arr[active,:3]=recol[active]
  assert np.array_equal(arr[:,:,3],np.asarray(im)[:,:,3])
  Image.fromarray(arr,"RGBA").save(dst)
  nbytes+=int(active.sum())
  o["a36h_art_pass"]="CANOPY_LOCATION_ANCHORED_PALETTE_FROM_GROUND3_CANDIDATE"
 else:
  shutil.copy2(src,dst)
 assert sha(dst)!= "" and Image.open(dst).size==(o["w"],o["h"])
 if sha(src)!=sha(dst):
  modified[o["id"]]={"source_SHA256":sha(src),"candidate_SHA256":sha(dst),"type":o["type"],"filename":o["filename"]}
 types[o["type"]]+=1
 o["sha256"]=sha(dst)
# Full authoring PAR from all 192 real independent source image layers.
par=Image.new("RGBA",(1280,928),(0,0,0,0))
for o in new_manifest["objects"]:
 p=SOURCE/o["filename"]
 assert sha(p)==o["sha256"]
 par.alpha_composite(Image.open(p).convert("RGBA"),(o["x"],o["y"]))
p_par=OUTPUT/"A36H_R1_AUTHORING_COMPLETE_PAR.png"
par.save(p_par,optimize=True)
p_ground=OUTPUT/"A36H_R1_AUTHORING_GROUND_ONLY.png"
shutil.copy2(R5/"A36G_R5_GROUND_1280x928.png",p_ground)
scene=Image.open(p_ground).convert("RGBA")
scene.alpha_composite(par)
full=scene.convert("RGB")
p_full=OUTPUT/"A36H_R1_RUNTIME_FULL_SCENE_GROUND.png"
full.save(p_full,optimize=True)
full.resize((640,464),Image.Resampling.NEAREST).save(OUTPUT/"A36H_R1_PREVIEW_640.png")
# Native R7 local source mask mask reused as SAME-PIXEL semantic geometry, with candidate's new full-scene source colors.
r7=BASE/"A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107"
covered=np.zeros((928,1280),bool)
for o in new_manifest["objects"]:
 local=r7/(o["id"]+"_SOURCE_SEMANTIC_RGBA.png")
 if not local.exists():continue
 sa=np.asarray(Image.open(local).convert("RGBA"))[:,:,3]>127
 x,y=int(o["x"]),int(o["y"])
 yy=max(0,y);xx=max(0,x);endx=min(1280,x+o["w"]);endy=min(928,y+o["h"])
 if yy>=endy or xx>=endx:continue
 covered[yy:endy,xx:endx]|=sa[yy-y:endy-y,xx-x:endx-x]
packed=np.zeros((928,1280,4),np.uint8)
rgb=np.asarray(full)
packed[covered,:3]=rgb[covered]
packed[covered,3]=255
p_runtime=OUTPUT/"A36H_R1_RUNTIME_SOURCE_OWNED_5_PAR.png"
Image.fromarray(packed,"RGBA").save(p_runtime,optimize=True)
assert np.all(np.asarray(full)[covered]==packed[covered,:3])
new_manifest["stage"]="A36H_R1_ORIGINAL_FS_WOOD_ROOF_BLUEGREEN_FOREST_ART_DRAFT"
new_manifest["source_stage"]=M["stage"]
new_manifest["a36h_recolored_object_count"]=len(modified)
new_manifest["a36h_original_Ground3_style_ref"]=str(Path(r"E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png"))
new_manifest["a36h_art_gate"]="NEEDS_MANUAL_VISUAL_REVIEW"
new_manifest["formal_seal"]="NO"
new_manifest["ground_sha256"]=sha(p_ground)
new_manifest["par_sha256"]=sha(p_par)
new_manifest["composite_sha256"]=sha(p_full)
p_manifest=OUTPUT/"A36H_R1_SCENE_MANIFEST.json"
p_manifest.write_text(json.dumps(new_manifest,ensure_ascii=False,indent=2),encoding="utf8")
# Canvas-level, full 1:1 comparison with NO scaling of the 1280 source.
old_full=Image.open(R5/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
np_old=np.asarray(old_full);np_new=np.asarray(full)
changed=np.any(np_old!=np_new,axis=2)
contact=Image.new("RGB",(1280,500),(23,27,31))
d=ImageDraw.Draw(contact)
contact.paste(old_full.resize((640,464),Image.Resampling.NEAREST),(0,36))
contact.paste(full.resize((640,464),Image.Resampling.NEAREST),(640,36))
d.text((8,12),"R5 Original FAIL / actual Ground + PAR",fill="white")
d.text((650,12),"A36H R1 actual Ground + PAR - ART REVIEW REQUIRED",fill="white")
contact.save(OUTPUT/"A36H_R1_FULLSCENE_R5_BEFORE_AFTER_640.png")
for key,box in [
 ("LEFT_HOUSE",(305,145,705,518)),
 ("RIGHT_HOUSE",(708,330,1058,712)),
 ("FOREST_BLUEGREEN_NORTH",(330,0,890,336)),
]:
 before=old_full.crop(box)
 after=full.crop(box)
 proof=Image.new("RGB",(before.width*2,before.height+25),(25,27,28))
 proof.paste(before,(0,25));proof.paste(after,(before.width,25))
 dr=ImageDraw.Draw(proof)
 dr.text((5,5),"R5 BEFORE",fill="white")
 dr.text((before.width+5,5),"A36H R1 AFTER",fill="white")
 proof.save(OUTPUT/("A36H_R1_"+key+"_BEFORE_AFTER_1X.png"))
q={
 "stage":new_manifest["stage"],
 "canvas":[1280,928],"source_count":len(objs),"source_type_counts":dict(types),
 "original_R5_full_par_recompile_exact":pixels==0,"original_source_hashes_verified":192,
 "candidate_source_modified_count":len(modified),"candidate_edit_by_type":dict(collections.Counter(x["type"] for x in modified.values())),
 "candidate_foliage_color_changed_pixels_in_sources":nbytes,
 "final_full_scene_changed_pixels":int(changed.sum()),
 "R5_ground_only_unchanged":sha(p_ground)==sha(R5/"A36G_R5_GROUND_1280x928.png"),
 "R5_collision_unchanged":new_manifest["collision_map_29x40"]==M["collision_map_29x40"],
 "authoring_par_all_192_sources":True,
 "runtime_5source_alpha_mask_coverage":round(float(covered.mean()),6),
 "runtime_5source_opaque_rgb_identical_master":True,
 "modified_source_sha":modified,"native_VX":"NOT RUN","godot":"NOT RUN","human_art_gate":"PENDING",
 "formal_seal":"NO",
 "output_files":{"ground_only":p_ground.name,"complete_par":p_par.name,"runtime_full":p_full.name,"runtime_par":p_runtime.name,"manifest":p_manifest.name}
}
(OUTPUT/"A36H_R1_PIXEL_SOURCE_QA.json").write_text(json.dumps(q,ensure_ascii=False,indent=2),encoding="utf8")
print("FINAL",json.dumps({k:q[k] for k in ["source_count","original_R5_full_par_recompile_exact","candidate_source_modified_count","candidate_edit_by_type","candidate_foliage_color_changed_pixels_in_sources","final_full_scene_changed_pixels","R5_ground_only_unchanged","R5_collision_unchanged","runtime_5source_opaque_rgb_identical_master"]},ensure_ascii=False),flush=True)