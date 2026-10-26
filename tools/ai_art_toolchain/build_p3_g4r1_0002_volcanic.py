from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np, json, shutil,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
SRCROOT=R/"outputs/P3_G4_0002_OFFICIAL_SOURCE_20261026"
SRC=SRCROOT/"SOURCE_0002"
M=json.loads((SRCROOT/"SOURCE_0002_MANIFEST.json").read_text(encoding="utf-8"))
BASE=R/"outputs/P3_G4R1_0002_VOLCANIC_EVOLUTION_20261026"
assert not BASE.exists(),"Avoid overwriting existing candidate"
DST=BASE/"VOLCANIC_0002";DST.mkdir(parents=True)
for f in SRC.glob("*"):
 if f.name=="AnimData.xml" or f.name.endswith(("-Offsets.png","-Shadow.png")):shutil.copy2(f,DST/f.name)
# Exact source palette to warm basalt creature with ember belly tones.
pal={
(175,207,239):(213,146,103), # light source blue -> volcanic warm-gray shell/body
(111,159,199):(148,116,109), # darker neutral burnt stone
(87,119,135):(88,84,87),    # cooler dark gray
(159,207,111):(162,127,90), # pale green skin highlights -> clay-orange
(215,239,167):(226,164,103),
(95,183,39):(97,105,108),   # original leaf green -> basalt shell medium
(39,135,0):(49,57,65),    # deep dark ridges
(215,63,0):(240,111,29),  # orange bud -> lava cracks
(159,0,0):(116,38,30),
(255,135,95):(249,151,80), # amber skin/highlight
(223,183,0):(252,167,55),
(255,247,0):(253,211,100),
(167,111,0):(151,78,37),
}
def map_palette(source):
 out=source.copy()
 valid=source[:,:,3]>0
 for old,new in pal.items():
  mask=valid & np.all(source[:,:,:3]==old,axis=2)
  out[mask,:3]=new
 return out
