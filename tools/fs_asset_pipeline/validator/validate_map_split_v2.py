#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Forest Symphony whole-map Binary Ground/PAR Validator v2.0.

Authority:
  GROUND = true ground/terrain surfaces + floor/terrain tiles + flowers + grass.
  PAR    = EVERYTHING ELSE.
  Primary completeness = MASTER ≈ GROUND + COMPLETE PAR.

This validator intentionally does NOT use a whole-SAM2-mask PAR coverage threshold.
SAM2 masks are optional QA evidence only.

Exit codes:
  0 = PASS / PASS_WITH_WARNINGS
  2 = FAIL
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

from PIL import Image, ImageChops

VERSION = "2.0"
STATUS_PASS = "PASS"
STATUS_WARN = "PASS_WITH_WARNINGS"
STATUS_FAIL = "FAIL"


def issue(code: str, message: str, **details: Any) -> Dict[str, Any]:
    out: Dict[str, Any] = {"code": code, "message": message}
    if details:
        out["details"] = details
    return out


def load_image(path: Path, label: str, failures: List[Dict[str, Any]]) -> Optional[Image.Image]:
    if not path.exists():
        failures.append(issue("FAIL_REQUIRED_FILE_MISSING", f"Missing {label}", path=str(path)))
        return None
    try:
        img = Image.open(path)
        img.load()
    except Exception as exc:
        failures.append(issue("FAIL_IMAGE_OPEN_ERROR", f"Cannot open {label}", path=str(path), error=str(exc)))
        return None
    return img.convert("RGBA")


def percentile(values: Sequence[int], q: float) -> int:
    if not values:
        return 0
    s = sorted(values)
    idx = min(len(s) - 1, max(0, int(math.ceil(q * len(s))) - 1))
    return int(s[idx])


def rgba_rgb_diff_metrics(master: Image.Image, candidate: Image.Image, delta_threshold: int) -> Dict[str, Any]:
    m = list(master.getdata())
    c = list(candidate.getdata())
    max_deltas: List[int] = []
    sum_abs = 0
    bad = 0
    for (mr, mg, mb, _ma), (cr, cg, cb, _ca) in zip(m, c):
        dr, dg, db = abs(mr - cr), abs(mg - cg), abs(mb - cb)
        dmax = max(dr, dg, db)
        max_deltas.append(dmax)
        sum_abs += dr + dg + db
        if dmax > delta_threshold:
            bad += 1
    n = max(1, len(m))
    return {
        "mean_abs_rgb": sum_abs / (n * 3.0),
        "p95_max_rgb_delta": percentile(max_deltas, 0.95),
        "max_rgb_delta": max(max_deltas) if max_deltas else 0,
        "bad_pixels": bad,
        "bad_ratio": bad / n,
        "delta_threshold": delta_threshold,
    }


def par_source_fidelity(master: Image.Image, par: Image.Image, delta_threshold: int) -> Dict[str, Any]:
    m = list(master.getdata())
    p = list(par.getdata())
    visible = 0
    bad = 0
    sum_abs = 0
    max_deltas: List[int] = []
    for (mr, mg, mb, _ma), (pr, pg, pb, pa) in zip(m, p):
        if pa <= 0:
            continue
        visible += 1
        dr, dg, db = abs(mr - pr), abs(mg - pg), abs(mb - pb)
        dmax = max(dr, dg, db)
        max_deltas.append(dmax)
        sum_abs += dr + dg + db
        if dmax > delta_threshold:
            bad += 1
    denom = max(1, visible)
    return {
        "visible_pixels": visible,
        "mean_abs_rgb": sum_abs / (denom * 3.0),
        "p95_max_rgb_delta": percentile(max_deltas, 0.95),
        "max_rgb_delta": max(max_deltas) if max_deltas else 0,
        "bad_pixels": bad,
        "bad_ratio": bad / denom,
        "delta_threshold": delta_threshold,
    }


def alpha_metrics(img: Image.Image) -> Dict[str, int]:
    alphas = list(img.getchannel("A").getdata())
    return {
        "transparent_pixels": sum(1 for a in alphas if a == 0),
        "partial_alpha_pixels": sum(1 for a in alphas if 0 < a < 255),
        "opaque_pixels": sum(1 for a in alphas if a == 255),
        "visible_pixels": sum(1 for a in alphas if a > 0),
    }


