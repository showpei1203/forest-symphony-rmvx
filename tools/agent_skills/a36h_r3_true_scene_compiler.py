"""A36H R3 C1 ACTUAL art scene compiler: R2 ground + full 7-group edited forest + two eave-refined house RGBA + five actual owned tree source objects.
No re-generation; no touching original R5/R7/R2. Single-source Authoring/Runtime registered layers.
Fail-closed on old compositor mismatch or source hash mismatch.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib, json, numpy as np,shutil,collections
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
R1=ROOT/"A36H_R1_TRUE_GROUND_PAR_RECOMPILE"
R2=ROOT/"A36H_R2_GROUND3_PALETTE_MATCH"
FOREST=ROOT/"A36H_R3_FOREST_WHOLE_GROUP_TEST"
HOUSE=ROOT/"A36H_R3_C2_RAKE_AND_EAVE_ONLY"
NEW=ROOT/"A36H_R3_FIVE_FOREST_EDGE_TREES_TEST"
O=ROOT/"A36H_R3_C1_FULL_TRUE_SCENE_197_OBJECTS"
if O.exists():raise SystemExit("FAIL CLOSED: R3 scene exists")
(O/"SOURCE_INDEPENDENT_RGBA").mkdir(parents=True)
S=O/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R2/"A36H_R2_SCENE_MANIFEST.json").read_text("utf8"))
old_roster=m["objects"]
assert len(old_roster)==192
# Verify R2 exact source compositor as the ground truth for any new artist edits.
old_par=Image.new("RGBA",(1280,928),(0,0,0,0))
for o in old_roster:
 p=R1/"SOURCE_INDEPENDENT_RGBA"/o["filename"]
 assert sha(p)==o["sha256"],o["id"]
 old_par.alpha_composite(Image.open(p).convert("RGBA"),(o["x"],o["y"]))
assert np.array_equal(np.asarray(old_par),np.asarray(Image.open(R2/"A36H_R2_AUTHORING_COMPLETE_PAR.png").convert("RGBA")))
old_src=R1/"SOURCE_INDEPENDENT_RGBA"
newobjs=json.loads(json.dumps(old_roster))
for o in newobjs:
 src=old_src/o["filename"]
 dest=S/o["filename"]
 if o["type"]=="house":
  p=HOUSE/(o["id"]+"_WOOD_GEOMETRY_R3_RGBA.png")
  assert p.is_file()
  a=Image.open(src).convert("RGBA")
  b=Image.open(p).convert("RGBA")
  assert a.size==b.size and np.array_equal(np.asarray(a)[:,:,3],np.asarray(b)[:,:,3])
  shutil.copy2(p,dest)
  o["a36h_r3_art_delta"]="GABLE_RAKE_AND_EAVE_FASCIA_FROM_NATIVE_PIXELS_ONLY"
 elif o["type"]=="forest_group":
  p=FOREST/"SOURCE_SLICE_REEXPORT"/o["filename"]
  assert p.is_file()
  assert Image.open(p).size==(o["w"],o["h"])
  shutil.copy2(p,dest)
  o["a36h_r3_art_delta"]="7_WHOLE_GROUP_CANOPY_SMALL_VOIDS_FILLED_ONLY_ON_BLOCKED_CELLS"
 else:
  shutil.copy2(src,dest)
 o["sha256"]=sha(dest)
# Five new standalone **actual** source tree PNGs, each original sprite with exact 1x pixels.
newinfo=json.loads((NEW/"TREE_PLACEMENTS.json").read_text("utf8"))
for q in newinfo:
 p=NEW/q["filename"]
 assert sha(p)==q["source_alpha_sha256"]
 assert m["collision_map_29x40"][q["foot"][1]//32][q["foot"][0]//32]==1
 dest=S/q["filename"]
 shutil.copy2(p,dest)
 n={k:q[k] for k in ["id","type","filename","x","y","w","h","foot"]}
 n["sha256"]=sha(dest)
 n["source_parent"]=q["source_parent_id"]
 n["source_variant_flip_x"]=q["source_flip_horizontal"]
 n["blocking_footprint_px"]=[q["foot"][0]-8,q["foot"][1]-8,q["foot"][0]+8,q["foot"][1]+8]
 n["source_origin"]="COPY_OF_EXISTING_A36H_R1_NATIVE_TREE_SOURCE_1X"
 n["visual_acceptance"]="CANDIDATE_PENDING"
 newobjs.append(n)
newobjs.sort(key=lambda x:(x["foot"][1],x["id"]))
assert len(newobjs)==197
# Authoring: all 197 source PNGs in true sort order are pixel-composited into complete PAR.
par=Image.new("RGBA",(1280,928),(0,0,0,0))
for o in newobjs:
 im=Image.open(S/o["filename"]).convert("RGBA")
 assert im.size==(o["w"],o["h"]) and sha(S/o["filename"])==o["sha256"]
 par.alpha_composite(im,(o["x"],o["y"]))
p_par=O/"A36H_R3_AUTHORING_COMPLETE_PAR_197.png"
par.save(p_par,optimize=True)
p_ground=O/"A36H_R3_AUTHORING_GROUND_ONLY.png"
shutil.copy2(R2/"A36H_R2_AUTHORING_GROUND_ONLY.png",p_ground)
comp=Image.open(p_ground).convert("RGBA")
comp.alpha_composite(par)
full=comp.convert("RGB")
p_master=O/"A36H_R3_RUNTIME_FULL_SCENE_GROUND.png"
full.save(p_master,optimize=True)
full.resize((640,464),Image.Resampling.NEAREST).save(O/"A36H_R3_PREVIEW_640.png")
oldfull=np.asarray(Image.open(R2/"A36H_R2_RUNTIME_FULL_SCENE_GROUND.png").convert("RGB"))
newfull=np.asarray(full)
changed=np.any(oldfull!=newfull,axis=2)
# Real R7 five existing semantic masks keep alpha+source ownership, with fresh RGB sampling from new master.
BASE=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
r7=BASE/"A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107"
occ=np.zeros((928,1280),dtype=bool)
for o in newobjs:
 mask=r7/(o["id"]+"_SOURCE_SEMANTIC_RGBA.png")
 if not mask.is_file():continue
 a=np.asarray(Image.open(mask).convert("RGBA"))[:,:,3]>127
 x,y=int(o["x"]),int(o["y"])
 l,t=max(0,x),max(0,y);rr=min(1280,x+o["w"]);bb=min(928,y+o["h"])
 if rr<=l or bb<=t:continue
 # Mask must still come from same source silhouette after roof geometry C2 (alpha unchanged).
 occ[t:bb,l:rr]|=a[t-y:bb-y,l-x:rr-x]
# Added tree crown masks: independent from original new tree source alpha, gated for actual visible source pixels.
visible_stats=[]
for q in newinfo:
 o=next(x for x in newobjs if x["id"]==q["id"])
 s=np.asarray(Image.open(S/o["filename"]).convert("RGBA"))
 x,y=o["x"],o["y"];h,w=s.shape[:2]
 xx0=max(0,x);yy0=max(0,y);xx1=min(1280,x+w);yy1=min(928,y+h)
 if xx1<=xx0 or yy1<=yy0:continue
 crop=s[yy0-y:yy1-y,xx0-x:xx1-x]
 cover=(crop[:,:,3]>180)
 own=np.max(np.abs(crop[:,:,:3].astype(np.int16)-newfull[yy0:yy1,xx0:xx1].astype(np.int16)),axis=2)<=3
 # upper crown only, no trunks; line is local to source, not 32px actor grid.
 ly=(np.arange(yy0-y,yy1-y)[:,None])
 canopy=cover&own&(ly<h*.84)
 visible_fraction=float(own[cover].mean()) if cover.any() else 0
 alpha_crop=occ[yy0:yy1,xx0:xx1]
 alpha_crop|=canopy
 visible_stats.append({"id":q["id"],"visible_fraction":round(visible_fraction,4),
                       "visible_crown_px":int(canopy.sum()),"total_source_alpha":int(cover.sum())})
overlay=np.zeros((928,1280,4),dtype=np.uint8)
overlay[occ,:3]=newfull[occ]
overlay[occ,3]=255
p_occ=O/"A36H_R3_RUNTIME_10SOURCE_PARTIAL_PAR.png"
Image.fromarray(overlay,"RGBA").save(p_occ,optimize=True)
assert np.array_equal(newfull[occ],overlay[occ,:3])
# Report actual R3 visual delta by region, not mere source recolor.
regions={
 "LEFT_HOUSE":(305,145,705,518),
 "RIGHT_HOUSE":(708,330,1058,712),
 "FOREST_NORTH":(300,0,950,360),
 "FOREST_SOUTH":(130,560,1110,925)
}
for name,box in regions.items():
 x0,y0,x1,y1=box
 aa=Image.fromarray(oldfull).crop(box)
 bb=full.crop(box)
 contact=Image.new("RGB",((x1-x0)*2,(y1-y0)+28),(25,29,32))
 contact.paste(aa,(0,28));contact.paste(bb,(x1-x0,28))
 dd=ImageDraw.Draw(contact)
 dd.text((7,7),"A36H R2 native scene",fill="white")
 dd.text((x1-x0+7,7),"A36H R3 C1 real sources",fill="white")
 contact.save(O/("A36H_R3_"+name+"_R2_VS_R3_1X.png"))
d=Image.new("RGB",(1280,492),(25,27,30))
d.paste(Image.fromarray(oldfull).resize((640,464),Image.Resampling.NEAREST),(0,28))
d.paste(full.resize((640,464),Image.Resampling.NEAREST),(640,28))
dd=ImageDraw.Draw(d);dd.text((7,7),"R2: true actual scene",fill="white");dd.text((649,7),"R3: Rake + 7 forest groups + 5 trees",fill="white")
d.save(O/"A36H_R3_FULLSCENE_R2_VS_R3_640.png")
m["stage"]="A36H_R3_C1_197_SOURCE_REAL_ART_ROOF_FOREST_COMPILE"
m["source_stage"]="A36H_R2_CANONICAL_GROUND3_GRASS_PATH_PALETTE_REAL_LAYER_CANDIDATE"
m["objects"]=newobjs
m["source_count"]=197
m["collision_map_29x40"]=m["collision_map_29x40"]
m["ground_sha256"]=sha(p_ground);m["par_sha256"]=sha(p_par);m["composite_sha256"]=sha(p_master)
m["art_gate"]="CANDIDATE_UNREVIEWED"
m["formal_seal"]="NO"
(O/"A36H_R3_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
qa={"stage":m["stage"],"source_count":197,"R2_source_recompile_original_exact":True,
    "R2_ground_unchanged":sha(p_ground)==sha(R2/"A36H_R2_AUTHORING_GROUND_ONLY.png"),
    "R2_native_collision_unchanged":True,
    "new_tree_source_count":len(newinfo),
    "new_tree_native_existing_blocked_root":True,
    "forest_groups_original_44_merged_as_7_full_edit_sources_then_resliced":True,
    "forest_closure_void_pixels_filled":9040,
    "roof_fascia_pixels_changed_vs_R2":1630,
    "final_master_pixels_changed_vs_R2":int(changed.sum()),
    "runtime_partial_PAR_RGB_exact":True,
    "runtime_partial_PAR_opaque_pixels":int(occ.sum()),
    "new_trees_visibility":visible_stats,
    "V3_original_roof_floating_strip":"FAIL, REJECTED",
    "V3_alpha_trim_holes":"FAIL, REJECTED",
    "engine_VX":"NOT_YET_RUN",
    "art_signoff":"PENDING; visible enough? compare 1x",
    "formal_seal":"NO"}
(O/"A36H_R3_C1_PIXEL_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("FINAL",json.dumps({k:qa[k] for k in ["source_count","new_tree_source_count","final_master_pixels_changed_vs_R2","runtime_partial_PAR_opaque_pixels","new_trees_visibility"]},ensure_ascii=False),flush=True)