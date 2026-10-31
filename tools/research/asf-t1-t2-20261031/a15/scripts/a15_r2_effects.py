from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,hashlib,json,shutil,math
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A15_ART_REPAIR")
rev=root/"r2";rev.mkdir(exist_ok=False)
for case in ("T1_forest_scout","T2_moss_antler"):
 c=rev/case
 shutil.copytree(root/case/"frames",c/"frames")
 shutil.copy2(root/case/"clips.json",c/"clips.json")
 shutil.copy2(root/case/"rig_authority.json",c/"rig_authority.json")
# T1 sword arc deliberately placed to the left/front of subject, not over original face.
# no continuous blurry motion strokes; 1px palette-coherent accent, only impact and follow-through.
for idx in [4,5,6]:
 file=rev/"T1_forest_scout"/"frames"/f"attack_{idx:02d}.png"
 im=Image.open(file).convert("RGBA")
 under=Image.new("RGBA",im.size)
 dr=ImageDraw.Draw(under)
 if idx==4:
  dr.line([(44,42),(41,46),(38,51),(36,56)],fill=(138,193,219,220),width=1)
  dr.point((40,46),fill=(239,250,246,245))
 elif idx==5:
  dr.line([(36,49),(33,53),(30,59),(30,66),(33,72)],fill=(117,181,220,210),width=1)
  dr.line([(38,51),(35,56),(34,63)],fill=(226,249,246,225),width=1)
  dr.point((30,66),fill=(244,251,246,255))
 elif idx==6:
  dr.line([(32,73),(33,77),(37,81),(43,84)],fill=(122,186,218,170),width=1)
  dr.point((36,80),fill=(224,242,239,195))
 # accent on top of existing art in attack frames; keep hair/skin pixel source unchanged.
 im.alpha_composite(under)
 im.save(file)
# T2 little earth dust at actual front/ground contact, not obscuring limbs.
# Pattern drawn behind the sprite feet by compositing with original artwork OVER effect.
dirt=(159,124,76,255);light=(196,170,105,210);shadow=(102,81,56,255)
for idx,puffs in {
  3:[(28,79),(30,81)],
  4:[(29,78),(27,79),(26,76),(30,81),(31,83),(36,81)],
  5:[(24,78),(26,80),(30,83),(36,82)],
  6:[(28,79),(30,81)]
}.items():
 file=rev/"T2_moss_antler"/"frames"/f"attack_{idx:02d}.png"
 im=Image.open(file).convert("RGBA")
 fx=Image.new("RGBA",im.size);dr=ImageDraw.Draw(fx)
 for k,(x,y) in enumerate(puffs):
  dr.point((x,y),fill=light if k%3==0 else dirt)
  if k in (0,3):dr.point((x+1,y),fill=shadow)
 fx.alpha_composite(im) # source sprite over dust to avoid breaking hoof silhouettes
 fx.save(file)
# Validate 1x expected edits and unchanged identity outside attack.
results={}
for case in ("T1_forest_scout","T2_moss_antler"):
 src=root/case/"frames";target=rev/case/"frames"
 edited=[]
 for a in sorted(target.glob("*.png")):
  before=np.asarray(Image.open(src/a.name).convert("RGBA"))
  after=np.asarray(Image.open(a).convert("RGBA"))
  diff=int(np.any(before!=after,axis=2).sum())
  if not a.name.startswith("attack_"):
   assert diff==0,(case,a.name)
  if diff:edited.append({"file":a.name,"pixels":diff})
  alpha=after[:,:,3]
  assert alpha.max()==255 and alpha.min()==0
  assert alpha[0].sum()+alpha[-1].sum()+alpha[:,0].sum()+alpha[:,-1].sum()==0
 results[case]={"changed_frames":edited,"nonattack_unchanged":True}
assert len(results["T1_forest_scout"]["changed_frames"])==3
assert len(results["T2_moss_antler"]["changed_frames"])==4
(rev/"A15_R2_EFFECT_AUDIT.json").write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps(results,ensure_ascii=False))