#!/usr/bin/env python3
"""Shared non-dithered palette candidate. Input sprites are private; do NOT commit them.
Pillow nearest pixel art + deterministic MiniBatchKMeans. No new PixelLab jobs.
This produces a CANDIDATE only, not an art-approved asset.
"""
from pathlib import Path
import argparse
import hashlib
import json
import numpy as np
from PIL import Image
from sklearn.cluster import MiniBatchKMeans

def sha256(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def build(src_dir: Path, atlas: Path, target: Path, colors=32):
    originals=[src_dir/f'PMD000{i}_STATIC_64.png' for i in (1,2,3)]
    source=[]
    for path in originals:
        im=Image.open(path).convert('RGBA')
        if im.size!=(64,64): raise ValueError(f'wrong source size {path}: {im.size}')
        arr=np.asarray(im);source.append(arr[arr[:,:,3]>8,:3])
    population=np.concatenate(source).astype(np.uint8)
    km=MiniBatchKMeans(n_clusters=colors,random_state=43,n_init=3,batch_size=1024,max_iter=120).fit(population)
    palette=np.clip(np.rint(km.cluster_centers_),0,255).astype(np.uint8)
    original=Image.open(atlas).convert('RGBA')
    if original.size!=(384,288): raise ValueError('atlas expected 384x288')
    a=np.asarray(original).copy()
    mask=a[:,:,3]>0
    # int32 is essential: int16 squaring overflows and causes catastrophic yellow speckling.
    pixels=a[mask,:3].astype(np.int32)
    colors_i32=palette.astype(np.int32)
    out_ids=np.empty(pixels.shape[0],dtype=np.int32)
    for start in range(0,len(pixels),4096):
        p=pixels[start:start+4096]
        out_ids[start:start+len(p)]=np.argmin(np.sum((p[:,None,:]-colors_i32[None,:,:])**2,axis=2),axis=1)
    a[mask,:3]=palette[out_ids]
    target.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(a,'RGBA').save(target,optimize=True)
    verify=np.asarray(Image.open(target).convert('RGBA'))
    assert np.array_equal(verify[:,:,3],np.asarray(original)[:,:,3]),'alpha mask must remain pixel-exact'
    n_unique=len({tuple(v) for v in verify[verify[:,:,3]>0,:3]})
    assert n_unique<=colors
    return {'schema':'fs-tb-palette-v1','original_atlas_sha256':sha256(atlas),
            'three_source_sha256':{p.name:sha256(p) for p in originals},
            'result_sha256':sha256(target),'max_colors':colors,'actual_colors':n_unique,
            'alpha_exact':True,'pixel_filter':'nearest; no dither','art':'HOLD'}

if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('--src-dir',type=Path,required=True)
    ap.add_argument('--atlas',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--colors',type=int,default=32)
    args=ap.parse_args()
    result=build(args.src_dir,args.atlas,args.out,args.colors)
    print(json.dumps(result,ensure_ascii=False,indent=2))
