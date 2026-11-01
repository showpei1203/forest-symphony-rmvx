"""A36 exact 3 frame FS humanoid SBS action standard.
A35 PixelLab real frames are a POSE LIBRARY only. This script does NOT synthesize pixels.
A36 candidate sheets: 3 columns × 40x40, precisely three frames per action.
Walk actual source sheet c0,c1,c2 and timing via engine c0,c1,c2,c1.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023")
A35=B/"A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
A31=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"
R=B/"A36_FS_ACTION_3FRAME_FORMAL_20261101"
R.mkdir(exist_ok=True)
def get(p):
 i=Image.open(p).convert("RGBA")
 assert i.size==(40,40),(p,i.size)
 return i
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
f0=get(A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png")
f1=get(A34/"B2_DODGE_NATIVE_VIEW_POSES"/"A34_B2_REAL_PROVIDER_01.png")
a={i:get(A35/"SEGMENT_A2_GUARD_TO_ROLL"/f"PIXELLAB_INTERPOLATION_RAW_{i:02}.png") for i in range(14)}
b={i:get(A35/"SEGMENT_B_ROLL_TO_GUARD"/f"PIXELLAB_INTERPOLATION_RAW_{i:02}.png") for i in range(14)}
# 4 visual A/B options from actual true source/provider art, 3 frames each
choices={
 "T1_READY_TUCK_RECOVER":[("NATIVE_F0",f0),("PIXELLAB_A04",a[4]),("NATIVE_F2",f0)],
 "T2_READY_MIDROLL_RECOVER":[("NATIVE_F0",f0),("PIXELLAB_A06",a[6]),("NATIVE_F2",f0)],
 "T3_READY_LOW_EVADE_RECOVER":[("NATIVE_F0",f0),("PIXELLAB_B03",b[3]),("NATIVE_F2",f0)],
 "T4_ANTICIPATE_ROLL_LAND":[("PIXELLAB_A02",a[2]),("PIXELLAB_A06",a[6]),("PIXELLAB_B07",b[7])]
}
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",17)
except:font=ImageFont.load_default()
def diff(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
qa={"stage":"A36","rule":"ALL ACTION SPRITES ARE EXACTLY 3 FRAMES, never 18/28",
    "native_size":[40,40],"sprite_sheet_dimensions":[120,40],"candidates":{},
    "actual_provider_source":"A35 /interpolation-v2 real source images + A34 native battle view master",
    "no_manual_redraw":True}
contact=Image.new("RGB",(3*265,4*288),(235,239,243))
d=ImageDraw.Draw(contact)
for row,(name,frames) in enumerate(choices.items()):
 strip=Image.new("RGBA",(120,40))
 for col,(_,im) in enumerate(frames):
  strip.alpha_composite(im,(40*col,0))
  bg=Image.new("RGBA",(40,40),(235,239,243,255));bg.alpha_composite(im)
  contact.paste(bg.convert("RGB").resize((235,235),Image.Resampling.NEAREST),(col*265+7,row*288+29))
  d.text((col*265+10,row*288+267),frames[col][0][:21],fill=(23,36,50),font=font)
 d.text((9,row*288+5),name,font=font,fill=(22,38,51))
 p=R/(name+"_3FRAME_40.png");strip.save(p)
 imgs=[im for label,im in frames]
 imgs[0].save(R/(name+"_3FRAME_ONESHOT.gif"),save_all=True,append_images=imgs[1:],
 duration=[140,230,350],loop=1,disposal=2,optimize=False)
 qa["candidates"][name]={"pose_source_labels":[k for k,_ in frames],"size":list(strip.size),
 "frame_bboxes":[im.getbbox() for _,im in frames],
 "transition_changed_pixels":[diff(imgs[0],imgs[1]),diff(imgs[1],imgs[2])],
 "first_and_last_identical":diff(imgs[0],imgs[2])==0,
 "sha256":sha(p),"angle_camera":"USER REVIEW REQUIRED PER FRAME",
 "art_status":"CANDIDATE NOT PASS"}
contact.save(R/"A36_DODGING_FOUR_3FRAME_VARIANTS_PREVIEW.png",optimize=True)
# walk: original provider A31 source cycle = actual 4 frame [step,neutral,step,neutral];
# copy only unique 3 actions per row, not 4 physical frames.
orig_walk=Image.open(A31/"A31_SE45_NATIVE_4FRAME_CYCLE_CANDIDATE.png").convert("RGBA")
assert orig_walk.size==(160,40)
unique_walk=orig_walk.crop((0,0,120,40))
unique_walk.save(R/"A36_WALK_3FRAME_APPROVED_A31.png")
# Idle static can be represented as exactly 3 duplicate frames, without generating fake shoulder movement.
idle=get(A31/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png")
wait=Image.new("RGBA",(120,40))
for i in range(3):wait.alpha_composite(idle,(40*i,0))
wait.save(R/"A36_WAITING_3FRAME_STATIC_REPEATED.png")
none=Image.new("RGBA",(120,40))
none.save(R/"A36_NOTHING_3FRAME_TRANSPARENT.png")
qa["walk"]={"sheet":"A36_WALK_3FRAME_APPROVED_A31.png","source":"A31 approved 4-phase c0,c1,c2,c1",
"source_c1_eq_c3":orig_walk.crop((40,0,80,40)).tobytes()==orig_walk.crop((120,0,160,40)).tobytes(),
"playback_sequence":[0,1,2,1],"actual_sheet_frames":3,"formal_engine_test":"NOT EXECUTED"}
qa["waiting"]={"sheet":"A36_WAITING_3FRAME_STATIC_REPEATED.png","all_three_identical":True,"no_paid_regeneration":True}
qa["nothing"]={"sheet":"A36_NOTHING_3FRAME_TRANSPARENT.png","blank":True}
(R/"A36_3FRAME_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("THREE_FRAME",json.dumps({k:v["transition_changed_pixels"] for k,v in qa["candidates"].items()},ensure_ascii=False))
print("PREVIEW_BYTES",(R/"A36_DODGING_FOUR_3FRAME_VARIANTS_PREVIEW.png").stat().st_size)
print("WALK c1eqc3",qa["walk"]["source_c1_eq_c3"])
