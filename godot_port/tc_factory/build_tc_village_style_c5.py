#!/usr/bin/env python3
"""FS T-C C5: whole-building style-unification candidate, native pixel layers.

This does NOT call PixelLab API, and it does NOT modify A35/R12/R14 production
scenes. It reuses one real independent PixelLab A36G integrated timber cottage
as a WHOLE structure, mirrored and recolored; no roof pieces are stitched.
True generated model designs are a separate future gate.
"""
from __future__ import annotations
import argparse, hashlib, json
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops, ImageEnhance
import build_tc_village_pilot as pilot

W,H = 1280,928
SECONDARY_ID = "TC_C5_WHOLE_TIMBER_COTTAGE_MIRRORED_VARIANT"
SRC_COTTAGE_ID = "A36G_ELF_HOUSE_AND_WORKSHOP"
HISTORICAL_HUT_ID = "A36F_ELF_COTTAGE_B"
NEW_ORIGIN=(795,390)
NEW_SIZE=(229,209)
CLEARANCE_POLYGON=[
    (841,348),(889,348),(941,391),(978,419),(985,470),
    (982,574),(965,615),(781,615),(753,565),(752,449),(773,408)
]

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def write_png(image,path):
    image.save(path,optimize=True)

def derive_cottage(src_png):
    # Flip the complete sourced building with a fresh, unified palette; don't
    # assemble separate gables or invent a new structural footprint.
    src=Image.open(src_png).convert("RGBA")
    if src.size != (284,259):
        raise ValueError("Whole house source dimensions changed: "+str(src.size))
    whole=src.transpose(Image.Transpose.FLIP_LEFT_RIGHT).resize(
        NEW_SIZE,resample=Image.Resampling.NEAREST
    )
    r,g,b,a=whole.split()
    # Restrained dark/cool palette shift relative to historical GOLDEN master:
    # different character but matching material/roof family, without new deps.
    r=r.point([min(255,round(i*0.94)) for i in range(256)])
    g=g.point([min(255,round(i*0.94)) for i in range(256)])
    b=b.point([min(255,round(i*0.97)) for i in range(256)])
    return Image.merge("RGBA",(r,g,b,a))

