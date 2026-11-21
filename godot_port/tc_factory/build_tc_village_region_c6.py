#!/usr/bin/env python3
"""T-C C6: an ENTIRE 8x8 woodland/roadside village seam, non-destructive candidate.

Every image is derived from the same C5 Master; no historical tree owner is
falsely reconstructed from flattened art. New saplings/waystone are authored
as separate reproducible 1x RGBA images, NOT new PixelLab API output.
Godot 4.7.2 native art/occlusion/collision gate is independent of static QA.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import shutil
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw

import build_tc_village_pilot as pilot
import build_tc_village_style_c5 as c5

WIDTH,HEIGHT=1280,928
REGION=(640,160,896,416)  # EXACT 8x8 at 32x32, no resize
SEED=20261121_06
PROPS=[
    {"id":"TC_C6_ANCIENT_WAYSTONE","kind":"waystone","origin":[726,272],
     "size":[34,55],"foot":[745,327],"blocking":[739,319,752,329]},
    {"id":"TC_C6_YOUNG_ALDER","kind":"sapling_a","origin":[649,282],
     "size":[38,54],"foot":[668,332],"blocking":[663,328,674,337]},
    {"id":"TC_C6_YOUNG_ROWAN","kind":"sapling_b","origin":[799,270],
     "size":[37,60],"foot":[818,326],"blocking":[812,325,822,334]}
]

def sha(p:Path)->str:
    return hashlib.sha256(p.read_bytes()).hexdigest()

def save(img:Image.Image,path:Path)->None:
    img.save(path,optimize=True)

def green(px):
    r,g,b=px[:3]
    return g>72 and g>r*1.11 and g>b*1.45 and b<120

def road(px):
    r,g,b=px[:3]
    return r>155 and g>129 and b>54 and r>g*1.025 and g>b*1.29

def draw_ground(source:Image.Image):
    im=source.convert("RGB").copy()
    px=im.load()
    rng=random.Random(SEED)
    touches=0
    roadside=0
    flowers=0
    # A region-sized native-pixel treatment, not a 32x32 repeated floor stamp.
    # Warm/bright forest clearings are irregular and never overwrite road cells.
    pockets=[(700,313,45,31),(765,290,44,33),(814,313,36,28),
             (674,360,40,34),(754,359,29,25)]
    for y in range(REGION[1]+2,REGION[3]-2):
        for x in range(REGION[0]+2,REGION[2]-2):
            old=px[x,y]
            if not green(old):
                continue
            strength=0.0
            for cx,cy,rx,ry in pockets:
                v=((x-cx)/rx)**2+((y-cy)/ry)**2
                if v<1.0:
                    # irregular native pixel edge prevents perfect ellipses
                    wobble=0.13*math.sin(x*0.19+y*0.11)+0.09*math.sin(y*0.31-x*0.07)
                    strength=max(strength,max(0.0,1.0-v+wobble))
            if strength>0.06 and rng.random() < 0.20*min(strength,1):
                r,g,b=old
                px[x,y]=(min(255,r+6),min(255,g+10),min(255,b+1))
                touches+=1

    d=ImageDraw.Draw(im)
    # Botanically clustered grass/lichen/flowers, non-grid positioned.
    leaf_colors=[(56,105,30),(73,122,37),(101,142,32),(51,89,26)]
    flowers_palette=[(230,217,167),(174,146,179),(191,191,153),(236,226,182)]
    for k in range(150):
        x=rng.randint(REGION[0]+5,REGION[2]-6)
        y=rng.randint(REGION[1]+9,REGION[3]-7)
        if not green(source.getpixel((x,y))):
            continue
        # Preserve continuous trail surfacing and foreground roots.
        if any(road(source.getpixel((xx,yy))) for xx,yy in
               ((x,y),(max(REGION[0],x-3),y),(min(REGION[2]-1,x+3),y))):
            continue
        col=leaf_colors[(k//7)%len(leaf_colors)]
        for _ in range(rng.randrange(2,6)):
            u=x+rng.randrange(-6,7); v=y+rng.randrange(-3,4)
            if not (REGION[0]+1<u<REGION[2]-1 and REGION[1]+1<v<REGION[3]-1):
                continue
            if not green(source.getpixel((u,v))):
                continue
            d.point((u,v),fill=col)
            d.point((u-1,v+1),fill=(43,82,27))
            if k%5==0 and rng.random()<0.4:
                d.point((u,v-1),fill=flowers_palette[k%len(flowers_palette)])
                flowers+=1
    # 1x grass tufts along the genuine authored road, without repainting the
    # road centreline or disconnecting it.
    for y in range(REGION[1]+5,REGION[3]-5,3):
        for x in range(REGION[0]+5,REGION[2]-5,3):
            if not green(source.getpixel((x,y))):
                continue
            if not any(road(source.getpixel((x+dx,y+dy))) for dx,dy in
                       ((-4,0),(4,0),(0,-4),(0,4))):
                continue
            if rng.random()<0.26:
                d.point((x,y),fill=(40,95,26))
                d.point((x+1,y-1),fill=(76,133,40))
                roadside+=1
    # Small stepping stones connect the forest boundary to the already
    # existing winding path. They are road-side dressing, NOT a NAV rewrite.
    stepping=[(771,335,7,3),(784,341,6,3),(798,344,5,3)]
    for x,y,w,h in stepping:
        if not green(source.getpixel((x,y))):
            continue
        d.ellipse((x,y,x+w,y+h),fill=(143,146,95),outline=(85,116,52))
        d.point((x+2,y),fill=(193,184,132))
    return im,{"native_grass_delta_pixels":touches,"roadside_tufts":roadside,
               "flower_pixels":flowers,"stepping_stones_attempted":len(stepping)}

def draw_waystone(w,h):
    s=Image.new("RGBA",(w,h),(0,0,0,0));d=ImageDraw.Draw(s)
    # Top-down 3/4 standing fieldstone with thick beveled/lichen sides.
    d.ellipse((2,h-12,w-3,h-3),fill=(50,74,27,92))
    d.polygon([(12,2),(23,3),(28,12),(29,44),(22,51),(9,50),(5,43),(5,14)],
              fill=(64,73,54,255),outline=(36,51,36,255))
    d.polygon([(12,2),(23,3),(26,12),(24,39),(20,45),(11,42),(8,13)],
              fill=(123,130,102,255))
    d.polygon([(12,3),(22,4),(24,8),(15,12),(8,11)],
              fill=(170,174,134,255))
    d.line([(11,15),(11,36)],fill=(153,160,120,255),width=2)
    d.line([(19,18),(22,34),(19,39)],fill=(70,87,74,255),width=2)
    # Quiet cyan-green rune details, not a large neon advertisement.
    for p in [(17,20),(17,21),(18,22),(17,23),(16,24),(17,25)]:
        d.point(p,fill=(108,178,129,255))
    d.polygon([(8,11),(11,8),(17,9),(19,12),(16,14),(10,13)],
              fill=(57,108,40,255))
    for p in [(9,10),(13,9),(17,12),(11,15),(25,29),(24,31)]:
        d.point(p,fill=(113,159,68,255))
    d.polygon([(8,42),(11,45),(13,45),(12,49),(7,48)],fill=(53,108,44,255))
    return s

def draw_sapling(w,h,variant):
    rng=random.Random(SEED+variant*337)
    s=Image.new("RGBA",(w,h),(0,0,0,0));d=ImageDraw.Draw(s)
    cx=w//2
    # Trunk first: visible foot/occlusion pivot remains independent.
    d.ellipse((cx-10,h-11,cx+10,h-4),fill=(50,68,23,125))
    d.polygon([(cx-3,30),(cx+3,29),(cx+4,h-5),(cx-4,h-5)],
              fill=(88,63,36,255),outline=(43,47,25,255))
    d.line([(cx,40),(cx-7,29)],fill=(71,51,30,255),width=2)
    d.line([(cx+1,37),(cx+7,29)],fill=(71,51,30,255),width=2)
    # Asymmetric leaf silhouette, different crown architecture by variant.
    if variant==1:
        lobes=[(-11,18,11,38),(-4,6,20,35),(13,16,28,37),(3,16,29,42)]
        base=(34,88,29,255); middle=(57,118,37,255); light=(111,155,54,255)
    else:
        lobes=[(-8,22,11,41),(2,13,28,36),(9,9,33,25),(-5,11,15,30)]
        base=(43,80,34,255);middle=(66,116,43,255);light=(127,149,60,255)
    for x0,y0,x1,y1 in lobes:
        d.ellipse((max(0,x0),y0,min(w-1,x1),y1),fill=base)
    for _ in range(105):
        x=rng.randint(1,w-2);y=rng.randint(6,39)
        if s.getpixel((x,y))[3]>0:
            col=middle if rng.random()<0.74 else light
            d.rectangle((x,y,x+rng.choice([0,1,2]),y+rng.choice([0,1,2])),
                        fill=col)
    # Final dark leaf pockets with bright 1-pixel tips.
    for _ in range(32):
        x=rng.randint(2,w-3);y=rng.randint(8,38)
        if s.getpixel((x,y))[3]>0:
            d.point((x,y),fill=light if rng.random()<.60 else base)
    return s

def draw_boulder(w,h,variant):
    s=Image.new("RGBA",(w,h),(0,0,0,0));d=ImageDraw.Draw(s)
    d.ellipse((0,h-8,w-1,h-1),fill=(48,64,32,95))
    d.polygon([(2,10),(9,3),(w-10,2),(w-3,9),(w-5,h-6),(6,h-6)],
              fill=(90,102,81,255),outline=(47,62,49,255))
    d.polygon([(9,4),(w-12,4),(w-8,9),(w-16,13),(4,11)],
              fill=(158,162,126,255))
    d.polygon([(4,11),(14,12),(15,h-7),(6,h-6)],fill=(74,86,72,255))
    d.line([(12,6),(17,9)],fill=(205,200,149,255))
    if variant==2:
        d.rectangle((14,7,20,8),fill=(62,121,56,255))
    d.point((7,9),fill=(55,121,43,255))
    return s

def build(out:Path,source:Path=pilot.SOURCE,existing_c5:Path|None=None):
    out.mkdir(parents=True,exist_ok=True)
    if existing_c5 is None:
        c5.build(out,source)
    else:
        # Local research replay uses C5 frozen native QA input; CI rebuilds
        # C5 directly from the canonical PixelLab historical source.
        for p in existing_c5.rglob("*"):
            if p.is_file() and not p.name.endswith(".import"):
                t=out/p.relative_to(existing_c5)
                t.parent.mkdir(parents=True,exist_ok=True)
                shutil.copyfile(p,t)
    baseline=Image.open(out/"MASTER.png").convert("RGB")
    original_ground=Image.open(out/"Authoring_GroundOnly.png").convert("RGB")
    ground,stats=draw_ground(original_ground)
    if ImageChops.difference(ground,original_ground).getbbox() is None:
        raise AssertionError("C6 meadow whole region has no actual source delta")
    par=Image.open(out/"Authoring_CompletePAR.png").convert("RGBA")
    assets=out/"c6_independent_props";assets.mkdir(exist_ok=True)
    sprites=[]
    for i,p in enumerate(PROPS):
        w,h=p["size"]
        if p["kind"]=="waystone":
            img=draw_waystone(w,h)
        elif p["kind"]=="sapling_a":
            img=draw_sapling(w,h,1)
        else:
            img=draw_sapling(w,h,2)
        name=p["id"]+".png";save(img,assets/name)
        if img.getchannel("A").getbbox() is None:
            raise AssertionError("Independent C6 prop empty: "+name)
        if not (REGION[0]<=p["origin"][0] and REGION[1]<=p["origin"][1]
                and p["origin"][0]+w<=REGION[2] and p["origin"][1]+h<=REGION[3]):
            raise AssertionError("C6 independent object outside 8x8 region: "+name)
        par.alpha_composite(img,tuple(p["origin"]))
        sprites.append((p,img,name))
    boulders=[((672,337),draw_boulder(33,24,1),"TC_C6_ROADSIDE_BOULDER_A.png"),
              ((701,364),draw_boulder(28,20,2),"TC_C6_ROADSIDE_BOULDER_B.png")]
    for xy,img,name in boulders:
        save(img,assets/name)
        par.alpha_composite(img,xy)
    master=Image.alpha_composite(ground.convert("RGBA"),par).convert("RGB")
    for name,img in [("MASTER.png",master),("Runtime_FullGround.png",master),
                     ("Authoring_GroundOnly.png",ground),
                     ("Authoring_CompletePAR.png",par)]:
        save(img,out/name)
    union=Image.new("L",(WIDTH,HEIGHT),0)
    existing_owners=json.loads((out/"TC_PILOT_OCCLUSION_OWNERS.json").read_text("utf8"))
    for owner in existing_owners:
        p=out/"occlusion_owners"/owner["file"]
        alpha=Image.open(p).convert("RGBA").getchannel("A")
        save(pilot.compose_mask_from_master(master,alpha),p)
        owner["sha256"]=sha(p)
        union=ImageChops.lighter(union,alpha)
    for prop,img,name in sprites:
        x,y=prop["origin"];w,h=prop["size"]
        # Independent source actor-occlusion mask: canopy/upper stone only.
        # Front/base pixels are never promoted into a blanket CompletePAR overlay.
        cut=min(h,max(1,prop["foot"][1]-y-6))
        a=img.getchannel("A").crop((0,0,w,cut))
        mask=Image.new("L",(WIDTH,HEIGHT),0)
        mask.paste(a,(x,y))
        fname="owner_"+prop["id"].lower()+".png"
        fp=out/"occlusion_owners"/fname
        save(pilot.compose_mask_from_master(master,mask),fp)
        union=ImageChops.lighter(union,mask)
        existing_owners.append({
            "id":prop["id"],"type":"tree" if "sapling" in prop["kind"] else "waystone",
            "foot_x":prop["foot"][0],"foot_y":prop["foot"][1],
            "file":fname,"bbox":list(mask.getbbox()),"sha256":sha(fp),
            "independent_source":str(Path("c6_independent_props")/name),
            "source_sha256":sha(assets/name),
            "occlusion_pixels":sum(mask.histogram()[1:]),
            "authored_method":"deterministic 1x handcrafted RGBA, not PixelLab new generation"
        })
    save(pilot.compose_mask_from_master(master,union),out/"Runtime_OcclusionPAR.png")
    (out/"TC_PILOT_OCCLUSION_OWNERS.json").write_text(
        json.dumps(existing_owners,ensure_ascii=False,indent=2),encoding="utf8")
    (out/"TC_C6_ROOT_FOOTPRINTS.json").write_text(
        json.dumps({"region_px":REGION,"colliders":[{"id":p["id"],
          "bbox":p["blocking"],"source":p["id"]+".png",
          "foot":p["foot"]} for p in PROPS],
          "type":"source_authored_canopy_footpoint_colliders",
          "native_gate":"PENDING_GODOT_C6_NATIVE_ROOT_TEST",
          "not_full_tree_collision_coverage":True},ensure_ascii=False,indent=2),encoding="utf8")

    changed=ImageChops.difference(baseline,master)
    bbox=changed.getbbox()
    if bbox is None or not (REGION[0]<=bbox[0]<bbox[2]<=REGION[2]
                            and REGION[1]<=bbox[1]<bbox[3]<=REGION[3]):
        raise AssertionError("C6 unintended change outside only 8x8 region: "+str(bbox))
    region_delta=sum(color !=(0,0,0) for color in changed.crop(REGION).getdata())
    if region_delta<1500:
        raise AssertionError("C6 whole region not materially authored: "+str(region_delta))
    recomposed=Image.alpha_composite(ground.convert("RGBA"),par).convert("RGB")
    if ImageChops.difference(recomposed,master).getbbox() is not None:
        raise AssertionError("C6 Master/Ground/PAR source mismatch")
    if ImageChops.difference(master,Image.open(out/"Runtime_FullGround.png").convert("RGB")).getbbox():
        raise AssertionError("C6 runtime fullground not exact Master")
    # Prove source ground and PAR are bit-identical OUTSIDE selected 8x8 region.
    before_ground=ImageChops.difference(ground,original_ground)
    if before_ground.getbbox() and not all((
        before_ground.getbbox()[0]>=REGION[0],before_ground.getbbox()[1]>=REGION[1],
        before_ground.getbbox()[2]<=REGION[2],before_ground.getbbox()[3]<=REGION[3])):
        raise AssertionError("C6 changed ground outside ROI")
    box_before=baseline.crop(REGION)
    box_after=master.crop(REGION)
    save(box_before,out/"TC_C6_REGION_BEFORE_1X.png")
    save(box_after,out/"TC_C6_REGION_AUTHORING_AFTER_1X.png")
    pair=Image.new("RGB",(512,256),(27,30,25))
    pair.paste(box_before,(0,0));pair.paste(box_after,(256,0))
    save(pair,out/"TC_C6_REGION_SOURCE_AB_1X.png")
    previous=json.loads((out/"TC_PILOT_SOURCE_QA.json").read_text("utf8"))
    previous.update({
        "stage":"C6 complete 8x8 woodland road threshold with source-differentiated understory",
        "region":"FS_01_VILLAGE north woodland-to-path entry",
        "region_px":list(REGION),"region_tile_origin":[20,5],
        "region_grid":[8,8],"world_grid":[40,29],
        "native_pixel_region_size":[256,256],
        "source_registration":"STATIC_PASS_MASTER_GROUND_COMPLETEPAR_SAME_SOURCE",
        "baseline_C5_sha256":sha(out/"TC_C5_INDEPENDENT_WHOLE_HOUSE_RGBA.png"),
        "region_change_bbox":list(bbox),"region_changed_px":region_delta,
        "grass_road_stats":stats,
        "independent_c6_sprite_count":len(PROPS)+len(boulders),
        "independent_c6_occluding_owners":len(PROPS),
        "c5_owners_preserved":len(existing_owners)-len(PROPS),
        "total_occlusion_owners":len(existing_owners),
        "new_prop_root_colliders":len(PROPS),
        "source_ground_outside_region":"BIT_EXACT",
        "existing_tree_group_sources":"PRESERVED_NO_FAKE_PRIVATE_TREE_ALPHA",
        "not_new_pixellab_generation":True,
        "art_gate":"ART_HOLD",
        "native_gate":"PENDING_GODOT_472",
        "human_review":"needs whole-map visual and 1x tree/waystone layering review",
        "image_sha256":{name:sha(out/name) for name in
            ("MASTER.png","Authoring_GroundOnly.png","Authoring_CompletePAR.png",
             "Runtime_FullGround.png","Runtime_OcclusionPAR.png")}
    })
    (out/"TC_PILOT_SOURCE_QA.json").write_text(
       json.dumps(previous,ensure_ascii=False,indent=2),encoding="utf8")
    print(json.dumps({"stage":"C6","region":REGION,"changes":region_delta,
         "stats":stats,"owners":len(existing_owners),"new_roots":len(PROPS),
         "gate":"STATIC_PASS_NOT_ART_PASS"},ensure_ascii=False))
    return previous

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--out",required=True,type=Path)
    ap.add_argument("--source",type=Path,default=pilot.SOURCE)
    ap.add_argument("--existing-c5",type=Path)
    args=ap.parse_args()
    build(args.out,args.source,args.existing_c5)
