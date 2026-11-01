"""A28: deterministic Faint (Death) native 32x24 1px tail-tip lossless/collision-safe patch.
Only edits a COPY of A27 generated source; original A25 and PixelLab raw frames remain untouched.
"""
from pathlib import Path
from PIL import Image
import json,hashlib
A27=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
R=Path(r"E:\GameAssetToolLab_20261023\A28_FS_SKELETON_BATTLE_AND_FOUR_ACTIONS_20261101")
p=A27/"PMD_XML_SE_ONLY_CANDIDATES"
source=Image.open(p/"Faint_SE45_CLEAN_64x5.png").convert('RGBA')
atlas=Image.open(p/"Faint_8ROW_SE_ONLY_XML_GEOMETRY_CANDIDATE.png").convert('RGBA')
assert source.size==(320,64) and atlas.size==(128,192)
# Frame4 output 64px in strip, frame3/native last end pose F4.
fr=source.crop((4*64,0,5*64,64));box=fr.getbbox()
assert box==(15,24,48,46),box
affected=[(x,y) for y in range(64) for x in range(64) if fr.getpixel((x,y))[3]>0 and x==box[0]]
# Careful: if leftmost column has more than one pixel, preserve structure by only
# clipping minimal tail-tip (the original native atlas already removes 1 pixel).
assert len(affected)==1,affected
x,y=affected[0]
fixed=fr.copy();fixed.putpixel((x,y),(0,0,0,0))
assert fixed.getbbox()==(16,24,48,46)
fixed.save(R/"PMD_Faint_lastFrame_tailtip_1px_patched_64.png")
newstrip=source.copy();newstrip.paste(fixed,(4*64,0))
newstrip.save(R/"PMD_Faint_clean5f_native_compatible_64strip.png")
# Last native Faint SE frame uses F4, source bbox now x16..48; with dx=-16, y=-24,
# it fits native 32x24 exactly with no pixels clipped.
cel=Image.new('RGBA',(32,24))
cel.alpha_composite(fixed,(-16,-24))
native=atlas.copy();native.paste(cel,(3*32,24)) # only SE row1 last native frame
nativefile=R/"Faint_8ROW_SE_ONLY_XML_GEOMETRY_CANDIDATE_1px_TAIL_FIX.png";native.save(nativefile)
# verify original 7 rows pixel perfect and only last SE cell changed.
for row in [0,2,3,4,5,6,7]:
 assert native.crop((0,row*24,128,(row+1)*24)).tobytes()==atlas.crop((0,row*24,128,(row+1)*24)).tobytes()
changes=sum(a!=b for a,b in zip(native.getdata(),atlas.getdata()))
# native atlas initially clipped exactly this same pixel, so the final native image may be pixel-identical.
log={"stage":"A28_Faint_pixel_compact","source_frame_bbox":box,
     "changed_source_pixels":1,"removed_pixel_coordinate":[x,y],"new_bbox":fixed.getbbox(),
     "native_clipped_pixels":0,"native_atlas_changes_vs_A27":changes,
     "seven_unedited_rows_sha_equivalent":True,
     "status":"TECHNICAL native geometry candidate; user art review still pending"}
(R/"A28_FAINT_1PX_FIX_QA.json").write_text(json.dumps(log,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(log,ensure_ascii=False))
