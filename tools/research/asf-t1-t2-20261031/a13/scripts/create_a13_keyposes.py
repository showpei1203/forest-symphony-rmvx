from pathlib import Path
from PIL import Image,ImageDraw
from math import hypot,atan2,cos,sin,pi
import numpy as np,json,hashlib,random
LAB=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
OUT=LAB/"A13_KEYPOSE_RIG"
OUT.mkdir(exist_ok=True)
A10=LAB/"A10_ONE_MASTER_RIG"
random.seed(13)
def color(im,x,y):return im.getpixel((x,y))
def segpoly(draw,a,b,width,outline,fill):
    dx=b[0]-a[0];dy=b[1]-a[1];norm=max(1.,hypot(dx,dy));nx=-dy/norm;ny=dx/norm
    def points(w):return [(int(round(x+nx*w*k)),int(round(y+ny*w*k))) for x,y,k in [(a[0],a[1],1),(b[0],b[1],1),(b[0],b[1],-1),(a[0],a[1],-1)]]
    draw.polygon(points(width/2+1),fill=outline)
    draw.polygon(points(width/2-0.6),fill=fill)
def make_sword(img,handle,angle_deg,length=25):
    # local 2d sword child of the wrist; all geometry derived from grip anchor + direction.
    ax=cos(angle_deg*pi/180);ay=sin(angle_deg*pi/180);nx=-ay;ny=ax
    def P(dist,width=0):return (int(round(handle[0]+ax*dist+nx*width)),int(round(handle[1]+ay*dist+ny*width)))
    d=ImageDraw.Draw(img)
    d.line([P(-5,0),P(2,0)],fill=(43,29,30,255),width=5)
    d.line([P(-5,0),P(0,0)],fill=(122,72,43,255),width=3)
    d.line([P(0,-4),P(0,4)],fill=(42,34,36,255),width=3)
    d.line([P(1,-4),P(1,4)],fill=(220,167,76,255),width=1)
    d.polygon([P(4,-2),P(4,2),P(length,0)],fill=(41,61,80,255))
    d.polygon([P(5,-1),P(5,1),P(length-1,0)],fill=(158,196,217,255))
    d.line([P(6,-1),P(length-2,0)],fill=(235,247,242,255),width=1)
    d.point(P(-5,0),fill=(238,192,74,255))
    return [P(0,0),P(length,0)]
def crop_with_alpha(src,pts):
    mask=Image.new("L",src.size,0);dr=ImageDraw.Draw(mask);dr.polygon(pts,fill=255)
    im=src.copy();im.putalpha(Image.fromarray(np.minimum(np.asarray(src.getchannel("A")),np.asarray(mask)).astype("uint8")))
    return im
