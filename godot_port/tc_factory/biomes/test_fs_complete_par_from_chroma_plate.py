"""D12 synthetic, deterministic tests only. NOT a generated art acceptance."""
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw

from fs_complete_par_from_chroma_plate import (
    convert_chroma_par, digest, parse_hex_color
)


def assert_rejected(fn, phrase):
    try:
        fn()
    except ValueError as error:
        if phrase not in str(error):
            raise AssertionError(f"Expected rejection {phrase!r}, got: {error}") from error
    else:
        raise AssertionError(f"Rejected input was wrongly accepted: {phrase}")


def main():
    with tempfile.TemporaryDirectory(prefix="tc_d12_chroma_") as tmp:
        root = Path(tmp)
        gp, pp = root / "GROUND.png", root / "FOREIGN_NON_GROUND_PLATE.png"
        ground = Image.new("RGB", (128, 96), (44, 39, 43))
        ground.save(gp)
        locked_sha = digest(gp)
        plate = Image.new("RGB", (128, 96), (0, 255, 0))
        brush = ImageDraw.Draw(plate)
        # A single plate carries every non-ground family together.
        brush.rectangle((18, 16, 57, 56), fill=(72, 73, 81))  # workshop
        brush.rectangle((70, 20, 95, 65), fill=(229, 91, 27))  # furnace
        brush.rectangle((32, 57, 83, 69), fill=(120, 126, 133))  # bridge
        plate.save(pp)
        report = convert_chroma_par(gp, pp, root / "valid", locked_sha)
        out = Image.open(root / "valid/PAR_ALL_NON_GROUND_CHROMA_CONVERTED.png")
        assert out.mode == "RGBA" and out.size == (128, 96)
        assert out.getpixel((0, 0))[3] == 0
        assert out.getpixel((22, 22)) == (72, 73, 81, 255)
        assert out.getpixel((75, 24)) == (229, 91, 27, 255)
        assert 0 < report["alpha_zero_pixels"] < 128 * 96
        assert report["alpha_nonbinary_pixels"] == 0
        assert report["formal_ART_GATE"] == "HOLD"
        assert digest(gp) == locked_sha, "Stage-one Ground must stay immutable"
        assert parse_hex_color("#00FF00") == (0, 255, 0)
        assert_rejected(lambda: parse_hex_color("FFF"), "6-digit")
        # Repeated image-generation failure mode: opaque full-city Master.
        Image.new("RGB", (128, 96), (58, 62, 66)).save(pp)
        assert_rejected(lambda: convert_chroma_par(gp, pp, root / "bad_master", locked_sha), "opaque Master")
        # All chroma background: alpha technically possible but no art.
        Image.new("RGB", (128, 96), (0, 255, 0)).save(pp)
        assert_rejected(lambda: convert_chroma_par(gp, pp, root / "empty", locked_sha), "empty plate")
        # Explicit corner contamination rejects the source.
        plate.putpixel((0, 0), (70, 40, 40))
        plate.save(pp)
        assert_rejected(lambda: convert_chroma_par(gp, pp, root / "bad_corner", locked_sha), "corners")
        plate.putpixel((0, 0), (0, 255, 0))
        plate.save(pp)
        # A 1px color shift may be accepted with strict bounded tolerance.
        plate.putpixel((0, 0), (1, 254, 0))
        plate.save(pp)
        assert_rejected(lambda: convert_chroma_par(gp, pp, root / "strict_key", locked_sha), "corners")
        convertible = convert_chroma_par(
            gp, pp, root / "tolerant", locked_sha, tolerance=2)
        assert convertible["alpha_zero_pixels"] > 0
        # Pixel world mismatch never gets silently resized.
        plate.resize((96, 96)).save(pp)
        assert_rejected(lambda: convert_chroma_par(gp, pp, root / "wrong_size", locked_sha), "pixel world size")
        plate.save(pp)
        # No transparent source is silently converted by the chroma bridge.
        transparent = plate.convert("RGBA")
        transparent.putpixel((18, 18), (20, 20, 20, 1))
        transparent.save(pp)
        assert_rejected(lambda: convert_chroma_par(gp, pp, root / "native_alpha", locked_sha), "existing RGBA PAR")
        # Ground lock is checked before source conversion.
        ground.putpixel((3, 3), (255, 255, 255))
        ground.save(gp)
        assert_rejected(lambda: convert_chroma_par(gp, pp, root / "ground_tampered", locked_sha), "SHA lock mismatch")
    print("D12 PASS: transparent alpha, composite, Ground SHA, corner, Master rejection, empty, world XY, tolerance, existing-alpha")


if __name__ == "__main__":
    main()
