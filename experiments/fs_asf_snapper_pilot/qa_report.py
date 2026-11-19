#!/usr/bin/env python3
"""Read-only QA of actual ASF + Pixel Snapper outputs. No fake PASS."""
from __future__ import annotations
import argparse, hashlib, json, math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

def metrics(path):
    image=Image.open(path).convert("RGBA")
    pixels=list(image.getdata())
    occupied=[px for px in pixels if px[3]>0]
    alpha=sorted({px[3] for px in pixels})
    pal={px[:3] for px in occupied}
    bbox=image.getbbox()
    return dict(file=str(path), size=list(image.size), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                opaque=sum(px[3]==255 for px in pixels), transparent=sum(px[3]==0 for px in pixels),
                partial=sum(0<px[3]<255 for px in pixels), alpha_levels=len(alpha),
                colors=len(pal), bounds=list(bbox) if bbox else None)
def iou(p,q):
    a=Image.open(p).convert("RGBA")
    b=Image.open(q).convert("RGBA")
    if a.size!=b.size: return None
    x=list(a.getchannel("A").getdata());y=list(b.getchannel("A").getdata())
    intersection=sum(ax>0 and bx>0 for ax,bx in zip(x,y))
    union=sum(ax>0 or bx>0 for ax,bx in zip(x,y))
    return round(intersection/union,6) if union else 1.0
def card(im, label, scale=5):
    im=Image.open(im).convert("RGBA")
    canvas=Image.new("RGB", (max(280,im.width*scale+16), max(280,im.height*scale+52)), (31,34,43))
    tile=Image.new("RGBA",im.size,(89,91,104,255))
    tile.alpha_composite(im)
    big=tile.convert("RGB").resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST)
    canvas.paste(big, ((canvas.width-big.width)//2,36))
    ImageDraw.Draw(canvas).text((8,9),label,fill=(248,248,248))
    return canvas
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--input",required=True)
    ap.add_argument("--master",required=True)
    ap.add_argument("--snap",required=True)
    ap.add_argument("--idle",required=False)
    ap.add_argument("--out",required=True)
    ap.add_argument("--asf-commit",default="unknown")
    ap.add_argument("--snapper-commit",default="unknown")
    args=ap.parse_args()
    out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    inputs={"source_picture":Path(args.input),"asf_master":Path(args.master),"snapper_master":Path(args.snap)}
    if args.idle:
        idle=Path(args.idle)
        samples=sorted(idle.rglob("frame_*.png"))
        if samples:
            inputs["asf_idle_0"]=samples[0]
            if len(samples)>1:inputs["asf_idle_1"]=samples[1]
    data={k:metrics(path) for k,path in inputs.items()}
    overlap=iou(inputs["asf_master"],inputs["snapper_master"])
    if overlap is not None:data["master_snap_silhouette_iou"]=overlap
    # This is a tool smoke test, NOT a judgment of fitness for the private FS Actor01.
    gates={"asf_master_exists":True,
           "snapper_executed":True,
           "asf_alpha_binary":data["asf_master"]["partial"]==0,
           "snapper_alpha_binary":data["snapper_master"]["partial"]==0,
           "snapper_matches_master_dimensions":data["asf_master"]["size"]==data["snapper_master"]["size"],
           "asf_idle_exists":"asf_idle_0" in data and "asf_idle_1" in data,
           "fs_45_degree_style":"NOT RUN",
           "fs_body_only_weaponless":"NOT RUN",
           "fs_native_godot":"NOT RUN",
           "fs_art_gate":"HOLD"}
    result={"status":"UPSTREAM_DEMO_SMOKE_TEST_ONLY","asset":"ASF open demonstration, not user's FS Actor01",
            "versions":{"agent_sprite_forge":args.asf_commit,"spritefusion_pixel_snapper":args.snapper_commit},
            "metrics":data,"gates":gates,"notes":[
            "ASF pixel-look master and deterministic breath are REAL upstream tool calls.",
            "Sprite Fusion Pixel Snapper is a REAL Rust CLI call, not a simulation.",
            "An already-pixel-clean 1x master need not benefit from further snapping.",
            "The pilot does not run AI image-to-video, does not generate 45-degree attack/run, and cannot certify FS art."]}
    (out/"qa_report.json").write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding="utf-8")
    cards=[card(inputs["asf_master"],"ASF: original 1x pixel-look master"),
           card(inputs["snapper_master"],"Pixel Snapper: postprocessed master")]
    if "asf_idle_0" in inputs:cards.append(card(inputs["asf_idle_0"],"ASF: actual generated idle frame 0"))
    if "asf_idle_1" in inputs:cards.append(card(inputs["asf_idle_1"],"ASF: actual generated idle frame 1"))
    columns=2
    width=max(x.width for x in cards)
    height=max(x.height for x in cards)
    page=Image.new("RGB",(columns*width, math.ceil(len(cards)/columns)*height),(23,25,34))
    for i,c in enumerate(cards):page.paste(c,((i%columns)*width,(i//columns)*height))
    page.save(out/"ASF_VS_PIXEL_SNAPPER_REAL_COMPARISON.png")
    print(json.dumps({"result":result["status"],"gates":gates,"colors":{k:v["colors"] for k,v in data.items()}},ensure_ascii=False))
if __name__=="__main__":main()
