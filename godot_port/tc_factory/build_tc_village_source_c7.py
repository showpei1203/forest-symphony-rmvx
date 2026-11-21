#!/usr/bin/env python3
"""T-C C7: REPLACE the full C6 placeholder-prop set with source-verified FS art.

All five complete independent RGBA are existing A36G-R4 public-source objects,
whose original SHA-256 and object footpoint are checked against the A36G R4
scene manifest. They are actual artist-authored original object sources,
NOT crops from flattened PAR. PixelLab NEW API jobs are NOT RUN.
The C6 whole-region GroundOnly remains intact; C5 CompletePAR is restored
before applying the five C7 art sources to avoid ghosting old C6 placeholders.

GitHub has code + SOURCE REFERENCES only; generated images/QA go to private Drive.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import tempfile
from pathlib import Path
from PIL import Image, ImageChops

import build_tc_village_pilot as pilot
import build_tc_village_style_c5 as c5
import build_tc_village_region_c6 as c6

WIDTH,HEIGHT=1280,928
REGION=(640,160,896,416)
FS_R4 = pilot.ROOT / "experiments/route_b_25d_20261031_stage16/A36G_R4_R3_6REGIONS_20261104"
MANIFEST = FS_R4 / "A36G_R4_SCENE_MANIFEST.json"
ART_DIR = FS_R4 / "SOURCE_INDEPENDENT_RGBA"
# Five complete SOURCE objects, not five new synthetically generated sprites.
# Collision follows original manifest.blocking: landmark/understory nonblocking.
PROPS=[
    {"id":"TC_C7_SOURCE_WAYMARKER","filename":"A36F_west_waymarker_ORIGINAL_RGBA.png",
     "origin":[725,255],"size":[38,70],"source_id":"west_waymarker","occlusion":True},
    {"id":"TC_C7_SOURCE_BROADLEAF","filename":"A36F_DENSE_TREE_143_RGBA.png",
     "origin":[645,269],"size":[68,64],"source_id":"a36c_dense_tree_143","occlusion":True},
    {"id":"TC_C7_SOURCE_MOSS_CONIFER","filename":"A36F_DENSE_TREE_071_RGBA.png",
     "origin":[791,247],"size":[50,85],"source_id":"a36c_dense_tree_071","occlusion":True},
    {"id":"TC_C7_SOURCE_ROAD_ROCK","filename":"A36F_north_rock_ORIGINAL_RGBA.png",
     "origin":[664,328],"size":[38,38],"source_id":"north_rock","occlusion":False},
    {"id":"TC_C7_SOURCE_UNDERSTORY","filename":"A36F_UNDERSTORY_028_RGBA.png",
     "origin":[696,346],"size":[63,38],"source_id":"a36c_understory_028","occlusion":False}
]

def checksum(p:Path)->str:
    return hashlib.sha256(p.read_bytes()).hexdigest()

def verify_public_source_manifest() -> dict:
    if not MANIFEST.is_file():
        raise FileNotFoundError("A36G R4 canonical source manifest unavailable")
    j=json.loads(MANIFEST.read_text("utf8"))
    if j["canvas"]!=[1280,928] or j["grid"]!=[40,29]:
        raise ValueError("Historical A36G R4 canonical world grid mismatch")
    return {o["id"]:o for o in j["objects"]}

def read_source(prop,original):
    record=original[prop["source_id"]]
    if record["filename"]!=prop["filename"]:
        raise AssertionError("Original authored object filename changed: "+prop["id"])
    raw_path=ART_DIR/record["filename"]
    if not raw_path.is_file():
        raise FileNotFoundError("C7 independent public source missing: "+str(raw_path))
    src_hash=checksum(raw_path)
    if src_hash!=record["sha256"]:
        raise AssertionError("C7 source SHA mismatch: "+prop["id"]+" "+src_hash)
    img=Image.open(raw_path).convert("RGBA")
    if img.size!=(record["w"],record["h"]):
        raise AssertionError("Original source sprite geometry disagrees with authoritative manifest")
    # The source object remains WHOLE and transparent; nearest only, no
    # material recolor or guessed postprocessing that destroys detail.
    if img.size!=tuple(prop["size"]):
        img=img.resize(tuple(prop["size"]),Image.Resampling.NEAREST)
    x,y=prop["origin"];w,h=prop["size"]
    if not (REGION[0]<=x and REGION[1]<=y and x+w<=REGION[2] and y+h<=REGION[3]):
        raise AssertionError("C7 full source sprite exceeds authored 8x8 boundary")
    src_x,src_y=int(record["x"]),int(record["y"])
    foot_x=round(x+(int(record["foot"][0])-src_x)*w/int(record["w"]))
    foot_y=round(y+(int(record["foot"][1])-src_y)*h/int(record["h"]))
    if foot_x<x or foot_x>x+w or foot_y<y or foot_y>y+h:
        raise AssertionError("C7 source footpoint transform invalid: "+prop["id"])
    return img,record,src_hash,[foot_x,foot_y]

def build(out:Path,source:Path=pilot.SOURCE):
    out.mkdir(parents=True,exist_ok=True)
    original=verify_public_source_manifest()
    # Restore C5 original complete PAR to GUARANTEE no C6 old handmade object
    # silhouette survives underneath. Build C6 floor intact first.
    c6.build(out,source)
    previous_master=Image.open(out/"MASTER.png").convert("RGB").copy()
    old_c6_qa=json.loads((out/"TC_PILOT_SOURCE_QA.json").read_text("utf8"))
    ground=Image.open(out/"Authoring_GroundOnly.png").convert("RGB")
    with tempfile.TemporaryDirectory(prefix="fs_tc_c7_c5_") as temp:
        tmp=Path(temp)
        c5.build(tmp,source)
        par=Image.open(tmp/"Authoring_CompletePAR.png").convert("RGBA")
        owners=json.loads((tmp/"TC_PILOT_OCCLUSION_OWNERS.json").read_text("utf8"))
        # C5 original independent owner source images had source-matched alpha;
        # reuse ONLY alpha and rebind new RGB to C7 master later.
        for o in owners:
            candidate=tmp/"occlusion_owners"/o["file"]
            target=out/"occlusion_owners"/o["file"]
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(candidate.read_bytes())
        # Two original full-house StaticBody2D footprints preserved exactly.
        (out/"TC_PILOT_COLLISION.json").write_bytes(
            (tmp/"TC_PILOT_COLLISION.json").read_bytes())

    prop_dir=out/"c7_independent_fs_origins";prop_dir.mkdir(exist_ok=True)
    new_source_metadata=[]
    new_owners=[]
    root_colliders=[]
    overlay_alphas={}
    for prop in PROPS:
        img,record,src_hash,foot=read_source(prop,original)
        target=prop_dir/(prop["id"]+".png")
        img.save(target,optimize=True)
        par.alpha_composite(img,tuple(prop["origin"]))
        meta={
          "id":prop["id"],"original_scene_object":record["id"],
          "source_path":str((ART_DIR/prop["filename"]).relative_to(pilot.ROOT)),
          "source_sha256":src_hash,"source_type":record["type"],
          "source_blocking":bool(record["blocking"]),
          "source_image_size":[record["w"],record["h"]],
          "authored_size":prop["size"],"authored_origin":prop["origin"],
          "footpoint":foot,"independent_output_sha256":checksum(target),
          "resize":"nearest-neighbor whole authored source if needed",
          "source_alpha_isolated":record.get("alpha_isolated",False),
          "pixel_art_source":"real FS A36G R4 independent art (not PixelLab new generation)"
        }
        new_source_metadata.append(meta)
        if prop["occlusion"]:
            x,y=prop["origin"];w,h=prop["size"]
            # Upper foliage/streetlamp only; never turn the whole PAR into
            # occlusion. Actor must be BEHIND this source footpoint.
            top_len=max(1,min(h,foot[1]-y-5))
            alpha=Image.new("L",(WIDTH,HEIGHT),0)
            alpha.paste(img.getchannel("A").crop((0,0,w,top_len)),(x,y))
            overlay_alphas[prop["id"]]=alpha
            new_owners.append({
              "id":prop["id"],"type":record["type"],"foot_x":foot[0],
              "foot_y":foot[1],"file":"owner_"+prop["id"].lower()+".png",
              "bbox":list(alpha.getbbox() or (0,0,0,0)),
              "source_sha256":src_hash,
              "independent_source":"c7_independent_fs_origins/"+target.name,
              "source_object_id":record["id"],
              "occlusion_pixels":sum(alpha.histogram()[1:]),
              "foot_semantics":"whole-source original footpoint scaled exactly"
            })
        if bool(record["blocking"]):
            # Original R4 source manifest gives tree blocking=true, but no
            # exact polygon; root point footprint is narrow, not canopy size.
            x,y=foot
            r=[x-5,y-5,x+5,y+5]
            root_colliders.append({
                "id":prop["id"],"bbox":r,"foot":foot,
                "source":record["filename"],"original_manifest_blocking":True,
                "coverage":"NARROW_ROOT_SAMPLE_NOT_FULL_TREE_COLLISION"
            })
    if len(new_source_metadata)!=5 or len(new_owners)!=3 or len(root_colliders)!=2:
        raise AssertionError("C7 source semantics not 5 source props / 3 roof-crown / 2 blocking trunks")
    # Recompose all C7 pixels in one RGB source to ensure alpha remains honest.
    master=Image.alpha_composite(ground.convert("RGBA"),par).convert("RGB")
    save={
        "MASTER.png":master,
        "Authoring_GroundOnly.png":ground,
        "Authoring_CompletePAR.png":par,
        "Runtime_FullGround.png":master,
    }
    for name,img in save.items():img.save(out/name,optimize=True)
    union=Image.new("L",(WIDTH,HEIGHT),0)
    for own in owners:
        path=out/"occlusion_owners"/own["file"]
        alpha=Image.open(path).convert("RGBA").getchannel("A")
        Image.merge("RGBA",(*master.split(),alpha)).save(path,optimize=True)
        own["sha256"]=checksum(path)
        union=ImageChops.lighter(union,alpha)
    for own in new_owners:
        alpha=overlay_alphas[own["id"]]
        path=out/"occlusion_owners"/own["file"]
        Image.merge("RGBA",(*master.split(),alpha)).save(path,optimize=True)
        own["sha256"]=checksum(path)
        union=ImageChops.lighter(union,alpha)
    owners.extend(new_owners)
    Image.merge("RGBA",(*master.split(),union)).save(
        out/"Runtime_OcclusionPAR.png",optimize=True)
    (out/"TC_PILOT_OCCLUSION_OWNERS.json").write_text(
        json.dumps(owners,ensure_ascii=False,indent=2),encoding="utf8")
    (out/"TC_C7_ROOT_FOOTPRINTS.json").write_text(
        json.dumps({"colliders":root_colliders,"landmark_blocking":False,
            "C5_cottages_unchanged":True,
            "source_contract":"A36G R4 manifest blocking; 2 trees yes, waymarker/rock/shrub no",
            "full_collision_of_historical_trees":"ART_NAV_HOLD"},ensure_ascii=False,indent=2),
        encoding="utf8")
    (out/"TC_C7_PUBLIC_SOURCE_OBJECTS.json").write_text(
        json.dumps(new_source_metadata,ensure_ascii=False,indent=2),encoding="utf8")

    difference=ImageChops.difference(master,previous_master)
    bbox=difference.getbbox()
    if bbox is None or not (REGION[0]<=bbox[0] and REGION[1]<=bbox[1]
                            and bbox[2]<=REGION[2] and bbox[3]<=REGION[3]):
        raise AssertionError("C7 changed map outside selected whole 8x8 region: "+str(bbox))
    changed=sum(color != (0,0,0) for color in difference.crop(REGION).getdata())
    if changed < 1200:
        raise AssertionError("C7 source change too small to replace full group: "+str(changed))
    expected=Image.alpha_composite(ground.convert("RGBA"),par).convert("RGB")
    if ImageChops.difference(expected,master).getbbox() is not None:
        raise AssertionError("C7 ground+completepar!=master")
    if any(x["id"].startswith("TC_C6_") for x in owners):
        raise AssertionError("Old handmade C6 owner remained after C7 source replacement")
    # Side by side source-art comparison; official art still requires native 1x.
    left=previous_master.crop(REGION)
    right=master.crop(REGION)
    left.save(out/"TC_C7_PREVIOUS_C6_REGION_1X.png")
    right.save(out/"TC_C7_NEW_SOURCE_REGION_1X.png")
    pair=Image.new("RGB",(512,256))
    pair.paste(left,(0,0));pair.paste(right,(256,0))
    pair.save(out/"TC_C6_VS_C7_SOURCE_REGION_AB_1X.png")
    qa={
        "stage":"C7 replace all 5 handcrafted C6 props with real independent FS A36G R4 source sprites",
        "world_grid":[40,29],"canvas":[1280,928],
        "region_px":list(REGION),"region_grid":[8,8],
        "source_manifest_path":str(MANIFEST.relative_to(pilot.ROOT)),
        "source_manifest_sha256":checksum(MANIFEST),
        "sources":[x["source_path"] for x in new_source_metadata],
        "original_sha_verified_sources":5,
        "C6_handdrawn_props_remaining":0,
        "source_registered":"STATIC_PASS_MASTER_GROUND_COMPLETEPAR",
        "C5_house_colliders_preserved":2,
        "new_blocking_tree_roots":len(root_colliders),
        "new_nonblocking_original_landmarks_and_shrubs":3,
        "source_consistent_semantic_owners":len(owners),
        "native_picture_format":[1280,928],
        "full_scene_8x8_region_other_pixels_unchanged":True,
        "C6_ground_edits_preserved":True,
        "previous_c6_changed_px":old_c6_qa["region_changed_px"],
        "C7_new_source_delta_bbox":list(bbox),
        "C7_replaced_region_changed_px":changed,
        "PixelLab_new_generation":"NOT_RUN",
        "art_gate":"ART_HOLD_PENDING_TRUE_NATIVE_1X_REVIEW",
        "native_engine_QA":"PENDING",
        "files_sha256":{name:checksum(out/name) for name in
            ("MASTER.png","Authoring_GroundOnly.png","Authoring_CompletePAR.png",
             "Runtime_FullGround.png","Runtime_OcclusionPAR.png")},
        "known_limits":"Source files original R4 authored, not NEW PixelLab jobs; 2 tree root rectangles inferred from source foot (not full collision scan)."
    }
    (out/"TC_C7_SOURCE_QA.json").write_text(
       json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
    print(json.dumps({k:qa[k] for k in (
        "stage","C7_replaced_region_changed_px","original_sha_verified_sources",
        "C6_handdrawn_props_remaining","new_blocking_tree_roots",
        "source_consistent_semantic_owners","art_gate")},ensure_ascii=False))
    return qa

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--out",type=Path,required=True)
    parser.add_argument("--source",type=Path,default=pilot.SOURCE)
    args=parser.parse_args()
    build(args.out,args.source)
