"""Test only wrong terrain identification, not artistic success."""
from pathlib import Path
import sys,tempfile
from PIL import Image
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
print("FS T-C biome identity gate synthetic 4/4 PASS; no art claims")
