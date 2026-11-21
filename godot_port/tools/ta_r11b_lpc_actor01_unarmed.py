#!/usr/bin/env python3
"""R11B first complete LPC-authentic weaponless 3/4 Actor01 12-frame candidate.
WARNING ART HOLD: official LPC has cardinal poses only; 3/4 uses pixel selection
from front+right, not a genuine original 45-degree frame or human painted finish.
No weapons, no guide markers, no elastic-arm raster distortion.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,math
ROOT=Path(r"E:\LPC_Original_20261121")
SHA="86a3719ee4a7e2e9fb27c7c152e29a741d3e930a"
SRC=ROOT/("Universal-LPC-Spritesheet-Character-Generator-"+SHA)/"spritesheets"
OWNER=ROOT/"FS_ACTOR01_A62_APPROVED_REFERENCE_64.png"
OUT=ROOT/"FS_R11B_ACTOR01_UNARMED_45_STUDY"
OUT.mkdir(exist_ok=True)
def digest(path):
    h=hashlib.sha256()
    with open(path,"rb") as f:
        for b in iter(lambda:f.read(1<<20),b""):h.update(b)
    return h.hexdigest()
assert digest(OWNER)=="70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"
approved=Image.open(OWNER).convert("RGBA")
assert approved.size==(64,64)
names={
 "skin":"body/bodies/male",
 "tunic":"torso/clothes/longsleeve/longsleeve/male",
 "trousers":"legs/pants/male",
 "boots":"feet/boots/basic/male"
}
colors={
 "tunic":[(10,24,24),(17,41,39),(25,58,52),(49,75,62),(82,98,75)],
 "trousers":[(8,13,15),(20,26,29),(35,41,40),(54,59,54),(75,79,65)],
 "boots":[(9,10,10),(27,23,19),(52,42,33),(82,65,45),(116,95,67)]
}
action="backslash"
sheets={}
hashes={}
for key,relative in names.items():
    file=SRC/relative/(action+".png")
    assert file.is_file(),str(file)
    sheets[key]=Image.open(file).convert("RGBA")
    assert sheets[key].size==(832,256),f"Invalid grid {file}"
    hashes[key]={"relative":str(file.relative_to(SRC)).replace("\\","/"),"sha256":digest(file)}
def recolor(img,palette):
    pix=list(img.getdata())
    values=[.2126*r+.7152*g+.0722*b for r,g,b,a in pix if a>0]
    if not values:return img
    lo,hi=min(values),max(values)
    mapped=[]
    for r,g,b,a in pix:
        if a==0:mapped.append((0,0,0,0));continue
        l=.2126*r+.7152*g+.0722*b
        k=min(len(palette)-1,max(0,round((l-lo)/max(1,hi-lo)*(len(palette)-1))))
        rgb=palette[k];mapped.append((*rgb,a))
    out=Image.new("RGBA",img.size);out.putdata(mapped);return out
def original_direction_pose(column,row):
    frame=Image.new("RGBA",(64,64))
    for name in ("skin","tunic","trousers","boots"):
        layer=sheets[name].crop((column*64,row*64,column*64+64,row*64+64))
        if name in colors:layer=recolor(layer,colors[name])
        shifted=Image.new("RGBA",(64,64))
        shifted.alpha_composite(layer,(0,-12))
        frame=Image.alpha_composite(frame,shifted)
    return frame
def threequarter(front,right):
    """Composite full original pixel anatomy: front chest/near leg, right-side far arm.
    Use original complete source pixels ONLY; never draw a synthetic arm/connector.
    Pixel selection, not stretching/rotating/resampling source limbs.
    """
    out=right.copy()
    f=front.load();r=right.load();dst=out.load()
    for y in range(14,56):
        for x in range(14,58):
            near_chest=(18<=y<=38 and 21<=x<=33)
            near_thigh=(38<y<=55 and 21<=x<=31)
            if (near_chest or near_thigh) and f[x,y][3]>0:
                dst[x,y]=f[x,y]
            # Right arm always retains original side slash pixels.
    return out
# Backslash original is 13-key continuous source attack.
# F0 & F11 match original neutral recovery. F7 original contact follow-through.
pose=[12,0,1,2,3,6,7,9,10,11,12,12]
names12=["idle","anticipation","step","coil","guard","release","accelerate","contact","followthrough","recovery","settle","idle"]
head_x=[0,0,0,1,1,0,-1,-1,0,0,0,0]
head_y=[0,0,-1,-1,-1,0,1,1,0,0,0,0]

from collections import deque
def remove_tiny_islands(sprite):
    """Only eliminate disconnected <=3px debris; never conceal detached real limbs."""
    pixel=sprite.load()
    remain={(x,y) for y in range(64) for x in range(64) if pixel[x,y][3]>0}
    groups=[]
    while remain:
        start=next(iter(remain))
        remain.remove(start)
        work=deque([start])
        pixels=[start]
        while work:
            x,y=work.popleft()
            for dx in (-1,0,1):
                for dy in (-1,0,1):
                    neighbor=(x+dx,y+dy)
                    if neighbor in remain:
                        remain.remove(neighbor)
                        pixels.append(neighbor)
                        work.append(neighbor)
        groups.append(pixels)
    groups.sort(key=len,reverse=True)
    if len(groups)==0 or len(groups[0])<100:
        raise ValueError("R11B invalid original-body silhouette")
    if any(len(g)>3 for g in groups[1:]):
        raise ValueError("R11B blocked detached real limb; human artwork required")
    erased=0
    for group in groups[1:]:
        for x,y in group:
            pixel[x,y]=(0,0,0,0)
            erased+=1
    return sprite,erased

body_atlas=Image.new("RGBA",(256,192))
frames=[]
removed_counts=[]
for i,col in enumerate(pose):
    frontal=original_direction_pose(col,2)
    side=original_direction_pose(col,3)
    body=threequarter(frontal,side)
    # Approved 3/4 white-haired identity, exact native source pixels.
    head=approved.crop((17,15,48,31))
    body.alpha_composite(head,(17+head_x[i],15+head_y[i]))
    body,erased=remove_tiny_islands(body)
    removed_counts.append(erased)
    frames.append(body)
    body_atlas.alpha_composite(body,((i%4)*64,(i//4)*64))
body_file=OUT/"R11B_ACTOR01_UNARMED_BODY_12x64.png"
body_atlas.save(body_file)
empty=Image.new("RGBA",(256,192))
weapon=OUT/"R11B_WEAPON_EMPTY_ZERO_ALPHA.png"
fx=OUT/"R11B_FX_EMPTY_ZERO_ALPHA.png"
empty.save(weapon);empty.save(fx)
assert all(p[3]==0 for p in empty.getdata())
assert list(frames[0].getdata())==list(frames[11].getdata()),"loop seam not exact"
alpha_counts=[sum(px[3]>0 for px in im.getdata()) for im in frames]
assert all(v>100 for v in alpha_counts)
unique={digest(body_file)}
# Source frames are not all distinct (native holds). Full-body source has 13 cells.
contact=Image.new("RGBA",(256*12,286),(22,27,32,255))
d=ImageDraw.Draw(contact)
for i,frame in enumerate(frames):
    contact.alpha_composite(frame.resize((256,256),Image.Resampling.NEAREST),(i*256,28))
    d.text((i*256+7,7),f"R11B F{i:02d}  {names12[i]}  LPC:{pose[i]}",fill=(242,245,246))
contact_file=OUT/"R11B_UNARMED_3Q_12KEY_4X.png";contact.convert("RGB").save(contact_file)
gif_frames=[]
for frame in frames:
    tile=Image.new("RGBA",(256,256),(20,25,27,255))
    tile.alpha_composite(frame.resize((256,256),Image.Resampling.NEAREST))
    gif_frames.append(tile.convert("RGB"))
gif_file=OUT/"R11B_UNARMED_3Q_12KEY_LOOP.gif"
gif_frames[0].save(gif_file,save_all=True,append_images=gif_frames[1:],duration=[140,90,80,70,70,70,65,80,90,95,100,160],loop=0,optimize=False)
manifest={
 "project":"FS T-A R11B","status":"ART_HOLD - partial 3/4 composited original LPC not hand-painted 45",
 "official_upstream_commit":SHA,
 "action":"backslash", "source_grids":"4 cardinal directions, 13 source frames each",
 "native_lpc_45_degree_frames":False,"no_weapon":True,"weapon_pixels":0,"fx_pixels":0,
 "A62_approved_sha256":digest(OWNER),
 "source_files":hashes, "source_frame_columns":pose, "source_front_row":2,"source_right_row":3,
 "composite_method":"authentic unwarped LPC source pixels, source-right limbs + source-front near chest and near leg, approved exact A62 face/hair",
 "phase":names12,"frame7_contact_seconds":0.63,"shape": [256,192],"frame": [64,64],
 "output_sha256":{p.name:digest(p) for p in (body_file,weapon,fx)},
 "islands_removed_per_frame":removed_counts,
 "issues":["3/4 composite is SOURCE-BASED REFERENCE, not approved manually painted 45-degree sprite","source F11 held and duplicate native pose, some shoulder seams need human-pixel-art repaint","64px face expression currently unchanged","not a Godot full battle proof"]
}
(OUT/"R11B_MANIFEST_SOURCE_LOCKED.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"R11B_created":str(OUT),"sha_body":digest(body_file),"weapon_pixels":0,"fx_pixels":0,"alpha_range":[min(alpha_counts),max(alpha_counts)],"islands_removed":removed_counts,"src_grid_13":True,"status":"ART_HOLD"},ensure_ascii=False))
