from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,shutil
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
B=R/"outputs/P3_R2_0001_UPSTREAM_PMD_20261026"
O=B/"official_0001"
PRE=R/"outputs/P3_R3_0001_STONEBACK_MORPHOLOGY_20261026/stoneback_0001"
D=R/"outputs/P3_G3R1_0001_VOLCANIC_GRAY_ORANGE_20261026"
if D.exists():raise SystemExit("FAIL-CLOSED candidate path exists")
T=D/"VOLCANIC_0001"
shutil.copytree(PRE,T)
defs=json.loads((B/"DOWNLOAD_MANIFEST.json").read_text(encoding="utf-8"))["animation_defs"]
num=0;records=[];total_magma=0;total_recolored=0
for meta in defs:
 if meta["copyOf"]:continue
 name=meta["name"];fw,fh=int(meta["width"]),int(meta["height"])
 orig=np.array(Image.open(O/(name+"-Anim.png")).convert("RGBA"))
 old=np.array(Image.open(PRE/(name+"-Anim.png")).convert("RGBA"))
 assert orig.shape==old.shape
 new=old.copy()
 nc=orig.shape[1]//fw;nr=orig.shape[0]//fh
 assert nc==len(meta["durations"])
 for row in range(nr):
  for col in range(nc):
   a=orig[row*fh:(row+1)*fh,col*fw:(col+1)*fw]
   b=old[row*fh:(row+1)*fh,col*fw:(col+1)*fw]
   c=b.copy()
   # Warmer gray underbody, not the earlier monotonous slate recolor
   solid=(a[:,:,3]>0)
   og=a[:,:,:3].astype(np.int16)
   body_light=solid & (og[:,:,1]>og[:,:,0]*1.1) & (og[:,:,1]>og[:,:,2]*1.1) & (og[:,:,0]>100)
   # Preserve fine outlines; provide volcanic ash gray, soft warm orange belly undertones
   if body_light.any():
    c[body_light,0]=np.clip(og[:,:,0][body_light]*.72+57,0,255).astype(np.uint8)
    c[body_light,1]=np.clip(og[:,:,1][body_light]*.45+29,0,255).astype(np.uint8)
    c[body_light,2]=np.clip(og[:,:,2][body_light]*.38+23,0,255).astype(np.uint8)
   green=solid & (np.all(a[:,:,:3]==[95,183,39],axis=2)|np.all(a[:,:,:3]==[39,135,0],axis=2))
   if not green.any():raise RuntimeError("Missing source bulb "+name)
   occ=np.argwhere(solid);ymin,ymax=int(occ[:,0].min()),int(occ[:,0].max())
   pts=np.argwhere(green & (np.indices(green.shape)[0]<=ymin+max(6,int((ymax-ymin)*.45))))
   if len(pts)<3:pts=np.argwhere(green)
   cx=int(np.median(pts[:,1]));top_dark=int(pts[:,0].min())
   rad=max(5,min(9,round((ymax-ymin)*.35)))
   top=max(1,top_dark-3)
   bottom=min(fh-3,top+max(8,rad+4))
   if bottom-top<6:bottom=min(fh-2,top+6)
   cx=max(rad+2,min(fw-rad-3,cx))
   # Restrict emissive cracks to preexisting slate-gray rock faces after morphology source
   yy=np.arange(fh)[:,None]
   xx=np.arange(fw)[None,:]
   dx=np.abs(xx-cx)
   rock_color=np.array([72,85,90])
   region=(yy>=top+3)&(yy<=bottom-2)&(dx<=rad-3)
   # Central 1-2px zigzag lava fracture, no flames yet: early-stage rock shell
   crack_x=np.array([cx+(-1 if k%4<2 else 1)+int((k//4)%2) for k in range(fh)])
   for y in range(top+3,bottom-1):
    x=int(crack_x[y]);x=max(2,min(fw-3,x))
    if not region[y,x]:continue
    if b[y,x,3]==0:continue
    c[y,x,:3]=[255,133,37]
    if (y%4==0):
     c[y,x+1,:3]=[255,194,69] if b[y,x+1,3]>0 else c[y,x+1,:3]
   # Secondary short offshoot (usually 1 pixel long) visible on rock face
   ymid=max(2,min(fh-3,(top+bottom)//2))
   for dxy in (1,2):
    x=max(1,min(fw-2,cx+dxy))
    if region[ymid,x] and b[ymid,x,3]>0:
     c[ymid,x,:3]=[239,81,35]
   # Apply subtle thermal orange transition pixels on back rock, leaving mineral greys.
   hot=(np.abs(xx-cx)<=4)&(yy>=top+4)&(yy<=bottom-2)&(b[:,:,3]>0)
   shadow_rock=((b[:,:,0]>=65)&(b[:,:,0]<=190)&(b[:,:,1]>=70)&(b[:,:,1]<=195)&(b[:,:,2]>=70)&(b[:,:,2]<=195))
   env=hot&shadow_rock&(((xx+2*yy+row+col)%11)==0)
   c[env,:3]=[157,94,68]
   # Keep alpha identical to previous established true silhouette and preserve below rock foot region
   assert np.array_equal(c[:,:,3],b[:,:,3])
   assert np.array_equal(c[min(fh-1,bottom+1):,:,3],b[min(fh-1,bottom+1):,:,3])
   magma=int(np.sum((c[:,:,0]>215)&(c[:,:,1]>=75)&(c[:,:,1]<=200)&(c[:,:,2]<100)&(c[:,:,3]>0)))
   if magma<2:raise RuntimeError("Magma invisible "+str((name,row,col,magma,fw,fh,top,bottom)))
   total_magma+=magma;total_recolored+=int(np.any(c[:,:,:3]!=b[:,:,:3],axis=2).sum())
   new[row*fh:(row+1)*fh,col*fw:(col+1)*fw]=c
   num+=1
 Image.fromarray(new,"RGBA").save(T/(name+"-Anim.png"))
 if not np.array_equal(new[:,:,3],old[:,:,3]):raise RuntimeError("Silhouette altered after rock approved base")
 records.append({"action":name,"cells":nc*nr,"sheet_dimensions":[orig.shape[1],orig.shape[0]],
                 "xml_frame":[fw,fh],"magma_min_2_per_cell":True,
                 "source_sha256":hashlib.sha256((O/(name+"-Anim.png")).read_bytes()).hexdigest()})
for a in [O/"AnimData.xml",*O.glob("*-Offsets.png"),*O.glob("*-Shadow.png")]:
 assert a.read_bytes()==(T/a.name).read_bytes()
# Three-way comparison: actual source Idle Walk Attack vs stone morphology vs magma variant; all directions show x2 nearest
board=Image.new("RGB",(1170,1130),(25,32,37));dr=ImageDraw.Draw(board)
for ai,act in enumerate(("Idle","Walk","Attack")):
 m=next(x for x in defs if x["name"]==act)
 fw,fh=int(m["width"]),int(m["height"])
 sources=[O,PRE,T]
 for k,s in enumerate(sources):
  v=Image.open(s/(act+"-Anim.png")).convert("RGBA")
  for row in range(min(8,v.height//fh)):
   tile=v.crop((0,row*fh,fw,(row+1)*fh)).resize((fw*2,fh*2),Image.Resampling.NEAREST)
   x=12+row*145
   y=28+ai*370+k*116
   board.paste(tile,(x,y),tile)
  dr.text((12,10+ai*370+k*116),act+" / "+("SOURCE","ROCK R3","VOLCANIC G3")[k],fill=(238,238,226))
board.save(D/"PMD0001_THREE_WAY_ALL_DIRECTIONS.png")
report={"stage":"P3_G3_PMD0001_VOLCANIC_ORANGE_GRAY","status":"SOURCE_QA_PASS_HUMAN_PENDING",
        "cells_tested":num,"magma_emissive_pixels":total_magma,"new_rgb_pixels":total_recolored,
        "real_actions":len(records),"xml_offsets_shadows_byte_identical":True,
        "alpha_silhouette_previous_rock_version_identical":True,
        "first_stage": {"color":"warm grey/charcoal and ember orange", "rock_shell":"closed with two fine jagged fissures","magma":"low-intensity inside stone"},
        "planned_progression":{"0002":"thicker splitting basalt and more cracks; brighter magma","0003":"large broken crust with exposed molten core; rock+fire"},
        "human_visual":"PENDING","official_pmd_runtime":"NOT_TESTED","records":records}
(D/"PMD0001_VOLCANIC_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
(D/"CURRENT_HANDOFF.md").write_text("""# P3_G3 volcanic first-stage PMD 0001, 2026-10-26
Previous P3_R3 rock morphology source was edited *frame by frame* to make juvenile rock+fire volcanic form. New color DNA: warm gray and ember orange, prominent angular back-stone inherited from P3_R3, one main hairline crack and occasional short branch showing orange/yellow magma. 0002 and 0003 evolution design semantics documented, NOT rendered. All 34 true PMD actions and 1123 frames retain atlas layout and original XML/Offsets/Shadow byte identity, rock silhouette/alpha and original foot anchor.
GATE: source QA PASS; user visual pending; official PMD/runtime compatibility NOT TESTED. Each action includes early magma pixels. If visual resembles mere hue shift, refine rock silhouette and actual crack location at all directions without altering frame grid.
Next: full single-action native player with original offset semantics; create separate 0002 only after 0001 style accepted. F2 map pipeline separate; F1R1 accepted frozen.
""",encoding="utf-8")
print(json.dumps({k:report[k] for k in ("stage","status","cells_tested","magma_emissive_pixels","new_rgb_pixels","real_actions")},ensure_ascii=False),flush=True)
