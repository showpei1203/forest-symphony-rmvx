#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Forest Symphony single Master Object compiler v0.2.

v0.2 separates semantic depth masks from engine render policy.

Preferred metadata:
  render_policy.profile = fs_legacy_parallax_vx
  ground = full Master
  par    = Master masked by D3 + D4

Backward compatibility:
  v0.1 export_rules are translated to masked-master outputs.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List

from PIL import Image


def _pixels(image: Image.Image):
    getter = getattr(image, "get_flattened_data", None)
    return getter() if getter is not None else image.getdata()


PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(PIPELINE_ROOT))

from validator.validate_asset import STATUS_FAIL, validate_asset_bundle  # noqa: E402

COMPILER_VERSION = "0.2"


def _load_meta(asset_dir: Path, meta_path: Path | None) -> tuple[Path, Dict[str, Any]]:
    if meta_path is None:
        metas = sorted(asset_dir.glob("*.meta.json"))
        if len(metas) != 1:
            raise ValueError(f"Expected exactly one *.meta.json, found {len(metas)}")
        meta_file = metas[0]
    else:
        meta_file = meta_path if meta_path.is_absolute() else asset_dir / meta_path
    return meta_file, json.loads(meta_file.read_text(encoding="utf-8"))


def _mask_membership(mask: Image.Image) -> bytes:
    return bytes(1 if a > 0 else 0 for a in _pixels(mask.convert("RGBA").getchannel("A")))


def _combine_memberships(memberships: Iterable[bytes]) -> bytes:
    memberships = list(memberships)
    if not memberships:
        raise ValueError("Cannot combine an empty mask list")
    return bytes(1 if any(values) else 0 for values in zip(*memberships))


def _master_membership(master: Image.Image) -> bytes:
    return bytes(1 if a > 0 else 0 for a in _pixels(master.convert("RGBA").getchannel("A")))


def _compose(master: Image.Image, membership: bytes) -> Image.Image:
    master = master.convert("RGBA")
    out = Image.new("RGBA", master.size, (0, 0, 0, 0))
    src = list(_pixels(master))
    dst = [(px if membership[i] else (0, 0, 0, 0)) for i, px in enumerate(src)]
    out.putdata(dst)
    return out


def _bbox(image: Image.Image) -> List[int] | None:
    box = image.getchannel("A").getbbox()
    return list(box) if box else None


def _visible_count(image: Image.Image) -> int:
    return sum(1 for a in _pixels(image.getchannel("A")) if a > 0)


def _count_intersection(a: bytes, b: bytes) -> int:
    return sum(1 for x, y in zip(a, b) if x and y)


def _normalize_render_policy(meta: Dict[str, Any]) -> tuple[Dict[str, Any], str]:
    """Return effective v0.2 render policy and source mode."""
    policy = meta.get("render_policy")
    if isinstance(policy, dict):
        return policy, "render_policy_v0_2"

    export_rules = meta.get("export_rules")
    if not isinstance(export_rules, dict):
        raise ValueError("Metadata has neither render_policy nor legacy export_rules")

    return {
        "profile": "legacy_export_rules_v0_1",
        "ground": {
            "source": "master",
            "mask_union": list(export_rules.get("ground_layers") or []),
        },
        "par": {
            "source": "master",
            "mask_union": list(export_rules.get("par_layers") or []),
        },
    }, "legacy_export_rules_v0_1"


def _resolve_target_membership(
    target: Dict[str, Any],
    master_membership: bytes,
    memberships: Dict[str, bytes],
) -> bytes:
    if target.get("source") != "master":
        raise ValueError(f"Unsupported render target source: {target.get('source')!r}")

    mask_union = target.get("mask_union")
    if mask_union is None:
        return master_membership

    return _combine_memberships(memberships[layer] for layer in mask_union)