stats=[]
fullcount=0
silhouette_changed=0
magma_ok=0
for item in M["actions"]:
 if "copyOf" in item:continue
 name=item["name"]
 fw,fh=item["cell"];cols=item["frames"];rows=item["rows"]
 raw=np.asarray(Image.open(SRC/(name+"-Anim.png")).convert("RGBA"),np.uint8)
 output=np.empty_like(raw)
 rowstats=[]
 for dr in range(rows):
  for fr in range(cols):
   y=dr*fh;x=fr*fw
   old=raw[y:y+fh,x:x+fw,:]
   p=map_palette(old)
   good=old[:,:,3]>0
   og=old[:,:,:3].astype(np.int16)
   green=good & (og[:,:,1]>og[:,:,0]*1.12) & (og[:,:,1]>og[:,:,2]*1.17) & (og[:,:,0]<180) & (og[:,:,1]>75)
   flower=good & (og[:,:,0]>150) & (og[:,:,0]>og[:,:,1]*1.4) & (og[:,:,1]<175)
   gy,gx=np.where(green)
   by,bx=np.where(flower)
   assert len(gx)>=20 and len(bx)>=8,(name,dr,fr)
   gxl,gxr=int(gx.min()),int(gx.max())
   gyt,gyb=int(gy.min()),int(gy.max())
   center=int(np.median(bx))
   flower_top=int(by.min())
   # Create a raised, recognizable shield of two basalt plates around the original molten flower:
   # source leaf growth becomes split volcanic stone shell with a magma-filled center.
   left=max(1,gxl-2);right=min(fw-2,gxr+2)
   top=max(1,min(flower_top,gyt)-2);bottom=min(fh-2,gyb+2)
   center=max(left+3,min(right-3,center))
   mid=(top+bottom)//2
   # The new basalt plates are angular and asymmetrical; cannot look like leftover leaves.
   image=Image.fromarray(p,"RGBA")
   draw=ImageDraw.Draw(image)
   # Left/right arms of rock shell, deliberately framing a central orange magma fissure
   lpoly=[(left+2,bottom-1),(left,mid+2),(left+1,top+5),
       (left+3,top+2),(center-3,top+1),(center-2,mid-1),
       (center-4,bottom-2)]
   rpoly=[(right-1,bottom),(right,mid+3),(right-1,top+5),
       (right-4,top+2),(center+2,top),(center+3,mid+1),
       (center+4,bottom-1)]
   draw.polygon(lpoly,fill=(70,77,80,255),outline=(25,32,36,255))
   draw.polygon(rpoly,fill=(89,96,95,255),outline=(25,32,36,255))
   # Visible fractured slate planes; on stage2 plate gaps are wide unlike stage1 hairlines
   draw.line([(left+2,top+6),(center-4,top+3),(center-5,mid+2)],fill=(151,155,150,255),width=1)
   draw.line([(right-4,top+3),(center+4,mid),(right-3,bottom-2)],fill=(166,168,157,255),width=1)
   # Bright rock-fire core stays inside original seed/bud region and varies naturally with pose
   core_top=max(top+2,int(by.min()))
   core_bottom=min(bottom-2,max(core_top+2,int(by.max())))
   cx=center
   corepoly=[(cx,core_top),(cx+2,core_top+2),(cx+3,(core_top+core_bottom)//2),
       (cx+1,core_bottom),(cx-1,core_bottom-1),(cx-3,mid),(cx-2,core_top+2)]
   draw.polygon(corepoly,fill=(231,79,23,255),outline=(102,30,24,255))
   draw.line([(cx,core_top+1),(cx+1,mid),(cx,core_bottom-1)],fill=(255,188,67,255),width=2)
   # Distinct lateral cracked lava veins, visibly stronger than 0001
   draw.line([(cx-1,mid),(cx-4,mid-2),(cx-5,mid-1)],fill=(247,108,32,255),width=1)
   draw.line([(cx+1,mid+1),(cx+4,mid-1),(cx+5,mid)],fill=(252,127,36,255),width=1)
   # fracture chips on top of the rock support, from source green-backed morphology
   draw.polygon([(left+4,top+3),(left+5,top),(left+7,top+4)],fill=(127,136,136,255),outline=(25,32,36,255))
   draw.polygon([(right-7,top+4),(right-4,top+1),(right-2,top+5)],fill=(129,139,138,255),outline=(25,32,36,255))
   changed=np.asarray(image,np.uint8)
   # true original seat positions and per-action sprite-sheet cells preserved
   assert changed.shape==old.shape
   assert not np.any((changed[0,:,3]>0)&(old[0,:,3]==0)),(name,dr,fr,"NEW_EDGE_TOP")
   assert not np.any((changed[-1,:,3]>0)&(old[-1,:,3]==0)),(name,dr,fr,"NEW_EDGE_BOTTOM")
   assert not np.any((changed[:,0,3]>0)&(old[:,0,3]==0)),(name,dr,fr,"NEW_EDGE_LEFT")
   assert not np.any((changed[:,-1,3]>0)&(old[:,-1,3]==0)),(name,dr,fr,"NEW_EDGE_RIGHT")
   # untouched leg/foot silhouette at lower 1-3 source pixels
   if bottom+1<fh:
    assert np.array_equal(changed[bottom+1:,:,3],old[bottom+1:,:,3]),(name,dr,fr,"FOOT_ALPHA")
   morph=np.count_nonzero(changed[:,:,3]!=old[:,:,3])
   if morph>0:silhouette_changed+=1
   molten=(changed[:,:,0]>=225)&(changed[:,:,1]>=75)&(changed[:,:,1]<215)&(changed[:,:,2]<110)&(changed[:,:,3]>0)
   if int(molten.sum())<5:raise AssertionError((name,dr,fr,"MOLTEN_CORE_INVISIBLE"))
   magma_ok+=1
   output[y:y+fh,x:x+fw]=changed
   rowstats.append({"direction":dr,"frame":fr,"new_alpha_pixels":int(morph),"magma_pixels":int(molten.sum()),
                   "source_green_pixels":int(len(gx)),"core_center":[cx,mid],"rock_bbox":[left,top,right,bottom]})
   fullcount+=1
 dest=DST/(name+"-Anim.png")
 Image.fromarray(output,"RGBA").save(dest)
 assert Image.open(dest).size==(fw*cols,fh*rows)
 stats.append({"name":name,"cell":[fw,fh],"cols":cols,"rows":rows,"frames":len(rowstats),
               "genuine_morphology_changed":sum(t["new_alpha_pixels"]>0 for t in rowstats),
               "row_stats":rowstats})
for o in [SRC/"AnimData.xml",*SRC.glob("*-Offsets.png"),*SRC.glob("*-Shadow.png")]:
 t=DST/o.name
 assert t.exists() and t.read_bytes()==o.read_bytes(),o.name
report={"id":"P3_G4_PMD0002_STAGE2_CRACKING_VOLCANIC","source":"PMDCollab/SpriteCollab sprite/0002",
"real_actions":len(stats),"xml_names":len(M["actions"]),"total_frames":fullcount,
"actual_morphology_changed_cells":silhouette_changed,
"all_frames_contain_visible_orange_magma":magma_ok==fullcount,
"XML_OFFSETS_SHADOW_EXACT_BYTE_PARITY":True,
"all_frame_grids_unchanged":True,"source_position_foot_preservation":True,
"palette":"warm sandstone/ash gray body; charcoal dark cracked rock with hot orange magma core",
"evolution":"0001 subtle narrow lava fissure, 0002 thicker split basalt and brighter visible magma, 0003 future exposed lava",
"human_visual":"PENDING","official_PMD_game_loader":"NOT_TESTED",
"rights":"Fan sprites copyright/licensing must be verified before distribution/commercial use",
"actions":stats}
BASE.mkdir(parents=True,exist_ok=True)
(BASE/"P3_G4_0002_MORPH_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
prev=Image.new("RGB",(1120,1250),(31,35,40))
d=ImageDraw.Draw(prev)
for k,name in enumerate(("Idle","Walk","Attack")):
 z=next(t for t in stats if t["name"]==name)
 w,h=z["cell"]
 for i,origin in enumerate((SRC,DST)):
  atlas=Image.open(origin/(name+"-Anim.png")).convert("RGBA")
  for facing in range(8):
   f=atlas.crop((0,facing*h,w,(facing+1)*h)).resize((w*3,h*3),Image.Resampling.NEAREST)
   xx=15+facing*138; yy=30+k*400+i*190
   prev.paste(f,(xx,yy),f)
  d.text((15,8+k*400+i*190),name+(" / ORIGINAL 0002" if i==0 else " / VOLCANIC STAGE2"),fill=(241,228,206))
prev.save(BASE/"P3_G4_0002_ORIGINAL_VS_LAVA_ALL_DIR.png")
print("REPORT",json.dumps({k:v for k,v in report.items() if k!="actions"},ensure_ascii=False),flush=True)
