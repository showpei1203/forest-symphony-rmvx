from pathlib import Path
from PIL import Image
from collections import deque
import json
R=Path(r"E:\GameAssetToolLab_20261023\A33_HUMANOID_DIRECT_POSE_20261101\REFERENCE_SOURCE")
def comps(im):
 a=im.getchannel("A")
 mask={(x,y) for y in range(im.height) for x in range(im.width) if a.getpixel((x,y))>0}
 result=[]
 while mask:
  start=min(mask,key=lambda p:(p[1],p[0]))
  mask.remove(start);todo=[start];pts=[]
  while todo:
   x,y=todo.pop();pts.append((x,y))
   for dy in [-1,0,1]:
    for dx in [-1,0,1]:
     q=(x+dx,y+dy)
     if q in mask:mask.remove(q);todo.append(q)
  result.append({"n":len(pts),"bbox":(min(x for x,y in pts),min(y for x,y in pts),max(x for x,y in pts)+1,max(y for x,y in pts)+1)})
 return sorted(result,key=lambda x:-x["n"])
for name in ['DODGE0','DODGE1','DODGE2','DAMAGE0','DAMAGE1','DAMAGE2']:
 im=Image.open(R/(name+'.png')).convert('RGBA')
 print(name,"size",im.size,"bbox",im.getbbox(),"connected",comps(im)[:12])
