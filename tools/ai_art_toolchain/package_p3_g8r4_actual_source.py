from pathlib import Path
from PIL import Image
import numpy as np,json,zipfile,hashlib,shutil,subprocess,xml.etree.ElementTree as ET
from io import BytesIO
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
A=R/"outputs/P3_G8R4_AUTHENTIC_FRAME_OUTLINE_MAGMA_20261026"
ST=R/"deliveries/P3_G8R4_NATIVE_PMD_MAGMA_OUTLINE_REPAIR_20261026"
Z=R/"deliveries/P3_G8R4_NATIVE_PMD_MAGMA_OUTLINE_REPAIR_20261026.zip"
assert not ST.exists() and not Z.exists()
ST.mkdir(parents=True)
G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
T=R/"outputs/P3_G5R1_0003_NATIVE_XML_PLAYER_20261026"
for sp in ("0002","0003"):
 SRC=R/f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}"
 shutil.copytree(SRC,ST/f"ORIGINAL_{sp}")
 shutil.copytree(SRC,ST/f"G8R4_SAMPLE_{sp}")
 D=A/sp
 for act in ("Idle","Walk"):
  shutil.copy2(D/(act+"-Anim.png"),ST/f"G8R4_SAMPLE_{sp}"/(act+"-Anim.png"))
 shutil.copytree(D/"frames",ST/f"EDITABLE_{sp}"/"frames")
 shutil.copytree(D/"pixelorama_layers",ST/f"EDITABLE_{sp}"/"pixelorama_layers")
 shutil.copy2(A/f"PMD_{sp}_G8R4_QA.json",ST/f"PMD_{sp}_G8R4_QA.json")
 p=ST/"PREVIEWS";p.mkdir(exist_ok=True)
 shutil.copy2(A/f"PMD_{sp}_G8R4_SOURCE_R3_R4_CONTACT.png",p)
 for act in ("Idle","Walk"):shutil.copy2(A/f"PMD_{sp}_{act}_G8R4.gif",p)
 DGO=ST/f"GODOT_{sp}";DGO.mkdir()
 for fn in ("project.godot","player.tscn","pmd_xml_player.gd"):shutil.copy2(T/fn,DGO/fn)
 gd=DGO/"pmd_xml_player.gd"
 text=gd.read_text(encoding="utf-8")
 if sp=="0002":text=text.replace("fcount!=698","fcount!=682")
 gd.write_text(text,encoding="utf-8")
 shutil.copytree(SRC,DGO/"original_0001")
 shutil.copytree(ST/f"G8R4_SAMPLE_{sp}",DGO/"rock_0001")
 p=subprocess.run([str(G),"--headless","--path",str(DGO),"--import"],capture_output=True,text=True,errors="replace",timeout=80)
 (DGO/"NATIVE_IMPORT.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf-8")
 assert p.returncode==0,(sp,p.stderr[-900:])
 p=subprocess.run([str(G),"--path",str(DGO),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=90)
 log=p.stdout+"\n"+p.stderr
 (DGO/"NATIVE_XML_GPU.log").write_text(log,encoding="utf-8")
 assert p.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in log and "ERROR:" not in log and "WARNING:" not in log,(sp,log[-1000:])
 imgs=[np.asarray(Image.open(DGO/f"GODOT_XML_RENDER_FRAME_{i}.png").convert("RGBA")) for i in range(3)]
 assert np.any(imgs[0]!=imgs[1]),(sp,"STATIC_GPU")
 print("G8R4_GODOT_NATIVE",sp,"PASS",flush=True)
for f in ("build_p3_g8r4_actual_source.py","inspect_g8r3_orphans_all24.py","inspect_g8r3_bridge.py"):
 (ST/"SCRIPTS").mkdir(exist_ok=True)
 shutil.copy2(R/f,ST/"SCRIPTS"/f)
(ST/"RULES_DELTA.md").write_text("""# P3 G8R4 exact source fix: no generated concept diagrams
2026-10-26. User rightly rejected repeat ImageGen calls: those two generated full 10-row illustrations are NOT compatible with original PMD Atlas/XML. Strictly forbidden to treat generated illustrative chart as PMD game asset. Work directly on original PMDCollab sprite/0002 and sprite/0003 frame PNG plus ORIGINAL XML/offsets/shadows.
Only 0002+0003 Idle/Walk D0,D2,D4 F0/F1 24 selected cells; 0001 user-liked lineage frozen; maps frozen. Source blue-body alpha/foot alpha/borders protected. Each new round-stone piece shaded 5-band; original G8R3 exposes weak magma and dark edge fragments. G8R4 adds explicit TOPMOST editable OpenRaster magma/crater/ember layer and per-frame constrained orange/yellow highlights. G8R4 repairs one 6px detached SOURCE-derived tail fragment on 0003 back F1 (Idle and Walk) by mineral retone and one bridge pixel, protecting 2 embedded original body pixels rather than erasing them. No other source silhouette loss.
Tests to enforce: no alpha disconnected fragment of <=8 pixels in upper region, XML/Offsets/Shadow bit parity, only 12 source cells per monster changed, all ORA merged PNG exact, original body and foot alpha unchanged, crater hot pixel threshold >= 7 for 0002 or 12 for 0003, original GPU bridge import and render, cold SHA. Genuine original PMD game and VX Tankentai SBS still NOT TESTED, user Human Visual ART PENDING. Do not expand all motions or claim human art PASS based on automated test.
""",encoding="utf-8")
(ST/"CURRENT_HANDOFF.md").write_text("""# CURRENT_HANDOFF G8R4 original PMD outline/magma samples
2026-10-26. USER STRONGLY OBJECTED to assistant repeatedly substituting AI-generated illustrated tall sprite chart for actual PMD files. Those two ImageGen pictures are invalid game assets and not included in any PMD authority or ZIP. Reverted to authentic original PMDCollab sprite/0002 & sprite/0003 and original per-species XML. Prior G8R3 was user-liked direction but remaining black outline, weak volcano.
G8R4 ACTUAL PATCH: only original Idle+Walk front D0/side D2/back D4 first two frames per species = 12 each, 24 total. Added more visible molten vent and yellow/orange crest on TOP editing layer to every sample, source frames 32x32 kept exactly; 0002 new overlay 136 opaque pixels aggregate, 0003 280; original blue frog body alpha never erased, feet and frame border unchanged. 0003 back F1 orphan component 6 pixels (incl. 2 source body pixels), on both Idle/Walk, got mineral retone and single-pixel contact bridge to main basalt body; new connected components QA all no <=8 upper orphan in 24 frames. 24 editable .ora layers exact merged PNG parity and original atlas untouched elsewhere. Godot original XML / GPU tech PASS both zero errors/warnings, but actual PMD game and VX SBS not tested. User ART PENDING and only 1x sprite image proves practical readability. Strict maps PAUSED, original 0001 accepted orange-gray sprite unchanged. Never resume plans-only or image generation for original file edits.
Upcoming: user inspect original/R3/R4 difference and two-frame GIF; improve artistry at 1x if needed, then and only then expand action atlas after user acceptance, document licensing check. Archive each iteration source ZIP/CMD/LOG + Drive/GitHub/Linear handoff.
""",encoding="utf-8")
(ST/"README.md").write_text("""# Real native PMD 0002+0003 G8R4
Use original \`ORIGINAL_0002/0003\` source and changed \`G8R4_SAMPLE_0002/0003\` sprite folder with original per-ID AnimData.xml, shadow and offsets. 12 changed Idle/Walk frame cells per species ONLY, all 10 other motion PNGs authentic and identical. All 24 editable OpenRaster files include a new visible molten top layer. Unmerged full-length illustrated AI images not included, because those do not meet native PMD requirements. Includes native Godot source and full independent validation scripts. G8R4 has stronger upper lava and repairs disconnected small 0003 back patch. User art approval PENDING; original game engine and VX SBS still untested.
""",encoding="utf-8")
QA='''from pathlib import Path
from PIL import Image
import numpy as np,json,xml.etree.ElementTree as ET,zipfile
from io import BytesIO
from scipy.ndimage import label
B=Path(__file__).resolve().parent
for sp in ("0002","0003"):
 O=B/("ORIGINAL_"+sp);M=B/("G8R4_SAMPLE_"+sp)
 assert (O/"AnimData.xml").read_bytes()==(M/"AnimData.xml").read_bytes()
 assert len(ET.parse(O/"AnimData.xml").getroot().findall(".//Anim"))==14
 for f in O.glob("*"):
  if f.name=="AnimData.xml" or f.name.endswith(("-Offsets.png","-Shadow.png")): assert f.read_bytes()==(M/f.name).read_bytes()
  if f.name.endswith("-Anim.png") and f.name not in ("Idle-Anim.png","Walk-Anim.png"): assert f.read_bytes()==(M/f.name).read_bytes()
 q=json.loads((B/("PMD_"+sp+"_G8R4_QA.json")).read_text(encoding="utf-8"))["G8R4_MOLTEN_REPAIR"]
 assert len(q["keyframes"])==12
 assert q["orphan_0003_back_F1_connected"]==(0 if sp=="0002" else 2)
 for act in ("Idle","Walk"):
  a=np.asarray(Image.open(O/(act+"-Anim.png")).convert("RGBA"))
  b=np.asarray(Image.open(M/(act+"-Anim.png")).convert("RGBA"))
  assert a.shape==b.shape==(256,128,4)
  for y in range(8):
   for x in range(4):
    src=a[y*32:(y+1)*32,x*32:(x+1)*32]
    dst=b[y*32:(y+1)*32,x*32:(x+1)*32]
    yes=y in (0,2,4) and x in (0,1)
    assert bool(np.any(src!=dst))==yes,(sp,act,y,x,"OUT_OF_SCOPE")
    if yes:assert np.array_equal(src[-3:,:,3],dst[-3:,:,3])
 for v in q["keyframes"]:
  assert v["lost_blue_body_alpha"]==0 and v["detached_alpha_fragments"]==0
  assert v["visible_lava_pixels"]>=(7 if sp=="0002" else 12)
  act,face,f=v["action"],v["face"],v["frame"]
  im=B/("EDITABLE_"+sp)/"frames"/f"{act}_{face}_F{f}.png"
  ora=B/("EDITABLE_"+sp)/"pixelorama_layers"/f"{act}_{face}_F{f}.ora"
  with zipfile.ZipFile(ora) as z:
   assert z.testzip() is None
   assert z.read("mimetype")==b"image/openraster"
   b=np.asarray(Image.open(BytesIO(z.read("mergedimage.png"))).convert("RGBA"))
   a=np.asarray(Image.open(im).convert("RGBA"))
   assert np.array_equal(a,b)
   assert any("G8R4_MAGMA_OUTLINE" in k for k in z.namelist())
  lbl,n=label(a[:,:,3]>0,structure=np.ones((3,3)))
  for i in range(1,n+1):
   yy,xx=np.where(lbl==i)
   assert len(xx)>8 or int(yy.min())>16,(sp,act,face,f,"FLOATING_UPPER",len(xx))
print("G8R4_REAL_PMD_ARCHIVE_PASS 0002/0003 24 original 32x32 cells, lava, body, connectivity, XML/ORA")
'''
(ST/"VERIFY_G8R4_ARCHIVE.py").write_text(QA,encoding="utf-8")
(ST/"RUN_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_G8R4_ARCHIVE.py"\r\npause\r\n',encoding="ascii")
(ST/"RUN_NATIVE_GODOT.cmd").write_text('''@echo off
setlocal
set "GODOT=E:\\GameAssetToolLab_20261023\\FS_MapDepthPar_20261024\\godot_depth_probe\\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (echo Update GODOT path first& pause& exit /b 1)
for %%S in (0002 0003) do (
 "%GODOT%" --headless --path "%~dp0GODOT_%%S" --import
 if errorlevel 1 exit /b 1
 "%GODOT%" --path "%~dp0GODOT_%%S" --rendering-driver opengl3 --scene res://player.tscn
 if errorlevel 1 exit /b 1
)
echo ORIGINAL PMD/VX SBS TARGET GAME: NOT TESTED. Human art pending.
pause
'''.replace("\n","\r\n"),encoding="ascii")
PY=R/".venv/Scripts/python.exe"
p=subprocess.run([str(PY),str(ST/"VERIFY_G8R4_ARCHIVE.py")],capture_output=True,text=True,errors="replace",timeout=40)
(ST/"QA.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf-8")
assert p.returncode==0,(p.stdout,p.stderr)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[x for x in sorted(ST.rglob("*")) if x.is_file() and ".godot" not in x.relative_to(ST).parts and x.name!="CHECKSUMS.json"]
manifest=[{"file":x.relative_to(ST).as_posix(),"sha256":sha(x)} for x in files]
(ST/"CHECKSUMS.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
with zipfile.ZipFile(Z,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as zipfile_out:
 for file in sorted(ST.rglob("*")):
  if file.is_file() and ".godot" not in file.relative_to(ST).parts:zipfile_out.write(file,file.relative_to(ST).as_posix())
with zipfile.ZipFile(Z) as archive:assert archive.testzip() is None;num=len(archive.namelist())
COLD=R/"COLD_P3_G8R4_REAL_SOURCE_20261026"
assert not COLD.exists()
with zipfile.ZipFile(Z) as ar:ar.extractall(COLD)
for item in manifest:assert sha(COLD/item["file"])==item["sha256"],item["file"]
p=subprocess.run([str(PY),str(COLD/"VERIFY_G8R4_ARCHIVE.py")],capture_output=True,text=True,errors="replace",timeout=40)
assert p.returncode==0,(p.stdout,p.stderr)
for sp in ("0002","0003"):
 f=COLD/f"GODOT_{sp}"
 p=subprocess.run([str(G),"--headless","--path",str(f),"--import"],capture_output=True,text=True,errors="replace",timeout=80)
 assert p.returncode==0,(sp,p.stderr[-800:])
 p=subprocess.run([str(G),"--path",str(f),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=80)
 txt=p.stdout+"\n"+p.stderr
 (R/f"reports/P3_G8R4_COLD_GODOT_{sp}.log").write_text(txt,encoding="utf-8")
 assert p.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in txt and "ERROR:" not in txt and "WARNING:" not in txt,(sp,txt[-1000:])
 print("G8R4_COLD_GODOT_PASS",sp,flush=True)
report={"name":"P3_G8R4_NATIVE_PMD_MAGMA_OUTLINE_REPAIR","zip_path":str(Z),"sha256":sha(Z),"bytes":Z.stat().st_size,"files":num,
        "actual_original_0002_cells":12,"actual_original_0003_cells":12,
        "0003_isolated_original_fragment_bridged":2,"original_0001":"UNMODIFIED","maps":"PAUSED",
        "XML_Offsets_Shadow":"BYTE_IDENTICAL","godot_XML_GPU_both":"PASS","cold_unzip_sha_source_native":"PASS",
        "human_art":"PENDING","original_PMD_game_and_VX_SBS":"NOT_TESTED"}
(R/"reports/P3_G8R4_DELIVERY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print("G8R4_COLD_RELEASE_VERIFIED",json.dumps(report,ensure_ascii=False),flush=True)
