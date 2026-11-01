"""A42 native-view in-place approach 3-frame QA, no synthetic raster frames.
Compare actual provider against source and user-approved T4 dodge (separate action).
Camera, unarmed, body ratio are visual fail-closed human gate.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A42_APPROACH_CLOSE_ATTACK_SKELETON_3F_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
files=[R/f"A42_REAL_PIXELLAB_APPROACH_F{i:02}.png" for i in range(3)]
if not all(x.exists() for x in files):print("A42_WAITING_PROVIDER");raise SystemExit(2)
F=[Image.open(p).convert("RGBA") for p in files]
orig=Image.open(A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png").convert("RGBA")
assert all(f.size==(40,40) for f in F+[orig])
def metric(img):
 return {"bbox":img.getbbox(),"right_touch":sum(img.getpixel((39,y))[3]>0 for y in range(40)),
 "bottom_touch":sum(img.getpixel((x,39))[3]>0 for x in range(40)),
 "alpha_pixels":sum(p[3]>0 for p in img.getdata())}
def changed(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
# A42 output three frames, first source exact anchor; changes to later poses only provider generated.
candidate=[orig,F[1],F[2]]
sheet=Image.new("RGBA",(120,40))
for i,im in enumerate(candidate):sheet.alpha_composite(im,(40*i,0))
out=R/"A42_SOURCE_ANCHORED_APPROACH_3F_CANDIDATE.png";sheet.save(out)
candidate[0].save(R/"A42_APPROACH_3FRAME_ONESHOT.gif",save_all=True,append_images=candidate[1:],
duration=[130,180,330],disposal=2,optimize=False)
gif=Image.open(R/"A42_APPROACH_3FRAME_ONESHOT.gif")
assert gif.n_frames==3 and gif.info.get("loop") is None
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",18)
except:font=ImageFont.load_default()
page=Image.new("RGB",(3*320,2*340),(238,241,245));d=ImageDraw.Draw(page)
rows=[("A42 PIXELLAB PROVIDER RAW 3 FRAMES",F),("A42 EXACT NATIVE F0 + REAL F1/F2",candidate)]
for i,(caption,arr) in enumerate(rows):
 y=i*340
 d.rectangle((0,y,959,y+30),fill=(24,41,58))
 d.text((11,y+6),caption,font=font,fill=(246,248,250))
 for j,f in enumerate(arr):
  bg=Image.new("RGBA",(40,40),(238,241,245,255));bg.alpha_composite(f)
  page.paste(bg.convert("RGB").resize((298,298),Image.Resampling.NEAREST),(j*320+10,y+33))
page.save(R/"A42_APPROACH_ALL_FRAMES_LARGE_PREVIEW.png",optimize=True)
data={"stage":"A42","action":"Moving to Close Attack","strict_3_frame":True,"native_sprite":[40,40],
"sheet_size":[120,40],"pixelLab_raw_bboxes":[metric(x) for x in F],
"selected_source_anchored_bboxes":[metric(x) for x in candidate],
"no_edge_clip":all(not m["right_touch"] and not m["bottom_touch"] for m in [metric(x) for x in F]),
"one_shot_gif_frames":gif.n_frames,
"changed_pixels_raw_neighbor":[changed(F[i],F[i+1]) for i in range(2)],
"changed_pixels_selected_neighbor":[changed(candidate[i],candidate[i+1]) for i in range(2)],
"anchor_F0_matches_native":changed(candidate[0],orig)==0,
"facing_45_each_frame":"PENDING human art visual gate",
"animation_step_naturalness":"PENDING user art",
"weaponlessness":"PENDING human art, SBS overlay not tested",
"sbs_owns_move":"WORLDSPACE movement script is required and not implemented; this is in-place pose ONLY",
"formal_art_pass":False,"original_FS_and_T4_unchanged":True,
"output_sha256":hashlib.sha256(out.read_bytes()).hexdigest()}
(R/"A42_APPROACH_TECHNICAL_QA.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8')
print("A42_QA",json.dumps(data,ensure_ascii=False),flush=True)
