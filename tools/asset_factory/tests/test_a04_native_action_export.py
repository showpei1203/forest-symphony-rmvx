"""A04 synthetic-only PMD native action export QA, no original game art."""
import hashlib
from io import BytesIO
import unittest
from PIL import Image

from tools.asset_factory.adapters.native_action_export import (
    NativeExportError, compile_native_action,
)


def png(size=(8, 8), color=(50, 70, 90, 255)):
    im = Image.new("RGBA", size, color)
    b = BytesIO()
    im.save(b, "PNG")
    return b.getvalue()


def sample(rows=8):
    xml = (b"<AnimData><ShadowSize>1</ShadowSize><Anims>"
           b"<Anim><Name>Walk</Name><Index>0</Index>"
           b"<FrameWidth>4</FrameWidth><FrameHeight>5</FrameHeight>"
           b"<Durations><Duration>6</Duration><Duration>5</Duration></Durations>"
           b"</Anim><Anim><Name>Stride</Name><CopyOf>Walk</CopyOf></Anim>"
           b"</Anims></AnimData>")
    original = {f"Walk-{s}.png": png((8, rows * 5)) for s in ("Anim", "Offsets", "Shadow")}
    locked = {k: hashlib.sha256(v).hexdigest() for k, v in original.items()}
    patch = {s: [png((4, 5), (210, 20, 40, 255)), png((4, 5), (220, 30, 50, 255))]
             for s in ("Anim", "Offsets", "Shadow")}
    return xml, original, locked, patch


class A04NativeActionExportTests(unittest.TestCase):
    def test_one_direction_preserves_other_seven(self):
        xml, original, locked, patch = sample()
        r = compile_native_action(xml, original, locked, "Walk", {1: patch})
        self.assertEqual(r["status"], "PASS_NATIVE_ATLAS_STATIC_ONLY")
        self.assertEqual(r["patched_native_row_indices"], [1])
        self.assertEqual(r["untouched_native_row_indices"], [0, 2, 3, 4, 5, 6, 7])
        self.assertEqual(r["complete_eight_direction_art"], "NOT_CERTIFIED")
        for suffix in ("Anim", "Offsets", "Shadow"):
            key = f"Walk-{suffix}.png"
            before = Image.open(BytesIO(original[key])).convert("RGBA")
            after = Image.open(BytesIO(r["compiled_pngs"][key])).convert("RGBA")
            self.assertEqual(after.size, (8, 40))
            for row in [0, 2, 3, 4, 5, 6, 7]:
                self.assertEqual(before.crop((0, row*5, 8, (row+1)*5)).tobytes(),
                                 after.crop((0, row*5, 8, (row+1)*5)).tobytes())
            self.assertNotEqual(before.crop((0, 5, 8, 10)).tobytes(),
                                after.crop((0, 5, 8, 10)).tobytes())

    def test_one_row_native_legal(self):
        xml, original, locked, patch = sample(rows=1)
        r = compile_native_action(xml, original, locked, "Walk", {0: patch})
        self.assertEqual(r["untouched_native_row_indices"], [])
        self.assertEqual(r["native_game_exe"], "NOT_RUN")

    def test_incomplete_three_sheet_patch_rejected(self):
        xml, original, locked, patch = sample()
        del patch["Shadow"]
        with self.assertRaises(NativeExportError):
            compile_native_action(xml, original, locked, "Walk", {1: patch})

    def test_native_wrong_frame_count_rejected(self):
        xml, original, locked, patch = sample()
        patch["Anim"] = patch["Anim"][:1]
        with self.assertRaises(NativeExportError):
            compile_native_action(xml, original, locked, "Walk", {1: patch})

    def test_native_wrong_cell_geometry_rejected(self):
        xml, original, locked, patch = sample()
        patch["Anim"][0] = png((5, 5))
        with self.assertRaises(NativeExportError):
            compile_native_action(xml, original, locked, "Walk", {1: patch})

    def test_source_sha_lock_mismatch_rejected(self):
        xml, original, locked, patch = sample()
        locked["Walk-Anim.png"] = "0" * 64
        with self.assertRaises(NativeExportError):
            compile_native_action(xml, original, locked, "Walk", {1: patch})

    def test_no_magic_direction_outside_rows(self):
        xml, original, locked, patch = sample()
        with self.assertRaises(NativeExportError):
            compile_native_action(xml, original, locked, "Walk", {8: patch})

    def test_copyof_alias_cannot_be_replaced(self):
        xml, original, locked, patch = sample()
        with self.assertRaises(NativeExportError):
            compile_native_action(xml, original, locked, "Stride", {1: patch})

    def test_unspecified_patch_rejected(self):
        xml, original, locked, _ = sample()
        with self.assertRaises(NativeExportError):
            compile_native_action(xml, original, locked, "Walk", {})

if __name__ == "__main__":
    unittest.main()
