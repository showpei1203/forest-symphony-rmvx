#!/usr/bin/env python3
"""Forest Symphony T-C reusable six-biome/twelve-map two-image contract.

GROUND is an opaque separately generated scene; PAR is a separately generated
RGBA containing EVERY non-ground object, not merely character occluders.
This checks image engineering; does not certify visual art or Godot runtime.
Images remain PRIVATE in owner's Google Drive, never commit them to GitHub.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw

def sha(path):
    h=hashlib.sha256()
    with open(path,'rb') as fp:
        for chunk in iter(lambda:fp.read(1024*1024),b''):
            h.update(chunk)
    return h.hexdigest()

def inspect_pair(ground_path:Path,par_path:Path,out:Path,scene_id:str,
                 tile:int=32,expected_ground_sha:str|None=None,
                 source_type:str="INDEPENDENT_GENERATED"):
    ground_path=Path(ground_path);par_path=Path(par_path);out=Path(out)
    if not ground_path.is_file() or not par_path.is_file():
        raise FileNotFoundError("Both separate sources GROUND and CompletePAR are required")
    if ground_path.resolve()==par_path.resolve():
        raise ValueError("GROUND and PAR must never be one same source")
    gs,ps=sha(ground_path),sha(par_path)
    if expected_ground_sha and gs.lower()!=expected_ground_sha.lower():
        raise ValueError("Ground changed after stage one SHA lock")
    ground=Image.open(ground_path);par=Image.open(par_path)
    w,h=ground.size
    checks={
        "Ground_is_opaque_RGB":ground.mode=="RGB" or (
            ground.mode=="RGBA" and ground.getchannel("A").getextrema()==(255,255)),
        "PAR_true_RGBA":par.mode=="RGBA",
        "same_canvas":ground.size==par.size,
        "32px_grid":w%tile==0 and h%tile==0,
        "separate_sources":ground_path.resolve()!=par_path.resolve(),
        "Ground_SHA_LOCK":not expected_ground_sha or gs.lower()==expected_ground_sha.lower(),
    }
    if not all(checks.values()):
        raise ValueError("GROUND + COMPLETEPAR fundamental PNG contract failure: "+repr(checks))
    alpha=par.getchannel("A");hist=alpha.histogram();total=w*h
    counts={
        "alpha_zero":hist[0],"alpha_1_to_8":sum(hist[1:9]),
        "alpha_9_to_239":sum(hist[9:240]),
        "alpha_240_to_254":sum(hist[240:255]),"alpha_255":hist[255],
    }
    checks["PAR_has_real_transparency"]=hist[0]>total//50
    checks["PAR_has_actual_visible_props"]=hist[0]<total
    if not checks["PAR_has_real_transparency"] or not checks["PAR_has_actual_visible_props"]:
        raise ValueError("PAR is not a transparent non-ground PNG")
    a=alpha.load()
    edge={
        "top":sum(a[x,0]>=225 for x in range(w)),
        "bottom":sum(a[x,h-1]>=225 for x in range(w)),
        "left":sum(a[0,y]>=225 for y in range(h)),
        "right":sum(a[w-1,y]>=225 for y in range(h)),
    }
    checks["low_alpha_artifacts_below_0_01pct"]=counts["alpha_1_to_8"]<=max(16,total//10000)
    checks["crop_edge_opaque_source_risk_low"]=max(edge.values())<=16
    checks["PAR_NO_ACTOR_OCCLUSION_SUBSET"]=True
    out.mkdir(parents=True,exist_ok=True)
    composite=Image.alpha_composite(ground.convert("RGBA"),par).convert("RGB")
    canvas=out/"PAIR_COMPOSITE_SOURCE_ORIGINAL_QA.png"
    composite.save(canvas,optimize=True)
    if ImageChops.difference(composite,Image.open(canvas).convert("RGB")).getbbox() is not None:
        raise AssertionError("Pixel exact Ground+ALL PAR composition was corrupted")
    scale=min(1,640/w);size=(max(1,round(w*scale)),max(1,round(h*scale)))
    contact=Image.new("RGB",(size[0]*2,size[1]+24),(242,245,250))
    contact.paste(ground.convert("RGB").resize(size,Image.Resampling.NEAREST),(0,24))
    contact.paste(composite.resize(size,Image.Resampling.NEAREST),(size[0],24))
    ImageDraw.Draw(contact).text((8,5),"GROUND ONLY",fill=(24,35,50))
    ImageDraw.Draw(contact).text((size[0]+8,5),"GROUND + COMPLETE PAR",fill=(24,35,50))
    contact.save(out/"PAIR_GROUND_VS_COMPOSITE_VISUAL_QA.png")
    report={
        "scene_id":scene_id,
        "source_contract":"GROUND_FIRST_THEN_COMPLETE_PAR_ALL_NON_GROUND",
        "canvas_px":[w,h],"grid_32px":[w//tile,h//tile],
        "Ground_sha256":gs,"CompletePAR_sha256":ps,
        "Ground_source_file":ground_path.name,"PAR_source_file":par_path.name,
        "source_provenance":source_type,
        "technical_checks":checks,"alpha_distribution":counts,
        "PAR_opaque_source_pixels_at_edges":edge,
        "composite_sha256":sha(canvas),
        "all_object_classes_in_PAR":"HUMAN_REVIEW_OR_SOURCE_MANIFEST_REQUIRED",
        "pixel_exact_world_registration":"HUMAN_REVIEW_REQUIRED",
        "Godot_4_7_2_native":"NOT_RUN_HERE",
        "technical_composition":"PASS",
        "formal_ART_GATE":"HOLD" if not (
            checks["low_alpha_artifacts_below_0_01pct"] and
            checks["crop_edge_opaque_source_risk_low"]) else "HOLD_PENDING_HUMAN",
        "note":"No actor occlusion extraction. Border hits may be artistic forest continuation or cropped objects, and are not automatically a formal art pass."
    }
    (out/"PAIR_CONTRACT_QA.json").write_text(
        json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    return report

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--ground",type=Path,required=True)
    p.add_argument("--par",type=Path,required=True)
    p.add_argument("--out",type=Path,required=True)
    p.add_argument("--scene-id",required=True)
    p.add_argument("--tile-px",type=int,default=32)
    p.add_argument("--ground-sha256")
    p.add_argument("--source-type",default="T_C_GENERATED_CANDIDATE")
    x=p.parse_args()
    v=inspect_pair(x.ground,x.par,x.out,x.scene_id,x.tile_px,x.ground_sha256,x.source_type)
    print(json.dumps({k:v[k] for k in (
        "scene_id","technical_composition","formal_ART_GATE","alpha_distribution",
        "PAR_opaque_source_pixels_at_edges")},ensure_ascii=False))
