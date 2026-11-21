#!/usr/bin/env python3
"""T-A R5B: rebuild the 12-frame run from the REAL owner-private A35/A62 images.
Retains six unchanged PixelLab A35 keys + one unchanged A62 idle key, with
five NON-PIXELLAB deterministic optical in-betweens. Never claim model output.
Owner private PNGs must be staged locally in an isolated work folder, NOT GitHub.
"""
import argparse
import hashlib
import json
from pathlib import Path
import cv2
import numpy as np
from PIL import Image

SOURCES = {
    "run": "ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b",
    "idle": "70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e",
    "sword": "6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b",
}
HANDS = [(38,48),(38,48),(37,49),(42,41),(42,42),(42,42),
         (40,45),(37,47),(38,48),(39,46),(40,43),(39,46)]
EXPECTED = {
    "body": "122f306454157084115b8348d3c4b6af7aceadbe096b64a3bd28557e5ea34027",
    "weapon": "c829788d1ffe309488a9be6f9d8d937932b5b9fb82d89a12e192770a82dd68cd",
    "fx": "ef58c9f85c4dd5bf843466dffb5c06114c7286fa4d11f19191367e468799e2a7",
}

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def middle(a, b):
    # RGBA-aware, nearest-pixel flow interpolation. Never creates blended colors.
    def greyscale(x):
        bg = np.full_like(x[:,:,:3], (30,31,37))
        rgb = np.where(x[:,:,3:4]>0, x[:,:,:3], bg)
        return cv2.cvtColor(rgb.astype(np.uint8), cv2.COLOR_RGB2GRAY)
    ab = cv2.calcOpticalFlowFarneback(greyscale(a),greyscale(b),None,0.5,4,14,5,7,1.5,0)
    ba = cv2.calcOpticalFlowFarneback(greyscale(b),greyscale(a),None,0.5,4,14,5,7,1.5,0)
    y,x = np.mgrid[:64,:64].astype(np.float32)
    aa = cv2.remap(a,x-ab[:,:,0]*.5,y-ab[:,:,1]*.5,cv2.INTER_NEAREST,
                   borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
    bb = cv2.remap(b,x-ba[:,:,0]*.5,y-ba[:,:,1]*.5,cv2.INTER_NEAREST,
                   borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
    out=np.zeros_like(a)
    out[bb[:,:,3]>0]=bb[bb[:,:,3]>0]
    out[aa[:,:,3]>0]=aa[aa[:,:,3]>0]
    return out

def build(run_path, idle_path, sword_path, destination):
    inputs={"run":Path(run_path),"idle":Path(idle_path),"sword":Path(sword_path)}
    for name,path in inputs.items():
        if sha(path)!=SOURCES[name]:
            raise ValueError("SOURCE_SHA_FAIL: "+name)
    a=np.asarray(Image.open(inputs["run"]).convert("RGBA"))
    idle=np.asarray(Image.open(inputs["idle"]).convert("RGBA"))
    orig_sword=Image.open(inputs["sword"]).convert("RGBA")
    if a.shape!=(128,256,4) or idle.shape!=(64,64,4) or orig_sword.size!=(256,192):
        raise ValueError("SOURCE_DIMENSION_FAIL")
    f=[a[(i//4)*64:(i//4+1)*64,(i%4)*64:(i%4+1)*64].copy() for i in range(6)]
    poses=[f[0],middle(f[0],f[1]),f[1],f[2],middle(f[2],f[3]),f[3],
           middle(f[3],f[4]),f[4],f[5],middle(f[5],idle),idle,middle(idle,f[0])]
    if len(set(p.tobytes() for p in poses))!=12:
        raise ValueError("DUPLICATED_POSES")
    # A35 F6/F7 are NEVER used because original gait was ART HOLD.
    body=Image.new("RGBA",(256,192))
    weapon=Image.new("RGBA",(256,192))
    fx=Image.new("RGBA",(256,192))
    sword=orig_sword.crop((64,64,128,128))  # original A52 F5
    pixels=int(np.count_nonzero(np.asarray(sword)[:,:,3]))
    overlaps=[]
    for i,pose in enumerate(poses):
        at=((i%4)*64,(i//4)*64)
        body.paste(Image.fromarray(pose),at)
        anchor=HANDS[i]
        best=None
        for dy in range(-2,3):
            for dx in range(-2,3):
                cell=Image.new("RGBA",(64,64))
                cell.alpha_composite(sword,(anchor[0]-42+dx,anchor[1]-42+dy))
                ar=np.asarray(cell)
                if np.count_nonzero(ar[:,:,3])!=pixels:
                    continue
                overlap=int(np.count_nonzero((ar[:,:,3]>0)&(pose[:,:,3]>0)))
                if overlap<5:continue
                score=2*overlap-5*(abs(dx)+abs(dy))
                if best is None or score>best[0]:best=(score,cell,overlap,dx,dy)
        if best is None:raise ValueError("SWORD_DISCONNECTED_F%d"%i)
        weapon.paste(best[1],at)
        overlaps.append({"frame":i,"alpha_overlap":best[2],"offset":[best[3],best[4]]})
    out=Path(destination)
    out.mkdir(parents=True,exist_ok=True)
    paths={
       "body":out/"run_body.png",
       "weapon":out/"run_weapon.png",
       "fx":out/"run_fx.png",
    }
    body.save(paths["body"]);weapon.save(paths["weapon"]);fx.save(paths["fx"])
    for key,path in paths.items():
        if sha(path)!=EXPECTED[key]:
            raise RuntimeError("REPRO_MISMATCH_"+key+"; use documented pinned image pipeline")
    feet=[]
    for pose in poses:
        deepest=[]
        for lo,hi in [(19,33),(33,48)]:
            yy=np.where(pose[39:55,lo:hi,3]>0)[0]
            deepest.append(int(yy.max()+39) if len(yy) else -1)
        feet.append(deepest)
    if not(any(l<r for l,r in feet[:6]) and any(l>r for l,r in feet[6:])):
        raise ValueError("GAIT_SWAP_GEOMETRY_FAIL")
    manifest={
        "status":"SOURCE_SHA_GPU_FORMAT_PASS_ART_HOLD",
        "method":"6 authentic A35, 1 authentic A62, 5 code interpolations",
        "old_A35_F6_F7_used":False,"new_pixellab_job":"NOT_RUN","units":0,
        "sources":SOURCES,"generated":{k:sha(p) for k,p in paths.items()},
        "frame_count":12,"size":[256,192],"grip_checks":overlaps,"boot_y":feet}
    (out/"r5b_motion_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
    return manifest

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--run",type=Path)
    ap.add_argument("--idle",type=Path)
    ap.add_argument("--sword",type=Path)
    ap.add_argument("--out",type=Path)
    ap.add_argument("--self-test",action="store_true")
    args=ap.parse_args()
    if args.self_test:
        from tempfile import TemporaryDirectory
        with TemporaryDirectory() as t:
            a=Path(t)/"test.png"
            Image.new("RGBA",(256,128)).save(a)
            try:build(a,a,a,Path(t)/"out")
            except ValueError as e:
                assert "SOURCE_SHA_FAIL" in str(e)
            else:raise AssertionError("Unsafe source accepted")
        print("TA_R5B_SOURCE_LOCK_SYNTHETIC_PASS")
    else:
        if not(args.run and args.idle and args.sword and args.out):
            ap.error("--run --idle --sword --out required")
        print(json.dumps(build(args.run,args.idle,args.sword,args.out),ensure_ascii=False,indent=2))
