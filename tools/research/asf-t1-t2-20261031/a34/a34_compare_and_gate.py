"""A34 objective no-false-PASS QA. Every frame checked and shown, user F0 gate flagged separately.
Actual PixelLab raw retained. Stable F0 candidate may reuse an authentic PixelLab native-battle master exact,
never manual pixel repaint. No provider source overwritten.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,statistics
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
A33=B/"A33_HUMANOID_DIRECT_POSE_20261101"
OUT=R/"B2_DODGE_NATIVE_VIEW_POSES"
master=Image.open(R/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png").convert("RGBA")
orig=[Image.open(A33/"B_DODGING_DIRECT_POSES"/f"PIXELLAB_B_DODGE_FRAME_{i:02}.png").convert("RGBA") for i in range(3)]
B2=[Image.open(OUT/f"A34_B2_REAL_PROVIDER_{i:02}.png").convert("RGBA") for i in range(3)]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def diff(a,b):return sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
def stats(frames):
 return [{"bbox":x.getbbox(),"alpha":sum(p[3]>0 for p in x.getdata()),
 "right_edge":sum(x.getpixel((39,y))[3]>0 for y in range(40)),
 "bottom_edge":sum(x.getpixel((i,39))[3]>0 for i in range(40))} for x in frames]
# Exact source-view F0/F2 vs provider raw: if the provider face drifts, original master remains explicit.
# This is a reference-locked *assembly*, not a claim that the provider returned these pixels at F0/F2.
assembled=[master.copy(),B2[1],master.copy()]
strip=Image.new("RGBA",(120,40))
for i,im in enumerate(assembled):strip.alpha_composite(im,(40*i,0))
final=R/"A34_NATIVE_F0_EXACT_VIEW_LOCK_CANDIDATE_3FRAMES.png";strip.save(final)
for name,arr in [("A34_B2_PROVIDER_RAW",B2),("A34_VIEW_LOCK_ASSEMBLY",assembled)]:
 fr=arr[0].copy();fr.save(R/(name+"_F0_40.png"))
 fr.save(R/(name+"_ONE_SHOT.gif"),save_all=True,append_images=arr[1:],
 duration=[180,235,550],disposal=2,optimize=False)
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",17)
except:font=ImageFont.load_default()
rows=[
("OLD A33 B: WRONG F0 / RIGHT-FACING",orig),
("NEW A34: RAW PIXELLAB native-view conditioned",B2),
("A34: native F0/F2 frame-exact anchor + real B2 crouch",assembled)
]
page=Image.new("RGB",(1110,3*333),(239,242,245))
d=ImageDraw.Draw(page)
for i,(label,frames) in enumerate(rows):
 y=i*333
 d.rectangle((0,y,1109,y+29),fill=(26,40,56))
 d.text((12,y+5),label,font=font,fill=(250,250,250))
 for j,im in enumerate(frames):
  bg=Image.new("RGBA",(40,40),(239,242,245,255));bg.alpha_composite(im)
  page.paste(bg.convert("RGB").resize((300,300),Image.Resampling.NEAREST),(j*365+15,y+30))
  d.text((j*365+225,y+297),"F"+str(j),font=font,fill=(35,52,68))
page.save(R/"A34_A33_VS_NEW_RAW_VS_F0_LOCK_REVIEW.png",optimize=True)
# Side by side face gate source contrast, with preserved native baseline
angle=Image.new("RGB",(5*245,294),(239,242,245));d=ImageDraw.Draw(angle)
fs=Image.open(R/"A34_NATIVE_ACTOR01_1_ROW2_C1_ORIGINAL_40.png").convert("RGBA")
tiles=[("ORIGINAL FS battle",fs),("A33 BAD F0",orig[0]),("A34 native master",master),("A34 RAW F0",B2[0]),("A34 F1 dodge",B2[1])]
for i,(label,im) in enumerate(tiles):
 bg=Image.new("RGBA",(40,40),(239,242,245,255));bg.alpha_composite(im)
 angle.paste(bg.convert("RGB").resize((235,235),Image.Resampling.NEAREST),(i*245+5,35))
 d.text((i*245+5,7),label,font=font,fill=(30,44,58))
angle.save(R/"A34_FIRST_FRAME_DIRECTION_GATE_REVIEW.png")
metrics={"source":{"native_ref_sha":sha(R/"A34_NATIVE_ACTOR01_1_ROW2_C1_ORIGINAL_40.png"),
 "corrected_new_2frame_native_master_sha":sha(R/"A34_REAL_NATIVE_BATTLE_REFERENCE_MASTERS_2FRAME.png")},
 "old_A33":stats(orig),"new_B2_raw":stats(B2),"candidate_view_locked":stats(assembled),
 "raw_source_first_match_diff":diff(master,B2[0]),
 "F1_crouch_raw_vs_bad_A33_diff":diff(B2[1],orig[1]),
 "assembled_F0_master_identical":diff(assembled[0],master)==0,
 "assembled_F2_master_identical":diff(assembled[2],master)==0,
 "assembled_F0_to_F2_identity":diff(assembled[0],assembled[2]),
 "raw_F0_face_style":"VISUAL REVIEW",
 "first_frame_angle_assessment":"NEW FIRST FRAME follows actual FS battle-view source; differs from OLD A33 side profile. Human artistic 45-degree approval PENDING.",
 "individual_frame_angle_gate":"F0 provisional; F1 provisional; F2 provisional. No formal PASS.",
 "Dodge_action":"F0 ready -> F1 crouch -> F2 ready, source driven. One-shot not a loop",
 "one_shot_gif":"no infinite loop; last frame hold",
 "SBS_overlay":"NOT TESTED",
 "source_edit":"Original pose data preserved; cleaned 44-pixel disconnected prior-row debris in a COPY only",
 "original_game_files_untouched":True}
(R/"A34_FRAME_DIRECTION_AND_ANIMATION_QA.json").write_text(json.dumps(metrics,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({k:metrics[k] for k in ("raw_source_first_match_diff","F1_crouch_raw_vs_bad_A33_diff","assembled_F0_master_identical","assembled_F2_master_identical","new_B2_raw","candidate_view_locked")},ensure_ascii=False))
print("OUTPUTS",[(p.name,p.stat().st_size) for p in [R/"A34_A33_VS_NEW_RAW_VS_F0_LOCK_REVIEW.png",R/"A34_FIRST_FRAME_DIRECTION_GATE_REVIEW.png",final]])
