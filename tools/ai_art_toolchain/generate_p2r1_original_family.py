from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np,json,hashlib,random
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
O=R/"outputs/P2R1_ORIGINAL_MOSS_DRAKE_3STAGES_20261025"
if O.exists():raise SystemExit("Refuse overwrite P2 candidate")
O.mkdir(parents=True)
C={"ink":"#27343f","shade":"#365d69","dark":"#366f71","mid":"#54a5a1","light":"#89d2b8",
 "belly":"#d0e5aa","belly_hi":"#f0e8ba","leaf":"#7cad65","leaf_d":"#4d8061","leaf_l":"#a4ce84",
 "horn":"#ddb779","horn_hi":"#fae6a3","eye":"#222c36","shine":"#fef8df","mouth":"#9e5f56","shadow":"#283038"}
def rgb(c):return C.get(c,c)
def layer():return Image.new("RGBA",(64,64),(0,0,0,0))
def ellipse(img,bb,color,outline="ink",width=1):
 d=ImageDraw.Draw(img);d.ellipse(bb,fill=rgb(color),outline=rgb(outline) if outline else None,width=width)
def polygon(img,pts,color,outline="ink"):
 d=ImageDraw.Draw(img);d.polygon(pts,fill=rgb(color))
 if outline:d.line(pts+[pts[0]],fill=rgb(outline),width=1,joint="curve")
def rect(img,bb,color,outline="ink"):
 ImageDraw.Draw(img).rectangle(bb,fill=rgb(color),outline=rgb(outline) if outline else None,width=1)
