"""FS A36G R7 C1: right house + 3 *actually visible* tree crowns + prior left house.
Hard rules: source SHA, per-pixel visibility ownership, R5 collision-walkable actor test points, no forest_group footpoint blanket masks.
"""
from pathlib import Path
from PIL import Image,ImageDraw
from scipy.ndimage import binary_closing,binary_fill_holes,binary_opening
import json, numpy as np, hashlib, shutil
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
BASE=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
OUT=BASE/"A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107"
if OUT.exists():raise SystemExit("FAIL CLOSED: candidate output exists")
OUT.mkdir(parents=True)
M=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text(encoding="utf8"))
origin=R5/"SOURCE_INDEPENDENT_RGBA"
master=R5/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"
rgb=np.asarray(Image.open(master).convert("RGB"))
H,W=rgb.shape[:2]
assert (H,W)==(928,1280)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
selected=[
 "A36G_ELF_HOUSE_AND_WORKSHOP",
 "A36G_R5_COTTAGE_B_SINGLE_ROOF",
 "tree_093","tree_010","tree_020"
]
manual_roof={
"A36G_R5_COTTAGE_B_SINGLE_ROOF":[
 [(68,25),(109,24),(159,47),(207,85),(254,120),(245,136),(208,109),(169,83),(154,103),(139,139),(117,173),(47,181),(18,135),(36,90)],
]}
source_count={}
occupancy=np.zeros((H,W),dtype=np.uint8)
mask_per={};summary=[]
for id in selected:
 o=next(z for z in M["objects"] if z["id"]==id)
 p=origin/o["filename"]
 assert sha(p)==o["sha256"],id
 src=Image.open(p).convert("RGBA");sw,sh=src.size
 assert (sw,sh)==(o["w"],o["h"])
 arr=np.asarray(src)
 a=arr[:,:,3]>=224
 if id=="A36G_ELF_HOUSE_AND_WORKSHOP":
  mask_src=BASE/"A36G_V6_C2_REFINED_ROOF_MASK_20261107"/(id+"_SEMANTIC_SOURCE_RGBA.png")
  sm=Image.open(mask_src).convert("RGBA")
  assert sm.size==src.size
  sem=np.asarray(sm)[:,:,3]>=128
  assert not np.any(sem & ~a)
 elif id in manual_roof:
  poly=Image.new("L",(sw,sh),0); dr=ImageDraw.Draw(poly)
  for pts in manual_roof[id]:dr.polygon(pts,fill=255)
  bounds=np.asarray(poly)>0
  hsv=np.asarray(src.convert("HSV"))
  hue,sat,val=hsv[:,:,0],hsv[:,:,1],hsv[:,:,2]
  moss=((hue>=33)&(hue<=96)&(sat>=52)&(val>=8))
  sem=bounds & moss & a
 else:
  hsv=np.asarray(src.convert("HSV"))
  hue,sat,val=hsv[:,:,0],hsv[:,:,1],hsv[:,:,2]
  greens=(hue>=38)&(hue<=113)&(sat>=57)&(val>=19)
  greenfield=binary_closing(greens & a,structure=np.ones((3,3)),iterations=1)
  greenfield=binary_fill_holes(greenfield)
  # Prevent woody trunks being pulled into canopy by hole fill.
  cutoff={"tree_093":.81,"tree_010":.81,"tree_020":.83}[id]
  greenfield[int(sh*cutoff):,:]=False
  sem=greenfield & a
 # Do not claim an invisible source owns another object's world pixels.
 x,y=int(o["x"]),int(o["y"])
 wx0=max(0,x);wy0=max(0,y);wx1=min(W,x+sw);wy1=min(H,y+sh)
 crop=sem[wy0-y:wy1-y,wx0-x:wx1-x]
 sr=arr[wy0-y:wy1-y,wx0-x:wx1-x,:3]
 underlying=rgb[wy0:wy1,wx0:wx1]
 visible=np.max(np.abs(sr.astype(np.int16)-underlying.astype(np.int16)),axis=2)<=3
 local_visible=crop & visible
 visibility_frac=round(float(local_visible.sum()/max(1,crop.sum())),4)
 if visibility_frac<.95:raise RuntimeError(f"source not visible as claimed: {id} frac={visibility_frac}")
 occupancy[wy0:wy1,wx0:wx1] += local_visible.astype(np.uint8)
 full=np.zeros((H,W),dtype=bool)
 full[wy0:wy1,wx0:wx1]=local_visible
 mask_per[id]=full
 sourcemask=np.zeros((sh,sw,4),dtype=np.uint8)
 sourcemask[sem]=arr[sem]
 Image.fromarray(sourcemask,"RGBA").save(OUT/(id+"_SOURCE_SEMANTIC_RGBA.png"))
 heat=np.zeros_like(arr)
 heat[sem]=[250,55,20,108]
 Image.alpha_composite(src,Image.fromarray(heat)).save(OUT/(id+"_SOURCE_WITNESS.png"))
 rec={"id":id,"type":o["type"],"source":o["filename"],"source_sha256":sha(p),
  "world_xy":[x,y],"local_size":[sw,sh],"selected_pixels":int(sem.sum()),
  "selected_visible_pixels":int(local_visible.sum()),"visible_semantic_fraction":visibility_frac,
  "scene_ownership_gate":True,"human_art_review":"PENDING"}
 summary.append(rec)
 print("SOURCE",id,"selected",rec["selected_pixels"],"visible",rec["selected_visible_pixels"],"owned",visibility_frac,flush=True)
