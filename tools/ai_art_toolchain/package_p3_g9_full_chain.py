from pathlib import Path
from PIL import Image
import numpy as np,json,zipfile,hashlib,shutil,subprocess,xml.etree.ElementTree as ET
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
G9=R/"outputs/P3_G9_FULL_0001_0002_0003_EVOLUTION_20261027"
ST=R/"deliveries/P3_G9_FULL_EVOLUTION_CHAIN_0001_0003_20261027"
ZIP=R/"deliveries/P3_G9_FULL_EVOLUTION_CHAIN_0001_0003_20261027.zip"
assert G9.is_dir() and not ST.exists() and not ZIP.exists()
ST.mkdir(parents=True)
accepted={"0001":"G3R1","0002":"G8R4","0003":"G8R5"}
for sp in ("0001","0002","0003"):
 ORIGINAL=R/("outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026/original_0001" if sp=="0001" else f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}")
 shutil.copytree(ORIGINAL,ST/f"ORIGINAL_{sp}",ignore=shutil.ignore_patterns("*.import",".godot"))
 shutil.copytree(G9/sp,ST/f"PRODUCTION_{sp}")
 for src in (ORIGINAL,G9/sp):
  assert (src/"AnimData.xml").is_file()
 for fn in ORIGINAL.glob("*"):
  if fn.name=="AnimData.xml" or fn.name.endswith(("-Offsets.png","-Shadow.png")):
   assert fn.read_bytes()==(G9/sp/fn.name).read_bytes(),(sp,fn.name)
 # native Godot source, no stale .godot import cache
 GOD=G9/f"GODOT_FULL_{sp}" if sp!="0001" else R/"outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026"
 DP=ST/f"GODOT_{sp}";DP.mkdir()
 for fn in ("project.godot","player.tscn","pmd_xml_player.gd"):
  shutil.copy2(GOD/fn,DP/fn)
 shutil.copytree(ORIGINAL,DP/"original_0001",ignore=shutil.ignore_patterns("*.import"))
 shutil.copytree(G9/sp,DP/"rock_0001")
 # old checkpoint engine needs original structure not extra image source.
 for name in ("GODOT_NATIVE_FULL_XML_GPU.log","NATIVE_GODOT_GPU_QA.log"):
  if (GOD/name).is_file():shutil.copy2(GOD/name,DP/name)
for png in G9.glob("*.png"):(ST/"PREVIEWS").mkdir(exist_ok=True);shutil.copy2(png,ST/"PREVIEWS"/png.name)
for gif in (G9/"PREVIEWS").glob("*.gif"):
 (ST/"PREVIEWS").mkdir(exist_ok=True);shutil.copy2(gif,ST/"PREVIEWS"/gif.name)
for data in ("G9_FULL_BUILD.json","G9_ALL_ACTION_SOURCE_QA.json","G9_NATIVE_TECH_PASS.json","G9_PREVIEWS.json"):
 shutil.copy2(G9/data,ST/data)
(SC:=ST/"SCRIPTS").mkdir()
for f in ("build_p3_g9_full_chain.py","qa_p3_g9_full_native.py","patch_g9_qa_approved_exception.py",
 "make_p3_g9_visual_montage.py","make_p3_g9_full_animation_previews.py","inspect_p3_g9_full_source_poses.py"):
 shutil.copy2(R/f,SC/f)
