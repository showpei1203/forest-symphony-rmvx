#!/usr/bin/env python3
from PIL import Image,ImageDraw
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(r"E:\LPC_Original_20261121")
BASE=ROOT/"FS_R13_ACTOR01_EIGHTDIR_UNARMED_45_ART"
N=BASE/"native_godot472_60Hz"
assert all((N/f"{i:03d}.png").exists() for i in range(73)), "missing original real GPU frames"
manifest=json.loads((BASE/"R13_UNARMED_EIGHT_DIRECTION_SOURCE_MANIFEST.json").read_text(encoding="utf-8"))
native=json.loads((N/"R13_NATIVE_QA.json").read_text(encoding="utf-8"))
assert native["engine"]["major"]==4 and native["engine"]["minor"]==7 and native["engine"]["patch"]==2
assert native["frames"]==73 and native["visited"]==list(range(12)) and native["contact_events"]==1
assert manifest["source_diagonal_direction_row"]==7 and manifest["verified_original_8dir_attack_sprite"]==False
assert manifest["no_weapon"] and manifest["weapon_opaque_pixels"]==manifest["fx_opaque_pixels"]==0
def sha(path):
 h=hashlib.sha256()
 with open(path,"rb") as f:
  for chunk in iter(lambda:f.read(1<<20),b""):h.update(chunk)
 return h.hexdigest()
