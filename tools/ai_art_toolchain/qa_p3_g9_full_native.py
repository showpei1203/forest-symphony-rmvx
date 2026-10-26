from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib,xml.etree.ElementTree as ET,shutil,subprocess
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
OUT=R/"outputs/P3_G9_FULL_0001_0002_0003_EVOLUTION_20261027"
REPORT={}
for sp in ("0001","0002","0003"):
 original=R/("outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026/original_0001" if sp=="0001" else f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}")
 modified=OUT/sp
 assert modified.exists()
 meta=ET.parse(original/"AnimData.xml").getroot().findall(".//Anim")
 assert (modified/"AnimData.xml").read_bytes()==(original/"AnimData.xml").read_bytes()
 count=0;sheet=0;change=0;source_body_erased=0;crop_issues=0;exact_preserved=0;action_rows=[]
 for m in meta:
  if m.findtext("CopyOf"):continue
  act=m.findtext("Name")
  fw,fh=int(m.findtext("FrameWidth")),int(m.findtext("FrameHeight"))
  nf=len(m.find("Durations").findall("Duration"))
  a=np.asarray(Image.open(original/(act+"-Anim.png")).convert("RGBA"))
  b=np.asarray(Image.open(modified/(act+"-Anim.png")).convert("RGBA"))
  assert a.shape==b.shape and a.shape[1]==nf*fw and a.shape[0]%fh==0,(sp,act,a.shape,b.shape,fw,fh,nf)
  dirs=a.shape[0]//fh
  local_change=0
  for dr in range(dirs):
   for f in range(nf):
    oa=a[dr*fh:(dr+1)*fh,f*fw:(f+1)*fw];bb=b[dr*fh:(dr+1)*fh,f*fw:(f+1)*fw]
    delta=int(np.any(oa!=bb,axis=2).sum())
    if sp!="0001":assert delta>=10,(sp,act,dr,f,"NO_MORPH",delta)
    change+=delta;local_change+=delta
    rgb=oa[:,:,:3].astype(np.int16);alpha=oa[:,:,3]>0
    blue=alpha&(rgb[:,:,2]>rgb[:,:,0]*1.07)&(rgb[:,:,1]>=rgb[:,:,0]*.90)&(rgb[:,:,0]>=55)
    if sp!="0001":
     removed=int((blue & (bb[:,:,3]==0)).sum())
     if sp=="0003" and act=="Idle" and dr==4 and f==1:
      # Approved G8R5 surgical repair removed 2 ORIGINAL petal junk pixels
      # incorrectly classified as cyan "body" at right upper exterior.
      # The user ACCEPTED that specific correction. DO NOT restore them.
      assert removed==2,(sp,act,dr,f,"APPROVED_G8R5_EXCEPTION_DRIFT",removed)
      Y,X=np.indices(blue.shape)
      true_actor=blue&(X>=8)&(X<=23)&(Y>=15)
      assert not np.any(true_actor&(bb[:,:,3]==0)),(sp,act,dr,f,"REAL_BODY_DAMAGED")
     else:
      assert removed==0,(sp,act,dr,f,"BODY_PIXEL_ERASED",removed)
     source_body_erased+=removed
    assert np.array_equal(oa[-3:,:,3],bb[-3:,:,3]),(sp,act,dr,f,"BOTTOM_FOOT")
    assert not np.any((bb[0,:,3]>0)&(oa[0,:,3]==0)) and not np.any((bb[-1,:,3]>0)&(oa[-1,:,3]==0)) and not np.any((bb[:,0,3]>0)&(oa[:,0,3]==0)) and not np.any((bb[:,-1,3]>0)&(oa[:,-1,3]==0)),(sp,act,dr,f,"BORDER_SPILL")
    if sp in ("0002","0003") and act in ("Idle","Walk") and dr in (0,2,4) and f in (0,1):
     ok=R/("outputs/P3_G8R4_AUTHENTIC_FRAME_OUTLINE_MAGMA_20261026/0002" if sp=="0002" else "deliveries/P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX_20261027/G8R5_SAMPLE_0003")
     baseline=np.asarray(Image.open(ok/(act+"-Anim.png")).convert("RGBA"))[dr*fh:(dr+1)*fh,f*fw:(f+1)*fw]
     assert np.array_equal(bb,baseline),(sp,act,dr,f,"USER_APPROVED_POSE_DRIFT")
     exact_preserved+=1
    count+=1
  action_rows.append({"action":act,"sheet_dims":[a.shape[1],a.shape[0]],"frame_dims":[fw,fh],"directions":dirs,"frames_each_direction":nf,"total_frames":dirs*nf,"changed_RGBA_pixels":local_change})
  sheet+=1
 for file in original.glob("*"):
  if file.name.endswith(("-Offsets.png","-Shadow.png")):
   assert file.read_bytes()==(modified/file.name).read_bytes(),(sp,file.name,"OFFSETS_SHADOW_CHANGED")
 if sp=="0001":
  # the user-accepted G3R1 original art must have NO changes during current run
  reference=R/"outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026/rock_0001"
  for f in reference.glob("*-Anim.png"):assert f.read_bytes()==(modified/f.name).read_bytes(),(sp,f.name,"ACCEPTED_0001_CHANGED")
 else:
  assert count==(682 if sp=="0002" else 698) and exact_preserved==12
 REPORT[sp]={"real_animation_atlases":sheet,"frames":count,"xml_named_actions":len(meta),
             "source_body_alpha_erased_pixels":source_body_erased,"edited_pixel_total":change,
             "accepted_keyframes_byte_equal":exact_preserved,"original_xml_offsets_shadow_byte_equal":True,
             "native_sheet_cell_dims_preserved":True,"original_foot_and_frame_border":"PASS",
             "human_art":"PENDING_NEW_ACTIONS" if sp!="0001" else "USER_ACCEPTED_G3R1_REUSED",
             "by_action":action_rows}
 print("P3_G9_FULL_SOURCE_QA_PASS",sp, "actions",sheet,"frames",count,"user_approved_kept",exact_preserved,"changed_pixels",change,flush=True)
