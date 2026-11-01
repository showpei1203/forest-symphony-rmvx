from pathlib import Path
from PIL import Image,ImageDraw
R=Path(r"E:\GameAssetToolLab_20261023\A31_FS_ORIGINAL_MOTION_TRANSFER_20261101")
fs=[Image.open(R/f"ORIGINAL_WALK_FRAME_{i:02}_C{c}.png").convert("RGBA") for i,c in enumerate([0,1,2,1])]
bg=(234,239,244,255)
idle=fs[1]
# Original static idle: one real image repeated rather than generating motion.
idle.save(R/"A31_FS_ORIGINAL_STATIC_IDLE_C1.png")
src=Image.new("RGBA",(160,40))
for i,im in enumerate(fs):src.alpha_composite(im,(40*i,0))
src.save(R/"A31_FS_ORIGINAL_TRUE_WALK_4F.png")
fs[0].save(R/"A31_FS_ORIGINAL_TRUE_WALK_4F.gif",save_all=True,append_images=fs[1:],duration=150,loop=0,disposal=2,optimize=False)
frame=lambda im: (lambda o:(o.alpha_composite(im),o)[1])(Image.new("RGBA",(40,40),bg))
panels=[]
for j in range(4):
 p=Image.new("RGB",(800,350),(234,239,244));d=ImageDraw.Draw(p)
 d.text((15,12),"REAL FOREST SYMPHONY $actor01 | 3-POSE WALK + STATIC IDLE",fill=(17,31,47))
 p.paste(frame(idle).convert("RGB").resize((270,270),Image.Resampling.NEAREST),(40,48))
 p.paste(frame(fs[j]).convert("RGB").resize((270,270),Image.Resampling.NEAREST),(450,48))
 d.text((100,320),"Idle: ORIGINAL STATIC C1",fill=(20,40,60))
 d.text((490,320),f"WALK: {'LEFT STEP' if j==0 else 'NEUTRAL' if j in (1,3) else 'RIGHT STEP'}",fill=(20,40,60))
 panels.append(p)
panels[0].save(R/"A31_REAL_NATIVE_IDLE_WALK_REFERENCE.gif",save_all=True,append_images=panels[1:],duration=165,loop=0,optimize=True)
print("SOURCE_PNG/LOOP",src.size,(R/"A31_REAL_NATIVE_IDLE_WALK_REFERENCE.gif").stat().st_size)
