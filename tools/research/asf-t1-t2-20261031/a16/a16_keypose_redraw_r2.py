"""A16 R2 manual pixel-cluster correction. Original A15 frames remain immutable.
The four 96px RGBA outputs are experimental art edits, never claim G7 pass."""
from PIL import Image,ImageDraw
from pathlib import Path
import numpy as np, json,hashlib,zipfile
SRC=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A15_ART_REPAIR\FINAL_CANDIDATE")
OUT=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_KEYPOSE_REDRAW")
SUF="_A16_KEY_R2.png"
def src(name,num): return Image.open(SRC/name/"frames"/f"attack_{num:02}.png").convert("RGBA")
def pal(im):
    cs=list(set(im.getdata()))
    cs=[p for p in cs if p[3]==255]
    choose=lambda rgb:min(cs,key=lambda p:sum((p[i]-rgb[i])**2 for i in range(3)))
    return {k:choose(v) for k,v in {
      "outline":(52,32,28),"shadow":(88,56,37),"leather":(138,75,41),
      "light":(191,127,74),"skin":(224,163,112),"darkgreen":(53,76,31),
      "green":(82,104,41),"leaf":(155,169,51),
      "fur":(162,126,83),"cream":(233,192,123),"hoof":(113,63,43),
      "hoof_hi":(170,112,59)}.items()}
def push(d,positions,c,main_color):
    # Pixel cluster anatomically constrained: narrower wrist/ankle, broken outline.
    hip,elbow,wrist=positions
    d.line([hip,elbow,wrist],fill=c["outline"],width=5,joint="curve")
    d.line([hip,elbow,wrist],fill=main_color,width=3,joint="curve")
    d.point((elbow[0],elbow[1]-1),fill=c["green"])
    d.line([(elbow[0]-1,elbow[1]+1),(elbow[0]+1,elbow[1]+1)],fill=c["darkgreen"])
def scout(num,elbow,wrist,hand):
    name="T1_forest_scout";base=src(name,num);new=base.copy();d=ImageDraw.Draw(new)
    c=pal(base)
    push(d,[(55,57),elbow,wrist],c,c["green"])
    x,y=hand
    # hand silhouette reauthored at source 1:1; glove doesn't float off hilt
    d.polygon([(x-2,y-2),(x+1,y-3),(x+3,y-1),(x+3,y+2),(x+1,y+3),(x-2,y+1)],fill=c["outline"])
    d.polygon([(x-1,y-1),(x+1,y-2),(x+2,y-1),(x+2,y+1),(x,y+2)],fill=c["leather"])
    d.line([(x,y-1),(x+2,y-1)],fill=c["skin"])
    d.point((x+2,y+1),fill=c["light"])
    # make elbow joint a bent cloth fold rather than a circular rod
    d.line([(elbow[0]-1,elbow[1]-2),(elbow[0]+1,elbow[1]-1)],fill=c["green"])
    d.point((elbow[0]-1,elbow[1]+2),fill=c["shadow"])
    # Original A15 sword and face are preserved; no source frame substitution.
    return base,new
def fiber(d,hip,knee,ankle,hoof,c,tone,near):
    # Manual 3/4 pixel silhouette with two texture clusters and a discrete knuckle.
    w=5 if near else 4
    d.line([hip,knee,ankle],fill=c["outline"],width=w,joint="curve")
    d.line([hip,knee,ankle],fill=tone,width=w-2,joint="curve")
    d.point((hip[0]-1,hip[1]),fill=c["cream"] if near else c["leaf"])
    d.line([(knee[0]-1,knee[1]),(knee[0]+1,knee[1]-1)],fill=c["light"])
    d.point((knee[0]+1,knee[1]+1),fill=c["shadow"])
    x,y=hoof
    # Native hooves are about 3px high: do not draw large boxes like R0.
    d.polygon([(x-2,y-1),(x+1,y-2),(x+3,y),(x+2,y+2),(x-2,y+2),(x-3,y)],fill=c["outline"])
    d.polygon([(x-2,y),(x+1,y-1),(x+2,y),(x+1,y+1),(x-2,y+1)],fill=c["hoof"])
    d.line([(x-2,y),(x,y-1)],fill=c["hoof_hi"])
def creature(num,legs,clear_boxes):
    name="T2_moss_antler";base=src(name,num);new=base.copy();d=ImageDraw.Draw(new);c=pal(base)
    # Remove only obsolete LOWER hoof pixels in 1-3px strips; no belly wipe.
    for box in clear_boxes:
        x0,y0,x1,y1=box
        for y in range(y0,y1+1):
            for x in range(x0,x1+1):
                R,G,B,A=base.getpixel((x,y))
                if A and (R>G*1.06 or (R<94 and G<90)):
                    d.point((x,y),fill=(0,0,0,0))
    # Far hooves behind near; front/near rim uses high-value color sampled from own frame.
    for key in ("front_far","back_far","front_near","back_near"):
        near=key.endswith("near")
        tone=c["cream"] if near else c["fur"]
        fiber(d,*legs[key],c,tone,near)
    return base,new
