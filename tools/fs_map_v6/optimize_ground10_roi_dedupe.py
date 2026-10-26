#!/usr/bin/env python3
# Isolated derivative: three unique RGBA ROI bitmaps reconstruct four animation frames.
from PIL import Image
from pathlib import Path
import json, hashlib, numpy as np, sys
ROOT=Path(sys.argv[2]) if len(sys.argv)>2 else Path.cwd()/"FS_MAP_V6_QA"
SRC=Path(sys.argv[1]) if len(sys.argv)>1 else Path.cwd()/"Graphics"/"Parallaxes"
ROI=(0,928,640,1280)
OUT=ROOT/"ANIM_ROI_DEDUP_CANDIDATE"
OUT.mkdir(exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def pix(n):return np.array(Image.open(SRC/n).convert("RGBA"))
originals=[pix("ground10_%s.png"%i) for i in range(1,5)]
assert all(a.shape==(1280,960,4) for a in originals)
assert np.array_equal(originals[1],originals[3]),"F2 != F4 pixels, dedup unsafe"
base=originals[0]
Image.fromarray(base,"RGBA").save(OUT/"ground10_static_v6.png")
timeline=[]
uniq=[]
for i,a in enumerate(originals,1):
    matched=next((j for j,b in enumerate(uniq) if np.array_equal(a,b)),None)
    if matched is None: matched=len(uniq);uniq.append(a)
    timeline.append(matched)
assert timeline==[0,1,2,1]
patches=[]
for i,a in enumerate(uniq):
    cut=Image.fromarray(a[ROI[1]:ROI[3],ROI[0]:ROI[2]],"RGBA")
    name=f"ground10_roi_unique_{i+1}.png";path=OUT/name
    cut.save(path)
    patches.append(dict(name=name,pixel_sha256=hashlib.sha256(cut.tobytes()).hexdigest(),png_sha256=sha(path)))
# Rebuild each of the four source frames with shared static map.
diffs=[]
for i,a in enumerate(originals):
    rebuilt=base.copy()
    j=timeline[i]
    rebuilt[ROI[1]:ROI[3],ROI[0]:ROI[2]]=uniq[j][ROI[1]:ROI[3],ROI[0]:ROI[2]]
    diffs.append(int(np.count_nonzero(np.any(rebuilt!=a,axis=2))))
assert diffs==[0,0,0,0],diffs
# Negative: replace non-matching frame with frame1 and enforce pixel mismatch.
neg=int(np.count_nonzero(np.any(uniq[1][ROI[1]:ROI[3],ROI[0]:ROI[2]] != uniq[0][ROI[1]:ROI[3],ROI[0]:ROI[2]],axis=2)))
assert neg>0
full_raw_bytes=4*960*1280*4
roi_raw_bytes=960*1280*4+3*640*352*4
audit=dict(version="FS_V6_ANIMATION_DEDUP_PILOT",status="STATIC_PIXEL_RECONSTRUCTION_PASS_VX_NATIVE_PENDING",
        world_px=[960,1280], animated_ROI_xyxy=list(ROI),
        four_frame_playback=[1,2,3,2],unique_texture_count=3,
        source_reference_pixel_duplicates=["ground10_2.png","ground10_4.png"],
        patch_0based_indices=timeline,reconstructed_RGBA_mismatch_pixels=diffs,
        pixel_negative_test=int(neg),unique=patches,
        full_RGBA_uncompressed_bytes=full_raw_bytes,optimized_RGBA_uncompressed_bytes=roi_raw_bytes,
        potential_uncompressed_reduction_fraction=round(1-roi_raw_bytes/full_raw_bytes,6),
        caveat="RGSS2 original runtime/cache remains sealed and untouched; no performance or native playback verified")
(OUT/"DEDUP_V6_QA.json").write_text(json.dumps(audit,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print(json.dumps({k:audit[k] for k in ("unique_texture_count","four_frame_playback","reconstructed_RGBA_mismatch_pixels","pixel_negative_test","potential_uncompressed_reduction_fraction","status")},ensure_ascii=False))