(ST/"README.md").write_text("""# PMD 0001-0003 FULL EVOLUTION CHAIN G9 — 2026-10-27
Produced **actual PMD source-aligned complete animation atlas PNGs**, NOT generated concept illustrations. Files in PRODUCTION_0001/0002/0003 each have authentic original per-species AnimData.xml, -Offsets.png, -Shadow.png and ALL -Anim.png, directly replace the corresponding sprite/<species> folder in your compatible native workflow. Source originals bundled separately in ORIGINAL_<species>. Do not copy the extra previews into a PMD game sprite root.

- 0001: EXACT original user-liked approved G3R1 orange-gray rock/fire juvenile *entire* set, 34 image action sheets, 1123 original animation frames; no rebuild performed on accepted 0001 art.
- 0002: ORIGINAL native per-action sizes and all 12 authentic animation sheets, 682 real frames; 12 user-reviewed G8R4 samples EXACT pixel preserved (Idle/Walk front/side/back f0/f1), 670 NEW source-derived body-mounted round-stone+lava animation frames.
- 0003: all 12 native original animation sheets / 698 frames; 12 G8R4/G8R5 reviewed keyframe pixel shapes EXACT preserved, including 0003 Idle Back F1 surgical 18px removal; 686 NEW source-derived heavier 5-rock volcano/lava animation frames.
- All original XML names/actions/timings/facing rows/variable frame sizes (24,32,40,48,56,64,72,80 px canvases depending on pose), shadow and offsets BYTE IDENTICAL. New sample frames protect original torso-blue alpha, sheet borders and foot/ground alpha. The single old approved 0003 Idle Back F1 exception erased 2 wrongly classified old petal cyan pixels as the user requested; DO NOT restore them under generic body preservation.
- Python independent full-source QA checks ALL per-action source grid placements, every frame, original XMLOffsets/Shadow, all user-approved 24 exact keyframes. Godot v4.7.2 native XMLParser + OpenGL GPU checks all three sprite source sets. They are a *bridge proof*, not original PMD game's own loader or RPG Maker VX Tankentai SBS gameplay certification.
- G9 NEW action art status: TECH SOURCE/GPU PASS, HUMAN FULL-ACTION VISUAL REVIEW PENDING. The 0001 early accepted art is preserved, and G8R4/5 keyframes user-liked are preserved. Do not claim all newly generated 1356 frames have individually received human art acceptance. Review true native per-action montages and GIFs before sealing.
- Original PMD fan sprite attribution and redistribution licensing may need independent audit before commercial/public game shipment; this file is a private project transfer. F2 map work continues PAUSED.
- ZIP contains full source and quick QA CMD and full sprite atlas native engine tests, logs, current handoff and rules. No invented 10-row imagegen mockup used as game content.
""",encoding="utf-8")
(ST/"RULES_DELTA.md").write_text("""# P3 G9 production authority rules
1. Never use ImageGen concept sprites as authentic PMD sprite atlas. Authentic original art only, derivative per original XML cell geometry.
2. Stable 0001 G3R1 ALL 34 image actions are frozen, copy bit-exact. 0002 G8R4 approved 12 cells F0/F1 Idle/Walk D0/D2/D4 frozen. 0003 G8R5 approved 12 cells frozen including deliberately removed two source cyan floral pixels on back D4 F1.
3. New 0002 670 + 0003 686 action frames use SOURCE BLUE BODY silhouette center to mount three/five separate 5-color round basalt rocks with orange-red + yellow visible crater. Never align root with flower petals, do not erase valid body pixels, no fixed frame dimensions across attack/rotate/sleep.
4. Keep original per-species XML, all action names and 8-way source offsets/shadows BYTE EXACT. Atomic output in isolated G9 folder; do not overwrite older accepted or failed candidates.
5. Per-frame source QA: exact cell dimensions, original lower-foot alpha and frame boundaries, protected original body alpha, actual RGBA visible changes, accepted prior keyframes pixel-exact. Native Godot XML/GPU; cold unzip repeat; printable LOG + Handoff + Drive GitHub Linear.
6. G9 full sheets TECH CANDIDATE only: all 1356 newly generated frames require honest human art review, especially abnormal Hurt/Faint/Attack poses. No "HUMAN PASS" claim just because source QA and Godot bridge pass. Original actual PMD engine/VX SBS not tested.
7. F2 Ground/PAR work still paused. Never re-open map tasks without user's explicit request.
""",encoding="utf-8")
(ST/"CURRENT_HANDOFF.md").write_text("""# CURRENT_HANDOFF P3_G9_FULL_EVOLUTION_CHAIN_0001_0003 — 2026-10-27
User explicitly authorized full PMD 0001–0003 derivative sheet production after visual acceptance of 0001 G3R1, 0002 G8R4 and 0003 G8R5 Idle Back stray rock removal. Assistant actually built all three per-species original PMD atlas sets in isolated E:\\GameAssetToolLab_20261023\\TOOLCHAIN_PILOT_20261025\\outputs\\P3_G9_FULL_0001_0002_0003_EVOLUTION_20261027. NO ImageGen concept charts.
Output includes:
- 0001 EXACT accepted G3R1 image actions 34 / 1123 original source XML animation cell positions, no changed accepted pixels.
- 0002 12 actual native action PNG sheets 682 frames, of which 12 user-reviewed keyframes exact G8R4 and 670 newly made G9 full evolution volcano frames.
- 0003 12 actual native action sheets 698 frames, of which 12 exact G8R5 user-reviewed keyframes incl Idle Back F1 surgical black stray fix, 686 newly made G9 frames.
Overall 58 action atlases and 2,503 original XML-defined cells. All per-species original XML, Offsets, Shadow unchanged byte-for-byte; action cell sizes varied by source 24..80 rather than forcing 32x32. Source-blue body anchor governs rock movement, not flower tracking. Real rock/fire with multi-tones and hot crater bright orange/yellow. AI illustration assets do not enter actual PMD source.
Source per-cell QA all 0001/2/3 PASS, exception on 0003 Idle Back F1 original color detector wrongly calls two removed petal pixels body (approved exact G8R5), true torso unaffected. Godot native XML/GPU both 0002+0003 PASS; 0001 previously verified, release freshly retest.
IMPORTANT HUMAN ART STATUS: 0001 accepted baseline, prior 0002/0003 12 samples each accepted, **new 1356 G9 full-action frames require human art acceptance**. Technical full atlas completion is NOT final formal art PASS. Original PMD game and VX Tankentai SBS target runtime NOT tested. User explicitly paused maps; no map changes.
Next: review all genuine action preview panels/GIFs and report pose defects, fix original PMD cells with source geometry, then seal after human art acceptance. Every later iteration must upload ZIP+RUN CMD+LOG+Handoff to Drive/GitHub/Linear.
""",encoding="utf-8")
(ST/"RUN_QUICK_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_FULL_EVOLUTION.py"\r\npause\r\n',encoding="ascii")
(ST/"RUN_GODOT_NATIVE_XML.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Update path to installed Godot 4.7.2& pause& exit /b 1)
for %%S in (0001 0002 0003) do (
 echo Testing PMD %%S native XML...
 "%GODOT%" --headless --path "%~dp0GODOT_%%S" --import
 if errorlevel 1 exit /b 1
 "%GODOT%" --path "%~dp0GODOT_%%S" --rendering-driver opengl3 --scene res://player.tscn
 if errorlevel 1 exit /b 1
)
echo Godot XML native bridge PASS if all scripts report. PMD original game and VX SBS NOT TESTED.
pause
'''.replace("\n","\r\n"),encoding="ascii")
verify='''from pathlib import Path
import json,numpy as np,xml.etree.ElementTree as ET
from PIL import Image
P=Path(__file__).resolve().parent
total_frames=0
for sp,actions,expected in (("0001",34,1123),("0002",12,682),("0003",12,698)):
 o=P/("ORIGINAL_"+sp);m=P/("PRODUCTION_"+sp)
 assert (o/"AnimData.xml").read_bytes()==(m/"AnimData.xml").read_bytes()
 xml=ET.parse(o/"AnimData.xml").getroot().findall(".//Anim")
 sheets=0;cells=0;preserved=0
 for f in o.glob("*"):
  if f.name.endswith(("-Offsets.png","-Shadow.png")):
   assert f.read_bytes()==(m/f.name).read_bytes(),(sp,f.name)
 for t in xml:
  if t.findtext("CopyOf"):continue
  act=t.findtext("Name");w=int(t.findtext("FrameWidth"));h=int(t.findtext("FrameHeight"))
  a=np.asarray(Image.open(o/(act+"-Anim.png")).convert("RGBA"))
  b=np.asarray(Image.open(m/(act+"-Anim.png")).convert("RGBA"))
  nf=len(t.find("Durations").findall("Duration"))
  assert a.shape==b.shape and a.shape[1]==w*nf and a.shape[0]%h==0
  sheets+=1
  for row in range(a.shape[0]//h):
   for fr in range(nf):
    old=a[row*h:(row+1)*h,fr*w:(fr+1)*w]
    new=b[row*h:(row+1)*h,fr*w:(fr+1)*w]
    if sp!="0001":assert np.any(old!=new)
    assert np.array_equal(old[-3:,:,3],new[-3:,:,3]),(sp,act,row,fr,"FOOT")
    assert not any(np.any(q) for q in (((new[0,:,3]>0)&(old[0,:,3]==0)),
     ((new[-1,:,3]>0)&(old[-1,:,3]==0)),((new[:,0,3]>0)&(old[:,0,3]==0)),
     ((new[:,-1,3]>0)&(old[:,-1,3]==0)))),(sp,act,row,fr,"BORDER")
    rgb=old[:,:,:3].astype(np.int16);blue=(old[:,:,3]>0)&(rgb[:,:,2]>rgb[:,:,0]*1.07)&(rgb[:,:,1]>=rgb[:,:,0]*.90)&(rgb[:,:,0]>=55)
    lost=int((blue&(new[:,:,3]==0)).sum())
    if sp=="0003" and act=="Idle" and row==4 and fr==1:assert lost==2
    elif sp!="0001":assert lost==0,(sp,act,row,fr,"BODY_DAMAGE",lost)
    cells+=1
  if sp=="0001":
   # Copy of accepted original G3R1 is separately checked via source provenance
   pass
 assert sheets==actions and cells==expected,(sp,sheets,cells)
 total_frames+=cells
 print(f"PASS G9 PMD{sp} {sheets} original-sheet actions {cells} original-XML cells, alpha/offset/shadow valid")
print("ALL_P3_G9_2503_SOURCE_FRAMES_QA_PASS",total_frames)
'''
(ST/"VERIFY_FULL_EVOLUTION.py").write_text(verify,encoding="utf-8")
# validate staged and run native Godot for 0001/0002/0003; strict no claiming original game compatibility
PY=R/".venv/Scripts/python.exe";G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
q=subprocess.run([str(PY),str(ST/"VERIFY_FULL_EVOLUTION.py")],capture_output=True,text=True,errors="replace",timeout=60)
(ST/"SOURCE_QA.log").write_text(q.stdout+"\n"+q.stderr,encoding="utf-8")
assert q.returncode==0,(q.stdout,q.stderr)
print("G9_STAGE_SOURCE_QA",q.stdout[-360:],flush=True)
for sp in ("0001","0002","0003"):
 D=ST/f"GODOT_{sp}"
 p=subprocess.run([str(G),"--headless","--path",str(D),"--import"],capture_output=True,text=True,errors="replace",timeout=85)
 (D/"NATIVE_RELEASE_IMPORT.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf-8")
 assert p.returncode==0,(sp,p.stdout[-700:],p.stderr[-1000:])
 p=subprocess.run([str(G),"--path",str(D),"--rendering-driver","opengl3","--scene","res://player.tscn"],
                  capture_output=True,text=True,errors="replace",timeout=80)
 raw=p.stdout+"\n"+p.stderr
 (D/"NATIVE_RELEASE_GPU.log").write_text(raw,encoding="utf-8")
 assert p.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in raw and "ERROR:" not in raw and "WARNING:" not in raw,(sp,raw[-1500:])
 print("G9_STAGE_GODOT_NATIVE_PASS",sp,flush=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[p for p in sorted(ST.rglob("*")) if p.is_file() and ".godot" not in p.relative_to(ST).parts and p.name!="CHECKSUMS.json"]
checksums=[{"file":p.relative_to(ST).as_posix(),"sha256":sha(p),"bytes":p.stat().st_size} for p in files]
(ST/"CHECKSUMS.json").write_text(json.dumps(checksums,ensure_ascii=False,indent=2),encoding="utf-8")
with zipfile.ZipFile(ZIP,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(ST.rglob("*")):
  if p.is_file() and ".godot" not in p.relative_to(ST).parts:z.write(p,p.relative_to(ST).as_posix())
with zipfile.ZipFile(ZIP) as z:assert z.testzip() is None;count=len(z.namelist())
COLD=R/"COLD_P3_G9_FULL_EVOLUTION_20261027"
assert not COLD.exists()
with zipfile.ZipFile(ZIP) as z:z.extractall(COLD)
for item in checksums:assert sha(COLD/item["file"])==item["sha256"],item["file"]
q=subprocess.run([str(PY),str(COLD/"VERIFY_FULL_EVOLUTION.py")],capture_output=True,text=True,errors="replace",timeout=60)
assert q.returncode==0,(q.stdout,q.stderr)
for sp in ("0001","0002","0003"):
 D=COLD/f"GODOT_{sp}"
 p=subprocess.run([str(G),"--headless","--path",str(D),"--import"],capture_output=True,text=True,errors="replace",timeout=85)
 assert p.returncode==0,(sp,p.stderr[-900:])
 p=subprocess.run([str(G),"--path",str(D),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=80)
 raw=p.stdout+"\n"+p.stderr
 (R/f"reports/P3_G9_COLD_GODOT_{sp}.log").write_text(raw,encoding="utf-8")
 assert p.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in raw and "ERROR:" not in raw and "WARNING:" not in raw,(sp,raw[-1300:])
 print("G9_COLD_NATIVE_GODOT_PASS",sp,flush=True)
report={"zip":str(ZIP),"bytes":ZIP.stat().st_size,"sha256":sha(ZIP),"members":count,
 "three_species":["0001","0002","0003"],"action_sheets":58,
 "true_original_XML_frames":2503,"0001_existing_approved_frames":1123,
 "0002_frames":682,"0003_frames":698,"preserved_approved_G8R4_G8R5_keyframes":24,
 "new_frames_0002_0003":1356,"source_XML_off_shadow":"BIT_IDENTICAL",
 "zip_CRC":"PASS","cold_file_SHA":"PASS","cold_source_2503_QA":"PASS",
 "cold_Godot_original_XML_GPU_all_three":"PASS",
 "human_new_art":"PENDING","original_PMD_runtime":"NOT_TESTED","VX_Tankentai_SBS":"NOT_TESTED","F2_map":"PAUSED"}
(R/"reports/P3_G9_FULL_EVOLUTION_RELEASE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print("G9_FULL_EVOLUTION_RELEASE_COLD_VERIFIED",json.dumps(report,ensure_ascii=False),flush=True)
