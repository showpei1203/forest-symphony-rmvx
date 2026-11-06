"""FS V4 A36G R6: Source-registered semantic actor-occlusion candidate.
This is a NEW independent candidate, not art approval.
Inputs: original R5 independent source assets + canonical Scene Manifest + saved R5 master.
Outputs: authoring layers preserved, separate engine full-scene ground / derived local actor-occlusion.
NO image generation and no source modification.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,hashlib,json,collections,shutil
from scipy.ndimage import gaussian_filter
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
O=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_R6_C2_CONTINUOUS_OCCLUSION_20261107")
if O.exists():
 raise SystemExit("REFUSED existing candidate "+str(O))
O.mkdir(parents=True)
M=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text(encoding="utf8"))
assets=R5/"SOURCE_INDEPENDENT_RGBA"
master=R5/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"
ground=R5/"A36G_R5_GROUND_1280x928.png"
complete=R5/"A36G_R5_PAR50_RGBA_1280x928.png"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert M["canvas"]==[1280,928]
assert len(M["collision_map_29x40"])==29
assert len(M["objects"])==192
# Full scene is the runtime Ground; GroundOnly and CompletePAR are preserved authoring sources.
for s,name in ((master,"R6_RUNTIME_FULL_SCENE_GROUND.png"),
               (ground,"R6_AUTHORING_GROUND_ONLY.png"),
               (complete,"R6_AUTHORING_COMPLETE_PAR.png")):
 shutil.copy2(s,O/name)
with Image.open(master) as i: original=np.asarray(i.convert("RGB"))
with Image.open(ground) as i: base=np.asarray(i.convert("RGBA"))
with Image.open(complete) as i: upper=np.asarray(i.convert("RGBA"))
assert original.shape==(928,1280,3)==base.shape[:2]+(3,)
assert np.array_equal(np.asarray(Image.alpha_composite(Image.fromarray(base),Image.fromarray(upper)).convert("RGB")),original)
blocking=M["collision_map_29x40"]
# Each potential player sprite rectangle at a WALKABLE tile (real RMVX body footprint).
actor_tiles=[(x*32+16,y*32+32) for y in range(29) for x in range(40) if not blocking[y][x]]
W,H=1280,928
mask=np.zeros((H,W),dtype=bool)
types=collections.defaultdict(lambda:{"objects":0,"source_alpha_pixels":0,"generated_mask_pixels":0})
fail=[]
object_metrics=[]
for obj in M["objects"]:
 src=assets/obj["filename"]
 if not src.exists():
  fail.append("Missing source: "+str(src));continue
 h=sha(src)
 if obj.get("sha256") and h!=obj["sha256"]:
  fail.append("SHA mismatch: "+obj["id"]);continue
 with Image.open(src) as s:
  rgba=np.asarray(s.convert("RGBA"))
 oy,ox=int(obj["y"]),int(obj["x"])
 sh,sw=rgba.shape[:2]
 if sw!=int(obj["w"]) or sh!=int(obj["h"]):
  fail.append("Object bbox mismatch "+obj["id"]+f" {sw}x{sh}!={obj['w']}x{obj['h']}")
  continue
 x0,y0=max(0,ox),max(0,oy)
 x1,y1=min(W,ox+sw),min(H,oy+sh)
 if x0>=x1 or y0>=y1:
  continue
 # Full source alpha (not a generated full-frame image) controls candidate geometry.
 source=rgba[y0-oy:y1-oy,x0-ox:x1-ox,3]>127
 if not source.any():continue
 if obj["type"] not in ("tree","forest_group","house","landmark"):
  # Shrubs are retained in authoring COMPLETE PAR, but do not automatically become actor-overlap occluders.
  object_metrics.append({"id":obj["id"],"type":obj["type"],"candidate_pixels":0,"reason":"non_tall_source_not_auto_occluder"})
  continue
 fy=int(obj.get("foot",[ox+sw//2,oy+sh])[1])
 # For each physically walkable player position, include source-art pixels only when:
 # 1) the actor's 32px body rectangle genuinely overlaps the source art,
 # 2) the player's foot is BEHIND the source object's foot in orthographic y-sort.
 # No arbitrary horizontal slice; this is scene/actor geometry-derived.
 possible=np.zeros(source.shape,dtype=bool)
 for cx,py in actor_tiles:
  if py>=fy:continue
  bx0,bx1=cx-12,cx+12
  by0,by1=py-32,py
  if bx1<=x0 or bx0>=x1 or by1<=y0 or by0>=y1:continue
  lx=max(bx0,x0)-x0;rx=min(bx1,x1)-x0
  ty=max(by0,y0)-y0;by=min(by1,y1)-y0
  possible[ty:by,lx:rx]=True
 # Smooth only the POSSIBLE ACTOR POSITION FIELD, never blur source art or runtime alpha.
 # This eliminates 32px sample lattice artifacts while source alpha remains exact.
 continuous=gaussian_filter(possible.astype(np.float32),sigma=7.5)>0.19
 included=source & continuous
 if included.any():
  mask[y0:y1,x0:x1]|=included
 t=types[obj["type"]]
 t["objects"]+=1
 t["source_alpha_pixels"]+=int(source.sum())
 t["generated_mask_pixels"]+=int(included.sum())
 object_metrics.append({"id":obj["id"],"type":obj["type"],"bbox":[ox,oy,sw,sh],"foot":obj.get("foot"),
                        "alpha_pixels":int(source.sum()),"mask_pixels":int(included.sum()),
                        "mask_fraction":round(float(included.sum()/max(source.sum(),1)),5)})
if fail:
 (O/"SOURCE_FAILURES.txt").write_text("\n".join(fail),encoding="utf8")
 raise SystemExit(f"FAIL CLOSED: {len(fail)} source missing/invalid. See SOURCE_FAILURES.txt")
# Create RGBA overlay derived pixel-for-pixel from final already authored full-scene.
runtime=np.zeros((H,W,4),dtype=np.uint8)
runtime[mask,:3]=original[mask]
runtime[mask,3]=255
par=O/"R6_RUNTIME_SOURCE_REGISTERED_PAR50.png"
Image.fromarray(runtime,"RGBA").save(par)
rgbmatch=np.mean(np.all(runtime[mask,:3]==original[mask],axis=1)) if mask.any() else 0
with Image.open(par) as im:
 assert im.mode=="RGBA" and im.size==(W,H)
assert rgbmatch==1.0
# QA: style visually unchanged from R5; new overlay is not art recolor.
assert sha(O/"R6_RUNTIME_FULL_SCENE_GROUND.png")==sha(master)
assert sha(O/"R6_AUTHORING_GROUND_ONLY.png")==sha(ground)
assert sha(O/"R6_AUTHORING_COMPLETE_PAR.png")==sha(complete)
# RGB recomposition unchanged: replicated pixel overlay on full-scene cannot change stationary world.
new_comp=np.asarray(Image.alpha_composite(Image.fromarray(np.dstack([original,np.full((H,W),255,dtype=np.uint8)])),Image.fromarray(runtime)).convert("RGB"))
assert np.array_equal(new_comp,original)
# Document how much each root class contributes; preserve semantic mask for subsequent manual review.
Image.fromarray((mask.astype(np.uint8)*255),"L").save(O/"R6_RUNTIME_OCCLUSION_MASK.png")
viz=Image.fromarray(original).convert("RGBA")
heat=np.zeros((H,W,4),dtype=np.uint8)
heat[mask]=[255,80,20,105]
viz=Image.alpha_composite(viz,Image.fromarray(heat))
viz.resize((640,464),Image.Resampling.NEAREST).save(O/"R6_OCCLUSION_HEATMAP_640.png")
manifest={
 "stage":"FS_A36G_R6_C2_CONTINUOUS_OCCLUSION_DRAFT",
 "upstream":"A36G_R5_R2 192 actual object source PNGs, unchanged",
 "canvas":[1280,928],"grid":[40,29],
 "source_manifest_sha256":sha(R5/"A36G_R5_SCENE_MANIFEST.json"),
 "source_master_sha256":sha(master),
 "source_ground_only_sha256":sha(ground),
 "source_complete_par_sha256":sha(complete),
 "source_objects":len(M["objects"]),
 "asset_types":dict(types),
 "mask_nonzero_pixels":int(mask.sum()),
 "mask_coverage":round(float(mask.mean()),6),
 "runtime_PAR_alpha_full_opaque":True,
 "runtime_ground_RGB_matches_master":True,
 "runtime_par_rgb_matches_runtime_ground_opaque":True,
 "runtime_full_scene_composite_equal_master":True,
 "authoring_ground_and_complete_par_preserved":True,
 "occlusion_algorithm":"same-source object alpha AND gaussian-smoothed physically possible walkable actor body footprint AND player foot behind object foot; binary output source pixels, no art blur",
 "known_limitations":[
   "Dense group depth slices are not semantic individual trees; per-group foot may be surrogate rather than biological root.",
   "Overlay mask excludes non-tall shrubs by policy; shrub occlusion remains manually unapproved.",
   "Generated candidate geometry is a heuristic and can omit genuine tree/roof occlusion or occlude foreground incorrectly.",
   "R5 original art explicitly rejected relative to canonical FS ground3; no aesthetic improvement claimed."
 ],
 "art_acceptance":"FAIL (R5 inherited)",
 "runtime_vx_gate":"NOT YET VERIFIED",
 "godot_gate":"NOT YET VERIFIED",
 "formal_seal":"NO",
 "outputs":{f.name:sha(f) for f in O.glob("R6_*.png")},
 "object_qa":object_metrics,
 }
(O/"R6_SCENE_DERIVATION_QA.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({k:manifest[k] for k in ["mask_nonzero_pixels","mask_coverage","asset_types","authoring_ground_and_complete_par_preserved","runtime_full_scene_composite_equal_master","art_acceptance","runtime_vx_gate"]},ensure_ascii=False,indent=2))
print("OUTPUT",O)