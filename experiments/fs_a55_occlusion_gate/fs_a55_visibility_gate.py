#!/usr/bin/env python3
"""FS A55: fail-closed per-frame occlusion and immutable A53 Body QA.

Only diagnostics and synthetic QA samples are emitted. The original Body and
licensed Iconset are read-only and must remain in owner-private Google Drive.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

SIZE = (64, 64)
VISIBILITY = frozenset({"visible", "partially_occluded", "fully_occluded"})
EXPECTED_SHA_A53 = "af2b94a424ab613fa5a8ff45125f0398da3a20432cdeaa744f87f9f1b1a9ac44"


def pixels(mask: Image.Image, threshold: int = 128) -> int:
    return sum(1 for p in mask.convert("L").getdata() if p >= threshold)


def outside_pixels(part: Image.Image, occluder: Image.Image) -> int:
    if part.size != occluder.size:
        raise ValueError("part/occluder dimensions differ")
    return sum(
        1 for a, b in zip(part.convert("L").getdata(), occluder.convert("L").getdata())
        if a >= 128 and b < 128
    )


def edge_count(mask: Image.Image) -> int:
    m = mask.convert("L")
    w, h = m.size
    return sum(
        1 for x, y in
        [(x, 0) for x in range(w)] +
        [(x, h-1) for x in range(w)] +
        [(0, y) for y in range(1, h-1)] +
        [(w-1, y) for y in range(1, h-1)]
        if m.getpixel((x, y)) >= 128
    )


def validate_contract(contract: dict[str, Any]) -> list[str]:
    failures: list[str] = []
    if contract.get("status") not in {"reference_only", "qa_candidate", "approved"}:
        failures.append("contract_status_invalid")
    cases = contract.get("example_frames", contract.get("frames", []))
    if not isinstance(cases, list) or not cases:
        return failures + ["no_frames"]
    seen: set[tuple[str, str, int]] = set()
    for item in cases:
        if not isinstance(item, dict):
            failures.append("frame_not_object")
            continue
        frame = item.get("frame")
        direction = item.get("view")
        action = item.get("action")
        if not isinstance(frame, int) or not 0 <= frame < 12 or not direction or not action:
            failures.append("invalid_frame_or_view_or_action")
            continue
        key = (str(direction), str(action), frame)
        if key in seen:
            failures.append("duplicate_frame")
        seen.add(key)
        vis = item.get("part_visibility", {})
        if not isinstance(vis, dict) or not vis:
            failures.append("missing_visibility")
            continue
        if any(v not in VISIBILITY and v != "visible" for v in vis.values()):
            failures.append("invalid_part_visibility")
        hidden = {part for part, state in vis.items() if state == "fully_occluded"}
        hidden_guide = set(item.get("guide_must_exclude", []))
        if hidden and not item.get("occluder"):
            failures.append("hidden_part_without_occluder")
        if not hidden.issubset(hidden_guide):
            failures.append("hidden_part_missing_from_guide_exclusion")
        if not isinstance(item.get("pixel_ownership"), dict):
            failures.append("missing_pixel_ownership")
        if item.get("native_art_status") not in {"NOT_RUN", "ART_HOLD", "ENGINE_PASS", "ART_PASS"}:
            failures.append("unknown_art_status")
    return failures


def inspect_frame(
    *,
    guide_hand: Image.Image,
    final_hand: Image.Image,
    shield: Image.Image,
    blade: Image.Image,
    hand_status: str,
    blade_status: str,
    min_visible_tip: int,
) -> dict[str, Any]:
    for im in (guide_hand, final_hand, shield, blade):
        if im.size != SIZE:
            raise ValueError("A55 fixture images must be 64x64")
    failures: list[str] = []
    guide_hidden = pixels(guide_hand)
    hand_leak = outside_pixels(final_hand, shield)
    blade_outside = outside_pixels(blade, shield)
    occluder_count = pixels(shield)
    if hand_status == "fully_occluded":
        if guide_hidden:
            failures.append("guide_draws_occluded_hand")
        if hand_leak:
            failures.append("visible_hand_outside_occluder")
        if not occluder_count:
            failures.append("occluder_missing")
    if blade_status == "partially_occluded" and blade_outside < min_visible_tip:
        failures.append("visible_blade_tip_insufficient")
    if edge_count(blade) or edge_count(final_hand) or edge_count(shield):
        failures.append("clip_on_sprite_canvas_edge")
    return {
        "pass": not failures,
        "failure_reasons": failures,
        "guide_hidden_hand_px": guide_hidden,
        "uncovered_hand_px": hand_leak,
        "visible_blade_tip_px": blade_outside,
        "occluder_px": occluder_count,
        "edge_clip_px": edge_count(blade) + edge_count(final_hand) + edge_count(shield),
    }


def synthetic_case(frame: int, *, corrected: bool) -> tuple[dict[str, Image.Image], Image.Image]:
    """A deliberately non-FS synthetic reference, NEVER an approved game sprite."""
    if frame not in (5, 6):
        raise ValueError("synthetic occlusion demonstration is only F5/F6")
    guide_hand = Image.new("L", SIZE, 0)
    final_hand = Image.new("L", SIZE, 0)
    shield = Image.new("L", SIZE, 0)
    blade = Image.new("L", SIZE, 0)
    shift = frame - 5
    ImageDraw.Draw(shield).ellipse((23, 20+shift, 45, 43+shift), fill=255)
    ImageDraw.Draw(blade).polygon(
        [(9, 27+shift), (21, 25+shift), (28, 30+shift), (21, 34+shift)],
        fill=255
    )
    if not corrected:
        ImageDraw.Draw(guide_hand).ellipse((42, 28+shift, 52, 37+shift), fill=255)
        ImageDraw.Draw(final_hand).ellipse((42, 28+shift, 52, 37+shift), fill=255)

    bg = Image.new("RGBA", SIZE, (18, 29, 41, 255))
    draw = ImageDraw.Draw(bg)
    draw.ellipse((26, 12, 44, 33), fill=(173, 183, 193, 255))
    draw.rectangle((31, 32, 40, 48), fill=(134, 142, 150, 255))
    draw.line((35, 46, 29, 56), fill=(185, 188, 183, 255), width=3)
    draw.line((38, 46, 44, 56), fill=(185, 188, 183, 255), width=3)
    if not corrected:
        draw.ellipse((42, 28+shift, 52, 37+shift), fill=(219, 153, 98, 255))
    draw.ellipse((23, 20+shift, 45, 43+shift), fill=(118, 83, 46, 255), outline=(215, 204, 176, 255), width=3)
    draw.polygon([(9,27+shift), (21,25+shift), (28,30+shift), (21,34+shift)], fill=(188, 205, 215, 255))
    return {
        "guide_hand": guide_hand, "final_hand": final_hand,
        "shield": shield, "blade": blade
    }, bg


def audit_a53_body(body_path: Path, anchors_path: Path | None, iconset_path: Path | None) -> dict[str, Any]:
    raw = body_path.read_bytes()
    source_sha = hashlib.sha256(raw).hexdigest()
    sheet = Image.open(body_path).convert("RGBA")
    failed: list[str] = []
    if source_sha != EXPECTED_SHA_A53:
        failed.append("body_sha_does_not_match_authorized_A53")
    if sheet.size != (256, 192):
        failed.append("atlas_dimensions_not_256x192")
    frames: list[dict[str, Any]] = []
    if sheet.size == (256, 192):
        seen: set[bytes] = set()
        for idx in range(12):
            f = sheet.crop(((idx % 4) * 64, (idx // 4) * 64, (idx % 4 + 1) * 64, (idx // 4 + 1) * 64))
            seen.add(f.tobytes())
            mask = f.getchannel("A")
            count = pixels(mask)
            clipped = edge_count(mask)
            if clipped:
                failed.append(f"body_frame_{idx}_edge_clipped")
            if count < 100:
                failed.append(f"body_frame_{idx}_suspiciously_empty")
            frames.append({"frame": idx, "visible_alpha_px": count, "border_alpha_px": clipped})
        if len(seen) < 10:
            failed.append("insufficient_unique_body_frames")
    if anchors_path:
        data = json.loads(anchors_path.read_text(encoding="utf-8"))
        poses = data.get("pose_anchors", [])
        if len(poses) != 12 or [p.get("frame") for p in poses] != list(range(12)):
            failed.append("hand_anchor_frames_not_0_to_11")
        else:
            for f in poses:
                wrist = f.get("wrist_px", [])
                if len(wrist) != 2 or not all(0 <= float(v) < 64 for v in wrist):
                    failed.append("wrist_outside_body_canvas")
                    break
        if data.get("contact_frame") != 7 or abs(float(data.get("contact_second", -1)) - 0.63) > .0001:
            failed.append("A53_contact_timing_changed")
    if iconset_path:
        icon = Image.open(iconset_path)
        if icon.width != 384 or icon.height % 24:
            failed.append("original_iconset_24px_grid_mismatch")
    return {
        "stage": "A55_REAL_A53_READ_ONLY_BASELINE",
        "pass": not failed,
        "failure_reasons": failed,
        "source_sha256": source_sha,
        "atlas_size": list(sheet.size),
        "frame_count": len(frames),
        "frames": frames,
        "armor_shield_assessment": "NOT_APPLICABLE: A53 canonical Body has no shield-occluded guide",
        "native_engine": "NOT_RUN",
        "art": "HOLD",
    }


def run_selftest(outdir: Path | None) -> dict[str, Any]:
    bad, bad_imgs = [], []
    good, good_imgs = [], []
    for frame in (5, 6):
        old_masks, before = synthetic_case(frame, corrected=False)
        new_masks, after = synthetic_case(frame, corrected=True)
        old = inspect_frame(**old_masks, hand_status="fully_occluded", blade_status="partially_occluded", min_visible_tip=15)
        new = inspect_frame(**new_masks, hand_status="fully_occluded", blade_status="partially_occluded", min_visible_tip=15)
        if old["pass"] or not {"guide_draws_occluded_hand", "visible_hand_outside_occluder"}.issubset(old["failure_reasons"]):
            raise AssertionError(f"negative control improperly passed at F{frame}: {old}")
        if not new["pass"]:
            raise AssertionError(f"positive control failed at F{frame}: {new}")
        bad.append({"frame": frame, **old})
        good.append({"frame": frame, **new})
        bad_imgs.append(before)
        good_imgs.append(after)
    if outdir:
        outdir.mkdir(parents=True, exist_ok=True)
        samples: list[Image.Image] = []
        for before, after in zip(bad_imgs, good_imgs):
            canvas = Image.new("RGBA", (128, 64))
            canvas.paste(before, (0, 0))
            canvas.paste(after, (64, 0))
            samples.append(canvas)
        samples[0].save(outdir / "A55_SYNTHETIC_F5_F6_BEFORE_AFTER.gif",
                        save_all=True, append_images=samples[1:], duration=350, loop=0, disposal=2)
        samples[0].resize((512, 256), Image.Resampling.NEAREST).save(
            outdir / "A55_SYNTHETIC_F5_BEFORE_AFTER_4X.png")
    return {
        "stage": "A55_SYNTHETIC_OCCLUSION_REGRESSION",
        "synthetic_not_real_FS_asset": True,
        "result": "PASS",
        "negative_controls_detected": bad,
        "positive_controls_passed": good,
        "godot_native": "NOT_RUN",
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--body", type=Path)
    ap.add_argument("--anchors", type=Path)
    ap.add_argument("--iconset", type=Path)
    ap.add_argument("--contract", type=Path)
    ap.add_argument("--output", type=Path, help="optional synthetic QA image directory")
    args = ap.parse_args()
    if not (args.selftest or args.body or args.contract):
        ap.error("at least one of --selftest, --body, --contract is needed")
    result: dict[str, Any] = {}
    if args.contract:
        contract = json.loads(args.contract.read_text(encoding="utf-8"))
        problems = validate_contract(contract)
        result["manifest"] = {"pass": not problems, "errors": problems}
    if args.selftest:
        result["synthetic"] = run_selftest(args.output)
    if args.body:
        result["real_A53_source"] = audit_a53_body(args.body, args.anchors, args.iconset)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if all(
        v.get("pass", v.get("result") == "PASS")
        for v in result.values()
    ) else 1


if __name__ == "__main__":
    raise SystemExit(main())
