from pathlib import Path
from PIL import Image
import numpy as np
import math,json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A10_ONE_MASTER_RIG")
config={"T1_forest_scout":{"shape":[96,112],"anchor":[48,104],"idle":8,"walk":8,"run":8,"attack":8,"hurt":6,"jump":8},
"T2_moss_antler":{"shape":[96,96],"anchor":[48,88],"idle":8,"walk":8,"attack":8,"hurt":6,"faint":8}}
def produce(master,kind,action,i,n,W,H):
 a=np.asarray(master,dtype=np.uint8);h,w=a.shape[:2]
 y,x=np.mgrid[:H,:W].astype(float)
 lx=x-(W-w)//2
 ly=y-((H-h)//2+(H-h)//4)
 t=2*math.pi*i/n;s=math.sin(t);c=math.cos(t)
 dx=np.zeros((H,W));dy=np.zeros((H,W))
 if kind=="T1_forest_scout":
  legs=np.clip((ly-45)/22,0,1);side=np.tanh((lx-32)/4)
  arms=np.exp(-((ly-47)/13)**2)*np.clip((np.abs(lx-32)-11)/6,0,1)
  head=np.clip((38-ly)/18,0,1)
  if action=="idle":
   dy+=.9*c*np.exp(-((ly-37)/24)**2);dx+=.7*s*head;dy+=.35*s*head
  elif action in ("walk","run"):
   size=2.9 if action=="run" else 2.
   dx+=size*s*legs*side;dy+=(-1.9 if action=="run" else -1.1)*np.maximum(0,s*side)*legs
   dx+=-1.7*s*arms*side;dy+=(.95 if action=="run" else .55)*abs(s);dx+=.65*s*head
  elif action=="attack":
   pose=[0,-.4,.4,3.,5.,4.,2.,.2][i]
   dx+=pose*np.clip((56-ly)/45,0,1)
   dx+=pose*.6*np.exp(-((lx-45)/11)**2-((ly-48)/14)**2)
   dy+=[0,1,1,2,2,1,0,0][i]
  elif action=="hurt":
   dx+=[0,-2,-5,-4,-2,0][i]*np.clip((57-ly)/50,0,1)
   dy+=[0,1,2,2,1,0][i]
  elif action=="jump":
   up=[0,2,6,11,13,10,5,0][i]
   dy-=up;dx+=[0,1,2,2,2,1,0,0][i]*head
   dy-=[0,.5,1.5,2,3,1.5,.5,0][i]*legs
 else:
  legs=np.clip((ly-37)/17,0,1);front=np.clip((34-lx)/13,0,1);back=np.clip((lx-34)/13,0,1)
  head=np.exp(-((lx-23)/16)**2-((ly-40)/25)**2);horn=np.clip((30-ly)/22,0,1)
  if action=="idle":dy+=1.1*c*np.exp(-((ly-41)/32)**2);dx+=.75*s*horn+.35*s*head
  elif action=="walk":
   dx+=2.3*s*legs*(back-front)
   dy+=-1.9*np.maximum(0,s)*legs*front-1.9*np.maximum(0,-s)*legs*back
   dy+=.6*abs(s);dx+=.7*s*horn
  elif action=="attack":
   p=[0,-1,1,4,6,5,2,0][i]
   dx+=-p*head-p*.65*horn+p*.4*legs*front
   dy+=[0,1,1,2,2,1,1,0][i]
  elif action=="hurt":
   p=[0,2,5,4,2,0][i];dx+=p*head;dy+=[0,1,2,1,1,0][i]
  elif action=="faint":dy+=[0,0,1,2,2,2,2,2][i]
 sx=lx-dx;sy=ly-dy
 iy=np.floor(sy+.5).astype(int);ix=np.floor(sx+.5).astype(int)
 valid=(iy>=0)&(iy<h)&(ix>=0)&(ix<w)
 rgba=np.zeros((H,W,4),dtype=np.uint8)
 rgba[valid]=a[iy[valid],ix[valid]]
 im=Image.fromarray(rgba,"RGBA")
 if action=="faint":im=im.rotate([0,6,16,30,53,72,75,75][i],resample=Image.Resampling.NEAREST,center=(W//2,H//2+6))
 return im

for case,info in config.items():
 src=Image.open(root/case/"master.png").convert("RGBA")
 W,H=info["shape"];base=root/case/"rig"
 (base/"frames").mkdir(parents=True,exist_ok=True)
 manifest={"schema":"generate2dsprite.animation_clips.v2","frames":[],"anchor_px":info["anchor"],"clips":{},"states":{"idle":"idle","moving":"walk","attacking":"attack"},"sampling":"nearest","pixel_art":True,"art_source":"existing","placeholder":False}
 for act in ("idle","walk","run","attack","hurt","jump","faint"):
  if act not in info:continue
  n=info[act];indices=[]
  for i in range(n):
   img=produce(src,case,act,i,n,W,H)
   assert img.getbbox() is not None,act
   bb=img.getbbox()
   assert bb[0]>0 and bb[1]>0 and bb[2]<W and bb[3]<H,(act,i,bb)
   filename=f"{act}_{i:02d}.png";img.save(base/"frames"/filename)
   indices.append(len(manifest["frames"]))
   manifest["frames"].append({"name":filename[:-4],"file":"frames/"+filename})
  manifest["clips"][act]={"frames":indices,"ticks":[12 if act=="idle" else 8 if act in ("walk","run") else 6]*n,"loop_policy":"cycle" if act in ("idle","walk","run") else "oneshot","role":"player" if case.startswith("T1") else "enemy"}
 (base/"clips.json").write_text(json.dumps(manifest,indent=2),encoding="utf8")
 print(case,"clips",len(manifest["clips"]),"frames",len(manifest["frames"]),"master_pixel_sha256",hashlib.sha256(np.asarray(src).tobytes()).hexdigest())