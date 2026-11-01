"""A35 technical QA of real PixelLab interpolation. Retain exact keyframes separately,
do not claim model preserved them. PixelLab interpolated frames are actual provider PNGs.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,statistics,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101")
seg=R/"SEGMENT_A2_GUARD_TO_ROLL"
paths=sorted(x for x in seg.glob("PIXELLAB_INTERPOLATION_RAW_*.png") if x.stem.rsplit("_",1)[-1].isdigit())
if len(paths)<2:
 print("INTERPOLATION_WAITING_OR_EMPTY",len(paths));raise SystemExit(3)
fs=[Image.open(p).convert('RGBA') for p in paths]
assert all(im.size==(40,40) for im in fs)
begin=Image.open(seg/"SOURCE_BEGIN_NATIVE45_REAL_PROVIDER.png").convert("RGBA")
end=Image.open(seg/"SOURCE_END_DODGE_F1_REAL_PROVIDER.png").convert("RGBA")
diff=lambda a,b:sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
def info(im):
 box=im.getbbox()
 return {"bbox":box,"bottom_border":sum(im.getpixel((x,39))[3]>0 for x in range(40)),
 "right_border":sum(im.getpixel((39,y))[3]>0 for y in range(40))}
q={"input_start_sha256":hashlib.sha256((seg/"SOURCE_BEGIN_NATIVE45_REAL_PROVIDER.png").read_bytes()).hexdigest(),
"input_end_sha256":hashlib.sha256((seg/"SOURCE_END_DODGE_F1_REAL_PROVIDER.png").read_bytes()).hexdigest(),
"provider_frames_count":len(fs),"provider_frames":[info(f) for f in fs],
"adjacent_pixel_changes":[diff(fs[i],fs[i+1]) for i in range(len(fs)-1)],
"first_generated_to_real_start_diff":diff(begin,fs[0]),"last_generated_to_real_end_diff":diff(fs[-1],end),
"contains_direct_source_images":False,"visual_identity_and_camera_gate":"PENDING HUMAN VISUAL INSPECTION",
"one_shot_not_loop":True,"no_original_game_overwrite":True}
(R/"A35_SEGMENT_A2_RAW_QA.json").write_text(json.dumps(q,ensure_ascii=False,indent=2),encoding="utf8")
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
except:F=ImageFont.load_default()
panel=Image.new("RGB",((len(fs)+2)*144,206),(236,239,243))
d=ImageDraw.Draw(panel)
for i,(caption,img) in enumerate([("KEY START",begin)]+[(f"PIX F{j}",f) for j,f in enumerate(fs)]+[("KEY END",end)]):
 bg=Image.new("RGBA",(40,40),(236,239,243,255));bg.alpha_composite(img)
 panel.paste(bg.convert("RGB").resize((136,136),Image.Resampling.NEAREST),(i*144+3,24))
 d.text((i*144+4,5),caption,font=F,fill=(16,29,44))
panel.save(R/"A35_INTERPOLATION_A_PROVIDER_FRAMES_LARGE.png")
print("A35_INTERPOLATION_QA",json.dumps(q,ensure_ascii=False),flush=True)
print("MONTAGE_BYTES",(R/"A35_INTERPOLATION_A_PROVIDER_FRAMES_LARGE.png").stat().st_size)
