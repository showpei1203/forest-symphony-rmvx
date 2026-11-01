"""A33 pose-direct B QA: provider 3 actual frames vs user 3 actual reference poses.
No generated repairs or silent clipping; no automatic new paid job.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,statistics,zipfile
ROOT=Path(r"E:\GameAssetToolLab_20261023\A33_HUMANOID_DIRECT_POSE_20261101")
P=ROOT/"B_DODGING_DIRECT_POSES"
source=[Image.open(P/f"DODGE_POSE_FROM_USER_{i}.png").convert("RGBA") for i in range(3)]
files=[P/f"PIXELLAB_B_DODGE_FRAME_{i:02}.png" for i in range(3)]
if not all(p.exists() for p in files):print("OUTPUT_NOT_READY");raise SystemExit(3)
generated=[Image.open(f).convert("RGBA") for f in files]
def opaque_points(im):return [(x,y) for y in range(40) for x in range(40) if im.getpixel((x,y))[3]>0]
def stat(im):
 pts=opaque_points(im);bb=im.getbbox()
 return dict(bbox=bb,center=[round(sum(x for x,y in pts)/len(pts),2),round(sum(y for x,y in pts)/len(pts),2)],
 alpha_pixels=len(pts),head_region_pixels=sum(y<22 for x,y in pts),foot_bottom=bb[3] if bb else None,
 right_edge=sum(im.getpixel((39,y))[3]>0 for y in range(40)),
 bottom_edge=sum(im.getpixel((x,39))[3]>0 for x in range(40)))
old_ref=[stat(x) for x in source];new=[stat(x) for x in generated]
diff=lambda a,b:sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
report={"stage":"A33_R1_B_DODGING","status":"TECHNICAL_RETURNED_ART_PENDING",
 "source_user_poses":old_ref,"pixelLab_outfit_transfer":new,
 "raw_delta":[diff(generated[i],generated[i+1]) for i in range(2)],
 "source_delta":[diff(source[i],source[i+1]) for i in range(2)],
 "center_motion":{"source":[x["center"] for x in old_ref],"provider":[x["center"] for x in new]},
 "no_40px_cutoff":not any(x['right_edge'] or x['bottom_edge'] for x in new),
 "one_shot_not_seamless_loop":True,
 "user_art_approval":"PENDING",
 "view_angle_gate":"PENDING, non-front and 3/4 right facing must be inspected",
 "no_weapons_gate":"VISUAL_PEND",
 "SBS_overlay":"NOT_TESTED"}
(ROOT/"A33_R1_B_DODGE_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",19)
except:font=ImageFont.load_default()
out=Image.new("RGB",(1020,680),(235,239,243))
d=ImageDraw.Draw(out)
for row,(label,ims) in enumerate([("USER'S THREE ACTUAL POSE PIXELS",source),("REAL PIXELLAB OUTFIT TRANSFER",generated)]):
 yy=row*340
 d.rectangle((0,yy,1019,yy+32),fill=(29,42,57))
 d.text((18,7+yy),label,font=font,fill=(249,249,250))
 for i,im in enumerate(ims):
  bb=Image.new("RGBA",(40,40),(235,239,243,255));bb.alpha_composite(im)
  out.paste(bb.convert("RGB").resize((292,292),Image.Resampling.NEAREST),(i*339+21,yy+38))
  d.text((i*339+32,yy+317),"POSE "+str(i),font=font,fill=(38,48,63))
out.save(ROOT/"A33_B_DODGE_USER_POSE_VS_REAL_PIXELLAB.png",optimize=True)
print(json.dumps(report,ensure_ascii=False),flush=True)
print("CONTACT_SIZE",(ROOT/"A33_B_DODGE_USER_POSE_VS_REAL_PIXELLAB.png").stat().st_size)
