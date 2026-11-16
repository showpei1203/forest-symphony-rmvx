"""Synthetic only: A03 private ZIP reader and 32px Master-first runtime mask QA."""
from __future__ import annotations
import hashlib
from io import BytesIO
import unittest
from zipfile import ZipFile, ZIP_DEFLATED
from PIL import Image
from tools.asset_factory.adapters.private_zip_scan import scan_pmd_zip, PrivateZipError
from tools.asset_factory.adapters.runtime_masks import check_runtime_objects, RuntimeMaskError


def png(size=(8, 40), mode="RGBA", fill=(14, 90, 35, 255)):
    pic = Image.new(mode, size, fill if mode == "RGBA" else 0)
    out = BytesIO()
    pic.save(out, format="PNG")
    return out.getvalue()


def zip_fixture(*, omit=None, bad_name=False):
    xml = (b'<AnimData><ShadowSize>1</ShadowSize><Anims><Anim><Name>Walk</Name>'
           b'<Index>0</Index><FrameWidth>4</FrameWidth><FrameHeight>5</FrameHeight>'
           b'<Durations><Duration>4</Duration><Duration>5</Duration></Durations>'
           b'</Anim></Anims></AnimData>')
    entries = {"example/AnimData.xml": xml}
    for suffix in ("Anim", "Offsets", "Shadow"):
        entries[f"example/Walk-{suffix}.png"] = png()
    if omit:
        del entries[omit]
    if bad_name:
        entries["../unsafe.txt"] = b"unsafe"
    out = BytesIO()
    with ZipFile(out, "w", compression=ZIP_DEFLATED) as z:
        for k, v in entries.items():
            z.writestr(k, v)
    return out.getvalue()


def runtime_fixture():
    master = Image.new("RGBA", (64, 64), (32, 100, 70, 255))
    par = Image.new("RGBA", (64, 64))
    par.putpixel((6, 7), (32, 100, 70, 255))
    mask = Image.new("L", (64, 64))
    mask.putpixel((6, 7), 255)
    def pack(pic):
        io = BytesIO()
        pic.save(io, "PNG")
        return io.getvalue()
    m, p, k = pack(master), pack(par), pack(mask)
    return m, p, {"tree": k}, {"tree": hashlib.sha256(k).hexdigest()}, hashlib.sha256(m).hexdigest()


class A03PrivateZipAndRuntimeTests(unittest.TestCase):
    def test_source_locked_zip_pass(self):
        binary = zip_fixture()
        r = scan_pmd_zip(binary, "example", hashlib.sha256(binary).hexdigest())
        self.assertEqual(r["native_png_checked"], 3)
        self.assertEqual(r["direction_rows"]["eight_rows"], 1)
        self.assertEqual(r["native_vx"], "NOT_RUN")

    def test_wrong_source_sha_fails(self):
        with self.assertRaises(PrivateZipError):
            scan_pmd_zip(zip_fixture(), "example", "a" * 64)

    def test_zip_missing_shadow_fails(self):
        binary = zip_fixture(omit="example/Walk-Shadow.png")
        with self.assertRaises(PrivateZipError):
            scan_pmd_zip(binary, "example", hashlib.sha256(binary).hexdigest())

    def test_zip_traversal_rejected(self):
        binary = zip_fixture(bad_name=True)
        with self.assertRaises(PrivateZipError):
            scan_pmd_zip(binary, "example", hashlib.sha256(binary).hexdigest())

    def test_zip_wrong_prefix_rejected(self):
        binary = zip_fixture()
        with self.assertRaises(PrivateZipError):
            scan_pmd_zip(binary, "../example", hashlib.sha256(binary).hexdigest())

    def test_runtime_mask_real_source_contract(self):
        args = runtime_fixture()
        r = check_runtime_objects(*args)
        self.assertEqual(r["owned_alpha_pixels"], 1)
        self.assertEqual(r["runtime_rgb_registration"], "PASS_SAME_XY")
        self.assertEqual(r["walkable_footpoint_occlusion_semantics"], "NOT_TESTED")

    def test_runtime_source_sha_rejected(self):
        m, p, mask, shas, _ = runtime_fixture()
        with self.assertRaises(RuntimeMaskError):
            check_runtime_objects(m, p, mask, shas, "a" * 64)

    def test_runtime_unowned_alpha_rejected(self):
        m, p, mask, shas, key = runtime_fixture()
        pic = Image.open(BytesIO(p)).convert("RGBA")
        pic.putpixel((7, 7), (32, 100, 70, 255))
        buf = BytesIO()
        pic.save(buf, "PNG")
        with self.assertRaises(RuntimeMaskError):
            check_runtime_objects(m, buf.getvalue(), mask, shas, key)

    def test_runtime_unregistered_rgb_rejected(self):
        m, p, mask, shas, key = runtime_fixture()
        pic = Image.open(BytesIO(p)).convert("RGBA")
        pic.putpixel((6, 7), (255, 0, 0, 255))
        buf = BytesIO()
        pic.save(buf, "PNG")
        with self.assertRaises(RuntimeMaskError):
            check_runtime_objects(m, buf.getvalue(), mask, shas, key)

    def test_runtime_overlapping_owner_rejected(self):
        m, p, mask, shas, key = runtime_fixture()
        mask["other"] = mask["tree"]
        shas["other"] = shas["tree"]
        with self.assertRaises(RuntimeMaskError):
            check_runtime_objects(m, p, mask, shas, key)

    def test_runtime_soft_mask_rejected(self):
        m, p, mask, shas, key = runtime_fixture()
        pic = Image.open(BytesIO(mask["tree"])).convert("L")
        pic.putpixel((6, 7), 127)
        b = BytesIO()
        pic.save(b, "PNG")
        mask["tree"] = b.getvalue()
        shas["tree"] = hashlib.sha256(mask["tree"]).hexdigest()
        with self.assertRaises(RuntimeMaskError):
            check_runtime_objects(m, p, mask, shas, key)


if __name__ == "__main__":
    unittest.main()
