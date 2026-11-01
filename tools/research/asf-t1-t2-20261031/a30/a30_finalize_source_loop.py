"""A30 final loop cut based on original Forest Symphony r2: preserve all real provider frames.
Idle select [0,1,2,3], Walk [0,1,2,3,4]; remove repeated terminal holds only.
No hand editing sprite pixels. A29 and original game untouched.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,zipfile,statistics
R=Path(r"E:\GameAssetToolLab_20261023\A30_FS_SOURCE_MOTION_RIG_LOOP_20261101")
A29=Path(r"E:\GameAssetToolLab_20261023\A29_FS45_UNARMED_PIXELLAB_LOOP_20261101")
D=json.loads((R/"A30_RAW_LOOP_QA.json").read_text(encoding="utf8"))
sel={"IDLE":[0,1,2,3],"WALK":[0,1,2,3,4]}
def pixel_diff(a,b):
 return sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for name,ids in sel.items():
 frames=[Image.open(R/("A30_"+name+"_SKELETON")/f"RAW_FRAME_{i:02}.png").convert("RGBA") for i in ids]
 step=[pixel_diff(frames[i],frames[i+1]) for i in range(len(frames)-1)]
 seam=pixel_diff(frames[-1],frames[0])
 assert max(f.getbbox()[3] for f in frames)==min(f.getbbox()[3] for f in frames)==38
 assert max(f.getbbox()[1] for f in frames)==min(f.getbbox()[1] for f in frames)==4
 assert seam<=2
 sheet=Image.new("RGBA",(40*len(frames),40))
 for i,f in enumerate(frames):sheet.alpha_composite(f,(40*i,0))
 sheet.save(R/f"A30_{name}_SOURCE_RIG_FINAL_SHEET_40.png")
 # Scale only nearest to present human-visible genuine pixel art. Source RGBA is the real editable art.
 durations=([240,150,150,240] if name=="IDLE" else [150]*5)
 frames[0].save(R/f"A30_{name}_SOURCE_RIG_FINAL_LOOP.gif",save_all=True,
   append_images=frames[1:],duration=durations,loop=0,disposal=2,optimize=False)
 D["final_"+name]={"source_indices":ids,"frame_count":len(ids),"durations_ms":durations,
  "adjacent_diffs":step,"loop_seam_diff":seam,"last_first_ratio":round(seam/max(1,statistics.median(step)),3),
  "floor_bottoms":[x.getbbox()[3] for x in frames],"head_tops":[x.getbbox()[1] for x in frames],
  "status":"TECHNICALLY STABLE, user art gate pending, 45-degree angle still provisional",
  "sheet_sha256":sha(R/f"A30_{name}_SOURCE_RIG_FINAL_SHEET_40.png")}
# synchronized four keyframe cross action contact compare by using actual 4 vs 5 frame loops
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",17)
except:F=ImageFont.load_default()
panels=[]
for i in range(20):
 page=Image.new("RGB",(710,360),(237,240,244))
 d=ImageDraw.Draw(page)
 d.text((15,9),"A30 | Source-guided 1:1 chibi | Empty fists | Fixed foot baseline",font=F,fill=(21,32,45))
 for row,act in enumerate(["IDLE","WALK"]):
  im=Image.open(R/f"A30_{act}_SOURCE_RIG_FINAL_SHEET_40.png").convert("RGBA")
  n=sel[act];index=i%len(n);frame=im.crop((index*40,0,(index+1)*40,40))
  y=38+row*155
  bg=Image.new("RGBA",(40,40),(237,240,244,255));bg.alpha_composite(frame)
  page.paste(bg.convert("RGB").resize((146,146),Image.Resampling.NEAREST),(130,y))
  d.text((15,y+64),act,font=F,fill=(25,38,55))
  d.text((350,y+54),f"Frame {index+1}/{len(n)} | floor Y = 38",font=F,fill=(42,55,72))
 panels.append(page)
panels[0].save(R/"A30_FINAL_IDLE_WALK_COMBINED_LOOP.gif",save_all=True,
 append_images=panels[1:],duration=155,loop=0,optimize=True)
# Source v A29 v A30 contact (actual sources, NN only)
page=Image.new("RGB",(4*205,2*255),(239,241,244));d=ImageDraw.Draw(page)
for row,name in enumerate(("IDLE","WALK")):
 d.text((8,row*255+8),name+" / A29 prior, A30 source rig selected",font=F,fill=(24,37,55))
 old=[Image.open(A29/name/f"PROVIDER_FRAME_{j:02}.png").convert("RGBA") for j in range(5)]
 new=[Image.open(R/f"A30_{name}_SOURCE_RIG_FINAL_SHEET_40.png").crop((j*40,0,(j+1)*40,40)) for j in range(len(sel[name]))]
 for col,(title,fr) in enumerate([("A29 F0",old[0]),("A29 F2",old[2]),("A30 F0",new[0]),("A30 F2",new[min(2,len(new)-1)])]):
  base=Image.new("RGBA",(40,40),(239,241,244,255));base.alpha_composite(fr)
  page.paste(base.convert("RGB").resize((186,186),Image.Resampling.NEAREST),(col*205+8,row*255+32))
  d.text((col*205+14,row*255+220),title,font=F,fill=(45,61,79))
page.save(R/"A30_A29_COMPARISON_8FRAMES.png",optimize=True)
(R/"A30_RAW_LOOP_QA.json").write_text(json.dumps(D,ensure_ascii=False,indent=2),encoding="utf8")
for name in ("IDLE","WALK"):print(name,"FINAL",D["final_"+name],flush=True)
print("PREVIEWS",[(f.name,f.stat().st_size) for f in [R/"A30_FINAL_IDLE_WALK_COMBINED_LOOP.gif",R/"A30_A29_COMPARISON_8FRAMES.png"]])
