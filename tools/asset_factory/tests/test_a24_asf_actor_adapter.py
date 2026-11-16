"""Synthetic-only guards for FS A24 ASF -> Actor 48px candidate export."""
import hashlib
import io
import unittest

from PIL import Image, ImageDraw

from tools.asset_factory.a24_asf_actor_adapter import (
    ASFActorContractError, compile_asf_actor_three_frame
)


def png(image):
    out = io.BytesIO()
    image.save(out, format="PNG")
    return out.getvalue()


def fixture():
    base = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(base)
    d.rectangle((17, 5, 31, 17), fill=(210, 210, 210, 255))
    d.rectangle((14, 17, 33, 32), fill=(12, 92, 86, 255))
    d.rectangle((18, 31, 23, 43), fill=(35, 45, 55, 255))
    d.rectangle((26, 31, 31, 43), fill=(35, 45, 55, 255))
    d.rectangle((16, 42, 23, 44), fill=(96, 65, 48, 255))
    d.rectangle((25, 42, 33, 44), fill=(96, 65, 48, 255))
    originals = [base.copy(), base.copy(), base.copy()]
    # Simulate two legitimate distinct poses at already accepted palette colours.
    ImageDraw.Draw(originals[1]).rectangle(
        (17, 33, 20, 41), fill=(12, 92, 86, 255)
    )
    ImageDraw.Draw(originals[2]).rectangle(
        (28, 33, 31, 41), fill=(12, 92, 86, 255)
    )
    # The Forge has cropped the frames, and reported an anchor in cropped coordinates.
    local = [png(i.crop((9, 2, 39, 46))) for i in originals]
    return png(base), local


class ASFNativeActorAdapterTests(unittest.TestCase):
    def setUp(self):
        self.base, self.local = fixture()
        self.sha = hashlib.sha256(self.base).hexdigest()

    def call(self, local=None, **kwargs):
        return compile_asf_actor_three_frame(
            self.base, self.sha, self.local if local is None else local,
            forge_anchor=kwargs.get("forge_anchor", (15, 43)),
            native_source_anchor=kwargs.get("native_source_anchor", (24, 45)),
        )

    def test_three_keyframes_canonical_f0_and_144px(self):
        r = self.call()
        self.assertEqual(r["status"], "STATIC_NATIVE_FORMAT_PASS_ONLY")
        self.assertEqual(r["translation"], [9, 2])
        self.assertEqual(r["native_sheet"], [144, 48])
        self.assertTrue(r["frame0_exact"])
        self.assertEqual(r["vx_game_exe"], "NOT_RUN")
        with Image.open(io.BytesIO(r["native_sheet_png"])) as sheet:
            self.assertEqual(sheet.size, (144, 48))
            with Image.open(io.BytesIO(self.base)) as original:
                self.assertEqual(sheet.crop((0, 0, 48, 48)).tobytes(), original.tobytes())

    def test_wrong_sha_fails(self):
        with self.assertRaisesRegex(ASFActorContractError, "SHA"):
            compile_asf_actor_three_frame(self.base, "0"*64, self.local,
                                           forge_anchor=(15, 43),
                                           native_source_anchor=(24, 45))

    def test_requires_three_actual_frames(self):
        with self.assertRaisesRegex(ASFActorContractError, "three"):
            self.call(self.local[:2])

    def test_reject_identical_loop(self):
        with self.assertRaisesRegex(ASFActorContractError, "distinct motion"):
            self.call([self.local[0]] * 3)

    def test_reject_nearly_identical_second_stride(self):
        with self.assertRaisesRegex(ASFActorContractError, "identical"):
            self.call([self.local[0], self.local[1], self.local[1]])

    def test_reject_wrong_new_colour(self):
        im = Image.open(io.BytesIO(self.local[1])).convert("RGBA")
        im.putpixel((15, 29), (240, 1, 244, 255))
        with self.assertRaisesRegex(ASFActorContractError, "palette"):
            self.call([self.local[0], png(im), self.local[2]])

    def test_reject_half_pixel_root_shift(self):
        with self.assertRaisesRegex(ASFActorContractError, "non-integer"):
            self.call(forge_anchor=(15.5, 43))

    def test_reject_oversize_crop(self):
        big = Image.new("RGBA", (56, 56), (0, 0, 0, 0))
        with self.assertRaisesRegex(ASFActorContractError, "too large"):
            self.call([png(big), self.local[1], self.local[2]])

    def test_reject_cropped_actor(self):
        with self.assertRaisesRegex(ASFActorContractError, "cropped"):
            self.call(native_source_anchor=(42, 45))

    def test_reject_nonbinary_alpha(self):
        im = Image.open(io.BytesIO(self.local[1])).convert("RGBA")
        im.putpixel((12, 15), (12, 92, 86, 128))
        with self.assertRaisesRegex(ASFActorContractError, "alpha"):
            self.call([self.local[0], png(im), self.local[2]])


if __name__ == "__main__":
    unittest.main()
