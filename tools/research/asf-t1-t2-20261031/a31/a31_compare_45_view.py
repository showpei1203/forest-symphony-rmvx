"""Evaluate source-faithful PixelLab transfer first pass vs coherent SE45 edit-animation second pass.
Do NOT claim motion/angle PASS unless visual and native structural checks.
Keep originals and both provider raw batches unchanged.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,statistics
R=Path(r"E:\GameAssetToolLab_20261023\A31_FS_ORIGINAL_MOTION_TRANSFER_20261101")
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",15)
except:F=ImageFont.load_default()
def load(names):
 ims=[]
 for p in names:
  if not p.exists():raise FileNotFoundError(str(p))
  im=Image.open(p).convert("RGBA");assert im.size==(40,40)
  ims.append(im)
 return ims
a=load([R/f"A31_PROVIDER_TRANSFER_FRAME_{i:02}.png" for i in range(4)])
b=load([R/f"A31_SECOND_PASS_SE45_FRAME_{i:02}.png" for i in range(4)])
native=load([R/f"ORIGINAL_WALK_FRAME_{i:02}_C{c}.png" for i,c in enumerate([0,1,2,1])])
def diff(x,y):return sum(a!=b for a,b in zip(x.getdata(),y.getdata()))
def stat(arr):
 boxes=[im.getbbox() for im in arr];return {
  "boxes":boxes,
  "bottoms":[b[3] for b in boxes],
  "tops":[b[1] for b in boxes],
  "neutral_duplicate_delta":diff(arr[1],arr[3]),
  "adjacent_deltas":[diff(arr[i],arr[i+1]) for i in range(3)],
  "loop_closure_delta":diff(arr[-1],arr[0]),
  "first_and_third_pose_delta":diff(arr[0],arr[2])}
record={"stage":"A31","orig":stat(native),"outfit_only":stat(a),"se_edit":stat(b),
 "true_original_motion":"r2,c0-c1-c2-c1 (neutral repeated exactly)",
 "art_gate":"UNREVIEWED",
 "rotation_intent":"EAST to SOUTH-EAST 45 deg, visual inspection required"}
# For second pass no normalizing if any height drift without explicit log of translation.
def snap(arr):
 out=[];offset=[]
 for im in arr:
  box=im.getbbox()
  y=38-box[3]
  if abs(y)>3:raise RuntimeError(f"BAD GROUND DRIFT {box}, cannot correct invisibly")
  dest=Image.new("RGBA",(40,40));dest.alpha_composite(im,(0,y))
  assert sum(v[3]>0 for v in im.getdata())==sum(v[3]>0 for v in dest.getdata())
  out.append(dest);offset.append(y)
 return out,offset
s,shift=snap(b)
# Native has repeated neutral column c1. Force exact same image for the two identical phases.
s[3]=s[1].copy()
record["second_pass_cycle_translations_y"]=shift
record["second_pass_final_cycle"]=stat(s)
record["second_pass_final_footline_pass"]=len(set(im.getbbox()[3] for im in s))==1
sheet=Image.new("RGBA",(160,40))
for i,im in enumerate(s):sheet.alpha_composite(im,(i*40,0))
sheet.save(R/"A31_SE45_NATIVE_4FRAME_CYCLE_CANDIDATE.png")
s[0].save(R/"A31_SE45_NATIVE_MOTION_WALK_LOOP.gif",save_all=True,append_images=s[1:],
 duration=155,disposal=2,loop=0,optimize=False)
s[1].save(R/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png")
# side-by-side 4-poses all versions
page=Image.new("RGB",(1240,850),(235,238,243));d=ImageDraw.Draw(page)
sources=[("FS ORIGINAL NATIVE MOTION",native),("OUTFIT TRANSFER FROM APPROVED LOOK",a),("SECOND PASS SOUTH-EAST DIRECTION",s)]
for row,(label,frames) in enumerate(sources):
 y=10+row*275
 d.text((13,y),label,fill=(20,29,44),font=F)
 for i,im in enumerate(frames):
  bg=Image.new("RGBA",(40,40),(235,238,243,255));bg.alpha_composite(im)
  page.paste(bg.convert("RGB").resize((250,250),Image.Resampling.NEAREST),(15+i*305,y+23))
page.save(R/"A31_THREE_WALK_METHODS_NATIVE_VS_OUTFIT_VS_45.png")
# Native static idle vs resulting static
idle=Image.new("RGB",(780,300),(235,238,243));d=ImageDraw.Draw(idle)
for i,(name,im) in enumerate([("ORIGINAL STATIC",native[1]),("OUTFIT TRANSFER STATIC",a[1]),("SE45 STATIC",s[1])]):
 bg=Image.new("RGBA",(40,40),(235,238,243,255));bg.alpha_composite(im)
 idle.paste(bg.convert("RGB").resize((240,240),Image.Resampling.NEAREST),(i*260+7,25))
 d.text((i*260+5,8),name,fill=(20,34,51),font=F)
idle.save(R/"A31_TRUE_IDLE_STATIC_THREE_WAYS.png")
# Real animated preview: original vs A30 wrong vs A31 candidate
frames=[]
for i in range(4):
 scene=Image.new("RGB",(1040,365),(236,240,244));dd=ImageDraw.Draw(scene)
 dd.text((8,5),"A31 | Original native steps -> unarmed SE45 candidate",font=F,fill=(24,36,50))
 for col,(label,im) in enumerate([("ORIGINAL",native[i]),("OUTFIT TRANSFER",a[i]),("SE45 VIEW",s[i])]):
  bg=Image.new("RGBA",(40,40),(236,240,244,255));bg.alpha_composite(im)
  scene.paste(bg.convert("RGB").resize((310,310),Image.Resampling.NEAREST),(col*343+12,30))
  dd.text((col*343+20,346),label,font=F,fill=(30,40,54))
 frames.append(scene)
frames[0].save(R/"A31_NATIVE_ORIGINAL_VS_GENERATED_WALK.gif",
 save_all=True,append_images=frames[1:],duration=155,loop=0,optimize=True)
(R/"A31_SE45_SECOND_PASS_QA.json").write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"orig":record["orig"],"outfit":record["outfit_only"],"southeast":record["se_edit"],"final":record["second_pass_final_cycle"],"align_y":shift},ensure_ascii=False))
