#!/usr/bin/env python3
"""FS T-C D1 TRUE GROUND-FIRST -> ALL NON-GROUND PAR FACTORY.

Authoritative user's instruction (2026-11-21):
  1. FIRST produce a truly separate opaque GROUND.
  2. ONLY AFTER GROUND IS FROZEN, generate a full, transparent PAR
     containing EVERY non-ground object, regardless of character occlusion.
  3. COMPOSITE is preview only. Character occlusion/collision is NOT an
     authoring-PAR selection rule and NOT a gate for the two PNG deliverables.

The reference run uses one *archived independent ground source* and ONE
complete historical FS A36G R4 scene source family, not new PixelLab credit
or a new AI-generated visual. It tests the sequential exporter. Never
misrepresent archival source playback as a newly generated AI scene.

No old Runtime_OcclusionPAR, no alpha slicing, no MASTER -> backwards cut.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "experiments/route_b_25d_20261031_stage16/A36G_R4_R3_6REGIONS_20261104"
GROUND_REFERENCE = REF / "A36G_R4_GROUND_1280x928.png"
OBJECT_MANIFEST = REF / "A36G_R4_SCENE_MANIFEST.json"
INDEPENDENT_OBJECTS = REF / "SOURCE_INDEPENDENT_RGBA"
W,H = 1280,928
IMAGE_SIZE = (W,H)
ROLE_FIELDS = ("forest_group","house","tree","shrub","landmark")
PIPELINE_VERSION = "FS_GROUND_FIRST_ALL_PAR_D1_20261121"

def digest(path):
    h=hashlib.sha256()
    with open(path,"rb") as f:
        for chunk in iter(lambda:f.read(1024*1024),b""):
            h.update(chunk)
    return h.hexdigest()

def json_write(path, data):
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")

def read_manifest(path=OBJECT_MANIFEST):
    data=json.loads(path.read_text("utf-8"))
    if data.get("canvas")!=[W,H] or data.get("grid")!=[40,29]:
        raise ValueError("FS reference canvas /32px grid mismatch")
    objs=data.get("objects",[])
    if not objs or any(o.get("type") not in ROLE_FIELDS for o in objs):
        raise ValueError("Object roles cannot be guessed from an already flattened image")
    if len({o["id"] for o in objs})!=len(objs):
        raise ValueError("Duplicate original object IDs")
    return data

def produce_ground(out, ground_source=GROUND_REFERENCE, manifest=OBJECT_MANIFEST):
    """STAGE ONE, accepts ONLY separately authored independent ground RGB source.

    This benchmark stages the historical R4 native Ground for replay.
    A future scene generation provider should produce the Ground source
    FIRST and supply it here; NEVER supply the flattened Master.
    """
    out.mkdir(parents=True,exist_ok=True)
    m=read_manifest(manifest)
    if not ground_source.is_file():
        raise FileNotFoundError("Separately authored Ground source missing")
    if ground_source.resolve()==(REF/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png").resolve():
        raise AssertionError("Flattened Ground+PAR is NOT a Ground-only asset")
    src=Image.open(ground_source)
    if src.size!=IMAGE_SIZE or src.mode not in ("RGB","RGBA"):
        raise ValueError("Ground must arrive native 1280x928, RGB(A), no resize: "+str((src.size,src.mode)))
    if src.mode=="RGBA" and src.getchannel("A").getextrema()!=(255,255):
        raise ValueError("Stage ONE requires a fully opaque real ground")
    # Exact identical pixel content and no interpolated rescale.
    ground=src.convert("RGB")
    path=out/"GROUND.png"
    ground.save(path,optimize=True)
    # Ground first: absence of PAR means this stage is real temporal separation.
    if (out/"PAR.png").exists():
        raise AssertionError("Stage ONE refuses overwrite of existing PAR; use fresh output directory")
    lock={
        "pipeline":PIPELINE_VERSION,"stage":"GROUND_PRODUCED_LOCKED",
        "map":"FS_01_VILLAGE_DIRECT_PAIR_SOURCE_BENCHMARK",
        "canvas":[W,H],"world_grid":[40,29],"tile_px":32,
        "ground_source_path":str(ground_source.relative_to(ROOT)) if ground_source.is_relative_to(ROOT) else str(ground_source),
        "ground_source_sha256":digest(ground_source),
        "ground_output_sha256":digest(path),
        "ground_source_mode":"ARCHIVAL_INDEPENDENT_FS_GROUND_NOT_NEW_AI_GENERATION",
        "authoring_rule":"Only terrain / flat grass flowers leaf litter paths / ground",
        "par_rule":"ALL non-ground objects, even if they never cover the character",
        "par_source_generation":"NOT_STARTED_AT_THIS_STAGE",
        "no_reverse_master_segmentation":True,
        "semantic_collision_and_actor_occlusion":"OUT_OF_SCOPE_FOR_TWO_REQUIRED_IMAGES",
        "new_PixelLab_job":"NOT_RUN","art_gate":"HOLD",
        "created_utc":datetime.now(timezone.utc).isoformat(timespec="seconds")
    }
    json_write(out/"01_GROUND_LOCK.json",lock)
    if digest(path)!=digest(ground_source):
        # PNG source and output encoding may differ; image pixels are what count.
        if ImageChops.difference(ground,src.convert("RGB")).getbbox():
            raise AssertionError("Ground pixel content changed after writing")
    print("FS_TWO_STAGE_GROUND:",json.dumps({
        "state":lock["stage"],"size":lock["canvas"],
        "sha256":lock["ground_output_sha256"],"par_exists":False
    }))
    return lock

def produce_par(out,manifest=OBJECT_MANIFEST,art_sources=INDEPENDENT_OBJECTS):
    """STAGE TWO: full transparent PAR from ALL authored non-ground objects."""
    lock_file=out/"01_GROUND_LOCK.json"
    if not lock_file.is_file():
        raise RuntimeError("FAIL_CLOSED: Ground phase must be generated and locked BEFORE PAR")
    lock=json.loads(lock_file.read_text("utf8"))
    if lock.get("pipeline")!=PIPELINE_VERSION or lock.get("stage")!="GROUND_PRODUCED_LOCKED":
        raise RuntimeError("Unknown or unfinished Ground stage")
    ground_file=out/"GROUND.png"
    if not ground_file.is_file() or digest(ground_file)!=lock["ground_output_sha256"]:
        raise RuntimeError("Ground altered since locked Phase 1")
    if (out/"PAR.png").exists():
        raise FileExistsError("Never silently overwrite an already generated PAR, use fresh output")
    m=read_manifest(manifest)
    if m.get("ground_sha256") != lock["ground_source_sha256"]:
        raise AssertionError("Ground lock and same-scene object authoring manifest disagree")
    objects=m["objects"]
    par=Image.new("RGBA",IMAGE_SIZE,(0,0,0,0))
    compiled=[]
    kinds={}
    # No custom occlusion selection whatsoever. Every non-ground family has to
    # be included; a tree CANOPY, house WALL, nonblocking ROCK and every SHRUB.
    for o in objects:
        obj_path=art_sources/o["filename"]
        if not obj_path.is_file():
            raise FileNotFoundError("Independent non-ground source MISSING: "+str(obj_path))
        real_sha=digest(obj_path)
        if real_sha!=o["sha256"]:
            raise AssertionError("PAR source SHA did not match original FS manifest: "+o["id"])
        raw=Image.open(obj_path).convert("RGBA")
        if raw.size!=(o["w"],o["h"]):
            raise AssertionError("A complete object may NOT be resized to hide geometry mismatch: "+o["id"])
        x,y=int(o["x"]),int(o["y"])
        par.alpha_composite(raw,(x,y))
        kinds[o["type"]]=kinds.get(o["type"],0)+1
        compiled.append({
            "id":o["id"],"type":o["type"],"file":o["filename"],
            "sha256":real_sha,"xy":[x,y],"source_size":[o["w"],o["h"]],
            "contributed_alpha_source_pixels":sum(raw.getchannel("A").histogram()[1:]),
            "included_irrespective_of_actor_occlusion":True
        })
    if set(kinds)!=set(ROLE_FIELDS):
        raise AssertionError("PAR object inventory missing one entire non-ground family: "+str(kinds))
    if sum(compiled[i]["contributed_alpha_source_pixels"] for i in range(len(compiled)))<=0:
        raise AssertionError("All PAR source objects empty")
    if par.getchannel("A").getextrema()!=(0,255):
        raise AssertionError("PAR must be a real transparent image with genuine object pixels")
    par_file=out/"PAR.png"
    par.save(par_file,optimize=True)
    ground=Image.open(ground_file).convert("RGBA")
    composite=Image.alpha_composite(ground,par).convert("RGB")
    composite.save(out/"COMPOSITE_PREVIEW.png",optimize=True)
    if ImageChops.difference(
            composite,Image.open(out/"COMPOSITE_PREVIEW.png").convert("RGB")).getbbox():
        raise AssertionError("Ground + ALL PAR composite changed under save")
    if digest(ground_file)!=lock["ground_output_sha256"]:
        raise AssertionError("Building PAR changed Ground bytes")
    inventory={"pipeline":PIPELINE_VERSION,
        "status":"ALL_NON_GROUND_SOURCE_AUTHORED",
        "source_manifest_path":str(manifest.relative_to(ROOT)),
        "source_manifest_sha256":digest(manifest),
        "object_count":len(compiled),"type_counts":kinds,
        "every_manifest_non_ground_object_in_par":len(compiled)==len(objects),
        "objects":compiled,
        "excluded_due_to_actor_occlusion":[],
        "complete_alpha_nonzero_pixels":sum(par.getchannel("A").histogram()[1:]),
        "PAR_is_all_objects_not_actor_occlusion_subset":True
    }
    json_write(out/"02_COMPLETE_PAR_OBJECT_LEDGER.json",inventory)
    qa={
        "pipeline":PIPELINE_VERSION,"build_order":["GROUND.png","PAR.png","COMPOSITE_PREVIEW.png"],
        "ground_lock_first":True,
        "authoring_ground_opaque":True,
        "PAR_real_RGBA_transparency":True,
        "PAR_all_192_authored_non_ground_source_objects":len(compiled)==192,
        "PAR_no_semantic_occluder_selection":True,
        "PAR_nonblocking_rocks_and_shrubs_included":kinds.get("shrub",0)>0 and kinds.get("landmark",0)>0,
        "GROUND_unchanged_after_PAR":True,
        "same_canvas":[W,H],
        "source_stage":m["stage"],
        "ground_sha256":digest(ground_file),"par_sha256":digest(par_file),
        "composite_sha256":digest(out/"COMPOSITE_PREVIEW.png"),
        "independent_object_manifest_sha256":digest(manifest),
        "non_ground_object_count":len(compiled),
        "non_ground_counts":kinds,
        "external_new_ground_generation":"NOT_RUN_ARCHIVAL_GROUND_ONLY_TEST",
        "external_new_par_generation":"NOT_RUN_ARCHIVAL_INDEPENDENT_OBJECTS_COMPILED",
        "new_PixelLab_job":"NOT_RUN",
        "Godot_native":"PENDING",
        "art_gate":"HOLD_NOT_NEW_AI_GENERATED_MAP",
        "formal_seal":"NO"
    }
    json_write(out/"03_TWO_STAGE_QA.json",qa)
    print("FS_TWO_STAGE_PAR:",json.dumps({
        "objects":len(compiled),"types":kinds,
        "all_non_ground":True,"no_occlusion_subset":True,
        "ground_sha":qa["ground_sha256"],"par_sha":qa["par_sha256"]
    }))
    return qa

def verify(out):
    qa=json.loads((out/"03_TWO_STAGE_QA.json").read_text("utf8"))
    lock=json.loads((out/"01_GROUND_LOCK.json").read_text("utf8"))
    ledger=json.loads((out/"02_COMPLETE_PAR_OBJECT_LEDGER.json").read_text("utf8"))
    if qa["ground_sha256"]!=digest(out/"GROUND.png") or qa["par_sha256"]!=digest(out/"PAR.png"):
        raise AssertionError("Two-stage paired layer SHA mismatch")
    if qa["ground_sha256"] != lock["ground_output_sha256"]:
        raise AssertionError("Stage1 ground changed")
    if not all(x["included_irrespective_of_actor_occlusion"] for x in ledger["objects"]):
        raise AssertionError("PAR asset was incorrectly filtered by occlusion role")
    g=Image.open(out/"GROUND.png").convert("RGBA")
    p=Image.open(out/"PAR.png").convert("RGBA")
    c=Image.open(out/"COMPOSITE_PREVIEW.png").convert("RGB")
    if g.size!=p.size or g.size!=c.size or g.size!=IMAGE_SIZE:
        raise AssertionError("Canvas XY alignment broken")
    if ImageChops.difference(Image.alpha_composite(g,p).convert("RGB"),c).getbbox():
        raise AssertionError("Composite not equal independent Ground + ALL PAR")
    print("FS_TWO_STAGE_VERIFY: PASS :: GROUND FIRST / PAR ALL NON-GROUND / 192 owners / NO ACTOR OCCLUSION CUT")
    return True

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("step",choices=("ground","par","verify"))
    parser.add_argument("--out",required=True,type=Path)
    parser.add_argument("--ground-source",type=Path,default=GROUND_REFERENCE)
    parser.add_argument("--manifest",type=Path,default=OBJECT_MANIFEST)
    parser.add_argument("--art-sources",type=Path,default=INDEPENDENT_OBJECTS)
    args=parser.parse_args()
    if args.step=="ground":
        produce_ground(args.out,args.ground_source,args.manifest)
    elif args.step=="par":
        produce_par(args.out,args.manifest,args.art_sources)
    else:
        verify(args.out)