def chroma_residue_count(img: Image.Image) -> Dict[str, int]:
    magenta = green = 0
    for r, g, b, a in img.getdata():
        if a <= 0:
            continue
        if (r, g, b) == (255, 0, 255):
            magenta += 1
        if (r, g, b) == (0, 255, 0):
            green += 1
    return {"magenta": magenta, "green": green, "total": magenta + green}


def circle_pixels(x: int, y: int, radius: int, width: int, height: int) -> Iterable[Tuple[int, int, float]]:
    r2 = radius * radius
    for yy in range(max(0, y - radius), min(height, y + radius + 1)):
        for xx in range(max(0, x - radius), min(width, x + radius + 1)):
            d2 = (xx - x) ** 2 + (yy - y) ** 2
            if d2 <= r2:
                yield xx, yy, math.sqrt(d2)


def validate_witnesses(
    par: Image.Image,
    manifest: Dict[str, Any],
    failures: List[Dict[str, Any]],
    warnings: List[Dict[str, Any]],
) -> Dict[str, Any]:
    defaults = manifest.get("defaults") if isinstance(manifest.get("defaults"), dict) else {}
    default_radius = int(defaults.get("radius", 4))
    default_min_alpha = int(defaults.get("min_par_alpha", 1))
    default_min_coverage = float(defaults.get("min_coverage_ratio", 0.08))
    default_max_nearest = float(defaults.get("max_nearest_distance", 3.0))
    require_visual = bool(defaults.get("require_visual_confirmation", True))

    objects = manifest.get("objects")
    if not isinstance(objects, list) or not objects:
        failures.append(issue("FAIL_WITNESS_MANIFEST_EMPTY", "Witness manifest must contain objects"))
        return {"objects": [], "object_pass": 0, "object_fail": 0, "witness_pass": 0, "witness_fail": 0}

    w, h = par.size
    object_rows: List[Dict[str, Any]] = []
    witness_pass = witness_fail = 0
    object_pass = object_fail = 0

    for obj in objects:
        oid = str(obj.get("id", "UNKNOWN"))
        label = str(obj.get("label", oid))
        object_confirmed = bool(obj.get("visual_confirmed", False))
        witnesses = obj.get("witnesses")
        if not isinstance(witnesses, list) or not witnesses:
            failures.append(issue("FAIL_OBJECT_HAS_NO_WITNESSES", f"{oid} has no witness points", object_id=oid))
            object_fail += 1
            object_rows.append({"id": oid, "label": label, "status": STATUS_FAIL, "witnesses": []})
            continue

        rows: List[Dict[str, Any]] = []
        obj_failed = False
        for i, wp in enumerate(witnesses, start=1):
            x = int(wp.get("x"))
            y = int(wp.get("y"))
            radius = int(wp.get("radius", default_radius))
            min_alpha = int(wp.get("min_par_alpha", default_min_alpha))
            min_coverage = float(wp.get("min_coverage_ratio", default_min_coverage))
            max_nearest = float(wp.get("max_nearest_distance", default_max_nearest))
            required = bool(wp.get("required", True))
            point_confirmed = bool(wp.get("visual_confirmed", object_confirmed))

            if not (0 <= x < w and 0 <= y < h):
                row = {"index": i, "x": x, "y": y, "status": STATUS_FAIL, "reason": "out_of_bounds"}
                rows.append(row)
                if required:
                    failures.append(issue("FAIL_WITNESS_OUT_OF_BOUNDS", f"{oid} witness {i} is out of bounds", object_id=oid, x=x, y=y))
                    witness_fail += 1
                    obj_failed = True
                continue

            if require_visual and not point_confirmed:
                row = {"index": i, "x": x, "y": y, "status": STATUS_FAIL, "reason": "not_visual_confirmed"}
                rows.append(row)
                if required:
                    failures.append(issue(
                        "FAIL_WITNESS_NOT_VISUAL_CONFIRMED",
                        f"{oid} witness {i} is not visually confirmed as non-Ground core structure",
                        object_id=oid,
                        x=x,
                        y=y,
                    ))
                    witness_fail += 1
                    obj_failed = True
                continue

            pixels = list(circle_pixels(x, y, radius, w, h))
            hit = 0
            nearest: Optional[float] = None
            for xx, yy, dist in pixels:
                if par.getpixel((xx, yy))[3] >= min_alpha:
                    hit += 1
                    nearest = dist if nearest is None else min(nearest, dist)
            coverage = hit / max(1, len(pixels))
            center_alpha = par.getpixel((x, y))[3]
            passed = nearest is not None and nearest <= max_nearest and coverage >= min_coverage
            row = {
                "index": i,
                "x": x,
                "y": y,
                "role": wp.get("role"),
                "radius": radius,
                "center_alpha": center_alpha,
                "coverage_ratio": coverage,
                "nearest_par_distance": nearest,
                "status": STATUS_PASS if passed else STATUS_FAIL,
            }
            rows.append(row)
            if passed:
                witness_pass += 1
            else:
                witness_fail += 1
                if required:
                    obj_failed = True
                    failures.append(issue(
                        "FAIL_PAR_WITNESS_MISSING",
                        f"PAR missing near required core witness for {oid}",
                        object_id=oid,
                        witness_index=i,
                        x=x,
                        y=y,
                        coverage_ratio=coverage,
                        nearest_par_distance=nearest,
                    ))
                else:
                    warnings.append(issue(
                        "WARN_OPTIONAL_PAR_WITNESS_MISSING",
                        f"Optional PAR witness missing for {oid}",
                        object_id=oid,
                        witness_index=i,
                    ))

        if obj_failed:
            object_fail += 1
            status = STATUS_FAIL
        else:
            object_pass += 1
            status = STATUS_PASS
        object_rows.append({"id": oid, "label": label, "status": status, "witnesses": rows})

    return {
        "objects": object_rows,
        "object_pass": object_pass,
        "object_fail": object_fail,
        "witness_pass": witness_pass,
        "witness_fail": witness_fail,
    }


