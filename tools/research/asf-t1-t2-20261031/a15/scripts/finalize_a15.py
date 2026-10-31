from pathlib import Path
from PIL import Image
import numpy as np,shutil,json,hashlib
lab=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
out=lab/"A15_ART_REPAIR";final=out/"FINAL_CANDIDATE"
assert not final.exists(),"FAIL_CLOSED_FINAL_ALREADY_EXISTS"
final.mkdir()
old=lab/"A14_OCCLUSION_RIG"
for case in ("T1_forest_scout","T2_moss_antler"):
 target=final/case;target.mkdir()
 shutil.copytree(out/case/"frames",target/"frames")
 shutil.copy2(out/case/"clips.json",target/"clips.json")
 shutil.copy2(out/case/"rig_authority.json",target/"rig_authority.json")
# Retain only collision and brake dust from R2, not floating dots on launch/recovery.
for i in [4,5]:
 shutil.copy2(out/"r2"/"T2_moss_antler"/"frames"/f"attack_{i:02d}.png",
              final/"T2_moss_antler"/"frames"/f"attack_{i:02d}.png")
# validate actual visual/source identity and the target of source matching
m2=np.asarray(Image.open(lab/"A10_ONE_MASTER_RIG"/"T2_moss_antler"/"master.png").convert("RGBA"))
cfg=json.loads((final/"T2_moss_antler"/"rig_authority.json").read_text())
stats={}
for case in ("T1_forest_scout","T2_moss_antler"):
 target=final/case/"frames";before=old/case/"frames"
 changed=[]
 for p in sorted(target.glob("*.png")):
  if not p.name.startswith("attack_"):assert p.read_bytes()==(before/p.name).read_bytes()
  if p.read_bytes()!=(before/p.name).read_bytes():changed.append(p.name)
 for idx in range(8):
  A=np.asarray(Image.open(target/f"attack_{idx:02d}.png").convert("RGBA"))
  alpha=A[:,:,3]
  assert int(alpha[0].sum()+alpha[-1].sum()+alpha[:,0].sum()+alpha[:,-1].sum())==0
  assert int(alpha.max())==255 and int(alpha.min())==0
 stats[case]={"changed_attack_frames":changed,"other_actions_byte_identical":True,
     "source_master_sha256":hashlib.sha256((lab/"A10_ONE_MASTER_RIG"/case/"master.png").read_bytes()).hexdigest()}
# T1 check precisely four source-colored hilt pixels, 6 frames, matched originally.
report1=json.loads((out/"A15_R1_SOURCE_ART_QA.json").read_text())
assert len(report1["T1"]["removal_candidates"])==24
stats["T1_forest_scout"]["verified_hilt_source_replacements"]=24
stats["T1_forest_scout"]["rejected_effect"]="R2 broad cyan arc over face, not accepted"
# Verify immutable T2 head/antlers against original Master for all action frames.
head_counts=[]
for idx,frame in enumerate(cfg["semantic_frames"]):
 dx,dy=frame["root_offset"]
 actual=np.asarray(Image.open(final/"T2_moss_antler"/"frames"/f"attack_{idx:02d}.png").convert("RGBA"))
 checks=0;errors=0
 for y in range(0,43):
  for x in range(0,64):
   if m2[y,x,3]<200:continue
   Y=15+dy+y;X=16+dx+x
   if X<0 or Y<0 or X>=96 or Y>=96:continue
   checks+=1
   if not np.array_equal(actual[Y,X],m2[y,x]):errors+=1
 head_counts.append({"frame":idx,"source_head_pixels":checks,"mismatches":errors})
assert all(x["mismatches"]==0 for x in head_counts),head_counts
stats["T2_moss_antler"]["head_antler_source_match"]=head_counts
stats["T2_moss_antler"]["dust_frames"]=[4,5]
stats["T2_moss_antler"]["rejected"]=["R1 crude 4-pillar synthetic legs","R2 broad left belly duplication from rectangular patches","R2 dust at launch/recovery frames"]
(final/"A15_FINAL_VISUAL_SOURCE_QA.json").write_text(json.dumps(stats,ensure_ascii=False,indent=2))
print(json.dumps({"selection":"T1 R1 clean scabbard; T2 R1 source pixel legs + limited R2 contact dust","T1_modified":stats["T1_forest_scout"]["changed_attack_frames"],
"T2_modified":stats["T2_moss_antler"]["changed_attack_frames"],"T2_head_coverage":sum(x["source_head_pixels"] for x in head_counts),"head_mismatches":sum(x["mismatches"] for x in head_counts)},ensure_ascii=False))