def t1():
    inp=Image.open(A10/"T1_forest_scout"/"master.png").convert("RGBA")
    out=OUT/"T1_forest_scout";(out/"frames").mkdir(parents=True,exist_ok=True)
    ox,oy=16,16
    # mask is annotated in original master 64x80 coordinate system, not inferred from coloured pixels.
    arm_mask=[(35,39),(42,38),(45,43),(46,51),(42,55),(35,54),(33,45)]
    marked=crop_with_alpha(inp,arm_mask)
    marked.save(out/"annotated_forearm_source.png")
    armpalette={"outline":(45,32,29,255),"coat":(78,111,49,255),"leather":(122,70,42,255),"skin":(227,173,110,255)}
    # recorded absolute local coordinates in original 64x80 image.
    poses=[
      ("sheathed", (42,47),(43,52),None,5),
      ("anticipation",(40,45),(42,52),None,8),
      ("draw",(44,43),(47,44),-75,8),
      ("raise",(46,42),(49,34),-85,6),
      ("accelerate",(47,43),(50,42),-145,4),
      ("contact",(46,45),(47,49),-180,5),
      ("follow_through",(43,48),(42,54),150,7),
      ("recovery",(41,47),(42,52),-55,10)
    ]
    # pose 0 and 1 do not expose a sword. Original hip shows a weapon scabbard;
    # from frame2 on, display intentionally adds drawn blade, while source scabbard
    # remains (empty-scabbard appearance NOT yet proven). This must stay art pending.
    conf={"master_file":"A10_ONE_MASTER_RIG/T1_forest_scout/master.png","origin":[ox,oy],"canvas":[96,112],
      "joint_master_coords":{"shoulder":[37,41],"elbow_candidates":[43,45],"wrist_rest":[43,52],"hip_scabbard":[45,52]},
      "arm_mask_polygon":arm_mask,"weapon_parent":"wrist","weapon_source":"procedural original pixel blade; independent from original Master",
      "notes":"The original painted hip scabbard still exists in A10 master. No claim of authoritative unsheathing visual or human G7 PASS.",
      "frames":[]}
    for idx,(name,el,wr,blade,hold) in enumerate(poses):
      frame=Image.new("RGBA",(96,112))
      # Pose root stays fixed, high parts original identity pixel-exact. Small torso lean for weight shift.
      torso_dx=[0,-1,-1,0,1,1,0,0][idx]
      frame.alpha_composite(inp,(ox+torso_dx,oy))
      # a patch of original torso colour covers the old glove silhouette; outside torso should not be redrawn
      dr=ImageDraw.Draw(frame)
      should=(ox+37+torso_dx,oy+41)
      elbow=(ox+el[0]+torso_dx,oy+el[1])
      wrist=(ox+wr[0]+torso_dx,oy+wr[1])
      # upper sleeve and lower forearm in layered z order. Grip placed on top of guard.
      segpoly(dr,should,elbow,7,armpalette["outline"],armpalette["coat"])
      segpoly(dr,elbow,wrist,5,armpalette["outline"],armpalette["leather"])
      if blade is not None:
        end=make_sword(frame,wrist,blade)
      else:end=None
      ImageDraw.Draw(frame).ellipse((wrist[0]-2,wrist[1]-2,wrist[0]+2,wrist[1]+2),fill=armpalette["skin"],outline=armpalette["outline"])
      frame.save(out/"frames"/f"attack_{idx:02d}.png")
      conf["frames"].append({"i":idx,"pose":name,"elbow":list(elbow),"wrist":list(wrist),"weapon_angle":blade,
        "tip":end[1] if end else None,"ticks":hold,"wrist_grip_delta_px":0 if blade is not None else None})
    (out/"rig_authority.json").write_text(json.dumps(conf,ensure_ascii=False,indent=2),encoding="utf8")
    return conf
def leg_image(draw,x0,y0,x1,y1,width,near):
    outline=(53,42,27,255)
    leg=(139,110,60,255) if near else (101,95,46,255)
    hoof=(70,54,32,255) if near else (79,67,29,255)
    segpoly(draw,(x0,y0),(x1,y1-2),width,outline,leg)
    draw.polygon([(x1-4,y1-3),(x1+3,y1-3),(x1+4,y1),(x1-4,y1)],fill=outline)
    draw.line([(x1-3,y1-2),(x1+2,y1-2)],fill=hoof,width=2)
