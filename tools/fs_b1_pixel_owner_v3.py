from pathlib import Path
from PIL import Image, ImageDraw, ImageChops
from collections import deque, Counter
from shutil import copy2
import hashlib, json, zipfile, time, os

BASE=Path(__file__).resolve().parent.parent/"baseline"
ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/"outputs"
LOG=ROOT/"logs"
SRC=BASE/"source"/"clean"
for p in [ROOT,OUT,LOG,OUT/"dynamic",ROOT/"input"]:p.mkdir(parents=True,exist_ok=True)
manifestbytes=(BASE/"scene_manifest.json").read_bytes()
m=json.loads(manifestbytes)
W,H=m["canvas"]["width"],m["canvas"]["height"]
assert (W,H)==(864,640)
objects=sorted(m["instances"],key=lambda v:(v["draw_order"],v["id"]))
assert len(objects)==48
ids={o["id"]:i+1 for i,o in enumerate(objects)}
by_id={i+1:o for i,o in enumerate(objects)}
assert all(o["draw_order"]==o["y"]+o["dimensions"][1] for o in objects), "DRAW_ORDER_NOT_FOOT"
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
images={}
for o in objects:
    name=o["asset_id"]
    if name not in images:
        p=SRC/(name+".png")
        assert p.is_file() and sha(p)==o["sha256"],("SOURCE_SHA_FAIL",name)
        im=Image.open(p).convert("RGBA")
        assert im.size==tuple(o["dimensions"])
        hist=im.getchannel("A").histogram()
        assert sum(hist[1:255])==0,("NON_BINARY_ALPHA_UNSUPPORTED",name)
        images[name]=im
    assert images[name].size==tuple(o["dimensions"])

