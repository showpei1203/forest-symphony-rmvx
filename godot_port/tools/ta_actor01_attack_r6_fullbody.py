#!/usr/bin/env python3
"""T-A R6: source-locked A52 ATTACK12 articulated head/torso candidate.

Uses real A52 Body/Weapon/FX; creates a DIFFERENT, unapproved variant.
Preserves both boot region and exact 0.63 second F7 contact FX.
This is procedural pixel retarget, NOT PixelLab Skeleton v3 output.
Usage:
  TA_A52_SOURCE_DIR=/private/a52 TA_R6_OUTPUT_DIR=/private/r6 python ta_actor01_attack_r6_fullbody.py
File names in source dir: actor01_a52_body_12frames.png,
actor01_a52_weapon_12frames.png, actor01_a52_fx_12frames.png.
"""
from pathlib import Path
import hashlib
import json
import math
import os
import cv2
import numpy as np
from PIL import Image

ROOT = Path(os.environ.get("TA_A52_SOURCE_DIR", "/mnt/data"))
OUT = Path(os.environ.get("TA_R6_OUTPUT_DIR", str(ROOT / "TA_R6_attack_fullbody")))
ATLAS_SIZE = (256, 192)
SHA = {
    "body": "a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f",
    "weapon": "6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b",
    "fx": "46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c",
}
ANGLE = [0,-5,-9,-12,-13,-8,7,18,15,9,4,0]
VERTICAL = [0,-1,-2,-2,-2,-1,1,2,3,2,1,0]
TWIST = [0,-0.6,-1,-1.4,-1.7,-1,1,2.1,1.8,0.9,0.2,0]
WRIST = [(42,43),(41,40),(42,38),(43,36),(44,37),(45,39),
         (46,42),(45,44),(43,44),(40,43),(38,42),(42,43)]
RECOVERY_CONNECT = {8:-3, 9:-2, 10:-3}
XX, YY = np.meshgrid(np.arange(64,dtype=np.float32),np.arange(64,dtype=np.float32))

def hash_file(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def read_private_originals():
    result={}
    for key in ("body","weapon","fx"):
        p=ROOT / ("actor01_a52_%s_12frames.png" % key)
        if not p.exists() or hash_file(p)!=SHA[key]:
            raise RuntimeError("Private A52 source missing or SHA changed: "+key)
        image=Image.open(p).convert("RGBA")
        if image.size!=ATLAS_SIZE:
            raise RuntimeError("A52 source atlas shape invalid: "+key)
        result[key]=[np.array(image.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64)))
                     for i in range(12)]
    return result

def upper_body_warp(image, i):
    # Inverse nearest-neighbor articulated rotation about original hip (32,47).
    # The waist blends into an unchanged foot region.
    strength=np.clip((49.-YY)/14.,0.,1.)
    theta=math.radians(ANGLE[i])*strength
    c,s=np.cos(theta),np.sin(theta)
    dx=XX-32.;dy=YY-47.
    src_x=32.+dx*c-dy*s-TWIST[i]*np.clip((44.-YY)/19.,0.,1.)
    src_y=47.+dx*s+dy*c-VERTICAL[i]*strength
    transformed=cv2.remap(image,src_x.astype(np.float32),src_y.astype(np.float32),
                          cv2.INTER_NEAREST,borderMode=cv2.BORDER_CONSTANT,
                          borderValue=(0,0,0,0))
    transformed[51:,:,:]=image[51:,:,:]
    if (transformed[0,:,3].any() or transformed[-1,:,3].any()
        or transformed[:,0,3].any() or transformed[:,-1,3].any()):
        raise RuntimeError("R6 body clipped on frame "+str(i))
    return transformed

def shift(image, x, y):
    m=np.float32([[1,0,x],[0,1,y]])
    return cv2.warpAffine(image,m,(64,64),flags=cv2.INTER_NEAREST,
                          borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))

def weapon_wrist_retarget(image,i):
    wrist_x,wrist_y=WRIST[i]
    weight=max(0.,min(1.,(49.-wrist_y)/14.))
    angle=math.radians(ANGLE[i])*weight
    dx=round(-(wrist_y-47.)*math.sin(angle)+TWIST[i]*max(0.,(44.-wrist_y)/19.))
    dy=round(VERTICAL[i]*weight)
    dx+=RECOVERY_CONNECT.get(i,0)
    raw_ys,raw_xs=np.where(image[:,:,3]>0)
    if raw_xs.size:
        dx=min(dx,63-int(raw_xs.max()))
        dx=max(dx,-int(raw_xs.min()))
        dy=min(dy,63-int(raw_ys.max()))
        dy=max(dy,-int(raw_ys.min()))
    return shift(image,int(dx),int(dy))

def main():
    source=read_private_originals()
    OUT.mkdir(parents=True,exist_ok=True)
    outputs={"body":[],"weapon":[],"fx":[]}
    measures=[]
    for i in range(12):
        body=upper_body_warp(source["body"][i],i)
        weapon=weapon_wrist_retarget(source["weapon"][i],i)
        fx=shift(source["fx"][i],RECOVERY_CONNECT.get(i,0),0)
        assert np.array_equal(body[51:,:,:],source["body"][i][51:,:,:])
        if i==7:
            assert np.array_equal(fx,source["fx"][i]),"F7 impact source FX must be frozen"
        outputs["body"].append(body)
        outputs["weapon"].append(weapon)
        outputs["fx"].append(fx)
        measures.append({"frame":i,"head_pixels_changed":int(np.any(body[14:32]!=
                 source["body"][i][14:32],axis=2).sum()),
                 "torso_pixels_changed":int(np.any(body[32:45]!=
                 source["body"][i][32:45],axis=2).sum()),
                 "feet_same":True})
    file_sha={}
    for key,items in outputs.items():
        atlas=Image.new("RGBA",ATLAS_SIZE)
        for i,rgba in enumerate(items):
            atlas.paste(Image.fromarray(rgba),((i%4)*64,(i//4)*64))
        p=OUT/("ACTOR01_ATTACK12_R6_%s_ARTICULATED_CANDIDATE.png" % key.upper())
        atlas.save(p)
        file_sha[key]=hash_file(p)
    result={"stage":"R6 ART_HOLD","method":"procedural articulated pose retarget",
            "pixel_lab_new_job":"NOT RUN","source_sha":SHA,"output_sha":file_sha,
            "contact_second":0.63,"contact_frame":7,"feet_pivot":"A52 unchanged y51..63",
            "frames":measures}
    (OUT/"ACTOR01_ATTACK12_R6_REPRO_MANIFEST.json").write_text(
        json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(file_sha,sort_keys=True))
    print("TA_R6_ARTICULATED_CANDIDATE_CREATED; ART HOLD, gameplay untouched")

if __name__=="__main__":
    main()
