#!/usr/bin/env python3
"""T-C six-biome image gate. Detects WRONG terrain, never certifies art.
Calibrated from real ice and real golden sand Ground source samples only.
Do not infer layer semantic purity, world coordinate placement or PAR alpha.
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image

SUPPORTED={"FROST_SNOWFIELD","WIND_ERODED_GOLD_SANDS"}

def analyze(path:Path,biome:str)->dict:
    if biome not in SUPPORTED:
        raise ValueError("Terrain identity color-gate not calibrated: "+biome)
    with Image.open(path) as source:
        pixels=list(source.convert("RGB").resize((160,116),Image.Resampling.BILINEAR).getdata())
    n=len(pixels)
    warm=sum(r>g*1.04 and g>b*1.1 for r,g,b in pixels)/n
    icy=sum((b>r*1.1 and b>g*1.03) or (b>=r and g>=r) for r,g,b in pixels)/n
    bad=(warm<0.55 or icy>0.30) if biome=="WIND_ERODED_GOLD_SANDS" else (icy<0.55 or warm>0.30)
    return {
        "requested_biome":biome,"source":str(path),
        "warm_pixel_fraction":round(warm,6),"cool_pixel_fraction":round(icy,6),
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