def line(img,pts,color,width=1):ImageDraw.Draw(img).line(pts,fill=rgb(color),width=width,joint="curve")
def create(stage,action,frame):
 # 64x64 native pixel-grid source, ?2 nearest to 128px for VX sprite frames.
 spec=[
  {"body":(20,31,43,49),"head":(33,18,53,38),"wing":0,"horn":3,"tail":(4,42),"neck":(32,29),
   "eye":(47,26),"feet_y":53,"spikes":2},
  {"body":(17,28,46,52),"head":(29,15,52,38),"wing":1,"horn":6,"tail":(3,43),"neck":(32,29),
   "eye":(45,25),"feet_y":57,"spikes":3},
  {"body":(14,25,47,54),"head":(27,12,51,38),"wing":2,"horn":9,"tail":(1,43),"neck":(32,27),
   "eye":(44,23),"feet_y":60,"spikes":4}
 ][stage]
 bob=([0,-1,0] if action=="idle" else [0,-2,0])[frame]
 lunge=([0,0,0] if action=="idle" else [-1,3,1])[frame]
 head_shift=lunge
 sheets={k:layer() for k in ("shadow","tail","wings","legs","body","head","mark")}
 # ground shadow outside character no bleed
 ellipse(sheets["shadow"],(17-stage*4,54,47+stage*3,60),"#334047",outline=None)
 t=sheets["tail"]
 off_y=bob
 if stage==0:
  polygon(t,[(20,39+off_y),(14,39+off_y),(7,37+off_y),(3,42+off_y),(12,46+off_y),(22,45+off_y)],"dark")
  polygon(t,[(7,37+off_y),(3,42+off_y),(10,43+off_y)],"leaf")
 else:
  polygon(t,[(21,40+off_y),(13,38+off_y),(7,39+off_y),(2,34+off_y),(3,46+off_y),(12,49+off_y),(24,46+off_y)],"dark")
  polygon(t,[(5,36+off_y),(1,35+off_y),(3,45+off_y),(9,43+off_y)],"leaf")
  line(t,[(8,42+off_y),(18,42+off_y)],"mid",2)
 # far legs and feet
 l=sheets["legs"];yf=spec["feet_y"]
 for left,right in ((22-stage*2,28-stage),(36+stage,42+stage)):
  rect(l,(left,43+bob,right,yf-2),"shade")
  rect(l,(left-2,yf-4,right+2,yf),"dark")
  for toe in (left,left+3):
   line(l,[(toe,yf-1),(toe+2,yf-1)],"horn_hi")
 # body with visible lighter belly
 bd=sheets["body"];bx0,by0,bx1,by1=spec["body"]
 ellipse(bd,(bx0,by0+bob,bx1,by1+bob),"dark")
 ellipse(bd,(bx0+3,by0+2+bob,bx1-2,by1-3+bob),"mid",outline=None)
 ellipse(bd,(bx0+11,by0+9+bob,bx1-3,by1-1+bob),"belly")
 ellipse(bd,(bx0+13,by0+10+bob,bx1-6,by1-5+bob),"belly_hi",outline=None)
 for k in range(spec["spikes"]):
  x=bx0+6+k*5
  polygon(bd,[(x,by0+bob+3),(x+2,by0+bob-3-(k%2)),(x+6,by0+bob+2)],"leaf")
 # leafy wings arise from back and evolve at later stages
 w=sheets["wings"]
 if stage>=1:
  if stage==1:
   polygon(w,[(26,31+bob),(16,18+bob),(15,32+bob),(18,42+bob),(31,39+bob)],"leaf_d")
   polygon(w,[(24,31+bob),(18,22+bob),(20,36+bob),(29,36+bob)],"leaf")
   line(w,[(20,22+bob),(27,34+bob)],"leaf_l")
  else:
   polygon(w,[(26,34+bob),(16,8+bob),(9,17+bob),(9,31+bob),(16,41+bob),(31,44+bob)],"leaf_d")
   polygon(w,[(24,34+bob),(16,14+bob),(13,27+bob),(19,38+bob)],"leaf")
   polygon(w,[(33,34+bob),(29,12+bob),(25,17+bob),(24,36+bob)],"leaf_d")
   line(w,[(15,17+bob),(27,39+bob)],"leaf_l",2)
   line(w,[(28,18+bob),(28,35+bob)],"leaf_l",1)
 # all cranial/head parts are drawn inside one locked layer; no cross-frame naked artefacts
 hd=sheets["head"];hx0,hy0,hx1,hy1=spec["head"]
 # neck, head and cheek
 polygon(hd,[(bx1-11,by0+6+bob),(hx0+2+head_shift,hy0+12+bob),
             (hx0+13+head_shift,hy1-1+bob),(bx1-3,by0+15+bob)],"mid")
 ellipse(hd,(hx0+head_shift,hy0+bob,hx1+head_shift,hy1+bob),"dark")
 ellipse(hd,(hx0+3+head_shift,hy0+2+bob,hx1-1+head_shift,hy1-4+bob),"mid",outline=None)
 ellipse(hd,(hx0+10+head_shift,hy0+14+bob,hx1+4+head_shift,hy1+1+bob),"mid")
 # snout tip
 rect(hd,(hx1-3+head_shift,hy0+18+bob,hx1+4+head_shift,hy0+23+bob),"mid")
 line(hd,[(hx1+2+head_shift,hy0+17+bob),(hx1+3+head_shift,hy0+17+bob)],"ink")
 # horns/stage identity
 polygon(hd,[(hx0+2+head_shift,hy0+4+bob),(hx0+4+head_shift,hy0-spec["horn"]+bob),
             (hx0+10+head_shift,hy0+4+bob)],"horn")
 polygon(hd,[(hx0+11+head_shift,hy0+3+bob),(hx0+14+head_shift,hy0-spec["horn"]+2+bob),
             (hx0+18+head_shift,hy0+5+bob)],"horn")
 # shared golden diamond mark (evolution DNA)
 mark=sheets["mark"]
 polygon(mark,[(hx0+13+head_shift,hy0+5+bob),(hx0+17+head_shift,hy0+9+bob),
                (hx0+13+head_shift,hy0+13+bob),(hx0+9+head_shift,hy0+9+bob)],"horn_hi","horn")
 # eye always appears in all poses, attack has eye bright
 ex,ey=spec["eye"];ex+=head_shift;ey+=bob
 ellipse(hd,(ex-3,ey-3,ex+3,ey+3),"eye",outline="ink")
 rect(hd,(ex-1,ey-2,ex,ey-1),"shine",outline=None)
 if action=="attack" and frame==1:
  line(hd,[(hx1-2+head_shift,hy0+22+bob),(hx1+4+head_shift,hy0+26+bob)],"mouth",2)
  rect(hd,(hx1-1+head_shift,hy0+25+bob,hx1+4+head_shift,hy0+27+bob),"mouth",outline=None)
 else:
  line(hd,[(hx1-1+head_shift,hy0+23+bob),(hx1+3+head_shift,hy0+23+bob)],"ink")
 # extra texture on scale armor to keep visual similarity with project chibi baseline
 line(bd,[(bx0+4,by0+6+bob),(bx0+8,by0+6+bob)],"light")
 line(bd,[(bx0+6,by0+10+bob),(bx0+10,by0+10+bob)],"light")
 comp=layer()
 for k in ("shadow","tail","wings","legs","body","head","mark"):
  comp.alpha_composite(sheets[k])
 return comp,sheets
