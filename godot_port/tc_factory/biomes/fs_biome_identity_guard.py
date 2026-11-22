#!/usr/bin/env python3
"""T-C six-biome image gate. Detects WRONG terrain, never certifies art.
Calibrated from real ice, golden sand, and D11 basalt/lava Ground samples.
Do not infer layer semantic purity, world coordinate placement or PAR alpha.
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image

SUPPORTED={"FROST_SNOWFIELD","WIND_ERODED_GOLD_SANDS","CRIMSON_VOLCANO"}

def analyze(path:Path,biome:str)->dict:
    if biome not in SUPPORTED:
        raise ValueError("Terrain identity color-gate not calibrated: "+biome)
    with Image.open(path) as source:
        pixels=list(source.convert("RGB").resize((160,116),Image.Resampling.BILINEAR).getdata())
    n=len(pixels)
    warm=sum(r>g*1.04 and g>b*1.1 for r,g,b in pixels)/n
    icy=sum((b>r*1.1 and b>g*1.03) or (b>=r and g>=r) for r,g,b in pixels)/n
    # Independent volcanic reference: black basalt dominates, with distinct
    # orange molten seams; a yellow sandstone map must FAIL even if its orange
    # color could be mistaken for fire. This is NOT a ground-purity/art test.
    basalt=sum(r<110 and g<110 and b<135 for r,g,b in pixels)/n
    lava=sum(r>140 and r>g*1.24 and g>b*1.26 and b<135 for r,g,b in pixels)/n
    if biome=="WIND_ERODED_GOLD_SANDS":
        bad=(warm<0.55 or icy>0.30)
    elif biome=="FROST_SNOWFIELD":
        bad=(icy<0.55 or warm>0.30)
    else:
        bad=(basalt<0.40 or lava<0.008 or lava>0.28 or warm>0.40)
    return {
        "requested_biome":biome,"source":str(path),
        "warm_pixel_fraction":round(warm,6),"cool_pixel_fraction":round(icy,6),\n        "basalt_dark_fraction":round(basalt,6),"orange_lava_fraction":round(lava,6),
        "biome_identity_gate":"FAIL_WRONG_BIOME" if bad else "PASS_COARSE_BIOME_PALETTE_ONLY",
        "art_gate":"HOLD",
        "Ground_vs_complete_PAR":"NOT_VERIFIED_BY_COLOR",
        "native_Godot":"NOT_RUN",
        "meaning":"Color catches wrong biome only; cannot certify source Ground purity or transparent PAR"
    }

def main():
    a=argparse.ArgumentParser()
    a.add_argument("--image",required=True,type=Path)
    a.add_argument("--biome",required=True,choices=sorted(SUPPORTED))
    a.add_argument("--output",type=Path)
    x=a.parse_args();result=analyze(x.image,x.biome)
    if x.output:x.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    print(json.dumps(result,ensure_ascii=False))
    if result["biome_identity_gate"].startswith("FAIL"):raise SystemExit(2)

if __name__=="__main__":main()
