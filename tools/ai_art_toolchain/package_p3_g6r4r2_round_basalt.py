from pathlib import Path
from PIL import Image
import numpy as np, json,hashlib,shutil,subprocess,zipfile,xml.etree.ElementTree as ET
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
A=R/"outputs/P3_G6R4R2_0002_0003_ROUNDED_SWAY_STONES_20261026"
T=R/"deliveries/P3_G6R4R2_ROUND_BASALT_PMD0002_0003_20261026"
Z=R/"deliveries/P3_G6R4R2_ROUND_BASALT_PMD0002_0003_20261026.zip"
assert not T.exists() and not Z.exists()
T.mkdir(parents=True)
for species in ("0002","0003"):
 o=R/f"outputs/P3_G{'4' if species=='0002' else '5'}_{species}_OFFICIAL_SOURCE_20261026/SOURCE_{species}"
 m=A/f"PMD_{species}_ROUND_STONES"
 shutil.copytree(o,T/f"ORIGINAL_{species}")
 shutil.copytree(m,T/f"ROUND_BASALT_{species}")
 native=A/f"NATIVE_GODOT_{species}"
 dest=T/f"NATIVE_GODOT_{species}"
 dest.mkdir()
 for p in ("project.godot","player.tscn"):shutil.copy2(native/p,dest/p)
 gd=(native/"pmd_xml_player.gd").read_text(encoding="utf-8")
 # The native engine's source path aliases are harmless but renamed for readability in release.
 gd=gd.replace("original_0001",f"ORIGINAL_{species}").replace("rock_0001",f"ROUND_BASALT_{species}")
 (dest/"pmd_xml_player.gd").write_text(gd,encoding="utf-8")
 shutil.copytree(o,dest/f"ORIGINAL_{species}")
 shutil.copytree(m,dest/f"ROUND_BASALT_{species}")
 for fn in ("NATIVE_GPU.log","RESULT.json","IMPORT.log"):
  shutil.copy2(native/fn,dest/fn)
 for k in range(3):shutil.copy2(native/f"GODOT_XML_RENDER_FRAME_{k}.png",dest/f"GODOT_XML_RENDER_FRAME_{k}.png")
 shutil.copy2(A/f"PMD_{species}_ROUND_STONES_QA.json",T/f"PMD_{species}_ROUND_STONES_QA.json")
P=T/"PREVIEWS";P.mkdir()
for p in [*A.glob("*.png"),*A.glob("*.gif")]:shutil.copy2(p,P/p.name)
SC=T/"SCRIPTS";SC.mkdir()
for f in ("build_p3_g6r4r2_rounded_rocks.py","make_p3_g6r4r2_animation_previews.py",
          "test_p3_g6r4r2_volcanic_round_stones.py","prepare_g6r4r2.py"):
 shutil.copy2(R/f,SC/f)