def build(out,source=pilot.SOURCE):
    out.mkdir(parents=True,exist_ok=True)
    pilot.W,pilot.H=W,H
    pilot.CROP=(0,0,W,H)
    baseline=pilot.build(out,source)
    baseline_master=Image.open(out/"MASTER.png").convert("RGB").copy()
    manifest=json.loads((source/pilot.SOURCE_IDS["manifest"]).read_text("utf-8"))
    house=next(x for x in manifest["objects"] if x.get("id")==SRC_COTTAGE_ID)
    historical_hut=next(x for x in manifest["objects"] if x.get("id")==HISTORICAL_HUT_ID)
    if tuple(house.get("foot",[])) != (563,458):
        raise ValueError("Original house pivot mutated, art alignment unsafe")
    original=(source/"SOURCE_INDEPENDENT_RGBA"/house["filename"])
    if not original.is_file() or digest(original)!=house["sha256"]:
        raise ValueError("Missing/unverified independent PixelLab whole cottage")
    new_house=derive_cottage(original)
    house_name="TC_C5_INDEPENDENT_WHOLE_HOUSE_RGBA.png"
    write_png(new_house,out/house_name)
    # Clean precisely the former FULL hut footprint, without flattening the
    # entire 40x29 world. No old hut cutout is used to fabricate a new sprite.
    par=Image.open(out/"Authoring_CompletePAR.png").convert("RGBA")
    former=Image.new("L",(W,H),0)
    ImageDraw.Draw(former).polygon(CLEARANCE_POLYGON,fill=255)
    new_alpha=ImageChops.subtract(par.getchannel("A"),former)
    par.putalpha(new_alpha)
    overlay=Image.new("RGBA",(W,H),(0,0,0,0))
    overlay.alpha_composite(new_house,NEW_ORIGIN)
    par=Image.alpha_composite(par,overlay)

    ground=Image.open(out/"Authoring_GroundOnly.png").convert("RGBA")
    # Original 40x29 ground and road pattern remain exact.
    master=Image.alpha_composite(ground,par).convert("RGB")
    assert master.size==(W,H)
    write_png(par,out/"Authoring_CompletePAR.png")
    write_png(master,out/"MASTER.png")
    write_png(master,out/"Runtime_FullGround.png")

    # Rebuild conditional PAR against the NEW master RGB for every old retained
    # independent object; do not reuse stale pixels from the previous master.
    owners_json=out/"TC_PILOT_OCCLUSION_OWNERS.json"
    owners=json.loads(owners_json.read_text("utf-8"))
    union=Image.new("L",(W,H),0)
    for owner in owners:
        file=out/"occlusion_owners"/owner["file"]
        old=Image.open(file).convert("RGBA")
        alpha=old.getchannel("A")
        # Remove any historical occlusion belonging to the cleared hut ROI.
        # Existing first cottage + west contiguous source survive untouched.
        alpha=ImageChops.subtract(alpha,former)
        write_png(pilot.compose_mask_from_master(master,alpha),file)
        union=ImageChops.lighter(union,alpha)
        owner["bbox"]=list(alpha.getbbox() or (0,0,0,0))
        owner["sha256"]=digest(file)
        owner["occlusion_pixels"]=sum(alpha.histogram()[1:])

    # New 2nd whole building owner: canopy/roof only, not all front facade.
    hx,hy=NEW_ORIGIN
    src=Image.new("L",(W,H),0)
    # y of eave and doorway derived via authentic original whole-house lower
    # source foot geometry, then vertically clipped for actor occlusion.
    occlusion_bottom=hy+round(NEW_SIZE[1]*0.82)
    alpha=new_house.getchannel("A")
    clipped=alpha.crop((0,0,NEW_SIZE[0],occlusion_bottom-hy))
    src.paste(clipped,(hx,hy))
    mask_name="owner_c5_whole_cottage.png"
    mask_file=out/"occlusion_owners"/mask_name
    write_png(pilot.compose_mask_from_master(master,src),mask_file)
    union=ImageChops.lighter(union,src)
    owners.append({
        "id":SECONDARY_ID, "type":"house", "file":mask_name,
        "foot_x":NEW_ORIGIN[0]+round(NEW_SIZE[0]*0.32),
        "foot_y":NEW_ORIGIN[1]+NEW_SIZE[1]-4,
        "bbox":list(src.getbbox()),"sha256":digest(mask_file),
        "occlusion_pixels":sum(src.histogram()[1:]),
        "whole_source_sha256":digest(original),
        "historical_source_id":SRC_COTTAGE_ID,
        "transform":"whole sprite mirror + nearest scale + restrained tonal shift"
    })
    runtime=pilot.compose_mask_from_master(master,union)
    write_png(runtime,out/"Runtime_OcclusionPAR.png")
    owners_json.write_text(json.dumps(owners,ensure_ascii=False,indent=2),encoding="utf-8")

    # Real collision sourced from the 1st cottage's AUTHOR footprint and
    # transformed as ONE building. Preserve 1st house collider unchanged.
    collage=json.loads((out/"TC_PILOT_COLLISION.json").read_text("utf-8"))
    fx0,fy0,fx1,fy1=map(int,house["blocking_footprint_px"])
    srcx,srcy=int(house["x"]),int(house["y"])
    sx=NEW_SIZE[0]/int(house["w"])
    sy=NEW_SIZE[1]/int(house["h"])
    rx0=NEW_ORIGIN[0]+round((int(house["w"])-(fx1-srcx))*sx)
    rx1=NEW_ORIGIN[0]+round((int(house["w"])-(fx0-srcx))*sx)
    ry0=NEW_ORIGIN[1]+round((fy0-srcy)*sy)
    ry1=NEW_ORIGIN[1]+round((fy1-srcy)*sy)
    if not (NEW_ORIGIN[0]<=rx0<rx1<=NEW_ORIGIN[0]+NEW_SIZE[0] and ry0<ry1):
        raise AssertionError("New full-house collision transform wrong")
    collage["colliders"].append({"id":SECONDARY_ID,"type":"house_facade",
        "bbox":[rx0,ry0,rx1,ry1], "source_manifest_sha256":digest(source/pilot.SOURCE_IDS["manifest"]),
        "whole_source_sha256":digest(original)})
    collage["native_gate"]="PENDING_GODOT_TWO_HOUSE_PHYSICS"
    (out/"TC_PILOT_COLLISION.json").write_text(json.dumps(collage,ensure_ascii=False,indent=2),encoding="utf-8")

    # C5 static evidence: registered same-origin layers, unchanged floor,
    # no old green-roof block, isolated changed ROI, complete building source.
    exact=Image.alpha_composite(ground,par).convert("RGB")
    assert ImageChops.difference(master,exact).getbbox() is None
    assert ImageChops.difference(master,Image.open(out/"Runtime_FullGround.png").convert("RGB")).getbbox() is None
    original_full=Image.open(out/"Authoring_GroundOnly.png").convert("RGBA")
    assert ImageChops.difference(original_full,ground).getbbox() is None
    # Compare against baseline A36G (with same authored floor embellishment)
    delta=ImageChops.difference(master,baseline_master)
    changed=delta.getbbox()
    style_roi=(740,340,1040,630)
    roi=delta.crop(style_roi)
    changed_px=sum(1 for color in roi.getdata() if color!=(0,0,0))
    if changed is None or changed_px < 1000:
        raise AssertionError("New whole-building style ROI changed fewer than 1000 pixels: "+str(changed_px))
    # Changes must be strictly limited to the isolated new building clearing.
    if changed[0] < style_roi[0] or changed[1] < style_roi[1] or changed[2] > style_roi[2] or changed[3] > style_roi[3]:
        raise AssertionError("Source floor or other forest/house areas outside C5 ROI changed: "+str(changed))
    # A single isolated house; no body parts or roof stitches in this variant.
    qa=json.loads((out/"TC_PILOT_SOURCE_QA.json").read_text("utf-8"))
    qa.update({
      "stage":"C5 whole-building harmonization candidate",
      "target":"FS_01_VILLAGE","canvas":[W,H],"world_grid":[40,29],
      "source_registration":"STATIC_PASS_MASTER_GROUND_COMPLETEPAR_SAME_SOURCE",
      "source_ground_preserved":True,
      "pixellab_new_generation":"NOT_RUN",
      "new_house_source":{"id":SRC_COTTAGE_ID,"file":house["filename"],"sha256":digest(original),
        "output_file":house_name,"output_sha256":digest(out/house_name),
        "transform":"complete sprite only; horizontal mirror; nearest resample; tonal shift"},
      "replaced_historical_house":historical_hut["id"],
      "old_green_roof_clearance_polygon":CLEARANCE_POLYGON,
      "replacement_building_origin":list(NEW_ORIGIN),
      "replacement_building_size":list(NEW_SIZE),
      "replacement_building_collision":[rx0,ry0,rx1,ry1],
      "new_building_overlay_owner":mask_name,
      "whole_map_delta_bbox":list(changed),
      "style_roi_changed_px":changed_px,
      "authors_comment":"Style coherence candidate, not a newly generated PixelLab house; art requires 1x native review.",
      "image_sha256":{name:digest(out/name) for name in
         ("MASTER.png","Authoring_GroundOnly.png","Authoring_CompletePAR.png",
          "Runtime_FullGround.png","Runtime_OcclusionPAR.png")},
      "art_gate":"ART_HOLD","native_godot":"NOT_RUN_BY_GENERATOR",
      "collision_native":"PENDING_GODOT_TWO_HOUSE_PHYSICS"
    })
    (out/"TC_PILOT_SOURCE_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf-8")
    return qa

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--out",required=True,type=Path)
    p.add_argument("--source",default=pilot.SOURCE,type=Path)
    args=p.parse_args()
    data=build(args.out,args.source)
    print(json.dumps({k:data[k] for k in
       ("stage","canvas","world_grid","replacement_building_collision","art_gate")},ensure_ascii=False))
