"""Synthetic only. No protected FS/PMD binary artwork in this public repository."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw

from tools.asset_factory.validator import validate_manifest_file


class AssetFactoryTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def write_manifest(self, data):
        p = self.root / "manifest.json"
        p.write_text(json.dumps(data), encoding="utf-8")
        return p

    def sprite(self):
        paths = []
        for index in range(3):
            p = self.root / f"actor_{index}.png"
            im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
            ImageDraw.Draw(im).rectangle(
                (4 + index, 4, 8 + index, 12), fill=(230, 88, 40, 255)
            )
            im.save(p)
            paths.append(p.name)
        data = {
            "schema": "fs-asset-candidate/v1",
            "kind": "sprite",
            "asset_id": "synthetic_actor01",
            "frame": {"width": 16, "height": 16},
            "require_binary_alpha": True,
            "animations": [
                {
                    "name": "walk",
                    "direction": "SE",
                    "expected_frames": 3,
                    "frame_paths": paths,
                    "require_distinct_adjacent": True,
                }
            ],
        }
        return data

    def map(self):
        green = (33, 110, 60, 255)
        dark = (66, 38, 20, 255)
        ground = Image.new("RGBA", (64, 64), green)
        par = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        ImageDraw.Draw(par).rectangle((10, 8, 17, 15), fill=dark)
        master = Image.alpha_composite(ground, par)
        occlude = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        ImageDraw.Draw(occlude).rectangle((10, 8, 17, 10), fill=dark)
        layers = {
            "authoring_ground_only": ground,
            "authoring_complete_par": par,
            "runtime_full_ground": master,
            "runtime_occlusion_par": occlude,
        }
        files = {}
        for name, im in layers.items():
            filename = f"{name}.png"
            im.save(self.root / filename)
            files[name] = filename
        return {
            "schema": "fs-asset-candidate/v1",
            "kind": "map",
            "asset_id": "synthetic_village",
            "canvas": {"width": 64, "height": 64, "tile_px": 32},
            "master_sha256": hashlib.sha256((self.root / "runtime_full_ground.png").read_bytes()).hexdigest(),
            "layers": files,
            "collision": {
                "walkable": [[1, 1], [1, 0]],
                "spawn": [0, 0],
                "goal": [1, 0],
            },
        }

    def check(self, data):
        return validate_manifest_file(self.write_manifest(data))

    def gates(self, result):
        return {x["gate"] for x in result["issues"]}

    def test_sprite_valid_three_distinct_frames(self):
        result = self.check(self.sprite())
        self.assertEqual(result["status"], "PASS_STATIC_ONLY", result)
        self.assertEqual(result["native_vx"], "NOT_RUN")
        self.assertEqual(result["formal_seal"], "NO")

    def test_sprite_fails_wrong_dimensions(self):
        data = self.sprite()
        data["frame"]["width"] = 32
        self.assertIn("S_DIMENSIONS", self.gates(self.check(data)))

    def test_sprite_fails_missing_frame(self):
        data = self.sprite()
        data["animations"][0]["frame_paths"][1] = "missing.png"
        self.assertIn("S_SOURCE", self.gates(self.check(data)))

    def test_sprite_fails_duplicate_frames(self):
        data = self.sprite()
        Image.open(self.root / "actor_0.png").save(self.root / "actor_1.png")
        self.assertIn("S_DUP_FRAME", self.gates(self.check(data)))

    def test_sprite_fails_nonbinary_alpha(self):
        data = self.sprite()
        p = self.root / "actor_0.png"
        im = Image.open(p).convert("RGBA")
        im.putpixel((4, 4), (230, 88, 40, 100))
        im.save(p)
        self.assertIn("S_ALPHA", self.gates(self.check(data)))

    def test_sprite_rejects_parent_path_escape(self):
        data = self.sprite()
        data["animations"][0]["frame_paths"][0] = "../secret.png"
        self.assertIn("S_SOURCE", self.gates(self.check(data)))

    def test_map_valid_four_layers_and_reachable(self):
        result = self.check(self.map())
        self.assertEqual(result["status"], "PASS_STATIC_ONLY", result)

    def test_map_fails_bad_overlay_rgb(self):
        data = self.map()
        p = self.root / data["layers"]["runtime_occlusion_par"]
        im = Image.open(p).convert("RGBA")
        im.putpixel((12, 9), (255, 0, 0, 255))
        im.save(p)
        self.assertIn("M_SOURCE_RGB", self.gates(self.check(data)))
        self.assertIn("M_RUNTIME_RECOMPOSE", self.gates(self.check(data)))

    def test_map_fails_missing_layer(self):
        data = self.map()
        del data["layers"]["authoring_complete_par"]
        self.assertIn("M_LAYER", self.gates(self.check(data)))

    def test_map_fails_bad_master_sha(self):
        data = self.map()
        data["master_sha256"] = "a" * 64
        self.assertIn("M_SOURCE_SHA", self.gates(self.check(data)))

    def test_map_fails_unreachable_goal(self):
        data = self.map()
        data["collision"]["goal"] = [1, 1]
        self.assertIn("M_GOAL", self.gates(self.check(data)))

    def test_map_fails_authoring_ground_drift(self):
        data = self.map()
        p = self.root / data["layers"]["authoring_ground_only"]
        im = Image.open(p).convert("RGBA")
        im.putpixel((40, 40), (200, 200, 200, 255))
        im.save(p)
        self.assertIn("M_AUTHOR_RECOMPOSE", self.gates(self.check(data)))

    def test_map_fails_invalid_collision_grid(self):
        data = self.map()
        data["collision"]["walkable"] = [[1], [1]]
        self.assertIn("M_COLLISION", self.gates(self.check(data)))

    def test_bad_manifest_fails_closed(self):
        p = self.root / "manifest.json"
        p.write_text("{not-json", encoding="utf-8")
        result = validate_manifest_file(p)
        self.assertEqual(result["status"], "FAIL")
        self.assertIn("MANIFEST", self.gates(result))


if __name__ == "__main__":
    unittest.main()
