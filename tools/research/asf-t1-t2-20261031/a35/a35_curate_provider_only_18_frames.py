"""A35 human-readable semantic curation of REAL native-keyframes and PixelLab provider frames.
Only indices from the genuine provider inputs; no new raster art, no 'smoothing' algorithm.
A interpolation frames 8-13 retain an unwanted lying phase AFTER a successful inversion,
B recovery frames 5-6 rebound to handstand AFTER getting up; remove these double-motion glitches.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101")
A=R/"SEGMENT_A2_GUARD_TO_ROLL";B=R/"SEGMENT_B_ROLL_TO_GUARD"
get=lambda p:Image.open(p).convert("RGBA")
start=get(A/"SOURCE_BEGIN_NATIVE45_REAL_PROVIDER.png")
f1=get(A/"SOURCE_END_DODGE_F1_REAL_PROVIDER.png")
assert start.tobytes()==get(B/"SOURCE_END_DODGE_F1_REAL_PROVIDER.png").tobytes()
a={i:get(A/f"PIXELLAB_INTERPOLATION_RAW_{i:02}.png") for i in range(14)}
b={i:get(B/f"PIXELLAB_INTERPOLATION_RAW_{i:02}.png") for i in range(14)}
seq=[("F0",start)]+[("A"+str(i),a[i]) for i in [0,1,2,3,4,5,6,7]]+[("F1",f1)]+[("B"+str(i),b[i]) for i in [0,1,2,3,4,7,8]]+[("F2",start)]
def diff(x,y):return sum(p!=q for p,q in zip(x.getdata(),y.getdata()))
d=[diff(seq[i][1],seq[i+1][1]) for i in range(len(seq)-1)]
# All selected from source PNG or actual PixelLab provider generated pixel outputs.
assert len(seq)==18
assert all(x.size==(40,40) for name,x in seq)
strip=Image.new("RGBA",(40*len(seq),40))
for idx,(name,im) in enumerate(seq):strip.alpha_composite(im,(idx*40,0))
strip.save(R/"A35_SEMANTIC_SELECTED_PROVIDER_ONLY_18FRAME.png")
imgs=[im for name,im in seq]
durations=[140]+[55]*8+[85]+[55]*7+[300]
imgs[0].save(R/"A35_SEMANTIC_SELECTED_DODGING_ONESHOT.gif",save_all=True,
 append_images=imgs[1:],duration=durations,loop=1,disposal=2,optimize=False)
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
except:font=ImageFont.load_default()
board=Image.new("RGB",(6*205,3*219),(236,240,243));draw=ImageDraw.Draw(board)
for idx,(name,im) in enumerate(seq):
 x=(idx%6)*205;y=(idx//6)*219
 bg=Image.new("RGBA",(40,40),(236,240,243,255));bg.alpha_composite(im)
 board.paste(bg.convert("RGB").resize((196,196),Image.Resampling.NEAREST),(x+4,y+22))
 draw.text((x+9,y+3),f"{idx:02} / {name}",fill=(25,37,51),font=font)
board.save(R/"A35_18FRAME_CURATED_REAL_PROVIDER_REVIEW.png")
report={"sequence":[name for name,im in seq],"per_frame_times_ms":durations,
 "adjacent_change":d,"largest_transition":max(d),"smallest_transition":min(d),
 "source_battle_F0_equals_F2":diff(seq[0][1],seq[-1][1])==0,
 "real_pixelLab_frames_only":True,"no_synthetic_pose_creation":True,
 "curation_reason":"A8-A13 became prone AFTER reaching invert and B5-B6 returned upside-down AFTER already standing. Removed these duplicated/unphysical moves; preserve all raw sequences unmodified.",
 "limitations":"Interpolation differs from source endpoints and some transitions remain >500 changed pixels; requires human approval for motion, 45-degree facing, and true SBS weapon-overlay test."}
(R/"A35_CURATED_18FRAME_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("CURATION_QA",json.dumps(report,ensure_ascii=False),flush=True)
print("GIF_BYTES",(R/"A35_SEMANTIC_SELECTED_DODGING_ONESHOT.gif").stat().st_size)
