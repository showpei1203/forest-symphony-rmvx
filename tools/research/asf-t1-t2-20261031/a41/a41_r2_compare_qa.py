"""A41 R1 FAIL vs R2 guards-in: source-backed provider 3 frames each, strict.
Determine whether normal Damage is visually distinguishable from A40 critical.
No raster repaint, source F0 and F2 exact canonical 45deg actor.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A41_NORMAL_DAMAGE_SKELETON_3F_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
A40=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
R2=R/"R2_HANDS_IN_GUARD"
r2paths=[R2/f"PIXELLAB_R2_DAMAGE_F{i}.png" for i in range(3)]
if not all(p.exists() for p in r2paths):print("R2_PENDING");raise SystemExit(2)
orig=Image.open(A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png").convert("RGBA")
r1=[Image.open(R/f"A41_REAL_SKELETON_V3_DAMAGE_FRAME_{i:02}.png").convert("RGBA") for i in range(3)]
r2=[Image.open(p).convert("RGBA") for p in r2paths]
crit=Image.open(A40/"A40_CRITICAL_SOURCE_ANCHORED_3FRAME_CANDIDATE.png").convert("RGBA")
cr=[crit.crop((i*40,0,(i+1)*40,40)) for i in range(3)]
assert all(im.size==(40,40) for im in [orig]+r1+r2+cr)
def changed(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def bbox(im):return {"bbox":im.getbbox(),"touch_right":sum(im.getpixel((39,i))[3]>0 for i in range(40)),"touch_bottom":sum(im.getpixel((i,39))[3]>0 for i in range(40))}
select=[orig,r2[1],orig]
sheet=Image.new("RGBA",(120,40))
for i,img in enumerate(select):sheet.alpha_composite(img,(40*i,0))
p=R/"A41_R2_NORMAL_DAMAGE_NATIVE_SOURCE_ANCHORED_3F.png";sheet.save(p)
select[0].save(R/"A41_R2_NORMAL_DAMAGE_3F_ONESHOT.gif",save_all=True,append_images=select[1:],
duration=[180,250,450],disposal=2,optimize=False)
gi=Image.open(R/"A41_R2_NORMAL_DAMAGE_3F_ONESHOT.gif")
assert gi.n_frames==3 and gi.info.get('loop') is None
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
except:F=ImageFont.load_default()
panel=Image.new("RGB",(3*318,4*325),(236,240,244));draw=ImageDraw.Draw(panel)
rows=[("A40 CRITICAL: body collapses, third frame",cr),
("A41 R1 NORMAL: arms flare (semantic FAIL)",r1),
("A41 R2 NORMAL: arms constrained, RAW",r2),
("A41 R2: exact native F0/F2 anchored",select)]
for i,(label,row) in enumerate(rows):
 y=i*325
 draw.rectangle((0,y,953,y+30),fill=(25,42,58))
 draw.text((13,y+7),label,font=F,fill=(247,248,250))
 for j,img in enumerate(row):
  bg=Image.new("RGBA",(40,40),(236,240,244,255));bg.alpha_composite(img)
  panel.paste(bg.convert("RGB").resize((297,290),Image.Resampling.NEAREST),(j*318+9,y+33))
panel.save(R/"A41_R1_FAIL_R2_VS_A40_CRITICAL_COMPARISON.png",optimize=True)
data={"stage":"A41-R2","generated_provider_real_frames":3,"native_40x40":True,"source_anchored_120x40":True,
"R1_F1_bad_arms":"clear sideways stretched arm, motion semantic FAIL",
"R1_to_R2_midpose_changes":changed(r1[1],r2[1]),
"R2_to_critical_F2_changes":changed(r2[1],cr[2]),
"R2_midpose_vs_original_changes":changed(r2[1],orig),
"R2_raw":[bbox(img) for img in r2],"R2_candidate":[bbox(img) for img in select],
"no_border_clip":all(not v["touch_right"] and not v["touch_bottom"] for v in [bbox(im) for im in select]),
"native_F0_F2_exact":changed(select[0],select[2])==0,
"art_camera_gate":"NEEDS VISUAL QA ALL THREE FRAMES, especially F1 head/eyes/armor",
"normal_damage_motion":"NEEDS VISUAL QA, could look like attack/cast",
"weapon_overlay":"NOT TESTED, source intended unarmed","Vx_sbs":"NOT TESTED",
"R2_sheet_sha256":hashlib.sha256(p.read_bytes()).hexdigest(),"original_game_files_untouched":True}
(R/"A41_R2_COMPARE_QA.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf8")
print("R2_COMPARE_QA",json.dumps(data,ensure_ascii=False),flush=True)
