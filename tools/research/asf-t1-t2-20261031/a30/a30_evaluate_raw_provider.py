"""A30 inspect genuine PixelLab rig animation against native actor01 source and A29 artifacts.
No new drawing or inferred frames. RAW exports always preserved.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,statistics,hashlib,zipfile
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A30_FS_SOURCE_MOTION_RIG_LOOP_20261101"
A29=BASE/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"
source=Image.open(A29/"A29_SELECTED_SE_VISUAL_45_UNARMED_40.png").convert("RGBA")
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def alpha_info(im):
 im=im.convert("RGBA");bbox=im.getbbox();a=im.getchannel("A")
 def occupancy(y0,y1):
  pts=[(x,y) for y in range(y0,y1) for x in range(40) if a.getpixel((x,y))>0]
  return {"count":len(pts),"x_center":round(sum(x for x,y in pts)/len(pts),2) if pts else None,
  "y_center":round(sum(y for x,y in pts)/len(pts),2) if pts else None}
 return {"bbox":bbox,"head":occupancy(3,19),"torso":occupancy(19,29),
 "feet":occupancy(29,40),"foot_contact_36_39":sum(a.getpixel((x,y))>0 for x in range(40) for y in range(36,40)),
 "bottom_edge_alpha":sum(a.getpixel((x,39))>0 for x in range(40))}
def pixelchange(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def contact_key(items):
 n=[v["bbox"][3] for v in items]
 return {"values":n,"range":max(n)-min(n)}
report={"stage":"A30","source_locked":{"FS_actor01_r2_3poses":"source C0/C1/C2; head tops 1/0/1; feet bottom32/32/32",
 "unarmed A29 image SHA":sha(A29/"A29_SELECTED_SE_VISUAL_45_UNARMED_40.png")},
"raw":{},"old_a29":{}}
for act in ("IDLE","WALK"):
 files=sorted((R/("A30_"+act+"_SKELETON")).glob("RAW_FRAME_*.png"))
 if len(files)<6:
  print("WAITING",act,len(files));raise SystemExit(3)
 frames=[Image.open(p).convert('RGBA') for p in files]
 metrics=[alpha_info(f) for f in frames]
 diffs=[pixelchange(frames[i],frames[i+1]) for i in range(len(frames)-1)]
 seam=pixelchange(frames[-1],frames[0])
 old=json.loads((A29/act/"SUBMISSION_LOCK.json").read_text(encoding="utf8"))["metrics"]
 evals={"frame_count":len(frames),"first_frame_exact":frames[0].tobytes()==source.tobytes(),
  "metrics":metrics,"adjacent_pixel_diffs":diffs,"seam_pixel_diff":seam,
  "loop_ratio":round(seam/max(1,statistics.median(diffs)),3),
  "head_top_range":max(m["bbox"][1] for m in metrics)-min(m["bbox"][1] for m in metrics),
  "floor_bottom_range":contact_key(metrics),
  "edge_clip_any":any(m["bottom_edge_alpha"] for m in metrics)}
 evals["vertical_idle_gate"]="PASS" if act=="IDLE" and evals["floor_bottom_range"]["range"]==0 and evals["head_top_range"]<=1 else "FAIL" if act=="IDLE" else None
 evals["no_clipping_gate"]="PASS" if not evals["edge_clip_any"] else "FAIL"
 evals["seam_gate"]="PASS" if evals["loop_ratio"]<=2 else "FAIL"
 report["raw"][act]=evals
 report["old_a29"][act]={"old_bbox":old["bboxes"],"old_floors":[x[3] for x in old["bboxes"]],
 "old_floor_range":max(x[3] for x in old["bboxes"])-min(x[3] for x in old["bboxes"]),
 "old_pair_diffs":old["pair_diffs"],"old_seam":old["last_to_first_diff"]}
 # save true provider GIF, no edits
 frames[0].save(R/f"A30_{act}_PIXELLAB_RAW_LOOP.gif",save_all=True,append_images=frames[1:],
     duration=145,loop=0,disposal=2,optimize=False)
 sheet=Image.new("RGBA",(40*len(frames),40))
 for i,im in enumerate(frames):sheet.alpha_composite(im,(i*40,0))
 sheet.save(R/f"A30_{act}_REAL_6FRAME_SHEET.png")
# two-row raw contact
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",17)
except:font=ImageFont.load_default()
review=Image.new('RGB',(1080,440),(235,239,242));d=ImageDraw.Draw(review)
for k,act in enumerate(("IDLE","WALK")):
 y=20+k*210;d.text((10,y+70),act,font=font,fill=(20,30,44))
 for i in range(6):
  fr=Image.open(R/("A30_"+act+"_SKELETON")/f"RAW_FRAME_{i:02}.png").convert('RGBA')
  bg=Image.new("RGBA",(40,40),(235,239,242,255));bg.alpha_composite(fr)
  review.paste(bg.convert("RGB").resize((148,148),Image.Resampling.NEAREST),(140+i*153,y))
  d.text((200+i*153,y+153),"F"+str(i),font=font,fill=(46,62,75))
review.save(R/"A30_TRUE_SKELETON_PIXELLAB_12FRAMES.png")
# A29 versus A30 side by side animated exact frames, old 5 frames, new 6 frames
oldframes={act:[Image.open(p).convert("RGBA") for p in sorted((A29/act).glob("PROVIDER_FRAME_*.png"))] for act in ("IDLE","WALK")}
newframes={act:[Image.open(p).convert("RGBA") for p in sorted((R/("A30_"+act+"_SKELETON")).glob("RAW_FRAME_*.png"))] for act in ("IDLE","WALK")}
panels=[]
for i in range(30):
 page=Image.new("RGB",(740,370),(236,239,243));d=ImageDraw.Draw(page)
 d.text((10,5),"Actual PixelLab A29 old vs A30 native-bone rig (both RAW)",font=font,fill=(15,31,48))
 for j,act in enumerate(("IDLE","WALK")):
  y=30+165*j
  d.text((10,y+57),act,font=font,fill=(25,43,60))
  for k,(title,fr) in enumerate([("A29",oldframes[act][i%5]),("A30",newframes[act][i%6])]):
   bg=Image.new("RGBA",(40,40),(236,239,243,255));bg.alpha_composite(fr)
   page.paste(bg.convert("RGB").resize((152,152),Image.Resampling.NEAREST),(125+280*k,y))
   d.text((280+280*k,y+54),title,font=font,fill=(27,46,65))
 panels.append(page)
panels[0].save(R/"A30_A29_VS_A30_RAW_LOOP_COMPARE.gif",save_all=True,append_images=panels[1:],
 duration=145,loop=0,optimize=True)
(R/"A30_RAW_LOOP_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("QA",json.dumps({k:{"floor":v["floor_bottom_range"],"head_top":v["head_top_range"],"seam":v["loop_ratio"],"vertical_idle":v["vertical_idle_gate"]} for k,v in report["raw"].items()},ensure_ascii=False))
for nm in ["A30_TRUE_SKELETON_PIXELLAB_12FRAMES.png","A30_A29_VS_A30_RAW_LOOP_COMPARE.gif"]:
 print("EXPORTED",nm,(R/nm).stat().st_size)