ground=Image.open(BASE/"build"/"FS_ELF_RICH_Ground.png").convert("RGBA")
refpar=Image.open(BASE/"build"/"FS_ELF_RICH_Par_COMPLETE.png").convert("RGBA")
refmaster=Image.open(BASE/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
assert ground.size==refpar.size==refmaster.size==(W,H)

owner=Image.new("I",(W,H),0)
upper=Image.new("L",(W,H),0)
recomp=Image.new("RGBA",(W,H),(0,0,0,0))
coverage=Counter()
for o in objects:
    idx=ids[o["id"]]
    im=images[o["asset_id"]]
    x,y=o["x"],o["y"]
    aa=im.getchannel("A")
    cut=o["base_cut_y"]
    assert isinstance(cut,int) and 0<=cut<=im.height
    owner.paste(idx,(x,y,x+im.width,y+im.height),aa)
    up=aa.copy()
    if cut<im.height:up.paste(0,(0,cut,im.width,im.height))
    lower=aa.copy()
    if cut>0:lower.paste(0,(0,0,im.width,cut))
    upper.paste(255,(x,y,x+im.width,y+im.height),up)
    upper.paste(0,(x,y,x+im.width,y+im.height),lower)
    recomp.alpha_composite(im,(x,y))
    coverage[o["role"]]+=1
assert ImageChops.difference(recomp,refpar).getbbox() is None,"SOURCE_VS_PAR_MISMATCH"
baseline=ground.copy();baseline.alpha_composite(recomp)
assert ImageChops.difference(baseline,refmaster).getbbox() is None,"SOURCE_VS_MASTER_MISMATCH"

# The entire visible PAR is split according to the last visible object's *own* semantic cut.
upperpart=Image.new("RGBA",(W,H),(0,0,0,0))
lowerpart=Image.new("RGBA",(W,H),(0,0,0,0))
upperpart.paste(refpar,(0,0),upper)
invert=Image.eval(upper,lambda c:255-c)
lowerpart.paste(refpar,(0,0),invert)
s=lowerpart.copy();s.alpha_composite(upperpart)
assert ImageChops.difference(s,refpar).getbbox() is None,"V3_PARTITION_MISMATCH"

owner.save(OUT/"PIXEL_OWNER_ID.png")
upper.save(OUT/"VISIBLE_UPPER_CLASS.png")
lowerpart.save(OUT/"Par_BASE_V3.png")
upperpart.save(OUT/"Occlusion_V3.png")
s.save(OUT/"Par_RECOMPOSED_V3.png")
baseline.save(OUT/"Master_REFERENCE.png")
copy2(BASE/"build"/"FS_ELF_RICH_Collision.png",OUT/"Collision.png")
copy2(BASE/"scene_manifest.json",ROOT/"input"/"scene_manifest.json")

# Independent visible-owner semantic audit, using the top visible source object's pixel.
opix=owner.load();upix=upper.load();parpix=refpar.load()
checks=0
for py in range(H):
    for px in range(W):
        idx=opix[px,py]
        if idx==0:
            assert parpix[px,py][3]==0,("UNOWNED_OPAQUE",px,py)
        else:
            ob=by_id[idx]
            lx,ly=px-ob["x"],py-ob["y"]
            assert 0<=lx<ob["dimensions"][0] and 0<=ly<ob["dimensions"][1]
            assert images[ob["asset_id"]].getpixel((lx,ly))==parpix[px,py],("OWNER_COLOR_DIFF",px,py,ob["id"])
            assert upix[px,py]==(255 if ly<ob["base_cut_y"] else 0),("OWNER_SEMANTIC_DIFF",px,py)
            checks+=1

# Build a 20x56 binary-alpha proxy, no attempt to impersonate sealed FS actor artwork.
actor=Image.new("RGBA",(20,56),(0,0,0,0))
draw=ImageDraw.Draw(actor)
draw.ellipse((2,0,17,16),fill=(243,188,78,255))
draw.rectangle((3,15,16,37),fill=(43,85,187,255))
draw.rectangle((2,37,8,55),fill=(33,35,58,255))
draw.rectangle((11,37,17,55),fill=(33,35,58,255))
assert sum(actor.getchannel("A").histogram()[1:255])==0
actor.save(OUT/"ACTOR_PROXY_20x56.png")
actpixels=actor.load()
ownerpx=owner.load()
blocked=Image.open(OUT/"Collision.png").convert("L")
def clear(tx,ty,rad=8):
    x,y=tx*32+16,ty*32+16
    if x-rad<0 or y-rad<0 or x+rad>=W or y+rad>=H:return False
    pix=blocked.load()
    for yy in range(y-rad,y+rad+1):
        for xx in range(x-rad,x+rad+1):
            if pix[xx,yy]>0:return False
    return True
spawn=m["spawn"]
start=spawn["x"]//32,spawn["y"]//32
assert clear(*start),("SPAWN_BLOCKED",start)
valid={(x,y) for y in range(H//32) for x in range(W//32) if clear(x,y)}
todo=deque([start]);prev={start:None}
while todo:
    a=todo.popleft()
    for n in ((a[0]+1,a[1]),(a[0]-1,a[1]),(a[0],a[1]+1),(a[0],a[1]-1)):
        if n in valid and n not in prev:
            prev[n]=a;todo.append(n)
def route(q):
    rr=[]
    while q is not None:
        rr.append(q);q=prev[q]
    return list(reversed(rr))
assert len(prev)>120,("NAVIGABLE_TOO_SMALL",len(prev))

def position(tx,ty):
    footx,footy=tx*32+16,ty*32+32
    return footx-actor.width//2,footy-actor.height,footy

def overlap_counts(tx,ty):
    x0,y0,fy=position(tx,ty)
    front=Counter();behind=Counter()
    for ay in range(actor.height):
        yy=y0+ay
        if yy<0 or yy>=H:continue
        for ax in range(actor.width):
            xx=x0+ax
            if xx<0 or xx>=W or actpixels[ax,ay][3]==0:continue
            idx=ownerpx[xx,yy]
            if idx:
                ob=by_id[idx]
                (front if fy<=ob["draw_order"] else behind)[ob["id"]]+=1
    return front,behind

candidates=[]
for tx,ty in prev:
    if (tx,ty)==start:continue
    f,b=overlap_counts(tx,ty)
    if f or b:
        candidates.append({"tile":[tx,ty],"foot_world":[tx*32+16,ty*32+32],
                           "front_pixels":sum(f.values()),"behind_pixels":sum(b.values()),
                           "front_objects":dict(f),"behind_objects":dict(b),
                           "steps":len(route((tx,ty)))-1})
fronts=sorted([x for x in candidates if x["front_pixels"]>=12],
              key=lambda x:(-x["front_pixels"],x["steps"]))
behinds=sorted([x for x in candidates if x["behind_pixels"]>=12],
               key=lambda x:(-x["behind_pixels"],x["steps"]))
assert fronts,("NO_LEGAL_BEHIND_OBJECT_OVERLAP",len(candidates))
assert behinds,("NO_LEGAL_IN_FRONT_OBJECT_OVERLAP",len(candidates))

def painter_frame(tx,ty):
    """Independent painter oracle: re-render all sprites + actor in full Z order."""
    x0,y0,footy=position(tx,ty)
    frame=ground.copy()
    jobs=[(o["draw_order"],1,o["id"],o) for o in objects]
    jobs.append((footy,0,"ACTOR",None))
    for zz,tie,key,ob in sorted(jobs,key=lambda j:(j[0],j[1],j[2])):
        if ob is None:frame.alpha_composite(actor,(x0,y0))
        else:frame.alpha_composite(images[ob["asset_id"]],(ob["x"],ob["y"]))
    return frame

def atlas_frame(tx,ty):
    """Owner atlas: overlay actor only at pixels whose *visible* owner is behind actor."""
    x0,y0,footy=position(tx,ty)
    frame=baseline.copy();pixels=frame.load()
    for ay in range(actor.height):
        yy=y0+ay
        if yy<0 or yy>=H:continue
        for ax in range(actor.width):
            xx=x0+ax
            if xx<0 or xx>=W or actpixels[ax,ay][3]==0:continue
            idx=ownerpx[xx,yy]
            if idx==0 or by_id[idx]["draw_order"]<footy:
                pixels[xx,yy]=actpixels[ax,ay]
    return frame

samples=[]
for label,candidate in [("BEHIND_OBJECT",fronts[0]),("IN_FRONT_OBJECT",behinds[0])]:
    tx,ty=candidate["tile"]
    oracle=painter_frame(tx,ty)
    fast=atlas_frame(tx,ty)
    diff=ImageChops.difference(oracle,fast)
    assert diff.getbbox() is None,("DYNAMIC_DIFF",label,diff.getbbox())
    oracle.save(OUT/"dynamic"/(label+"_native_contract_oracle.png"))
    fast.save(OUT/"dynamic"/(label+"_owner_atlas.png"))
    samples.append({"name":label,**candidate,"path_from_spawn":route((tx,ty)),
                    "oracle_vs_atlas_diff_pixels":0})

# Additional deterministic oracle samples (not just the two cherry-picked frames).
more=sorted(candidates,key=lambda v:(v["steps"],v["tile"]))
testcount=0
for cand in more:
    if cand["front_pixels"]+cand["behind_pixels"]<4:continue
    tx,ty=cand["tile"]
    assert ImageChops.difference(painter_frame(tx,ty),atlas_frame(tx,ty)).getbbox() is None,("DYNAMIC_MULTI_FAIL",tx,ty)
    testcount+=1

# Fail-closed negative: 1px X drift of a single scene object changes ownership.
target=objects[0]
owner_mutated=Image.new("I",(W,H),0)
for o in objects:
    im=images[o["asset_id"]]
    dx=1 if o["id"]==target["id"] else 0
    owner_mutated.paste(ids[o["id"]],(o["x"]+dx,o["y"],o["x"]+dx+im.width,o["y"]+im.height),im.getchannel("A"))
mut=owner_mutated.load()
drift_diff=sum(opix[x,y]!=mut[x,y] for y in range(H) for x in range(W))
assert drift_diff>0,("NEGATIVE_1PX_NOT_DETECTED",target["id"])

# Fail-closed negative: flattened PAR always in front of actor breaks the legal front case.
tx,ty=behinds[0]["tile"]
wrong=ground.copy()
ax,ay,_=position(tx,ty)
wrong.alpha_composite(actor,(ax,ay))
wrong.alpha_composite(refpar)
expected=painter_frame(tx,ty)
negative_flat=sum(p!=q for p,q in zip(wrong.getdata(),expected.getdata()))
assert negative_flat>0,("NEGATIVE_FLAT_PAR_NOT_DETECTED",tx,ty)
wrong.save(OUT/"dynamic"/"NEGATIVE_FLAT_PAR.png")

# Overview: topmost owner rendered with a deterministic color per object; DEBUG ONLY, never game art.
palette={0:(0,0,0,0)}
for i in by_id:
    palette[i]=((i*61)%236+12,(i*137)%236+12,(i*19)%236+12,255)
owner_preview=Image.new("RGBA",(W,H))
owner_preview.putdata([palette[idx] for idx in owner.getdata()])
owner_preview.save(OUT/"VISIBLE_OWNER_DEBUG_ONLY.png")
fullcount=Counter(owner.getdata())
report={
 "status":"REFERENCE_OWNER_DEPTH_CONTRACT_PASS_NOT_NATIVE_FS_PASS",
 "canvas":[W,H],"manifest_sha256":hashlib.sha256(manifestbytes).hexdigest(),
 "owner_semantic":"last visible instance id, drawn in ascending foot_y, binary alpha",
 "alpha_policy":"binary only, fail closed for semitransparent source",
 "instance_count":len(objects),"source_asset_types":len(images),"instance_roles":dict(coverage),
 "opaque_par_pixels":checks,"visible_instance_ids":len(fullcount)-int(0 in fullcount),
 "static_master_difference_pixels":0,"static_owner_partition_difference_pixels":0,
 "reachable_tiles":len(prev),"candidate_overlap_tiles":len(candidates),
 "dynamic_oracle_test_positions":testcount,"chosen_legal_actor_samples":samples,
 "negative_one_pixel_drift_detected_pixels":drift_diff,
 "negative_flattened_par_detected_pixels":negative_flat,
 "native_vx_this_run":"NOT_RUN","sealed_fs_runtime":"NOT_RUN",
 "visual_reference_gate":"NOT_PASS_B1_SOURCE_KIT_MISSING",
 "source_rights":"PRIVATE_TEST_CANDIDATES_ONLY_NOT_PUBLICLY_DISTRIBUTABLE"
}
(LOG/"OWNER_DEPTH_V3_REPORT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
(OUT/"INSTANCE_ID_INDEX.json").write_text(json.dumps({
 str(i):{"id":o["id"],"asset_id":o["asset_id"],"draw_order":o["draw_order"],
         "world_xy":[o["x"],o["y"]],"source_sha256":o["sha256"],
         "upper_cut_local_y":o["base_cut_y"],"role":o["role"]}
 for i,o in by_id.items()},ensure_ascii=False,indent=2),encoding="utf8")
print("B1_OWNER_DEPTH_V3 PASS",json.dumps({
 "objects":len(objects),"owner_pixels":checks,"dynamic_positions":testcount,
 "front_choice":samples[0]["tile"],"behind_choice":samples[1]["tile"],
 "negative_1px":drift_diff,"negative_flat":negative_flat
},ensure_ascii=False),flush=True)
