from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np,shutil,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
UP=R/"outputs/P3_G5_0003_OFFICIAL_SOURCE_20261026"
SRC=UP/"SOURCE_0003"
DATA=json.loads((UP/"SOURCE_0003_MANIFEST.json").read_text(encoding="utf-8"))
OUT=R/"outputs/P3_G5R1_0003_RUPTURED_LAVA_CORE_20261026"
assert not OUT.exists(),"Do not overwrite existing 0003"
T=OUT/"VOLCANIC_0003"
T.mkdir(parents=True)
for f in SRC.glob("*"):
 if f.name=="AnimData.xml" or f.name.endswith(("-Offsets.png","-Shadow.png")):shutil.copy2(f,T/f.name)
color={
(135,175,207):(226,155,111), # body highlight / warm orange
(103,135,159):(156,119,112), # warmer ash intermediate
(63,87,111):(76,77,85), # shadow charcoal
(255,135,95):(255,155,90), # warm highlight
(215,239,167):(227,173,110), # pale body tint
(159,207,111):(173,132,92),
(95,183,39):(105,113,119), # stone where leaves formerly green
(39,135,0):(54,63,68),
(159,0,0):(122,37,31), # outer lava crust
(215,63,0):(237,103,24), # fiery interior
(223,183,0):(252,171,42),
(255,247,0):(255,226,127),
(167,111,0):(146,79,42)
}
def recolor(a):
 b=a.copy()
 v=a[:,:,3]!=0
 for src,dst in color.items():
  mask=v&np.all(a[:,:,:3]==src,axis=2)
  b[mask,:3]=dst
 return b
