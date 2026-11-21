#!/usr/bin/env python3
"""Forest Symphony R10: weaponless LPC source-posed Actor01 study.
Copyright provenance: upstream mixed-license source, preserve LICENSE/CREDITS.csv.
This is a candidate only. Four source cardinal directions != true 45-degree art.
NO sword, shield, weapon sprite, impact arc, or new symbol. No rubber/warp limbs.
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import hashlib, json
from collections import Counter

COMMIT = "86a3719ee4a7e2e9fb27c7c152e29a741d3e930a"
ROOT = Path(r"E:\LPC_Original_20261121")
UP = ROOT / ("Universal-LPC-Spritesheet-Character-Generator-" + COMMIT)
BASE = UP / "spritesheets"
OUT = ROOT / "FS_R10_ACTOR01_UNARMED_SOURCE_STUDY"
OUT.mkdir(exist_ok=True)
OWNER = ROOT / "FS_ACTOR01_A62_APPROVED_REFERENCE_64.png"
SRC = {
  "skin": BASE / "body/bodies/male/slash.png",
  "tunic": BASE / "torso/clothes/longsleeve/longsleeve/male/slash.png",
  "trousers": BASE / "legs/pants/male/slash.png",
  "boots": BASE / "feet/boots/basic/male/slash.png",
}
def sha256(p):
    h=hashlib.sha256()
    with open(p,'rb') as f:
        for chunk in iter(lambda: f.read(1048576), b''):h.update(chunk)
    return h.hexdigest()
assert sha256(OWNER) == "70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e", "ACTOR01 approved A62 drift"
assert all(p.is_file() for p in SRC.values()), "missing official source"
sheets={name: Image.open(path).convert("RGBA") for name,path in SRC.items()}
assert all(im.size == (384,256) for im in sheets.values()), "unexpected LPC grid"
a62=Image.open(OWNER).convert("RGBA")
assert a62.size == (64,64)

def palette_tint(src, shades):
    # Apply shade groups to *existing source clothing masks*; never warp/bend.
    out=Image.new("RGBA",src.size)
    colors=[(r,g,b,a) for (r,g,b,a) in src.getdata() if a>0]
    if not colors: return out
    lum=[round(.2126*r+.7152*g+.0722*b) for r,g,b,a in colors]
    lo, hi=min(lum),max(lum)
    px=[]
    for r,g,b,a in src.getdata():
        if not a: px.append((0,0,0,0));continue
        l=.2126*r+.7152*g+.0722*b
        index=min(len(shades)-1,max(0,round((l-lo)/(max(1,hi-lo))*(len(shades)-1))))
        cr,cg,cb=shades[index];px.append((cr,cg,cb,a))
    out.putdata(px)
    return out

CLOTH={
 "tunic": [(10,28,28),(18,45,42),(29,61,55),(57,84,69)],
 "trousers":[(10,13,16),(26,32,31),(44,51,48),(75,77,69)],
 "boots":[(7,9,10),(26,25,22),(65,53,45),(114,90,67)],
}
phases=[
 "idle","ready","drawback","load","windup","drive",
 "contact","extension","followthrough","return","settle","idle"
]
# Native LPC /male/slash.png row 3 (right). 6 original source frames;
# twelve timing slots with held real-source poses, never synthesized elastic arms.
columns=[0,0,1,2,3,4,5,5,4,2,1,0]
head_shift_x=[0,0,0,1,1,0,-1,-1,0,0,0,0]
head_shift_y=[0,0,0,-1,-1,-1,0,0,0,0,0,0]

def compose(n,src_frame):
    canvas=Image.new("RGBA",(64,64))
    for name in ["skin","tunic","trousers","boots"]:
        im=sheets[name].crop((src_frame*64,3*64,(src_frame+1)*64,4*64))
        if name in CLOTH: im=palette_tint(im,CLOTH[name])
        layer=Image.new("RGBA",(64,64))
        layer.alpha_composite(im,(0,-12))
        canvas=Image.alpha_composite(canvas,layer)
    # Preserve A62 genuine original face and white hair pixels, not generated new head.
    head=Image.new("RGBA",(64,64))
    head_region=a62.crop((17,15,48,31))
    head.alpha_composite(head_region,(17+head_shift_x[n],15+head_shift_y[n]))
    canvas=Image.alpha_composite(canvas,head)
    return canvas

frames=[compose(i,c) for i,c in enumerate(columns)]
atlas=Image.new("RGBA",(256,192))
for i,frame in enumerate(frames):
    atlas.alpha_composite(frame,((i%4)*64,(i//4)*64))
body_path=OUT/"R10_ACTOR01_UNARMED_BODY_12x64.png"
atlas.save(body_path)
transparent=Image.new("RGBA",(256,192))
weapon_path=OUT/"R10_WEAPON_EMPTY_REQUIRED.png"
fx_path=OUT/"R10_FX_EMPTY_REQUIRED.png"
transparent.save(weapon_path);transparent.save(fx_path)
qa=Image.new("RGBA",(12*64*4, 64*4+50),(24,27,32,255))
d=ImageDraw.Draw(qa)
for i,frame in enumerate(frames):
    qa.alpha_composite(frame.resize((256,256),Image.Resampling.NEAREST),(i*256,35))
    d.text((i*256+4,5),f"F{i:02d} {phases[i]}",fill=(242,242,242,255))
qa_path=OUT/"R10_UNARMED_12POSE_CONTACT_4X.png";qa.save(qa_path)
gif_frames=[]
for frame in frames:
    tile=Image.new("RGBA",(256,256),(20,25,27,255))
    tile.alpha_composite(frame.resize((256,256),Image.Resampling.NEAREST))
    gif_frames.append(tile.convert("RGB"))
gif_path=OUT/"R10_UNARMED_12FRAME_LOOP_4X.gif"
gif_frames[0].save(gif_path,save_all=True,append_images=gif_frames[1:],duration=[110,90,75,75,80,65,90,85,100,110,120,160],loop=0,optimize=False)
manifest={
 "project":"Forest Symphony T-A R10","status":"PROTOTYPE_ART_HOLD","engine":"Godot 4.7.2 target; native GPU test not run yet",
 "upstream":"https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator","commit":COMMIT,
 "native_lpc_directions":"4 cardinal; this is source-right with Actor01 3/4 head, not genuine native 45 degree",
 "source_rule":"exact LPC source frames no limb deformation; A62 approved head+hair copy; 12 timing slots 6 unique source poses",
 "unarmed":True,"weapon_pixels":0,"fx_pixels":0,"shape": [256,192],
 "source_frames":columns,"phase":phases,"a62_original_sha256":sha256(OWNER),
 "sources":{n:{"relative_path":str(p.relative_to(UP)).replace("\\","/"),"sha256":sha256(p)} for n,p in SRC.items()},
 "output_sha256":{x.name:sha256(x) for x in [body_path,weapon_path,fx_path]},
 "art_warnings":["LPC native right side + Actor01 approved 3/4 head is not a newly drawn diagonal 45 attack", "head is identity-preserving overlay not per-frame facial performance","animation uses 6 original poses held in 12 timing slots","do not promote to production before owner visual review"]
}
(OUT/"R10_SOURCE_LOCKED_MANIFEST.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding="utf-8")
print("R10_UNARMED_SOURCE_STUDY_PASS")
print(json.dumps({"dir":str(OUT),"upstream_commit":COMMIT,"frames":12,"unique_native_poses":6,"weapon_pixels":0,"fx_pixels":0,"body_sha":sha256(body_path),"contact":str(qa_path),"gif":str(gif_path)},ensure_ascii=False))
