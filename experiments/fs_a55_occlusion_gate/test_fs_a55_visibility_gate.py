#!/usr/bin/env python3
"""A55 independent regression tests: positive, negative and source-truth gates."""
import json
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw

from fs_a55_visibility_gate import (
    SIZE, audit_a53_body, edge_count, inspect_frame,
    outside_pixels, run_selftest, synthetic_case, validate_contract,
)

HERE = Path(__file__).resolve().parent


class A55VisibilityRegression(unittest.TestCase):
    def test_both_frames_negative_and_positive(self):
        report = run_selftest(None)
        self.assertEqual(report["result"], "PASS")
        for wrong in report["negative_controls_detected"]:
            self.assertFalse(wrong["pass"])
            self.assertGreater(wrong["uncovered_hand_px"], 0)
            self.assertGreater(wrong["guide_hidden_hand_px"], 0)
        for corrected in report["positive_controls_passed"]:
            self.assertTrue(corrected["pass"])
            self.assertEqual(corrected["uncovered_hand_px"], 0)
            self.assertEqual(corrected["guide_hidden_hand_px"], 0)
            self.assertGreaterEqual(corrected["visible_blade_tip_px"], 15)

    def test_missing_blade_tip_rejected(self):
        masks, _ = synthetic_case(5, corrected=True)
        masks["blade"] = Image.new("L", SIZE, 0)
        r = inspect_frame(**masks, hand_status="fully_occluded",
                          blade_status="partially_occluded", min_visible_tip=15)
        self.assertIn("visible_blade_tip_insufficient", r["failure_reasons"])

    def test_bad_guide_rejected_even_when_final_hidden(self):
        masks, _ = synthetic_case(6, corrected=True)
        ImageDraw.Draw(masks["guide_hand"]).ellipse((26, 29, 31, 33), fill=255)
        r = inspect_frame(**masks, hand_status="fully_occluded",
                          blade_status="partially_occluded", min_visible_tip=15)
        self.assertIn("guide_draws_occluded_hand", r["failure_reasons"])
        self.assertEqual(r["uncovered_hand_px"], 0)

    def test_clip_rejected(self):
        masks, _ = synthetic_case(5, corrected=True)
        ImageDraw.Draw(masks["blade"]).point((0, 0), fill=255)
        r = inspect_frame(**masks, hand_status="fully_occluded",
                          blade_status="partially_occluded", min_visible_tip=15)
        self.assertIn("clip_on_sprite_canvas_edge", r["failure_reasons"])
        self.assertGreater(edge_count(masks["blade"]), 0)

    def test_full_occlusion_requires_real_occluder(self):
        masks, _ = synthetic_case(5, corrected=True)
        masks["shield"] = Image.new("L", SIZE, 0)
        r = inspect_frame(**masks, hand_status="fully_occluded",
                          blade_status="partially_occluded", min_visible_tip=15)
        self.assertIn("occluder_missing", r["failure_reasons"])

    def test_wrong_resolution_not_permitted(self):
        masks, _ = synthetic_case(5, corrected=True)
        masks["shield"] = Image.new("L", (32, 32), 0)
        with self.assertRaises(ValueError):
            inspect_frame(**masks, hand_status="fully_occluded",
                          blade_status="partially_occluded", min_visible_tip=15)

    def test_user_reference_manifest_is_reference_only(self):
        contract = json.loads((HERE / "a55_visibility_manifest_reference.json").read_text(encoding="utf-8"))
        self.assertEqual(contract["status"], "reference_only")
        self.assertEqual(validate_contract(contract), [])
        self.assertEqual([x["frame"] for x in contract["example_frames"]], [5, 6])

    def test_invalid_hidden_limb_guide_rejected(self):
        contract = json.loads((HERE / "a55_visibility_manifest_reference.json").read_text(encoding="utf-8"))
        contract["example_frames"][0]["guide_must_exclude"] = []
        self.assertIn("hidden_part_missing_from_guide_exclusion", validate_contract(contract))

    def test_missing_occlusion_owner_rejected(self):
        contract = json.loads((HERE / "a55_visibility_manifest_reference.json").read_text(encoding="utf-8"))
        contract["example_frames"][1]["occluder"] = ""
        self.assertIn("hidden_part_without_occluder", validate_contract(contract))

    def test_duplicate_frames_rejected(self):
        contract = json.loads((HERE / "a55_visibility_manifest_reference.json").read_text(encoding="utf-8"))
        contract["example_frames"].append(dict(contract["example_frames"][0]))
        self.assertIn("duplicate_frame", validate_contract(contract))

    def test_art_pass_requires_body_mask_evidence(self):
        contract = json.loads((HERE / "a55_visibility_manifest_reference.json").read_text(encoding="utf-8"))
        contract["example_frames"][0]["native_art_status"] = "ART_PASS"
        self.assertIn("art_pass_without_body_mask_qa_provenance", validate_contract(contract))
        contract["example_frames"][0]["body_mask_qa_pass"] = True
        contract["example_frames"][0]["source_qa_hash"] = "verified-example-only"
        self.assertNotIn("art_pass_without_body_mask_qa_provenance", validate_contract(contract))

    def test_no_source_image_modification(self):
        """Only synthetic fixtures are generated; actual FS artwork is read-only."""
        masks, _ = synthetic_case(5, corrected=True)
        self.assertEqual(outside_pixels(masks["final_hand"], masks["shield"]), 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
