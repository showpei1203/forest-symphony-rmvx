#!/usr/bin/env python3
"""T-C C8 independent-right-house candidate sourced from authentic R5 R2.

Uses R5 ONE complete author-generated PixelLab right gable house only. DOES NOT
reuse R5 failed Ground/PAR compositing scheme or claim R5 legacy art was approved.
Builds on C7 whole-image MASTER from C5/C6/C7, where right house is a mirror.
C8 removes that one C5 mirror and places the separate R5 complete sprite,
independent source hash-verified and transformed true authored footprint.
Godot 4.7.2 native approval required; ART formally HOLD.
"""
from __future__ import annotations
import argparse,hashlib,json
from pathlib import Path
from PIL import Image,ImageChops
import build_tc_village_pilot as pilot
import build_tc_village_style_c5 as c5
import build_tc_village_source_c7 as c7

W,H=1280,928
R5=pilot.ROOT/"experiments/route_b_25d_20261031_stage16/A36G_R5_R2_HOUSE_STYLE_20261104"
INPUT=R5/"SOURCE_INDEPENDENT_RGBA/A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png"
R5_QA=R5/"A36G_R5_R2_INTEGRATION_QA.json"
ID="TC_C8_INDEPENDENT_R5_SINGLE_GABLE_WOOD_COTTAGE"
PLACE=(791,371)
OLD_R5_ORIGIN=(743,376)
STYLE_ROI=(740,340,1040,650)
OLD_ID=c5.SECONDARY_ID

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def build(out,source=pilot.SOURCE):
    out.mkdir(parents=True,exist_ok=True)
    c7.build(out,source)
    baseline=Image.open(out/"MASTER.png").convert("RGB")
    ground=Image.open(out/"Authoring_GroundOnly.png").convert("RGBA")
    par=Image.open(out/"Authoring_CompletePAR.png").convert("RGBA")

    qa=json.loads(R5_QA.read_text("utf8"))
    if qa["right_new_source_size"] != [256,272]:
        raise AssertionError("R5 complete right original source dimensions not authoritative")
    if not INPUT.is_file() or sha(INPUT)!=qa["right_new_full_sprite_rgba_sha256"]:
        raise AssertionError("C8 true authored original R5 independent PixelLab right house SHA mismatch")
    new_house=Image.open(INPUT).convert("RGBA")
    if list(new_house.getchannel("A").getbbox())!=qa["right_source_rgba_bbox"]:
        raise AssertionError("C8 original authored RGBA transparency bbox changed")
    old_house=Image.open(out/"TC_C5_INDEPENDENT_WHOLE_HOUSE_RGBA.png").convert("RGBA")
    if old_house.size!=c5.NEW_SIZE:
        raise AssertionError("C5 mirror source to remove changed unexpectedly")
    # Remove the old *complete* C5 mirrored-house alpha; the underlying original
    # C5 Ground is never edited. Not a second R5 failed PAR overlay.
    owner_alpha=Image.new("L",(W,H),0)
    owner_alpha.paste(old_house.getchannel("A"),c5.NEW_ORIGIN)
    remaining_alpha=ImageChops.subtract(par.getchannel("A"),owner_alpha)
    par.putalpha(remaining_alpha)
    # Put truly independent R5 single-gable building, no rotation/piece stitch.
    par.alpha_composite(new_house,PLACE)
    dest=out/"TC_C8_REAL_R5_SINGLE_GABLE_HOUSE_RGBA.png"
    new_house.save(dest,optimize=True)
    master=Image.alpha_composite(ground,par).convert("RGB")
    for n,img in [
        ("MASTER.png",master),
        ("Authoring_CompletePAR.png",par),
        ("Runtime_FullGround.png",master)]:
        img.save(out/n,optimize=True)
    # GroundOnly stays byte-exact C7 (this is entirely a complete-house swap).
    former=json.loads((out/"TC_PILOT_OCCLUSION_OWNERS.json").read_text("utf8"))
    owner_removed=[o for o in former if o["id"]==OLD_ID]
    if len(owner_removed)!=1:
        raise AssertionError("Expected exact one full mirrored C5 house owner")
    owners=[o for o in former if o["id"]!=OLD_ID]
    union=Image.new("L",(W,H),0)
    for own in owners:
        f=out/"occlusion_owners"/own["file"]
        alpha=Image.open(f).convert("RGBA").getchannel("A")
        Image.merge("RGBA",(*master.split(),alpha)).save(f,optimize=True)
        own["sha256"]=sha(f)
        union=ImageChops.lighter(union,alpha)
    # New house roof alpha only; derive from whole original authentic source,
    # clipped before the actual authored footpoint, NOT blanket CompletePAR.
    dx=PLACE[0]-OLD_R5_ORIGIN[0];dy=PLACE[1]-OLD_R5_ORIGIN[1]
    foot=(qa["right_foot"][0]+dx,qa["right_foot"][1]+dy)
    cutoff=min(272,foot[1]-PLACE[1]-7)
    mask=Image.new("L",(W,H),0)
    mask.paste(new_house.getchannel("A").crop((0,0,256,cutoff)),PLACE)
    mask_file="owner_tc_c8_true_independent_house.png"
    fp=out/"occlusion_owners"/mask_file
    Image.merge("RGBA",(*master.split(),mask)).save(fp,optimize=True)
    union=ImageChops.lighter(union,mask)
    owners.append({
        "id":ID,"type":"house","foot_x":foot[0],"foot_y":foot[1],
        "file":mask_file,"bbox":list(mask.getbbox()),
        "sha256":sha(fp),"occlusion_pixels":sum(mask.histogram()[1:]),
        "independent_source":"TC_C8_REAL_R5_SINGLE_GABLE_HOUSE_RGBA.png",
        "original_source_sha256":sha(INPUT),
        "original_R5_author_foot":qa["right_foot"],
        "source_note":"Original authentic PixelLab R5 R2 complete single-gable building; R5 art seal FAIL preserved"
    })
    (out/"TC_PILOT_OCCLUSION_OWNERS.json").write_text(json.dumps(owners,ensure_ascii=False,indent=2),encoding="utf8")
    Image.merge("RGBA",(*master.split(),union)).save(out/"Runtime_OcclusionPAR.png",optimize=True)

    collision=json.loads((out/"TC_PILOT_COLLISION.json").read_text("utf8"))
    second=[x for x in collision["colliders"] if x["id"]==OLD_ID]
    if len(second)!=1 or len(collision["colliders"])!=2:
        raise AssertionError("Expected two C5 house physics objects, exactly one C5 mirror")
    authentic=qa["right_new_blocking_footprint_px"]
    translated=[authentic[0]+dx,authentic[1]+dy,
                authentic[2]+dx,authentic[3]+dy]
    collision["colliders"]=[
        x for x in collision["colliders"] if x["id"]!=OLD_ID
    ]+[{
        "id":ID,"type":"house_facade","bbox":translated,
        "source_original_R5_blocking_footprint_px":authentic,
        "independent_original_sha256":sha(INPUT),
        "semantic":"right complete wood house true source footblock"
    }]
    (out/"TC_PILOT_COLLISION.json").write_text(
        json.dumps(collision,ensure_ascii=False,indent=2),encoding="utf8")

    change=ImageChops.difference(baseline,master)
    bbox=change.getbbox()
    changed=sum(p!=(0,0,0) for p in change.crop(STYLE_ROI).getdata())
    if bbox is None or changed<1000 or not (
        STYLE_ROI[0]<=bbox[0] and STYLE_ROI[1]<=bbox[1]
        and bbox[2]<=STYLE_ROI[2] and bbox[3]<=STYLE_ROI[3]):
        raise AssertionError("C8 independent whole-house art must change only right whole-house ROI: "+str(bbox))
    if ImageChops.difference(
            Image.alpha_composite(ground,par).convert("RGB"),master).getbbox():
        raise AssertionError("C8 master and final authoring PAR differ")
    before=baseline.crop(STYLE_ROI)
    after=master.crop(STYLE_ROI)
    before.save(out/"TC_C8_PREVIOUS_MIRROR_HOUSE_1X.png",optimize=True)
    after.save(out/"TC_C8_NEW_COMPLETE_HOUSE_1X.png",optimize=True)
    contact=Image.new("RGB",(600,310))
    contact.paste(before,(0,0));contact.paste(after,(300,0))
    contact.save(out/"TC_C7_C8_INDEPENDENT_HOUSE_AB_1X.png",optimize=True)
    status={
        "stage":"C8 whole independently authored right-house R5 true source rescued without R5 failed layer scheme",
        "source":str(INPUT.relative_to(pilot.ROOT)),
        "source_sha256":sha(INPUT),
        "source_legacy_art_approved":False,
        "source_legacy_layer_approved":False,
        "new_PixelLab_generation":"NOT_RUN",
        "original_authored_house_size":[256,272],
        "complete_rgba_bbox":qa["right_source_rgba_bbox"],
        "new_full_source_origin":list(PLACE),
        "original_source_foot_R5":qa["right_foot"],
        "new_author_foot":list(foot),
        "new_house_footprint_px":translated,
        "old_mirrored_house_owner_removed":True,
        "independent_2_houses":True,
        "source_owners_total":len(owners),
        "C7_independent_region_owners_preserved":3,
        "C7_source_qa_preserved":(out/"TC_C7_SOURCE_QA.json").is_file(),
        "C8_modified_full_image_bbox":list(bbox),
        "C8_changed_region_pixels":changed,
        "canvas":[W,H],"grid":[40,29],
        "master_ground_par_registration":"STATIC_PASS",
        "art_gate":"ART_HOLD_ORIGINAL_FS_STYLE_REFERENCE_REQUIRED",
        "native_gate":"PENDING_GODOT472",
        "image_hashes":{n:sha(out/n) for n in (
            "MASTER.png","Authoring_GroundOnly.png","Authoring_CompletePAR.png",
            "Runtime_FullGround.png","Runtime_OcclusionPAR.png"
        )}
    }
    (out/"TC_C8_SOURCE_QA.json").write_text(
        json.dumps(status,ensure_ascii=False,indent=2),encoding="utf8")
    print(json.dumps({k:status[k] for k in (
        "stage","source_sha256","new_house_footprint_px",
        "C8_changed_region_pixels","source_owners_total","art_gate"
    )},ensure_ascii=False))
    return status

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--out",type=Path,required=True)
    parser.add_argument("--source",type=Path,default=pilot.SOURCE)
    args=parser.parse_args()
    build(args.out,args.source)