def sam2_evidence(
    audit_path: Optional[Path],
    mask_dir: Optional[Path],
    par: Optional[Image.Image],
    expected_size: Optional[Tuple[int, int]],
    warnings: List[Dict[str, Any]],
) -> Dict[str, Any]:
    """Collect optional SAM2 overlap evidence. NEVER gates PAR completeness."""
    if audit_path is None:
        return {"enabled": False, "note": "SAM2 evidence not supplied; no effect on formal result"}
    try:
        audit = json.loads(audit_path.read_text(encoding="utf-8"))
    except Exception as exc:
        warnings.append(issue("WARN_SAM2_AUDIT_UNREADABLE", "SAM2 audit could not be read; formal gate unaffected", error=str(exc)))
        return {"enabled": False, "error": str(exc)}

    rows: List[Dict[str, Any]] = []
    audit_size = (int(audit.get("width", -1)), int(audit.get("height", -1)))
    if expected_size and audit_size != expected_size:
        warnings.append(issue("WARN_SAM2_AUDIT_SIZE_MISMATCH", "SAM2 audit canvas differs from Master; evidence only", audit_size=list(audit_size), master_size=list(expected_size)))

    for obj in audit.get("objects", []):
        row: Dict[str, Any] = {
            "id": obj.get("id"),
            "label": obj.get("label"),
            "box": obj.get("box"),
            "mask_file": obj.get("mask_file"),
            "audit_mask_pixels": obj.get("mask_pixels"),
            "audit_mask_canvas_ratio": obj.get("mask_canvas_ratio"),
        }
        mask_file = obj.get("mask_file")
        if mask_dir and par is not None and mask_file:
            path = mask_dir / str(mask_file)
            if path.exists():
                try:
                    mask = Image.open(path).convert("RGBA")
                    if mask.size == par.size:
                        mask_bits = [a > 0 for a in mask.getchannel("A").getdata()]
                        par_bits = [a > 0 for a in par.getchannel("A").getdata()]
                        mask_visible = sum(mask_bits)
                        overlap = sum(1 for m, p in zip(mask_bits, par_bits) if m and p)
                        row["measured_mask_pixels"] = mask_visible
                        row["par_overlap_pixels"] = overlap
                        row["par_overlap_ratio_evidence_only"] = overlap / max(1, mask_visible)
                    else:
                        row["mask_note"] = "mask_canvas_mismatch"
                except Exception as exc:
                    row["mask_note"] = f"mask_read_error: {exc}"
            else:
                row["mask_note"] = "mask_not_found"
        rows.append(row)

    return {
        "enabled": True,
        "authority": "QA_EVIDENCE_ONLY_NO_WHOLE_MASK_THRESHOLD",
        "asset_id": audit.get("asset_id"),
        "objects": rows,
    }


