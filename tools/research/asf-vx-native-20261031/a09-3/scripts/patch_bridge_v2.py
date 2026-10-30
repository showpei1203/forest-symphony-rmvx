from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import hashlib,zlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
src=root/"VX_A09_NATIVE_ISOLATED"/"Data"/"Scripts.rvdata"
dst=root/"VX_A09_3_INENGINE_BRIDGE"/"Data"/"Scripts.rvdata"
adapter=root/"vx_real_actor_20261031"/"a09_3"/"rgss2_capture_adapter.rb"
original=load(src.open("rb"))
candidate=load(dst.open("rb"))
assert len(original)==505 and len(candidate)==506
assert all(a==b for a,b in zip(original,candidate[:482]+candidate[483:])), "SOURCE MODIFIED"
raw=adapter.read_bytes()
assert raw.isascii()
candidate[482]=[999992,b"ASF A09-3 Native Renderer TESTONLY",zlib.compress(raw,9)]
with dst.open("wb") as f:write(f,candidate)
verify=load(dst.open("rb"))
assert zlib.decompress(verify[482][2])==raw
assert all(a==b for a,b in zip(original,verify[:482]+verify[483:]))
print(json.dumps({"source_entries":505,"test_entries":506,"source_sha":hashlib.sha256(src.read_bytes()).hexdigest(),"test_sha":hashlib.sha256(dst.read_bytes()).hexdigest(),"adapter_sha":hashlib.sha256(raw).hexdigest()}))