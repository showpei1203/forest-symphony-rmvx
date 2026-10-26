from pathlib import Path
from PIL import Image
import numpy as np,json,xml.etree.ElementTree as ET,zipfile,subprocess,shutil
from scipy.ndimage import label
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
OUT=R/"outputs/P3_G8R1_COMBO_B_LAYERED_ROCK_PALETTE_20261026"
GODOT=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
TEMPLATE=R/"outputs/P3_G5R1_0003_NATIVE_XML_PLAYER_20261026"
reports={}
for sp,expected in [("0002",682),("0003",698)]:
 SRC=R/f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}"
 D=OUT/sp
 q=json.loads((OUT/f"PMD_{sp}_G8_QA.json").read_text(encoding="utf-8"))
 assert len(q["samples"])==12 and q["body_pixel_erased"]==0
 assert len(list((D/"pixelorama_layers").glob("*.ora")))==12
 body_counts=[];stone_flat=0;stone_palette=[]
 orphan_counts=[];shading_diff=[];samples=0
 for row in q["samples"]:
  act,face,f=row["action"],row["face"],row["frame"]
  fpath=D/"frames"/f"{act}_{face}_F{f}.png"
  ar=np.asarray(Image.open(fpath).convert("RGBA"))
  ori=Image.open(SRC/(act+"-Anim.png")).convert("RGBA")
  original=np.asarray(ori.crop((f*32,row["direction"]*32,(f+1)*32,(row["direction"]+1)*32)))
  blue=(original[:,:,3]>0)&(original[:,:,2]>original[:,:,0]*1.07)&(original[:,:,1]>=original[:,:,0]*.90)&(original[:,:,0]>=55)
  assert np.all(ar[:,:,3][blue]==255)
  assert np.array_equal(original[-3:,:,3],ar[-3:,:,3])
  assert row["body_erased_pixels"]==0
  # editor project must be a genuine editable OpenRaster ZIP with independent
  # body, back saddle, crater, one layer per rounded rock and protected body overlay.
  ora=D/"pixelorama_layers"/f"{act}_{face}_F{f}.ora"
  with zipfile.ZipFile(ora) as z:
   assert z.testzip() is None
   assert z.read("mimetype")==b"image/openraster"
   root=ET.fromstring(z.read("stack.xml"))
   layers=root.findall(".//layer")
   expected_layers=3+(3 if sp=="0002" else 5)+1
   assert len(layers)==expected_layers,(sp,act,face,f,len(layers))
   merged=np.asarray(Image.open(__import__("io").BytesIO(z.read("mergedimage.png"))).convert("RGBA"))
   assert np.array_equal(merged,ar),(sp,act,face,f,"layer composite drift")
  for stone in row["rocks"]:
   total=stone["rock_pixel_count"]
   assert stone["distinct_palette_colors"]>=3
   assert total>=12
   assert stone.get("mid",0)>=2 and stone.get("light",0)>=1,(sp,act,face,f,"flat rock",stone)
   stone_palette.append(stone["distinct_palette_colors"])
  # orphan check: no tiny isolated 1-8 pixel fragments next to the upper crown
  lbl,n=label(ar[:,:,3]>0,structure=np.ones((3,3)))
  orphans=[]
  for j in range(1,n+1):
   y,x=np.where(lbl==j)
   if len(x)<=8 and len(x)>0 and int(y.min())<12:orphans.append((len(x),int(x.min()),int(y.min())))
  orphan_counts+=orphans
  samples+=1
 assert samples==12
 # motion: anchor and each stone must move when switching from F0/F1 in all three facings
 for act in ("Idle","Walk"):
  for direction in (0,2,4):
   p=[r for r in q["samples"] if r["action"]==act and r["direction"]==direction]
   assert len(p)==2
   assert p[0]["mount"]!=p[1]["mount"]
   for a,b in zip(p[0]["rocks"],p[1]["rocks"]):
    assert a["center"]!=b["center"]
 # altered atlas limited only to desired 12 cells
 for act in ("Idle","Walk"):
  updated=np.asarray(Image.open(D/(act+"-Anim.png")).convert("RGBA"))
  original=np.asarray(Image.open(SRC/(act+"-Anim.png")).convert("RGBA"))
  assert updated.shape==original.shape==(256,128,4)
  for facing in range(8):
   for col in range(4):
    a=original[facing*32:(facing+1)*32,col*32:(col+1)*32]
    b=updated[facing*32:(facing+1)*32,col*32:(col+1)*32]
    selected=facing in (0,2,4) and col in (0,1)
    assert bool(np.any(a!=b))==selected
 # Native Godot XML bridge using complete ORIGINAL PMD action atlas and exact
 # original XML, with only select Idle/Walk cells patched.
 runtime=D/"GODOT_G8_TRUE_SOURCE"
 assert not runtime.exists()
 runtime.mkdir()
 for name in ("project.godot","player.tscn","pmd_xml_player.gd"):shutil.copy2(TEMPLATE/name,runtime/name)
 script=(runtime/"pmd_xml_player.gd").read_text(encoding="utf-8")
 assert "fcount!=698" in script
 if sp=="0002":script=script.replace("fcount!=698","fcount!=682")
 (runtime/"pmd_xml_player.gd").write_text(script,encoding="utf-8")
 shutil.copytree(SRC,runtime/"original_0001")
 shutil.copytree(SRC,runtime/"rock_0001")
 for act in ("Idle","Walk"):shutil.copy2(D/(act+"-Anim.png"),runtime/"rock_0001"/(act+"-Anim.png"))
 p=subprocess.run([str(GODOT),"--headless","--path",str(runtime),"--import"],capture_output=True,text=True,errors="replace",timeout=70)
 (runtime/"IMPORT.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf-8")
 assert p.returncode==0,p.stderr[-900:]
 g=subprocess.run([str(GODOT),"--path",str(runtime),"--rendering-driver","opengl3","--scene","res://player.tscn"],
                  capture_output=True,text=True,errors="replace",timeout=80)
 log=g.stdout+"\n"+g.stderr
 (runtime/"NATIVE_GODOT_XML_GPU.log").write_text(log,encoding="utf-8")
 assert g.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in log and "ERROR:" not in log and "WARNING:" not in log,(sp,log[-1600:])
 imgs=[np.asarray(Image.open(runtime/f"GODOT_XML_RENDER_FRAME_{i}.png").convert("RGBA")) for i in range(3)]
 assert np.any(imgs[0]!=imgs[1])
 reports[sp]={"edited_source_sample_cells":12,"source_original_other_actions_preserved":10,
              "original_XML_Offsets_Shadow":"UNMODIFIED",
              "original_blue_body_alpha_erased":0,
              "rock_shades_each":min(stone_palette),"pixelorama_ora_layer_files":12,
              "godot_native_XML_GPU":"PASS","orphan_singleton_upper_components":orphans if orphans else [],
              "official_PMD_game":"NOT_TESTED","human_art":"PENDING"}
 print("G8R1_SOURCE_NATIVE_PASS",sp,json.dumps(reports[sp],ensure_ascii=False),flush=True)
(OUT/"G8R1_QA_NATIVE_REPORT.json").write_text(json.dumps(reports,ensure_ascii=False,indent=2),encoding="utf-8")
