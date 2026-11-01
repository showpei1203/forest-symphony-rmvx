"""A33 compare baseline A, direct B, corrected C, and user reference exact 3 screenshot poses.
Outputs only real provider images; no invented poses.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,zipfile,hashlib
ROOT=Path(r"E:\GameAssetToolLab_20261023\A33_HUMANOID_DIRECT_POSE_20261101")
B=ROOT/"B_DODGING_DIRECT_POSES";C=ROOT/"C_DODGE_45_CORRECTION"
paths=[[B/f"DODGE_POSE_FROM_USER_{i}.png" for i in range(3)],
[B/f"PIXELLAB_B_DODGE_FRAME_{i:02}.png" for i in range(3)],
[C/f"PIXELLAB_C_FRAME_{i:02}.png" for i in range(3)]]
if not all(f.exists() for group in paths for f in group):print("NOT_READY");raise SystemExit(3)
groups=[[Image.open(f).convert('RGBA') for f in row] for row in paths]
F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",17)
p=Image.new('RGB',(1008,1008),(239,242,245));d=ImageDraw.Draw(p)
labels=["USER POSES (real source pixels)","B PIXELLAB real outfit transfer","C PIXELLAB 45-degree edit"]
for j,(name,frames) in enumerate(zip(labels,groups)):
 y=j*336;d.rectangle((0,y,1007,y+32),fill=(31,45,60));d.text((12,y+6),name,font=F,fill=(251,251,252))
 for i,im in enumerate(frames):
  bg=Image.new("RGBA",(40,40),(239,242,245,255));bg.alpha_composite(im)
  p.paste(bg.convert("RGB").resize((306,306),Image.Resampling.NEAREST),(i*336+13,y+32))
  d.text((i*336+180,y+310),"F"+str(i),fill=(37,51,63),font=F)
p.save(ROOT/"A33_POSE_SOURCE_B_VS_C_LARGE.png",optimize=True)
def metrics(frames):
 out=[]
 for im in frames:
  bb=im.getbbox()
  a=im.getchannel('A')
  pts=[(x,y) for y in range(40) for x in range(40) if a.getpixel((x,y))>0]
  out.append({"bbox":bb,"center":[round(sum(x for x,y in pts)/len(pts),2),
    round(sum(y for x,y in pts)/len(pts),2)],"n_alpha":len(pts),
    "low_center":round(sum(x for x,y in pts if y>=23)/max(1,sum(y>=23 for x,y in pts)),2),
    "bottom_edge":sum(a.getpixel((x,39))>0 for x in range(40))})
 return out
qa={"source":metrics(groups[0]),"B":metrics(groups[1]),"C":metrics(groups[2]),
"source_real":"from user screenshot indexed palette 32x32 exact RGB/alpha, padded x4/y6",
"one_shot":"three distinct positions, not a seamless GIF",
"status":"CANDIDATE_USER_ART_REVIEW",
"angle_45":"needs visual review","no_weapons":"needs visual review",
"original_role_both":"FS A26-approved 1:1 appearance; A31 source, no sealed files touched"}
(ROOT/"A33_BC_COMPARISON_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf8')
for name,frames in [('B',groups[1]),('C',groups[2])]:
 frames[0].save(ROOT/f"A33_{name}_DODGE_PROPOSED_ACTION.gif",save_all=True,append_images=frames[1:],
 duration=[180,310,450],loop=1,disposal=2,optimize=False)
print(json.dumps(qa,ensure_ascii=False,indent=2),flush=True)
print("PREVIEW", (ROOT/"A33_POSE_SOURCE_B_VS_C_LARGE.png").stat().st_size)
