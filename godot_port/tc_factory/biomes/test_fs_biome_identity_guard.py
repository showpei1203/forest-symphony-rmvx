"""Test only wrong terrain identification, not artistic success."""
from pathlib import Path
import sys,tempfile
from PIL import Image, ImageDraw
sys.path.insert(0,str(Path(__file__).resolve().parent))
from fs_biome_identity_guard import analyze
with tempfile.TemporaryDirectory() as dirname:
    p=Path(dirname)/"sample.png"
    Image.new("RGB",(64,64),(218,164,76)).save(p)
    assert analyze(p,"WIND_ERODED_GOLD_SANDS")["biome_identity_gate"].startswith("PASS")
    assert analyze(p,"FROST_SNOWFIELD")["biome_identity_gate"].startswith("FAIL")
    Image.new("RGB",(64,64),(184,201,236)).save(p)
    assert analyze(p,"FROST_SNOWFIELD")["biome_identity_gate"].startswith("PASS")
    assert analyze(p,"WIND_ERODED_GOLD_SANDS")["biome_identity_gate"].startswith("FAIL")
    # D11 volcano candidate is overwhelmingly basalt gray with a modest orange lava network.
    # A yellow desert image must be rejected even though it contains warm orange pixels.
    Image.new("RGB",(64,64),(56,54,63)).save(p)
    with Image.open(p) as im:
        im=im.copy()
        ImageDraw.Draw(im).rectangle((3,3,18,14),fill=(254,92,18))
        im.save(p)
    assert analyze(p,"CRIMSON_VOLCANO")["biome_identity_gate"].startswith("PASS")
    assert analyze(p,"WIND_ERODED_GOLD_SANDS")["biome_identity_gate"].startswith("FAIL")
    Image.new("RGB",(64,64),(218,164,76)).save(p)
    assert analyze(p,"CRIMSON_VOLCANO")["biome_identity_gate"].startswith("FAIL")
    Image.new("RGB",(64,64),(184,201,236)).save(p)
    assert analyze(p,"CRIMSON_VOLCANO")["biome_identity_gate"].startswith("FAIL")
print("FS T-C biome identity gate synthetic 8/8 PASS; NO ART PASS CLAIM")
