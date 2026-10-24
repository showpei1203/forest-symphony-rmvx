from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json
R=Path(__file__).resolve().parent.parent
P=R.parent
OLD=R
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
source=Image.open(R/"source/reference/AI_V23_FULL_STYLE_MASTER.png").convert("RGBA")
assert source.size==(1434,1097)
# Human-reviewed polygon relative to 455x320, 355x300 source ROIs.
house_defs={
 "elf_blue_cottage":{
  "source_box":[40,30,495,350],
  "polygon":[[179,7],[191,8],[196,37],[225,39],[245,42],[283,39],[300,43],
    [302,27],[332,27],[345,37],[345,142],[348,175],[351,199],[343,236],
    [329,247],[308,250],[278,253],[255,263],[237,275],[208,279],
    [144,281],[130,271],[99,269],[60,271],[47,259],[49,177],
    [53,145],[53,42],[68,35],[141,38],[159,27],[173,15]],
  "resize_scale":0.70,"safety_padding":7,
  "target_center_x":216,"target_foot_y":207,
  "kind":"cottage_blue","body_foot_y_frac":0.69,"body_left_frac":0.12,"body_right_frac":0.92,
  "roof_occlusion_frac":0.57
 },
 "elf_ochre_cottage":{
  "source_box":[325,705,680,1005],
  "polygon":[[267,35],[288,38],[296,51],[308,52],[321,62],[320,210],[327,227],
    [324,247],[310,259],[279,261],[260,254],[248,240],[218,248],
    [192,243],[165,246],[136,248],[112,252],[80,252],[55,252],
    [38,244],[26,222],[31,178],[36,146],[35,65],[53,53],[80,43],[250,43]],
  "resize_scale":0.68,"safety_padding":7,
  "target_center_x":114,"target_foot_y":407,
  "kind":"cottage_ochre","body_foot_y_frac":0.69,"body_left_frac":0.12,"body_right_frac":0.90,
  "roof_occlusion_frac":0.53
 }
}
for name,o in house_defs.items():
 box=o["source_box"];cut=source.crop(tuple(box))
 mask=Image.new("L",cut.size,0);dr=ImageDraw.Draw(mask)
 dr.polygon([tuple(z) for z in o["polygon"]],fill=255)
 cut.putalpha(mask)
 # Tight after full-source polygon; unlike previous clip, preserve *all* traced appendages:
 ext=cut.getchannel("A").getbbox()
 assert ext and ext[0]>0 and ext[1]>0 and ext[2]<cut.width and ext[3]<cut.height
 cut=cut.crop(ext)
 src_asset=R/"source/original"/(name+"_full_res_polygon.png")
 cut.save(src_asset)
 scaled=(round(cut.width*o["resize_scale"]),round(cut.height*o["resize_scale"]))
 sprite=cut.resize(scaled,Image.Resampling.NEAREST)
 pad=o["safety_padding"]
 final=Image.new("RGBA",(sprite.width+2*pad,sprite.height+2*pad),(0,0,0,0))
 final.alpha_composite(sprite,(pad,pad))
 # Normalize invisible channel, keep nearest-neighbor pixels:
 final.putdata([(r,g,b,a) if a else (0,0,0,0) for r,g,b,a in final.get_flattened_data()])
 visible_bbox=final.getchannel("A").getbbox()
 assert visible_bbox is not None and visible_bbox[0]>=pad and visible_bbox[1]>=pad
 assert visible_bbox[2]<=pad+sprite.width and visible_bbox[3]<=pad+sprite.height
 assert all(final.getchannel("A").getpixel((x,0))==0 for x in range(final.width))
 assert all(final.getchannel("A").getpixel((0,y))==0 for y in range(final.height))
 dest=R/"source/generated"/(name+".png");final.save(dest)
 o["tight_source_bbox_on_original"]=[box[0]+ext[0],box[1]+ext[1],box[0]+ext[2],box[1]+ext[3]]
 o["full_res_object_pixels"]=sum(1 for v in cut.getchannel("A").get_flattened_data() if v)
 o["output_size"]=[final.width,final.height]
 o["output_sha256"]=digest(dest)
 o["original_v23_size"]=[Image.open(OLD/"source/original"/(name+".png")).width,Image.open(OLD/"source/original"/(name+".png")).height]
 o["output_alpha_visible_bbox"]=list(final.getchannel("A").getbbox())
 print("V231_REBUILT_SOURCE",name,json.dumps({"bbox":o["tight_source_bbox_on_original"],
   "size":o["output_size"],"pixels":o["full_res_object_pixels"],
   "old":o["original_v23_size"],"sha":o["output_sha256"][:16]},ensure_ascii=False),flush=True)
# A stand-alone source ledger to reproduce the extracted image, not merely a pasted image.
ledger={"schema":"STYLE_FIRST_V231_HOUSE_FULL_MASTER_ROI_MASKED",
        "source":"source/reference/AI_V23_FULL_STYLE_MASTER.png",
        "source_sha256":digest(R/"source/reference/AI_V23_FULL_STYLE_MASTER.png"),
        "version_parent":"V23_USER_FAIL_SOURCE_COMPLETE_AND_SCALE",
        "houses":house_defs,"mask":"EXPLICIT_FULL_RES_POLYGON_VALIDATED_PADDING",
        "pixel_crisp_resize":"PIL_NEAREST","human_new_visual":"NOT_RUN"}
(R/"input/V231_REEXTRACTION_LEDGER.json").write_text(json.dumps(ledger,indent=2,ensure_ascii=False),encoding="utf8")
