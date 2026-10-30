from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import zlib,hashlib,json
r=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
master=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\N5_B0_ADAPTER_CANDIDATE")
clone=r/"VX_A09_4_N5_CONTROL"
marker=r/"vx_real_actor_20261031"/"a09_4"/"stage0_marker.rb"
original=load((master/"Data"/"Scripts.rvdata").open("rb"))
candidate=load((clone/"Data"/"Scripts.rvdata").open("rb"))
assert len(original)==len(candidate)==506
assert all(a==b for a,b in zip(original,candidate))
assert str(candidate[483][1]) in ("b'Main'","Main")
candidate.insert(483,[999994,b"ASF A09-4 STAGE0 MARKER TESTONLY",zlib.compress(marker.read_bytes())])
with (clone/"Data"/"Scripts.rvdata").open("wb") as f:write(f,candidate)
roundtrip=load((clone/"Data"/"Scripts.rvdata").open("rb"))
assert len(roundtrip)==507 and all(a==b for a,b in zip(original,roundtrip[:483]+roundtrip[484:]))
ini=clone/"Game.ini"
text=ini.read_bytes().splitlines(keepends=True)
ini.write_bytes(b"".join(b"Title=ASF_A094_N5_CONTROL\r\n" if t.startswith(b"Title=") else t for t in text))
res={"baseline_sha":hashlib.sha256((master/"Data"/"Scripts.rvdata").read_bytes()).hexdigest(),"candidate_sha":hashlib.sha256((clone/"Data"/"Scripts.rvdata").read_bytes()).hexdigest(),"source_entries":506,"test_entries":507,"unchanged":True,"marker_position":483}
(r/"vx_real_actor_20261031"/"a09_4"/"build_stage0.json").write_text(json.dumps(res,indent=2))
print(json.dumps(res))