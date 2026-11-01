"""A37 user-selected variant 4 for DODGING; strict 3-frame SBS candidate.
Use exact A36 T4 art; no PixelLab repaint, no independent generated frames.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,shutil
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A37_FS_T4_DODGE_AND_DAMAGE_20261101";R.mkdir(parents=True,exist_ok=True)
SRC=B/"A36_FS_ACTION_3FRAME_FORMAL_20261101"/"T4_ANTICIPATE_ROLL_LAND_3FRAME_40.png"
SRC_GIF=B/"A36_FS_ACTION_3FRAME_FORMAL_20261101"/"T4_ANTICIPATE_ROLL_LAND_3FRAME_ONESHOT.gif"
im=Image.open(SRC).convert("RGBA");assert im.size==(120,40)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def d(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
fs=[im.crop((i*40,0,(i+1)*40,40)) for i in range(3)]
name=R/"A37_DODGING_T4_USER_SELECTED_3FRAME_120x40.png"
name.write_bytes(SRC.read_bytes())
assert sha(name)==sha(SRC)
for i,f in enumerate(fs):f.save(R/f"A37_DODGING_T4_FRAME_{i:02}.png")
# Use 3 unmodified artist/provider real frames, but GIF is playback only.
fs[0].save(R/"A37_DODGING_T4_USER_SELECTED_ONESHOT.gif",
save_all=True,append_images=fs[1:],duration=[150,220,360],disposal=2,optimize=False)
g=Image.open(R/"A37_DODGING_T4_USER_SELECTED_ONESHOT.gif")
assert g.n_frames==3 and g.info.get('loop') is None
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",20)
except:F=ImageFont.load_default()
p=Image.new("RGB",(3*315,355),(234,238,243));drawer=ImageDraw.Draw(p)
for i,f in enumerate(fs):
 bg=Image.new("RGBA",(40,40),(234,238,243,255));bg.alpha_composite(f)
 p.paste(bg.convert("RGB").resize((294,294),Image.Resampling.NEAREST),(i*315+10,38))
 drawer.text((i*315+10,8),["F0 | ANTICIPATE","F1 | ROLL","F2 | LAND"][i],font=F,fill=(23,37,53))
p.save(R/"A37_DODGING_T4_USER_SELECTED_PREVIEW.png",optimize=True)
q={"stage":"A37","action":"Dodging","user_selection":"T4 fourth alternative user selected","status":"USER CHOSE T4, INTEGRATION AND 45DEG PER-FRAME GATE NOT YET TESTED",
"source_path":str(SRC),"source_sha":sha(SRC),"output_sha":sha(name),
"frame_source":[
"A35 genuine PixelLab interpolation frame segment A02",
"A35 genuine PixelLab interpolation frame segment A06",
"A35 genuine PixelLab interpolation frame segment B07"],
"native_size":[40,40],"sheet_size":[120,40],"frame_count":3,
"frame_bbox":[f.getbbox() for f in fs],"f0_to_f1_changed_pixels":d(fs[0],fs[1]),
"f1_to_f2_changed_pixels":d(fs[1],fs[2]),
"one_shot_gif_nframes":g.n_frames,"no_extra_art_generation":True,"new_PixelLab_generation":0,
"per_frame_cam_art":"User selected the T4 composition; formal each-frame exact 45° QA still pending",
"weapon_paper_doll":"All actor sprites must be unarmed; SBS overlay test pending",
"source_authority":"A35 PixelLab raw frame sources unchanged; A36 variant T4 unchanged",
"other_FS_action":"Walk/Waiting are not altered; all source files and SBS code unchanged"}
(R/"A37_DODGING_T4_SELECTION_QA.json").write_text(json.dumps(q,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({"sha":sha(name),"frame_bbox":q["frame_bbox"],"diffs":[q["f0_to_f1_changed_pixels"],q["f1_to_f2_changed_pixels"]],"gif_nframes":g.n_frames},ensure_ascii=False))
