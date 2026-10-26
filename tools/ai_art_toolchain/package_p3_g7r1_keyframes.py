from pathlib import Path
from PIL import Image
import numpy as np,shutil,subprocess,json,hashlib,zipfile,xml.etree.ElementTree as ET
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
A=R/"outputs/P3_G7R1_RESET_BACK_MOUNTED_ROCK_CLUSTER_20261026"
ST=R/"deliveries/P3_G7R1_MOUNTED_ROCK_KEYFRAME_SAMPLES_20261026"
Z=R/"deliveries/P3_G7R1_MOUNTED_ROCK_KEYFRAME_SAMPLES_20261026.zip"
assert not ST.exists() and not Z.exists()
ST.mkdir(parents=True)
qa={};reference=[]
for species in ("0002","0003"):
 SRC=R/f"outputs/P3_G{'4' if species=='0002' else '5'}_{species}_OFFICIAL_SOURCE_20261026/SOURCE_{species}"
 SAMPLE=A/f"PMD_{species}_SAMPLE_SHEETS"
 # Original original files are packaged for genuine source audits/replay, do not edit.
 orig=ST/f"ORIGINAL_{species}"
 shutil.copytree(SRC,orig)
 modified=ST/f"SAMPLE_{species}"
 shutil.copytree(SRC,modified)
 for act in ("Idle","Walk"):
  shutil.copy2(SAMPLE/(act+"-Anim.png"),modified/(act+"-Anim.png"))
 sample_report=A/f"PMD_{species}_G7_KEYFRAME_QA.json"
 shutil.copy2(sample_report,ST/sample_report.name)
 # Static system can verify only 12 sample slots changed and unaffected sheet positions unchanged.
 info=json.loads(sample_report.read_text(encoding="utf-8"))
 assert info["sample_cells"]==12 and info["body_erased_total"]==0
 assert info["XML_Offsets_Shadow_exact"] and info["all_rock_modules_move_with_body"]
 for fn in (ST/f"ORIGINAL_{species}").glob("*"):
  if fn.name=="AnimData.xml" or fn.name.endswith(("-Offsets.png","-Shadow.png")):
   assert fn.read_bytes()==(modified/fn.name).read_bytes()
 for action in ("Idle","Walk"):
  o=np.asarray(Image.open(orig/(action+"-Anim.png")).convert("RGBA"))
  new=np.asarray(Image.open(modified/(action+"-Anim.png")).convert("RGBA"))
  changed=0
  for row in range(8):
   for col in range(4):
    a=o[row*32:(row+1)*32,col*32:(col+1)*32]
    b=new[row*32:(row+1)*32,col*32:(col+1)*32]
    selected=row in (0,2,4) and col in (0,1)
    if selected:
     assert np.any(a!=b),(species,action,row,col,"SAMPLE_UNCHANGED")
     assert np.array_equal(a[-4:,:,3],b[-4:,:,3]),(species,action,row,col,"FOOT_DAMAGE")
     changed+=1
    else:assert np.array_equal(a,b),(species,action,row,col,"NON_SAMPLED_MODIFIED")
  assert changed==6
 other=0
 for origp in orig.glob("*-Anim.png"):
  if origp.name in ("Idle-Anim.png","Walk-Anim.png"):continue
  assert origp.read_bytes()==(modified/origp.name).read_bytes(),origp.name
  other+=1
 assert other==10,(species,other)
 # Native Godot player supports authentic original XML for *ALL* 12 motions;
 # we copy 10 original sheet files unchanged and replace exactly 12 sampled key frames.
 T=R/"outputs/P3_G5R1_0003_NATIVE_XML_PLAYER_20261026"
 runtime=ST/f"NATIVE_GODOT_{species}";runtime.mkdir()
 for fn in ("project.godot","player.tscn"):
  shutil.copy2(T/fn,runtime/fn)
 script=(T/"pmd_xml_player.gd").read_text(encoding="utf-8")
 assert "fcount!=698" in script
 if species=="0002":script=script.replace("fcount!=698","fcount!=682")
 (runtime/"pmd_xml_player.gd").write_text(script,encoding="utf-8")
 shutil.copytree(SRC,runtime/"original_0001")
 shutil.copytree(modified,runtime/"rock_0001")
 qa[species]={"actual_samples_changed":12,"original_actions_untouched":other,
              "original_xml_offsets_shadow_byte_equal":True,
              "other_10_actions_fully_unchanged":True,
              "original_0001_style_untouched":True,
              "body_erased":0,
              "foot_contact_alpha_unchanged":True,
              "all_6_direction_motions_follow_body":True,
              "art_gate":"PENDING",
              "rpgmaker_vx_sbs":"NOT_TESTED"}