frames=[
 ("T1_DRAW","T1_forest_scout",2,scout(2,(60,62),(64,60),(66,61))),
 ("T1_STRIKE","T1_forest_scout",5,scout(5,(61,57),(65,64),(67,65))),
 ("T2_FLIGHT","T2_moss_antler",3,creature(3,{
  "front_far":((31,63),(30,65),(32,67),(31,67)),
  "front_near":((40,64),(41,67),(39,68),(39,68)),
  "back_far":((59,63),(62,65),(65,65),(65,66)),
  "back_near":((67,63),(70,65),(72,66),(72,67))
  },[(27,67,38,69),(39,68,47,70),(65,66,76,69)])),
 ("T2_LANDING","T2_moss_antler",5,creature(5,{
  "front_far":((30,66),(30,70),(27,72),(28,73)),
  "front_near":((40,67),(40,72),(37,73),(38,74)),
  "back_far":((59,64),(63,66),(64,69),(64,69)),
  "back_near":((67,64),(69,67),(70,69),(70,70))
  },[(22,72,36,75),(36,73,45,76),(64,70,74,73)]))
]
qa={}
for label,name,num,(base,new) in frames:
    dest=OUT/name/f"attack_{num:02}{SUF}"
    new.save(dest)
    a=np.array(base);b=np.array(new)
    diff=np.any(a!=b,axis=2)
    alpha=a[:,:,3]!=b[:,:,3]
    # source-character authority must be pixel identical in protected head and antlers
    if name.startswith("T1"):
        protection=(slice(10,54),slice(20,54))
    else: protection=(slice(0,55),slice(12,83))
    protected=int(diff[protection].sum())
    assert protected==0, f"fail-closed head/antlers {label} {protected}"
    assert new.size==base.size and a.dtype==np.uint8
    # Compare untouched content away from local articulation area
    bbox=(25,53,76,82) if name.startswith("T1") else (20,60,81,82)
    mask=np.ones(diff.shape,dtype=bool)
    x0,y0,x1,y1=bbox
    mask[y0:y1,x0:x1]=False
    outside=int((diff&mask).sum())
    assert outside==0,f"changed pixels outside allowed anatomy ROI {label} {outside}"
    qa[label]={"width":new.width,"height":new.height,"changed_rgba_pixels":int(diff.sum()),
       "alpha_changes":int(alpha.sum()),"protected_head_drift":protected,
       "outside_anatomy_roi_changes":outside,"sha256":hashlib.sha256(dest.read_bytes()).hexdigest(),
       "G7_ART":"PENDING HUMAN VISUAL","G5_G6_G8":"NOT RUN"}
def review(scale):
    wc=96*scale;rh=123*scale
    sheet=Image.new("RGB",(wc*2,rh*4),(223,224,226));d=ImageDraw.Draw(sheet)
    for row,(label,_,_,(base,new)) in enumerate(frames):
        for col,im in enumerate([base,new]):
            bg=Image.new("RGBA",im.size,(223,224,226,255));bg.alpha_composite(im)
            sheet.paste(bg.convert("RGB").resize((wc,im.height*scale),Image.Resampling.NEAREST),
                        (col*wc,row*rh+26))
            d.text((col*wc+4,row*rh+6),f"{label} / "+("A15" if col==0 else "A16 R2"),fill=(26,27,27))
    sheet.save(OUT/f"A16_R2_COMPARE_{scale}X.png")
for s in (1,3,6): review(s)
(OUT/"A16_R2_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf-8")
(OUT/"A16_R2_HANDOFF.md").write_text("""# A16 R2 Native Pixel-Cluster Local Redraw
Source is **each original A15 frame**, not an incorrectly substituted frame like R1 T1_STRIKE.
Both T1 frames retain all face/head and source sword pixels. Locally repaints shoulder-to-elbow-to-wrist cloth volume, leather fist and grip alignment without imprecise blade duplication.
T2 frames retain head/antlers/body textures and repaint hoof/knee clusters after conservative old-pixel removal in lower ROIs. No rigid affine movement or large cartoon boxes.
QA rejects any changed pixel outside anatomy ROI and any changed protected head/antler pixel.
Visual inspection at 1x/3x mandatory. Export native .aseprite only for EDITABLE working candidate. ASF/Godot only AFTER G7 visual acceptable.
Sealed FS unaffected. ART STATUS: unapproved candidate.
""",encoding="utf-8")
print(json.dumps({k:[v["changed_rgba_pixels"],v["alpha_changes"]] for k,v in qa.items()}))
