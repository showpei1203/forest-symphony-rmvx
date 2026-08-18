#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Forest Symphony Asset Validator v0.1.

Validates a Master Object + D1/D3/D4 masks + metadata bundle.
Exit codes:
  0 = PASS / PASS_WITH_WARNINGS
  2 = FAIL
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

from PIL import Image


def _pixels(image: Image.Image):
    """Pillow-compatible pixel iterator without relying on a single API generation."""
    getter = getattr(image, "get_flattened_data", None)
    return getter() if getter is not None else image.getdata()

STATUS_PASS = "PASS"
STATUS_WARN = "PASS_WITH_WARNINGS"
STATUS_FAIL = "FAIL"

REQUIRED_META_FIELDS = (
    "asset_id",
    "family",
    "category",
    "source_master",
    "masks",
    "anchor",
    "export_rules",
)


def _issue(code: str, message: str, **details: Any) -> Dict[str, Any]:
    out: Dict[str, Any] = {"code": code, "message": message}
    if details:
        out["details"] = details
    return out


def _visible_mask_pixels(image: Image.Image) -> Tuple[bytes, int, int]:
    """Return boolean membership bytes, visible count, partial-alpha count."""
    rgba = image.convert("RGBA")
    data = list(_pixels(rgba))
    membership = bytearray(len(data))
    visible = 0
    partial = 0
    for i, (_, _, _, a) in enumerate(data):
        if 0 < a < 255:
            partial += 1
        if a > 0:
            membership[i] = 1
            visible += 1
    return bytes(membership), visible, partial


def _bbox_from_membership(bits: bytes, size: Tuple[int, int]) -> Optional[List[int]]:
    width, height = size
    xs: List[int] = []
    ys: List[int] = []
    for idx, value in enumerate(bits):
        if value:
            y, x = divmod(idx, width)
            xs.append(x)
            ys.append(y)
    if not xs:
        return None
    return [min(xs), min(ys), max(xs) + 1, max(ys) + 1]


def _count_intersection(a: bytes, b: bytes) -> int:
    return sum(1 for x, y in zip(a, b) if x and y)


def _same_membership(a: bytes, b: bytes) -> bool:
    return a == b


def _load_png(path: Path, label: str, failures: List[Dict[str, Any]]) -> Optional[Image.Image]:
    if not path.exists():
        failures.append(_issue("FAIL_REQUIRED_FILE_MISSING", f"Missing {label}: {path.name}"))
        return None
    try:
        img = Image.open(path)
        img.load()
    except Exception as exc:
        failures.append(_issue("FAIL_IMAGE_OPEN_ERROR", f"Cannot open {label}: {path.name}", error=str(exc)))
        return None
    if img.format != "PNG":
        failures.append(_issue("FAIL_NOT_PNG", f"{label} is not PNG", file=path.name, format=img.format))
    if img.mode != "RGBA":
        failures.append(_issue(f"FAIL_{label.upper()}_NOT_RGBA", f"{label} must be RGBA", file=path.name, mode=img.mode))
    return img.convert("RGBA")


def _validate_binary_mask(
    image: Image.Image,
    label: str,
    failures: List[Dict[str, Any]],
) -> None:
    partial_alpha = 0
    invalid_visible_color = 0
    for r, g, b, a in _pixels(image):
        if 0 < a < 255:
            partial_alpha += 1
        if a > 0 and (r, g, b, a) != (255, 255, 255, 255):
            invalid_visible_color += 1
    if partial_alpha:
        failures.append(_issue("FAIL_MASK_HAS_PARTIAL_ALPHA", f"{label} has partial alpha pixels", count=partial_alpha))
    if invalid_visible_color:
        failures.append(_issue("FAIL_MASK_HAS_INVALID_VISIBLE_COLOR", f"{label} visible pixels must be opaque white", count=invalid_visible_color))


