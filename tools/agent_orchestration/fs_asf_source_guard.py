"""Lossless guard for an already-approved RGBA source; NOT an art generator.
New art must use separate candidate QA. This guard prevents silent identity loss.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import numpy as np
from PIL import Image

def load_rgba(data):
    with Image.open(io.BytesIO(data)) as im:
        return np.array(im.convert("RGBA"))

def restore_exact(source, candidate):
    if source.ndim!=3 or source.shape[2]!=4 or candidate.ndim!=3 or candidate.shape[2]!=4:
        raise ValueError("RGBA_REQUIRED")
    if not np.isin(source[:,:,3],[0,255]).all() or not np.isin(candidate[:,:,3],[0,255]).all():
        raise ValueError("BINARY_ALPHA_REQUIRED")
    ys,xs=np.where(source[:,:,3]>0)
    if not len(ys):
        raise ValueError("EMPTY_SOURCE")
    x0,y0,x1,y1=int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)
    crop=source[y0:y1,x0:x1]
    if candidate.shape!=crop.shape:
        raise ValueError("CROP_DIMENSIONS_CHANGED")
    if not np.array_equal(candidate[:,:,3],crop[:,:,3]):
        raise ValueError("SILHOUETTE_CHANGED")
    opaque=crop[:,:,3]>0
    if not np.array_equal(candidate[opaque,:3],crop[opaque,:3]):
        raise ValueError("OPAQUE_RGB_CHANGED")
    # Preserve all original pixels including invisible RGB, origin and canvas.
    return source.copy(),(x0,y0,x1,y1)

def selftest():
    src=np.zeros((64,64,4),dtype=np.uint8)
    src[20:55,13:36]=[10,20,30,255]
    src[22,14]=[40,50,60,255]
    src[25,17]=[11,22,33,0]
    crop=src[20:55,13:36].copy()
    out,bbox=restore_exact(src,crop)
    assert bbox==(13,20,36,55) and np.array_equal(out,src)
    bad=[(crop[:1,:1],"CROP_DIMENSIONS_CHANGED")]
    diff=crop.copy();diff[0,0,3]=0;bad.append((diff,"SILHOUETTE_CHANGED"))
    diff=crop.copy();diff[0,0,0]+=1;bad.append((diff,"OPAQUE_RGB_CHANGED"))
    diff=crop.copy();diff[0,0,3]=128;bad.append((diff,"BINARY_ALPHA_REQUIRED"))
    for candidate,reason in bad:
        try:restore_exact(src,candidate)
        except ValueError as e:assert str(e)==reason,(str(e),reason)
        else:raise AssertionError("accepted "+reason)
    print("FS_ASF_SOURCE_GUARD_PASS exact=1 negative=4 synthetic_only")

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--self-test",action="store_true")
    ap.add_argument("--source",type=Path)
    ap.add_argument("--candidate",type=Path)
    ap.add_argument("--source-sha256")
    args=ap.parse_args()
    if args.self_test:
        selftest();return
    if not args.source or not args.candidate or not args.source_sha256:
        ap.error("source, candidate and approved source SHA required")
    data=args.source.read_bytes()
    if hashlib.sha256(data).hexdigest()!=args.source_sha256:
        raise SystemExit("SOURCE_SHA_MISMATCH")
    source=load_rgba(data)
    candidate=load_rgba(args.candidate.read_bytes())
    if source.shape!=(64,64,4):
        raise SystemExit("SOURCE_NOT_64_RGBA")
    out,bbox=restore_exact(source,candidate)
    assert np.array_equal(out,source)
    # No generated file: exact result means retain original bytes; no purpose in re-encoding.
    print(json.dumps(dict(status="PASS_REUSE_ORIGINAL",source_sha256=args.source_sha256,bbox=bbox,canvas=[64,64],original_bytes_preserved=True)))
if __name__=="__main__":
    main()