(T/"README.md").write_text("""# P3 G6R4R2 REAL PMD SOURCE — Petal Motion, Round Basalt Morphology
Actual PMDCollab/SpriteCollab source-derived 0002 and 0003 full animation spritesheets. No generated illustrations. Each of the 12 original action sheets per species and all 682 (0002) / 698 (0003) atlas positions edited to REPLACE the flower/plant form with SEPARATE ROUND BASALT ROCKS: 0002 three rounded stones surrounding a small hot vent; 0003 five larger/layered stones surrounding a stronger molten crater with small overflow. Warm orange and slate gray body/rocks family motif; user-liked 0001 G3R1 NOT EDITED.
The core request was to preserve the ORIGINAL flower sway. Each original frame records the actual leaf-petal centroid and left/right group positions. Round stone positions are derived from ORIGINAL PER-FRAME centroid positions with the original untouched XML duration/rows. Native source-motion QA reports 0002 88/88 and 0003 89/89 action-direction source motion cases followed; see QA JSON.
The original AnimData.xml and ALL offsets/shadows byte-identical for each species. EXACT original sheet dimensions/cell positions; original action and frame counts, 14 names with 2 CopyOf, 12 image actions. Foot alpha and frame-boundary clipping preserved. All cells have meaningful material/pixel changes and lava. Full GIFs Idle/Walk/Attack compare original and round basalt for 8 directions, timing assumed at 60 ticks/sec solely for preview.
R4 SELF-REVIEW detected remnant dark flower outline flecks over 0003. R4R1 and R4R2 cleaned isolated remnants while preserving rock motion/source borders. Original PMD game loader and VX Tankentai SBS have NOT BEEN TESTED; actual Godot XMLParser/OpenGL GPU for both passed with 0 ERROR/WARNING. User Human Art acceptance PENDING. SpriteCollab third-party asset rights and redistribution/commercial use NOT VERIFIED. Private Drive project distribution only.
FS maps remain PAUSED per user; sealed baseline untouched.
""",encoding="utf-8")
(T/"RULES_DELTA.md").write_text("""# G6R4R2 mandatory art pipeline rule
0001 remains the user-liked orange/gray juvenile basalt shell untouched. In 0002 and 0003 flower/petal replacement means TRUE round rock components, not flat gray recolored petals, rigid triangular volcano shell or independent animation motion.
- 0002 uses 3 small rounded uneven boulders around a low dark crater with minor magma.
- 0003 uses 5 thicker round stone units around a broader magma crater and a short lava runoff.
- Extract actual original leaf-tip / flower centroid from each source frame and position boulders in that frame. Preserve actual original action timings XML, facing, shadow, offsets, atlas cell dimensions and entire layout.
- Check each source-movement direction also has edited boulder movement: 0002 88/88; 0003 89/89.
- Preserve source character's face and feet. No old petals/outlines should float above rock cluster; validate no added alpha border pixels. Error R4 top flecks and earlier giant volcano silhouette G6R1/G6R2 recorded.
- User final Visual ART gate pending. Godot bridge source/GPU QA is not the original PMD or RGSS2 VX SBS runtime; licensing not established.
- Maps remain PAUSED.
""",encoding="utf-8")
(T/"CURRENT_HANDOFF.md").write_text("""# CURRENT_HANDOFF — P3 G6R4R2 rounded-rock / original petal sway
2026-10-26 | Maps F2 remain PAUSED; accepted F1R1 A04 and PMD 0001 G3R1 remain UNTOUCHED.
Actual fresh PMDCollab \`sprite/0002\`, \`sprite/0003\`, 14 original XML action names each, 12 image actions per, 682/698 action-facings/frame slots. Rebuilt EACH source sheet directly; 0002 3 discrete rounded gray basalt boulders, 0003 5 larger rounded boulders around darker central lava opening. No petal color leftovers in edited source mask. Sway is per-frame derived from original leaf/bud positions rather than simulated arbitrary oscillations. True original XML, offsets and shadow bit-identical, frame coordinates and durations unchanged.
QA all 1380 frames changed actual pixels, each has >=2 hot lava pixels. Source-motion checks: 0002 88/88, 0003 89/89 action-direction cases with original flower centroid changes also have round-boulder changes. Real Godot 4.7.2 original XMLParser + GPU displays changed frames, 0 ERROR/WARNING for both; full ZIP cold extraction and native rerun should be reverified each release. Original PMD game runtime and native VX Tankentai SBS compatibility NOT TESTED. User human art gate PENDING.
Self-corrections: prior G6R3 volcano still visually looked like colored petals; G6R4 transformed petals to separate round boulders; initial G6R4 0003 contained detached original flower-outline pixels near top, G6R4R1 and G6R4R2 cleaned source remnant specks, archived earlier candidates. Do not present new generated mockups for actual source previews.
NEXT: visual user review, then genuine target-native action/offset/shadow test. F2/F1 map production frozen.
""",encoding="utf-8")
VERIFY='''from pathlib import Path
import json,numpy as np,xml.etree.ElementTree as ET
from PIL import Image
R=Path(__file__).resolve().parent
for sp,expected,expected_sway in (("0002",682,88),("0003",698,89)):
 O=R/("ORIGINAL_"+sp);M=R/("ROUND_BASALT_"+sp)
 assert (O/"AnimData.xml").read_bytes()==(M/"AnimData.xml").read_bytes()
 records=ET.parse(O/"AnimData.xml").getroot().findall(".//Anim")
 assert len(records)==14
 motion=json.loads((R/("PMD_"+sp+"_ROUND_STONES_QA.json")).read_text(encoding="utf-8"))
 cells=0;real_actions=0;sway=0
 for t in records:
  if t.findtext("CopyOf"):continue
  act=t.findtext("Name");w=int(t.findtext("FrameWidth"));h=int(t.findtext("FrameHeight"))
  old=np.asarray(Image.open(O/(act+"-Anim.png")).convert("RGBA"))
  new=np.asarray(Image.open(M/(act+"-Anim.png")).convert("RGBA"))
  assert old.shape==new.shape
  assert old.shape[1]//w==len(t.find("Durations").findall("Duration")) and old.shape[0]%h==0
  for suffix in ("Offsets","Shadow"):
   f=act+"-"+suffix+".png"
   assert (O/f).read_bytes()==(M/f).read_bytes()
  history=next(q for q in motion["record"] if q["action"]==act)
  assert len(history["motion_instances"])==old.shape[1]//w*old.shape[0]//h
  for q in history["motion_instances"]:
   row,col=q["direction"],q["frame"]
   A=old[row*h:(row+1)*h,col*w:(col+1)*w]
   B=new[row*h:(row+1)*h,col*w:(col+1)*w]
   assert np.any(A!=B) and np.array_equal(A[-4:,:,3],B[-4:,:,3])
   assert len(q["rounded_boulders"])==(3 if sp=="0002" else 5)
   assert q["lava_pixels"]>=2
   assert not(np.any((B[0,:,3]>0)&(A[0,:,3]==0)) or np.any((B[-1,:,3]>0)&(A[-1,:,3]==0)) or np.any((B[:,0,3]>0)&(A[:,0,3]==0)) or np.any((B[:,-1,3]>0)&(A[:,-1,3]==0)))
   cells+=1
  for face in range(8):
   frames=[z for z in history["motion_instances"] if z["direction"]==face]
   if len(frames)<2:continue
   start={tuple(z["source_original_flower_centroid"]) for z in frames}
   end={tuple(tuple(t) for t in z["rounded_boulders"]) for z in frames}
   if len(start)>1:
    assert len(end)>1,(sp,act,face,"SOURCE_SWAY_NOT_FOLLOWED")
    sway+=1
  real_actions+=1
 assert cells==expected and real_actions==12 and sway==expected_sway,(sp,cells,real_actions,sway)
 print("PASS_ROUND_BASALT",sp,"SHEETS",real_actions,"CELLS",cells,"SWAY",sway,"XML_OFFSETS_SHADOW","ORIGINAL")
'''
(T/"VERIFY_SOURCE_AND_SWAY.py").write_text(VERIFY,encoding="utf-8")
(T/"RUN_SOURCE_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_SOURCE_AND_SWAY.py"\r\npause\r\n',encoding="ascii")
(T/"RUN_NATIVE_GODOT_XML.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Set installed Godot path first& pause& exit /b 1)
for %%I in (0002 0003) do (
 "%GODOT%" --headless --path "%~dp0NATIVE_GODOT_%%I" --import
 if errorlevel 1 exit /b 1
 "%GODOT%" --path "%~dp0NATIVE_GODOT_%%I" --rendering-driver opengl3 --scene res://player.tscn
 if errorlevel 1 exit /b 1
)
echo Godot XML bridge PASS for both. Actual PMD game / VX SBS NOT TESTED.
pause
'''.replace("\n","\r\n"),encoding="ascii")
py=R/".venv/Scripts/python.exe"
g=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
p=subprocess.run([str(py),str(T/"VERIFY_SOURCE_AND_SWAY.py")],capture_output=True,text=True,errors="replace",timeout=50)
(T/"SOURCE_AND_SWAY_QA.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf-8")
assert p.returncode==0,(p.stdout,p.stderr)
print("STAGE_SOURCE",p.stdout[-400:],flush=True)
for species in ("0002","0003"):
 folder=T/f"NATIVE_GODOT_{species}"
 imp=subprocess.run([str(g),"--headless","--path",str(folder),"--import"],capture_output=True,text=True,errors="replace",timeout=90)
 (folder/"RELEASE_IMPORT.log").write_text(imp.stdout+"\n"+imp.stderr,encoding="utf-8")
 assert imp.returncode==0,(species,imp.stderr[-1000:])
 run=subprocess.run([str(g),"--path",str(folder),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=85)
 msg=run.stdout+"\n"+run.stderr
 (folder/"RELEASE_NATIVE_GPU.log").write_text(msg,encoding="utf-8")
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in msg and "ERROR:" not in msg and "WARNING:" not in msg,(species,msg[-1800:])
 print("STAGE_NATIVE_XML_GPU",species,"PASS",flush=True)
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
entries=[f for f in sorted(T.rglob("*")) if f.is_file() and ".godot" not in f.relative_to(T).parts and f.name!="CHECKSUMS.json"]
listings=[{"file":f.relative_to(T).as_posix(),"sha256":digest(f)} for f in entries]
(T/"CHECKSUMS.json").write_text(json.dumps(listings,indent=2),encoding="utf-8")
with zipfile.ZipFile(Z,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in sorted(T.rglob("*")):
  if f.is_file() and ".godot" not in f.relative_to(T).parts:z.write(f,f.relative_to(T).as_posix())
with zipfile.ZipFile(Z) as z:assert z.testzip() is None;num=len(z.infolist())
C=R/"COLD_P3_G6R4R2_ROUND_BASALT_20261026"
assert not C.exists()
with zipfile.ZipFile(Z) as z:z.extractall(C)
for item in listings:assert digest(C/item["file"])==item["sha256"]
p=subprocess.run([str(py),str(C/"VERIFY_SOURCE_AND_SWAY.py")],capture_output=True,text=True,errors="replace",timeout=50)
assert p.returncode==0,(p.stdout,p.stderr)
for species in ("0002","0003"):
 folder=C/f"NATIVE_GODOT_{species}"
 imp=subprocess.run([str(g),"--headless","--path",str(folder),"--import"],capture_output=True,text=True,errors="replace",timeout=80)
 assert imp.returncode==0,(species,imp.stderr[-300:])
 run=subprocess.run([str(g),"--path",str(folder),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=80)
 raw=run.stdout+"\n"+run.stderr
 (R/f"reports/P3_G6R4R2_COLD_GODOT_{species}.log").write_text(raw,encoding="utf-8")
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in raw and "ERROR:" not in raw and "WARNING:" not in raw,(species,raw[-1400:])
 print("COLD_XML_GPU",species,"PASS",flush=True)
result={"zip":str(Z),"bytes":Z.stat().st_size,"sha256":digest(Z),"members":num,
"edited_cells":{"0002":682,"0003":698},"actual_original_sway_directions_followed":{"0002":88,"0003":89},
"rounded_stone_count":{"0002":3,"0003":5},"original_xml_offsets_shadow":"BYTE_IDENTICAL",
"zip_CRC":"PASS","cold_SHA":"PASS","cold_source_sway_QA":"PASS","cold_godot_XML_GPU_both":"PASS",
"human_style":"PENDING","actual_PMD_and_VX_SBS":"NOT_TESTED","maps":"PAUSED"}
(R/"reports/P3_G6R4R2_ROUND_BASALT_DELIVERY.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
print("G6R4R2_DELIVERY",json.dumps(result,ensure_ascii=False),flush=True)
