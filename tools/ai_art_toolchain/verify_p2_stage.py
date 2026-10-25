from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib,sys
ROOT=Path(__file__).resolve().parent
F=ROOT/"P2_family"
issues=[]
def gate(name,ok):
 if not ok:issues.append(name)
 print(("PASS " if ok else "FAIL ")+name)
qa=json.loads((F/"P2_AUTOMATED_QA.json").read_text(encoding="utf-8"))
gate("3stages_18frames_7source_layers",qa["stage_count"]==3 and qa["total_frames"]==18 and qa["src_reusable_layers_per_stage"]==7)
for i,name in enumerate(("01_seedling","02_grove_drake","03_ancient_warden")):
 d=F/name
 meta=json.loads((d/"metadata.json").read_text(encoding="utf-8"))
 sh=Image.open(d/"spritesheet_3x2.png").convert("RGBA")
 gate(name+"_sheet_size",sh.size==(384,256) and meta["grid"]==[3,2])
 for a,aname in enumerate(("idle","attack")):
  for frame in range(3):
   p=d/"frames"/(aname+"_"+str(frame)+".png")
   sprite=Image.open(p).convert("RGBA")
   tile=sh.crop((frame*128,a*128,frame*128+128,a*128+128))
   pixels=int(np.count_nonzero(np.asarray(sprite)[:,:,3]))
   gate(name+"_"+aname+str(frame)+"_nonempty_sheet_cell",sprite.size==(128,128) and pixels>=650 and np.array_equal(np.asarray(sprite),np.asarray(tile)))
   gate(name+"_"+aname+str(frame)+"_not_cropped_edge",int(np.max(np.asarray(sprite)[0,:,3]))==0 and int(np.max(np.asarray(sprite)[-1,:,3]))==0 and int(np.max(np.asarray(sprite)[:,0,3]))==0 and int(np.max(np.asarray(sprite)[:,-1,3]))==0)
 base=Image.new("RGBA",(128,128))
 for lname in ("shadow","tail","wings","legs","body","head","mark"):
  p=d/"layers_idle_0"/(lname+".png")
  assert p.exists()
  base.alpha_composite(Image.open(p).convert("RGBA"))
 gate(name+"_first_frame_is_composite_of_layers",np.array_equal(np.asarray(base),np.asarray(Image.open(d/"frames/idle_0.png").convert("RGBA"))))
# native engine real graphics, no first-run missing texture false positive
gpu={}
for f in ("IDLE0","IDLE1","ATTACK1"):
 p=F/("P2_NATIVE_GPU_"+f+".png")
 gate("godot_gpu_"+f+"_exists",p.exists() and p.stat().st_size>5000)
 if p.exists():gpu[f]=np.asarray(Image.open(p).convert("RGBA"),dtype=np.uint8)
if len(gpu)==3:
 for f in ("IDLE1","ATTACK1"):
  v=int(np.any(gpu["IDLE0"]!=gpu[f],axis=2).sum())
  gate("real_gpu_animation_changed_"+f,v>100)
 log=(ROOT/"reports/P2_NATIVE_GPU_CAPTURE_RETRY.log").read_bytes()
 txt=log.decode("utf-16" if log.startswith(b"\xff\xfe") else "utf-8-sig",errors="replace")
 gate("real_native_opengl3_and_3captures","AMD Radeon RX 6700 XT" in txt and all("P2_REAL_GPU_CAPTURE_OK "+f in txt for f in ("IDLE0","IDLE1","ATTACK1")) and "ERROR:" not in txt)
status={"status":"TECH_CANDIDATE_HUMAN_ART_PENDING" if not issues else "FAIL","issues":issues,"actions":["idle","attack"],"stages":3,"total_frames":18,"godot_native":True,"vx_sbs_integration":"NOT_YET_TESTED","human_visual":"PENDING"}
(ROOT/"VERIFY_P2_RESULT.json").write_text(json.dumps(status,indent=2),encoding="utf-8")
print(json.dumps(status))
if issues:sys.exit(1)
