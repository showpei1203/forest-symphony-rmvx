from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,statistics
R=Path(r"E:\GameAssetToolLab_20261023\A32_FS_BATTLE45_NATIVE_REFERENCES_20261101")
T=R/"ACTION_09_DODGE_PIXEL_LAB_TEST"
frames=[Image.open(T/f"PIXELLAB_DODGE_FRAME_{i:02}.png").convert("RGBA") for i in range(5)]
F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
p=Image.new("RGB",(1020,250),(240,243,247));d=ImageDraw.Draw(p)
d.text((16,5),"A32 PixelLab DODGING | 5 real provider frames | not yet ART PASS",font=F,fill=(20,33,49))
for i,im in enumerate(frames):
 bg=Image.new("RGBA",(40,40),(240,243,247,255));bg.alpha_composite(im)
 p.paste(bg.convert("RGB").resize((192,192),Image.Resampling.NEAREST),(10+i*202,28))
 d.text((76+i*202,224),"F"+str(i),font=F,fill=(31,43,56))
p.save(T/"A32_PIXELLAB_DODGING_5F_6X_PREVIEW.png")
def diff(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def cent(im,box):
 pts=[(x,y) for y in range(box[1],box[3]) for x in range(box[0],box[2]) if im.getpixel((x,y))[3]]
 return [round(sum(x for x,y in pts)/len(pts),2),round(sum(y for x,y in pts)/len(pts),2)] if pts else None
stats={"frame_count":5,"frames_px":[40,40],"bboxes":[f.getbbox() for f in frames],
 "body_alpha_centroids":[cent(f,f.getbbox()) for f in frames],
 "head_top_y":[f.getbbox()[1] for f in frames],
 "foot_bottom_y":[f.getbbox()[3] for f in frames],
 "consecutive_pixel_diff":[diff(frames[i],frames[i+1]) for i in range(4)],
 "source_frame0_exact":True,
 "source_image_to_provider":"A31 unarmed 40x40; three screenshot poses translated to semantics, screenshot pixels NOT supplied directly to provider",
 "semantic_gate":"FAIL/NOT_PROVEN: visible mass shifts only subtly and no clear crouch+side evade+recover; screen-right face remains angle candidate",
 "user_approval":"PENDING",
 "SBS_paper_doll":"NOT TESTED",
 "loop_policy":"ONE SHOT; GIF demo should stop/hold last frame, not loop indefinitely"}
(T/"A32_DODGE_TRIAL_QA.json").write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(stats,ensure_ascii=False,indent=2))
