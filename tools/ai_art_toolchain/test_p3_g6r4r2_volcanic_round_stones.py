from pathlib import Path
from PIL import Image
import xml.etree.ElementTree as ET
import numpy as np, subprocess, shutil, json
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
A=R/"outputs/P3_G6R4R2_0002_0003_ROUNDED_SWAY_STONES_20261026"
OLD=R/"outputs/P3_G6R3_0002_0003_BACK_VOLCANO_20261026"
GODOT=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
report={}
for id,expected in (("0002",682),("0003",698)):
 src=R/f"outputs/P3_G{'4' if id=='0002' else '5'}_{id}_OFFICIAL_SOURCE_20261026/SOURCE_{id}"
 art=A/f"PMD_{id}_ROUND_STONES"
 base=OLD/f"NATIVE_GODOT_{id}"
 dst=A/f"NATIVE_GODOT_{id}"
 assert not dst.exists(),dst
 dst.mkdir()
 for x in ["project.godot","player.tscn","pmd_xml_player.gd"]:shutil.copy2(base/x,dst/x)
 shutil.copytree(src,dst/"original_0001")
 shutil.copytree(art,dst/"rock_0001")
 assert (dst/"original_0001/AnimData.xml").read_bytes()==(dst/"rock_0001/AnimData.xml").read_bytes()
 t=ET.parse(src/"AnimData.xml").getroot()
 assert len(t.findall(".//Anim"))==14
 count=0;actions=0;changes=0;stone_motion=0;motion_actions=0
 qa=json.loads((A/f"PMD_{id}_ROUND_STONES_QA.json").read_text(encoding="utf-8"))
 for act in qa["record"]:
  source=act["action"]
  matching=next(x for x in t.findall(".//Anim") if x.findtext("Name")==source)
  w,h=act["frame_dimensions"]
  assert w==int(matching.findtext("FrameWidth")) and h==int(matching.findtext("FrameHeight"))
  o=np.asarray(Image.open(src/(source+"-Anim.png")).convert("RGBA"))
  n=np.asarray(Image.open(art/(source+"-Anim.png")).convert("RGBA"))
  assert o.shape==n.shape and o.shape[1]==w*len(matching.find("Durations").findall("Duration"))
  assert len(act["motion_instances"])==o.shape[0]//h * o.shape[1]//w
  for t0 in act["motion_instances"]:
   row,col=t0["direction"],t0["frame"]
   prev=o[row*h:(row+1)*h,col*w:(col+1)*w]
   now=n[row*h:(row+1)*h,col*w:(col+1)*w]
   assert int(np.any(prev!=now,axis=2).sum())>=18
   assert np.array_equal(prev[-4:,:,3],now[-4:,:,3])
   for x in ("TOP","BOTTOM","LEFT","RIGHT"):
    e={"TOP":((now[0,:,3]>0)&(prev[0,:,3]==0)),
       "BOTTOM":((now[-1,:,3]>0)&(prev[-1,:,3]==0)),
       "LEFT":((now[:,0,3]>0)&(prev[:,0,3]==0)),
       "RIGHT":((now[:,-1,3]>0)&(prev[:,-1,3]==0))}[x]
    assert not np.any(e),(id,source,row,col,x)
   assert len(t0["rounded_boulders"])==(3 if id=="0002" else 5)
   assert t0["lava_pixels"]>=2
   count+=1;changes+=int(t0["changed_rgba_pixels"]>=18)
  actions+=1
  for dr in range(8):
   frames=[q for q in act["motion_instances"] if q["direction"]==dr]
   if len(frames)<2:continue
   buds={tuple(f["source_original_flower_centroid"]) for f in frames}
   derived={tuple(tuple(t) for t in f["rounded_boulders"]) for f in frames}
   if len(buds)>1:
    motion_actions+=1
    stone_motion+=int(len(derived)>1)
 assert actions==12 and count==expected and changes==expected,(id,actions,count,changes)
 assert stone_motion>0,(id,"No source-driven rock motion")
 print("SWAY_QA",id,"source_moving_action_directions",motion_actions,"rock_positions_followed",stone_motion,flush=True)
 imp=subprocess.run([str(GODOT),"--headless","--path",str(dst),"--import"],capture_output=True,text=True,errors="replace",timeout=80)
 (dst/"IMPORT.log").write_text(imp.stdout+"\n"+imp.stderr,encoding="utf-8")
 assert imp.returncode==0,(id,imp.stdout[-300:],imp.stderr[-300:])
 run=subprocess.run([str(GODOT),"--path",str(dst),"--rendering-driver","opengl3","--scene","res://player.tscn"],
                    capture_output=True,text=True,errors="replace",timeout=80)
 (dst/"NATIVE_GPU.log").write_text(run.stdout+"\n"+run.stderr,encoding="utf-8")
 combined=run.stdout+"\n"+run.stderr
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in combined,(id,combined[-1400:])
 assert "ERROR:" not in combined and "WARNING:" not in combined,(id,combined[-1400:])
 images=[np.asarray(Image.open(dst/f"GODOT_XML_RENDER_FRAME_{i}.png").convert("RGBA")) for i in range(3)]
 assert any(np.any(images[0]!=v) for v in images[1:]),(id,"GPU frames same")
 report[id]={"source_actions":actions,"all_frames_edited":count,"original_XML_Offsets_Shadow":"UNCHANGED",
             "original_motion_followed_frames":stone_motion,
             "original_motion_detected_frames":motion_actions,
             "native_Godot_XML":"PASS","native_GPU_render":"PASS","native_ERRORS_WARNINGS":0,
             "human_visual":"PENDING","original_PMD_loader":"NOT_TESTED"}
 (dst/"RESULT.json").write_text(json.dumps(report[id],ensure_ascii=False,indent=2),encoding="utf-8")
 print("PASS",id,json.dumps(report[id],ensure_ascii=False),flush=True)
(A/"G6R4R1_NATIVE_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
