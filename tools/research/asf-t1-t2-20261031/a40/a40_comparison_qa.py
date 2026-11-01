"""A40 QA real PixelLab skeleton-controlled critical hit vs A38/A39 prompt-only.
No manual painting, no fabricated poses. Source F0 unchanged in separately labeled assembly.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
A38=B/"A38_DAMAGE_F1_NATIVE_45_IMAGE_EDIT_20261101"
A39=B/"A39_CRITICAL_DAMAGE_NATIVE45_20261101"
files=[R/f"A40_REAL_SKELETON_V3_FRAME_{i:02}.png" for i in range(3)]
if not all(f.exists() for f in files):
 print("SKEL_PROVIDER_NOT_READY");raise SystemExit(2)
F=[Image.open(p).convert("RGBA") for p in files]
base=Image.open(A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png").convert("RGBA")
normal=Image.open(A38/"A38_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png").convert("RGBA")
critold=Image.open(A39/"A39_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png").convert("RGBA")
assert all(f.size==(40,40) for f in F+[base,normal,critold])
def delta(a,b):return sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
def metrics(im):
 return {"bbox":im.getbbox(),"alpha":sum(c[3]>0 for c in im.getdata()),
 "right_edge":sum(im.getpixel((39,y))[3]>0 for y in range(40)),
 "bottom_edge":sum(im.getpixel((x,39))[3]>0 for x in range(40))}
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",18)
except:font=ImageFont.load_default()
panels=[
("A34 ORIGINAL / F0",base),("A38 NORMAL DAMAGE",normal),("A39 CRITICAL WORD-ONLY",critold),
("A40 REAL SKELETON F0",F[0]),("A40 REAL SKELETON F1",F[1]),("A40 REAL SKELETON F2",F[2])]
p=Image.new("RGB",(3*308,2*336),(235,240,244));d=ImageDraw.Draw(p)
for i,(name,im) in enumerate(panels):
 x=i%3*308;y=i//3*336
 bg=Image.new("RGBA",(40,40),(235,240,244,255));bg.alpha_composite(im)
 p.paste(bg.convert("RGB").resize((293,293),Image.Resampling.NEAREST),(x+7,y+37))
 d.text((x+8,y+8),name,font=font,fill=(20,34,49))
p.save(R/"A40_NATIVE_VS_NORMAL_VS_CRITICAL_SKELETON_COMPARISON.png",optimize=True)
# Preserve real provider output; make separately labeled formal 3-frame candidate exact source F0 + 2 provider poses.
out=[base,F[1],F[2]]
sheet=Image.new("RGBA",(120,40))
for i,im in enumerate(out):sheet.alpha_composite(im,(i*40,0))
path=R/"A40_CRITICAL_SOURCE_ANCHORED_3FRAME_CANDIDATE.png";sheet.save(path)
out[0].save(R/"A40_CRITICAL_ANCHORED_3FRAME_ONESHOT.gif",save_all=True,append_images=out[1:],
 duration=[150,235,490],disposal=2,optimize=False)
gi=Image.open(R/"A40_CRITICAL_ANCHORED_3FRAME_ONESHOT.gif")
assert gi.n_frames==3 and gi.info.get('loop') is None
report={"stage":"A40","title":"True 18-joint skeletal-controlled severe hit animation 3 frames",
"source_f0":"A34 true Pixellab white-hair 45deg battle reference","provider_raw":[metrics(x) for x in F],
"source_anchored_candidate":[metrics(x) for x in out],
"pixel_delta_raw_vs_base":[delta(base,x) for x in F],
"normal_damage_vs_f2_delta":delta(normal,F[2]),
"old_critical_vs_f2_delta":delta(critold,F[2]),
"raw_adjacent_changed_pixels":[delta(F[i],F[i+1]) for i in range(2)],
"source_anchored_adjacent_changed_pixels":[delta(out[i],out[i+1]) for i in range(2)],
"source_anchored_F0_exact":delta(base,out[0])==0,
"native_size":[40,40],"sprite_sheet_size":[120,40],"exact_three_frame":True,
"canvas_crop_gate":"FAIL" if any(x["right_edge"] or x["bottom_edge"] for x in [metrics(y) for y in out]) else "PASS",
"artist_45deg_gate":"PENDING visual review for all frames; any single 90deg profile FAIL",
"art_character_identity":"PENDING","motion_critical_severity":"PENDING",
"armament_paperdoll":"not tested in SBS","VX_engine":"NOT TESTED",
"source_file_unmodified":True,"raw_provider_preserved":True,
"comparison_png_sha256":hashlib.sha256((R/"A40_NATIVE_VS_NORMAL_VS_CRITICAL_SKELETON_COMPARISON.png").read_bytes()).hexdigest()}
(R/"A40_SOURCE_ANCHORED_COMPARE_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("A40_QA",json.dumps(report,ensure_ascii=False),flush=True)
