"""A41 compare native source, A38 prompt-only damage, A40 skeletal critical, A41 skeletal normal.
Preserve provider raw 3 frames; anchor true native 45deg F0/F2 separately, strictly 3.
No synthetic pixel drawing; any artist quality failure blocks formal game assets.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A41_NORMAL_DAMAGE_SKELETON_3F_20261101"
A40=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
A38=B/"A38_DAMAGE_F1_NATIVE_45_IMAGE_EDIT_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
paths=[R/f"A41_REAL_SKELETON_V3_DAMAGE_FRAME_{i:02}.png" for i in range(3)]
if not all(x.exists() for x in paths):print("A41_RAW_FRAMES_NOT_READY");raise SystemExit(2)
new=[Image.open(x).convert("RGBA") for x in paths]
base=Image.open(A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png").convert("RGBA")
old=Image.open(A38/"A38_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png").convert("RGBA")
critical=Image.open(A40/"A40_CRITICAL_SOURCE_ANCHORED_3FRAME_CANDIDATE.png").convert("RGBA")
cr=[critical.crop((i*40,0,(i+1)*40,40)) for i in range(3)]
assert all(x.size==(40,40) for x in new+cr+[base,old])
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def changed(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def metrics(x):
 return {"bbox":x.getbbox(),"opaque":sum(p[3]>0 for p in x.getdata()),
 "touch_right":sum(x.getpixel((39,y))[3]>0 for y in range(40)),
 "touch_bottom":sum(x.getpixel((i,39))[3]>0 for i in range(40))}
selected=[base,new[1],base]
strip=Image.new("RGBA",(120,40))
for i,im in enumerate(selected):strip.alpha_composite(im,(40*i,0))
sheet=R/"A41_NORMAL_DAMAGE_EXACT_SOURCE_3FRAME_CANDIDATE_120x40.png";strip.save(sheet)
selected[0].save(R/"A41_NORMAL_DAMAGE_3FRAME_ONESHOT.gif",save_all=True,append_images=selected[1:],
duration=[180,250,470],disposal=2,optimize=False)
gif=Image.open(R/"A41_NORMAL_DAMAGE_3FRAME_ONESHOT.gif")
assert gif.n_frames==3 and gif.info.get("loop") is None
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",17)
except:F=ImageFont.load_default()
rows=[
("A38 NORMAL DAMAGE: text-only F1", [base,old,base]),
("A40 CRITICAL DAMAGE: skeleton-controlled", cr),
("A41 NORMAL DAMAGE: provider RAW 3 frames", new),
("A41 NORMAL DAMAGE: source-anchored 3 frames",selected)]
canvas=Image.new("RGB",(3*320,4*333),(237,241,244));d=ImageDraw.Draw(canvas)
for row,(name,frames) in enumerate(rows):
 y=row*333
 d.rectangle((0,y,959,y+31),fill=(26,43,57))
 d.text((13,y+6),name,font=F,fill=(250,250,252))
 for col,item in enumerate(frames):
  bg=Image.new("RGBA",(40,40),(237,241,244,255));bg.alpha_composite(item)
  canvas.paste(bg.convert("RGB").resize((297,297),Image.Resampling.NEAREST),(320*col+12,y+34))
canvas.save(R/"A41_A38_A40_NORMAL_VS_CRITICAL_COMPARISON.png",optimize=True)
qa={"stage":"A41","native_frame_size":[40,40],"strict_sheet_size":[120,40],"exactly_three_frames":True,
"PixelLab_source":"A34 45-degree native battle-facing white-haired unarmed master, reuse actual A40 18-joint PixelLab skeleton",
"A41_raw_frame_metrics":[metrics(x) for x in new],
"A41_source_anchored_metrics":[metrics(x) for x in selected],
"alpha_no_right_bottom_clip":not any(v["touch_right"] or v["touch_bottom"] for v in [metrics(x) for x in new+selected]),
"source_F0_equals_F2":changed(selected[0],selected[2])==0,
"old_normal_to_new_normal_F1_changes":changed(old,new[1]),
"new_normal_F1_to_critical_F1_changes":changed(new[1],cr[1]),
"new_normal_F1_to_critical_F2_changes":changed(new[1],cr[2]),
"A41_selected_adjacent_pixel_changes":[changed(selected[i],selected[i+1]) for i in range(2)],
"camera_45_each":"NEEDS HUMAN IMAGE REVIEW, compare face planes/shoulders/hips in each frame",
"normal_hit_semantic":"NEEDS HUMAN IMAGE REVIEW, must read as moderate recoil not deep critical",
"paper_doll_unarmed":"VISUAL CHECK, engine not run","SBS_VX_engine":"NOT TESTED",
"formal_art_pass":False,"no_game_project_changes":True,"new_sheet_sha256":sha(sheet)}
(R/"A41_VISUAL_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("A41_QA",json.dumps(qa,ensure_ascii=False),flush=True)
