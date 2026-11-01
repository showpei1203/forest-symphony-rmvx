from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A39_CRITICAL_DAMAGE_NATIVE45_20261101"
A38=B/"A38_DAMAGE_F1_NATIVE_45_IMAGE_EDIT_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
F0=Image.open(A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png").convert("RGBA")
normal=Image.open(A38/"A38_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png").convert("RGBA")
crit=Image.open(R/"A39_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png").convert("RGBA")
assert all(x.size==(40,40) for x in [F0,normal,crit])
def diff(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def metrics(im):
 box=im.getbbox()
 return {"bbox":box,"alpha_coverage":sum(x[3]>0 for x in im.getdata()),
 "right_touch":sum(im.getpixel((39,y))[3]>0 for y in range(40)),
 "bottom_touch":sum(im.getpixel((x,39))[3]>0 for x in range(40))}
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",18)
except:font=ImageFont.load_default()
imgs=[F0,normal,crit,F0,crit,F0]
labels=["AUTHORITY F0","A38 ORDINARY DAMAGE F1","A39 CRITICAL DAMAGE F1","CRITICAL F0","CRITICAL F1","CRITICAL F2"]
panel=Image.new("RGB",(3*305,2*327),(240,242,246));d=ImageDraw.Draw(panel)
for i,(label,im) in enumerate(zip(labels,imgs)):
 x=(i%3)*305;y=(i//3)*327
 bg=Image.new("RGBA",(40,40),(240,242,246,255));bg.alpha_composite(im)
 panel.paste(bg.convert("RGB").resize((285,285),Image.Resampling.NEAREST),(x+8,y+29))
 d.text((x+8,y+5),label,font=font,fill=(21,38,55))
panel.save(R/"A39_NORMAL_VS_CRITICAL_VISUAL_COMPARE.png",optimize=True)
sheet=Image.new("RGBA",(120,40))
for i,im in enumerate([F0,crit,F0]):sheet.alpha_composite(im,(40*i,0))
p=R/"A39_CRITICAL_DAMAGE_3FRAME_120x40.png";sheet.save(p)
F0.save(R/"A39_CRITICAL_DAMAGE_3FRAME_ONE_SHOT.gif",save_all=True,append_images=[crit,F0],
 duration=[160,290,450],disposal=2,optimize=False)
gif=Image.open(R/"A39_CRITICAL_DAMAGE_3FRAME_ONE_SHOT.gif")
assert gif.n_frames==3 and gif.info.get("loop") is None
qa={"stage":"A39","action":"Critic Damaged","source_pixels":"A34 genuine 45-degree FS native-battle master + actual A39 /edit-images-v2 result","frame_count":3,"sheet_size":[120,40],
"F0":metrics(F0),"A38_normal_F1":metrics(normal),"A39_critical_F1":metrics(crit),
"normal_to_critical_pixel_changes":diff(normal,crit),
"ready_to_normal_pixel_changes":diff(F0,normal),
"ready_to_critical_pixel_changes":diff(F0,crit),
"F0_equals_F2":True,"technical_three_frame_pass":True,
"camera_angle":"User art approval pending; reference native 45-derived, critical retains both face planes",
"critically_damaged_semantics":"User art approval pending: must exhibit larger hit recoil than A38 normal Damage",
"SBS_weapon_overlay":"NOT TESTED","formal_art_pass":False,
"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
(R/"A39_CRITICAL_DAMAGE_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(qa,ensure_ascii=False),flush=True)
