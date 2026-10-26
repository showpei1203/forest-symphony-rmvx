from pathlib import Path
import shutil,subprocess,json,hashlib,xml.etree.ElementTree as ET
from PIL import Image
import numpy as np
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
SRC=R/"outputs/P3_G4_0002_OFFICIAL_SOURCE_20261026/SOURCE_0002"
MOD=R/"outputs/P3_G4R1_0002_VOLCANIC_EVOLUTION_20261026/VOLCANIC_0002"
OLD=R/"outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026"
OUT=R/"outputs/P3_G4R1_0002_NATIVE_XML_PLAYER_20261026"
assert not OUT.exists()
OUT.mkdir()
for name in ("project.godot","player.tscn","pmd_xml_player.gd"):
 shutil.copy2(OLD/name,OUT/name)
shutil.copytree(SRC,OUT/"original_0001")
shutil.copytree(MOD,OUT/"rock_0001")
s=(OUT/"pmd_xml_player.gd").read_text(encoding="utf-8")
assert 'declared.size()!=36' in s and 'actual.size()!=34' in s and 'if fcount!=1123' in s
s=s.replace('declared.size()!=36','declared.size()!=14').replace('actual.size()!=34','actual.size()!=12').replace('if fcount!=1123','if fcount!=682')
(OUT/"pmd_xml_player.gd").write_text(s,encoding="utf-8")
g=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
initial=subprocess.run([str(g),"--headless","--path",str(OUT),"--import"],capture_output=True,text=True,errors="replace",timeout=50)
(OUT/"GODOT_IMPORT.log").write_text(initial.stdout+"\n"+initial.stderr,encoding="utf-8")
if initial.returncode!=0:raise RuntimeError("Godot import FAIL "+initial.stderr[-1500:])
p=subprocess.run([str(g),"--path",str(OUT),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=70)
log=p.stdout+"\n"+p.stderr
(OUT/"GODOT_NATIVE_XML_RENDER.log").write_text(log,encoding="utf-8")
assert p.returncode==0,log[-1500:]
assert "P3_NATIVE_GODOT_XML_STRUCTURE_PASS" in log and "P3_NATIVE_GODOT_XML_GPU_PASS" in log,log[-1500:]
assert "ERROR:" not in log and "WARNING:" not in log,log[-1500:]
frames=[]
for k in range(3):
 img=OUT/(f"GODOT_XML_RENDER_FRAME_{k}.png")
 assert img.is_file()
 frames.append(np.asarray(Image.open(img).convert("RGBA")))
assert all(np.any(frames[0]!=x) for x in frames[1:])
manifest=json.loads((R/"outputs/P3_G4R1_0002_VOLCANIC_EVOLUTION_20261026/P3_G4_0002_MORPH_QA.json").read_text(encoding="utf-8"))
assert manifest["real_actions"]==12 and manifest["total_frames"]==682 and manifest["actual_morphology_changed_cells"]==682
root=ET.parse(SRC/"AnimData.xml").getroot()
assert len(root.findall(".//Anim"))==14
for p in SRC.glob("*.png"):
 fn=MOD/p.name
 assert fn.is_file()
 if p.name.endswith(("-Offsets.png","-Shadow.png")):assert fn.read_bytes()==p.read_bytes()
assert (SRC/"AnimData.xml").read_bytes()==(MOD/"AnimData.xml").read_bytes()
result={"engine":"Godot native XMLParser 4.7.2 OpenGL", "xml_names":14,"real_actions":12,"cells":682,
 "native_XMLParser":"PASS","native_GPU":"PASS","native_frame_delta":"PASS","zero_WARNING_ERROR":"PASS",
 "original_xml_offset_shadow_unchanged":"PASS","human_visual":"PENDING",
 "actual_original_PMD_game":"NOT_TESTED","original_VX_Tankentai_SBS":"NOT_TESTED"}
(OUT/"P3_G4_0002_NATIVE_GODOT_RESULT.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
print("NATIVE_P3_G4_0002",json.dumps(result,ensure_ascii=False),flush=True)
