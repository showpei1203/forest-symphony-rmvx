"""Ephemeral fixture tests only: no real/private FS images are copied into CI."""
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "stage_private_a35_534.py"
spec = importlib.util.spec_from_file_location("fs_a35_stage", MODULE_PATH)
stage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(stage)

class StageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.archive = self.root / "fixture.zip"
        self.output = self.root / "a35_private"

    def write_zip(self, override=None):
        files = {
            "A35/project.godot": b"[application]\n",
            "A35/scenes/a35_r8_r3_grove_balance_scene.tscn":
                b'[gd_scene format=3]\n[ext_resource type="Script" path="res://scripts/actor.gd" id="1"]\n[node name="A35" type="Node2D"]\n',
            "A35/scripts/actor.gd": b'extends Node2D\nconst IMAGE="res://private_assets/ground_only.png"\n',
            "A35/private_assets/ground_only.png": b"synthetic-ground-for-unit-test",
        }
        if override:
            files.update(override)
        with zipfile.ZipFile(self.archive, "w", zipfile.ZIP_DEFLATED) as zf:
            for name, data in files.items():
                if data is not None:
                    zf.writestr(name, data)
        return hashlib.sha256(self.archive.read_bytes()).hexdigest()

    def test_dry_run_and_stage_resource_namespaces(self):
        zip_sha = self.write_zip()
        ground_sha = hashlib.sha256(b"synthetic-ground-for-unit-test").hexdigest()
        report = stage.stage_archive(self.archive, self.output, zip_sha, ground_sha, True)
        self.assertFalse(self.output.exists())
        self.assertEqual(report["files_staged"], 3)
        result = stage.stage_archive(self.archive, self.output, zip_sha, ground_sha)
        self.assertEqual(result["art"], "HOLD")
        content = (self.output / "scripts" / "actor.gd").read_text()
        self.assertIn('res://a35_private/private_assets/ground_only.png', content)
        scene = (self.output / "scenes" / "a35_r8_r3_grove_balance_scene.tscn").read_text()
        self.assertIn('res://a35_private/scripts/actor.gd', scene)
        self.assertEqual((self.output/"private_assets"/"ground_only.png").read_bytes(),
                         b"synthetic-ground-for-unit-test")
        self.assertTrue((self.output / "fs_private_a35_manifest.json").exists())
        with self.assertRaises(stage.PrivateStageError):
            stage.stage_archive(self.archive, self.output, zip_sha, ground_sha)

    def test_archive_sha_rejects_before_write(self):
        self.write_zip()
        with self.assertRaisesRegex(stage.PrivateStageError, "ZIP SHA256 mismatch"):
            stage.stage_archive(self.archive, self.output, "0"*64, "1"*64)
        self.assertFalse(self.output.exists())

    def test_ground_sha_rejects_before_write(self):
        zip_sha = self.write_zip()
        with self.assertRaisesRegex(stage.PrivateStageError, "Ground-only PNG hash"):
            stage.stage_archive(self.archive, self.output, zip_sha, "f"*64)
        self.assertFalse(self.output.exists())

    def test_traversal_and_duplicate_rejected(self):
        zip_sha = self.write_zip({"../attack.txt": b"not allowed"})
        with self.assertRaises(stage.PrivateStageError):
            stage.stage_archive(self.archive, self.output, zip_sha, "0"*64)
        self.assertFalse(self.output.exists())

    def test_missing_original_scene_rejected(self):
        zip_sha = self.write_zip({
            "A35/scenes/a35_r8_r3_grove_balance_scene.tscn": None,
        })
        with self.assertRaisesRegex(stage.PrivateStageError, "exactly one complete"):
            stage.stage_archive(self.archive, self.output, zip_sha, "0"*64)
        self.assertFalse(self.output.exists())

if __name__ == "__main__":
    unittest.main()