body=BASE/"R13_ACTOR01_REAL_8DIR_BASE_UNARMED_ATTACK_BODY.png"
src=Image.open(body).convert("RGBA")
frames=[src.crop(((i%4)*64,(i//4)*64,(i%4)*64+64,(i//4)*64+64)) for i in range(12)]
for p in ["R13_WEAPON_ALPHA_ZERO.png","R13_FX_ALPHA_ZERO.png"]:
 assert Image.open(BASE/p).convert("RGBA").getbbox() is None
first={}
for entry in native["timeline"]:first.setdefault(entry["frame"],entry["tick"])
mismatches=[]
captured=[]
for i in range(12):
 real=Image.open(N/f"{first[i]:03d}.png").convert("RGBA")
 captured.append(real)
 mismatches.append(sum(a!=b for a,b in zip(real.tobytes(),frames[i].tobytes())))
assert mismatches==[0]*12, "native viewport source RGBA pixels mismatch"
assert frames[0].tobytes()==frames[-1].tobytes()
assert len({f.tobytes() for f in frames})==11
# 1x sprite readability and native 4x storyboard
for scale in (1,4):
 cell=64*scale
 art=Image.new("RGBA",(4*cell,3*(cell+18)),(22,27,32,255))
 d=ImageDraw.Draw(art)
 for i,f in enumerate(captured):
  xx=(i%4)*cell; yy=(i//4)*(cell+18)
  art.alpha_composite(f.resize((cell,cell),Image.Resampling.NEAREST),(xx,yy+18))
  d.text((xx+2,yy+1),f"R13 F{i:02d}",fill=(240,243,244))
 art.convert("RGB").save(BASE/f"R13_TRUE_GODOT472_NATIVE_12KEY_{scale}X.png")
# 73 actual native screenshots rendered as 60hz GIF, no re-painted demonstration frames
gif=[]
for i in range(73):
 frame=Image.open(N/f"{i:03d}.png").convert("RGBA").resize((256,256),Image.Resampling.NEAREST)
 bg=Image.new("RGBA",(256,256),(22,27,32,255))
 bg.alpha_composite(frame)
 gif.append(bg.convert("RGB"))
gif[0].save(BASE/"R13_GODOT472_ACTUAL_73_FRAMES_60HZ.gif",save_all=True,append_images=gif[1:],duration=17,loop=0,optimize=True)
# Honest compare: earlier R12 PRIVATE CPU source, R13 actual Godot GPU
r12=Image.open(ROOT/"FS_R12_ACTOR01_UNARMED_45_STUDY"/"R12_ACTOR01_UNARMED_BODY_12x64.png").convert("RGBA")
wide=Image.new("RGBA",(4*512,3*280),(22,27,32,255))
d=ImageDraw.Draw(wide)
for i in range(12):
 x=(i%4)*512;y=(i//4)*280
 old=r12.crop(((i%4)*64,(i//4)*64,(i%4)*64+64,(i//4)*64+64)).resize((256,256),Image.Resampling.NEAREST)
 new=captured[i].resize((256,256),Image.Resampling.NEAREST)
 wide.alpha_composite(old,(x,y+22));wide.alpha_composite(new,(x+256,y+22))
 d.text((x+2,y+2),f"F{i:02d} R12 CPU",fill=(240,243,244));d.text((x+257,y+2),"R13 Godot GPU",fill=(240,243,244))
wide.convert("RGB").save(BASE/"R12_VS_R13_EIGHTDIR_ACTUAL_GODOT_12POSE_4X.png")
report={
 "status":"ENGINE_QA_PASS_ART_HOLD",
 "true_original_eight_dir_body_source":True,
 "true_original_eight_dir_ATTACK_source":False,
 "attack_art":"new rigid pivot pose redraw based on diagonal LPC walk ORIGINAL arm layers",
 "engine":native["engine"],"native_60hz_frames":73,
 "native_12poses_source_rgba_byte_differences":mismatches,
 "loop_first_last_equal":True,"unique_poses":11,
 "weapon_pixels":0,"fx_pixels":0,
 "owner_original_lpc_sha":manifest["source_ora_sha"],
 "private_body_sha256":sha(body),
 "f7_contact_exact_once":native["contact_events"]==1,
 "source_color_version":"Approved A62 head + recolored 8-dir LPC shoulder/torso/lower limbs",
 "art_blockers":["Reauthored attack not verified source-native 8-dir attack",
 "Need human review face/shoulder anatomy and natural forward punch at 1x",
 "Not in real FS battle ATB/damage"]
}
(BASE/"R13_FINAL_NATIVE_QA.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf-8")
readme="""# Forest Symphony T-A R13 | 8 direction LPC source, NO WEAPON
New actual 12-frame Body source constructed from VERIFIED LPC ORIGINAL male diagonal walk ORA.
Official original 8 direction anatomy (9 frames x 8 directions), row7 for 45-facing actor.
Body's shoulder arms taken from ORA independently, rigidly rotated around shoulder to AUTHOR new attack. No stretch, zero weapons, no FX. ACTOR01 face/head original approved A62 copied into all frames. This is an R13 artist candidate, NOT preexisting eight-direction LPC attack source.
Actual Godot 4.7.2 Windows OpenGL 73 screenshots at 60 Hz, all 12 active poses, F7 contact 0.630 exactly once. 0 full RGBA readback differences for all keyframes. Whole-battle FS ATB/HP not tested. ART HOLD due shoulder, punch and face readability.
Original diagonal walk/run ZIP: E:\\LPC_Original_20261121\\LPC_8DIR_ORIGINAL_DIAGONAL\\LPC_diagonalwalknruncycle.zip
Original 8direction ZIP SHA256: 278bba048b4f25b8c8d9601b2cc27402c298cf1c68c554be9e68c8e11c2ee716.
Attribution author Wolthera van Hövell tot Westerflier (TheraHedwig), based on Redshrike LPC. Licensed CC BY-SA 3.0/GPL3/OGA-BY3. Keep original private, retain credits. Source art cannot be pasted into unrestricted public GitHub.
"""
(BASE/"README_R13_SOURCE_AND_ART_HOLD.md").write_text(readme,encoding="utf-8")
files=[
 "R13_ACTOR01_REAL_8DIR_BASE_UNARMED_ATTACK_BODY.png",
 "R13_WEAPON_ALPHA_ZERO.png","R13_FX_ALPHA_ZERO.png",
 "R13_UNARMED_EIGHT_DIRECTION_SOURCE_MANIFEST.json",
 "R13_NATIVE_8DIR_BASE_12FRAME_ATTACK_CONTACT_4X.png",
 "R13_UNARMED_8DIR_BASE_12FRAME_LOOP.gif",
 "R13_TRUE_GODOT472_NATIVE_12KEY_1X.png",
 "R13_TRUE_GODOT472_NATIVE_12KEY_4X.png",
 "R13_GODOT472_ACTUAL_73_FRAMES_60HZ.gif",
 "R12_VS_R13_EIGHTDIR_ACTUAL_GODOT_12POSE_4X.png",
 "R13_FINAL_NATIVE_QA.json","README_R13_SOURCE_AND_ART_HOLD.md",
 "godot_project/project.godot","godot_project/tests/capture_r13_unarmed.gd",
 "native_godot472_60Hz/R13_NATIVE_QA.json",
 "native_godot472_60Hz/godot_log.txt"]
zpath=BASE/"FS_TA_R13_REAL_8DIR_UNARMED_73_NATIVE_QA_20261122.zip"
with zipfile.ZipFile(zpath,"w",zipfile.ZIP_DEFLATED) as z:
 for file in files:z.write(BASE/file,file)
 for i in range(73):z.write(N/f"{i:03d}.png",f"native/{i:03d}.png")
 z.write(ROOT/"FS_R13_ACTOR01_EIGHTDIR_UNARMED.py","source/FS_R13_ACTOR01_EIGHTDIR_UNARMED.py")
with zipfile.ZipFile(zpath) as z:
 assert z.testzip() is None
 count=len(z.namelist())
print(json.dumps({"qa_archive":str(zpath),"bytes":zpath.stat().st_size,"zip_sha256":sha(zpath),"files":count,"actual_native_frames":73,"source_gpu_rgba_diffs":mismatches,"true_original_8dir_attack":False,"status":"ART_HOLD"},ensure_ascii=True))
