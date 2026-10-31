from pathlib import Path
from PIL import Image
import shutil,json,hashlib
lab=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
src=lab/"A11_LAYERED_RIG";root=lab/"A13_KEYPOSE_RIG"
q={}
for case in ("T1_forest_scout","T2_moss_antler"):
 dst=root/case
 frames=dst/"frames"
 old=src/case/"frames"
 manifest=json.loads((src/case/"clips.json").read_text(encoding="utf8"))
 allfiles=[p.name for p in old.glob("*.png")]
 for p in old.glob("*.png"):
  target=frames/p.name
  if not target.exists():shutil.copy2(p,target)
  elif not p.name.startswith("attack_"):assert target.read_bytes()==p.read_bytes(),p
 assert len(list(frames.glob("*.png")))==len(allfiles)
 clip=manifest["clips"]["attack"]
 ref=json.loads((dst/"rig_authority.json").read_text(encoding="utf8"))
 k=ref["frames"] if case.startswith("T1") else ref["semantic_frames"]
 assert len(k)==8 and len(clip["frames"])==8
 clip["ticks"]=[int(r["ticks"]) for r in k]
 # The exact schema is validated by ASF strict compilation.
 (dst/"clips.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
 imgs=[Image.open(frames/f"attack_{i:02d}.png").convert("RGBA") for i in range(8)]
 counts=[int(sum(a>0 for a in im.getchannel("A").getdata())) for im in imgs]
 hashes=[hashlib.sha256(im.tobytes()).hexdigest() for im in imgs]
 touched=[]
 for i,im in enumerate(imgs):
  a=im.getchannel("A")
  w,h=im.size
  touched.append(sum(a.crop((0,0,w,1)).getdata())+sum(a.crop((0,h-1,w,h)).getdata())+sum(a.crop((0,0,1,h)).getdata())+sum(a.crop((w-1,0,w,h)).getdata()))
 assert all(counts) and max(touched)==0,(case,touched)
 assert len(set(hashes))>=7,(case,hashes)
 q[case]={"original_master_sha256":hashlib.sha256((lab/"A10_ONE_MASTER_RIG"/case/"master.png").read_bytes()).hexdigest(),
 "frame_count":len(allfiles),"attack_frames":8,"unique":len(set(hashes)),"edge_alpha_sum":sum(touched),
 "other_action_source":"A11 unchanged","ticks":clip["ticks"],"attack_source_hashes":hashes}
(root/"A13_PREBUILD_QA.json").write_text(json.dumps(q,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(q,ensure_ascii=False,indent=2)[:2400])