#!/usr/bin/env python3
# Forest Symphony visual scale and animation ROI evidence pilot V6 (no runtime mutation).
from pathlib import Path
from PIL import Image
import numpy as np, json, hashlib, shutil, sys

OUT=Path(sys.argv[2]) if len(sys.argv)>2 else Path.cwd()/"FS_MAP_V6_QA"
SOURCE=Path(sys.argv[1]) if len(sys.argv)>1 else Path.cwd()/"Graphics"/"Parallaxes"
FILES=["ground3.png","ground10.png","ground10_1.png","ground10_2.png","ground10_3.png","ground10_4.png"]
TILE=32
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def entry(p):
    with Image.open(p) as im:
        alpha=np.array(im.convert("RGBA").getchannel("A"))
        return dict(filename=p.name,source=str(p),sha256=sha(p),size_px=list(im.size),
                    tiles_32=[im.width/TILE,im.height/TILE],mode=im.mode,
                    alpha_fully_opaque=bool(np.all(alpha==255)),
                    exact_32_grid=(im.width%32==0 and im.height%32==0))
def rgba(name):
    with Image.open(SOURCE/name) as im:return np.array(im.convert("RGBA"))
meta=[entry(SOURCE/n) for n in FILES]
g3=meta[0]; assert g3["size_px"]==[1280,928] and g3["exact_32_grid"]
arrs=[rgba(n) for n in FILES[1:]]
assert all(a.shape==(1280,960,4) for a in arrs)
base=arrs[1] # ground10_1, not unsuffixed ground10
diff_masks=[np.any(a!=base,axis=2) for a in arrs[2:]]
union=np.logical_or.reduce(diff_masks)
ys,xs=np.nonzero(union)
assert len(xs)>0
bbox_exact=[int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)]
# pad ROI to 32px grid for stable world alignment
x0=(bbox_exact[0]//32)*32;y0=(bbox_exact[1]//32)*32
x1=min(960,((bbox_exact[2]+31)//32)*32)
y1=min(1280,((bbox_exact[3]+31)//32)*32)
roi=[x0,y0,x1,y1]
assert roi==[0,928,640,1280],f"unexpected animation region {roi}"
off_mask=np.ones(union.shape,bool);off_mask[y0:y1,x0:x1]=False
assert all(np.count_nonzero(np.any(a!=base,axis=2)&off_mask)==0 for a in arrs[1:])

# In RGB+alpha world images, unsuffixed 'ground10' is a distinct untrusted base;
# do not silently treat it as animation frame 0.
unsuffixed=np.any(arrs[0]!=base,axis=2)
unmatched_unsuffixed=int(np.count_nonzero(unsuffixed & off_mask))

outdir=OUT/"ANIM_ROI_CANDIDATE"
outdir.mkdir(exist_ok=True,parents=True)
Image.fromarray(base,"RGBA").save(outdir/"ground10_static_source_copy.png")
records=[]
for i,a in enumerate(arrs[1:],start=1):
    patch=Image.fromarray(a[y0:y1,x0:x1],"RGBA")
    out=outdir/f"ground10_water_region_{i}.png"
    patch.save(out)
    # Strict 4-channel exact reconstitution: static + current ROI must equal input frame.
    reconstructed=base.copy()
    reconstructed[y0:y1,x0:x1]=np.array(patch)
    diff=int(np.count_nonzero(np.any(reconstructed!=a,axis=2)))
    assert diff==0,(i,diff)
    records.append(dict(frame=i,file=str(out),sha256=sha(out),roi_rgba_exact_diff_pixels=diff))
memory_full_bytes=4*960*1280*4
memory_roi_bytes=960*1280*4 + 4*(x1-x0)*(y1-y0)*4
audit={
    "version":"FS_V6_ANIM_ROI_SOURCE_AUDIT_20261026",
    "source_read_only":True,"project":"Forest Symphony / RPG Maker VX RGSS2",
    "art_goal_ground3":{"px":[1280,928],"tiles":[40,29],"total_tiles":1160},
    "art_goal_ground10":{"px":[960,1280],"tiles":[30,40],"total_tiles":1200},
    "files":meta,
    "animation_semantics":"Use ground10_1 .. _4 as 4 looping frames; ground10 (unsuffixed) differs outside motion region.",
    "full_frame_rgba": [960,1280], "frame_count":4,"pixel_exact_changed_bbox":bbox_exact,
    "roi_32px_grid_xyxy":roi,"roi_size_px":[x1-x0,y1-y0],
    "non_animated_pixel_drift_F1_F2_to_F4":0,
    "unsuffixed_ground10_non_motion_diff_pixels":unmatched_unsuffixed,
    "per_frame_full_vs_static_pixel_diff": [int(m.sum()) for m in diff_masks],
    "per_frame_recomposition":records,
    "estimated_naive_uncompressed_bytes_full_four_frames":memory_full_bytes,
    "estimated_uncompressed_bytes_static_plus_four_roi":memory_roi_bytes,
    "theoretical_bytes_reduction_fraction":round(1-memory_roi_bytes/memory_full_bytes,5),
    "native_vx_performance":"NOT_TESTED", "engine_adoption":"CANDIDATE_ONLY",
    "quality_requirements":["native 1x no blur","static pixels outside ROI strictly identical",
                            "32px-aligned static/dynamic placement","pixel-perfect four-channel recomposition",
                            "animated layer depth, camera scroll, map reload and correct disposal tested in VX"]
}
out=OUT/"FS_V6_ART_SCALE_AND_ANIMATION_EVIDENCE.json"
out.write_text(json.dumps(audit,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
print(json.dumps({k:audit[k] for k in ("art_goal_ground3","art_goal_ground10","roi_32px_grid_xyxy","non_animated_pixel_drift_F1_F2_to_F4","unsuffixed_ground10_non_motion_diff_pixels","estimated_naive_uncompressed_bytes_full_four_frames","estimated_uncompressed_bytes_static_plus_four_roi","native_vx_performance")},ensure_ascii=False))
print("OUTPUT",str(out))
