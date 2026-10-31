from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,shutil,hashlib,json
lab=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
old=lab/"A14_OCCLUSION_RIG";out=lab/"A15_ART_REPAIR"
m1=Image.open(lab/"A10_ONE_MASTER_RIG"/"T1_forest_scout"/"master.png").convert("RGBA")
m2=Image.open(lab/"A10_ONE_MASTER_RIG"/"T2_moss_antler"/"master.png").convert("RGBA")
cfg=json.loads((old/"T2_moss_antler"/"rig_authority.json").read_text(encoding="utf8"))
qa={"revision":"A15_R1_ANATOMICAL_PART_SOURCE","T1":{"source_hilt_pixels_exact":{},"removal_candidates":[]},"T2":{"leg_source_polygons":{},"frames":[]}}
for case in ("T1_forest_scout","T2_moss_antler"):
 dst=out/case
 if dst.exists():raise RuntimeError("A15_FAIL_CLOSED_DST_EXISTS")
 dst.mkdir()
 shutil.copytree(old/case/"frames",dst/"frames")
 shutil.copy2(old/case/"clips.json",dst/"clips.json")
 shutil.copy2(old/case/"rig_authority.json",dst/"rig_authority.json")
# T1 source hilt RGB-key mask, conservative: only 4 gold-green pixels in the correct hip location.
# Frame0/1 still sheathed; frame2..7 drawn sword and EMPTY leather sheath must have no gold pommel.
# Use only original source pixels verified exactly in current frame (fail closed otherwise).
src_hilt={(40,63),(40,64),(41,63),(41,64)}
body_x=[0,-1,-1,0,1,1,0,0]
for fi in range(2,8):
 file=out/"T1_forest_scout"/"frames"/f"attack_{fi:02d}.png"
 im=Image.open(file).convert("RGBA")
 changes=[]
 for sx,sy in sorted(src_hilt):
  tx=16+sx+body_x[fi];ty=16+sy
  before=im.getpixel((tx,ty))
  original=m1.getpixel((sx,sy))
  if before!=original:
   qa["T1"]["source_hilt_pixels_exact"][f"{fi}/{sx},{sy}"]="NOT_MATCHED_SKIP"
   continue
  # Adapt palette from adjacent leather within the same original source image.
  replacement=m1.getpixel((38,sy))
  if replacement[3]!=255:raise AssertionError("BACKFILL_OPAQUE_SOURCE_REQUIRED")
  im.putpixel((tx,ty),replacement)
  changes.append({"src":[sx,sy],"dst":[tx,ty],"old":list(before),"new":list(replacement)})
 qa["T1"]["removal_candidates"].extend({"frame":fi,**x} for x in changes)
 if changes:im.save(file)
# T2 original source master leg masks: disjoint organic polygon areas and dark hoof only
# preventing duplicated light belly pixels formerly present in oversized rectangular source leg patches.
masks={
 "front_far":[(15,53),(19,52),(24,54),(25,58),(23,61),(17,61),(14,58)],
 "front_near":[(23,53),(29,52),(34,55),(34,61),(28,63),(23,59)],
 "back_far":[(39,53),(45,53),(49,56),(48,61),(42,62),(37,58)],
 "back_near":[(49,52),(55,53),(60,55),(60,61),(53,62),(47,57)],
}
parts={}
for name,polygon in masks.items():
 mask=Image.new("L",(64,64),0);ImageDraw.Draw(mask).polygon(polygon,fill=255)
 a=np.asarray(m2).copy()
 alpha=np.asarray(mask)
 for y in range(64):
  for x in range(64):
   if alpha[y,x]==0 or y<53:
    a[y,x,3]=0;continue
   # Keep the natural dark brown hoof/leg pixels, not large face/belly beige or bright moss.
   rr,gg,bb,aa=a[y,x]
   if aa and not ((rr<175 and gg<145 and bb<100) or (y>=58 and rr<210 and gg<175 and bb<140)):
    a[y,x,3]=0
 im=Image.fromarray(a,"RGBA")
 im.save(out/"T2_moss_antler"/f"part_{name}.png")
 parts[name]=im
 qa["T2"]["leg_source_polygons"][name]={"vertices":polygon,"source_opaque":int(np.asarray(im.getchannel("A")).astype(bool).sum())}
# Body source with original hooves surgically removed from y>=56, preserving upper torso/face/antlers.
body=np.asarray(m2).copy()
for y in range(56,64):
 for x in range(12,61):
  rr,gg,bb,aa=body[y,x]
  if aa and rr<180 and gg<145 and bb<110:
   body[y,x,3]=0
body=Image.fromarray(body,"RGBA")
body.save(out/"T2_moss_antler"/"body_preserve_belly.png")
for row in cfg["semantic_frames"]:
 i=row["frame"]
 if i in (0,7):continue
 dx,dy=row["root_offset"]
 canvas=Image.new("RGBA",(96,96))
 # source limbs are full-size 64x64 masked RGBA with common origins
 for n in ("front_far","back_far"):
  name=n
  old_anchor=cfg["limb_origins_master_coords"][name]
  target=row["foot_targets"][name]
  tx=int(target[0]-(16+old_anchor[0]));ty=int(target[1]-75)
  canvas.alpha_composite(parts[name],(16+tx,15+ty))
 canvas.alpha_composite(body,(16+dx,15+dy))
 for name in ("front_near","back_near"):
  old_anchor=cfg["limb_origins_master_coords"][name]
  target=row["foot_targets"][name]
  tx=int(target[0]-(16+old_anchor[0]));ty=int(target[1]-75)
  canvas.alpha_composite(parts[name],(16+tx,15+ty))
 canvas.save(out/"T2_moss_antler"/"frames"/f"attack_{i:02d}.png")
 qa["T2"]["frames"].append({"frame":i,"root_offset":[dx,dy],
 "source":"single Master segmented organic brown-leg pixels and preserved belly"})
# QA strict source lineage, image no-edge, nonattack unchanged.
for name in ["T1_forest_scout","T2_moss_antler"]:
 ps=out/name/"frames"
 before=old/name/"frames"
 nonattack=list(ps.glob("*.png"))
 for f in nonattack:
  if not f.name.startswith("attack_"):
   assert f.read_bytes()==(before/f.name).read_bytes()
 frame_hashes=[]
 for i in range(8):
  im=Image.open(ps/f"attack_{i:02d}.png").convert("RGBA")
  a=np.asarray(im.getchannel("A"))
  assert (a[0].sum()+a[-1].sum()+a[:,0].sum()+a[:,-1].sum())==0
  assert a.max()==255 and a.min()==0
  frame_hashes.append(hashlib.sha256(im.tobytes()).hexdigest())
 qa[name]={"unique_attack_frames":len(set(frame_hashes)),"nonattack_byte_identical":True,
 "changed_attack_frames":[i for i in range(8) if (ps/f"attack_{i:02d}.png").read_bytes()!=(before/f"attack_{i:02d}.png").read_bytes()]}
qa["status"]="A15_R1_RENDER_READY_G7_NOT_PASSED"
(out/"A15_R1_SOURCE_ART_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"T1_hilt_replacements":len(qa["T1"]["removal_candidates"]),"T1_changed":qa["T1_forest_scout"]["changed_attack_frames"],
"T2_changed":qa["T2_moss_antler"]["changed_attack_frames"],"source_counts":{x:qa["T2"]["leg_source_polygons"][x]["source_opaque"] for x in masks}},ensure_ascii=False))