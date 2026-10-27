from PIL import Image
from pathlib import Path
import numpy as np,json
root=Path(__file__).resolve().parent/"R6_SAME_SESSION_ISOLATED"/"NATIVE_ABA"
case="PLAYER_FRONT_NPC_BEHIND"
a=np.asarray(Image.open(root/(case+"__A1.png")).convert("RGB")).astype(np.int16)
b=np.asarray(Image.open(root/(case+"__A2.png")).convert("RGB")).astype(np.int16)
c=np.asarray(Image.open(root/(case+"__B.png")).convert("RGB")).astype(np.int16)
def probe(src,tgt,rect):
 x1,y1,x2,y2=rect
 ref=src[y1:y2,x1:x2]
 vals=[]
 for oy in range(-24,25):
  for ox in range(-24,25):
   q=tgt[y1+oy:y2+oy,x1+ox:x2+ox]
   if q.shape!=ref.shape:continue
   diff=np.max(np.abs(ref-q),axis=2)
   vals.append((float(np.median(diff)),float(diff.mean()),float((diff<=5).mean()),ox,oy))
 vals.sort(key=lambda z:(z[1],z[0]))
 return {"best_by_mean":vals[0],"best_by_percent_equal":max(vals,key=lambda z:z[2]),"same":[x for x in vals if x[3:]==(0,0)][0]}
for name,rect in [("center_ground",(180,190,380,280)),("left_tree",(85,100,205,210)),("right_tree",(400,100,510,260)),("house",(275,95,370,215)),("background_whole",(100,100,440,300))]:
 print(name,"A1_A2",probe(a,b,rect))
 print(name,"A1_B",probe(a,c,rect))