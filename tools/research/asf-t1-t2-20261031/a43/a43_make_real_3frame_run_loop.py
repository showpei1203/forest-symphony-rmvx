"""A43 actual FS Moving to Close Attack RUN LOOP, 3 source cells:
F0 = A31 true source c1 neutral planted
F1 = A31 true source c0 stride-left
F2 = A31 true source c2 stride-right
PLAYBACK repeat indices [0,1,0,2] exactly; do not store a fourth sprite.
A42 rejected old art remains unchanged. PixelLab cost 0, all frames real A31 approved art.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,zipfile
B=Path(r"E:\GameAssetToolLab_20261023")
A31=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"
A36=B/"A36_FS_ACTION_3FRAME_FORMAL_20261101"
A42=B/"A42_APPROACH_CLOSE_ATTACK_SKELETON_3F_20261101"
R=B/"A43_FS_RUN_LOOP_3FRAME_20261101"
R.mkdir(exist_ok=True)
src=A31/"A31_SE45_NATIVE_4FRAME_CYCLE_CANDIDATE.png"
assert src.exists()
orig=Image.open(src).convert("RGBA");assert orig.size==(160,40)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
c=[orig.crop((i*40,0,(i+1)*40,40)) for i in range(4)]
assert c[1].tobytes()==c[3].tobytes(),"A31 original 4-phase walk has nonmatching neutral poses; halt"
# We retain exact source geometry. Format exactly 3 frames.
selected=[c[1],c[0],c[2]]
names=["F0_FEET_PARALLEL_NEUTRAL","F1_STEP_LEFT","F2_STEP_RIGHT"]
sheet=Image.new("RGBA",(120,40))
for i,im in enumerate(selected):
 assert im.size==(40,40)
 sheet.alpha_composite(im,(40*i,0))
 im.save(R/(names[i]+"_40.png"))
out=R/"A43_MOVING_TO_CLOSE_ATTACK_RUN_3FRAME_120x40.png"
sheet.save(out)
# User explicitly specified neutral, left, neutral, right. 3 stored sprites only!
sequence=[0,1,0,2]
assert len(set(sequence))==3
speed_ms=115
# 12 repetitions for a clearly visible browser preview, GIF must intentionally loop
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",21)
except:font=ImageFont.load_default()
frames=[]
for k in sequence:
 bg=Image.new("RGBA",(40,40),(236,240,243,255));bg.alpha_composite(selected[k])
 box=Image.new("RGB",(640,392),(236,240,243))
 d=ImageDraw.Draw(box)
 box.paste(bg.convert("RGB").resize((320,320),Image.Resampling.NEAREST),(160,31))
 title=["F0  FEET NEUTRAL","F1  LEFT STEP","F2  RIGHT STEP"][k]
 d.text((10,8),"FS / Moving to Close Attack / 3 stored sprites",font=font,fill=(23,42,58))
 d.text((163,353),title,font=font,fill=(24,40,54))
 frames.append(box)
# Streaming loop is correct for Moving to Close Attack. GIF infinite loop on purpose.
gif=R/"A43_RUN_LOOP_PLAYBACK_0_1_0_2_8X.gif"
frames[0].save(gif,save_all=True,append_images=frames[1:],duration=[speed_ms]*4,
 loop=0,disposal=2,optimize=False)
assert Image.open(gif).n_frames==4
assert Image.open(gif).info.get("loop")==0
# pixel art sheets visually enlarged, three stored frames are only 3.
bg=Image.new("RGB",(1050,435),(236,240,243));d=ImageDraw.Draw(bg)
for k,im in enumerate(selected):
 pane=Image.new("RGBA",(40,40),(236,240,243,255));pane.alpha_composite(im)
 bg.paste(pane.convert("RGB").resize((320,320),Image.Resampling.NEAREST),(k*350+15,54))
 d.text((k*350+20,12),["F0 | BOTH FEET NEUTRAL","F1 | STEP LEFT","F2 | STEP RIGHT"][k],font=font,fill=(23,38,52))
 d.text((k*350+20,386),f"Stored column {k}; source A31 c{[1,0,2][k]}",font=font,fill=(45,56,69))
preview=R/"A43_MOVING_TO_CLOSE_ATTACK_3FRAME_LARGE_PREVIEW.png";bg.save(preview)
# original vs new, intentionally no A42 old sprite pixels used.
comp=Image.new("RGB",(1050,2*430),(236,240,243));dc=ImageDraw.Draw(comp)
old=Image.open(A42/"A42_SOURCE_ANCHORED_APPROACH_3F_CANDIDATE.png").convert("RGBA");assert old.size==(120,40)
for row,(label,srcseq) in enumerate([("A42  REJECTED: damage-looking action",[old.crop((i*40,0,(i+1)*40,40)) for i in range(3)]),
                                    ("A43  REAL RUN LOOP: neutral / left / right",selected)]):
 y=row*430;dc.rectangle((0,y,1049,y+32),fill=(27,44,59));dc.text((12,y+6),label,font=font,fill=(250,251,252))
 for i,p in enumerate(srcseq):
  b=Image.new("RGBA",(40,40),(236,240,243,255));b.alpha_composite(p)
  comp.paste(b.convert("RGB").resize((320,320),Image.Resampling.NEAREST),(i*350+15,y+46))
comp.save(R/"A43_A42_FAIL_VS_CORRECT_RUN_LOOP.png")
def delta(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def bbox(i):
 return {"bbox":i.getbbox(),
  "right_touch":sum(i.getpixel((39,y))[3]>0 for y in range(40)),
  "bottom_touch":sum(i.getpixel((x,39))[3]>0 for x in range(40))}
qa={"stage":"A43","date":"2026-11-01","action":"Moving to Close Attack",
"source":"A31 accepted source motion, 3 genuinely existing PixelLab-derived sprite art frames",
"source_a31_path":str(src),"source_a31_sha":sha(src),
"source_column_to_output":[1,0,2],"source_phase_1_equals_3":delta(c[1],c[3])==0,
"stored_frames":3,"source_sheet_size":[160,40],"output_sheet_size":[120,40],"each_frame":[40,40],
"output_sha":sha(out),"loop_sequence":[0,1,0,2],"gif_loop_enabled":True,
"individual_frames":[bbox(x) for x in selected],
"changed_pixels_neutral_to_left":delta(selected[0],selected[1]),
"changed_pixels_neutral_to_right":delta(selected[0],selected[2]),
"changed_pixels_left_to_right":delta(selected[1],selected[2]),
"extra_pixels_hand_painted":0,
"new_pixelLab_api_calls":0,
"visual_art_gate":"Candidate source based on A31 approved motion, user has NOT separately approved A43 running speed or 45° camera",
"sbs_worldspace":"SBS movement should control travel; runtime NOT EXECUTED",
"strict_3_frame_gate":"PASS","semantic_run_cycle":"SOURCE LEGS ALTERNATE YES; gif [0,1,0,2] ACTUAL GENERATED",
"formal_integration_pass":False,
"original_files_unchanged":True,"A37_dodging_T4_unchanged":True,"A42_fail_preserved":True}
(R/"A43_RUN_LOOP_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("A43_REAL_RUN_LOOP_COMPLETE",json.dumps({"gif_frames":Image.open(gif).n_frames,"loop":Image.open(gif).info.get("loop"),
"sha":sha(out),"bbox":qa["individual_frames"],
"pixelchanges":[qa["changed_pixels_neutral_to_left"],qa["changed_pixels_neutral_to_right"],qa["changed_pixels_left_to_right"]]},ensure_ascii=False),flush=True)