# the only modified source code for this build lives in the ZIP.
for fn in ("build_p3_g7r1_keyframes.py","inspect_g7_reference.py","inspect_g7_body_anchors.py"):
 shutil.copy2(R/fn,ST/fn)
# Two separate previews and two GIFs per species; no new full modified sheet claimed.
p=ST/"PREVIEWS";p.mkdir()
for img in A.glob("*.png"):shutil.copy2(img,p/img.name)
for img in A.glob("*.gif"):shutil.copy2(img,p/img.name)
# Include complete original-face reference boards in packaged output.
ref=R/"outputs/P3_G7_KEYFRAME_REFERENCE_INSPECTION_20261026"
for img in ref.glob("*.png"):shutil.copy2(img,p/img.name)
# Actual independent executable QA script included for review.
code='''from pathlib import Path
from PIL import Image
import numpy as np,json,xml.etree.ElementTree as ET
B=Path(__file__).resolve().parent
for sp in ("0002","0003"):
 orig=B/("ORIGINAL_"+sp);new=B/("SAMPLE_"+sp)
 assert (orig/"AnimData.xml").read_bytes()==(new/"AnimData.xml").read_bytes()
 assert len(ET.parse(orig/"AnimData.xml").getroot().findall(".//Anim"))==14
 report=json.loads((B/("PMD_"+sp+"_G7_KEYFRAME_QA.json")).read_text(encoding="utf-8"))
 assert report["sample_cells"]==12 and report["body_erased_total"]==0
 assert report["all_rock_modules_move_with_body"]
 for item in orig.glob("*"):
  if item.name=="AnimData.xml" or item.name.endswith(("-Offsets.png","-Shadow.png")):
   assert item.read_bytes()==(new/item.name).read_bytes()
  elif item.name.endswith("-Anim.png") and item.name not in ("Idle-Anim.png","Walk-Anim.png"):
   assert item.read_bytes()==(new/item.name).read_bytes()
 for action in ("Idle","Walk"):
  a=np.asarray(Image.open(orig/(action+"-Anim.png")).convert("RGBA"))
  b=np.asarray(Image.open(new/(action+"-Anim.png")).convert("RGBA"))
  assert a.shape==(256,128,4) and b.shape==a.shape
  for row in range(8):
   for col in range(4):
    x=a[row*32:(row+1)*32,col*32:(col+1)*32]
    y=b[row*32:(row+1)*32,col*32:(col+1)*32]
    selected=row in (0,2,4) and col in (0,1)
    if selected:
     assert np.any(x!=y),(sp,action,row,col,"UNEDITED_SAMPLE")
     assert np.array_equal(x[-4:,:,3],y[-4:,:,3]),(sp,action,row,col,"FOOT")
     assert not(np.any((y[0,:,3]>0)&(x[0,:,3]==0)) or np.any((y[-1,:,3]>0)&(x[-1,:,3]==0)) or np.any((y[:,0,3]>0)&(x[:,0,3]==0)) or np.any((y[:,-1,3]>0)&(x[:,-1,3]==0))),(sp,action,row,col,"BORDER")
    else:assert np.array_equal(x,y),(sp,action,row,col,"NON_SAMPLE_CHANGED")
 for action in ("Idle","Walk"):
  for direction in (0,2,4):
   fs=[x for x in report["keyframes"] if x["action"]==action and x["direction"]==direction]
   assert len(fs)==2 and fs[0]["mount"]!=fs[1]["mount"]
   for i in range(3 if sp=="0002" else 5):
    assert fs[0]["rock_centers"][i]!=fs[1]["rock_centers"][i]
print("G7_KEYFRAMES_STATIC_QA_PASS: 24 total selected cells, source-body and feet preserved, 10 other actions unchanged, XML unchanged")
'''
(ST/"VERIFY_SAMPLES.py").write_text(code,encoding="utf-8")
(ST/"RUN_SOURCE_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_SAMPLES.py"\r\npause\r\n',encoding="ascii")
(ST/"RUN_GODOT_TEST.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Set GODOT path first& pause& exit /b 1)
for %%S in (0002 0003) do (
 "%GODOT%" --headless --path "%~dp0NATIVE_GODOT_%%S" --import
 if errorlevel 1 exit /b 1
 "%GODOT%" --path "%~dp0NATIVE_GODOT_%%S" --rendering-driver opengl3 --scene res://player.tscn
 if errorlevel 1 exit /b 1
)
echo Godot XML bridge sample TECH PASS only. Human art / real PMD game / VX SBS PENDING.
pause
'''.replace("\n","\r\n"),encoding="ascii")
(ST/"CURRENT_HANDOFF.md").write_text('''# CURRENT_HANDOFF — P3_G7R1_RESET_BACK_MOUNTED_ROCK_CLUSTER
2026-10-26; maps PAUSED, original PMD 0001 user-liked G3R1 intact.
G6R4R2 round-rock and flower-centroid following produced visibly damaged frog/rock pixels and is permanently **ART FAIL — DO NOT BASE**.
New isolated G7R1 began again from untouched PMDCollab original sprite/0002 and sprite/0003. New production scope is **KEYFRAMES ONLY**: per species Idle/Walk original facing row0 (front), row2 (side) and row4 (back), frame0/1 only, exactly 12 cells per species, 24 total. No full 682/698 edits! Source body cyan alpha protected: deleted body pixels=0, original foot alpha preserved, no new frame border alpha. Stable rock body mount computed from each SOURCE BODY blue-pixel median, not leaf centroids. 0002: 3 stone module + small lava vent; 0003: 5 stone module + larger vent and subtle flow. Each stone has dark border, fully filled round interior and mineral pixel accents. Sway: whole rock group follows body mount plus small phase-dependent secondary bob so none is independently static; check 3 facings x Idle+Walk both F0/F1. Flowers removed only inside source dorsal material mask; never erase blue body, no G6 mass-erasure. Isolated dark flower remains were caught in initial G7 and cleaned for G7R1 with connected components excluding protected blue pixels. Native Godot XML bridge may run in NATIVE_GODOT folders which preserve original other action sheets. Original XML/Offsets/Shadow identical. New visual art gate NOT SEEN by USER/PENDING.
No actual PMD engine or native RPG Maker VX SBS PASS. Next step: user Human Art acceptance of both sample comparison and GIF BEFORE any full atlas production; continue keyframe iteration if visual QA flags fragments, proportions or unnatural anchor. Keep visual failures and rules synced to Drive/GitHub/Linear.
''',encoding="utf-8")
(ST/"RULES_DELTA.md").write_text('''# P3_G7 hard reset — user-directed
G6R4R2 permanent ART_FAIL due pixel holes and static/disconnected rock anatomy; never reuse it. Source from PMDCollab ORIGINAL 0002/0003, no following original petals. 0001 art frozen and maps paused.
Only produce Idle/Walk directions 0,2,4 frames 0,1 (12 each / 24 total). Protect actual frog blue-body pixels and original foot alpha; build independent solid boulders anchored to torso centroid; stone motion as a connected root module with small phase bob. Keep each source XML and any offsets/shadows bit-exact, full sheet cell positions unchanged. Original 10 other action sheets remain unmodified.
Visual Gate requires: complete body, filled stones, natural back contact, synchronized per-frame body/rock dynamics, distinct evolution between 3 rocks and 5 rocks. Source/engine QA does not confer human art PASS.
''',encoding="utf-8")
(ST/"README.md").write_text('''# G7R1 actual PMD sample-only candidate
Delivers actual original PMD 0002/0003 plus ONLY the selected edited Idle+Walk F0/F1 for front D0, side D2 and back D4. Includes authentic original per-species XML, offsets, shadows, unchanged other 10 animation atlases and an isolated Godot XML bridge for playback. Both species have exactly 12 changed original animation cells, no full sprite-sheet change. Includes keyframe 1x nearest previews, original-vs-new and small two-frame motion GIFs, source body/mount/alpha QA. User human art review MUST precede expanding to all 682/698 cells; no substitute imagegen. Map remains paused, 0001 untouched. Attribution/commercial rights not resolved; keep private.
''',encoding="utf-8")
py=R/".venv/Scripts/python.exe"
raw=subprocess.run([str(py),str(ST/"VERIFY_SAMPLES.py")],capture_output=True,text=True,errors="replace",timeout=45)
(ST/"STATIC_QA.log").write_text(raw.stdout+"\n"+raw.stderr,encoding="utf-8")
assert raw.returncode==0,(raw.stdout,raw.stderr)
print("SOURCE_QA",raw.stdout,flush=True)
# Native isolated Godot loading tests. This proves the 12 patched cells are compatible with the existing XML bridge.
godot=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
for sp in ("0002","0003"):
 P=ST/f"NATIVE_GODOT_{sp}"
 imp=subprocess.run([str(godot),"--headless","--path",str(P),"--import"],
                    capture_output=True,text=True,errors="replace",timeout=75)
 (P/"GODOT_IMPORT.log").write_text(imp.stdout+"\n"+imp.stderr,encoding="utf-8")
 assert imp.returncode==0,(sp,imp.stderr[-800:])
 run=subprocess.run([str(godot),"--path",str(P),"--rendering-driver","opengl3",
                     "--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=85)
 log=run.stdout+"\n"+run.stderr
 (P/"NATIVE_GODOT_XML_GPU_QA.log").write_text(log,encoding="utf-8")
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in log and "ERROR:" not in log and "WARNING:" not in log,(sp,log[-1400:])
 caps=[np.asarray(Image.open(P/f"GODOT_XML_RENDER_FRAME_{k}.png").convert("RGBA")) for k in range(3)]
 assert np.any(caps[0]!=caps[1])
 print("NATIVE_GODOT_SAMPLE",sp,"PASS",flush=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[f for f in sorted(ST.rglob("*")) if f.is_file() and ".godot" not in f.relative_to(ST).parts and f.name!="CHECKSUMS.json"]
manifest=[{"path":f.relative_to(ST).as_posix(),"sha256":sha(f),"bytes":f.stat().st_size} for f in files]
(ST/"CHECKSUMS.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
with zipfile.ZipFile(Z,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(ST.rglob("*")):
  if p.is_file() and ".godot" not in p.relative_to(ST).parts:z.write(p,p.relative_to(ST).as_posix())
with zipfile.ZipFile(Z) as z:assert z.testzip() is None;items=len(z.infolist())
cold=R/"COLD_P3_G7R1_KEYFRAME_SAMPLES_20261026"
assert not cold.exists()
with zipfile.ZipFile(Z) as z:z.extractall(cold)
for x in manifest:assert sha(cold/x["path"])==x["sha256"],x["path"]
retest=subprocess.run([str(py),str(cold/"VERIFY_SAMPLES.py")],capture_output=True,text=True,errors="replace",timeout=45)
assert retest.returncode==0,(retest.stdout,retest.stderr)
for sp in ("0002","0003"):
 P=cold/f"NATIVE_GODOT_{sp}"
 imported=subprocess.run([str(godot),"--headless","--path",str(P),"--import"],
                  capture_output=True,text=True,errors="replace",timeout=75)
 assert imported.returncode==0,(sp,imported.stderr[-600:])
 run=subprocess.run([str(godot),"--path",str(P),"--rendering-driver","opengl3","--scene","res://player.tscn"],
                    capture_output=True,text=True,errors="replace",timeout=75)
 txt=run.stdout+"\n"+run.stderr
 (R/f"reports/P3_G7R1_COLD_GODOT_{sp}.log").write_text(txt,encoding="utf-8")
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in txt and "ERROR:" not in txt and "WARNING:" not in txt,(sp,txt[-900:])
print("COLD_BOTH_GODOT_XML_GPU_PASS",flush=True)
report={"name":"P3_G7R1_BACK_MOUNTED_ROCK_KEYFRAME_SAMPLES","zip":str(Z),"sha256":sha(Z),
"size":Z.stat().st_size,"members":items,
"sample_cells_modified":{"0002":12,"0003":12},"no_full_sheet_production":True,
"all_10_other_actions_original":True,"body_erased_pixels":0,"foot_alpha_original":True,
"original_XML_Offsets_Shadow_byte_equal":True,
"zip_CRC":"PASS","cold_SHA":"PASS","cold_source_QA":"PASS","cold_native_Godot_XML_GPU":"PASS",
"human_art":"PENDING", "original_PMD_game_and_VX_SBS":"NOT_TESTED","maps":"PAUSED"}
(R/"reports/P3_G7R1_DELIVERY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print("P3_G7R1_PACKAGE_SUCCESS",json.dumps(report,ensure_ascii=False),flush=True)
