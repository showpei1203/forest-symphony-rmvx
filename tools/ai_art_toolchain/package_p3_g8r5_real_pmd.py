from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,shutil,zipfile,subprocess,xml.etree.ElementTree as ET
import numpy as np
from io import BytesIO
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
SOURCE=R/"outputs/P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX_20261027"
OLD_ST=R/"deliveries/P3_G8R4_NATIVE_PMD_MAGMA_OUTLINE_REPAIR_20261026"
ST=R/"deliveries/P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX_20261027"
ZIP=R/"deliveries/P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX_20261027.zip"
assert SOURCE.is_dir() and OLD_ST.is_dir() and not ST.exists() and not ZIP.exists()
ST.mkdir(parents=True)
# Authentic original source, prior accepted G8R4 reference, new actual G8R5
for dir in ("ORIGINAL_0003","G8R4_SAMPLE_0003"):
 shutil.copytree(OLD_ST/dir,ST/dir)
shutil.copytree(OLD_ST/"G8R4_SAMPLE_0003",ST/"G8R5_SAMPLE_0003")
shutil.copy2(SOURCE/"Idle-Anim.png",ST/"G8R5_SAMPLE_0003/Idle-Anim.png")
editable=ST/"EDITABLE_0003"
shutil.copytree(OLD_ST/"EDITABLE_0003",editable)
for f in (0,1):
 shutil.copy2(SOURCE/"pixelorama_layers"/f"Idle_back_F{f}.ora",editable/"pixelorama_layers"/f"Idle_back_F{f}.ora")
 shutil.copy2(SOURCE/"keyframes"/f"Idle_back_F{f}.png",editable/"frames"/f"Idle_back_F{f}.png")
P=ST/"PREVIEWS";P.mkdir()
shutil.copy2(SOURCE/"G8R5_0003_IDLE_BACK_G8R4_VS_FIXED_6X.png",P/"G8R5_0003_IDLE_BACK_G8R4_VS_FIXED_6X.png")
frames=[]
for f in (0,1):
 tile=Image.open(SOURCE/"keyframes"/f"Idle_back_F{f}.png").convert("RGBA")
 layer=Image.new("RGB",(270,185),(36,42,48));d=ImageDraw.Draw(layer)
 up=tile.resize((128,128),Image.Resampling.NEAREST);layer.paste(up,(72,20),up)
 d.text((8,7),f"PMD0003 Idle Back F{f} Native 32x32",fill=(235,222,205))
 frames.append(layer)
frames[0].save(P/"G8R5_PMD0003_IDLE_BACK_NATIVE.gif",save_all=True,append_images=frames[1:],
 duration=[190,190],loop=0,disposal=2)
shutil.copy2(SOURCE/"G8R5_0003_IDLE_BACK_QA.json",ST/"G8R5_0003_IDLE_BACK_QA.json")
SC=ST/"SCRIPTS";SC.mkdir()
for f in ("build_p3_g8r5_0003_idle_back.py","prepare_p3_g8r5_f1_only.py","g8r5_forensic_idle_back.py","g8r5_0003_idle_back_pixel_origin.py"):
 shutil.copy2(R/f,SC/f)
