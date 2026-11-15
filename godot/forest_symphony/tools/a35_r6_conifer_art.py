#!/usr/bin/env python3
"""Forest Symphony A35 R6: native-pixel conifer foliage refinement, not scale-up.

R5's three conifers already have corrected dimensions. R6 works on their
existing 1:1 canvas without further resizing, anti-aliasing or tiled leaf stamps.
It smooths artificial square-color islands inside opaque canopies, adds
species-specific 1px needles at natural silhouette boundaries, and preserves
the entire trunk/root zone exactly. Deterministic and reconstructible.
"""
from PIL import Image, ImageFilter, ImageDraw
import numpy as np
import random

KINDS=("cypress","fir","needle")
SPECIES_COLOR={
 "cypress":(0.88,0.95,0.96),
 "fir":(0.91,0.94,0.91),
 "needle":(1.04,0.94,0.90)
}
COLORS={
 "cypress":{"shade":(44,82,38,255),"mid":(65,101,42,246),"tip":(116,143,62,240)},
 "fir":{"shade":(34,70,39,255),"mid":(52,95,46,246),"tip":(113,139,75,238)},
 "needle":{"shade":(24,65,50,255),"mid":(37,96,62,250),"tip":(92,143,94,242)}
}

def _neighbors(mask):
    p=np.pad(mask.astype(np.uint8),1)
    h,w=mask.shape
    n=np.zeros((h,w),dtype=np.uint8)
    for y in range(3):
        for x in range(3):
            n+=p[y:y+h,x:x+w]
    return n

def refine(kind,original):
    if kind not in KINDS:raise ValueError("R6 only changes original three conifers")
    rgba=np.asarray(original.convert("RGBA"),dtype=np.uint8).copy()
    H,W=rgba.shape[:2]
    rgb=rgba[:,:,:3].astype(np.float32)
    r,g,b=rgb[:,:,0],rgb[:,:,1],rgb[:,:,2]
    yy,xx=np.mgrid[:H,:W]
    # Keep footpoint, collision-related silhouette and shadows in last 18px identical.
    preserve_y=H-19
    green=(rgba[:,:,3]>65)&(g>r*.92)&(g>b*.94)&(g>26)&(yy<preserve_y)
    neighborhood=_neighbors(green)
    inside=green&(neighborhood>=7)
    # Use source detail; spatial median only inside true foliage and only 43%.
    med=np.asarray(original.convert("RGB").filter(ImageFilter.MedianFilter(3))).astype(np.float32)
    smooth=np.clip(rgb*.57+med*.43,0,255)
    rgb[inside]=smooth[inside]
    # Broad directional volume shading, not arbitrary per-pixel random confetti.
    level=(.5-xx/max(W-1,1))*.067+(0.55-yy/max(H-1,1))*.060
    low_freq=np.sin(xx*.115+yy*.069)*.020+np.cos(xx*.093-yy*.159)*.019
    factor=(1+level+low_freq).astype(np.float32)
    rgb[green]=rgb[green]*factor[green,None]
    ratio=np.asarray(SPECIES_COLOR[kind],dtype=np.float32)
    rgb[green]=rgb[green]*ratio
    rgba[:,:,:3]=np.uint8(np.clip(rgb,0,255))
    img=Image.fromarray(rgba,"RGBA")
    painter=ImageDraw.Draw(img)
    rng=random.Random("FS_A35_R6_CONIFER_"+kind)
    al=rgba[:,:,3]
    # Sequential handmade-looking branch orders, tapered from tip to boughs.
    for y in range(max(8,int(H*.22)),preserve_y-9,5 if kind=="fir" else 6):
        xs=np.flatnonzero((al[y]>145)&green[y])
        if len(xs)<8:continue
        left=int(xs[0]);right=int(xs[-1])
        wide=(right-left)/2
        if kind=="cypress" and wide<8:continue
        if kind=="needle" and wide<5:continue
        for edge,direction in ((left,-1),(right,1)):
            if rng.random()<(.31 if kind=="cypress" else .23):continue
            depth=max(1,int(wide/22))
            side=(2 if kind=="cypress" else 3 if kind=="fir" else 4)+depth+rng.randrange(0,2)
            x1=max(1,min(W-2,edge+direction*side))
            if abs(x1-edge)<2:continue
            y1=max(1,min(preserve_y-2,y+rng.choice((-2,-1,0,1))))
            c=COLORS[kind]["shade"] if (y%3==0) else COLORS[kind]["mid"]
            painter.line([(edge-direction,y+1),(edge+direction*2,y),(x1,y1)],fill=c,width=1)
            if rng.random()<.78:
                painter.point((x1,y1-1),fill=COLORS[kind]["tip"])
    # Interior light needle highlights in short 1-2 px diagonal clusters.
    al=np.asarray(img.getchannel("A"))
    count={"cypress":210,"fir":230,"needle":270}[kind]
    for k in range(count):
        y=rng.randrange(max(8,int(H*.20)),preserve_y-8)
        xs=np.flatnonzero(green[y]& (al[y]>160))
        if not len(xs):continue
        x=int(xs[rng.randrange(len(xs))])
        if neighborhood[y,x]<5:continue
        light=(x < W*.54 and y < H*.75)
        if rng.random() < (.63 if light else .33):
            color=COLORS[kind]["tip"] if light else COLORS[kind]["shade"]
        else:color=COLORS[kind]["mid"]
        dx=rng.choice((-1,0,1))
        painter.line([(x,y),(max(1,min(W-2,x+dx)),min(preserve_y-2,y+rng.choice((1,2))))],
                     fill=color,width=1)
    out=np.asarray(img)
    if not np.array_equal(out[preserve_y:],np.asarray(original.convert("RGBA"))[preserve_y:]):
        raise ValueError("R6 trunk/root anchor changed")
    if img.getbbox() is None:raise ValueError("Empty conifer")
    bounds=img.getbbox()
    if not(0<=bounds[0]<bounds[2]<=W and 0<=bounds[1]<bounds[3]<=H):
        raise ValueError("New needles outside canvas")
    return img