(OUT/"G9_ALL_ACTION_SOURCE_QA.json").write_text(json.dumps(REPORT,ensure_ascii=False,indent=2),encoding="utf-8")
G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
T=R/"outputs/P3_G5R1_0003_NATIVE_XML_PLAYER_20261026"
for sp in ("0002","0003"):
 D=OUT/f"GODOT_FULL_{sp}";D.mkdir()
 for f in ("project.godot","player.tscn","pmd_xml_player.gd"):shutil.copy2(T/f,D/f)
 scr=D/"pmd_xml_player.gd"
 txt=scr.read_text(encoding="utf-8")
 assert "fcount!=698" in txt
 if sp=="0002":txt=txt.replace("fcount!=698","fcount!=682")
 scr.write_text(txt,encoding="utf-8")
 original=R/f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}"
 shutil.copytree(original,D/"original_0001")
 shutil.copytree(OUT/sp,D/"rock_0001")
 imp=subprocess.run([str(G),"--headless","--path",str(D),"--import"],capture_output=True,text=True,errors="replace",timeout=85)
 (D/"GODOT_IMPORT.log").write_text(imp.stdout+"\n"+imp.stderr,encoding="utf-8")
 assert imp.returncode==0,(sp,imp.stderr[-1200:])
 run=subprocess.run([str(G),"--path",str(D),"--rendering-driver","opengl3","--scene","res://player.tscn"],capture_output=True,text=True,errors="replace",timeout=85)
 output=run.stdout+"\n"+run.stderr
 (D/"GODOT_NATIVE_FULL_XML_GPU.log").write_text(output,encoding="utf-8")
 assert run.returncode==0 and "P3_NATIVE_GODOT_XML_GPU_PASS" in output and "ERROR:" not in output and "WARNING:" not in output,(sp,output[-1900:])
 for n in range(3):assert (D/f"GODOT_XML_RENDER_FRAME_{n}.png").exists()
 print("P3_G9_NATIVE_GODOT_GPU_PASS",sp,flush=True)
(OUT/"G9_NATIVE_TECH_PASS.json").write_text(json.dumps({"0001":"ACCEPTED_PREVIOUS_NATIVE_GODOT_PASS_UNMODIFIED","0002":"NEW_FULL_ATLAS_GODOT_PASS","0003":"NEW_FULL_ATLAS_GODOT_PASS","original_PMD_game":"NOT_TESTED","RPG_VX_SBS":"NOT_TESTED","full_animation_visual":"PENDING_HUMAN"},ensure_ascii=False,indent=2),encoding="utf-8")