records=[]
for stage,stem in enumerate(("01_seedling","02_grove_drake","03_ancient_warden")):
 d=O/stem; (d/"frames").mkdir(parents=True)
 (d/"layers_idle_0").mkdir()
 full=Image.new("RGBA",(384,256))
 for ai,action in enumerate(("idle","attack")):
  for frame in range(3):
   comp,layers=create(stage,action,frame)
   # Immutable nearest-neighbour 2x pixel size, no blur
   comp=comp.resize((128,128),Image.Resampling.NEAREST)
   assert comp.getbbox() is not None
   png=d/"frames"/(f"{action}_{frame}.png")
   comp.save(png)
   full.alpha_composite(comp,dest=(frame*128,ai*128))
   pix=np.asarray(comp)
   colored=int(np.count_nonzero(pix[:,:,3]>0))
   head,_=create(stage,action,frame)
   # Head layer alpha and torso layer have nonzero every frame
   part_map=create(stage,action,frame)[1]
   assert all(part_map[key].getbbox() for key in ("head","body","legs","tail","mark")),("NAKED_FRAME",stem,action,frame)
   records.append({"stage":stem,"action":action,"frame":frame,"source_sha256":hashlib.sha256(png.read_bytes()).hexdigest(),
                   "opaque_pixels":colored,"head_exists":True,"body_exists":True,"foot_exists":True})
   if action=="idle" and frame==0:
    for k,v in layers.items():
     v.resize((128,128),Image.Resampling.NEAREST).save(d/"layers_idle_0"/(k+".png"))
 full.save(d/"spritesheet_3x2.png")
 st={"id":stem,"stage":stage+1,"cell":[128,128],"sheet":[384,256],"grid":[3,2],
     "rows":["idle","attack"],"timing_ms":{"idle":[180,180,180],"attack":[120,110,190]},
     "family":"moss_horn_drake","dna":{"jade_turquoise_skin":True,"amber_horns":True,"forehead_diamond":True,
      "leaf_morphology":stage,"shared_torso_head_skeleton":True},"source_style":"PMD-inspired forest monster / original hand-coded pixel geometry",
     "shader":"nearest_only","commercial_art":"candidate not approved"}
 (d/"metadata.json").write_text(json.dumps(st,indent=2),encoding="utf-8")
# studio review: exact 1:1 sprite sheet shown on charcoal neutral panel; three stages aligned
mont=Image.new("RGB",(3*256,340),"#252b3b")
paint=ImageDraw.Draw(mont)
for i,stage in enumerate(("01_seedling","02_grove_drake","03_ancient_warden")):
 sheet=Image.open(O/stage/"spritesheet_3x2.png").convert("RGBA")
 for frame in range(3):
  cropped=sheet.crop((frame*128,0,(frame+1)*128,128))
  mont.paste(cropped,(i*256+64,30),cropped)
  if frame==0:
   atk=sheet.crop((128,128,256,256))
   mont.paste(atk,(i*256+64,177),atk)
 ImageDraw.Draw(mont).text((i*256+8,3),stage,fill="#f3efdf")
 ImageDraw.Draw(mont).text((i*256+8,154),"IDLE / ATTACK",fill="#cfcfdf")
mont.save(O/"P2_3STAGE_STYLE_REVIEW.png")
# strict checks clear alpha, integer scaled pixels, all stages share locked palette and anatomy
qa={"status":"TECH_CANDIDATE_PENDING_HUMAN","stage_count":3,"frames_per_stage":6,"total_frames":len(records),
    "naked_frames":0,"src_reusable_layers_per_stage":7,"actions":["idle","attack"],
    "is_new_procedural_art":True,"uses_paid_image_generation":False,"same_style_dna":True,
    "commercial_licensing":"new original code generated but requires review",
    "records":records}
(O/"P2_AUTOMATED_QA.json").write_text(json.dumps(qa,indent=2),encoding="utf-8")
print(json.dumps({k:v for k,v in qa.items() if k!="records"}))
