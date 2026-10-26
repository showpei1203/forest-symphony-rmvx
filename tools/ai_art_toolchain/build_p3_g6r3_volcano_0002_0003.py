from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,shutil,xml.etree.ElementTree as ET,hashlib,math
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
NEW=R/"outputs/P3_G6R3_0002_0003_BACK_VOLCANO_20261026"
assert not NEW.exists(),"Do not overwrite production candidate"
NEW.mkdir(parents=True)
result={}
for dex in (2,3):
 key=f"{dex:04d}"
 UP=R/f"outputs/P3_G{'4' if dex==2 else '5'}_{key}_OFFICIAL_SOURCE_20261026"
 O=UP/f"SOURCE_{key}"
 assert O.exists() and (O/"AnimData.xml").is_file()
 D=NEW/f"PMD_{key}_BACK_VOLCANO"
 D.mkdir()
 for p in O.glob("*"):
  if p.name=="AnimData.xml" or p.name.endswith(("-Offsets.png","-Shadow.png")):shutil.copy2(p,D/p.name)
 roots=ET.parse(O/"AnimData.xml").getroot()
 nframes=0;actions=[];morph_count=0;caldera_count=0;lava_count=0;errors=[]
 for xml in roots.findall(".//Anim"):
  if xml.findtext("CopyOf"):continue
  name=xml.findtext("Name");fw=int(xml.findtext("FrameWidth"));fh=int(xml.findtext("FrameHeight"))
  ds=xml.find("Durations").findall("Duration");nf=len(ds)
  raw=np.asarray(Image.open(O/(name+"-Anim.png")).convert("RGBA"))
  assert raw.shape[1]==nf*fw and raw.shape[0]%fh==0
  nr=raw.shape[0]//fh;res=np.empty_like(raw);per=[]
  for dr in range(nr):
   for frame in range(nf):
    sx=frame*fw;sy=dr*fh
    a=raw[sy:sy+fh,sx:sx+fw]
    b=a.copy()
    rgb=a[:,:,:3].astype(np.int32);alpha=a[:,:,3]>0
    # Source original in 0002/0003 contains green vines + orange-pink bud. Identify dorsal creature part per CELL.
    plant=alpha&(rgb[:,:,1]>rgb[:,:,0]*1.13)&(rgb[:,:,1]>rgb[:,:,2]*1.2)&(rgb[:,:,1]>73)&(rgb[:,:,0]<190)
    core=alpha&(rgb[:,:,0]>110)&(rgb[:,:,0]>rgb[:,:,1]*1.35)&(rgb[:,:,1]<145)&(rgb[:,:,2]<130)
    gx=np.where(plant)[1];gy=np.where(plant)[0]
    ry=np.where(core)[0];rx=np.where(core)[1]
    assert len(gx)>=9 and len(rx)>=6,(key,name,dr,frame,"REGION_SOURCE")
    # Body palette: source blue into warm burnt orange, original green -> shale colors,
    # never alter alpha or foot location in lower silhouette outside the dorsal shape.
    source_colors=rgb.copy()
    # broad cool blue source body pixels (source palette 0002/0003)
    blue=alpha &(rgb[:,:,2]>rgb[:,:,0]*1.04)&(rgb[:,:,1]>=rgb[:,:,0]*.93)&(rgb[:,:,0]>=55)
    bright_blue=blue&(rgb[:,:,0]>=125)
    medium_blue=blue&~bright_blue
    b[bright_blue,:3]=[219,148,106] if dex==2 else [229,149,92]
    b[medium_blue,:3]=[151,120,109] if dex==2 else [145,109,100]
    b[plant,:3]=[90,100,101] if dex==2 else [74,83,88]
    b[core,:3]=[172,79,39] if dex==2 else [194,70,30]
    # Original frame's plant/crown is the envelope of the elevated back. Do not draw generic identical shape
    # in all directions; use per-cell positions and original crown movement.
    center=int(np.median(rx))
    origin_top=min(int(min(ry)),int(min(gy)))
    origin_bottom=max(int(max(gy)),int(max(ry)))
    lgreen,rgreen=int(min(gx)),int(max(gx))
    top=max(2,origin_top-(1 if dex==2 else 2))
    # G6R1 ART_FAIL: volcano buried face/body. Keep cone upper-dorsal.
    # Reserve nearly all the original head and body. True BACKPACK volcano only.
    bottom=min(fh-5,top+(7 if dex==2 else 10))
    center=max(12,min(fw-13,center))
    radius=5 if dex==2 else 7
    left=max(2,center-radius)
    right=min(fw-3,center+radius)
    # Strictly constrain inside source cell. If source is small, adjust automatically.
    height=bottom-top
    if height<7:raise RuntimeError((key,name,dr,frame,"CONE_TOO_SHORT",top,bottom))
    # Authentic volcano silhouette: truncated cone with open orange ring at the top, no closed apex.
    # Volcanic juvenile has narrow crater with dim magma; mature is broad crater and lava downslope.
    caldera_w=2 if dex==2 else 3
    caldera_y=top+1
    base_y=bottom
    img=Image.fromarray(b,"RGBA");d=ImageDraw.Draw(img)
    outline=(27,34,39,255)
    deep=(65,74,80,255) if dex==2 else (57,64,69,255)
    shaded=(101,111,111,255) if dex==2 else (99,107,108,255)
    light=(145,153,149,255) if dex==2 else (139,145,140,255)
    # front silhouette trapezoid rock slopes from low opening to broad base
    cone=[(left+1,base_y),(left,base_y-3),
          (center-caldera_w-2,caldera_y+1),
          (center-caldera_w,caldera_y),
          (center+caldera_w,caldera_y),
          (center+caldera_w+2,caldera_y+1),
          (right,base_y-3),(right-1,base_y)]
    d.polygon(cone,fill=deep,outline=outline)
    # left lit face and right shaded face: asymmetry reads as actual rock form
    d.polygon([(left+2,base_y-1),(center-caldera_w-1,caldera_y+2),(center-1,base_y-1)],
              fill=shaded)
    d.polygon([(center+1,base_y-1),(center+caldera_w+1,caldera_y+2),(right-2,base_y-1)],
              fill=(72,79,80,255))
    d.line([(left+3,base_y-3),(center-caldera_w,caldera_y+2)],
           fill=light,width=1)
    d.line([(right-3,base_y-3),(center+caldera_w,caldera_y+2)],
           fill=(121,125,120,255),width=1)
    # Concave crater opening: ring exterior shades and hot center, located at cone top.
    d.line([(center-caldera_w-1,caldera_y+1),(center-caldera_w,caldera_y),
            (center+caldera_w,caldera_y),(center+caldera_w+1,caldera_y+1)],
           fill=(170,171,157,255),width=1)
    d.rectangle((center-caldera_w+1,caldera_y+1,center+caldera_w-1,caldera_y+2),
                fill=(41,35,36,255))
    d.line([(center-caldera_w+1,caldera_y+2),(center+caldera_w-1,caldera_y+2)],
           fill=(234,84,21,255),width=1)
    d.line([(center-(1 if dex==2 else 3),caldera_y+2),
            (center+(1 if dex==2 else 3),caldera_y+2)],
           fill=(255,171,53,255),width=1)
    # Stage2 = shorter semi-formed cone, its magma stays mostly inside crater.
    # Stage3 = taller, defined open caldera; two glowing overflow rivulets follow outer conical wall.
    if dex==3:
      # right overflow with dark crust border and bright inner vein
      flow=[(center+caldera_w-1,caldera_y+3),
            (center+caldera_w,caldera_y+5),
            (center+caldera_w+2,caldera_y+7),
            (min(right-3,center+caldera_w+2),bottom-4),
            (right-2,bottom-1)]
      d.line(flow,fill=(84,30,25,255),width=3)
      d.line(flow,fill=(251,95,23,255),width=2)
      d.line(flow[:3],fill=(255,193,62,255),width=1)
      flow2=[(center-caldera_w+1,caldera_y+3),
             (center-caldera_w-1,caldera_y+6),
             (max(left+2,center-caldera_w-2),bottom-3)]
      d.line(flow2,fill=(247,94,25,255),width=1)
      # broken rock chips on the slope; separate pieces without blanking original frame areas
      d.polygon([(left+4,bottom-3),(left+5,bottom-6),(left+7,bottom-4)],fill=(153,157,150,255))
      d.polygon([(right-6,bottom-4),(right-3,bottom-6),(right-4,bottom-2)],fill=(133,141,137,255))
      # Only some active attacks contain a weak glowing vent spark; no animation XML changes.
      if name in ("Attack","Special","Swing") and frame%2==0 and caldera_y>=5:
       px=center+1
       d.point((px,caldera_y-2),fill=(255,183,64,255))
    else:
      # Sparse hairline fissures on the forming cone walls.
      d.line([(center+3,caldera_y+4),(center+4,caldera_y+6)],fill=(222,91,30,255),width=1)
      d.point((center+4,caldera_y+5),fill=(255,164,52,255))
      d.line([(left+4,bottom-2),(left+5,bottom-4)],fill=(119,124,122,255),width=1)
    made=np.asarray(img.convert("RGBA")).copy()
    # Do not synthesize new alpha on frame borders. Keep exact original action cell boundaries.
    for axis in ("top","bottom"):
      idx=0 if axis=="top" else -1
      made[idx,:,:]=b[idx,:,:]
    made[:,0,:]=b[:,0,:];made[:,-1,:]=b[:,-1,:]
    # No altered foot anchor / body region below basalt base.
    visible_body=np.count_nonzero(made[bottom+1:,:,3]>0)
    assert visible_body>=15 if name in ("Idle","Walk") else visible_body>=0,(key,name,dr,frame,"FROG_BODY_HIDDEN",visible_body)
    assert np.array_equal(made[bottom+1:,:,3],a[bottom+1:,:,3]),(key,name,dr,frame,"FOOT_GEOM")
    old_alpha=a[:,:,3];now=made[:,:,3]
    morph=int(np.count_nonzero(old_alpha!=now))
    assert np.count_nonzero(np.any(made[:,:,:3]!=a[:,:,:3],axis=2))>=18,(key,name,dr,frame,"NO_MATERIAL_CHANGE")
    # Crater must be distinguishable from solid cone
    crater=made[caldera_y+2,center-caldera_w+1:center+caldera_w,:3]
    hot=int(np.sum((crater[:,0]>210)&(crater[:,1]>70)&(crater[:,1]<220)&(crater[:,2]<120)))
    assert hot>=(2 if dex==2 else 3),(key,name,dr,frame,"NO_HOT_CRATER",hot)
    assert not(np.any((now[0,:]>0)&(old_alpha[0,:]==0)) or np.any((now[-1,:]>0)&(old_alpha[-1,:]==0)) or np.any((now[:,0]>0)&(old_alpha[:,0]==0)) or np.any((now[:,-1]>0)&(old_alpha[:,-1]==0)))
    assert not np.array_equal(made,a),(key,name,dr,frame)
    res[sy:sy+fh,sx:sx+fw]=made
    per.append({"direction":dr,"frame":frame,"basalt_base_y":base_y,"crater_y":caldera_y,"crater_center_x":center,
                "changed_alpha_pixels":morph,"hot_crater_pixels":hot})
    nframes+=1;morph_count+=int(morph>=2);caldera_count+=1
  out=D/(name+"-Anim.png")
  Image.fromarray(res,"RGBA").save(out)
  assert Image.open(out).size==(fw*nf,fh*nr)
  actions.append({"name":name,"cell":[fw,fh],"frames_per_direction":nf,"directions":nr,"cells":len(per),"data":per})
 for f in O.glob("*"):
  if f.name=="AnimData.xml" or f.name.endswith(("-Offsets.png","-Shadow.png")):
    assert (D/f.name).read_bytes()==f.read_bytes(),(key,f.name)
 expected=682 if dex==2 else 698
 assert nframes==expected and len(actions)==12
 result[key]={"stage":2 if dex==2 else 3,"source":str(O),
         "original_named_actions":14,"real_action_sheets":len(actions),"individual_cells":nframes,
         "cells_with_2_or_more_alpha_morph_pixels":morph_count,"caldera_hot_cells":caldera_count,"original_below_cone_alpha_preserved":True,
         "original_xml_offsets_shadow_unchanged":True,
         "frame_count_dimensions_positions_unchanged":True,
         "morphology":"nascent low volcanic cone with smaller opening" if dex==2 else "mature elevated volcano cone with wide crater and lava overflow",
         "status":"SOURCE_QA_PASS__HUMAN_ART_PENDING",
         "actions":actions}
 # Species source vs volcano actual frames, 8 directions across Idle/Walk/Attack
 pane=Image.new("RGB",(1160,1165),(29,35,41));dd=ImageDraw.Draw(pane)
 for ai,act in enumerate(("Idle","Walk","Attack")):
   a=next(t for t in actions if t["name"]==act);fw,fh=a["cell"]
   for t_idx,directory in enumerate((O,D)):
    sheet=Image.open(directory/(act+"-Anim.png")).convert("RGBA")
    for rr in range(8):
      fr=sheet.crop((0,rr*fh,fw,(rr+1)*fh)).resize((fw*3,fh*3),Image.Resampling.NEAREST)
      pane.paste(fr,(13+rr*143,32+ai*380+t_idx*175),fr)
    dd.text((13,12+ai*380+t_idx*175),f"PMD {key} | {act} | "+("ORIGINAL" if t_idx==0 else ("SMALL NASCENT VOLCANO" if dex==2 else "MATURE LAVA VOLCANO")),fill=(245,234,212))
 pane.save(NEW/f"PMD_{key}_ORIGINAL_VS_BACK_VOLCANO_ALL_FACINGS.png")
 # Default Idle source-real animation one GIF per species for quick vision.
 a=next(t for t in actions if t["name"]=="Idle");fw,fh=a["cell"]
 x=next(z for z in roots.findall(".//Anim") if z.findtext("Name")=="Idle")
 ticks=[int(q.text) for q in x.find("Durations").findall("Duration")]
 orig=Image.open(O/"Idle-Anim.png").convert("RGBA")
 modified=Image.open(D/"Idle-Anim.png").convert("RGBA")
 gif_frames=[]
 for k,tick in enumerate(ticks):
  f=Image.new("RGB",(580,550),(32,40,46));di=ImageDraw.Draw(f)
  di.text((9,9),f"PMD {key} Idle frame {k+1}/{len(ticks)} original XML tick {tick}",fill=(244,232,217))
  di.text((15,28),"SOURCE",fill=(185,228,164));di.text((305,28),"VOLCANO",fill=(251,210,144))
  for face in range(8):
   p0=orig.crop((k*fw,face*fh,(k+1)*fw,(face+1)*fh))
   p1=modified.crop((k*fw,face*fh,(k+1)*fw,(face+1)*fh))
   scale=2 if max(fw,fh)<=52 else 1
   p0=p0.resize((fw*scale,fh*scale),Image.Resampling.NEAREST)
   p1=p1.resize((fw*scale,fh*scale),Image.Resampling.NEAREST)
   f.paste(p0,(92,57+face*60),p0)
   f.paste(p1,(387,57+face*60),p1)
  gif_frames.append(f)
 gif_frames[0].save(NEW/f"PMD_{key}_Idle_SOURCE_VS_VOLCANO_XML.gif",save_all=True,append_images=gif_frames[1:],
                    duration=[max(35,int(t*1000/60)) for t in ticks],loop=0,disposal=2,optimize=False)
 with Image.open(NEW/f"PMD_{key}_Idle_SOURCE_VS_VOLCANO_XML.gif") as ch:
   assert ch.n_frames==len(ticks)
 # XML validator should work without original downloaded repository
 (NEW/f"PMD_{key}_SOURCE_QA.json").write_text(json.dumps(result[key],ensure_ascii=False,indent=2),encoding="utf-8")
