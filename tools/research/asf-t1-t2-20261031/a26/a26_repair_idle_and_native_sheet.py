"""A26 PMD source-locked fail-closed pixel cleanup and native-sized preview sheets."""
from pathlib import Path
from PIL import Image,ImageFilter
import json,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
A25=Path(r"E:\GameAssetToolLab_20261023\A25_T1_PIXELLAB_CONCEPT_FROM_REAL_SOURCES_20261101")
source=Image.open(A25/"PMD0001"/"PIXELLAB_CONCEPT_64.png").convert("RGBA")
reference_bbox=source.getbbox()
assert reference_bbox==(20,22,47,46),reference_bbox
# Keep only pixels at most two true pixel units outside the exact approved monster silhouette.
# This is suitable only for idle; action with a legitimate leap/attack needs different limits.
sm=source.getchannel("A").point(lambda a:255 if a>0 else 0)
allowed=sm.filter(ImageFilter.MaxFilter(5))
report={}
for name,(W,H,y) in {"IDLE":(32,40,12),"WALK":(40,40,12)}.items():
 folder=R/("PMD_"+name)
 frames=[Image.open(folder/f"PIXELLAB_FRAME_{i:02}.png").convert("RGBA") for i in range(5)]
 assert all(im.size==(64,64) for im in frames)
 before=[];after=[]
 cleaned=[]
 for i,frame in enumerate(frames):
  old=frame.getchannel("A")
  orig_extra=sum(old.getpixel((x,z))>0 and allowed.getpixel((x,z))==0 for z in range(64) for x in range(64))
  before.append(orig_extra)
  if name=="IDLE" and i>0:
   pixels=frame.load()
   for z in range(64):
    for x in range(64):
     if allowed.getpixel((x,z))==0:pixels[x,z]=(0,0,0,0)
  new=frame.getchannel("A")
  after.append(sum(new.getpixel((x,z))>0 and allowed.getpixel((x,z))==0 for z in range(64) for x in range(64)))
  cleaned.append(frame)
  frame.save(folder/f"REVIEW_CLEAN_FRAME_{i:02}.png")
 sheet=Image.new("RGBA",(64*len(cleaned),64))
 native=Image.new("RGBA",(W*len(cleaned),H))
 for i,f in enumerate(cleaned):
  sheet.alpha_composite(f,(64*i,0))
  native.alpha_composite(f.crop(((64-W)//2,y,(64+W)//2,y+H)),(W*i,0))
 sheet.save(folder/f"{name}_SOURCE_LOCKED_CLEAN_64x5.png")
 native.save(folder/f"{name}_NATIVE_{W}x{H}_5F_CANDIDATE.png")
 # view on gray and nearest-neighbor 6x
 preview=Image.new("RGB",(64*5*6,64*6),(230,233,237))
 for i,f in enumerate(cleaned):
  bg=Image.new("RGBA",(64,64),(230,233,237,255))
  bg.alpha_composite(f)
  preview.paste(bg.convert("RGB").resize((384,384),Image.Resampling.NEAREST),(i*384,0))
 preview.save(folder/f"{name}_CLEAN_6X_REVIEW.png")
 report[name]={"nframes":len(frames),"native_cell":[W,H],
 "generated_extra_opaque_pixels_outside_approved_dilation":before,
 "cleaned_extra_opaque_pixels_outside_approved_dilation":after,
 "raw_sheet":"PIXELLAB_SPRITESHEET_64x5.png",
 "source_locked_clean_sheet":f"{name}_SOURCE_LOCKED_CLEAN_64x5.png",
 "native_candidate_sheet":f"{name}_NATIVE_{W}x{H}_5F_CANDIDATE.png",
 "visual_status":"CANDIDATE_PRESERVED_NOT_APPROVED",
 "method":"Idle uses source alpha silhouette dilated 2 pixels; Walk raw frames unchanged"}
(R/"A26_PMD_TWO_SHEETS_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(report,ensure_ascii=False,indent=2))
