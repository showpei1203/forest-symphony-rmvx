from pathlib import Path
from PIL import Image
import numpy as np,xml.etree.ElementTree as ET
import json,hashlib,subprocess,shutil
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
ART=R/"outputs/P3_G6R3_0002_0003_BACK_VOLCANO_20261026"
TEMPLATE=R/"outputs/P3_G5R1_0003_NATIVE_XML_PLAYER_20261026"
GODOT=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
for dex in (2,3):
 key=f"{dex:04d}"
 expected=682 if dex==2 else 698
 SR=R/f"outputs/P3_G{'4' if dex==2 else '5'}_{key}_OFFICIAL_SOURCE_20261026/SOURCE_{key}"
 MOD=ART/f"PMD_{key}_BACK_VOLCANO"
 D=ART/f"NATIVE_GODOT_{key}"
 assert not D.exists()
 D.mkdir()
 shutil.copytree(SR,D/"original_0001")
 shutil.copytree(MOD,D/"rock_0001")
 for fn in ("project.godot","player.tscn","pmd_xml_player.gd"):
  shutil.copy2(TEMPLATE/fn,D/fn)
 gd=D/"pmd_xml_player.gd";s=gd.read_text(encoding="utf-8")
 assert "fcount!=698" in s
 s=s.replace("fcount!=698",f"fcount!={expected}")
 gd.write_text(s,encoding="utf-8")
 manifest=json.loads((ART/f"PMD_{key}_SOURCE_QA.json").read_text(encoding="utf-8"))
 assert manifest["individual_cells"]==expected
 assert manifest["original_xml_offsets_shadow_unchanged"] and manifest["frame_count_dimensions_positions_unchanged"]
 assert manifest["caldera_hot_cells"]==expected
 assert manifest["real_action_sheets"]==12 and manifest["original_named_actions"]==14
 assert SR.joinpath("AnimData.xml").read_bytes()==MOD.joinpath("AnimData.xml").read_bytes()
 root=ET.parse(SR/"AnimData.xml").getroot()
 cells=0;morph=0;changed=0
 for a in root.findall(".//Anim"):
  if a.findtext("CopyOf"):continue
  name=a.findtext("Name");w=int(a.findtext("FrameWidth"));h=int(a.findtext("FrameHeight"))
  old=np.asarray(Image.open(SR/(name+"-Anim.png")).convert("RGBA"))
  new=np.asarray(Image.open(MOD/(name+"-Anim.png")).convert("RGBA"))
  assert old.shape==new.shape
  assert old.shape[1]//w==len(a.find("Durations").findall("Duration"))
  assert old.shape[0]%h==0
  for kind in ("Offsets","Shadow"):
   f=name+"-"+kind+".png"
   assert SR.joinpath(f).read_bytes()==MOD.joinpath(f).read_bytes()
  for y in range(0,old.shape[0],h):
   for x in range(0,old.shape[1],w):
    u=old[y:y+h,x:x+w];v=new[y:y+h,x:x+w]
    assert not(np.any((v[0,:,3]>0)&(u[0,:,3]==0)) or np.any((v[-1,:,3]>0)&(u[-1,:,3]==0)) or np.any((v[:,0,3]>0)&(u[:,0,3]==0)) or np.any((v[:,-1,3]>0)&(u[:,-1,3]==0)))
    assert int(np.any(v!=u,axis=2).sum())>=18
    morph+=int((u[:,:,3]!=v[:,:,3]).sum()>=2)
    changed+=1;cells+=1
 assert cells==expected
 native=subprocess.run([str(GODOT),"--headless","--path",str(D),"--import"],capture_output=True,text=True,errors="replace",timeout=75)
 (D/"GODOT_IMPORT.log").write_text(native.stdout+"\n"+native.stderr,encoding="utf-8")
 assert native.returncode==0,(key,native.stderr[-1500:])
 run=subprocess.run([str(GODOT),"--path",str(D),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=75)
 stdout=run.stdout+"\n"+run.stderr
 (D/"GODOT_NATIVE_XML_GPU.log").write_text(stdout,encoding="utf-8")
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in stdout and "ERROR:" not in stdout and "WARNING:" not in stdout,(key,stdout[-1200:])
 captures=[]
 for i in range(3):
  fn=D/(f"GODOT_XML_RENDER_FRAME_{i}.png");assert fn.is_file()
  captures.append(np.asarray(Image.open(fn).convert("RGBA")))
 assert all(np.any(captures[0]!=f) for f in captures[1:])
 result={"id":key,"action_names":14,"actual_action_sheets":12,"source_edited_cells":cells,
  "source_material_changed_cells":changed,"new_alpha_edge_changed_cells":morph,
  "crater_hot_all_cells":True,"original_xml_offsets_shadows_byte_equal":True,
  "Godot_real_XML_parser":"PASS","Godot_native_GPU_3_frames":"PASS","engine_ERRORS_WARNINGS":0,
  "original_PMD_game":"NOT_TESTED","actual_VX_SBS":"NOT_TESTED","human_art":"PENDING"}
 (D/"G6R3_NATIVE_TEST_RESULT.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
 print("PMD_"+key+"_TRUE_NATIVE_TEST",json.dumps(result,ensure_ascii=False),flush=True)
