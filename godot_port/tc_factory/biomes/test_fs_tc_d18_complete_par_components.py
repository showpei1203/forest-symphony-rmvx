"""D18 structural regression. Synthetic source and Ground; ART always HOLD."""
from pathlib import Path
import sys
import tempfile

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
from fs_tc_d18_complete_par_components import render, sha256


def rejected(fn, phrase):
    try:
        fn()
    except (ValueError, FileNotFoundError) as error:
        assert phrase in str(error), str(error)
    else:
        raise AssertionError("expected reject: " + phrase)


def main():
    with tempfile.TemporaryDirectory(prefix="tc_d18_forest_") as temp:
        root = Path(temp)
        g = root / "GROUND_RGB.png"
        p = root / "PAR_NEW_INDEPENDENT.png"
        Image.new("RGB", (1280, 928), (46, 40, 50)).save(g)
        ground_lock = sha256(g)
        src = Image.new("RGBA", (1474, 1067), (0, 0, 0, 0))
        draw = ImageDraw.Draw(src)
        # Six separated, fully authored source objects with all connected pixels intact.
        for x, y, width, height in [
            (30, 20, 80, 80), (290, 90, 100, 90),
            (90, 450, 90, 80), (630, 450, 100, 85),
            (380, 730, 85, 90), (510, 280, 80, 90)
        ]:
            draw.rectangle((x, y, x+width, y+height), fill=(112, 75, 38, 250))
        src.save(p)
        qa = render(g, p, root / "VALID", ground_lock, sha256(p))
        assert qa["world_pixels"] == [1280, 928]
        assert qa["alpha_zero_pixels"] > 0
        assert qa["polygon_trim_pixels"] == 0
        assert qa["source_significant_pixels_lost_to_polygon_trim"] == 0
        assert qa["all_six_independent_source_components_preserved"] is True
        assert qa["source_significant_pixels_preserved"] > 25000
        assert qa["private_art_Godot_4_7_2_native"] == "NOT_RUN"
        assert qa["formal_ART_PASS"] == "0/12"
        assert sha256(g) == ground_lock
        assert Image.open(root / "VALID" / "PAR_ALL_NON_GROUND_1280x928.png").mode == "RGBA"
        assert Image.open(root / "VALID" / "GROUND_PLUS_PAR_STATIC_QA_1280x928.png").size == (1280, 928)
        rejected(lambda: render(g, p, root / "EXTRA", "0"*64, sha256(p)), "Ground source SHA")
        rejected(lambda: render(g, p, root / "EXTRA", ground_lock, "0"*64), "PAR source SHA")
        rejected(lambda: render(g, p, root / "VALID", ground_lock, sha256(p)), "new empty")
        src.resize((1280, 928)).save(p)
        rejected(lambda: render(g, p, root / "WRONG_SIZE", ground_lock, sha256(p)), "1474x1067")
        Image.new("RGBA", (1474, 1067), (60, 60, 66, 255)).save(p)
        rejected(lambda: render(g, p, root / "OPAQUE", ground_lock, sha256(p)), "Opaque Master")
        Image.new("RGBA", (1474, 1067), (0, 0, 0, 0)).save(p)
        rejected(lambda: render(g, p, root / "EMPTY", ground_lock, sha256(p)), "Missing independent")
    print("D18 PASS synthetic: 1x six whole objects, original Ground lock, real alpha, no polygon trims, fail-closed source/size, ART HOLD")


if __name__ == "__main__":
    main()