def t2():
    inp=Image.open(A10/"T2_moss_antler"/"master.png").convert("RGBA")
    out=OUT/"T2_moss_antler";(out/"frames").mkdir(parents=True,exist_ok=True)
    # original legs from y~48-60, body stays full/antlers unsegmented.
    base=inp.copy()
    dr=ImageDraw.Draw(base)
    # Remove exposed original hooves only in narrow bottom strip. We do not alter antlers.
    # Keep moss body above 49 px unaltered; 49-60 becomes underlying hidden-legs transparent.
    for y in range(51,64):
      for x in range(64):
        if y>=54 and x in range(11,58): base.putpixel((x,y),(0,0,0,0))
    ox,oy=16,15
    leg_origins={"front_far":(20,47),"front_near":(27,48),"back_far":(43,48),"back_near":(51,48)}
    # 0 contact, 1 crouch, 2 hind push, 3 brief flight, 4 impact, 5 brake, 6 restore, 7 rest.
    steps=[
      ("stance", 0,0,{"front_far":(0,0),"front_near":(0,0),"back_far":(0,0),"back_near":(0,0)},[1,1,1,1],9),
      ("compression",0,2,{"front_far":(0,0),"front_near":(0,0),"back_far":(0,0),"back_near":(0,0)},[1,1,1,1],8),
      ("push",-2,-2,{"front_far":(-1,-2),"front_near":(-1,0),"back_far":(2,-1),"back_near":(2,0)},[0,1,0,1],6),
      ("flight",-5,-4,{"front_far":(-3,-3),"front_near":(-3,-2),"back_far":(4,-2),"back_near":(4,-3)},[0,0,0,0],5),
      ("contact",-7,0,{"front_far":(-6,0),"front_near":(-6,0),"back_far":(2,-2),"back_near":(3,-2)},[1,1,0,0],5),
      ("brake",-5,2,{"front_far":(-5,0),"front_near":(-5,0),"back_far":(2,0),"back_near":(3,-1)},[1,1,1,0],7),
      ("recover",-2,0,{"front_far":(-2,0),"front_near":(-2,0),"back_far":(0,0),"back_near":(0,0)},[1,1,1,1],8),
      ("rest",0,0,{"front_far":(0,0),"front_near":(0,0),"back_far":(0,0),"back_near":(0,0)},[1,1,1,1],10)
    ]
    conf={"master_file":"A10_ONE_MASTER_RIG/T2_moss_antler/master.png","origin":[ox,oy],"canvas":[96,96],
      "body_unsegmented":True,"body_source_pixel_identity":"A10 master except original hooves removed by conservative lower-row mask",
      "leg_names":list(leg_origins),"limb_origins_master_coords":leg_origins,"contact_definition":"1 means hoof designated stance/ground in semantic keypose table; visual foot-lock not yet geometrically validated",
      "semantic_frames":[]}
    for idx,(label,dx,dy,stepshift,contacts,ticks) in enumerate(steps):
      frame=Image.new("RGBA",(96,96))
      overlay=Image.new("RGBA",(96,96))
      ld=ImageDraw.Draw(overlay)
      foot_pts={}
      for z,name in enumerate(leg_origins):
        lx,ly=leg_origins[name];sx,sy=stepshift[name]
        # Relative to body translation: leg attachment follows body, foot target remains separately controllable.
        start=(ox+lx+dx,oy+ly+dy)
        target=(ox+lx+sx+dx,oy+60+sy+max(0,dy))
        foot_pts[name]=list(target)
        leg_image(ld,*start,*target,6 if "near" in name else 4,"near" in name)
      # far legs below body, near legs over body in foreground.
      frame.alpha_composite(overlay)
      frame.alpha_composite(base,(ox+dx,oy+dy))
      ld2=ImageDraw.Draw(frame)
      for name in ("front_near","back_near"):
        lx,ly=leg_origins[name];sx,sy=stepshift[name]
        p=(ox+lx+dx,oy+ly+dy);q=(ox+lx+sx+dx,oy+60+sy+max(0,dy))
        leg_image(ld2,*p,*q,6,True)
      frame.save(out/"frames"/f"attack_{idx:02d}.png")
      conf["semantic_frames"].append({"frame":idx,"pose":label,"root_offset":[dx,dy],"contacts":dict(zip(leg_origins,contacts)),"foot_targets":foot_pts,"ticks":ticks})
    (out/"rig_authority.json").write_text(json.dumps(conf,ensure_ascii=False,indent=2),encoding="utf8")
    return conf
r1=t1();r2=t2()
print(json.dumps({"T1":len(r1["frames"]),"T2":len(r2["semantic_frames"]),"reference":"only original pixel art and procedural geometry; no I2V","gate":"KEYPOSE_CANDIDATE_VISUAL_PENDING"},ensure_ascii=False))