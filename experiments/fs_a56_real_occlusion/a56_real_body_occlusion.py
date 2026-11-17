#!/usr/bin/env python3
"""A56: nondestructive A53 source-registered occlusion candidate and pixel QA.

Only an isolated engineering candidate. It does NOT approve an FS shield design or
infer an unseen forearm: manual/approved part masks remain required for release.

Sources remain immutable; never copy source sprites or derivative frames to a
public repository. Output is for private Drive with provenance only.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw

EXPECTED_BODY_SHA = "af2b94a424ab613fa5a8ff45125f0398da3a20432cdeaa744f87f9f1b1a9ac44"
FRAME_SIZE = 64
FRAME_COUNT = 12
REQUIRED_OCCLUDED_FRAMES = (5, 6)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def rgba_atlas_frames(path: Path) -> list[Image.Image]:
    if sha256(path) != EXPECTED_BODY_SHA:
        raise ValueError("FAIL_CLOSED: A53 source SHA mismatch, do not modify source")
    sheet = Image.open(path).convert("RGBA")
    if sheet.size != (256, 192):
        raise ValueError("FAIL_CLOSED: A53 atlas dimensions changed")
    return [sheet.crop((f % 4 * 64, f // 4 * 64, f % 4 * 64 + 64, f // 4 * 64 + 64)) for f in range(12)]


def anchor_points(path: Path) -> list[tuple[float, float]]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    if raw.get("contact_frame") != 7 or abs(raw.get("contact_second", -1) - .63) > 0.00001:
        raise ValueError("A53 contact timing must remain F7 at 0.63 seconds")
    poses = raw.get("pose_anchors", [])
    if len(poses) != 12 or [p.get("frame") for p in poses] != list(range(12)):
        raise ValueError("Expected twelve canonical A53 wrist anchors")
    return [tuple(float(z) for z in p["wrist_px"]) for p in poses]


def mask_count(mask: Image.Image) -> int:
    return sum(v >= 128 for v in mask.getdata())


def leakage(hidden_part: Image.Image, shield_alpha: Image.Image) -> int:
    return sum(a >= 128 and b < 128 for a, b in zip(hidden_part.getdata(), shield_alpha.getdata()))


def mask_region(alpha: Image.Image, xy: tuple[float, float], r: float = 3.0) -> Image.Image:
    # This is a wrist-region *candidate*, not anatomical segmentation authority.
    out = Image.new("L", (64, 64), 0)
    a = alpha.load()
    d = out.load()
    cx, cy = xy
    for y in range(64):
        for x in range(64):
            if a[x, y] >= 128 and (x - cx)**2 + (y-cy)**2 <= r * r:
                d[x, y] = 255
    return out


def shield_geometry(wrist: tuple[float, float]) -> tuple[Image.Image, Image.Image]:
    """Temporary geometry for depth/occlusion engineering, not an approved shield asset."""
    cx, cy = wrist
    cx -= 4.5
    cy -= 2
    shape = (round(cx - 9), round(cy - 12), round(cx + 9), round(cy + 12))
    image = Image.new("RGBA", (64, 64))
    d = ImageDraw.Draw(image)
    d.ellipse(shape, fill=(78, 54, 36, 255), outline=(194, 161, 105, 255), width=2)
    # Vertical wooden grain and small center boss.
    for dx in (-3, 0, 3):
        d.line((int(cx + dx), int(cy - 7), int(cx + dx), int(cy + 7)), fill=(108, 80, 48, 255), width=1)
    d.ellipse((round(cx-3), round(cy-3), round(cx+3), round(cy+3)), fill=(171, 178, 184, 255), outline=(74, 82, 91, 255), width=1)
    return image, image.getchannel("A")


def visible_tip(wrist: tuple[float, float]) -> Image.Image:
    # Deliberately *not* original FS equipment art, just a visible-blade proxy.
    cx, cy = wrist
    tip = Image.new("RGBA", (64, 64))
    d = ImageDraw.Draw(tip)
    x, y = int(cx - 25), int(cy - 5)
    d.polygon([(x, y+3), (x+8, y), (x+21, y+3), (x+8, y+6)], fill=(197, 206, 218, 255))
    d.line((x+6, y+3, x+20, y+3), fill=(115, 126, 161, 255))
    return tip


def alpha_edges(image: Image.Image) -> int:
    a = image.getchannel("A")
    return sum(int(a.getpixel((x,y)) >= 128)
               for x,y in ([(x,0) for x in range(64)] + [(x,63) for x in range(64)]
                           + [(0,y) for y in range(1,63)] + [(63,y) for y in range(1,63)]))


def verify_registration(body: Image.Image, shield: Image.Image, tip: Image.Image, out: Image.Image,
                        forbidden_mask: Image.Image, mask: Image.Image,
                        *, check_hidden: bool) -> dict:
    # Exact alpha compositing is needed: a mask hidden *behind* shield must
    # be proved occluded in the reference coordinate system, not just claim so.
    expected = Image.alpha_composite(Image.alpha_composite(body, shield), tip)
    if expected.tobytes() != out.tobytes():
        raise AssertionError("Layer compositor does not equal registered RGB+alpha source")
    count = mask_count(forbidden_mask)
    leak = leakage(forbidden_mask, mask)
    # The candidate only annotates the 3px wrist-region, NOT the whole forearm.
    # Missing wrist pixels mean we cannot infer a complete hand -> ART HOLD.
    if check_hidden and (leak or count < 1):
        raise AssertionError(f"Uncovered/empty A53 wrist region: leak={leak}, marked={count}")
    edge = alpha_edges(out)
    if edge:
        raise AssertionError("Frame content touches 64px edge")
    return {"marked_wrist_opaque_px": count, "uncovered_marked_wrist_px": leak,
            "composite_exact": True, "frame_edge_clipped_px": edge,
            "full_forearm_segmentation": "NOT_RUN"}


def compile_candidate(body_path: Path, anchor_path: Path, out_dir: Path) -> dict:
    frames = rgba_atlas_frames(body_path)
    wrist = anchor_points(anchor_path)
    # Keep the original exactly; the overlay is independent at runtime.
    raw_before = body_path.read_bytes()
    shielded = []
    mask_preview = []
    frame_report = []
    for frame, (body, hand) in enumerate(zip(frames, wrist)):
        overlay, mask = shield_geometry(hand)
        blade = visible_tip(hand)
        original_body = body.tobytes()
        rendered = Image.alpha_composite(Image.alpha_composite(body, overlay), blade)
        if body.tobytes() != original_body:
            raise AssertionError("Body memory modified")
        hidden_mask = mask_region(body.getchannel("A"), hand)
        check = verify_registration(body, overlay, blade, rendered, hidden_mask, mask,
                                    check_hidden=frame in REQUIRED_OCCLUDED_FRAMES)
        if frame in REQUIRED_OCCLUDED_FRAMES:
            # The intended exposed blade must be visibly outside the shield.
            visible_blade = leakage(blade.getchannel("A"), mask)
            if visible_blade < 8:
                raise AssertionError(f"F{frame} missing visible blade pixels")
            check["blade_outside_shield_px"] = visible_blade
        check.update({"frame": frame, "phase": "candidate_overlay_not_approved",
                      "wrist_position": list(hand)})
        frame_report.append(check)
        shielded.append(rendered)
        # Witness grid: white means existing A53 wrist-region, gold shield over it.
        colored = Image.new("RGBA", (64, 64), (19, 28, 38, 255))
        colored.alpha_composite(body)
        colored.alpha_composite(overlay)
        colored.alpha_composite(blade)
        mask_preview.append(colored)
    if body_path.read_bytes() != raw_before:
        raise AssertionError("Original A53 source bytes mutated")
    out_dir.mkdir(parents=True, exist_ok=True)
    sheet = Image.new("RGBA", (256, 192))
    original_sheet = Image.new("RGBA", (256, 192))
    for idx, (b,a) in enumerate(zip(shielded, frames)):
        xy=(idx % 4 *64, idx//4*64)
        sheet.paste(b,xy)
        original_sheet.paste(a,xy)
    sheet.save(out_dir / "A56_REAL_A53_SHIELD_CANDIDATE_12F.png")
    # 1x A/B side-by-side. This is NOT an approved new battle character.
    candidate_gif=[]
    for f in range(12):
        ab=Image.new("RGBA",(128,64),(19,28,38,255))
        ab.alpha_composite(frames[f],(0,0))
        ab.alpha_composite(shielded[f],(64,0))
        candidate_gif.append(ab)
    candidate_gif[0].save(out_dir / "A56_SOURCE_VS_SHIELD_CANDIDATE_NATIVE_1X.gif",save_all=True,
                          append_images=candidate_gif[1:],duration=100,loop=0,disposal=2)
    preview = sheet.resize((1024,768),Image.Resampling.NEAREST)
    preview.save(out_dir / "A56_CANDIDATE_ZOOM4X.png")
    report={"status":"ENGINEERING_CANDIDATE_ONLY", "engine":"PIL source registration (NOT Godot GPU)",
            "source_sha256":sha256(body_path),"source_preserved":True,
            "frames":frame_report,"F5_F6_wrist_occlusion":"pixel QA PASS; partial wrist region only",
            "real_full_hand_forearm_segmentation":"NOT_RUN", "source_art":"A53 real Body", 
            "shield_art":"NEW PROCEDURAL PLACEHOLDER, NOT FS CANONICAL",
            "art_gate":"HOLD", "runtime_godot":"NOT_RUN"}
    (out_dir / "A56_PIXEL_QA_REPORT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
    return report


def selftest() -> None:
    b=Image.new("RGBA",(64,64),(0,0,0,0))
    ImageDraw.Draw(b).ellipse((33,34,39,40),fill=(100,100,100,255))
    shield, mask=shield_geometry((36,38))
    hand=mask_region(b.getchannel("A"),(36,38),r=2)
    assert mask_count(hand)>0
    assert leakage(hand,mask)==0
    corrupted=mask.copy()
    ImageDraw.Draw(corrupted).rectangle((33,34,40,40),fill=0)
    assert leakage(hand,corrupted)>0
    tip=visible_tip((36,38))
    out=Image.alpha_composite(Image.alpha_composite(b,shield),tip)
    assert verify_registration(b,shield,tip,out,hand,mask,check_hidden=True)["composite_exact"]
    assert alpha_edges(out)==0
    print("A56_SELFTEST_PASS both occlusion positive and negative fail-closed")


def main() -> int:
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--body",type=Path)
    ap.add_argument("--anchors",type=Path)
    ap.add_argument("--out",type=Path)
    ap.add_argument("--selftest",action="store_true")
    args=ap.parse_args()
    if args.selftest:selftest()
    if args.body:
        if args.anchors is None or args.out is None:
            ap.error("--body also requires --anchors and --out")
        report=compile_candidate(args.body,args.anchors,args.out)
        print(json.dumps({"status":report["status"],"frames":len(report["frames"]),
                          "witness_f5_f6":[report["frames"][i] for i in REQUIRED_OCCLUDED_FRAMES]},
                         ensure_ascii=False,indent=2))
    return 0

if __name__=="__main__": raise SystemExit(main())
