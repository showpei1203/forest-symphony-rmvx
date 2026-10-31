"""A16 R1 keypose visual repair. R0 is retained as rejected evidence.
This script intentionally authors replacement silhouette pixels rather than moving old parts."""
from PIL import Image,ImageDraw
from pathlib import Path
import hashlib,json,math,zipfile
SRC=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A15_ART_REPAIR\FINAL_CANDIDATE")
OUT=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_KEYPOSE_REDRAW")
H=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def srcimg(n,k):return Image.open(SRC/n/"frames"/f"attack_{k:02}.png").convert("RGBA")
def palette(im):
    p={c for c in im.getdata() if c[3]==255}
    choose=lambda rgb:min(p,key=lambda c:sum((c[i]-rgb[i])**2 for i in range(3)))
    c={k:choose(v) for k,v in {
     "outline":(48,31,25),"brown":(112,59,36),"brown_hi":(168,105,59),
     "skin":(223,157,104),"green":(72,91,36),"green_hi":(126,137,59),
     "fur":(173,144,91),"cream":(231,195,131),"hoof":(102,59,33),
     "blue":(119,182,212),"white":(222,240,246)}.items()}
    # Blue metal from the actual A15 sword instead of mistakenly sampling a cream pixel.
    blues=[v for v in p if v[2]>v[0]+12 and v[2]>v[1]+3 and v[1]>85]
    if blues:
        c["blue"]=min(blues,key=lambda v:abs(v[0]-124)+abs(v[1]-187)+abs(v[2]-219))
        c["white"]=max(blues,key=lambda v:sum(v[:3]))
    return c
def path(d,points,c,w):d.line(points,fill=c,width=w,joint="curve")
def weapon(d,grip,tip,c):
    x,y=grip; dx=tip[0]-x;dy=tip[1]-y;L=math.hypot(dx,dy)
    vx,vy=dx/L,dy/L;nx,ny=-vy,vx
    p=(round(x+vx*5),round(y+vy*5))
    q=(round(tip[0]-vx*2),round(tip[1]-vy*2))
    path(d,[p,q,tip],c["outline"],5)
    path(d,[p,q,tip],c["blue"],3)
    path(d,[(round(p[0]-nx),round(p[1]-ny)),(round(q[0]-nx),round(q[1]-ny)),tip],c["white"],1)
    g=(round(x+vx*3),round(y+vy*3))
    path(d,[(round(g[0]-nx*3),round(g[1]-ny*3)),(round(g[0]+nx*3),round(g[1]+ny*3))],c["outline"],3)
    path(d,[(round(g[0]-nx*2),round(g[1]-ny*2)),(round(g[0]+nx*2),round(g[1]+ny*2))],c["brown_hi"],1)
    path(d,[grip,(round(x-vx*6),round(y-vy*6))],c["outline"],4)
    path(d,[grip,(round(x-vx*5),round(y-vy*5))],c["brown"],2)
def human(i,elbow,hand,tip):
    name="T1_forest_scout"
    orig=srcimg(name,i);canvas=srcimg(name,1)
    canvas.paste(orig.crop((54,76,61,84)),(54,76))
    c=palette(orig);d=ImageDraw.Draw(canvas)
    weapon(d,hand,tip,c)
    shoulder=(55,57)
    # Hand-authored upper / lower arm contours and elbow, not an affine rotation.
    path(d,[shoulder,elbow,hand],c["outline"],6)
    path(d,[shoulder,elbow,hand],c["green"],4)
    path(d,[(56,56),(elbow[0],elbow[1]-1),(hand[0],hand[1]-1)],c["green_hi"],1)
    d.polygon([(53,55),(56,54),(60,57),(57,61),(53,60)],fill=c["outline"])
    d.polygon([(54,56),(56,55),(58,57),(55,59)],fill=c["green"])
    d.line([(elbow[0]-1,elbow[1]+1),(elbow[0]+2,elbow[1]+1)],fill=c["brown"],width=1)
    x,y=hand
    d.rectangle((x-2,y-2,x+2,y+2),fill=c["outline"])
    d.rectangle((x-1,y-1,x+1,y+1),fill=c["brown"])
    d.line([(x,y-1),(x+2,y-1)],fill=c["skin"],width=1)
    d.point((x+2,y+1),fill=c["brown_hi"])
    return orig,canvas
def leg(d,j,c,near):
    hip,knee,ankle,foot=j
    tone=c["cream"] if near else c["fur"]
    path(d,[hip,knee,ankle],c["outline"],4 if near else 3)
    path(d,[hip,knee,ankle],tone,2 if near else 1)
    # Shade one pixel below knee joint to show flexion; no round/blob feet.
    d.point((knee[0],knee[1]+1),fill=c["brown"])
    x,y=foot
    d.polygon([(x-2,y-1),(x+1,y-2),(x+2,y),(x+1,y+1),(x-2,y+1)],fill=c["outline"])
    d.line([(x-1,y),(x+1,y)],fill=c["hoof"],width=1)
    d.point((x-1,y-1),fill=c["brown_hi"])
