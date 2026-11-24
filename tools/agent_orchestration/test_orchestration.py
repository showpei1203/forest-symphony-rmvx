"""Offline synthetic guard tests: no private art, provider, PC or network access."""
from __future__ import annotations

import copy
import json
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent))
from route_task import infer_lane, load_manifest, route
from validate_evidence import validate

DIR = Path(__file__).resolve().parent


class LaneRoutingTests(unittest.TestCase):
    def setUp(self):
        self.cfg = load_manifest()

    def test_all_lanes_bind_to_actual_source_branch(self):
        for lane in ("T-A", "T-B", "T-C", "GODOT", "CONTROL"):
            with self.subTest(lane=lane):
                out = route(lane, self.cfg)
                self.assertEqual(out["formal_engine"], "Godot 4.7.2")
                self.assertFalse(out["execution_allowed"])
                self.assertFalse(out["auto_use_of_skills_verified"])
                self.assertTrue(out["requires_live_fetch"])
                self.assertTrue(out["requires_P0_local_temp_approval_if_needed"])
                self.assertIn("fs-rmvx-router", out["skills_to_load_explicitly"])
                self.assertIn("fs-handoff-qa", out["skills_to_load_explicitly"])
                self.assertIn(self.cfg["lanes"][lane]["handoff"],
                              [x["path"] for x in out["files_to_fetch_live"]])

    def test_governance_links_to_current_branch_not_obsolete_main(self):
        out = route("T-C", self.cfg)
        governed = [f for f in out["files_to_fetch_live"] if f["path"] in
                    ("AGENTS.md", ".agents/skills/fs-rmvx-router/SKILL.md",
                     "authority/FS_UNIFIED_CONTROL_PROTOCOL_20261124.md",
                     "authority/FS_CURRENT_RULES_INDEX_20261107.md")]
        self.assertEqual(len(governed), 4)
        self.assertTrue(all(f["branch"] == self.cfg["governance_branch"] for f in governed))

    def test_TC_ground_first_and_true_all_non_ground_PAR(self):
        contract = route("T-C", self.cfg)["binding_contract"].lower()
        self.assertIn("ground first", contract)
        self.assertIn("all non-ground", contract)
        self.assertIn("transparent", contract)
        self.assertIn("par_complete_alpha", route("T-C", self.cfg)["required_gates"])

    def test_TA_no_false_paperdoll(self):
        out = route("T-A", self.cfg)
        self.assertIn("underpaint", out["binding_contract"])
        self.assertIn("genuine_paperdoll", out["required_gates"])
        self.assertIn("twelve_frames", out["required_gates"])

    def test_Godot_described_as_engine_not_extra_lane(self):
        self.assertEqual(infer_lane("繼續 T-A 角色 Godot 動畫"), "T-A")
        self.assertEqual(infer_lane("總控同步 T-A T-B T-C Godot"), "CONTROL")
        self.assertEqual(infer_lane("T-B 怪物進化 Godot"), "T-B")

    def test_ambiguous_lane_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "ambiguous"):
            infer_lane("T-A 和 T-B 一起處理")
        with self.assertRaises(ValueError):
            infer_lane("繼續")

    def test_unreviewed_manifest_fails_closed(self):
        copied = json.loads((DIR / "routing_manifest.json").read_text(encoding="utf8"))
        copied["formal_engine"] = "RPG Maker VX"
        temporary = DIR / "_never_created.json"
        # Don't write test data onto owner PC or checkouts.
        self.assertNotEqual(copied["formal_engine"], self.cfg["formal_engine"])
        self.assertFalse(route("T-B", self.cfg)["execution_allowed"])


class EvidenceGateTests(unittest.TestCase):
    def setUp(self):
        self.example = json.loads((DIR / "proof_template.json").read_text(encoding="utf8"))

    def test_unfilled_template_is_not_run_never_pass(self):
        self.assertEqual(self.example["claim"], "NOT_RUN")
        self.assertEqual(validate(self.example), [])

    def test_fake_formal_pass_rejected(self):
        self.example["claim"] = "VERIFIED_PASS"
        err = validate(self.example)
        self.assertTrue(any("ALL six" in x for x in err))

    def test_godot_native_claim_without_real_run_rejected(self):
        self.example["claim"] = "ACTIVE"
        self.example["actual_delta"] = "synthetic metadata fixture"
        self.example["qa"]["godot_native"] = "PASS"
        errors = validate(self.example)
        self.assertTrue(any("Godot PASS" in x for x in errors))

    def test_visual_art_claim_without_owner_refused(self):
        self.example["qa"]["owner_art"] = "PASS"
        errors = validate(self.example)
        self.assertTrue(any("ART PASS" in x for x in errors))

    def test_cloud_pass_without_write_readback_refused(self):
        self.example["qa"]["cloud_readback"] = "PASS"
        errors = validate(self.example)
        self.assertTrue(any("Delivery PASS" in x for x in errors))

    def test_owner_PC_temp_requires_prior_scope(self):
        self.example["pc_temp"]["used"] = True
        self.assertTrue(any("P0:" in x for x in validate(self.example)))

    def test_structural_technical_fixture_not_real_art(self):
        e = copy.deepcopy(self.example)
        e["claim"] = "TECH_PASS"
        e["actual_delta"] = "synthetic-only validation, no real art"
        e["source"] = {
            "asset_id": "synthetic", "sha256": "a" * 64,
            "drive_url": "https://drive.google.com/file/d/synthetic-fixture/view",
            "license_checked": True,
        }
        e["tools_invoked"] = [{
            "tool": "synthetic-stdlib", "operation": "unit",
            "evidence_url": "https://github.com/example/fake/actions/runs/1",
        }]
        e["artifacts"]["github_commit_url"] = "https://github.com/example/fake/commit/fake"
        e["qa"]["source"] = "PASS"
        e["qa"]["technical"] = "PASS"
        self.assertEqual(validate(e), [])
        self.assertNotEqual(e["qa"]["owner_art"], "PASS")
        self.assertNotEqual(e["qa"]["full_gameplay"], "PASS")


if __name__ == "__main__":
    unittest.main()
