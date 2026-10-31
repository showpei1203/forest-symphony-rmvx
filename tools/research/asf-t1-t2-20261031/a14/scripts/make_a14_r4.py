from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,shutil,hashlib
lab=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
a13=lab/"A13_KEYPOSE_RIG"
a14=lab/"A14_OCCLUSION_RIG"
qa={}
for case in ("T1_forest_scout","T2_moss_antler"):
  dest=a14/case
  src=a13/case
  assert not dest.exists(),f"FAIL_CLOSED existing {dest}"
  dest.mkdir()
  shutil.copytree(src/"frames",dest/"frames")
  shutil.copy2(src/"clips.json",dest/"clips.json")
  shutil.copy2(src/"rig_authority.json",dest/"rig_authority.json")
  qa[case]={"baseline":"A13_R3","copied_frames":len(list((dest/"frames").glob("*.png")))}
# T1 R4: restrict scabbard correction to source-matching pixels at the waist
master=Image.open(lab/"A10_ONE_MASTER_RIG"/"T1_forest_scout"/"master.png").convert("RGBA")
t1=a14/"T1_forest_scout"
body_shifts=[0,-1,-1,0,1,1,0,0]
per_frame=[]
for idx in range(8):
  p=t1/"frames"/f"attack_{idx:02d}.png"
  frame=Image.open(p).convert("RGBA")
  changed=[]
  if idx>=2:
    # A10 sheathed hilt's protruding pixels on right hip.
    for sy in range(60,67):
      for sx in range(49,55):
        tx=16+sx+body_shifts[idx]; ty=16+sy
        source=master.getpixel((sx,sy))
        if frame.getpixel((tx,ty)) != source or source[3]==0:
          continue # never erase independently animated blade or hand
        # Choose actual A10 cloak/leather source colours, no blurred approximations
        alt=master.getpixel((max(42,sx-5),sy))
        if alt[3]==0:
          alt=master.getpixel((max(39,sx-9),max(55,sy-2)))
        if alt[3]>0 and alt!=source:
          frame.putpixel((tx,ty),alt);changed.append((tx,ty))
    # add narrow dark empty sheath rim only when the original painted handle is removed
    # Leave it out if there is no unambiguously empty sheath mask.
  if changed:frame.save(p)
  per_frame.append({"frame":idx,"replaced_original_scabbard_pixels":len(changed),"coords":changed})
qa["T1_forest_scout"]["scabbard_source_matched_replaced"]=per_frame
# T2 R4: true source Master on keyposes 0 and 7 instead of grafted legs, conserves source identity and removes rest seams.
t2=a14/"T2_moss_antler"
m=Image.open(lab/"A10_ONE_MASTER_RIG"/"T2_moss_antler"/"master.png").convert("RGBA")
for idx in (0,7):
  canvas=Image.new("RGBA",(96,96));canvas.alpha_composite(m,(16,15))
  canvas.save(t2/"frames"/f"attack_{idx:02d}.png")
qa["T2_moss_antler"]["rest_poses_exactly_single_master"]=True
# Compare all files for clipping, local identity, non-attack untouched; preserve A13 other actions byte-identically.
for case in qa:
  current=a14/case/"frames"
  old=a13/case/"frames"
  items=sorted(current.glob("*.png"))
  other=[p for p in items if not p.name.startswith("attack_")]
  assert all((old/p.name).read_bytes()==p.read_bytes() for p in other)
  frames=[Image.open(current/f"attack_{i:02d}.png").convert("RGBA") for i in range(8)]
  assert len({hashlib.sha256(im.tobytes()).hexdigest() for im in frames}) >= 7
  for im in frames:
    assert im.getbbox() is not None
    arr=np.array(im.getchannel("A"))
    assert (arr[0].sum()+arr[-1].sum()+arr[:,0].sum()+arr[:,-1].sum())==0
  qa[case]["nonattack_source_byte_identical"]=True
  qa[case]["unique_attack_frames"]=len({hashlib.sha256(im.tobytes()).hexdigest() for im in frames})
(a14/"A14_R4_PREBUILD_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"T1_replacements":[x["replaced_original_scabbard_pixels"] for x in per_frame],
"T2_rest_exact":True,
"attack_unique":[qa[c]["unique_attack_frames"] for c in qa]},ensure_ascii=False))