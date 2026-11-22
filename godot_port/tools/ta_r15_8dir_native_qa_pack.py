#!/usr/bin/env python3
"""R15 real private Godot 4.7.2 native QA and reproducible file-by-file source archive.
No public original LPC image upload. True 8dir original source, newly authored unarmed attack.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,zipfile
ROOT=Path(r"E:\LPC_Original_20261121")
BASE=ROOT/"FS_R15_ACTOR01_EIGHTDIR_TWO_JOINT_UNARMED_45"
N=BASE/"native_godot472_60Hz"
assert all((N/f"{i:03d}.png").exists() for i in range(73)),"73 native Godot frames missing"
m=json.loads((BASE/"R15_SOURCE_AND_ART_QA_MANIFEST.json").read_text(encoding="utf-8"))
native=json.loads((N/"R15_NATIVE_QA.json").read_text(encoding="utf-8"))
assert native["engine"]["major"]==4 and native["engine"]["minor"]==7 and native["engine"]["patch"]==2
assert native["frames"]==73 and native["visited"]==list(range(12)) and native["contact_events"]==1
assert m["source_directions"]==8 and m["source_native_attack"] is False
assert m["source_original_8dir_anatomy"] is True
assert m["frame_count"]==12 and m["unique_poses"]==11
assert m["weapon_pixels"]==m["fx_pixels"]==0
assert m["front_upper_length"]==m["back_upper_length"]==8.0
assert m["status"].startswith("ART_HOLD")
assert len(m["animation"])==12

# R15 joint motion requirements: no flying fist attached to hair, meaningful
# x travel between acceleration/contact; 1x jaw/chest-level contact not top hair.
wrist=m["front_wrist_screen_trajectory"]
assert len(wrist)==12 and wrist[0]==wrist[11]
assert wrist[5][0]+3<=wrist[6][0] and wrist[6][0]+2<=wrist[7][0]
assert wrist[7][0]>49 and 29<=wrist[7][1]<=35
assert wrist[8][0]<wrist[7][0] and wrist[9][0]<wrist[8][0]
# Earlier R14 wrist trajectory screen-space at the contact key:
# source shoulder(39,35), elbow(39,43), near wrist +6, angles upper75° bend-10°,
# center translate +2x and -12y => (54.164,27.605) near hair.
import math
old_wrist=[round(39+8*math.sin(math.radians(75))+6*math.sin(math.radians(65))+2,3),
           round(35+8*math.cos(math.radians(75))+6*math.cos(math.radians(65))-12,3)]
assert wrist[7][1]>old_wrist[1]+3,"R15 still punches at hairline!"
for frame in m["animation"]:
 assert frame["front"]["upper_len"]==8.0
 assert frame["back"]["upper_len"]==8.0
 assert frame["debris_removed"]==0
 assert frame["body_pixels"]>=250
assert m["animation"][0]["face_changed_pixels"]==m["animation"][11]["face_changed_pixels"]==0
assert all(f["face_changed_pixels"]>0 for f in m["animation"][1:11])
def sha(p):
 h=hashlib.sha256()
 with open(p,"rb") as f:
  for b in iter(lambda:f.read(1<<20),b""):h.update(b)
 return h.hexdigest()
body=BASE/"R15_ACTOR01_8DIR_TWO_JOINT_UNARMED_BODY.png"
source=Image.open(body).convert("RGBA")
assert source.size==(256,192) and sha(body)==m["sprite_sha256"]
for name in ("R15_WEAPON_ALPHA_ZERO.png","R15_FX_ALPHA_ZERO.png"):
 blank=Image.open(BASE/name).convert("RGBA")
 assert blank.size==(256,192) and blank.getbbox() is None
source_frames=[source.crop(((i%4)*64,(i//4)*64,(i%4)*64+64,(i//4)*64+64)) for i in range(12)]
assert source_frames[0].tobytes()==source_frames[11].tobytes()
assert len({f.tobytes() for f in source_frames})==11
first_tick={}
for tick in native["timeline"]:first_tick.setdefault(tick["frame"],tick["tick"])
native_poses=[]
rgba_mismatch=[]
for i in range(12):
 im=Image.open(N/f"{first_tick[i]:03d}.png").convert("RGBA")
 native_poses.append(im)
 rgba_mismatch.append(sum(a!=b for a,b in zip(im.tobytes(),source_frames[i].tobytes())))
assert rgba_mismatch==[0]*12,"Source vs true Godot GPU sprite differs"
for scale in (1,4):
 size=64*scale
 board=Image.new("RGBA",(4*size,3*(size+20)),(23,27,32,255))
 d=ImageDraw.Draw(board)
 for i,im in enumerate(native_poses):
  x=i%4*size;y=i//4*(size+20)
  board.alpha_composite(im.resize((size,size),Image.Resampling.NEAREST),(x,y+20))
  d.text((x+2,y+2),f"R15 F{i:02d}",fill=(244,244,246))
 board.convert("RGB").save(BASE/f"R15_GODOT472_NATIVE_12KEY_{scale}X.png")
gif=[]
for i in range(73):
 fr=Image.open(N/f"{i:03d}.png").convert("RGBA").resize((256,256),Image.Resampling.NEAREST)
 bg=Image.new("RGBA",(256,256),(23,27,32,255))
 bg.alpha_composite(fr)
 gif.append(bg.convert("RGB"))
gif[0].save(BASE/"R15_GODOT472_ACTUAL_73_FRAMES_60HZ.gif",save_all=True,append_images=gif[1:],duration=17,loop=0,optimize=True)
# R13 native vs R15 native 4x contact sheet. Do not mislabel as same source.
prev=Image.open(ROOT/"FS_R14_ACTOR01_EIGHTDIR_TWO_JOINT_UNARMED_45"/"R14_ACTOR01_8DIR_TWO_JOINT_UNARMED_BODY.png").convert("RGBA")
compare=Image.new("RGBA",(4*512,3*280),(23,27,32,255))
d=ImageDraw.Draw(compare)
for i in range(12):
 x=i%4*512;y=i//4*280
 p=prev.crop((i%4*64,i//4*64,i%4*64+64,i//4*64+64)).resize((256,256),Image.Resampling.NEAREST)
 n=native_poses[i].resize((256,256),Image.Resampling.NEAREST)
 compare.alpha_composite(p,(x,y+22))
 compare.alpha_composite(n,(x+256,y+22))
 d.text((x+3,y+3),f"F{i:02d} R14 source",fill=(243,244,245))
 d.text((x+260,y+3),"R15 Godot GPU",fill=(243,244,245))
compare.convert("RGB").save(BASE/"R14_VS_R15_8DIR_TWO_JOINT_12POSE_4X.png")
report={
 "result":"ENGINE_QA_PASS_ART_HOLD",
 "godot_build":native["engine"],
 "native_frame_count":73,"fps":60,"source_vs_gpu_exact_RGBA_byte_mismatches":rgba_mismatch,
 "original_source_is_eight_direction_diagonal_walk":True,
 "original_source_is_eight_direction_attack":False,
 "newly_reauthored_attack_with_fixed_upper_and_forearm":True,
 "front_upper_source_bone_length_px":8,
 "back_upper_source_bone_length_px":8,
 "emotion_source_pixel_changes": [f["face_changed_pixels"] for f in m["animation"]],
 "all_body_continuous":True,"stray_removed_pixels":0,
 "contact_estimated_wrist_screen_coordinates":wrist[7],
 "previous_r14_estimated_contact_wrist_screen_coordinates":old_wrist,
 "contact_wrist_y_shift_downward_px":round(wrist[7][1]-old_wrist[1],3),
 "kinematic_forward_and_recoil_gates_pass":True,
 "weapon_pixels":0,"fx_pixels":0,"actual_f7_0_630_visual_event_once":native["contact_events"]==1,
 "real_live_FSBattle":"NOT_RUN",
 "art_hold_reason":"R15 lowers front hand from R14 high hairline and drives forward then recoil; geometry source check is not true visual anatomy nor FSBattle approval",
 "sha256":{name:sha(BASE/name) for name in ("R15_ACTOR01_8DIR_TWO_JOINT_UNARMED_BODY.png","R15_WEAPON_ALPHA_ZERO.png","R15_FX_ALPHA_ZERO.png")}
}
(BASE/"R15_FINAL_REAL_GODOT_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
readme=(
"FS T-A R15: authentic LPC original EIGHT-DIRECTION diagonal torso/arm layers, reauthored 12-frame 45-degree UNARMED attack. "
"No original native 8dir attack source was found. R15 corrects the F7 high hairline fist flaw using source shoulder/elbow kinematics and pivots both "
"about original 8px upper-arm bone, with deliberate elbow bend. No elastic stretch, weapon, shield, FX or symbols. "
"Original A62 white-haired face maintained, expression phases introduce 1..5 changed face pixels at body frames 1..10. "
"Real original-source Windows Godot 4.7.2 OpenGL private asset 73/73 native 60Hz PNG capture, 12/12 pixel-perfect 0 RGBA differences, "
"F7 contact presentation once at 0.630 sec. NOT validated against original live FSBattle. "
"ART HOLD: user visual approval of 1x 45-degree whole-body acting still needed. "
"Source ORA owner E:\\LPC_Original_20261121\\LPC_8DIR_ORIGINAL_DIAGONAL\\extracted\\LPC_male_diagonal_walkcycle.ora. "
"Artist credit Wolthera van Hoevell tot Westerflier, based on Redshrike; respect original CC BY-SA 3.0/GPL 3.0/OGA-BY 3.0."
)
(BASE/"README_R15_QUALITY_AND_PROVENANCE.md").write_text(readme,encoding="utf-8")
includes=[
 "R15_ACTOR01_8DIR_TWO_JOINT_UNARMED_BODY.png",
 "R15_WEAPON_ALPHA_ZERO.png",
 "R15_FX_ALPHA_ZERO.png",
 "R15_SOURCE_AND_ART_QA_MANIFEST.json",
 "R15_12KEY_ART_CONTACT_4X.png",
 "R15_TWO_JOINT_UNARMED_ART_PREVIEW.gif",
 "R15_GODOT472_NATIVE_12KEY_1X.png",
 "R15_GODOT472_NATIVE_12KEY_4X.png",
 "R15_GODOT472_ACTUAL_73_FRAMES_60HZ.gif",
 "R14_VS_R15_8DIR_TWO_JOINT_12POSE_4X.png",
 "R15_FINAL_REAL_GODOT_QA.json",
 "README_R15_QUALITY_AND_PROVENANCE.md",
 "godot_project/project.godot",
 "godot_project/tests/capture_r15_unarmed.gd",
 "native_godot472_60Hz/R15_NATIVE_QA.json",
 "native_godot472_60Hz/godot_log.txt"
]
zip_path=BASE/"FS_TA_R15_8DIR_TWO_JOINT_UNARMED_NATIVE_73FRAMES_QA_20261122.zip"
with zipfile.ZipFile(zip_path,"w",zipfile.ZIP_DEFLATED) as z:
 for f in includes:z.write(BASE/f,f)
 for i in range(73):z.write(N/f"{i:03d}.png",f"native/{i:03d}.png")
 z.write(ROOT/"FS_R15_ACTOR01_8DIR_PUNCH_KINEMATICS.py","source/FS_R15_ACTOR01_8DIR_PUNCH_KINEMATICS.py")
 z.write(ROOT/"FS_R15_NATIVE_QA_PACK.py","source/FS_R15_NATIVE_QA_PACK.py")
with zipfile.ZipFile(zip_path) as z:
 assert z.testzip() is None,"ZIP CRC FAIL"
 count=len(z.namelist())
assert count==91,count
print(json.dumps({"name":zip_path.name,"zip_bytes":zip_path.stat().st_size,"zip_sha256":sha(zip_path),"members":count,
"engine_real_73":True,"source_gpu_differences":rgba_mismatch,"art":"ART_HOLD","weapon":0,"fx":0},ensure_ascii=True))
