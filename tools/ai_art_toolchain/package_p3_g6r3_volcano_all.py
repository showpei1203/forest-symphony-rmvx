from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib,zipfile,shutil,subprocess,xml.etree.ElementTree as ET
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
BASE=R/"outputs/P3_G6R3_0002_0003_BACK_VOLCANO_20261026"
ST=R/"deliveries/P3_G6R3_PMD0002_0003_BACK_VOLCANO_20261026"
Z=R/"deliveries/P3_G6R3_PMD0002_0003_BACK_VOLCANO_20261026.zip"
assert not ST.exists() and not Z.exists(),"No overwrites"
ST.mkdir(parents=True)
for dex in (2,3):
 key=f"{dex:04d}"
 O=R/f"outputs/P3_G{'4' if dex==2 else '5'}_{key}_OFFICIAL_SOURCE_20261026/SOURCE_{key}"
 MOD=BASE/f"PMD_{key}_BACK_VOLCANO"
 shutil.copytree(O,ST/f"ORIGINAL_{key}")
 shutil.copytree(MOD,ST/f"VOLCANO_{key}")
 for p in [
    BASE/f"PMD_{key}_ORIGINAL_VS_BACK_VOLCANO_ALL_FACINGS.png",
    BASE/f"PMD_{key}_Idle_SOURCE_VS_VOLCANO_XML.gif",
    BASE/f"PMD_{key}_SOURCE_QA.json"
 ]:shutil.copy2(p,ST/p.name)
 nd=ST/f"NATIVE_GODOT_{key}";nd.mkdir()
 test=BASE/f"NATIVE_GODOT_{key}"
 for p in ("project.godot","player.tscn"):
  shutil.copy2(test/p,nd/p)
 native_script=(test/"pmd_xml_player.gd").read_text(encoding="utf-8")
 native_script=native_script.replace("original_0001",f"ORIGINAL_{key}").replace("rock_0001",f"VOLCANO_{key}")
 assert "original_0001" not in native_script and "rock_0001" not in native_script
 (nd/"pmd_xml_player.gd").write_text(native_script,encoding="utf-8")
 shutil.copytree(O,nd/f"ORIGINAL_{key}")
 shutil.copytree(MOD,nd/f"VOLCANO_{key}")
 shutil.copy2(test/"GODOT_NATIVE_XML_GPU.log",nd/"GODOT_NATIVE_XML_GPU_PREPACK.log")
 shutil.copy2(test/"G6R3_NATIVE_TEST_RESULT.json",nd/"G6R3_NATIVE_TEST_RESULT.json")
 for k in range(3):shutil.copy2(test/f"GODOT_XML_RENDER_FRAME_{k}.png",nd/f"TEST_GPU_FRAME_{k}.png")
shutil.copy2(BASE/"PMD_0001_0002_0003_VOLCANO_REAL_SOURCE_EVOLUTION.png",ST)
shutil.copy2(BASE/"P3_G6_VOLCANO_RESULTS.json",ST)
for f in ("build_p3_g6r3_volcano_0002_0003.py","test_p3_g6r3_true_godot_volcano.py","prepare_p3_g6r3_dorsal_only.py"):
 shutil.copy2(R/f,ST/f)
