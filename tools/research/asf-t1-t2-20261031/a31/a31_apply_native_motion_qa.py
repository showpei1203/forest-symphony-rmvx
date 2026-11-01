"""A31 compare actual source-frame-based outfit transfer with original FS steps and A30 fail.
NO pixel repaint: normalized candidate only reuses genuine provider frames and repeats exact neutral pose.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,zipfile,statistics
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"
A30=B/"A30_FS_SOURCE_MOTION_RIG_LOOP_20261101"
files=sorted(R.glob("A31_PROVIDER_TRANSFER_FRAME_*.png"))
if len(files)!=4:
 print("NOT_READY",len(files));raise SystemExit(3)
def getframes(paths):return [Image.open(p).convert('RGBA') for p in paths]
orig=getframes([R/f"ORIGINAL_WALK_FRAME_{i:02}_C{c}.png" for i,c in enumerate([0,1,2,1])])
raw=getframes(files)
assert all(f.size==(40,40) for f in raw)
def changed(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def metrics(fs):
 return [{"bbox":f.getbbox(),"alpha_px":sum(v[3]>0 for v in f.getdata()),
          "foot_contact_36_38":sum(f.getpixel((x,y))[3]>0 for y in range(36,39) for x in range(40))} for f in fs]
def level_y(m):return [v["bbox"][3] if v["bbox"] else None for v in m]
mm=metrics(raw);target_foot=38
# Handle only pixel-position adjustment (not deformation) if provider moves entire character vertically.
corrected=[];shifts=[]
for im in raw:
 box=im.getbbox()
 if box is None:raise ValueError("EMPTY_PROVIDER_FRAME")
 dy=target_foot-box[3]
 if abs(dy)>3:raise ValueError("excessive frame drift, cannot normalize safely")
 output=Image.new("RGBA",(40,40))
 output.alpha_composite(im,(0,dy))
 if output.getbbox() and output.getbbox()[1]<0:raise ValueError("top crop")
 assert sum(v[3]>0 for v in output.getdata())==sum(v[3]>0 for v in im.getdata()),"PIXEL CLIPPED"
 corrected.append(output);shifts.append([0,dy])
# Same original source center c1 repeated exactly in original, AI could make last neutral differ.
# Enforce same pixel-exact idle frame, not fabricate movement or redraw.
cycle=[corrected[0],corrected[1],corrected[2],corrected[1]]
idl=corrected[1]
p=R/"A31_ORIGINAL_POSE_RESTYLE_STATIC_IDLE.png";idl.save(p)
strip=Image.new("RGBA",(160,40))
for i,f in enumerate(cycle):strip.alpha_composite(f,(40*i,0))
strip.save(R/"A31_FS_OUTFIT_TRANSFER_NATIVE_4_FRAME_LOOP.png")
cycle[0].save(R/"A31_FS_OUTFIT_TRANSFER_REAL_SOURCE_WALK.gif",save_all=True,append_images=cycle[1:],duration=160,disposal=2,loop=0,optimize=False)
# Idle actual from the exact center reference frame: static preview, not artificial shoulder wiggle
base=Image.new("RGBA",(40,40),(232,236,241,255));base.alpha_composite(idl)
base.convert("RGB").resize((240,240),Image.Resampling.NEAREST).save(R/"A31_REAL_SOURCE_STATIC_IDLE_6X.png")
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",15)
except:F=ImageFont.load_default()
panels=[]
for idx in range(4):
 page=Image.new("RGB",(1150,400),(236,239,243));d=ImageDraw.Draw(page)
 d.text((15,8),"FS TRUE $actor01 MOTION | RAW SOURCE vs PIXELLAB OUTFIT TRANSFER | unarmed candidate",font=F,fill=(16,30,43))
 for j,(title,im) in enumerate([("NATIVE ORIGINAL",orig[idx]),("TRANSFER RAW",raw[idx]),("ALIGNED CANDIDATE",cycle[idx])]):
  bg=Image.new("RGBA",im.size,(236,239,243,255));bg.alpha_composite(im)
  page.paste(bg.convert("RGB").resize((330,330),Image.Resampling.NEAREST),(j*385+12,35))
  d.text((j*385+30,375),title+f" F{idx}",font=F,fill=(33,47,58))
 panels.append(page)
panels[0].save(R/"A31_REAL_SOURCE_VS_PIXEL_LAB_OUTFIT_LOOP.gif",save_all=True,append_images=panels[1:],
 duration=160,loop=0,optimize=True)
# full static frame comparison
page=Image.new("RGB",(1280,560),(237,240,243));d=ImageDraw.Draw(page)
for j,which in enumerate(("native","transfer")):
 d.text((15,15+j*275),"TRUE FS ORIGINAL" if which=="native" else "PIXELLAB RE-DRESSED (unaltered poses)",font=F,fill=(17,33,49))
 fs=orig if which=="native" else cycle
 for i,f in enumerate(fs):
  bg=Image.new("RGBA",(40,40),(237,240,243,255));bg.alpha_composite(f)
  page.paste(bg.convert("RGB").resize((255,255),Image.Resampling.NEAREST),(i*315+20,28+j*275))
page.save(R/"A31_ORIGINAL_VS_NEW_4FRAME_REAL_POSES.png")
frame_diffs=[changed(cycle[i],cycle[i+1]) for i in range(3)]
seam=changed(cycle[-1],cycle[0])
source_diffs=[changed(orig[i],orig[i+1]) for i in range(3)]
qa={"stage":"A31","transferred_raw":mm,"original_bboxes":[f.getbbox() for f in orig],
  "source_diffs":source_diffs,"provider_original_frame_diffs":[changed(raw[i],raw[i+1]) for i in range(3)],
  "provider_neutral_repeat_difference":changed(raw[1],raw[3]),
  "pixel_only_alignment_shift_xy":shifts,"normalization":"Translation only; no re-render/repaint",
  "final_cycle_indices":[0,1,2,1],"final_frame_diffs":frame_diffs,"final_loop_seam":seam,
  "floor_bottoms":level_y(metrics(cycle)),
  "native_motion_sequence":"source right facing row2: c0-c1-c2-c1",
  "idle_policy":"STATIC source neutral pose transferred to outfit, no invented breath",
  "visual_gate":"USER_REVIEW_PENDING; transfer output may alter style",
  "true_45degree_gate":"NOT YET PASSED; original source r2 right-facing",
  "SBS_engine":"NOT TESTED"}
qa["footline_gate"]="PASS" if len(set(qa["floor_bottoms"]))==1 and qa["floor_bottoms"][0]==38 else "FAIL"
(R/"A31_TRANSFER_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("A31_QA",json.dumps({k:qa[k] for k in ["source_diffs","provider_neutral_repeat_difference","pixel_only_alignment_shift_xy","final_frame_diffs","final_loop_seam","floor_bottoms","footline_gate"]},ensure_ascii=False))
print("OUTPUTS",[(p.name,p.stat().st_size) for p in [R/"A31_REAL_SOURCE_VS_PIXEL_LAB_OUTFIT_LOOP.gif",R/"A31_FS_OUTFIT_TRANSFER_REAL_SOURCE_WALK.gif"]])
