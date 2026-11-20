#!/usr/bin/env python3
"""Deterministic RUN12 weapon candidate from real A52 PixelLab F5 sword.
Pixel translation only: this is NOT a fresh PixelLab v3 job.
Input/output paths are explicit, no user PC projects or private PNGs in GitHub.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import tempfile
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw

SIZE = (256, 192)
CELL = 64
SWORD_FRAME = 5
SWORD_HILT = (42, 42)
HAND = [(38,48),(37,49),(37,49),(42,41),(42,42),(38,47),
        (37,47),(38,48),(39,49),(40,48),(38,49),(38,49)]
BODY_SHA = "fab73bc51109ad0b896333899c82ff80a7f5340d0ee25e4d0f7e94f6fd9f0bfb"
SWORD_SHA = "6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b"

def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def nonzero(image: Image.Image) -> int:
    channel = image.getchannel("A") if "A" in image.getbands() else image
    return sum(channel.histogram()[1:])

def build(body_path: Path, sword_path: Path, output: Path, strict: bool = True) -> dict:
    if strict and (sha(body_path) != BODY_SHA or sha(sword_path) != SWORD_SHA):
        raise ValueError("Locked source SHA mismatch: refusing to retarget unapproved sheets")
    body = Image.open(body_path).convert("RGBA")
    source = Image.open(sword_path).convert("RGBA")
    if body.size != SIZE or source.size != SIZE:
        raise ValueError("Both original private atlases must be RGBA 256x192")
    original = source.crop((CELL,CELL,CELL*2,CELL*2))  # approved A52 F5
    sword_pixels = nonzero(original)
    if sword_pixels < 40:
        raise ValueError("Approved A52 sword source is unexpectedly empty")
    weapon = Image.new("RGBA", SIZE)
    fx = Image.new("RGBA", SIZE)  # RUN has no impact VFX by design.
    frames = []
    for i,(gx,gy) in enumerate(HAND):
        x0,y0 = (i % 4)*CELL, (i//4)*CELL
        dst = Image.new("RGBA",(CELL,CELL))
        dx,dy = gx-SWORD_HILT[0],gy-SWORD_HILT[1]
        dst.alpha_composite(original,(dx,dy))
        if nonzero(dst) != sword_pixels:
            raise ValueError(f"F{i}: sword clipped")
        bounds = dst.getchannel("A").getbbox()
        if bounds is None or bounds[0] <= 0 or bounds[1] <= 0 or bounds[2] >= CELL or bounds[3] >= CELL:
            raise ValueError(f"F{i}: sword touches atlas border")
        source_body = body.crop((x0,y0,x0+CELL,y0+CELL))
        contact = ImageChops.multiply(source_body.getchannel("A"),dst.getchannel("A"))
        overlap = nonzero(contact)
        if overlap == 0:
            raise ValueError(f"F{i}: detached sword")
        weapon.alpha_composite(dst,(x0,y0))
        frames.append({"frame":i,"hilt_xy":[gx,gy],"shift_xy":[dx,dy],
                       "sword_pixels":sword_pixels,"body_weapon_overlap":overlap,
                       "bbox_xyxy":list(bounds)})
    output.mkdir(parents=True,exist_ok=True)
    wp=output/"TA_ACTOR01_RUN12_WEAPON_A52_HAND_ALIGNED_R2.png"
    fp=output/"TA_ACTOR01_RUN12_FX_NONE_BY_DESIGN_R2.png"
    weapon.save(wp);fx.save(fp)
    result={"status":"GEOMETRY_PASS_ART_HOLD","generation_method":"original A52 sword F5 rigid translation",
            "fresh_pixellab_job":"NOT_RUN","pixel_lab_units":0,
            "body_source_sha256":sha(body_path),"sword_source_sha256":sha(sword_path),
            "new_weapon_sha256":sha(wp),"new_run_fx_sha256":sha(fp),
            "blocking_art":["A35 F6/F7 stance","private source Godot GPU proof","manual motion art review"],
            "frames":frames}
    (output/"TA_ACTOR01_RUN12_R2_QA.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    return result

def self_test() -> None:
    with tempfile.TemporaryDirectory() as temp:
        root=Path(temp)
        body=Image.new("RGBA",SIZE)
        sword=Image.new("RGBA",SIZE)
        sample=Image.new("RGBA",(64,64))
        d=ImageDraw.Draw(sample)
        d.line([(42,42),(55,27)],fill=(225,231,240,255),width=3)
        d.rectangle((40,40,44,43),fill=(193,160,31,255))
        sword.alpha_composite(sample,(64,64))
        for i,(hx,hy) in enumerate(HAND):
            bx,by=(i%4)*64,(i//4)*64
            ImageDraw.Draw(body).rectangle((bx+hx-4,by+hy-3,bx+hx+1,by+hy+1),fill=(4,100,64,255))
        bp,sp=root/"mock_body.png",root/"mock_sword.png"
        body.save(bp);sword.save(sp)
        result=build(bp,sp,root/"out",strict=False)
        assert len(result["frames"]) == 12
        assert all(m["body_weapon_overlap"] > 0 for m in result["frames"])
        print("TA_ACTOR01_RUN12_WEAPON_SELF_TEST_PASS 12/12; memory synthetic, no private assets")

if __name__=="__main__":
    cli=argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--body",type=Path)
    cli.add_argument("--sword",type=Path)
    cli.add_argument("--output",type=Path)
    cli.add_argument("--self-test",action="store_true")
    args=cli.parse_args()
    if args.self_test:
        self_test()
    else:
        if not (args.body and args.sword and args.output):
            cli.error("--body --sword --output required unless --self-test")
        result=build(args.body,args.sword,args.output)
        print("TA_ACTOR01_RUN12_R2_REAL_SOURCE_GEOMETRY_PASS_ART_HOLD")
        print(result["new_weapon_sha256"])