# Static source Q/A script must run after cold ZIP independently, preserving per species native frame positions.
qa='''from pathlib import Path
from PIL import Image
import numpy as np,xml.etree.ElementTree as ET,json
r=Path(__file__).resolve().parent
totals={}
for name,expected in (("0002",682),("0003",698)):
 a=r/("ORIGINAL_"+name);b=r/("VOLCANO_"+name)
 assert (a/"AnimData.xml").read_bytes()==(b/"AnimData.xml").read_bytes()
 acts=ET.parse(a/"AnimData.xml").getroot().findall(".//Anim")
 assert len(acts)==14
 frame_count=0;alpha_morph=0;action_count=0
 for t in acts:
  if t.findtext("CopyOf"):continue
  f=t.findtext("Name");w=int(t.findtext("FrameWidth"));h=int(t.findtext("FrameHeight"))
  old=np.asarray(Image.open(a/(f+"-Anim.png")).convert("RGBA"))
  new=np.asarray(Image.open(b/(f+"-Anim.png")).convert("RGBA"))
  assert old.shape==new.shape
  assert old.shape[1]//w==len(t.find("Durations").findall("Duration")) and old.shape[0]%h==0
  for ex in ("Offsets","Shadow"):
   n=f+"-"+ex+".png"
   assert (a/n).read_bytes()==(b/n).read_bytes()
  for y in range(0,old.shape[0],h):
   for x in range(0,old.shape[1],w):
    src=old[y:y+h,x:x+w];dst=new[y:y+h,x:x+w]
    assert np.any(src!=dst),(name,f,x,y,"UNCHANGED_CELL")
    assert not(np.any((dst[0,:,3]>0)&(src[0,:,3]==0)) or np.any((dst[-1,:,3]>0)&(src[-1,:,3]==0)) or np.any((dst[:,0,3]>0)&(src[:,0,3]==0)) or np.any((dst[:,-1,3]>0)&(src[:,-1,3]==0))),(name,f,x,y,"NEW_CROP_EDGE")
    alpha_morph+=int(np.count_nonzero(dst[:,:,3]!=src[:,:,3])>=2)
    frame_count+=1
  action_count+=1
 assert frame_count==expected and action_count==12
 result=json.loads((r/("PMD_"+name+"_SOURCE_QA.json")).read_text(encoding="utf-8"))
 assert result["caldera_hot_cells"]==frame_count and result["original_xml_offsets_shadow_unchanged"]
 assert result["cells_with_2_or_more_alpha_morph_pixels"]==alpha_morph
 totals[name]={"actions":action_count,"frames":frame_count,"alpha_morph_cells":alpha_morph,"XML_OFFSETS_SHADOWS":"UNCHANGED"}
print("PMD_G6R3_COLD_SOURCE_QA_PASS",json.dumps(totals))
'''
(ST/"VERIFY_FULL_SOURCE.py").write_text(qa,encoding="utf-8")
(ST/"RUN_SOURCE_QA.cmd").write_text('@echo off\r\nset "PY=E:\\GameAssetToolLab_20261023\\TOOLCHAIN_PILOT_20261025\\.venv\\Scripts\\python.exe"\r\nif not exist "%PY%" set "PY=py -3"\r\n%PY% "%~dp0VERIFY_FULL_SOURCE.py"\r\npause\r\n',encoding="ascii")
(ST/"RUN_NATIVE_GODOT_XML.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Set correct Godot path manually first& pause& exit /b 1)
for %%N in (0002 0003) do (
 echo Testing authentic PMD %%N original XML...
 "%GODOT%" --headless --path "%~dp0NATIVE_GODOT_%%N" --import
 "%GODOT%" --path "%~dp0NATIVE_GODOT_%%N" --rendering-driver opengl3 --scene res://player.tscn
 if errorlevel 1 (echo FAIL %%N& pause& exit /b 1)
)
echo TWO SPECIES GODOT XML BRIDGE PASS; original PMD game and VX SBS NOT TESTED
pause
'''.replace("\n","\r\n"),encoding="ascii")
(ST/"README.md").write_text("""# PMD 0002 + 0003 G6R3 source-backed miniature volcano evolution.
Production, not generated art mockups: real PMDCollab/SpriteCollab original sprite/0002 and sprite/0003 action sheets in ORIGINAL_0002 and ORIGINAL_0003. The two modified folders VOLCANO_0002 (682 source frame cells) and VOLCANO_0003 (698) keep all frame placements; every XML, Offsets, Shadow binary file is identical within each original/mod pair. 12 action sheets each, 14 named XML action records each including 2 CopyOf.
0001 orange-grey rock baby unchanged (user approved style DIRECTION).
0002: smaller juvenile low cone on its BACK with narrow dark rim and small hot caldera.
0003: more developed high-backed volcanic cone, wide orange caldera, short glowing lava flows.
Failures archived in isolated working root: G6R1 was a giant mountain hiding the frog (HUMAN SELF-QA ART FAIL), G6R2 still too big, G6R3 is corrected so the animal's visible head/body and feet remain legible. Initial script failures: numpy RGBA dtype, strict Hurt red pixel bound, per-frame alpha requirement and rotated Attack absolute body pixel count; revised source-derived pose checks. Crop hard borders preserved.
Caveat: From source, certain poses have no NEW alpha silhouette because a small volcano fits entirely inside the existing source sprite silhouette; 0002 measured 309/682 altered alpha profiles, 0003 573/698. Every frame has visible material/morphology drawing and source body/foot border protection. Do not claim 100% alpha silhouette differences or official PMD engine compatibility.
Native Godot v4.7.2 XMLParser/GPU validates these actual animation atlases but does NOT certify official PMD game loader or VX Tankentai SBS. The original timing previews assume 60 ticks/sec.
Commercial redistribution or attribution rights for fan source sprites must be separately confirmed; private Drive project use only.
F2 map production remains PAUSED by user. F1R1 and accepted PMD0001 untouched.
""",encoding="utf-8")
(ST/"RULES_DELTA.md").write_text("""# G6R3 — user-approved new evolution direction
User approved: PMD0001 remains orange-gray basalt juvenile, 0002 grows a LOW volcano on back with small crater, 0003 develops a mature BACK volcano with wide lava crater and small surface flows.
Do not replace the frog's main body with a volcano. Protect face, body, foot placement and all original action cells. This exact issue was caught in G6R1/G6R2 and preserved as an ART FAIL regression.
Only build from original sprite/0002 and sprite/0003 atlas and XML, preserve 14 original XML names per, 12 genuine action sheets each, 682/698 source frames, byte identical AnimData.xml, Offsets and Shadow. Source PNG may change visibly; some alpha outlines can remain due original sprite silhouette.
PMD0002/0003 human art signoff PENDING; native Godot XML/GPU bridge TECH PASS, official PMD/VX SBS not tested. F2 map stays PAUSED.
""",encoding="utf-8")
(ST/"CURRENT_HANDOFF.md").write_text("""# CURRENT_HANDOFF PMD 0002 & 0003 back-volcano G6R3 — 2026-10-26
Production actual-source candidate G6R3: 0002 tiny growing caldera on back, 0003 larger rock+fire cone, wide open crater and lava trickles. 0001 user-liked rock baby exact original unchanged.
Source: PMDCollab/SpriteCollab original sprite/0002, sprite/0003 original XML, all 12 authentic action sheets each, 682/698 cells. Every frame modified with pixel-art volcano on BACK, original cell atlas/timings/offsets/shadows retained. Native Godot XMLParser and GPU rendered 3 different frames per character, zero errors/warnings. Original game or VX SBS target runtime PENDING. Art human gate PENDING.
CRITICAL NEGATIVE VISUAL TEST: G6R1 giant mountain mostly hid the frog; G6R2 not sufficiently small; G6R3 tightened cone region so limbs, body, head remain visible. User asked not to waste turns on plans. Every milestone requires actual source ZIP/log and Handoff. F2 map paused/SEALED FS untouched.
New production alpha outline count: 0002 309/682, 0003 573/698 have >=2 changed alpha px. Others have significant pixel changes inside original occupied outlines; do not falsely say each frame changes alpha.
NEXT: user stage2/stage3 visual check, official PMD / isolated native VX SBS proper offsets playback if meaningful, and clean image quality tweaks only with authentic sprite original. No mockup image generation.
""",encoding="utf-8")
# Stage QA and native runtime live
PY=R/".venv/Scripts/python.exe"
first=subprocess.run([str(PY),str(ST/"VERIFY_FULL_SOURCE.py")],capture_output=True,text=True,errors="replace",timeout=40)
(ST/"SOURCE_QA.log").write_text(first.stdout+"\n"+first.stderr,encoding="utf-8")
print("STAGING_QA",first.returncode,first.stdout[-220:],first.stderr[-220:],flush=True)
assert first.returncode==0
G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
for dex in (2,3):
 key=f"{dex:04d}";path=ST/f"NATIVE_GODOT_{key}"
 native=subprocess.run([str(G),"--headless","--path",str(path),"--import"],capture_output=True,text=True,errors="replace",timeout=75)
 (path/"GODOT_IMPORT_RELEASE.log").write_text(native.stdout+"\n"+native.stderr,encoding="utf-8")
 assert native.returncode==0,(key,native.stderr[-1000:])
 run=subprocess.run([str(G),"--path",str(path),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=75)
 raw=run.stdout+"\n"+run.stderr
 (path/"GODOT_NATIVE_XML_GPU_RELEASE.log").write_text(raw,encoding="utf-8")
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in raw and "ERROR:" not in raw and "WARNING:" not in raw,(key,raw[-1400:])
 caps=[np.asarray(Image.open(path/f"GODOT_XML_RENDER_FRAME_{i}.png").convert("RGBA")) for i in range(3)]
 assert all(np.any(caps[0]!=im) for im in caps[1:])
 print("NATIVE_GODOT_RELEASE_PASS",key,flush=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
paths=[p for p in ST.rglob("*") if p.is_file() and ".godot" not in p.relative_to(ST).parts and p.name!="CHECKSUMS.json"]
hashes=[{"path":p.relative_to(ST).as_posix(),"sha256":sha(p),"bytes":p.stat().st_size} for p in sorted(paths)]
(ST/"CHECKSUMS.json").write_text(json.dumps(hashes,indent=2),encoding="utf-8")
with zipfile.ZipFile(Z,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as f:
 for p in sorted(ST.rglob("*")):
  if p.is_file() and ".godot" not in p.relative_to(ST).parts:f.write(p,p.relative_to(ST).as_posix())
with zipfile.ZipFile(Z) as f:assert f.testzip() is None;items=len(f.infolist())
COLD=R/"COLD_PMD_G6R3_BACK_VOLCANO_20261026";assert not COLD.exists()
with zipfile.ZipFile(Z) as f:f.extractall(COLD)
for a in hashes:assert sha(COLD/a["path"])==a["sha256"],a["path"]
cold=subprocess.run([str(PY),str(COLD/"VERIFY_FULL_SOURCE.py")],capture_output=True,text=True,errors="replace",timeout=40)
assert cold.returncode==0,cold.stderr
for dex in (2,3):
 key=f"{dex:04d}";p=COLD/f"NATIVE_GODOT_{key}"
 x=subprocess.run([str(G),"--headless","--path",str(p),"--import"],capture_output=True,text=True,errors="replace",timeout=75)
 assert x.returncode==0,(key,x.stderr[-700:])
 a=subprocess.run([str(G),"--path",str(p),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=75)
 raw=a.stdout+"\n"+a.stderr
 (R/f"reports/P3_G6R3_COLD_GODOT_{key}.log").write_text(raw,encoding="utf-8")
 assert a.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in raw and "ERROR:" not in raw and "WARNING:" not in raw,(key,raw[-1000:])
 print("COLD_GODOT_PASS",key,flush=True)
delivery={"zip":str(Z),"bytes":Z.stat().st_size,"sha256":sha(Z),"files":items,
 "original_sheets_per_species":12,"source_0002_frames":682,"source_0003_frames":698,
 "source_alpha_changed":{"0002":309,"0003":573},
 "source_all_frames_material_changed":1380,
 "zip_CRC":"PASS","cold_SHA":"PASS","cold_source_QA":"PASS","cold_native_Godot_XML_GPU_both":"PASS",
 "human_art":"PENDING","official_PMD_and_VX_SBS":"NOT_TESTED","maps":"PAUSED"}
(R/"reports/P3_G6R3_BACK_VOLCANO_DELIVERY.json").write_text(json.dumps(delivery,ensure_ascii=False,indent=2),encoding="utf-8")
print("DELIVERED_P3_G6R3",json.dumps(delivery,ensure_ascii=False),flush=True)