def monster(i,positions):
    name="T2_moss_antler"
    orig=srcimg(name,i);canvas=orig.copy();c=palette(orig);d=ImageDraw.Draw(canvas)
    # Old foot pixels only, preserving original face, canopy, moss, chest and central belly.
    for bbox in [(27,69,45,81),(55,69,75,81)]:
        d.rectangle(bbox,fill=(0,0,0,0))
    # Two 1px attachment edges, not broad cover-up polygons (R0 defect).
    d.line([(34,66),(39,66)],fill=c["cream"],width=1)
    d.line([(59,66),(65,66)],fill=c["green"],width=1)
    for key in ("front_far","back_far","front_near","back_near"):
        leg(d,positions[key],c,key.endswith("_near"))
    return orig,canvas
poses3={
"front_far":((34,64),(33,66),(32,67),(31,69)),
"front_near":((41,64),(43,67),(41,68),(39,69)),
"back_far":((58,64),(61,65),(63,67),(64,69)),
"back_near":((64,64),(68,65),(68,67),(68,69))}
poses5={
"front_far":((33,65),(31,68),(29,73),(28,75)),
"front_near":((41,65),(39,69),(37,73),(35,75)),
"back_far":((58,65),(63,67),(60,70),(59,72)),
"back_near":((65,65),(68,67),(66,70),(64,72))}
runs=[
 ("T1_02_DRAW",*human(2,(59,64),(68,58),(75,35)),"T1_forest_scout",2),
 ("T1_05_STRIKE",*human(5,(61,56),(69,63),(39,61)),"T1_forest_scout",5),
 ("T2_03_FLIGHT",*monster(3,poses3),"T2_moss_antler",3),
 ("T2_05_LANDING",*monster(5,poses5),"T2_moss_antler",5)]
def diff(a,b):
    return [(i%a.width,i//a.width,px[3]!=py[3]) for i,(px,py) in enumerate(zip(a.getdata(),b.getdata())) if px!=py]
qa={}
for label,old,new,n,i in runs:
    pathout=OUT/n/f"attack_{i:02}_A16_KEY_R1.png";new.save(pathout)
    ds=diff(old,new)
    # Facial ROI and antler ROI are smaller than generic upper-image test; sword is allowed outside.
    face=(23,18,53,52) if n.startswith("T1") else (15,0,80,55)
    protected=sum(1 for x,y,_ in ds if face[0]<=x<face[2] and face[1]<=y<face[3])
    qa[label]={"size":list(new.size),"changed_rgba_pixels":len(ds),"changed_alpha_pixels":sum(bool(z) for x,y,z in ds),
       "protected_head_roi_changes":protected,"sha256":H(pathout),"G7":"PENDING / visually rejected until reviewed",
       "ASF_Godot":"NOT RUN FOR R1"}
def compare(scale):
    cw=96*scale;rh=121*scale
    contact=Image.new("RGB",(2*cw,4*rh),(222,223,225));dw=ImageDraw.Draw(contact)
    for row,(label,old,new,n,i) in enumerate(runs):
        for col,spr in enumerate([old,new]):
            bg=Image.new("RGBA",spr.size,(222,223,225,255));bg.alpha_composite(spr)
            contact.paste(bg.convert("RGB").resize((cw,spr.height*scale),Image.Resampling.NEAREST),(col*cw,row*rh+25))
            dw.text((col*cw+3,row*rh+5),label+" / "+("A15" if col==0 else "A16 R1"),fill=(25,25,25))
    contact.save(OUT/f"A16_R1_COMPARE_{scale}X.png")
for s in (1,3,6):compare(s)
(OUT/"A16_R1_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf-8")
(OUT/"A16_R1_HANDOFF.md").write_text("""# A16 R1 — four original RGBA keyposes, ART CANDIDATE ONLY
- R0 visually rejected: sword edge was hollow and hoof sizes badly overscaled. R0 is preserved as failure evidence.
- T1 02 / 05: real bent/extended shoulder-elbow-wrist artwork with hand/finger and sword silhouette replacement.
- T2 03 / 05: original lower hooves removed then four knee-ankle-hoof outlines redrawn using source palette; R1 hooves scaled down.
- No image interpolation or transform-only claim. Face and antlers must be pixel-identical inside protection ROI.
- A15 base, sealed FS, K4 and N5 remain immutable.
- Before running ASF, human must inspect PNG at 1x and 3x and reject unnatural limbs, missing fur, duplicated hands or cloak overlaps.
- G7 aesthetic acceptance NOT PASSED, G5/G6 A16 NOT TESTED, G8 VX NOT TESTED.
""",encoding="utf-8")
with zipfile.ZipFile(OUT/"A16_R1_PRIVATE_KEYPOSE_CANDIDATE.zip","w",zipfile.ZIP_DEFLATED) as z:
    for file in [OUT/"A16_R1_QA.json",OUT/"A16_R1_HANDOFF.md",OUT/"A16_R1_COMPARE_1X.png",OUT/"A16_R1_COMPARE_3X.png",OUT/"A16_R1_COMPARE_6X.png",Path(__file__)]+[OUT/n/f"attack_{i:02}_A16_KEY_R1.png" for _,_,_,n,i in runs]:
        z.write(file,file.relative_to(OUT))
print(json.dumps({k:{"diff":v["changed_rgba_pixels"],"face_or_antler":v["protected_head_roi_changes"]} for k,v in qa.items()},ensure_ascii=False))
print("ZIP_SHA256",H(OUT/"A16_R1_PRIVATE_KEYPOSE_CANDIDATE.zip"))
