from pathlib import Path
import shutil,json,hashlib,zipfile,subprocess,xml.etree.ElementTree as ET
import numpy as np
from PIL import Image
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
O=R/"outputs/P3_G4_0002_OFFICIAL_SOURCE_20261026"
B=R/"outputs/P3_G4R1_0002_VOLCANIC_EVOLUTION_20261026"
RUN=R/"outputs/P3_G4R1_0002_NATIVE_XML_PLAYER_20261026"
ST=R/"deliveries/P3_G4R1_PMD0002_VOLCANIC_STAGE2_20261026"
ZIP=R/"deliveries/P3_G4R1_PMD0002_VOLCANIC_STAGE2_20261026.zip"
assert not ST.exists() and not ZIP.exists()
ST.mkdir(parents=True)
shutil.copytree(O/"SOURCE_0002",ST/"ORIGINAL_0002")
shutil.copytree(B/"VOLCANIC_0002",ST/"VOLCANIC_0002")
for name in ("project.godot","player.tscn"):
 shutil.copy2(RUN/name,ST/name)
script=(RUN/"pmd_xml_player.gd").read_text(encoding="utf-8")
script=script.replace("original_0001","ORIGINAL_0002").replace("rock_0001","VOLCANIC_0002")
assert "original_0001" not in script and "rock_0001" not in script
(ST/"pmd_xml_player.gd").write_text(script,encoding="utf-8")
P=ST/"PREVIEWS";P.mkdir()
for file in [B/"P3_G4_0002_ORIGINAL_VS_LAVA_ALL_DIR.png",B/"PMD_EVOLUTION_0001_0002_REAL_SPRITES.png",
            *B.glob("*_ORIGINAL_VS_VOLCANIC_XML.gif")]:
 shutil.copy2(file,P/file.name)
(ST/"SOURCE_0002_MANIFEST.json").write_bytes((O/"SOURCE_0002_MANIFEST.json").read_bytes())
(ST/"P3_G4R1_0002_MORPH_QA.json").write_bytes((B/"P3_G4_0002_MORPH_QA.json").read_bytes())
S=ST/"SCRIPTS";S.mkdir()
for name in ("get_p3_0002_true_source.py","build_p3_g4r1_0002_volcanic.py",
             "build_p3_g4r1_0002_previews.py","test_p3_g4r1_0002_godot_xml.py"):
 shutil.copy2(R/name,S/name)
