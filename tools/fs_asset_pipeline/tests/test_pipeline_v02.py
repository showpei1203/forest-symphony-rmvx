#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Regression tests for Forest Symphony Asset Pipeline v0.2."""
from __future__ import annotations

import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw

PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(PIPELINE_ROOT))

from compiler.compile_master_object import compile_asset  # noqa: E402
from validator.validate_asset import STATUS_FAIL, STATUS_PASS, STATUS_WARN, validate_asset_bundle  # noqa: E402


ASSET_ID = "FS_Tree_Standard_Broadleaf_01"


def _visible_count(path: Path) -> int:
    image = Image.open(path).convert("RGBA")
    getter = getattr(image.getchannel("A"), "get_flattened_data", None)
    pixels = getter() if getter is not None else image.getchannel("A").getdata()
    return sum(1 for a in pixels if a > 0)


def _make_bundle(root: Path, *, legacy: bool = False, invalid_profile: bool = False) -> Path:
    asset_dir = root / ("legacy" if legacy else "v02")
    asset_dir.mkdir(parents=True)

    size = (64, 64)
    master = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(master)
    draw.rectangle([28, 28, 36, 58], fill=(120, 80, 40, 255))
    draw.ellipse([12, 4, 52, 38], fill=(50, 140, 60, 255))
    draw.ellipse([24, 52, 40, 62], fill=(90, 60, 30, 255))
    master.save(asset_dir / f"{ASSET_ID}_Master.png")

    d1 = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(d1).rectangle([24, 52, 40, 62], fill=(255, 255, 255, 255))
    d1.save(asset_dir / f"{ASSET_ID}_D1.png")

    d3 = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(d3).rectangle([28, 28, 36, 58], fill=(255, 255, 255, 255))
    d3.save(asset_dir / f"{ASSET_ID}_D3.png")

    d4 = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(d4).ellipse([12, 4, 52, 38], fill=(255, 255, 255, 255))
    d4.save(asset_dir / f"{ASSET_ID}_D4.png")

    meta = {
        "asset_id": ASSET_ID,
        "family": "standard_broadleaf",
        "category": "tree",
        "variant": "synthetic_regression",
        "status": "test_only",
        "source_master": f"{ASSET_ID}_Master.png",
        "masks": {
            "D1": f"{ASSET_ID}_D1.png",
            "D3": f"{ASSET_ID}_D3.png",
            "D4": f"{ASSET_ID}_D4.png",
        },
        "anchor": {"mode": "normalized", "x": 0.5, "y": 0.95},
    }

    if legacy:
        meta["export_rules"] = {
            "ground_layers": ["D1"],
            "par_layers": ["D3", "D4"],
        }
    else:
        meta["render_policy"] = {
            "profile": "fs_legacy_parallax_vx",
            "ground": {"source": "master"},
            "par": {
                "source": "master",
                "mask_union": ["D1", "D4"] if invalid_profile else ["D3", "D4"],
            },
        }

    (asset_dir / f"{ASSET_ID}.meta.json").write_text(
        json.dumps(meta, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return asset_dir


class AssetPipelineV02Tests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="fs_asset_pipeline_v02_"))

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_fs_legacy_profile_ground_is_full_master_and_par_is_occlusion_overlay(self) -> None:
        asset_dir = _make_bundle(self.tmp)
        validation = validate_asset_bundle(asset_dir)
        self.assertEqual(STATUS_PASS, validation["status"])

        result = compile_asset(asset_dir)
        compiled = result["compiled"]
        report = result["report"]
        output = Path(result["output_dir"])

        self.assertEqual("0.2", compiled["compiler_version"])
        self.assertEqual("render_policy_v0_2", compiled["render_policy_source"])
        self.assertEqual("fs_legacy_parallax_vx", report["render_policy_profile"])

        master_count = _visible_count(asset_dir / f"{ASSET_ID}_Master.png")
        ground_count = _visible_count(output / f"{ASSET_ID}_ground.png")
        par_count = _visible_count(output / f"{ASSET_ID}_par.png")

        self.assertEqual(master_count, ground_count)
        self.assertGreater(par_count, 0)
        self.assertLess(par_count, ground_count)
        self.assertEqual(par_count, report["metrics"]["ground_par_overlap_pixels"])

    def test_v01_export_rules_remain_compatible_but_warn(self) -> None:
        asset_dir = _make_bundle(self.tmp, legacy=True)
        validation = validate_asset_bundle(asset_dir)

        self.assertEqual(STATUS_WARN, validation["status"])
        warning_codes = {item["code"] for item in validation["warnings"]}
        self.assertIn("WARN_LEGACY_EXPORT_RULES_V0_1", warning_codes)

        result = compile_asset(asset_dir)
        self.assertEqual(
            "legacy_export_rules_v0_1",
            result["compiled"]["render_policy_source"],
        )

    def test_fs_legacy_profile_rejects_wrong_par_semantics(self) -> None:
        asset_dir = _make_bundle(self.tmp, invalid_profile=True)
        validation = validate_asset_bundle(asset_dir)

        self.assertEqual(STATUS_FAIL, validation["status"])
        failure_codes = {item["code"] for item in validation["failures"]}
        self.assertIn("FAIL_FS_LEGACY_PAR_MASK_UNION_INVALID", failure_codes)


if __name__ == "__main__":
    unittest.main(verbosity=2)
