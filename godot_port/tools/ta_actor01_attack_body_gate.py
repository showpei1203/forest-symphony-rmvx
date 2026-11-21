#!/usr/bin/env python3
"""Reject visually static A52-like attack bodies before claiming motion art.
Head/torso pixel DIFFERENCE is a necessary but insufficient art criterion.
Source-private files only. --self-test runs with synthetic pixels in CI.
"""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops
import hashlib

A52_SHA="a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f"

def frame(img,i):
    return img.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))

def difference_count(a,b,top,bottom):
    old=a.crop((0,top,64,bottom))
    new=b.crop((0,top,64,bottom))
    diff=ImageChops.difference(old,new)
    # Count changed RGBA pixels, not just RGB, so transparent edges matter.
    return sum(1 for pixel in diff.getdata() if pixel!=(0,0,0,0))

def verify(before,after, strict=True):
    if before.size!=(256,192) or after.size!=(256,192):
        raise ValueError("Expected 12 x 64x64 sprites (256x192 atlas)")
    records=[]
    for i in range(12):
        old,new=frame(before,i),frame(after,i)
        head=difference_count(old,new,14,32)
        torso=difference_count(old,new,32,45)
        feet=difference_count(old,new,51,64)
        if feet:
            raise ValueError("Original A52 foot pivot changed at F"+str(i))
        if i in (0,11) and (head or torso):
            raise ValueError("Original approved start/recovery identity altered at F"+str(i))
        if i in (3,4,7,8) and (head<90 or torso<70):
            raise ValueError("Head/torso too static at key F%d: head=%d torso=%d" %(i,head,torso))
        records.append((i,head,torso,feet))
    return records

def self_test():
    src=Image.new("RGBA",(256,192))
    dst=Image.new("RGBA",(256,192))
    for i in range(12):
        px=(i%4)*64;py=(i//4)*64
        for atlas,move in ((src,0),(dst,4 if i not in (0,11) else 0)):
            d=ImageDraw.Draw(atlas)
            d.rectangle((px+21+move,py+17,px+38+move,py+29),fill=(220,220,221,255))
            d.rectangle((px+23+move,py+33,px+41+move,py+43),fill=(24,98,85,255))
            d.rectangle((px+23,py+51,px+39,py+57),fill=(62,56,43,255))
    out=verify(src,dst,False)
    assert len(out)==12 and out[7][1]>=90 and out[7][2]>=70
    try:
        verify(src,src)
        raise AssertionError("Static head/torso erroneously accepted")
    except ValueError:
        pass
    print("TA_ATTACK_STATIC_HEAD_TORSO_REGRESSION_SELFTEST_PASS (synthetic; not art gate)")

if __name__=="__main__":
    cli=argparse.ArgumentParser()
    cli.add_argument("--before",type=Path)
    cli.add_argument("--after",type=Path)
    cli.add_argument("--self-test",action="store_true")
    a=cli.parse_args()
    if a.self_test:
        self_test()
    else:
        if not a.before or not a.after:
            cli.error("Supply --before A52 original and --after R6 candidate")
        if hashlib.sha256(a.before.read_bytes()).hexdigest()!=A52_SHA:
            raise ValueError("A52 original SHA mismatch")
        result=verify(Image.open(a.before).convert("RGBA"),Image.open(a.after).convert("RGBA"))
        print("TA_ATTACK_HEAD_TORSO_GEOMETRY_PASS_ART_HOLD",result)