def save_diff(master: Image.Image, recomposed: Image.Image, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    recomposed.save(out_dir / "recomposed.png")
    diff = ImageChops.difference(master.convert("RGB"), recomposed.convert("RGB"))
    diff.save(out_dir / "diff_rgb.png")
    heat = Image.new("RGBA", master.size, (0, 0, 0, 255))
    src = list(diff.getdata())
    heat.putdata([(min(255, max(r, g, b) * 4), 0, 0, 255) for r, g, b in src])
    heat.save(out_dir / "diff_heatmap.png")


def validate(
    master_path: Path,
    ground_path: Path,
    par_path: Path,
    witness_path: Path,
    out_dir: Path,
    sam2_audit_path: Optional[Path] = None,
    sam2_mask_dir: Optional[Path] = None,
) -> Dict[str, Any]:
    failures: List[Dict[str, Any]] = []
    warnings: List[Dict[str, Any]] = []
    info: List[Dict[str, Any]] = []
    metrics: Dict[str, Any] = {"validator_version": VERSION}

    try:
        manifest = json.loads(witness_path.read_text(encoding="utf-8"))
    except Exception as exc:
        return finalize(failures=[issue("FAIL_WITNESS_MANIFEST_UNREADABLE", "Cannot read witness manifest", error=str(exc))], warnings=[], info=[], metrics=metrics)

    master = load_image(master_path, "Master", failures)
    ground = load_image(ground_path, "Ground", failures)
    par = load_image(par_path, "Complete PAR", failures)
    if master is None or ground is None or par is None:
        return finalize(failures, warnings, info, metrics)

    expected_canvas = manifest.get("canvas")
    if isinstance(expected_canvas, list) and len(expected_canvas) == 2:
        expected_size = (int(expected_canvas[0]), int(expected_canvas[1]))
        if master.size != expected_size:
            failures.append(issue("FAIL_MASTER_CANVAS_MISMATCH", "Master canvas differs from witness Authority", expected=list(expected_size), actual=list(master.size)))
    else:
        expected_size = master.size
        warnings.append(issue("WARN_WITNESS_CANVAS_NOT_DECLARED", "Witness manifest does not declare canvas; Master size used"))

    if ground.size != master.size:
        failures.append(issue("FAIL_GROUND_CANVAS_MISMATCH", "Ground canvas differs from Master", master=list(master.size), ground=list(ground.size)))
    if par.size != master.size:
        failures.append(issue("FAIL_PAR_CANVAS_MISMATCH", "PAR canvas differs from Master", master=list(master.size), par=list(par.size)))
    if failures:
        return finalize(failures, warnings, info, metrics)

    thresholds = manifest.get("thresholds") if isinstance(manifest.get("thresholds"), dict) else {}
    recomp_delta = int(thresholds.get("recomposition_delta", 24))
    recomp_bad_ratio_max = float(thresholds.get("recomposition_bad_ratio_max", 0.02))
    recomp_mean_max = float(thresholds.get("recomposition_mean_abs_rgb_max", 4.0))
    source_delta = int(thresholds.get("par_source_delta", 24))
    source_bad_ratio_max = float(thresholds.get("par_source_bad_ratio_max", 0.02))

    metrics["canvas"] = list(master.size)
    metrics["master_alpha"] = alpha_metrics(master)
    metrics["ground_alpha"] = alpha_metrics(ground)
    metrics["par_alpha"] = alpha_metrics(par)

    if metrics["par_alpha"]["transparent_pixels"] == 0:
        failures.append(issue("FAIL_PAR_HAS_NO_TRANSPARENCY", "Complete PAR must use true alpha transparency outside objects"))

    partial = metrics["par_alpha"]["partial_alpha_pixels"]
    total = master.width * master.height
    if partial > 0:
        ratio = partial / max(1, total)
        warnings.append(issue("WARN_PAR_PARTIAL_ALPHA", "PAR contains partial-alpha pixels; inspect edge cleanliness", count=partial, ratio=ratio))

    chroma = chroma_residue_count(par)
    metrics["par_chroma_residue"] = chroma
    if chroma["total"] > 0:
        failures.append(issue("FAIL_PAR_CHROMA_RESIDUE", "PAR contains exact chroma-key residue", **chroma))

    recomposed = Image.alpha_composite(ground, par)
    save_diff(master, recomposed, out_dir)
    recomp = rgba_rgb_diff_metrics(master, recomposed, recomp_delta)
    metrics["recomposition"] = recomp
    if recomp["bad_ratio"] > recomp_bad_ratio_max or recomp["mean_abs_rgb"] > recomp_mean_max:
        failures.append(issue(
            "FAIL_RECOMPOSITION_DIVERGENCE",
            "MASTER ≈ GROUND + COMPLETE PAR gate failed",
            bad_ratio=recomp["bad_ratio"],
            bad_ratio_max=recomp_bad_ratio_max,
            mean_abs_rgb=recomp["mean_abs_rgb"],
            mean_abs_rgb_max=recomp_mean_max,
        ))

    source = par_source_fidelity(master, par, source_delta)
    metrics["par_source_fidelity"] = source
    if source["visible_pixels"] == 0:
        failures.append(issue("FAIL_PAR_EMPTY", "Complete PAR has no visible pixels"))
    elif source["bad_ratio"] > source_bad_ratio_max:
        failures.append(issue(
            "FAIL_PAR_SOURCE_FIDELITY",
            "Visible PAR pixels are not sufficiently registered/fidelitous to Master",
            bad_ratio=source["bad_ratio"],
            bad_ratio_max=source_bad_ratio_max,
        ))

    witness_report = validate_witnesses(par, manifest, failures, warnings)
    metrics["witness"] = {
        "object_pass": witness_report["object_pass"],
        "object_fail": witness_report["object_fail"],
        "witness_pass": witness_report["witness_pass"],
        "witness_fail": witness_report["witness_fail"],
    }

    sam2 = sam2_evidence(sam2_audit_path, sam2_mask_dir, par, master.size, warnings)

    info.append(issue(
        "INFO_BINARY_AUTHORITY",
        "GROUND=true terrain/floor + flowers + grass; PAR=everything else; actor occlusion irrelevant",
    ))
    info.append(issue(
        "INFO_SAM2_POLICY",
        "SAM2 overlap is recorded only as QA evidence and never used as a whole-mask coverage gate",
    ))

    report = finalize(failures, warnings, info, metrics)
    report["witness_detail"] = witness_report["objects"]
    report["sam2_evidence"] = sam2
    return report


def finalize(
    failures: List[Dict[str, Any]],
    warnings: List[Dict[str, Any]],
    info: List[Dict[str, Any]],
    metrics: Dict[str, Any],
) -> Dict[str, Any]:
    status = STATUS_FAIL if failures else (STATUS_WARN if warnings else STATUS_PASS)
    return {
        "validator": "FS_MAP_SPLIT_BINARY_PAR_COMPLETENESS",
        "validator_version": VERSION,
        "status": status,
        "fail_count": len(failures),
        "warn_count": len(warnings),
        "info_count": len(info),
        "failures": failures,
        "warnings": warnings,
        "info": info,
        "metrics": metrics,
    }


def main() -> int:
    p = argparse.ArgumentParser(description="Validate Forest Symphony whole-map Master/Ground/Complete-PAR split")
    p.add_argument("--master", required=True, type=Path)
    p.add_argument("--ground", required=True, type=Path)
    p.add_argument("--par", required=True, type=Path)
    p.add_argument("--witnesses", required=True, type=Path)
    p.add_argument("--out", required=True, type=Path, help="QA output directory")
    p.add_argument("--sam2-audit", type=Path, default=None, help="Optional guided_audit.json; evidence only")
    p.add_argument("--sam2-mask-dir", type=Path, default=None, help="Optional SAM2 mask directory; evidence only")
    p.add_argument("--report", type=Path, default=None)
    args = p.parse_args()

    report = validate(args.master, args.ground, args.par, args.witnesses, args.out, args.sam2_audit, args.sam2_mask_dir)
    text = json.dumps(report, ensure_ascii=False, indent=2)
    print(text)
    report_path = args.report or (args.out / "validation_report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(text + "\n", encoding="utf-8")
    return 2 if report["status"] == STATUS_FAIL else 0


if __name__ == "__main__":
    raise SystemExit(main())
