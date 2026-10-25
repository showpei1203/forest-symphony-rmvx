from pathlib import Path
from PIL import Image, ImageDraw
from scipy.ndimage import binary_dilation
import numpy as np,json,hashlib,xml.etree.ElementTree as ET,shutil
BASE=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
ROOT=BASE/"outputs/P3_R2_0001_UPSTREAM_PMD_20261026"
SRC=ROOT/"official_0001"
DST=ROOT/"STONEBACK_DERIVATIVE_0001"
assert not DST.exists(),"Fail-closed: no overwrite"
DST.mkdir()
XML=SRC/"AnimData.xml"
shutil.copy2(XML,DST/"AnimData.xml")
manifest=json.loads((ROOT/"DOWNLOAD_MANIFEST.json").read_text(encoding="utf-8"))
cfg={}
for a in manifest["animation_defs"]:
 if a["copyOf"]:continue
 cfg[a["name"]]={"fw":int(a["width"]),"fh":int(a["height"]),"frames":len(a["durations"])}
assert len(cfg)>=30
for f in SRC.glob("*-Offsets.png"):shutil.copy2(f,DST/f.name)
for f in SRC.glob("*-Shadow.png"):shutil.copy2(f,DST/f.name)
palette={
 (215,239,167): (198,196,171), # rocky stone belly
 (159,207,111): (140,148,137), # moss stone shadow
 (95,183,39): (98,108,111),   # slate shell / boulder
 (39,135,0): (57,71,79),      # shadowed rock faces
 (255,255,255): (255,248,220),
 (159,0,0): (241,161,57),     # distinctive amber eye
 (255,135,95):(235,175,104),  # mouth pale ochre
 (0,0,0):(0,0,0)
}
actionstats=[]
totalcells=0
facetframes=0
changedpixels=0
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for name,spec in cfg.items():
 f=SRC/(name+"-Anim.png")
 assert f.exists(),"Missing official action "+name
 im=Image.open(f).convert("RGBA")
 fw,fh,n=spec["fw"],spec["fh"],spec["frames"]
 assert im.width==fw*n and im.height%fh==0,(name,im.size,fw,fh,n)
 rows=im.height//fh
 original=np.asarray(im,dtype=np.uint8)
 changed=original.copy()
 # Color-mapped species change, every original opaque pixel persists, all XML anchors unchanged.
 for old,new in palette.items():
  mask=np.all(original[:,:,:3]==old,axis=2) & (original[:,:,3]>0)
  changed[mask,0]=new[0];changed[mask,1]=new[1];changed[mask,2]=new[2]
 count=0
 localfacet=0
 for direction in range(rows):
  for frame in range(n):
   y0=direction*fh;x0=frame*fw
   original_cell=original[y0:y0+fh,x0:x0+fw,:]
   cell=changed[y0:y0+fh,x0:x0+fw,:]
   # The original darkest + medium bulb pixels are the factual 0001 seed region.
   # Restrict new mineral facets strictly to original bulb pixels:
   # no frame displacement, offsets changes or cropped protrusions.
   darkest=np.all(original_cell[:,:,:3]==(39,135,0),axis=2)
   mid=np.all(original_cell[:,:,:3]==(95,183,39),axis=2)
   rock=darkest|mid
   ys,xs=np.where(rock)
   if len(xs)>7:
    xx0,xx1=int(xs.min()),int(xs.max())
    yy0,yy1=int(ys.min()),int(ys.max())
    width=xx1-xx0+1;height=yy1-yy0+1
    for yy,xx in zip(ys,xs):
     dx=xx-xx0;dy=yy-yy0
     # Angular granite face with two diagonal facet highlights.
     if (dx+2*dy)%(max(4,width//2+2)) in (0,1) and dy < height*.8:
      cell[yy,xx,:3]=[205,204,185]
     elif (2*dx-dy)%(max(5,height//2+3))==1:
      cell[yy,xx,:3]=[160,165,159]
     elif (dx*3+dy)%13==0:
      cell[yy,xx,:3]=[40,57,70]
    localfacet+=1
   count+=int(np.any(cell[:,:,:3]!=original_cell[:,:,:3],axis=2).sum())
   if not np.array_equal(cell[:,:,3],original_cell[:,:,3]):
    raise RuntimeError("Alpha occupancy altered! "+name)
 action=Image.fromarray(changed,"RGBA")
 target=DST/(name+"-Anim.png")
 action.save(target)
 assert action.size==im.size and np.array_equal(np.asarray(action)[:,:,3],original[:,:,3])
 actionstats.append({"action":name,"cells":rows*n,"frame_size":[fw,fh],"full_size":list(im.size),
                     "changed_RGB_pixels":count,"facet_applied_frames":localfacet,"alpha_exact_match":True,
                     "original_sha":digest(f),"derivative_sha":digest(target)})
 totalcells+=rows*n;facetframes+=localfacet;changedpixels+=count
# Detect any images not handled.
all_orig={p.name for p in SRC.glob("*-Anim.png")}
all_new={p.name for p in DST.glob("*-Anim.png")}
assert all_orig==all_new,(all_orig-all_new)
for f in [XML,*SRC.glob("*-Offsets.png"),*SRC.glob("*-Shadow.png")]:
 assert digest(f)==digest(DST/f.name),"XML/offset/shadow differed "+f.name
# Build direction/frame sample comparison: Idle + Attack + Walk: preserve cell layout on both full sides.
preview=Image.new("RGBA",(1100,630),(31,39,49,255))
text=ImageDraw.Draw(preview)
for row, name in enumerate(("Idle","Walk","Attack")):
 sp=cfg[name];fw,fh=sp["fw"],sp["fh"]
 img0=Image.open(SRC/(name+"-Anim.png")).convert("RGBA")
 img1=Image.open(DST/(name+"-Anim.png")).convert("RGBA")
 # chosen front 0, side 2, back 4, diagonal 6
 for c,dr in enumerate((0,2,4,6)):
  x=100+c*245
  before=img0.crop((0,dr*fh,fw,(dr+1)*fh)).resize((96,96),Image.Resampling.NEAREST)
  after=img1.crop((0,dr*fh,fw,(dr+1)*fh)).resize((96,96),Image.Resampling.NEAREST)
  preview.alpha_composite(before,(x,35+row*198))
  preview.alpha_composite(after,(x+111,35+row*198))
 text.text((10,90+row*198),name+" (orig/stone)",fill=(244,245,236,255))
preview.save(ROOT/"P3_R2_STONEBACK_COMPARE_ACTIONS.png")
# vertical 3 rows x frames with action letters
report={"source":"PMDCollab/SpriteCollab master sprite/0001","format":"full original PMD individual -Anim.png -Offsets.png -Shadow.png AnimData.xml",
        "actions_real":len(cfg),"xml_anims_including_copyof":len(manifest["animation_defs"]),
        "full_eight_dir_frame_cells":totalcells,"facet_enhanced_cells":facetframes,
        "changed_color_pixels":changedpixels,"xml_sha_exact_preserved":True,"offset_and_shadow_sha_exact":True,
        "every_action_sheet_dimensions_unchanged":True,"every_frame_alpha_occupancy_unchanged":True,
        "palette_change":"rock-grey body + dark mineral backpack with faceted highlights + amber eyes",
        "species_morphology":"bulb pixels converted to faceted stone texture in every directional/action frame, without changing silhouette; potential visual quality to be reviewed",
        "human_visual":"PENDING","actual_animation_runtime":"PENDING","source_rights":"Fan resource; credit PMDCollab and source contributors; commercial rights not verified",
        "actions":actionstats}
(ROOT/"P3_R2_SOURCE_FRAME_AUDIT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({k:v for k,v in report.items() if k not in ("actions",)},ensure_ascii=False))