(ST/"README.md").write_text("""# PMD 0002 — G4R1 Stage-2 volcanic evolution source candidate
Based on actual official-format PMDCollab/SpriteCollab sprite/0002 original assets: 37 source XML/PNG metadata/image files. Original XML defines 14 action names, 12 actual image actions and 682 action/direction/frame cells. No assumption that 0002 has 0001's 34 actions or 1123 frames.
VOLCANIC_0002 is a true original-source derivative edited across **all 682 cells**: plant-green leaves transformed into two prominent angular black/gray basalt plates, a much wider exposed bright orange magma fissure than the approved PMD 0001 juvenile; frog body warmed toward the orange-ash scheme. Actual alpha silhouette changes in all frames. The original XML, -Offsets.png, -Shadow.png remain BYTE-FOR-BYTE UNCHANGED from ORIGINAL_0002, source frame rectangles/durations/rows/footpoint unchanged.
The included 3 GIFs provide side-by-side original + derivative frames with XML duration mapping assuming 60 ticks/second; all 8 directions shown. PREVIEWS also include 0001 stage1 vs 0002 stage2 authentic source sprite comparison.
RUN_NATIVE_GODOT_XML.cmd invokes native Godot 4.7.2 bridge, parses source AnimData.xml and loads the new original-format atlases. Actual Godot player/GPU is TECH PASS, but this is NOT the original PMD game engine and NOT RPG Maker VX Tankentai SBS compatibility proof. User Human Visual approval remains PENDING; commercial fan-asset contributor rights and credit need separate permission review.
Original bad G4 self-review candidate was too beige; G4R1 uses more orange body shading. All earlier F2 map work is PAUSED per user directive, original accepted F1R1 remains sealed.
""",encoding="utf-8")
(ST/"CURRENT_HANDOFF.md").write_text("""# CURRENT_HANDOFF — P3 G4R1 stage2 PMD0002 rock + magma, map paused
User ordered **PAUSE ALL F2 MAP PRODUCTION**. Do not modify map, actor-scale Gate G5R4, Ground/PAR, F1R1 or use image_gen for PMD atlas. Future work is P3 only until user unpauses.
PMD 0001 G3R1 visual DIRECTION approved: orange+gray juvenile basalt shell, narrow magma glow, full 34 action source derivative 1123 original frame positions. Stage2 **PMD0002 G4R1** uses source SpriteCollab sprite/0002 and own original XML: 14 named XML actions including 2 CopyOf, 12 genuine actions, 682 frames. Every frame source derived: angular thicker dark gray split volcanic shell plus wider orange hot lava center, warmer orange-gray body. All per-action filenames, original canvas/frame cells, sprite lower foot anchor, XML/Offsets/Shadow exact immutable. Native Godot XMLParser and GPU testing error-free and cold-retest PASS. Original PMD game loader and actual VX Tankentai SBS, commercial rights, user stage2 art approval remain PENDING.
Saved the bad filecount assumption FAIL (>60 source files) then corrected to real 37 files; no false import from 0001. Self-review found initial stage2 body too beige; archived G4 then made G4R1 warm orange.
NEXT P3 stage2: human review PNG/GIF; refine rock shell if needed while preserving entire original 0002 action sheet positions. When approved, begin authentic PMD 0003 original source, larger shell fragments and exposed core (rock+fire final stage), with its own XML/frame layout; do not fabricate one mega sprite atlas and call XML compatible.
""",encoding="utf-8")
(ST/"RULES_DELTA.md").write_text("""# Stage2 evolution / scope lock
Map: user explicitly PAUSED. F2 all remaining gates frozen. PMD next production only.
0001 orange/gray juvenile rock with thin glowing cracks USER APPROVED VISUAL DIRECTION. 0002 must have bigger dark basalt plates and a noticeably wider exposed hot magma core while retaining same orange/gray family feeling; 0003 later will show rock shell broken widely open.
Each numbered PMD creature uses ITS OWN authentic source XML and spritesheets: 0001 had 34 actual actions/1123 cells, 0002 actually 12 actual actions/682 cells. Never assume action sets match. Preserve all action names, file structure, frame grid, original XML durations, offsets and shadows; segment morphology within original frame rectangles and keep foot contact.
Real Godot bridge parser/GPU TECH PASS is not original PMD game or RGSS2 SBS. Explicit USER VISUAL acceptance required before sealing. Keep source code, ZIP/CMD/LOG/Handoff and Drive/GitHub/Linear. No generated raster mockups as actual production sprites.
""",encoding="utf-8")
verify='''from pathlib import Path
import xml.etree.ElementTree as ET,json,numpy as np
from PIL import Image
import hashlib
r=Path(__file__).resolve().parent
a=r/"ORIGINAL_0002";b=r/"VOLCANIC_0002"
assert a.joinpath("AnimData.xml").read_bytes()==b.joinpath("AnimData.xml").read_bytes()
metadata=json.loads((r/"SOURCE_0002_MANIFEST.json").read_text(encoding="utf-8"))
assert len(metadata["actions"])==14
count=0;actions=0;morph=0
for z in ET.parse(a/"AnimData.xml").getroot().findall(".//Anim"):
 if z.findtext("CopyOf"):continue
 name=z.findtext("Name");w=int(z.findtext("FrameWidth"));h=int(z.findtext("FrameHeight"))
 src=np.asarray(Image.open(a/(name+"-Anim.png")).convert("RGBA"))
 dst=np.asarray(Image.open(b/(name+"-Anim.png")).convert("RGBA"))
 assert src.shape==dst.shape and src.shape[1]%w==0 and src.shape[0]%h==0
 for ending in ("Offsets","Shadow"):
  fn=name+"-"+ending+".png"
  assert a.joinpath(fn).read_bytes()==b.joinpath(fn).read_bytes()
 for yy in range(0,src.shape[0],h):
  for xx in range(0,src.shape[1],w):
   old=src[yy:yy+h,xx:xx+w];new=dst[yy:yy+h,xx:xx+w]
   assert np.any(old[:,:,3]!=new[:,:,3]),(name,xx,yy,"NO_MORPH")
   assert not (np.any(new[0,:,3]) and not np.any(old[0,:,3])),(name,xx,yy,"CROP_TOP")
   assert not (np.any(new[-1,:,3]) and not np.any(old[-1,:,3])),(name,xx,yy,"CROP_BOTTOM")
   assert not (np.any(new[:,0,3]) and not np.any(old[:,0,3])),(name,xx,yy,"CROP_LEFT")
   assert not (np.any(new[:,-1,3]) and not np.any(old[:,-1,3])),(name,xx,yy,"CROP_RIGHT")
   orange=(new[:,:,0]>=225)&(new[:,:,1]>=75)&(new[:,:,1]<215)&(new[:,:,2]<110)&(new[:,:,3]>0)
   assert orange.sum()>=5,(name,xx,yy,"MAGMA_MISSING")
   morph+=1;count+=1
 actions+=1
assert actions==12 and count==682 and morph==682
print("P3_G4R1_SOURCE_QA_PASS 14 XML names, 12 real action sheets, 682 individual frames; original XML/offsets/shadows exact; visual human pending")
'''
(ST/"VERIFY_P3_G4R1.py").write_text(verify,encoding="utf-8")
(ST/"RUN_SOURCE_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_P3_G4R1.py"\r\npause\r\n',encoding="ascii")
(ST/"RUN_NATIVE_GODOT_XML.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Configure native Godot path first& pause& exit /b 1)
"%GODOT%" --headless --path "%~dp0" --import
"%GODOT%" --path "%~dp0" --rendering-driver opengl3 --scene res://player.tscn
pause
'''.replace("\n","\r\n"),encoding="ascii")
py=R/".venv/Scripts/python.exe"
first=subprocess.run([str(py),str(ST/"VERIFY_P3_G4R1.py")],capture_output=True,text=True,errors="replace",timeout=55)
(ST/"SOURCE_QA.log").write_text(first.stdout+"\n"+first.stderr,encoding="utf-8")
assert first.returncode==0,(first.stdout,first.stderr)
# Actual Godot run with proper 0002 folder names rather than confusing 0001 alias
G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
imp=subprocess.run([str(G),"--headless","--path",str(ST),"--import"],capture_output=True,text=True,errors="replace",timeout=90)
(ST/"GODOT_IMPORT.log").write_text(imp.stdout+"\n"+imp.stderr,encoding="utf-8")
assert imp.returncode==0,imp.stderr[-1100:]
native=subprocess.run([str(G),"--path",str(ST),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=75)
native_log=native.stdout+"\n"+native.stderr
(ST/"NATIVE_GODOT_XML_GPU_QA.log").write_text(native_log,encoding="utf-8")
assert native.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in native_log and "ERROR:" not in native_log and "WARNING:" not in native_log,native_log[-1600:]
frames=[np.asarray(Image.open(ST/(f"GODOT_XML_RENDER_FRAME_{x}.png")).convert("RGBA")) for x in range(3)]
assert all(np.any(frames[0]!=a) for a in frames[1:])
# ZIP includes reproducible source and actual engine screenshot evidence, excludes cached .godot
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
entries=[f for f in sorted(ST.rglob("*")) if f.is_file() and ".godot" not in f.relative_to(ST).parts and f.name!="CHECKSUMS.json"]
manifest=[{"name":x.relative_to(ST).as_posix(),"sha256":sha(x),"bytes":x.stat().st_size} for x in entries]
(ST/"CHECKSUMS.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
with zipfile.ZipFile(ZIP,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(ST.rglob("*")):
  if p.is_file() and ".godot" not in p.relative_to(ST).parts:
   z.write(p,p.relative_to(ST).as_posix())
with zipfile.ZipFile(ZIP) as z:assert z.testzip() is None;n=len(z.infolist())
C=R/"COLD_P3_G4R1_0002_20261026"
assert not C.exists()
with zipfile.ZipFile(ZIP) as z:z.extractall(C)
for obj in manifest:
 assert sha(C/obj["name"])==obj["sha256"],obj["name"]
t=subprocess.run([str(py),str(C/"VERIFY_P3_G4R1.py")],capture_output=True,text=True,errors="replace",timeout=55)
assert t.returncode==0,(t.stdout,t.stderr)
native_cold=subprocess.run([str(G),"--path",str(C),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=75)
coldlog=native_cold.stdout+"\n"+native_cold.stderr
(R/"reports/P3_G4R1_0002_COLD_NATIVE_LOG.txt").write_text(coldlog,encoding="utf-8")
assert native_cold.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in coldlog and "ERROR:" not in coldlog and "WARNING:" not in coldlog,coldlog[-1400:]
result={"release":str(ZIP),"bytes":ZIP.stat().st_size,"sha256":sha(ZIP),
"files":n,"crc":"PASS","cold_SHA":"PASS","cold_source":"PASS","cold_Godot_XML_GPU":"PASS",
"source_XML_actions":14,"real_actions":12,"original_frames_modified":682,
"human_style":"PENDING","original_pmd_runtime":"NOT_TESTED","VX_SBS":"NOT_TESTED","map":"PAUSED"}
(R/"reports/P3_G4R1_0002_DELIVERY.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
print("P3_G4R1_DELIVERY",json.dumps(result,ensure_ascii=False),flush=True)
