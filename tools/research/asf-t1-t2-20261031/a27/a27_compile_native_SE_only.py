"""A27: native PMD 8-row atlas SE-only technical candidates.
Input is verified A25 user-approved design and real A26/A27 PixelLab PNGs.
Does not claim 8 directions matching or mutate sealed PMD/XML/Offset/Shadow.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import xml.etree.ElementTree as ET
import json,hashlib,shutil
G9=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025\outputs\P3_G9_FULL_0001_0002_0003_EVOLUTION_20261027\0001")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
A25=Path(r"E:\GameAssetToolLab_20261023\A25_T1_PIXELLAB_CONCEPT_FROM_REAL_SOURCES_20261101")
OUT=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101\PMD_XML_SE_ONLY_CANDIDATES")
OUT.mkdir(parents=True,exist_ok=True)
act={"idle":"Idle","walk":"Walk","attack":"Attack","cast":"Charge","hurt":"Hurt","death":"Faint"}
seed=Image.open(A25/"PMD0001"/"PIXELLAB_CONCEPT_64.png").convert("RGBA")
assert seed.size==(64,64)
seedbox=seed.getbbox()
assert seedbox==(20,22,47,46)
xml=ET.parse(G9/"AnimData.xml").getroot()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def component_clean(im):
 # preserve largest 8-neighbor silhouette component; remove disjoint rock/blob artifacts
 a=im.getchannel("A"); w,h=im.size
 seen=set(); comps=[]
 for y in range(h):
  for x in range(w):
   if a.getpixel((x,y))==0 or (x,y) in seen:continue
   stack=[(x,y)];seen.add((x,y));comp=[]
   while stack:
    xx,yy=stack.pop();comp.append((xx,yy))
    for ny in range(max(0,yy-1),min(h,yy+2)):
     for nx in range(max(0,xx-1),min(w,xx+2)):
      if (nx,ny) not in seen and a.getpixel((nx,ny))>0:
       seen.add((nx,ny));stack.append((nx,ny))
   comps.append(comp)
 if not comps:return im.copy(),0,0
 comps.sort(key=len,reverse=True)
 kept=set(comps[0]);out=im.copy();p=out.load()
 removed=0
 for y in range(h):
  for x in range(w):
   if a.getpixel((x,y))>0 and (x,y) not in kept:
    p[x,y]=(0,0,0,0);removed+=1
 return out,removed,len(comps)
results={}
for key,name in act.items():
 folder=A26/("PMD_"+key.upper())
 if not (folder/"PIXELLAB_FRAME_04.png").exists():
  results[key]={"status":"WAITING_PROVIDER","reason":"required raw 5 frames absent"}
  continue
 el=next(x for x in xml.findall(".//Anim") if x.findtext("Name")==name)
 cw=int(el.findtext("FrameWidth"));ch=int(el.findtext("FrameHeight"))
 png=G9/(name+"-Anim.png")
 original=Image.open(png).convert("RGBA")
 native_frames=original.width//cw;rows=original.height//ch
 assert rows==8
 orig_frame=original.crop((0,ch,cw,2*ch))
 bx=orig_frame.getbbox()
 assert bx
 anchor_x=(bx[0]+bx[2])/2;anchor_bottom=bx[3]
 seed_cx=(seedbox[0]+seedbox[2])/2;seed_bottom=seedbox[3]
 base_dx=round(anchor_x-seed_cx);base_dy=round(anchor_bottom-seed_bottom)
 raw=[Image.open(folder/f"PIXELLAB_FRAME_{i:02}.png").convert("RGBA") for i in range(5)]
 if key=="idle":
  raw=[Image.open(folder/f"REVIEW_CLEAN_FRAME_{i:02}.png").convert("RGBA") for i in range(5)]
 cleans=[];removed=[];components=[]
 for im in raw:
  if key not in ("idle","walk"):
   clean,n,parts=component_clean(im)
  else:clean,n,parts=im.copy(),0,1
  cleans.append(clean);removed.append(n);components.append(parts)
 # Create complete 5-frame original 64x64 cleaned strip
 strip=Image.new("RGBA",(64*5,64))
 for i,im in enumerate(cleans):
  strip.alpha_composite(im,(64*i,0));im.save(OUT/f"{name}_SE45_CLEANED_FRAME_{i:02}.png")
 strip.save(OUT/(name+"_SE45_CLEAN_64x5.png"))
 atlas=original.copy()
 mapping=[];outbounds=[]
 for frame_id in range(native_frames):
  provider_idx=round(frame_id*(len(cleans)-1)/max(1,native_frames-1))
  img=cleans[provider_idx]
  bbox=img.getbbox()
  # keep exact approved pixel positions; clamp to native cell only where geometry otherwise crops
  dx=base_dx;dy=base_dy
  if bbox:
   dx+=max(0,-(bbox[0]+dx))
   dy+=max(0,-(bbox[1]+dy))
   dx-=max(0,(bbox[2]+dx)-cw)
   dy-=max(0,(bbox[3]+dy)-ch)
  # ensure no pixel clipping after placement; if bboxes too big, record it
  placed=Image.new("RGBA",(cw,ch))
  placed.alpha_composite(img,(dx,dy))
  # moving compositing in PIL clips, check counting theoretical clipped pixels.
  clipped=0
  for y in range(64):
   for x in range(64):
    if img.getpixel((x,y))[3]>0 and not (0<=x+dx<cw and 0<=y+dy<ch):clipped+=1
  outbounds.append(clipped)
  atlas.paste(placed,(frame_id*cw,ch),placed) if False else None
  # IMPORTANT: replace entire native frame (allows transparent pixels to erase old source)
  atlas.paste(placed,(frame_id*cw,ch))
  mapping.append({"native_frame":frame_id,"generated_idx":provider_idx,"delta":[dx,dy],"clipped_pixels":clipped})
 atlasfile=OUT/(name+"_8ROW_SE_ONLY_XML_GEOMETRY_CANDIDATE.png")
 atlas.save(atlasfile)
 # source immutable check; rows 0 and 2..7 pixel-exact
 r0=original.crop((0,0,original.width,ch))
 r0new=atlas.crop((0,0,original.width,ch))
 other_ok=r0.tobytes()==r0new.tobytes()
 for row in range(2,8):
  a=original.crop((0,row*ch,original.width,(row+1)*ch))
  b=atlas.crop((0,row*ch,atlas.width,(row+1)*ch))
  other_ok &= a.tobytes()==b.tobytes()
 results[key]={"status":"SE_ROW_ONLY_NATIVE_CANDIDATE","native_action":name,"cell":[cw,ch],
  "native_frame_count":native_frames,"provider_frame_count":5,"atlas_dimensions":list(original.size),
  "unchanged_other_seven_directions":other_ok,"provider_disconnected_removed":removed,
  "provider_components_per_frame":components,"retime_map":mapping,"total_clipped_pixels":sum(outbounds),
  "formal_gate":"NOT_PASS - 7 facings unadapted, image quality/velocity to review"}
 assert other_ok
resultpath=OUT/"A27_XML_SE_ONLY_COMPILE_QA.json"
resultpath.write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({k:{"status":v["status"],"frames":v.get("native_frame_count"),"clipped":v.get("total_clipped_pixels"),"removed":v.get("provider_disconnected_removed")} for k,v in results.items()},ensure_ascii=False,indent=2))
