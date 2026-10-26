from pathlib import Path
import shutil,json,hashlib,zipfile,subprocess,xml.etree.ElementTree as ET
import numpy as np
from PIL import Image
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
U=R/"outputs/P3_G5_0003_OFFICIAL_SOURCE_20261026"
A=U/"SOURCE_0003"
B=R/"outputs/P3_G5R1_0003_RUPTURED_LAVA_CORE_20261026"
M=B/"VOLCANIC_0003"
ENGINE=R/"outputs/P3_G5R1_0003_NATIVE_XML_PLAYER_20261026"
STAGE=R/"deliveries/P3_G5R1_PMD0003_FINAL_LAVA_EVOLUTION_20261026"
ZIP=R/"deliveries/P3_G5R1_PMD0003_FINAL_LAVA_EVOLUTION_20261026.zip"
assert not STAGE.exists() and not ZIP.exists()
STAGE.mkdir(parents=True)
shutil.copytree(A,STAGE/"ORIGINAL_0003")
shutil.copytree(M,STAGE/"VOLCANIC_0003")
for name in ("project.godot","player.tscn"):
 shutil.copy2(ENGINE/name,STAGE/name)
godotscript=(ENGINE/"pmd_xml_player.gd").read_text(encoding="utf-8")
assert "original_0001" in godotscript and "rock_0001" in godotscript
godotscript=godotscript.replace("original_0001","ORIGINAL_0003").replace("rock_0001","VOLCANIC_0003")
(STAGE/"pmd_xml_player.gd").write_text(godotscript,encoding="utf-8")
P=STAGE/"PREVIEWS";P.mkdir()
for p in [B/"P3_G5_ORIGINAL_VS_0003_STAGE3_EIGHT_DIRECTIONS.png",
          B/"P3_0001_0002_0003_AUTHENTIC_EVOLUTION_CHAIN.png",
          *sorted(B.glob("*_SOURCE_VS_EVOLUTION_XML.gif"))]:
 shutil.copy2(p,P/p.name)
shutil.copy2(B/"P3_G5_0003_SOURCE_MORPH_QA.json",STAGE/"P3_G5_SOURCE_MORPH_QA.json")
shutil.copy2(U/"SOURCE_0003_MANIFEST.json",STAGE/"SOURCE_0003_MANIFEST.json")
SOURCE=STAGE/"SOURCE_SCRIPTS";SOURCE.mkdir()
for fn in ("get_p3_0003_true_source.py","build_p3_g5r1_0003_molten_core.py",
           "build_p3_g5r1_0003_previews.py","test_p3_g5r1_0003_godot_xml.py"):
 shutil.copy2(R/fn,SOURCE/fn)
