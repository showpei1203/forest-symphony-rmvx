#!/usr/bin/env python3
"""FS A35 R8: deterministic, source-accurate tree canopy occluder polygons.

Read all 175 authored tree PNG sprites from owner-only R7 ZIP and derive
source-alpha canopy contours. This is an image-to-geometry tool, not a map
renderer. Shape profiles preserve original footpoint coordinate convention.
"""
import argparse, hashlib, io, json, zipfile
from pathlib import Path
import numpy as np
from PIL import Image

BASE="FS_A35_R7_SHADOW_SOURCE_PRIVATE_20261115.zip"
GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
def digest(x):return hashlib.sha256(x).hexdigest()

def extract(source_png:bytes):
    img=Image.open(io.BytesIO(source_png)).convert("RGBA")
    arr=np.asarray(img, dtype=np.uint8)
    h,w=arr.shape[:2]
    alpha=arr[:,:,3]>140
    ys=np.flatnonzero(alpha.any(axis=1))
    if len(ys)<15:raise ValueError("Artwork has insufficient alpha")
    start=int(ys[0]);end=int(ys[-1])
    top=int(start+max(2,(end-start)*0.025))
    bottom=min(end-14,int(start+(end-start)*0.76))
    if bottom-top<12:raise ValueError("Not enough canopy space")
    interval=max(4,int((bottom-top)/14))
    positions=sorted(set([top]+list(range(top+interval,bottom,interval))+[bottom]))
    left=[];right=[]
    green=np.asarray(arr[:,:,:3],dtype=np.float32)
    leaf=(alpha & (green[:,:,1]>green[:,:,0]*.70) &
           (green[:,:,1]>green[:,:,2]*.77))
    for y in positions:
        ids=np.flatnonzero(leaf[max(0,y-1):min(h,y+2)].any(axis=0))
        if len(ids)<8:
            ids=np.flatnonzero(alpha[max(0,y-1):min(h,y+2)].any(axis=0))
        if len(ids)<5:continue
        # 5th to 95th percentile protects against single stray leaf pixels.
        l=float(np.percentile(ids,4))
        r=float(np.percentile(ids,96))
        if r-l<6:continue
        left.append([round(l - w/2.0 + 2,2),round(y-h+1.0,2)])
        right.append([round(r - w/2.0 - 2,2),round(y-h+1.0,2)])
    if len(left)<4:raise ValueError("Canopy contour too sparse")
    vertices=left+right[::-1]
    # Non-self intersecting monotonic Y outline, rectangle never used as substitute.
    for row in range(len(left)):
        if left[row][0]>=right[row][0]:raise ValueError("Invalid narrow canopy contour")
    if len(vertices)>48:raise ValueError("Excessive vertex budget")
    bbox=img.getbbox()
    return {"polygon":vertices,"canvas":[w,h],"original_bbox":list(bbox),
            "canopy_row_span":[top,bottom],"vertices":len(vertices),
            "sprite_sha256":digest(source_png)}

def build(source:Path,output:Path):
    with zipfile.ZipFile(source) as z:
        if z.testzip():raise ValueError("R7 source CRC failure")
        if digest(z.read("private_assets/ground_only.png"))!=GROUND:
            raise ValueError("Original Ground modified")
        manifest=json.loads(z.read("data/a35_r6_conifer_manifest.json"))
        trees=[o for o in manifest["objects"] if o["semantic"]=="tree"]
        if len(trees)!=175:raise ValueError("Not 175 canonical trees")
        profiles={}
        assignment={}
        for o in trees:
            asset=manifest["assets"][o["asset_id"]]
            path=asset["file"]
            if path not in profiles:
                profiles[path]=extract(z.read(path))
            assignment[o["id"]]=path
        if len(assignment)!=175:raise ValueError("Duplicate original owner IDs")
    result={"schema":"FS_A35_R8_CANOPY_PROFILES_V1",
      "extraction":"authored sprite alpha; green/alpha row percentile contour; top ~76 percent; 4-96 percentile",
      "coordinate_space":"owner-local, Sprite2D centered=false position=(-width/2,-height+1)",
      "tree_instances":175,"source_profiles":len(profiles),
      "total_polygon_vertices":sum(len(profiles[p]["polygon"]) for p in assignment.values()),
      "source_owner_image_sha_validation":True,
      "source_zip_sha256":digest(source.read_bytes()),"original_ground_sha256":GROUND,
      "profiles":profiles,"owners":assignment}
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(result,ensure_ascii=False,separators=(",",":")),encoding="utf-8")
    print(json.dumps({k:v for k,v in result.items() if k not in ("profiles","owners")},indent=2))
    print("R8_PROFILE_SOURCE_BYTES",output.stat().st_size)
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--source",required=True)
    p.add_argument("--output",required=True)
    a=p.parse_args();build(Path(a.source),Path(a.output))
