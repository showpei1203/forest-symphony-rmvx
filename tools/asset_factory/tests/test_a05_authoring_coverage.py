"""A05 synthetic fail-closed Master Authoring vs Runtime scope tests."""
from __future__ import annotations
import hashlib
from io import BytesIO
import unittest
from PIL import Image
from tools.asset_factory.adapters.authoring_coverage import (
    audit_authoring_runtime_gap, CoverageError,
)


def pack(im):
    b = BytesIO()
    im.save(b, "PNG")
    return b.getvalue()


def sample():
    color = (40, 75, 20, 255)
    master = Image.new("RGBA", (64, 64), color)
    author = Image.new("RGBA", (64, 64), (0,0,0,0))
    run = Image.new("RGBA", (64, 64), (0,0,0,0))
    for pt in ((3, 4), (35, 4), (35, 35)):
        author.putpixel(pt, color)
    run.putpixel((3, 4), color)
    master_bytes = pack(master)
    return master_bytes, pack(author), pack(run), hashlib.sha256(master_bytes).hexdigest(), [[0,1],[0,0]]


class A05AuthoringGapTests(unittest.TestCase):
    def test_measures_nonregistered_authoring_pixels_without_promoting_to_runtime(self):
        m,a,r,sha,grid=sample()
        report=audit_authoring_runtime_gap(m,a,r,sha,grid)
        self.assertEqual(report["authoring_alpha_pixels"], 3)
        self.assertEqual(report["runtime_alpha_pixels"], 1)
        self.assertEqual(report["authoring_only_alpha_pixels"], 2)
        self.assertEqual(report["authoring_only_tiles"], 2)
        self.assertEqual(report["authoring_only_alpha_on_draft_walkable_tiles"], 1)
        self.assertEqual(report["authoring_object_source_inventory"], "NOT_VERIFIED")
        self.assertEqual(report["native_vx"], "NOT_RUN")

    def test_outside_authoring_fails(self):
        m,a,r,sha,grid=sample()
        im=Image.open(BytesIO(r)).convert("RGBA")
        im.putpixel((60, 60), (40, 75, 20, 255))
        with self.assertRaises(CoverageError):
            audit_authoring_runtime_gap(m,a,pack(im),sha,grid)

    def test_wrong_runtime_rgb_fails(self):
        m,a,r,sha,grid=sample()
        im=Image.open(BytesIO(r)).convert("RGBA")
        im.putpixel((3,4), (220,75,20,255))
        with self.assertRaises(CoverageError):
            audit_authoring_runtime_gap(m,a,pack(im),sha,grid)

    def test_wrong_authoring_rgb_fails(self):
        m,a,r,sha,grid=sample()
        im=Image.open(BytesIO(a)).convert("RGBA")
        im.putpixel((35,4), (220,75,20,255))
        with self.assertRaises(CoverageError):
            audit_authoring_runtime_gap(m,pack(im),r,sha,grid)

    def test_wrong_sha_fails(self):
        m,a,r,sha,grid=sample()
        with self.assertRaises(CoverageError):
            audit_authoring_runtime_gap(m,a,r,"a"*64,grid)

    def test_wrong_collision_geometry_fails(self):
        m,a,r,sha,grid=sample()
        with self.assertRaises(CoverageError):
            audit_authoring_runtime_gap(m,a,r,sha,[[0],[0]])

    def test_invalid_collision_value_fails(self):
        m,a,r,sha,grid=sample()
        with self.assertRaises(CoverageError):
            audit_authoring_runtime_gap(m,a,r,sha,[[0,2],[0,0]])

    def test_without_collision_does_not_invent_walkability(self):
        m,a,r,sha,grid=sample()
        x=audit_authoring_runtime_gap(m,a,r,sha)
        self.assertIsNone(x["authoring_only_alpha_on_draft_walkable_tiles"])
        self.assertIsNone(x["hotspots"][0]["draft_walkable"])


if __name__ == "__main__":
    unittest.main()
