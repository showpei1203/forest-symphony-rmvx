#!/usr/bin/env python3
"""Forest Symphony T-A R19: five independently drawn 45-degree boxing key poses.
ART CANDIDATE ONLY; preserve approved A62 actual source face/hair pixels.
No rotated LPC walk limbs, no interpolated skeleton bars, no 12-frame production claim.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,zipfile
ROOT=Path(r"E:\LPC_Original_20261121")
SOURCE=ROOT/"FS_ACTOR01_A62_APPROVED_REFERENCE_64.png"
SOURCE_SHA="70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"
OUT=ROOT/"FS_R19_ACTOR01_FIVE_HAND_PAINTED_BOXING_KEYS"
OUT.mkdir(parents=True,exist_ok=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(SOURCE)==SOURCE_SHA
ref=Image.open(SOURCE).convert("RGBA")
assert ref.size==(64,64)
# Pixel palette is selected from the approved A62 identity; do NOT synthesize a new outfit.
K=(6,8,11,255)      # black-violet outline
D=(20,44,43,255)    # jacket deep forest
G=(25,60,53,255)    # original forest fabric
H=(46,74,65,255)    # jacket highlight
G2=(25,67,67,255)   # edge teal
P=(69,65,57,255)    # pants muted grey/brown
PD=(46,41,38,255)   # pants shadow
PL=(122,117,106,255)
B=(89,70,56,255)    # shoe
BL=(125,95,72,255)  # shoe light
W=(155,152,146,255) # fabric seam
S=(234,201,158,255) # skin bright
SM=(196,151,114,255)
SS=(125,95,72,255)
BUCK=(147,145,138,255)
# Each silhouette is a separately authored collection of pixel-clusters.
# Keys: guard(F0), loaded coil(F3), forward drive(F5), clenched impact(F7), recoil(F9).
# Coordinates below are not scaled skeletons or lerp: each torso, cuff, hand,
# knee and boot is placed explicitly in native 64x64 pixels.
POSES=[
 dict(key="F0_GUARD", head=(0,0),
  rear_thigh=[(28,40),(34,40),(35,45),(32,47),(30,49),(26,48),(25,44)],
  front_thigh=[(34,41),(40,41),(42,44),(42,48),(38,49),(34,48),(33,45)],
  rear_shade=[(27,44),(31,44),(30,47),(27,48)],
  front_shade=[(36,43),(39,42),(40,46),(38,48)],
  rear_boot=[(26,47),(31,47),(32,50),(30,51),(24,51),(24,49)],
  front_boot=[(37,47),(42,47),(44,49),(44,51),(36,51),(35,49)],
  back_sleeve=[(28,33),(31,33),(30,36),(29,39),(25,40),(24,37),(25,35)],
  back_hand=[(27,30),(30,30),(32,31),(32,34),(29,35),(27,34)],
  tunic=[(29,32),(35,32),(40,33),(42,37),(41,43),(36,44),(29,43),(26,40),(27,35)],
  tunic_light=[(33,34),(37,34),(40,37),(39,40),(36,41),(33,39)],
  collar=[(29,32),(33,32),(33,35),(30,35)],
  tail=[(29,41),(33,43),(30,46),(26,44)],
  near_upper=[(38,33),(42,34),(44,37),(42,40),(39,40),(37,37)],
  near_lower=[(42,38),(42,35),(41,33),(39,32),(37,33),(38,35),(39,38)],
  near_cuff=[(38,35),(41,34),(41,36),(39,37)],
  near_fist=[(37,30),(40,29),(42,30),(42,34),(40,35),(37,34)],
  rear_crease=[(28,46),(30,47)], front_crease=[(39,44),(40,47)],
  belt=[(30,41),(39,41)], head_note="same approved A62 head, front guard raised"),
 dict(key="F3_COIL",head=(-2,1),
  rear_thigh=[(27,41),(33,41),(34,45),(31,48),(29,51),(24,51),(24,47)],
  front_thigh=[(32,41),(39,41),(41,46),(39,50),(35,51),(33,49),(30,46)],
  rear_shade=[(25,46),(29,46),(29,50),(24,50)],
  front_shade=[(34,44),(38,44),(38,48),(36,49)],
  rear_boot=[(24,49),(29,49),(31,52),(29,53),(21,53),(22,51)],
  front_boot=[(35,49),(40,49),(42,52),(41,53),(33,53),(33,51)],
  back_sleeve=[(25,34),(29,33),(29,36),(26,40),(23,39),(22,36)],
  back_hand=[(25,31),(28,30),(30,31),(30,34),(27,35),(25,34)],
  tunic=[(26,33),(34,32),(38,35),(40,39),(39,44),(34,45),(27,44),(23,40),(24,36)],
  tunic_light=[(29,34),(32,33),(36,36),(37,39),(34,41),(30,40)],
  collar=[(27,32),(30,33),(30,36),(27,36)],
  tail=[(27,42),(31,44),(28,48),(24,45)],
  near_upper=[(36,34),(40,36),(41,40),(39,43),(36,43),(34,39)],
  near_lower=[(38,41),(35,41),(33,40),(31,38),(33,36),(36,37)],
  near_cuff=[(31,38),(34,37),(35,40),(33,41)],
  near_fist=[(29,36),(32,35),(34,36),(34,40),(32,41),(29,40)],
  rear_crease=[(27,46),(29,49)], front_crease=[(36,44),(38,47)],
  belt=[(27,42),(37,42)], head_note="coiled chest and deep back-knee load"),
 dict(key="F5_DRIVE",head=(-1,0),
  rear_thigh=[(29,42),(35,41),(36,45),(33,48),(30,50),(25,49),(26,45)],
  front_thigh=[(35,42),(41,40),(44,44),(44,47),(40,50),(35,49),(34,45)],
  rear_shade=[(26,45),(29,46),(29,49),(25,49)],
  front_shade=[(38,44),(42,43),(43,47),(40,49)],
  rear_boot=[(25,48),(31,48),(33,51),(31,52),(23,52),(23,50)],
  front_boot=[(39,48),(45,47),(47,49),(47,51),(39,52),(38,50)],
  back_sleeve=[(27,33),(31,33),(33,36),(30,40),(26,40),(25,37)],
  back_hand=[(28,30),(31,30),(33,31),(33,34),(30,35),(28,34)],
  tunic=[(29,32),(37,31),(43,34),(44,38),(42,43),(37,45),(30,44),(27,40),(27,35)],
  tunic_light=[(34,33),(39,33),(42,36),(41,40),(36,42),(33,39)],
  collar=[(29,32),(33,32),(34,35),(30,36)],
  tail=[(30,43),(35,44),(32,48),(28,46)],
  near_upper=[(41,33),(45,34),(47,37),(45,40),(42,40),(40,37)],
  near_lower=[(46,36),(49,35),(50,36),(49,39),(46,40),(44,38)],
  near_cuff=[(48,35),(50,35),(50,39),(48,40)],
  near_fist=[(50,34),(53,34),(55,36),(54,39),(51,40),(49,38)],
  rear_crease=[(28,46),(30,49)], front_crease=[(41,43),(42,47)],
  belt=[(31,42),(41,41)], head_note="hip fires first, near arm angled forward, far hand guarding"),
 dict(key="F7_IMPACT",head=(0,-1),
  rear_thigh=[(31,42),(36,41),(37,44),(32,47),(28,49),(24,48),(25,45)],
  front_thigh=[(36,41),(43,40),(47,43),(48,46),(44,49),(39,48),(36,45)],
  rear_shade=[(25,44),(30,44),(29,48),(24,48)],
  front_shade=[(40,43),(44,42),(46,46),(43,48)],
  rear_boot=[(23,47),(29,47),(30,50),(27,51),(20,51),(21,49)],
  front_boot=[(43,47),(49,46),(51,48),(51,50),(42,51),(41,49)],
  back_sleeve=[(30,32),(34,32),(35,35),(32,38),(29,38),(27,35)],
  back_hand=[(29,29),(32,29),(34,30),(34,34),(31,35),(29,33)],
  tunic=[(32,32),(39,31),(45,33),(47,36),(46,42),(41,45),(34,44),(30,40),(30,35)],
  tunic_light=[(39,33),(43,33),(46,36),(44,39),(40,41),(36,39)],
  collar=[(32,32),(35,32),(36,35),(32,35)],
  tail=[(33,42),(38,44),(34,47),(29,45)],
  near_upper=[(43,32),(47,32),(49,34),(49,37),(46,39),(43,36)],
  near_lower=[(48,33),(52,31),(54,32),(54,35),(51,37),(48,36)],
  near_cuff=[(52,31),(54,31),(55,35),(52,36)],
  near_fist=[(54,30),(57,29),(59,30),(59,34),(57,35),(54,34)],
  rear_crease=[(28,45),(26,48)], front_crease=[(43,43),(46,45)],
  belt=[(34,42),(44,41)], head_note="extended fist, shoulder drives through, far fist remains tight"),
 dict(key="F9_RECOVER",head=(0,0),
  rear_thigh=[(28,41),(34,41),(34,45),(31,48),(28,50),(25,48),(25,44)],
  front_thigh=[(34,41),(40,40),(43,44),(43,48),(39,50),(35,48),(33,45)],
  rear_shade=[(26,45),(30,45),(29,49),(25,48)],
  front_shade=[(37,43),(40,42),(42,46),(39,48)],
  rear_boot=[(25,48),(31,48),(33,51),(30,52),(23,52),(23,50)],
  front_boot=[(38,48),(44,47),(46,49),(45,51),(37,52),(36,50)],
  back_sleeve=[(28,33),(31,33),(31,36),(29,39),(25,40),(24,37)],
  back_hand=[(27,30),(30,30),(32,31),(32,34),(29,35),(27,34)],
  tunic=[(29,32),(36,32),(41,34),(42,38),(41,43),(36,44),(29,43),(26,40),(27,35)],
  tunic_light=[(33,34),(38,34),(40,37),(39,41),(35,41),(31,39)],
  collar=[(29,32),(32,32),(33,35),(29,35)],
  tail=[(29,42),(33,43),(30,47),(26,44)],
  near_upper=[(39,33),(43,34),(44,38),(42,41),(39,40),(37,37)],
  near_lower=[(43,39),(42,36),(40,35),(38,35),(38,38),(40,40)],
  near_cuff=[(38,35),(41,35),(42,38),(39,39)],
  near_fist=[(37,32),(40,31),(42,33),(42,36),(39,37),(37,35)],
  rear_crease=[(28,46),(29,48)], front_crease=[(40,43),(41,47)],
  belt=[(30,41),(39,41)], head_note="fist back to face, feet recover")]
# Source-accurate hair+face (and ONLY upper head): exact A62 pixels, optional whole-head translation.
HEAD=ref.crop((17,15,47,35))
def solid_polygon(draw, pts, fill, border=K):
    draw.polygon(pts,fill=fill)
    draw.line(pts+[pts[0]],fill=border,width=1)
def detail(draw,p):
    x,y=p
    draw.point((x,y),fill=PL)
def clenched_fist(draw,outline,impact=False):
    # Polygon border defines a closed knuckle cluster with separately shaded thumb.
    solid_polygon(draw,outline,SM)
    x0=min(x for x,y in outline);x1=max(x for x,y in outline)
    y0=min(y for x,y in outline);y1=max(y for x,y in outline)
    draw.line((x0+2,y0+1,x1-1,y0+1),fill=S,width=1)
    draw.point((x0+1,y1-1),fill=SS)
    if impact:
        draw.line((x1-1,y0+2,x1-1,y1-2),fill=SS,width=1)
        draw.point((x1-2,y0+1),fill=S)
    else:
        draw.point((x1-1,y1-1),fill=SS)
def render(p):
    canvas=Image.new("RGBA",(64,64))
    d=ImageDraw.Draw(canvas)
    # Far leg and pivoting boots: distinct original-style brown pixel clusters
    solid_polygon(d,p["rear_thigh"],P,PD)
    solid_polygon(d,p["rear_shade"],PD,PD)
    solid_polygon(d,p["rear_boot"],B,K)
    rb=p["rear_boot"]
    d.line((rb[0][0]+2,rb[0][1]+2,rb[1][0]-1,rb[0][1]+2),fill=BL)
    # Near leg volume, knee, ankle and rolling boot heel
    solid_polygon(d,p["front_thigh"],P,PD)
    solid_polygon(d,p["front_shade"],PD,PD)
    solid_polygon(d,p["front_boot"],B,K)
    fb=p["front_boot"]
    d.line((fb[0][0]+1,fb[0][1]+2,fb[1][0]-1,fb[0][1]+2),fill=BL)
    # Far forearm bends in tight guard, always behind chest and head.
    solid_polygon(d,p["back_sleeve"],D)
    clenched_fist(d,p["back_hand"])
    # Whole torso as tailored, shifted pixel silhouette, never a rotated old WALK frame
    solid_polygon(d,p["tunic"],G)
    solid_polygon(d,p["tunic_light"],H,G)
    solid_polygon(d,p["collar"],D,D)
    solid_polygon(d,p["tail"],D,D)
    belt=p["belt"]
    d.line((belt[0][0],belt[0][1],belt[1][0],belt[1][1]),fill=K,width=2)
    xm=(belt[0][0]+belt[1][0])//2;ym=belt[0][1]
    d.point((xm,ym),fill=BUCK)
    # Head reuses SHA-locked approved A62 pixels unchanged, only 1-2 pixel poses.
    dx,dy=p["head"]
    canvas.alpha_composite(HEAD,(17+dx,15+dy))
    d=ImageDraw.Draw(canvas)
    # Separate near-cheek clenched guard fist, drawn over the head's lower-left
    # boundary (never over the eyes or hair crown). It belongs to the far elbow
    # already painted behind the torso, not a floating duplicate limb.
    offhand_dx={"F0_GUARD":-2,"F3_COIL":-1,"F5_DRIVE":-2,"F7_IMPACT":-2,"F9_RECOVER":-2}[p["key"]]
    offhand_dy={"F0_GUARD":2,"F3_COIL":2,"F5_DRIVE":2,"F7_IMPACT":3,"F9_RECOVER":2}[p["key"]]
    offhand=[(x+offhand_dx,y+offhand_dy) for x,y in p["back_hand"]]
    clenched_fist(d,offhand)
    # Manually oriented lapel and chest folds encode the actual torso torque.
    fold={"F0_GUARD":[(32,35),(34,38),(35,40)],
          "F3_COIL":[(27,36),(30,39),(33,42)],
          "F5_DRIVE":[(35,35),(38,37),(40,40)],
          "F7_IMPACT":[(38,35),(41,37),(44,40)],
          "F9_RECOVER":[(32,35),(35,38),(37,40)]}[p["key"]]
    d.line(fold,fill=D,width=1)
    for x,y in fold[1:]: d.point((x-1,y),fill=G2)
    # A separately DRAWN near-side sleeve (not an algorithmic line segment).
    solid_polygon(d,p["near_upper"],G2)
    solid_polygon(d,p["near_lower"],SM,K)
    solid_polygon(d,p["near_cuff"],D,D)
    clenched_fist(d,p["near_fist"],impact=p["key"]=="F7_IMPACT")
    # Physical garment folds and TWO leg creases differ for each individual pose
    d.line(p["rear_crease"],fill=PL,width=1)
    d.line(p["front_crease"],fill=PL,width=1)
    return canvas
frames=[]
for i,p in enumerate(POSES):
    f=render(p)
    f.save(OUT/f"R19_{p['key']}_64.png")
    assert f.getbbox() is not None
    assert all(px[3] in (0,255) for px in f.getdata())
    frames.append(f)
assert len({f.tobytes() for f in frames})==5
sheet=Image.new("RGBA",(320,64))
for i,f in enumerate(frames):sheet.alpha_composite(f,(64*i,0))
sheet_path=OUT/"R19_FIVE_KEYPOSES_320x64.png"
sheet.save(sheet_path)
for sc in (1,4,8):
    sz=64*sc
    bg=Image.new("RGBA",(5*sz,sz+22),(26,30,34,255))
    d=ImageDraw.Draw(bg)
    for i,f in enumerate(frames):
        bg.alpha_composite(f.resize((sz,sz),Image.Resampling.NEAREST),(i*sz,22))
        d.text((i*sz+3,3),POSES[i]["key"].replace("_"," "),fill=(240,240,235))
    bg.convert("RGB").save(OUT/f"R19_FIVE_KEYPOSES_CONTACT_{sc}X.png")
gif=[]
for i in [0,1,2,3,3,4,0]:
    im=Image.new("RGBA",(256,256),(26,30,34,255))
    im.alpha_composite(frames[i].resize((256,256),Image.Resampling.NEAREST))
    gif.append(im.convert("RGB"))
gif[0].save(OUT/"R19_FIVE_KEYPOSES_BLOCKING_PREVIEW.gif",save_all=True,append_images=gif[1:],duration=[220,170,125,220,180,150,250],loop=0,optimize=False)
manifest={
"version":"T-A-R19-FIVE-KEY-ART-CANDIDATE","status":"ART_GATE_PENDING_1X_OWNER_APPROVAL",
"source_A62_sha256":sha(SOURCE),"source_head":"A62 x17..46 y15..34 unchanged pixels, offsets <=2px",
"art_authorship":"five individually coordinate-authored original 64px silhouettes; NO rotated WALK source/rig interpolations",
"keys":[{"name":p["key"],"sha256":sha(OUT/f"R19_{p['key']}_64.png"),"intent":p["head_note"]} for p in POSES],
"sheet_size":[320,64],"sheet_sha256":sha(sheet_path),"characters":5,
"weapon_fx":"not produced: keypose art gate only","godot_qa":"NOT_RUN: artwork first",
"full_FSBattle":"NOT_RUN","original_eight_direction_attack":"NOT_FOUND, original LPC 8dir WALK references only",
"banned":"R16/R17/R18 procedural limb rotation or narrow geometry fixes","do_not_promote":True}
(OUT/"R19_ART_GATE_MANIFEST.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
print("R19_FIVE_KEYS_GENERATED",json.dumps({"sheet_sha":sha(sheet_path),"keys":len(frames),"status":manifest["status"]},ensure_ascii=False))
