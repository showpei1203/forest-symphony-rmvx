"""A33 Waiting static baseline + cross-action QA and pack audit, no fabricated art."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,zipfile,shutil
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A33_HUMANOID_DIRECT_POSE_20261101"
WAIT=R/"A33_WAITING_STATIC_BASELINE";WAIT.mkdir(exist_ok=True)
A31=BASE/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png"
f=WAIT/"FS_WAITING_NATIVE_40.png"
assert A31.exists();shutil.copy2(A31,f)
im=Image.open(f).convert("RGBA");assert im.size==(40,40)
# Real FS idle is a one-frame static neutral pose. A waiting loop means holding it, not
# 3 frames of repeated sprite copies/shoulder-only jitter.
(WAIT/"WAITING_QA.json").write_text(json.dumps({"stage":"A33-R1-Waiting",
"source":str(A31),"source_sha256":hashlib.sha256(f.read_bytes()).hexdigest(),
"original_Forest_Symphony_Idle_policy":"single unchanging center pose c1, no shoulder jitter",
"reference_poses":"Waiting row04 three reference frames are guidance only; FS original remains a static idle",
"pixelLab_charge":0,"technical_status":"STATIC_BASELINE_COMPLETE",
"visual_45_angle":"PENDING_USER_REVIEW","SBS_layer":"NOT_TESTED"},ensure_ascii=False,indent=2),encoding="utf8")
# Prebuild separate B Damage 3 user reference poses as soon as transferred files exist.
D=R/"B_DAMAGE_DIRECT_POSES"
if D.exists():
 fp=sorted(D.glob("PIXELLAB_B_DAMAGE_FRAME_*.png"))
 if len(fp)==3:
  src=[Image.open(D/f"DAMAGE_POSE_FROM_USER_{i}.png").convert("RGBA") for i in range(3)]
  dst=[Image.open(x).convert("RGBA") for x in fp]
  F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
  pic=Image.new("RGB",(990,668),(239,242,246));d=ImageDraw.Draw(pic)
  for row,(lbl,ims) in enumerate([("USER SOURCE: THREE DAMAGE POSES",src),("PIXELLAB DIRECT OUTFIT: THREE REAL FRAMES",dst)]):
   yy=row*334
   d.rectangle((0,yy,989,yy+32),fill=(28,42,57));d.text((12,yy+5),lbl,font=F,fill=(250,250,251))
   for j,item in enumerate(ims):
    bg=Image.new("RGBA",(40,40),(239,242,246,255));bg.alpha_composite(item)
    pic.paste(bg.convert('RGB').resize((296,296),Image.Resampling.NEAREST),(j*330+15,yy+33))
  out=R/"A33_B_DAMAGE_USER_POSES_VS_PIXEL_LAB.png";pic.save(out,optimize=True)
  report={"source_bboxes":[f.getbbox() for f in src],"provider_bboxes":[f.getbbox() for f in dst],
   "art_status":"PENDING_USER; inspect recoil/pose clarity","weapon_layer":"not integrated","one_shot":True}
  (R/"A33_R1_B_DAMAGE_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
  print("DAMAGE_PREVIEW",out.stat().st_size)
print("WAITING_STATIC_FREE_PASS",im.getbbox())
