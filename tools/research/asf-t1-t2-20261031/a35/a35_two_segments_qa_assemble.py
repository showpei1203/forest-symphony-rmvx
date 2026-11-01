"""A35 genuine PixelLab 2-segment dodge test. No raster artwork synthesized or repainted.
Generate unedited raw 2-segment QA + two candidate sequences by selecting existing raw PNGs,
explicitly label stitched sequences as assemblies, never pretend native provider outputs.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,statistics,hashlib,zipfile
R=Path(r"E:\GameAssetToolLab_20261023\A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101")
A=R/"SEGMENT_A2_GUARD_TO_ROLL";B=R/"SEGMENT_B_ROLL_TO_GUARD"
def frames(folder):
 ps=sorted(p for p in folder.glob("PIXELLAB_INTERPOLATION_RAW_*.png") if p.stem.rsplit("_",1)[-1].isdigit())
 if not ps:return None
 return [Image.open(p).convert("RGBA") for p in ps]
a=frames(A);b=frames(B)
if not a or not b:print("WAITING_SEGMENTS",len(a or []),len(b or []));raise SystemExit(3)
start=Image.open(A/"SOURCE_BEGIN_NATIVE45_REAL_PROVIDER.png").convert("RGBA")
middle=Image.open(A/"SOURCE_END_DODGE_F1_REAL_PROVIDER.png").convert("RGBA")
end=Image.open(B/"SOURCE_END_DODGE_F1_REAL_PROVIDER.png").convert("RGBA")
assert all(im.size==(40,40) for im in [start,middle,end]+a+b)
def changed(x,y):return sum(p!=q for p,q in zip(x.getdata(),y.getdata()))
def inf(im):
 bbox=im.getbbox()
 return {"bbox":bbox,"end_right":sum(im.getpixel((39,i))[3]>0 for i in range(40)),
 "end_bottom":sum(im.getpixel((i,39))[3]>0 for i in range(40))}
# Provider /interpolation-v2 returns many unedited frames but may redraw endpoints.
# Every candidate boundary is an EXACT SHA/PX copy of A34 validated native-view original.
dense=[start]+a+[middle]+b+[end]
# Sparse only includes actual provider frames. 8 actual from each of 14 originals, selected
# in chronologically uniform order; no generating missing poses with nonprovider tools.
def sampling(arr,maxn):
 if len(arr)<=maxn:return arr
 ids=sorted({round(i*(len(arr)-1)/(maxn-1)) for i in range(maxn)})
 return [arr[i] for i in ids]
sparse=[start]+sampling(a,7)+[middle]+sampling(b,7)+[end]
def save_gif(path,items,durations):
 imgs=[im.convert("RGBA") for im in items]
 assert len(imgs)==len(durations)
 imgs[0].save(path,save_all=True,append_images=imgs[1:],duration=durations,loop=1,disposal=2,optimize=False)
def sheet(path,items):
 im=Image.new("RGBA",(40*len(items),40))
 for i,f in enumerate(items):im.alpha_composite(f,(i*40,0))
 im.save(path)
sheet(R/"A35_DENSE_2SEG_REAL_SOURCE_ASSEMBLY.png",dense)
sheet(R/"A35_SPARSE_2SEG_REAL_SOURCE_ASSEMBLY.png",sparse)
save_gif(R/"A35_DENSE_2SEG_ONE_SHOT.gif",dense,[55]*len(dense))
save_gif(R/"A35_SPARSE_2SEG_ONE_SHOT.gif",sparse,[75]*len(sparse))
# For each distinct actual action frame include 9x enlargement.
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",15)
except:F=ImageFont.load_default()
page=Image.new("RGB",(8*160,4*190),(238,241,245));d=ImageDraw.Draw(page)
for i,(name,im) in enumerate([("KEY F0",start)]+[("A"+str(j),x) for j,x in enumerate(a)]+[("KEY F1",middle)]+[("B"+str(j),x) for j,x in enumerate(b)]+[("KEY F2",end)]):
 x=(i%8)*160;y=(i//8)*190
 bg=Image.new("RGBA",(40,40),(238,241,245,255));bg.alpha_composite(im)
 page.paste(bg.convert("RGB").resize((155,155),Image.Resampling.NEAREST),(x,y+22))
 d.text((x+7,y+4),name,font=F,fill=(22,36,53))
page.save(R/"A35_ALL_INTERPOLATED_REAL_FRAMES_QA_MONTAGE.png",optimize=True)
report={
 "stage":"A35","source":"A34 true FS battle-view F0/F2 and reference-driven provider F1",
 "true_provider_frames_A":len(a),"true_provider_frames_B":len(b),
 "dense_frames":len(dense),"sparse_frames":len(sparse),
 "deltas_sparse":[changed(sparse[i],sparse[i+1]) for i in range(len(sparse)-1)],
 "deltas_dense":[changed(dense[i],dense[i+1]) for i in range(len(dense)-1)],
 "boundaries":[{"name":"master to first A","change":changed(start,a[0])},
   {"name":"last A to exact inverted","change":changed(a[-1],middle)},
   {"name":"inverted to first B","change":changed(middle,b[0])},
   {"name":"last B to exact master","change":changed(b[-1],end)}],
 "master_first_last_identical":changed(start,end)==0,
 "native_40x40_full_shape":all(x.size==(40,40) for x in dense),
 "border_clip_count":sum(bool(inf(x)["end_right"] or inf(x)["end_bottom"]) for x in dense),
 "all_frames_painted_by_pixelLab_or_exact_sources":True,
 "provider_outputs_raw_preserved":True,
 "no_manual_raster_paint":True,
 "animation_semantics":"ONE_SHOT forward roll, not loop; two segment motion sequence",
 "camera_gate":"Requires per-frame viewing; do not claim 45deg approved",
 "SBS_engine_gate":"NOT TESTED",
 "visual_motion_gate":"HUMAN REVIEW PENDING"}
(R/"A35_INTERPOLATION_FULL_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("A35_FULL_QA",json.dumps(report,ensure_ascii=False),flush=True)
print("OUTPUTS",[(p.name,p.stat().st_size) for p in [R/"A35_DENSE_2SEG_ONE_SHOT.gif",R/"A35_SPARSE_2SEG_ONE_SHOT.gif",R/"A35_ALL_INTERPOLATED_REAL_FRAMES_QA_MONTAGE.png"]])