def compile_asset(
    asset_dir: Path | str,
    output_dir: Path | str | None = None,
    meta_path: Path | str | None = None,
) -> Dict[str, Any]:
    asset_dir = Path(asset_dir)
    output_dir = Path(output_dir) if output_dir is not None else asset_dir / "compiled"
    meta_arg = Path(meta_path) if meta_path is not None else None

    validation = validate_asset_bundle(asset_dir, meta_arg)
    if validation["status"] == STATUS_FAIL:
        raise RuntimeError(json.dumps(
            {"error": "VALIDATION_FAILED", "validation": validation},
            ensure_ascii=False,
            indent=2,
        ))

    meta_file, meta = _load_meta(asset_dir, meta_arg)
    asset_id = meta["asset_id"]
    master = Image.open(asset_dir / meta["source_master"]).convert("RGBA")
    mask_images = {
        layer: Image.open(asset_dir / filename).convert("RGBA")
        for layer, filename in meta["masks"].items()
    }
    memberships = {
        layer: _mask_membership(mask_images[layer])
        for layer in ("D1", "D3", "D4")
    }
    master_membership = _master_membership(master)

    render_policy, policy_source = _normalize_render_policy(meta)
    ground_membership = _resolve_target_membership(
        render_policy["ground"], master_membership, memberships
    )
    par_membership = _resolve_target_membership(
        render_policy["par"], master_membership, memberships
    )

    ground = _compose(master, ground_membership)
    par = _compose(master, par_membership)

    output_dir.mkdir(parents=True, exist_ok=True)
    ground_name = f"{asset_id}_ground.png"
    par_name = f"{asset_id}_par.png"
    compiled_name = f"{asset_id}_compiled.json"
    report_name = f"{asset_id}_report.json"

    ground.save(output_dir / ground_name, "PNG")
    par.save(output_dir / par_name, "PNG")

    compiled = {
        "asset_id": asset_id,
        "compiler_version": COMPILER_VERSION,
        "compiled_from": meta["source_master"],
        "source_metadata": meta_file.name,
        "semantic_depth": {
            "masks": meta["masks"],
            "anchor": meta["anchor"],
        },
        "render_policy": render_policy,
        "render_policy_source": policy_source,
        "outputs": {
            "ground": ground_name,
            "par": par_name,
        },
    }

    report = {
        "asset_id": asset_id,
        "compiler_version": COMPILER_VERSION,
        "status": validation["status"],
        "validation": validation,
        "render_policy_source": policy_source,
        "render_policy_profile": render_policy.get("profile"),
        "metrics": {
            "master_visible_pixels": _visible_count(master),
            "ground_visible_pixels": _visible_count(ground),
            "par_visible_pixels": _visible_count(par),
            "ground_par_overlap_pixels": _count_intersection(ground_membership, par_membership),
            "unassigned_master_pixels": validation.get("metrics", {}).get("unassigned_pixels", 0),
            "d1_d3_overlap_pixels": validation.get("metrics", {}).get("d1_d3_overlap_pixels", 0),
            "d1_d4_overlap_pixels": validation.get("metrics", {}).get("d1_d4_overlap_pixels", 0),
            "d3_d4_overlap_pixels": validation.get("metrics", {}).get("d3_d4_overlap_pixels", 0),
        },
        "bounding_boxes": {
            "master": _bbox(master),
            "ground": _bbox(ground),
            "par": _bbox(par),
        },
    }

    (output_dir / compiled_name).write_text(
        json.dumps(compiled, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    (output_dir / report_name).write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return {
        "compiled": compiled,
        "report": report,
        "output_dir": str(output_dir),
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Compile an FS Master Object into Ground / Par outputs using render_policy v0.2"
    )
    parser.add_argument("asset_dir", type=Path)
    parser.add_argument("--meta", type=Path, default=None)
    parser.add_argument("--output", type=Path, default=None)
    args = parser.parse_args()

    try:
        result = compile_asset(args.asset_dir, args.output, args.meta)
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 2
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
