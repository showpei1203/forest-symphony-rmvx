"""T-C shared Ground-first/all-CompletePAR checker unit tests (synthetic 64px)."""
import sys
import tempfile
from pathlib import Path
from PIL import Image, ImageDraw

sys.path.insert(0,str(Path(__file__).resolve().parents[0]))
from fs_validate_ground_complete_par import inspect_pair,sha

def main():
    with tempfile.TemporaryDirectory(prefix="fs_tc_twelve_") as raw:
        d=Path(raw)
        ground=Image.new("RGB",(64,64),(180,180,190))
        ground.save(d/"GROUND.png")
        par=Image.new("RGBA",(64,64),(0,0,0,0))
        ImageDraw.Draw(par).rectangle((20,10,36,45),fill=(50,70,90,255))
        par.save(d/"PAR.png")
        good=inspect_pair(d/"GROUND.png",d/"PAR.png",d/"ok","FS_SYNTHETIC",32,sha(d/"GROUND.png"))
        assert good["technical_composition"]=="PASS"
        assert good["technical_checks"]["PAR_NO_ACTOR_OCCLUSION_SUBSET"]
        assert good["technical_checks"]["low_alpha_artifacts_below_0_01pct"]
        assert good["technical_checks"]["crop_edge_opaque_source_risk_low"]
        assert good["formal_ART_GATE"].startswith("HOLD")
        # Source Alpha fringe should remain in QA, not silently recolored.
        par.putpixel((0,0),(255,0,0,1))
        par.save(d/"PAR.png")
        low=inspect_pair(d/"GROUND.png",d/"PAR.png",d/"edge","FS_SYNTHETIC",32,sha(d/"GROUND.png"))
        assert low["alpha_distribution"]["alpha_1_to_8"]==1
        # Modified Ground MUST fail closed rather than unexpectedly regenerate PAR.
        locked=sha(d/"GROUND.png")
        ground.putpixel((0,0),(1,1,1))
        ground.save(d/"GROUND.png")
        try:
            inspect_pair(d/"GROUND.png",d/"PAR.png",d/"fail","FS_SYNTHETIC",32,locked)
        except ValueError:
            pass
        else:
            raise AssertionError("Modified Ground incorrectly accepted")
    print("PASS synthetic: source lock, all-PAR alpha, image size, art gate fails closed")

if __name__=="__main__":
    main()
