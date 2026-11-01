"""A37 Damage B/C per-frame comparison and 3-frame fail-closed review.
All cells come from genuine original PixelLab provider frames, no generated substitutes.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A37_FS_T4_DODGE_AND_DAMAGE_20261101")
B=R/"DAMAGE_B_NATIVE_FACING";C=R/"DAMAGE_C_STRONG_HIT"
bc=[B/f"PIXELLAB_REAL_DAMAGE_F{i}.png" for i in range(3)]
cc=[C/f"PIXELLAB_DAMAGE_C_REAL_F{i}.png" for i in range(3)]
if not all(p.exists() for p in cc):
 print("DAMAGE_C_NOT_READY");raise SystemExit(2)
before=[Image.open(x).convert("RGBA") for x in bc]
after=[Image.open(x).convert("RGBA") for x in cc]
assert all(f.size==(40,40) for f in before+after)
def diff(a,b):return sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
def dims(frames):
 return [{"bbox":x.getbbox(),"right_edge":sum(x.getpixel((39,j))[3]>0 for j in range(40)),
 "bottom_edge":sum(x.getpixel((j,39))[3]>0 for j in range(40))} for x in frames]
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",18)
except:font=ImageFont.load_default()
p=Image.new("RGB",(3*335,3*330),(237,240,243));d=ImageDraw.Draw(p)
mix=[before[0],after[1],before[2]]
rows=[("B FIRST PASS, REAL PIXELLAB",before),("C SECOND PASS STRONG HIT, REAL PIXELLAB",after),("COMPOSITE: REAL B F0 + C F1 + B F2",mix)]
for k,(name,items) in enumerate(rows):
 y=330*k;d.rectangle((0,y,1004,y+32),fill=(29,44,60));d.text((14,y+5),name,font=font,fill=(250,250,251))
 for i,x in enumerate(items):
  bg=Image.new("RGBA",(40,40),(237,240,243,255));bg.alpha_composite(x)
  p.paste(bg.convert("RGB").resize((305,305),Image.Resampling.NEAREST),(335*i+10,y+32))
p.save(R/"A37_DAMAGE_B_VS_C_VS_CAMERA_LOCK_REVIEW.png",optimize=True)
sheet=Image.new("RGBA",(120,40))
for i,frame in enumerate(mix):sheet.alpha_composite(frame,(40*i,0))
sheet.save(R/"A37_DAMAGE_COMPOSITE_3FRAME_CANDIDATE.png")
mix[0].save(R/"A37_DAMAGE_COMPOSITE_ONESHOT.gif",save_all=True,append_images=mix[1:],
duration=[165,265,425],disposal=2,optimize=False)
qa={"stage":"A37","source":"three genuine PixelLab B/C frames only",
"B_bbox":dims(before),"C_bbox":dims(after),"camera_locked_mix_bbox":dims(mix),
"B_C_per_frame_changed_pixels":[diff(x,y) for x,y in zip(before,after)],
"B_adjacent_diffs":[diff(before[i],before[i+1]) for i in range(2)],
"C_adjacent_diffs":[diff(after[i],after[i+1]) for i in range(2)],
"composite_adjacent_diffs":[diff(mix[i],mix[i+1]) for i in range(2)],
"max_candidates":3,"all_120x40":True,
"last_gate":"NOT FORMAL ART PASS; user visual review of Damage action and per-frame 45-degree",
"source_raw_untouched":True,"sbs_engine":"NOT TESTED",
"output_sha256":hashlib.sha256((R/"A37_DAMAGE_COMPOSITE_3FRAME_CANDIDATE.png").read_bytes()).hexdigest()}
(R/"A37_DAMAGE_B_C_COMPARE_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("B/C_QA",json.dumps(qa,ensure_ascii=False),flush=True)