keep=occupancy>0
assert not np.any(occupancy>2),"too many overlapping object masks"
rpar=np.zeros((H,W,4),dtype=np.uint8)
rpar[keep,:3]=rgb[keep]
rpar[keep,3]=255
par=OUT/"R7_RUNTIME_PAR50_5OBJECTS.png"
Image.fromarray(rpar,"RGBA").save(par)
for filename,name in [
 ("A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png","R7_RUNTIME_FULL_SCENE_GROUND50.png"),
 ("A36G_R5_GROUND_1280x928.png","R7_AUTHORING_GROUND_ONLY.png"),
 ("A36G_R5_PAR50_RGBA_1280x928.png","R7_AUTHORING_COMPLETE_PAR.png")
]:
 shutil.copy2(R5/filename,OUT/name)
assert sha(OUT/"R7_RUNTIME_FULL_SCENE_GROUND50.png")==sha(master)
assert np.all(rpar[keep,:3]==rgb[keep])
# Test spots: prioritize manifest-walkable (true traversable) tiles; report when source cannot occlude actual walkable 32x32 actor.
blocked=M["collision_map_29x40"]
report_by_id={}
for id,mask in mask_per.items():
 scores=[]
 for ty in range(29):
  for tx in range(40):
   cx=tx*32+16;fy=ty*32+32
   rect=mask[fy-32:fy,cx-12:cx+12]
   if rect.shape!=(32,24):continue
   if rect.sum()<=0:continue
   scores.append({"tile":[tx,ty],"overlap":round(float(rect.mean()),4),"walkable":blocked[ty][tx]==0})
 walk=sorted([x for x in scores if x["walkable"]],key=lambda r:r["overlap"],reverse=True)
 allbest=sorted(scores,key=lambda r:r["overlap"],reverse=True)
 report_by_id[id]={"walkable_top10":walk[:10],"all_top5":allbest[:5],
                   "walkable_above_10pct":len([v for v in walk if v["overlap"]>.1]),
                   "walkable_max_overlap":walk[0]["overlap"] if walk else 0.0}
 print("ACTOR_SAMPLES",id,"top_walkable",walk[:3],"top_all",allbest[:2],flush=True)
# draw real scene with precise source mask overlay and 32 grid.
witness=Image.fromarray(rgb).convert("RGBA")
hl=np.zeros((H,W,4),dtype=np.uint8);hl[keep]=[255,85,15,126]
witness=Image.alpha_composite(witness,Image.fromarray(hl))
witness.resize((640,464),Image.Resampling.NEAREST).save(OUT/"R7_5OBJECTS_FULL_HEATMAP_640.png")
from PIL import ImageDraw
vis=witness.convert("RGB")
dr=ImageDraw.Draw(vis)
for id,rec in report_by_id.items():
 if rec["walkable_top10"]:
  tile=rec["walkable_top10"][0]["tile"]
  dr.rectangle((tile[0]*32+4,tile[1]*32+3,tile[0]*32+28,tile[1]*32+29),outline="yellow",width=2)
vis.resize((640,464),Image.Resampling.NEAREST).save(OUT/"R7_5OBJECTS_WALKABLE_TEST_WITNESS_640.png")
# ensure old invisible tree_003 is deliberately omitted
assert "tree_003" not in selected and "tree_056" not in selected
R={
 "stage":"A36G_R7_C1_FIVE_OBJECT_NATIVE_SOURCE_VISIBILITY_GATED",
 "A36G_R5_manifest_sha":sha(R5/"A36G_R5_SCENE_MANIFEST.json"),
 "A36G_R5_master_sha":sha(master),
 "selected_sources":summary,
 "walkable_test_candidates":report_by_id,
 "selected_count":len(selected),
 "out_of_scope_R5_total_objects":len(M["objects"]),
 "exclusions":["tree_003 original object visibility ~5.12%","tree_056 original object visibility ~1.92%"],
 "runtime_mask_opaque_px":int(keep.sum()),
 "runtime_mask_fraction":round(float(keep.mean()),6),
 "runtime_rgb_equals_master":True,
 "authoring_complete_par_preserved":True,
 "source_sha_validated":True,
 "source_visibility_pixel_gate":True,
 "native_203_gate":"NOT RUN",
 "A36G_R5_art_gate":"FAIL",
 "C1_per_object_art_gate":"PENDING",
 "formal_seal":"NO"
}
(OUT/"R7_C1_FIVE_OBJECTS_SOURCE_QA.json").write_text(json.dumps(R,ensure_ascii=False,indent=2),encoding="utf8")
print("FINAL",json.dumps({"sources":len(selected),"coverage":R["runtime_mask_fraction"],"walkable_max":{k:v["walkable_max_overlap"] for k,v in report_by_id.items()}},ensure_ascii=False),flush=True)