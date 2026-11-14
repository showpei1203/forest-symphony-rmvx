"""A40 Actor01 punch-strike keyframe factory; approved A62 pixels, nearest-neighbor edits.
Only reads A39 64px source. Writes to owner-only Drive A40 folder.
Never touches RMVX source, A35 RUN, A62 approved PNG or public GitHub binary art.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, json

ROOT=Path(__file__).resolve().parent.parent
SOURCE=ROOT/'assets'/'actor01_a62_approved_idle_source_64.png'
OUTPUT=ROOT/'assets'/'actor01_attack_lunge_8frames.png'
CONTACT=ROOT/'qa'/'A40_ATTACK_KEYPOSE_CONTACT_8X.png'
src=Image.open(SOURCE).convert('RGBA')
assert src.size==(64,64)
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()=='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
# Eight animation phases, hit at phase 4. Offset palm, not the head or face.
# Do not fabricate new head/feet; the original color palette is reused.
OFFSETS=((0,0),(-1,1),(-1,-1),(2,-3),(8,-5),(7,0),(2,0),(0,0))
BODY_LEAN=(0,0,0,1,2,1,0,0)
FRAMES=[]
base_palette=set(src.getdata())
def sample(x,y):
    return src.getpixel((x,y))
# Reuse only original greens, outlines, gauntlet gold, never introduce fuzzy interpolation.
DARK=sample(40,39)
SLEEVE=sample(40,41)
EDGE=sample(42,42)
GLOVE=sample(41,45)
# Front-arm region segmented with a fixed polygon: head/face and both boots are outside it.
arm_mask=Image.new('L',(64,64),0)
ImageDraw.Draw(arm_mask).polygon([(39,38),(43,38),(44,45),(42,46),(38,46),(37,42)],fill=255)
arm=Image.new('RGBA',(64,64),(0,0,0,0))
arm.paste(src,(0,0),arm_mask)
# The source body remains immutable in unmasked regions. 
# During windup / contact restore a clean shoulder by borrowing the same source colors.
for i,(dx,dy) in enumerate(OFFSETS):
    if i in (0,7):
        FRAMES.append(src.copy())
        continue
    frame=src.copy()
    draw=ImageDraw.Draw(frame)
    # Clear old front arm pixels ONLY, preserving hair/head/left arm/boots and whole original palette.
    for y in range(38,47):
        for x in range(37,45):
            if arm_mask.getpixel((x,y)) and src.getpixel((x,y))[3]:
                frame.putpixel((x,y),(0,0,0,0))
    draw=ImageDraw.Draw(frame)
    # Front shoulder -> elbow connection, native chunky pixels (outline + sleeve).
    sx,sy=39,39
    ex,ey=40+dx//2,41+dy//2
    wrist=(41+dx,43+dy)
    draw.line([(sx,sy),(ex,ey),wrist],fill=sample(38,42),width=5,joint='curve')
    draw.line([(sx,sy),(ex,ey),wrist],fill=sample(40,42),width=3,joint='curve')
    # Approved gauntlet color from the original hand image, shifted in x/y only.
    px=Image.new('RGBA',(64,64),(0,0,0,0))
    px.paste(arm,(dx,dy),arm)
    frame.alpha_composite(px)
    # Native contact glint, already-existing source gold/white colors, no new palette.
    if i==4:
        effect=ImageDraw.Draw(frame)
        gold=sample(39,45)
        white=sample(36,24)
        effect.line([(49,32),(53,30),(55,27)],fill=white,width=1)
        effect.point((54,32),fill=gold)
    if i==5:
        draw=ImageDraw.Draw(frame)
        draw.point((50,37),fill=sample(36,24))
    # Immutable foot/contact rows: keep the original native boot pixels exactly.
    for fy in range(47,64):
        for fx in range(64):
            frame.putpixel((fx,fy),src.getpixel((fx,fy)))
    FRAMES.append(frame)
assert len(FRAMES)==8 and FRAMES[0].tobytes()==src.tobytes() and FRAMES[7].tobytes()==src.tobytes()
# Only A62 source colors plus transparent pixels may appear. Original face is unchanged.
source_colors=set(src.getdata())
for i,frame in enumerate(FRAMES):
    assert frame.getpixel((32,25))==src.getpixel((32,25))
    for y in range(15,34):
        for x in range(22,44):
            assert frame.getpixel((x,y))==src.getpixel((x,y)), (i,x,y,'head changed')
    for y in range(47,50):
        for x in range(22,44):
            assert frame.getpixel((x,y))==src.getpixel((x,y)),(i,x,y,'foot changed')
    new_colors=set(frame.getdata())-source_colors-{(0,0,0,0)}
    assert not new_colors,(i,new_colors)
sheet=Image.new('RGBA',(256,128),(0,0,0,0))
for i,f in enumerate(FRAMES):
    sheet.alpha_composite(f,((i%4)*64,(i//4)*64))
sheet.save(OUTPUT)
scale=8
thumbs=Image.new('RGB',(4*64*scale,2*64*scale),(39,51,60))
for i,f in enumerate(FRAMES):
    tile=Image.new('RGBA',(64,64),(39,51,60,255))
    tile.alpha_composite(f)
    thumbs.paste(tile.convert('RGB').resize((64*scale,64*scale),Image.Resampling.NEAREST),((i%4)*64*scale,(i//4)*64*scale))
thumbs.save(CONTACT)
meta={'stage':'A40','source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'attack_sheet_sha256':hashlib.sha256(OUTPUT.read_bytes()).hexdigest(),'frames':8,'frame_size':[64,64],'atlas_size':[256,128],'fps':10.0,'hit_second':0.44,'duration_seconds':0.8,'phase':['ready','brace','draw','windup','contact','followthrough','recover','settle'],'art_status':'HOLD until review; no original sprite replaced'}
(ROOT/'qa'/'A40_ATTACK_KEYPOSE_MANIFEST.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf-8')
print('A40_GENERATION_OK', json.dumps(meta,ensure_ascii=False))