def validate_asset_bundle(asset_dir: Path | str, meta_path: Path | str | None = None) -> Dict[str, Any]:
    asset_dir = Path(asset_dir)
    failures: List[Dict[str, Any]] = []
    warnings: List[Dict[str, Any]] = []
    info: List[Dict[str, Any]] = []

    if meta_path is None:
        metas = sorted(asset_dir.glob("*.meta.json"))
        if len(metas) != 1:
            failures.append(_issue("FAIL_META_DISCOVERY", "Expected exactly one *.meta.json", found=[p.name for p in metas]))
            return _finalize("UNKNOWN", failures, warnings, info, {})
        meta_file = metas[0]
    else:
        meta_file = Path(meta_path)
        if not meta_file.is_absolute():
            meta_file = asset_dir / meta_file

    try:
        meta = json.loads(meta_file.read_text(encoding="utf-8"))
    except Exception as exc:
        failures.append(_issue("FAIL_JSON_PARSE_ERROR", f"Cannot parse metadata: {meta_file.name}", error=str(exc)))
        return _finalize("UNKNOWN", failures, warnings, info, {})

    asset_id = str(meta.get("asset_id") or "UNKNOWN")

    for field in REQUIRED_META_FIELDS:
        if field not in meta:
            failures.append(_issue("FAIL_META_REQUIRED_FIELD_MISSING", f"Metadata missing required field: {field}", field=field))

    expected_meta_name = f"{asset_id}.meta.json"
    if asset_id != "UNKNOWN" and meta_file.name != expected_meta_name:
        failures.append(_issue("FAIL_INVALID_FILENAME_PATTERN", "Metadata filename does not match asset_id", expected=expected_meta_name, actual=meta_file.name))

    source_master = meta.get("source_master")
    masks = meta.get("masks") if isinstance(meta.get("masks"), dict) else {}

    expected_master = f"{asset_id}_Master.png"
    if source_master and source_master != expected_master:
        failures.append(_issue("FAIL_META_MASTER_FILENAME_MISMATCH", "source_master does not match asset_id naming", expected=expected_master, actual=source_master))

    expected_mask_names = {layer: f"{asset_id}_{layer}.png" for layer in ("D1", "D3", "D4")}
    for layer, expected_name in expected_mask_names.items():
        actual = masks.get(layer)
        if not actual:
            failures.append(_issue("FAIL_META_REQUIRED_FIELD_MISSING", f"Metadata masks missing {layer}", field=f"masks.{layer}"))
        elif actual != expected_name:
            failures.append(_issue("FAIL_META_MASK_FILENAME_MISMATCH", f"{layer} filename does not match asset_id naming", expected=expected_name, actual=actual))

    master_path = asset_dir / str(source_master or expected_master)
    master = _load_png(master_path, "master", failures)

    mask_images: Dict[str, Image.Image] = {}
    for layer in ("D1", "D3", "D4"):
        mask_path = asset_dir / str(masks.get(layer) or expected_mask_names[layer])
        img = _load_png(mask_path, f"mask_{layer.lower()}", failures)
        if img is not None:
            mask_images[layer] = img
            _validate_binary_mask(img, layer, failures)

    if master is not None:
        alpha = master.getchannel("A")
        alpha_values = list(_pixels(alpha))
        transparent_count = sum(1 for a in alpha_values if a == 0)
        partial_count = sum(1 for a in alpha_values if 0 < a < 255)
        visible_count = sum(1 for a in alpha_values if a > 0)
        if transparent_count == 0:
            warnings.append(_issue("WARN_MASTER_NO_TRANSPARENT_PIXEL", "Master contains no fully transparent pixels"))
        partial_ratio = partial_count / max(1, len(alpha_values))
        if partial_ratio > 0.05:
            warnings.append(_issue("WARN_MASTER_HIGH_PARTIAL_ALPHA_RATIO", "Master has a high partial-alpha ratio", ratio=partial_ratio))
        info.append(_issue("INFO_MASTER_METRICS", "Master metrics", width=master.width, height=master.height, visible_pixels=visible_count, transparent_pixels=transparent_count, partial_alpha_pixels=partial_count))

        for layer, img in mask_images.items():
            if img.size != master.size:
                failures.append(_issue(f"FAIL_MASK_SIZE_MISMATCH_{layer}", f"{layer} size does not match Master", master_size=list(master.size), mask_size=list(img.size)))

    memberships: Dict[str, bytes] = {}
    metrics: Dict[str, Any] = {}
    if master is not None and len(mask_images) == 3 and all(img.size == master.size for img in mask_images.values()):
        master_bits, master_visible, _ = _visible_mask_pixels(master)
        metrics["master_visible_pixels"] = master_visible

        for layer in ("D1", "D3", "D4"):
            bits, visible, partial = _visible_mask_pixels(mask_images[layer])
            memberships[layer] = bits
            metrics[f"{layer.lower()}_pixels"] = visible
            metrics[f"{layer.lower()}_bbox"] = _bbox_from_membership(bits, master.size)
            if visible == 0:
                failures.append(_issue(f"FAIL_{layer}_EMPTY", f"{layer} mask is empty"))

        metrics["d1_d3_overlap_pixels"] = _count_intersection(memberships["D1"], memberships["D3"])
        metrics["d1_d4_overlap_pixels"] = _count_intersection(memberships["D1"], memberships["D4"])
        metrics["d3_d4_overlap_pixels"] = _count_intersection(memberships["D3"], memberships["D4"])

        for a, b in (("D1", "D3"), ("D1", "D4"), ("D3", "D4")):
            if _same_membership(memberships[a], memberships[b]):
                failures.append(_issue("FAIL_MASKS_EFFECTIVELY_IDENTICAL", f"{a} and {b} masks are identical", layers=[a, b]))

        assigned = bytes(1 if any(values) else 0 for values in zip(memberships["D1"], memberships["D3"], memberships["D4"]))
        unassigned = sum(1 for mv, av in zip(master_bits, assigned) if mv and not av)
        metrics["unassigned_pixels"] = unassigned
        metrics["unassigned_ratio"] = unassigned / max(1, master_visible)
        if metrics["unassigned_ratio"] > 0.10:
            failures.append(_issue("FAIL_EXCESSIVE_UNASSIGNED_VISIBLE_PIXELS", "More than 10% of visible Master pixels are unassigned", ratio=metrics["unassigned_ratio"]))
        elif unassigned > 0:
            warnings.append(_issue("WARN_MASTER_VISIBLE_PIXELS_UNASSIGNED", "Some visible Master pixels are not assigned to D1/D3/D4", count=unassigned, ratio=metrics["unassigned_ratio"]))

        d1_bbox = metrics.get("d1_bbox")
        d4_bbox = metrics.get("d4_bbox")
        if d1_bbox and d1_bbox[1] < master.height * 0.35:
            warnings.append(_issue("WARN_D1_VERTICAL_POSITION_SUSPECT", "D1 extends unusually high in the canvas", bbox=d1_bbox))
        if d4_bbox and d4_bbox[3] > master.height * 0.95 and d4_bbox[1] > master.height * 0.60:
            warnings.append(_issue("WARN_D4_VERTICAL_POSITION_SUSPECT", "D4 appears concentrated near the bottom", bbox=d4_bbox))

    anchor = meta.get("anchor")
    if not isinstance(anchor, dict):
        failures.append(_issue("FAIL_ANCHOR_MISSING", "anchor must be an object"))
    else:
        mode = anchor.get("mode")
        if mode != "normalized":
            failures.append(_issue("FAIL_ANCHOR_MODE_UNSUPPORTED", "v0.1 supports only normalized anchor", mode=mode))
        try:
            x = float(anchor.get("x"))
            y = float(anchor.get("y"))
            if not (0.0 <= x <= 1.0 and 0.0 <= y <= 1.0):
                failures.append(_issue("FAIL_ANCHOR_OUT_OF_BOUNDS", "Normalized anchor must be within [0,1]", x=x, y=y))
            else:
                if y < 0.70:
                    warnings.append(_issue("WARN_ANCHOR_VERTICAL_POSITION_SUSPECT", "Tree anchor is unusually high", y=y))
        except (TypeError, ValueError):
            failures.append(_issue("FAIL_ANCHOR_OUT_OF_BOUNDS", "Anchor x/y must be numeric"))

    export_rules = meta.get("export_rules")
    if not isinstance(export_rules, dict):
        failures.append(_issue("FAIL_EXPORT_RULE_INVALID", "export_rules must be an object"))
    else:
        ground_layers = export_rules.get("ground_layers")
        par_layers = export_rules.get("par_layers")
        allowed = {"D1", "D3", "D4"}
        if not isinstance(ground_layers, list) or not ground_layers:
            failures.append(_issue("FAIL_GROUND_EXPORT_HAS_NO_SOURCE_LAYER", "ground_layers must be a non-empty list"))
        if not isinstance(par_layers, list) or not par_layers:
            failures.append(_issue("FAIL_PAR_EXPORT_HAS_NO_SOURCE_LAYER", "par_layers must be a non-empty list"))
        if isinstance(ground_layers, list) and any(x not in allowed for x in ground_layers):
            failures.append(_issue("FAIL_EXPORT_RULE_INVALID", "ground_layers contains unknown depth layer", layers=ground_layers))
        if isinstance(par_layers, list) and any(x not in allowed for x in par_layers):
            failures.append(_issue("FAIL_EXPORT_RULE_INVALID", "par_layers contains unknown depth layer", layers=par_layers))

    return _finalize(asset_id, failures, warnings, info, metrics)


def _finalize(asset_id: str, failures: List[Dict[str, Any]], warnings: List[Dict[str, Any]], info: List[Dict[str, Any]], metrics: Dict[str, Any]) -> Dict[str, Any]:
    status = STATUS_FAIL if failures else (STATUS_WARN if warnings else STATUS_PASS)
    return {
        "asset_id": asset_id,
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
    parser = argparse.ArgumentParser(description="Validate an FS Master Object asset bundle")
    parser.add_argument("asset_dir", type=Path, help="Directory containing Master, D1/D3/D4 masks and metadata")
    parser.add_argument("--meta", type=Path, default=None, help="Metadata filename/path (default: auto-discover *.meta.json)")
    parser.add_argument("--report", type=Path, default=None, help="Optional JSON report output path")
    args = parser.parse_args()

    report = validate_asset_bundle(args.asset_dir, args.meta)
    text = json.dumps(report, ensure_ascii=False, indent=2)
    print(text)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(text + "\n", encoding="utf-8")
    return 2 if report["status"] == STATUS_FAIL else 0


if __name__ == "__main__":
    raise SystemExit(main())
