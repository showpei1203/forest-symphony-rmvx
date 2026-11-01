"""A37 true T4-selected Dodge and new PixelLab Damage: 3-frame per action,
trace inputs vs raw provider, per-frame direction and trim review, no synthetic art.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A37_FS_T4_DODGE_AND_DAMAGE_20261101"
D=R/"DAMAGE_B_NATIVE_FACING"
A33=B/"A33_HUMANOID_DIRECT_POSE_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
files=[D/f"PIXELLAB_REAL_DAMAGE_F{i}.png" for i in range(3)]
if not all(x.exists() for x in files):print("DAMAGE_PIXELLAB_NOT_READY");raise SystemExit(2)
F=[Image.open(p).convert("RGBA") for p in files]
assert all(f.size==(40,40) for f in F)
input_frames=[Image.open(D/f).convert("RGBA") for f in [
"INPUT_CORRECT_F0_45_BATTLE.png","INPUT_DAMAGE_F1_FROM_A33_REAL_PROVIDER.png","INPUT_CORRECT_F2_45_BATTLE.png"]]
previous=[Image.open(A33/"B_DAMAGE_DIRECT_POSES"/f"PIXELLAB_B_DAMAGE_FRAME_0{i}.png").convert("RGBA") for i in range(3)]
T4=Image.open(R/"A37_DODGING_T4_USER_SELECTED_3FRAME_120x40.png").convert("RGBA")
get=lambda im,i:im.crop((i*40,0,(i+1)*40,40))
def changed(a,b):return sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
def border(im):
 box=im.getbbox()
 return {"bbox":box,"alpha_pixels":sum(v[3]>0 for v in im.getdata()),
 "touch_right":sum(im.getpixel((39,y))[3]>0 for y in range(40)),
 "touch_bottom":sum(im.getpixel((x,39))[3]>0 for x in range(40))}
# QA all frames F0 first, then F1/F2; orientation marked visual and pending no auto false pass
qa={"stage":"A37_DAMAGE","action":"Damage","requirement":"EXACTLY 3 source frames per action; FS 45deg SE, 1:1 chibi, no weapons",
"new_provider": [border(i) for i in F],"input": [border(i) for i in input_frames],
"previous_A33": [border(i) for i in previous],
"source_vs_result_changed_pixels":[changed(a,b) for a,b in zip(input_frames,F)],
"result_adjacent_changed_pixels":[changed(F[i],F[i+1]) for i in range(2)],
"provider_frame0_to_frame2_diff":changed(F[0],F[2]),
"start_direction_camera_gate":"USER VISUAL REVIEW PENDING: must compare face/head/shoulders/hips with true FS actor01_1 reference",
"F1_recoil_action_gate":"USER VISUAL REVIEW PENDING: distinguish damage recoil from ordinary walk/idle",
"F2_recovery_camera_gate":"USER VISUAL REVIEW PENDING",
"weapon_paper_doll_gate":"VISUAL REVIEW/NO SBS ENGINE TEST",
"phase_count_gate":"PASS exactly 3 provider frames",
"source_40px_geometry_gate":"PASS",
"cropping_gate":"PASS" if all(v["touch_right"]==0 and v["touch_bottom"]==0 for v in [border(i) for i in F]) else "FAIL",
"original_fs_untouched":True,
"formal_art_pass":False}
# transparent raw 120x40 already in D; copy into A37 as exactly three frame candidate preserving original bytes
src=D/"PIXELLAB_REAL_DAMAGE_3FRAMES_120x40.png"
out=R/"A37_DAMAGE_SOURCE_DIRECT_3FRAME_CANDIDATE.png";out.write_bytes(src.read_bytes())
qa["full_sprite_sheet_sha256"]=hashlib.sha256(out.read_bytes()).hexdigest()
F[0].save(R/"A37_DAMAGE_3FRAME_ONESHOT.gif",save_all=True,append_images=F[1:],duration=[155,255,410],disposal=2,optimize=False)
g=Image.open(R/"A37_DAMAGE_3FRAME_ONESHOT.gif")
assert g.n_frames==3 and g.info.get("loop") is None
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",18)
except:font=ImageFont.load_default()
rows=[("A33 PREVIOUS DAMAGE (side-view risk)",previous),
("A37 INPUT: native battle F0 / damage middle / native F2",input_frames),
("A37 REAL PIXELLAB OUTPUT (3 frames)",F),
("A37 DODGING USER-SELECTED T4", [get(T4,i) for i in range(3)])]
page=Image.new("RGB",(3*320,4*330),(234,239,243));d=ImageDraw.Draw(page)
for row,(label,items) in enumerate(rows):
 y=row*330
 d.rectangle((0,y,959,y+30),fill=(23,40,56))
 d.text((15,y+5),label,font=font,fill=(245,246,248))
 for col,im in enumerate(items):
  bg=Image.new("RGBA",(40,40),(234,239,243,255));bg.alpha_composite(im)
  page.paste(bg.convert("RGB").resize((296,296),Image.Resampling.NEAREST),(col*320+12,y+32))
page.save(R/"A37_T4_DODGE_AND_DAMAGE_SOURCE_VS_RESULT_3FRAME.png",optimize=True)
p=Image.new("RGB",(3*315,335),(234,239,243));d=ImageDraw.Draw(p)
for i,im in enumerate(F):
 bg=Image.new("RGBA",(40,40),(234,239,243,255));bg.alpha_composite(im)
 p.paste(bg.convert("RGB").resize((295,295),Image.Resampling.NEAREST),(i*315+8,35))
 d.text((i*315+12,8),["F0: BRACE","F1: HIT RECOIL","F2: RECOVERY"][i],font=font,fill=(23,38,52))
p.save(R/"A37_DAMAGE_3FRAME_LARGE_PREVIEW.png",optimize=True)
(R/"A37_DAMAGE_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("DAMAGE_QA",json.dumps(qa,ensure_ascii=False),flush=True)
print("PREVIEWS",(R/"A37_T4_DODGE_AND_DAMAGE_SOURCE_VS_RESULT_3FRAME.png").stat().st_size)
