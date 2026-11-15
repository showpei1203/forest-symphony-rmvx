#!/usr/bin/env python3
"""A35 R5 coherent botanical sprites, native pixel art, eight species.

Source: private 1x Forest Symphony A36F trees. Only the three previously tiny
conifers use explicitly documented nearest-neighbor enlargement plus 1px needle
restoration, not repeated foliage tiles. Broadleaves retain native 1x artwork.
"""
import io,random
import numpy as np
from PIL import Image,ImageDraw

SPECIES={
 "cypress":("a36f_dense_tree_102_rgba",(92,172),(1.21,1.52)),
 "willow":("a36f_dense_tree_073_rgba",(154,174),(1.0,1.0)),
 "elder":("a36f_dense_tree_121_rgba",(162,158),(1.0,1.0)),
 "fir":("a36f_dense_tree_049_rgba",(108,185),(1.65,1.74)),
 "birch":("a36f_dense_tree_007_rgba",(122,171),(1.0,1.0)),
 "oak":("a36f_dense_tree_042_rgba",(172,159),(1.0,1.0)),
 "needle":("a36f_dense_tree_131_rgba",(90,179),(1.55,1.87)),
 "maple":("a36f_dense_tree_021_rgba",(142,152),(1.0,1.0))
}
TINT={
 "cypress":(.90,1.0,.92),"fir":(.92,.96,.94),"needle":(.79,.96,1.10),
 "willow":(.96,1.02,.91),"elder":(.95,1.,.9),"birch":(1.02,1.05,.95),
 "oak":(.87,.91,.82),"maple":(1.10,.95,.76)
}

def render(spec,assets,files):
    source,wanted,scale=SPECIES[spec]
    raw=Image.open(io.BytesIO(files[assets[source]["file"]])).convert("RGBA")
    crop=raw.crop(raw.getbbox())
    if scale!=(1.0,1.0):
        # R4 conifers occupied less than half of their empty PNG. Enlarge only
        # original painted whole tree, anchored by its actual root footpoint.
        crop=crop.resize((round(crop.width*scale[0]),round(crop.height*scale[1])),Image.Resampling.NEAREST)
    width,height=wanted
    if crop.width>width-2 or crop.height>height-5:
        raise ValueError("source overshoots owned alpha box "+spec)
    image=Image.new("RGBA",wanted)
    position=((width-crop.width)//2,height-crop.height-6)
    image.alpha_composite(crop,position)
    arr=np.asarray(image).copy()
    r,g,b=(arr[:,:,i].astype("float32") for i in (0,1,2))
    leaf=(g>r*.88)&(g>b*.82)&(g>32)&(arr[:,:,3]>30)
    rgb=arr[:,:,:3].astype("float32")
    rgb=np.where(leaf[:,:,None],np.clip(rgb*np.asarray(TINT[spec]),0,255),rgb)
    if spec in ("cypress","fir","needle"):
        rng=np.random.default_rng(1013+sum(ord(c) for c in spec))
        dust=rng.normal(0,7,(height,width,1))
        sunlight=(np.arange(width)[None,:,None]/width-.46)*(-6)
        rgb=np.where(leaf[:,:,None],np.clip(rgb+dust+sunlight,0,255),rgb)
    arr[:,:,:3]=np.uint8(np.clip(rgb,0,255))
    image=Image.fromarray(arr,"RGBA")
    painter=ImageDraw.Draw(image,"RGBA")
    rand=random.Random("FS_A35_R5_"+spec)

    if spec in ("cypress","fir","needle"):
        alpha=np.asarray(image.getchannel("A"))
        for _ in range(200 if spec=="fir" else 150):
            y=rand.randrange(max(3,position[1]),height-24)
            xs=np.flatnonzero(alpha[y,:]>120)
            if len(xs)<5 or rand.random()>.72:continue
            x=int(xs[0] if rand.random()<.5 else xs[-1])
            direction=-1 if x<width//2 else 1
            color=rand.choice([(58,91,47,239),(94,119,57,240),(121,143,79,232),(43,79,50,248)])
            if spec=="needle":
                color=(int(color[0]*.75),int(color[1]*.93),int(color[2]*1.12),color[3])
            painter.line((x,y,x+direction*rand.choice((1,2,3)),y+rand.choice((-2,0,2,3))),fill=color,width=1)
    elif spec=="willow":
        alpha=np.asarray(image.getchannel("A"))
        positions=[]
        for x in range(15,width-13,3):
            occupied=np.flatnonzero(alpha[:height-50,x]>160)
            if len(occupied)>10:positions.append((x,int(occupied[-1])))
        rand.shuffle(positions)
        for x,y in positions[:41]:
            length=rand.randrange(14,38);bend=rand.randrange(-8,9)
            end=min(height-18,y+length)
            if end-y<8:continue
            color=rand.choice([(65,100,38,224),(54,85,35,234),(105,129,48,219),(117,144,62,204)])
            painter.line((x,y,x+bend//2,(y+end)//2),fill=color,width=1)
            painter.line((x+bend//2,(y+end)//2,x+bend,end),fill=color,width=1)
    elif spec=="birch":
        arr=np.asarray(image).copy()
        red,green=(arr[:,:,i].astype("float32") for i in (0,1))
        yy=np.arange(height)[:,None]
        bark=(yy>height*.63)&(arr[:,:,3]>160)&(red>green*.70)&(red>45)&(green<red*1.24)
        recolored=np.clip(arr[:,:,:3].astype("float32")*np.asarray([1.4,1.4,1.19]),0,232).astype("uint8")
        arr[:,:,:3]=np.where(bark[:,:,None],recolored,arr[:,:,:3])
        image=Image.fromarray(arr,"RGBA")
        painter=ImageDraw.Draw(image,"RGBA")
        for _ in range(20):
            x=rand.randrange(width//2-14,width//2+16)
            y=rand.randrange(height-65,height-10)
            if image.getpixel((x,y))[3]>150:
                painter.line((x-2,y,x+1,y+1),fill=(63,57,45,214),width=1)
    elif spec=="oak":
        for _ in range(70):
            x=rand.randrange(28,width-28)
            y=rand.randrange(8,height-46)
            if image.getpixel((x,y))[3]>120:
                painter.point((x,y),fill=rand.choice([(132,153,60,175),(67,88,29,225),(162,167,83,175)]))
    elif spec=="maple":
        for _ in range(450):
            x=rand.randrange(12,width-12)
            y=rand.randrange(8,height-44)
            if image.getpixel((x,y))[3]>180 and rand.random()<.55:
                painter.line((x,y,x+rand.choice((0,1,2)),y),fill=rand.choice([(197,158,64,215),(159,124,57,212),(209,171,83,201),(147,159,57,215)]),width=1)
    elif spec=="elder":
        for _ in range(55):
            x=rand.randrange(18,width-18)
            y=rand.randrange(18,height-40)
            if image.getpixel((x,y))[3]>170:
                painter.point((x,y),fill=rand.choice([(140,151,66,215),(174,178,84,215),(75,83,39,237)]))
    return image
