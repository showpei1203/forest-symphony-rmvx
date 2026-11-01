"""A38 actual frame-only QA, no generated artwork.
Pair real PixelLab DAMAGE F1 with exact genuine battle-view F0 and F2.
Exactly 3 sprite cells; preserve existing T4 Dodging unchanged.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import hashlib,json
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A38_DAMAGE_F1_NATIVE_45_IMAGE_EDIT_20261101"
A37=B/"A37_FS_T4_DODGE_AND_DAMAGE_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
S=R/"A38_AUTHORITY_NATIVE_BATTLE_45_UNARMED_F0.png"
F1=R/"A38_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png"
if not F1.exists():
 print("PIXELLAB_PENDING");raise SystemExit(2)
orig=Image.open(S).convert("RGBA")
hit=Image.open(F1).convert("RGBA")
old=Image.open(A37/"DAMAGE_C_STRONG_HIT"/"PIXELLAB_DAMAGE_C_REAL_F1.png").convert("RGBA")
b_old=Image.open(A37/"DAMAGE_B_NATIVE_FACING"/"PIXELLAB_REAL_DAMAGE_F1.png").convert("RGBA")
assert orig.size==hit.size==old.size==b_old.size==(40,40)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def diff(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def info(x):
 bbox=x.getbbox()
 return {"bbox":bbox,"alpha":sum(v[3]>0 for v in x.getdata()),
 "touch_right":sum(x.getpixel((39,y))[3]>0 for y in range(40)),
 "touch_bottom":sum(x.getpixel((i,39))[3]>0 for i in range(40))}
frames=[orig,hit,orig]
sheet=Image.new("RGBA",(120,40))
for i,im in enumerate(frames):sheet.alpha_composite(im,(40*i,0))
dest=R/"A38_DAMAGE_NATIVE_VIEW_3FRAME_CANDIDATE_120x40.png";sheet.save(dest)
hit.save(R/"A38_DAMAGE_HIT_F1_ONE_PROVIDER_FRAME_COPY.png")
frames[0].save(R/"A38_DAMAGE_EXACT_THREE_FRAME_ONESHOT.gif",save_all=True,append_images=frames[1:],
 duration=[150,260,400],disposal=2,optimize=False)
gif=Image.open(R/"A38_DAMAGE_EXACT_THREE_FRAME_ONESHOT.gif")
assert gif.n_frames==3 and gif.info.get("loop") is None,(gif.n_frames,gif.info)
try:fnt=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",19)
except:fnt=ImageFont.load_default()
board=Image.new("RGB",(3*302,2*327),(239,242,245))
d=ImageDraw.Draw(board)
# Compare side-view previous B and C + new image-edited native view
comparison=[
 ("A37 B: WEAK",b_old),
 ("A37 C: 90-DEG FAIL",old),
 ("A38 F1: NATIVE-EDIT",hit),
 ("A38 F0: NATIVE",orig),
 ("A38 F1: DAMAGE",hit),
 ("A38 F2: NATIVE",orig)]
for n,(label,im) in enumerate(comparison):
 x=(n%3)*302;y=(n//3)*327
 b=Image.new("RGBA",(40,40),(239,242,245,255));b.alpha_composite(im)
 board.paste(b.convert("RGB").resize((285,285),Image.Resampling.NEAREST),(x+8,y+28))
 d.text((x+8,y+6),label,font=fnt,fill=(21,38,55))
board.save(R/"A38_A37_FAIL_VS_NATIVE_F1_DAMAGE_CONTACT.png",optimize=True)
qa={
"stage":"A38","date":"2026-11-01",
"method":"PixelLab true /edit-images-v2 from native battle-facing 40px art, then exact F0+F1+F2 assembly",
"source_f0_sha":sha(S),"provider_f1_sha":sha(F1),"final_sheet_sha":sha(dest),
"native40x40":[info(x) for x in frames],
"all_frames_exactly_three":True,
"all_120x40_transparent":True,
"source_battle_F0_and_F2_pixel_identical":diff(frames[0],frames[2])==0,
"new_F1_changed_vs_guard":diff(orig,hit),
"new_F1_changed_vs_old_A37_C":diff(hit,old),
"one_shot_gif_framecount":gif.n_frames,
"art_camera_gate":"NEEDS HUMAN INSPECTION (F1 frontal + side planes, shoulders/hips, no 90deg)",
"hit_recoil_semantics":"NEEDS HUMAN INSPECTION",
"weaponless_SBS":"NEEDS HUMAN INSPECTION",
"formal_approval":"CANDIDATE ONLY",
"game_project_unchanged":True}
(R/"A38_DAMAGE_F1_AND_THREEFRAME_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(qa,ensure_ascii=False),flush=True)
print("PREVIEW_BYTES",(R/"A38_A37_FAIL_VS_NATIVE_F1_DAMAGE_CONTACT.png").stat().st_size)
