"""Early art candidates do not have to be 48x48 or exactly three frames."""
from __future__ import annotations

import io
import unittest

from PIL import Image

from tools.asset_factory.asf_raw_preview import (
    SpritePreviewError, preview_frames,
)


def mk(w, h, color=(190, 60, 120, 255)):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    im.putpixel((w // 2, h - 2), color)
    out = io.BytesIO()
    im.save(out, format="PNG")
    return out.getvalue()


class ASFSizeAgnosticPreviewTest(unittest.TestCase):
    def test_30x44_from_upstream_asf_is_accepted(self):
        r = preview_frames([mk(30, 44), mk(30, 44, (15, 155, 85, 255))])
        self.assertEqual(r["status"], "PREVIEW_ONLY_NEEDS_ART_REVIEW")
        self.assertEqual(r["sheet_size"], [60, 44])
        self.assertEqual(r["original_sizes"], [[30, 44], [30, 44]])
        self.assertEqual(r["duplicate_pairs"], [])
        self.assertTrue(r["preview_gif"].startswith(b"GIF"))

    def test_arbitrary_mixed_dimensions_and_variable_frames(self):
        sizes = [(30, 44), (64, 64), (80, 75), (36, 47)]
        r = preview_frames([mk(w, h, (70+i, 80, 140, 255)) for i,(w,h) in enumerate(sizes)])
        self.assertEqual(r["frame_count"], 4)
        self.assertEqual(r["display_cell"], [80, 75])
        self.assertEqual(r["sheet_size"], [320, 75])
        self.assertEqual(r["original_sizes"], [list(p) for p in sizes])
        self.assertEqual(r["native_vx"], "NOT_RUN")
        with Image.open(io.BytesIO(r["sheet_png"])) as im:
            self.assertEqual(im.size, (320, 75))

    def test_no_resizing_or_repainting_in_png_sheet(self):
        first = mk(30, 44)
        second = mk(71, 53, (34, 55, 122, 255))
        r = preview_frames([first, second])
        with Image.open(io.BytesIO(r["sheet_png"])) as strip:
            with Image.open(io.BytesIO(first)) as a:
                ax, ay = r["bottom_center_offsets"][0]
                self.assertEqual(
                    strip.crop((ax, ay, ax+30, ay+44)).tobytes(),
                    a.convert("RGBA").tobytes(),
                )
            with Image.open(io.BytesIO(second)) as b:
                bx, by = r["bottom_center_offsets"][1]
                self.assertEqual(
                    strip.crop((r["display_cell"][0]+bx, by,
                                r["display_cell"][0]+bx+71, by+53)).tobytes(),
                    b.convert("RGBA").tobytes(),
                )

    def test_duplicate_is_warning_not_geometry_gate(self):
        a=mk(35, 54)
        r=preview_frames([a,a, mk(35,54,(12,99,99,255))])
        self.assertEqual(r["duplicate_pairs"], [[0,1]])
        self.assertEqual(r["frame_count"],3)

    def test_one_frame_is_allowed_as_concept_first(self):
        r=preview_frames([mk(96,120)])
        self.assertEqual(r["frame_count"],1)
        self.assertEqual(r["sheet_size"],[96,120])

    def test_reject_empty_list_only(self):
        with self.assertRaisesRegex(SpritePreviewError,"at least one"):
            preview_frames([])

    def test_reject_non_png_source(self):
        with self.assertRaises(SpritePreviewError):
            preview_frames([b"not a PNG"])

    def test_reject_fully_transparent(self):
        im=Image.new("RGBA",(30,44),(0,0,0,0))
        out=io.BytesIO()
        im.save(out,format="PNG")
        with self.assertRaisesRegex(SpritePreviewError,"fully transparent"):
            preview_frames([out.getvalue()])


if __name__ == "__main__":
    unittest.main()