log=[]
total=0;strong=0;magma_total=0
for act in DATA["actions"]:
 if "copyOf" in act:continue
 name=act["name"]
 fw,fh=act["cell"];n=act["frames"];rows=act["rows"]
 arr=np.asarray(Image.open(SRC/(name+"-Anim.png")).convert("RGBA"),np.uint8)
 assert arr.shape[1]==fw*n and arr.shape[0]==fh*rows
 dst=np.empty_like(arr)
 actions=[]
 for rr in range(rows):
  for cc in range(n):
   y0=rr*fh;x0=cc*fw
   orig=arr[y0:y0+fh,x0:x0+fw,:]
   new=recolor(orig)
   good=orig[:,:,3]>0
   rgb=orig[:,:,:3].astype(np.int32)
   fiery=good & (rgb[:,:,0]>110)&(rgb[:,:,0]>rgb[:,:,1]*1.35)&(rgb[:,:,1]<145)&(rgb[:,:,2]<130)
   leafy=good & (rgb[:,:,1]>rgb[:,:,0]*1.13)&(rgb[:,:,1]>rgb[:,:,2]*1.2)&(rgb[:,:,1]>73)&(rgb[:,:,0]<190)
   gy,gx=np.where(leafy)
   assert len(gx)>=9,(name,rr,cc,"no source leaves")
   rg_y,rg_x=np.where(fiery & (np.indices(fiery.shape)[0] <= int(gy.max())+1))
   assert len(rg_x)>=18,(name,rr,cc,"no flower crown")
   # Native source flower centered around a bright core, all metrics per original frame.
   xl,xr=int(gx.min()),int(gx.max())
   rt,rb=int(rg_y.min()),int(rg_y.max())
   cx=int(np.median(rg_x))
   top=max(1,min(rt,int(gy.min()))-1)
   bot=min(fh-3,max(int(gy.max())+2,top+13))
   left=max(2,xl-2);right=min(fw-3,xr+2)
   # For 32x32 0003, the center stays near x16 and rock clusters span original flower/leaf area.
   cx=max(left+7,min(right-7,cx))
   mid=max(top+7,min(bot-5,int(np.median(rg_y))+2))
   if bot-top<12 or right-left<16:raise RuntimeError(f"Shell region invalid {name} {rr} {cc}")
   # Final-stage molten exposed core is larger than stage2's narrow fissure.
   # Draw lava core first (behind shattered plates), then angular basalt fragments around it.
   img=Image.fromarray(new,"RGBA")
   d=ImageDraw.Draw(img)
   core_width=max(5,min(7,round((right-left)*.3)))
   coretop=top+1
   corebot=bot-2
   rim=[
      (cx-2,coretop),(cx+2,coretop),
      (cx+core_width-1,coretop+4),(cx+core_width,mid),
      (cx+core_width-2,corebot-2),(cx+2,corebot),
      (cx-3,corebot-1),(cx-core_width,mid+1),
      (cx-core_width+1,coretop+4)]
   d.polygon(rim,fill=(158,43,23,255),outline=(29,31,37,255))
   inside=[
      (cx-1,coretop+1),(cx+2,coretop+2),
      (cx+core_width-2,mid-2),(cx+core_width-3,corebot-2),
      (cx,corebot-2),(cx-core_width+2,mid+1),
      (cx-core_width+2,coretop+5)]
   d.polygon(inside,fill=(248,101,20,255))
   d.polygon([(cx-1,coretop+2),(cx+1,coretop+2),(cx+3,mid-3),
              (cx+1,mid+2),(cx+2,corebot-3),(cx-2,mid+3),(cx-3,mid-2)],
             fill=(255,183,60,255))
   d.line([(cx,coretop+3),(cx+1,mid-3),(cx-1,mid+1)],fill=(255,232,115,255),width=2)
   # Outer crust substantially ruptured. Left/right basalt plates each flank the exposed core.
   left_plate=[
      (left+3,bot-1),(left,mid+3),(left+1,top+7),(left+3,top+4),
      (left+6,top+1),(cx-core_width-1,top+3),
      (cx-core_width-3,mid-2),(cx-core_width-1,mid+3),
      (cx-core_width-3,bot-2)]
   right_plate=[
      (right-3,bot),(right,mid+4),(right-1,top+7),
      (right-4,top+3),(right-7,top+1),(cx+core_width+1,top+2),
      (cx+core_width+3,mid-1),(cx+core_width+1,mid+3),
      (cx+core_width+3,bot-1)]
   d.polygon(left_plate,fill=(70,79,85,255),outline=(24,29,34,255))
   d.polygon(right_plate,fill=(82,91,97,255),outline=(24,29,34,255))
   d.polygon([(left+2,mid+2),(left+2,top+7),(left+6,top+4),
              (cx-core_width-4,top+7),(cx-core_width-5,mid)],fill=(119,127,129,255))
   d.polygon([(right-3,top+6),(right-6,top+3),
              (cx+core_width+5,top+7),(cx+core_width+5,mid+2),(right-3,mid+3)],
             fill=(123,131,130,255))
   # Magma vein traverses cracks in separated rock remnants, not random red recoloring.
   d.line([(cx-core_width,mid),(cx-core_width-3,mid-2),(cx-core_width-5,mid+1)],
          fill=(251,123,31,255),width=1)
   d.line([(cx+core_width-1,mid+1),(cx+core_width+3,mid-1),(cx+core_width+5,mid+1)],
          fill=(246,113,26,255),width=1)
   # Small detached stone chunks, make final evolutionary break visibly distinct.
   d.polygon([(left+4,top+4),(left+5,top),(left+8,top+2),(left+7,top+5)],
             fill=(134,143,145,255),outline=(26,30,34,255))
   d.polygon([(right-8,top+3),(right-5,top),(right-3,top+4),(right-6,top+6)],
             fill=(141,149,146,255),outline=(26,30,34,255))
   # Hard clip added overlay only to original frame interior. Preserve original recolored
   # border pixels to prevent across-cell bleeding for rotated/attack poses.
   cooked=np.asarray(img,np.uint8).copy()
   cooked[0,:,:]=new[0,:,:]
   cooked[-1,:,:]=new[-1,:,:]
   cooked[:,0,:]=new[:,0,:]
   cooked[:,-1,:]=new[:,-1,:]
   assert cooked.shape==orig.shape
   # no newly introduced new-border alpha ensures all action cells remain uncropped
   for edge,test in (
      ("TOP",(cooked[0,:,3]>0)&(orig[0,:,3]==0)),
      ("BOTTOM",(cooked[-1,:,3]>0)&(orig[-1,:,3]==0)),
      ("LEFT",(cooked[:,0,3]>0)&(orig[:,0,3]==0)),
      ("RIGHT",(cooked[:,-1,3]>0)&(orig[:,-1,3]==0))
   ):
    if np.any(test):raise RuntimeError(f"NEW_EDGE_CROP:{name}:{rr}:{cc}:{edge}")
   # Must preserve all pixels under source shell's lower boundary, maintaining foot contact/pose.
   assert np.array_equal(cooked[bot+1:,:,3],orig[bot+1:,:,3]),(name,rr,cc,"FOOT_ALPHA_CHANGED")
   morphed=int(np.count_nonzero(cooked[:,:,3]!=orig[:,:,3]))
   if morphed<2:raise RuntimeError(f"NO_MEANINGFUL_ROCK_MORPH {name} row{rr} col{cc}")
   molten=((cooked[:,:,0]>=220)&(cooked[:,:,1]>75)&(cooked[:,:,1]<240)&
           (cooked[:,:,2]<140)&(cooked[:,:,3]>0))
   amt=int(molten.sum())
   if amt<20:raise RuntimeError(f"CORE_TOO_SMALL {name} row{rr} col{cc} pixels{amt}")
   total+=1;strong+=1;magma_total+=amt
   dst[y0:y0+fh,x0:x0+fw]=cooked
   actions.append({"dir":rr,"frame":cc,"new_alpha_morph_pixels":morphed,"molten_pixels":amt,
                   "shell_bbox":[left,top,right,bot],"lava_mid":[cx,mid]})
 out=T/(name+"-Anim.png")
 Image.fromarray(dst,"RGBA").save(out)
 assert Image.open(out).size==(fw*n,fh*rows)
 log.append({"action":name,"directions":rows,"frames_per_direction":n,
             "cell":[fw,fh],"cells":len(actions),
             "minimum_magma_pixels":min(p["molten_pixels"] for p in actions),
             "cells_detail":actions})