(STAGE/"README.md").write_text("""# PMD 0003 G5R1 — final stage rock+fire authentic source derivative
Upstream: PMDCollab/SpriteCollab sprite/0003 original. PMD original AnimData.xml declares 14 motion names (12 real action atlases + 2 CopyOf) and 698 frame/direction/action cells. Original XML, Offsets and Shadow files remain exactly byte-identical in this bundle.
The juvenile 0001 warm orange / charcoal rock microcracks and stage2 0002 larger split basalt / hotter magma are respected. G5R1 stage3 significantly ruptures both dark jagged external rock plates and reveals a large central orange-yellow molten core. All 698 individual original sprite atlas cells were edited with real alpha silhouette changes and at least 20 orange/yellow molten pixels each. Per-sheet original dimensions, frame counts, direction rows, XML timings and lower foot region are unchanged. Negative regression on Swing edge crop was caught; first failed version archived outside release, G5R1 restores each original frame's border pixels before verifying no new edge clipping.
The PREVIEWS directory includes side-by-side original 0003 vs modified stage3 8-facing PNG, 0001→0002→0003 original-asset evolution comparison, and 3 XML-paced side-by-side GIFs. The native Godot 4.7.2 XMLParser/OpenGL bridge displays atlas poses on GPU; exact test scope documented in NATIVE_GODOT_XML_GPU_QA.log. This is NOT proof of importing original PMD GAME runtime nor RGSS2 Tankentai SBS. Human visual art gate PENDING, commercial sprite rights and attribution PENDING.
The user asked to PAUSE ALL F2 MAP WORK. This ZIP contains no map changes. Sealed F1R1 unchanged.
""",encoding="utf-8")
(STAGE/"CURRENT_HANDOFF.md").write_text("""# CURRENT_HANDOFF — P3_G5R1 PMD0003 final rock-fire evolutionary morphology
Date 2026-10-26. Maps paused by user. No F2, F1R1 SEALED, P1G or CG Pet Battle changes.
**USER STYLE-DIRECTION APPROVED PMD 0001** orange-gray juvenile microfracture. **PMD 0002 G4R1** next stage cracked basalt and larger glowing central seam TECH PASS but human ART PENDING. NEW **PMD 0003 G5R1** edited authentic separate PMDCollab sprite/0003 XML/actions: 14 names/12 actual sheets/698 original frame cells. All cells source-derived; charred dark mineral plates pulled apart around enlarged orange-yellow fully exposed molten lava core; orange-gray body aligns to lineage. Immutable original XML/Offsets/Shadow, per-action cell rectangles/rows/timings/foot shape. Native Godot GPU XML bridge TECH PASS and cold unpack tests PASS, but original PMD official loader and native RGSS2 SBS NOT TESTED. User Human Art PENDING. Fan game source attribution/licensing not established.
Initial G5 generated a 1-cell-right-edge leak on Swing dir1 frame3, marked FAIL; new G5R1 restores original cell boundary pixels and per-cell crop checks pass. Do not overwrite failure files/accepted 0001.
Next P3 gate: visual human review of entire 0001/0002/0003 family, original PMD or isolated VX SBS real loader/pivot action tests, refine ONLY if user flags it. Do not start map work without explicit user request.
""",encoding="utf-8")
(STAGE/"RULES_DELTA.md").write_text("""Stage3 PMD final evolution: separate authentic sprite/0003 source. Large exposed magma core and broken outward dark rock panels must be visibly stronger than 0002. Original 14 XML motion names, 12 real action sheets, 698 frames (NOT 0002 682). Keep XML, offsets, shadows byte-identical, original sprite sheet cell origin, timing, direction and original foot positions. No new frame-border alpha; regression Swing right edge. User approval of 0001 color DNA applies to family direction only; stage2 and stage3 human art acceptance pending. Godot bridge TECH PASS does not imply actual PMD game or VX SBS loader. F2 map work remains paused.
""",encoding="utf-8")
qa='''from pathlib import Path
import numpy as np,xml.etree.ElementTree as ET,json
from PIL import Image
root=Path(__file__).resolve().parent
o=root/"ORIGINAL_0003";m=root/"VOLCANIC_0003"
assert (o/"AnimData.xml").read_bytes()==(m/"AnimData.xml").read_bytes()
xml=ET.parse(o/"AnimData.xml").getroot()
records=xml.findall(".//Anim")
assert len(records)==14
cells=0;acts=0
for a in records:
 if a.findtext("CopyOf"):continue
 name=a.findtext("Name");w=int(a.findtext("FrameWidth"));h=int(a.findtext("FrameHeight"))
 original=np.asarray(Image.open(o/(name+"-Anim.png")).convert("RGBA"))
 new=np.asarray(Image.open(m/(name+"-Anim.png")).convert("RGBA"))
 assert original.shape==new.shape and original.shape[1]%w==0 and original.shape[0]%h==0
 assert original.shape[1]//w==len(a.find("Durations").findall("Duration"))
 for ext in ("Offsets","Shadow"):
  f=name+"-"+ext+".png"
  assert (o/f).read_bytes()==(m/f).read_bytes()
 for y in range(0,original.shape[0],h):
  for x in range(0,original.shape[1],w):
   a=original[y:y+h,x:x+w];b=new[y:y+h,x:x+w]
   assert np.count_nonzero(a[:,:,3]!=b[:,:,3])>=2,(name,x,y,"NO_MORPHOLOGY")
   for d,c in [("TOP",((b[0,:,3]>0)&(a[0,:,3]==0))),
               ("BOTTOM",((b[-1,:,3]>0)&(a[-1,:,3]==0))),
               ("LEFT",((b[:,0,3]>0)&(a[:,0,3]==0))),
               ("RIGHT",((b[:,-1,3]>0)&(a[:,-1,3]==0)))]:
    assert not np.any(c),(name,x,y,d,"NEW_CLIPPED_BORDER")
   molten=(b[:,:,0]>=220)&(b[:,:,1]>75)&(b[:,:,1]<240)&(b[:,:,2]<140)&(b[:,:,3]>0)
   assert int(np.count_nonzero(molten))>=20,(name,x,y,"CORE_INVISIBLE")
   cells+=1
 acts+=1
assert acts==12 and cells==698
print("P3_G5R1_SOURCE_QA_PASS authentic 0003: 12 action sheets, 698 modified cells, original XML/Offsets/Shadows exact, molten core, no frame edge alpha.")
'''
(STAGE/"VERIFY_SOURCE_0003.py").write_text(qa,encoding="utf-8")
(STAGE/"RUN_SOURCE_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_SOURCE_0003.py"\r\npause\r\n',encoding="ascii")
(STAGE/"RUN_NATIVE_GODOT_XML.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Godot executable path must be configured& pause& exit /b 1)
"%GODOT%" --headless --path "%~dp0" --import
"%GODOT%" --path "%~dp0" --rendering-driver opengl3 --scene res://player.tscn
pause
'''.replace("\n","\r\n"),encoding="ascii")
PY=R/".venv/Scripts/python.exe"
t=subprocess.run([str(PY),str(STAGE/"VERIFY_SOURCE_0003.py")],capture_output=True,text=True,errors="replace",timeout=45)
(STAGE/"SOURCE_QA.log").write_text(t.stdout+"\n"+t.stderr,encoding="utf-8")
assert t.returncode==0,(t.stdout,t.stderr)
G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
imp=subprocess.run([str(G),"--headless","--path",str(STAGE),"--import"],capture_output=True,text=True,errors="replace",timeout=65)
(STAGE/"GODOT_IMPORT.log").write_text(imp.stdout+"\n"+imp.stderr,encoding="utf-8")
assert imp.returncode==0,imp.stderr[-500:]
run=subprocess.run([str(G),"--path",str(STAGE),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=75)
content=run.stdout+"\n"+run.stderr
(STAGE/"NATIVE_GODOT_XML_GPU_QA.log").write_text(content,encoding="utf-8")
assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in content and "ERROR:" not in content and "WARNING:" not in content,content[-1500:]
cap=[np.asarray(Image.open(STAGE/(f"GODOT_XML_RENDER_FRAME_{j}.png")).convert("RGBA")) for j in range(3)]
assert all(np.any(cap[0]!=im) for im in cap[1:])
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
records=[{"path":x.relative_to(STAGE).as_posix(),"sha256":sha(x),"bytes":x.stat().st_size} for x in sorted(STAGE.rglob("*")) if x.is_file() and ".godot" not in x.relative_to(STAGE).parts and x.name!="CHECKSUMS.json"]
(STAGE/"CHECKSUMS.json").write_text(json.dumps(records,indent=2),encoding="utf-8")
with zipfile.ZipFile(ZIP,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for x in sorted(STAGE.rglob("*")):
  if x.is_file() and ".godot" not in x.relative_to(STAGE).parts:z.write(x,x.relative_to(STAGE).as_posix())
with zipfile.ZipFile(ZIP) as z:assert z.testzip() is None;num=len(z.infolist())
COLD=R/"COLD_P3_G5R1_PMD0003_20261026"
assert not COLD.exists()
with zipfile.ZipFile(ZIP) as z:z.extractall(COLD)
for obj in records:assert sha(COLD/obj["path"])==obj["sha256"],obj["path"]
a=subprocess.run([str(PY),str(COLD/"VERIFY_SOURCE_0003.py")],capture_output=True,text=True,errors="replace",timeout=45)
assert a.returncode==0,(a.stdout,a.stderr)
native=subprocess.run([str(G),"--path",str(COLD),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=65)
log=native.stdout+"\n"+native.stderr
(R/"reports/P3_G5R1_0003_COLD_NATIVE_LOG.txt").write_text(log,encoding="utf-8")
assert native.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in log and "ERROR:" not in log and "WARNING:" not in log,log[-1400:]
status={"zip":str(ZIP),"size":ZIP.stat().st_size,"sha256":sha(ZIP),"files":num,
 "source_pmd":"0003","upstream_XML_names":14,"actual_sheets":12,"original_cells_edited":698,
 "zip_crc":"PASS","cold_archive_SHA":"PASS","cold_source_qa":"PASS","cold_native_Godot_XML_and_GPU":"PASS",
 "user_visual":"PENDING","original_PMD_game":"NOT_TESTED","VX_Tankentai_SBS":"NOT_TESTED","maps":"PAUSED"}
(R/"reports/P3_G5R1_0003_FINAL_DELIVERY.json").write_text(json.dumps(status,ensure_ascii=False,indent=2),encoding="utf-8")
print("P3_G5R1_RELEASE",json.dumps(status,ensure_ascii=False),flush=True)
