"""Collision connectivity and any-pixel overlap QA for 32px FS maps.

A threshold above 20 percent must never be reported as no overlap.
Never certify Game.exe or art based on this static report.
"""
from __future__ import annotations
from collections import deque
from io import BytesIO
from typing import Sequence, Mapping
from PIL import Image

class CollisionReviewError(ValueError):
    pass

def _grid(blocked: Sequence[Sequence[int]]) -> tuple[int,int]:
    if not blocked or not blocked[0]:
        raise CollisionReviewError("empty grid")
    h,w=len(blocked),len(blocked[0])
    if any(len(row)!=w or any(type(v) is not int or v not in (0,1) for v in row)
           for row in blocked):
        raise CollisionReviewError("collision grid must be rectangular and binary")
    return w,h

def connected_walkable(blocked: Sequence[Sequence[int]], start: tuple[int,int]) -> dict:
    w,h=_grid(blocked);x,y=start
    if not (0<=x<w and 0<=y<h and blocked[y][x]==0):
        raise CollisionReviewError("start must be walkable")
    seen={start};queue=deque([start])
    while queue:
        cx,cy=queue.popleft()
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            xx,yy=cx+dx,cy+dy
            if 0<=xx<w and 0<=yy<h and blocked[yy][xx]==0 and (xx,yy) not in seen:
                seen.add((xx,yy));queue.append((xx,yy))
    free={(xx,yy) for yy,row in enumerate(blocked) for xx,v in enumerate(row) if v==0}
    return {"total_walkable":len(free),"reachable_walkable":len(seen),
            "unreachable_tiles":[list(p) for p in sorted(free-seen)],
            "all_walkable_reachable":free==seen,
            "native_vx":"NOT_RUN","art":"NOT_REVIEWED"}

def propose_blocked_tiles(blocked: Sequence[Sequence[int]],tiles: Sequence[Mapping],
                          start: tuple[int,int]) -> dict:
    w,h=_grid(blocked);updated=[list(r) for r in blocked];seen=set()
    for item in tiles:
        xy=item.get("tile") if isinstance(item,Mapping) else None
        reason=item.get("reason") if isinstance(item,Mapping) else None
        if not isinstance(xy,(list,tuple)) or len(xy)!=2 or any(type(v) is not int for v in xy) or not isinstance(reason,str) or len(reason.strip())<8:
            raise CollisionReviewError("manual tile and reason required")
        x,y=xy
        if not (0<=x<w and 0<=y<h) or (x,y) in seen or updated[y][x]!=0:
            raise CollisionReviewError("patch outside walkable source or duplicate")
        seen.add((x,y));updated[y][x]=1
    return {"grid":updated,"before":connected_walkable(blocked,start),
            "after":connected_walkable(updated,start),
            "changed_tiles":[list(p) for p in sorted(seen)],
            "proposal_only":True,"native_vx":"NOT_RUN","art":"NOT_REVIEWED"}

def audit_footpoint_overlap(mask_png:bytes,blocked:Sequence[Sequence[int]],
                            actor_frame:tuple[int,int]=(23,30),
                            significant_ratio:float=0.2) -> dict:
    w,h=_grid(blocked)
    if (not isinstance(actor_frame,tuple) or len(actor_frame)!=2 or
            any(type(v) is not int or not 1<=v<=32 for v in actor_frame)):
        raise CollisionReviewError("actor frame must fit 32px tiles")
    if not 0<=significant_ratio<=1:
        raise CollisionReviewError("ratio outside 0..1")
    try:
        with Image.open(BytesIO(mask_png)) as im:
            if im.format!="PNG" or im.mode not in ("L","RGBA") or im.size!=(w*32,h*32):
                raise CollisionReviewError("full-world L or RGBA PNG required")
            alpha=im.copy() if im.mode=="L" else im.getchannel("A")
    except (ValueError,OSError) as exc:
        raise CollisionReviewError(f"mask read failed: {exc}") from exc
    hist=alpha.histogram()
    if sum(hist[1:255]):
        raise CollisionReviewError("only 0/255 binary source masks")
    aw,ah=actor_frame;candidates=[]
    for y in range(h):
        for x in range(w):
            if blocked[y][x]: continue
            px,fy=x*32+16,(y+1)*32
            box=(px-aw//2,fy-ah,px-aw//2+aw,fy)
            if box[0]<0 or box[1]<0 or box[2]>w*32 or box[3]>h*32:
                continue
            count=alpha.crop(box).histogram()[255]
            if count:
                ratio=count/(aw*ah)
                candidates.append({"tile":[x,y],"mask_pixels_under_actor_rect":count,
                    "ratio":round(ratio,6),"ratio_above_threshold":ratio>significant_ratio})
    return {"any_overlap_walkable_tile_count":len(candidates),
            "significant_overlap_walkable_tile_count":sum(p["ratio_above_threshold"] for p in candidates),
            "candidates":sorted(candidates,key=lambda p:-p["mask_pixels_under_actor_rect"]),
            "mask_channel":"L-intensity or RGBA-alpha",
            "native_actor_alpha":"RECT_APPROXIMATION_ONLY",
            "native_vx":"NOT_RUN","art":"NOT_REVIEWED"}