for x in [SRC/"AnimData.xml",*SRC.glob("*-Offsets.png"),*SRC.glob("*-Shadow.png")]:
 assert (T/x.name).read_bytes()==x.read_bytes(),x.name
report={"id":"P3_G5_PMD0003_STAGE3_EXPOSED_MOLTEN_CORE","source":"PMDCollab/SpriteCollab sprite/0003",
        "original_source_action_names":len(DATA["actions"]),
        "real_action_sheets":len(log),"cells_total":total,
        "frames_w_real_morphology":strong,"molten_pixel_sum":magma_total,
        "old_XML_Offsets_Shadow_byte_equal":True,"all_frame_grid_positions_preserved":True,
        "stage3":"major ruptured dark basalt plates and broad fully exposed lava core, stage1/2/3 progression",
        "status":"SOURCE_QA_CANDIDATE_VISUAL_PENDING",
        "actual_pmd_game":"NOT_TESTED","vx_sbs":"NOT_TESTED",
        "actions":log}
(OUT/"P3_G5_0003_SOURCE_MORPH_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
# Side-by-side 8 directions for three actions, actual art, 1x source nearest
canvas=Image.new("RGB",(1150,1230),(26,33,40));d=ImageDraw.Draw(canvas)
for k,name in enumerate(("Idle","Walk","Attack")):
 spec=next(a for a in DATA["actions"] if a["name"]==name)
 fw,fh=spec["cell"]
 for i,srcroot in enumerate((SRC,T)):
  sheet=Image.open(srcroot/(name+"-Anim.png")).convert("RGBA")
  for row in range(8):
   tile=sheet.crop((0,row*fh,fw,(row+1)*fh)).resize((fw*3,fh*3),Image.Resampling.NEAREST)
   x=8+row*143;y=33+k*401+i*190
   canvas.paste(tile,(x,y),tile)
  d.text((10,12+k*401+i*190),name+("  ORIGINAL PMD 0003" if i==0 else "  FINAL ROCK/FIRE VOLCANIC 0003"),fill=(244,232,208))
canvas.save(OUT/"P3_G5_ORIGINAL_VS_0003_STAGE3_EIGHT_DIRECTIONS.png")
print("P3_G5_SOURCE_GATE",json.dumps({k:v for k,v in report.items() if k!="actions"},ensure_ascii=False),flush=True)