# 3-stage real sprites with adopted 0001 unchanged
old=R/"outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026/rock_0001/Idle-Anim.png"
assert old.exists()
board=Image.new("RGB",(1190,550),(29,35,42));d=ImageDraw.Draw(board)
d.text((17,12),"SOURCE-DERIVED ROCK/FIRE EVOLUTION | REAL PMD ORIGINAL XML ATLASES",fill=(245,229,199))
f1=Image.open(old).convert("RGBA")
for j,(key,sheet,fw,fh,heading) in enumerate([
 ("0001",f1,32,40,"0001: cracked basalt baby / unchanged user-approved direction"),
 ("0002",Image.open(NEW/"PMD_0002_BACK_VOLCANO/Idle-Anim.png").convert("RGBA"),32,32,"0002: small emerging crater and cone"),
 ("0003",Image.open(NEW/"PMD_0003_BACK_VOLCANO/Idle-Anim.png").convert("RGBA"),32,32,"0003: mature cone, wide crater and lava overflow")]):
 xx=13+j*392
 d.text((xx,50),heading[:53],fill=(253,211,147))
 for ii,row in enumerate((0,2,4,6)):
   tile=sheet.crop((0,row*fh,fw,(row+1)*fh)).resize((96,fh*3),Image.Resampling.NEAREST)
   board.paste(tile,(xx+(ii%2)*175+15,82+(ii//2)*187),tile)
board.save(NEW/"PMD_0001_0002_0003_VOLCANO_REAL_SOURCE_EVOLUTION.png")
(NEW/"P3_G6_VOLCANO_RESULTS.json").write_text(json.dumps({k:{y:z for y,z in v.items() if y!="actions"} for k,v in result.items()},ensure_ascii=False,indent=2),encoding="utf-8")
print("P3_G6_VOLCANO_SOURCE_PASS",json.dumps({k:{y:z for y,z in v.items() if y!="actions"} for k,v in result.items()},ensure_ascii=False),flush=True)