# Native Godot original XML test project, using the prior G8R4 project untouched except one atlas.
shutil.copytree(OLD_ST/"GODOT_0003",ST/"GODOT_0003",ignore=shutil.ignore_patterns(".godot","GODOT_XML_RENDER_FRAME_*.png","NATIVE_*log"))
shutil.copy2(SOURCE/"Idle-Anim.png",ST/"GODOT_0003/rock_0001/Idle-Anim.png")
# no other engine asset touched
QA='''from pathlib import Path
from PIL import Image
from io import BytesIO
import numpy as np,xml.etree.ElementTree as ET,zipfile,json
P=Path(__file__).resolve().parent
B=P/"G8R4_SAMPLE_0003";N=P/"G8R5_SAMPLE_0003";OR=P/"ORIGINAL_0003"
for f in B.iterdir():
 if f.name=="Idle-Anim.png":continue
 assert f.read_bytes()==(N/f.name).read_bytes(),("UNWANTED_FILE_CHANGE",f.name)
 if f.name=="AnimData.xml" or f.name.endswith(("-Offsets.png","-Shadow.png")):
  assert f.read_bytes()==(OR/f.name).read_bytes(),("METADATA_CHANGED",f.name)
assert len(ET.parse(N/"AnimData.xml").getroot().findall(".//Anim"))==14
old=np.asarray(Image.open(B/"Idle-Anim.png").convert("RGBA"))
new=np.asarray(Image.open(N/"Idle-Anim.png").convert("RGBA"))
assert old.shape==new.shape==(256,128,4)
changed=np.any(old!=new,axis=2)
assert int(changed.sum())==18,("WRONG_CHANGED_PIXEL_COUNT",int(changed.sum()))
for row in range(8):
 for col in range(4):
  a=old[row*32:(row+1)*32,col*32:(col+1)*32]
  b=new[row*32:(row+1)*32,col*32:(col+1)*32]
  if row==4 and col==1:
   assert np.any(a!=b)
   # fixed rocks: upper-right and left exterior cleaned, original body preserved
   assert not np.any((b[0:13,24:32,3]>0)),("RIGHT_UPPER_ROCK_STILL_THERE")
   assert np.array_equal(a[15:32,8:24],b[15:32,8:24]),("CENTRAL_BODY_CHANGED")
   assert np.array_equal(a[-4:],b[-4:]),("FEET_CHANGED")
  else:assert np.array_equal(a,b),("WRONG_FRAME_MODIFIED",row,col)
assert not np.any(changed[128:160,0:32]),("F0_WAS_ALREADY_VALID")
for f in (0,1):
 ori=P/"EDITABLE_0003/pixelorama_layers"/f"Idle_back_F{f}.ora"
 frame=P/"EDITABLE_0003/frames"/f"Idle_back_F{f}.png"
 with zipfile.ZipFile(ori) as z:
  assert z.testzip() is None
  assert z.read("mimetype")==b"image/openraster"
  root=ET.fromstring(z.read("stack.xml"))
  layers=root.findall(".//layer")
  assert len(layers)==12
  cur=Image.new("RGBA",(32,32))
  for l in reversed(layers):
   cur=Image.alpha_composite(cur,Image.open(BytesIO(z.read(l.attrib["src"]))).convert("RGBA"))
  assert np.array_equal(np.asarray(cur),np.asarray(Image.open(frame).convert("RGBA")))
  assert np.array_equal(np.asarray(cur),new[4*32:5*32,f*32:(f+1)*32])
q=json.loads((P/"G8R5_0003_IDLE_BACK_QA.json").read_text(encoding="utf-8"))
assert q["total_changed_32px_pixels"]==18 and q["edited_frame_indices"]==[1]
print("G8R5_AUTHENTIC_PMD_PASS: only 0003 Idle Back F1 18 changed pixels, F0/other 30 Idle cells/Walk/10 actions/XML/Offsets/Shadow unchanged")
'''
(ST/"VERIFY_G8R5.py").write_text(QA,encoding="utf-8")
(ST/"RUN_QUICK_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_G8R5.py"\r\npause\r\n',encoding="ascii")
(ST/"RUN_GODOT_XML.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Adjust Godot path and try again& pause& exit /b 1)
"%GODOT%" --headless --path "%~dp0GODOT_0003" --import
if errorlevel 1 exit /b 1
"%GODOT%" --path "%~dp0GODOT_0003" --rendering-driver opengl3 --scene res://player.tscn
pause
'''.replace("\n","\r\n"),encoding="ascii")
(ST/"README.md").write_text("""# P3 G8R5 REAL PMD 0003 IDLE BACK source patch (2026-10-27)
Only actual source frame modified: \`G8R5_SAMPLE_0003/Idle-Anim.png\` direction=4 back, original f1 (cell x32..63,y128..159) 18 changed 32px RGBA pixel positions. F0 was checked and found already correct, therefore deliberately unchanged. Original PNG action atlas 128x256 (32px cells) and original AnimData.xml, Shadow and Offsets kept EXACT. Other original actions from prior G8R4 unchanged. 0002 untouched, other animation directions untouched, maps paused and 0001 user-liked juvenile unchanged.

ROOT CAUSE: G8R3/R4 retained source original petal art in lower body layer: a spurious right-upper fragment at x25–26,y8–11 (including two old blue pixels incorrectly classified as protected frog body) plus added bridge on the R4 top overlay. Left x4–6,y13–17 similarly came from old underlayer, distinct from the real connected rounded-rock module. Removing entire connected components or moving boulder layers would damage source creature; only remove the identified unconnected decorative pixels in specific original body/repair layers. Side/main body, lava and every boulder layer unmodified. G8R5 removes 18 visible pixels in F1, leaving proper attached body. F0 left intact because original QA showed no actual stray in those regions.

The 12-layer ORA files for Idle back F0/F1 retain editable Pixelorama/OpenRaster layers; F1 only uses transparent erased old body ornament pixels; their merged output byte-equal to actual source cell and rebuilt native PMD atlas. Independent source diff and Godot XML/GPU tested, user art review still pending. Pixelorama native GUI not separately tested; original PMD game & VX SBS engines NOT TESTED. No imagegen concept charts in this package.
""",encoding="utf-8")
(ST/"RULES_DELTA.md").write_text("""# Localized stray-rock source fix authority
When the source of a floating pixel is *original floral body underlayer* or an old assistant-added corrective overlay, remove pixels from those exact layers and original atlas cell, not from the rock modules or entire character. Do not blindly preserve original blue-body pixels if they are proven detached floral junk (0003 Idle Back F1 x25/26 y8–11). Body preservation is spatially audited: core x8..23,y15..31 and original feet exact. 0003 Idle Back F0 was verified sound and MUST stay pixel-exact. Only F1 may differ by 18 RGBA pixel positions. Keep original timing/AnimData/Offsets/Shadow untouched and all other animation cells unchanged. Native rendering is technical QA, user still owns art acceptance.
""",encoding="utf-8")
(ST/"CURRENT_HANDOFF.md").write_text("""# CURRENT_HANDOFF P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX | 2026-10-27
User approved overall G8R4 appearance and requested ONLY stray stones at 0003 Idle Back upper right and left outside creature corrected. Absolutely no independent imagegen charts, no full batch 0002/0003 edits. Genuine source code isolated at E:\\GameAssetToolLab_20261023\\TOOLCHAIN_PILOT_20261025\\build_p3_g8r5_0003_idle_back.py. Based on prior approved G8R4 authentic PMD original atlas.
Forensics: 0003 Back F1 originals Recolored_Original_Body and Protected_Original_Frog_Body layers hold junk at x25/26 y8–11 and x4–6 y13–17; G8R4 correction overlay had added a bridge to upper right. G8R5 edits actual PMD \`Idle-Anim.png\` at direction row 4, frame1 ONLY, deleting **18** exterior junk RGB/Alpha pixels. Back F0 examined and pixel-exact unchanged; all other 30 Idle frames, Walk, remaining 10 actions, 0002, user-liked 0001 and maps unchanged. Original XML, Offsets and Shadow byte-identical; all boulders and lava edit layers pixel-exact. Corrected native Pixelorama/OpenRaster Idle_back_F1.ora full mergedimage/stack match, 0003 actual native G8R5 sheet.
G8R5 source QA and Godot XML native cold replay PASS, human art acceptance still pending; PMD game's own engine and RPG Maker VX SBS not tested. Don't confuse artificial AI illustrations with native PMD assets. Deliver ZIP, QA, preview, LOG, Drive, Github, Linear updated. Continue only if user finds remaining extra stones. All F2 map work paused.
""",encoding="utf-8")
PY=R/".venv/Scripts/python.exe"
q=subprocess.run([str(PY),str(ST/"VERIFY_G8R5.py")],capture_output=True,text=True,errors="replace",timeout=45)
(ST/"QA.log").write_text(q.stdout+"\n"+q.stderr,encoding="utf-8")
assert q.returncode==0,(q.stdout,q.stderr)
print("SOURCE QA",q.stdout[-350:],flush=True)
G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
PTH=ST/"GODOT_0003"
q=subprocess.run([str(G),"--headless","--path",str(PTH),"--import"],capture_output=True,text=True,errors="replace",timeout=80)
(PTH/"GODOT_IMPORT.log").write_text(q.stdout+"\n"+q.stderr,encoding="utf-8")
assert q.returncode==0,q.stderr[-750:]
q=subprocess.run([str(G),"--path",str(PTH),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=85)
log=q.stdout+"\n"+q.stderr
(PTH/"GODOT_XML_GPU.log").write_text(log,encoding="utf-8")
assert q.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in log and "ERROR:" not in log and "WARNING:" not in log,log[-1000:]
print("G8R5_GODOT_NATIVE_PASS",flush=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[p for p in sorted(ST.rglob("*")) if p.is_file() and ".godot" not in p.relative_to(ST).parts and p.name!="CHECKSUMS.json"]
meta=[{"file":p.relative_to(ST).as_posix(),"sha256":sha(p)} for p in files]
(ST/"CHECKSUMS.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf-8")
with zipfile.ZipFile(ZIP,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(ST.rglob("*")):
  if p.is_file() and ".godot" not in p.relative_to(ST).parts:z.write(p,p.relative_to(ST).as_posix())
with zipfile.ZipFile(ZIP) as z:assert z.testzip() is None;count=len(z.namelist())
COLD=R/"COLD_G8R5_0003_IDLE_BACK_20261027"
assert not COLD.exists()
with zipfile.ZipFile(ZIP) as z:z.extractall(COLD)
for row in meta:assert sha(COLD/row["file"])==row["sha256"],row["file"]
q=subprocess.run([str(PY),str(COLD/"VERIFY_G8R5.py")],capture_output=True,text=True,errors="replace",timeout=45)
assert q.returncode==0,(q.stdout,q.stderr)
PTH=COLD/"GODOT_0003"
q=subprocess.run([str(G),"--headless","--path",str(PTH),"--import"],capture_output=True,text=True,errors="replace",timeout=80)
assert q.returncode==0,q.stderr[-600:]
q=subprocess.run([str(G),"--path",str(PTH),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=85)
raw=q.stdout+"\n"+q.stderr
(R/"reports/P3_G8R5_0003_COLD_GODOT.log").write_text(raw,encoding="utf-8")
assert q.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in raw and "ERROR:" not in raw and "WARNING:" not in raw,raw[-750:]
print("G8R5_COLD_GODOT_PASS",flush=True)
report={"zip_path":str(ZIP),"bytes":ZIP.stat().st_size,"files":count,"sha256":sha(ZIP),
 "changed_actual_PMD_cells":1,"changed_cell":"0003 Idle back direction4 f1",
 "RGBA_pixels_changed":18,"f0_unchanged":True,
 "all_XML_Offsets_Shadow_other_actions_unchanged":True,
 "boulders_lava_untouched":True,
 "zip_CRC":"PASS","cold_SHA":"PASS","source_QA":"PASS","cold_native_Godot_XML_GPU":"PASS",
 "human_art":"PENDING","original_PMD_engine_and_VX_SBS":"NOT_TESTED",
 "maps":"PAUSED","PMD0001":"UNMODIFIED","PMD0002":"UNMODIFIED"}
(R/"reports/P3_G8R5_0003_IDLE_BACK_DELIVERY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print("G8R5_RELEASE_COMPLETE",json.dumps(report,ensure_ascii=False),flush=True)
