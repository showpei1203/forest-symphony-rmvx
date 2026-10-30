from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import hashlib,zlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
src=root/"VX_A09_NATIVE_ISOLATED"/"Data"/"Scripts.rvdata"
dst=root/"VX_A09_3_INENGINE_BRIDGE"/"Data"/"Scripts.rvdata"
adapter=root/"vx_real_actor_20261031"/"a09_3"/"rgss2_capture_adapter.rb"
assert src.exists() and dst.exists()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(src)==sha(dst),"TEST CLONE DID NOT MATCH BASELINE"
original=load(src.open("rb"))
data=load(dst.open("rb"))
assert len(original)==len(data)==505
indices=[i for i,x in enumerate(data) if str(x[1]) in ("b'Main'","Main")]
assert indices==[482],indices
content=adapter.read_bytes()
assert content.isascii()
data.insert(482,[999992,b"ASF A09-3 Native Renderer TESTONLY",zlib.compress(content,9)])
with dst.open("wb") as f:write(f,data)
check=load(dst.open("rb"))
assert len(check)==506
assert zlib.decompress(check[482][2])==content
assert all(a==b for a,b in zip(original,check[:482]+check[483:])),"ORIGINAL ENTRY CHANGED"
ini=root/"VX_A09_3_INENGINE_BRIDGE"/"Game.ini"
s=ini.read_bytes()
s=b"\n".join(b"Title=FS_A093_NATIVE_BRIDGE_TESTONLY" if t.startswith(b"Title=") else t for t in s.split(b"\n"))
ini.write_bytes(s)
report={"status":"TEST_ONLY_NATIVE_ADAPTER_INSERTED_505_ORIGINAL_UNCHANGED",
"index":482,"scripts_original_entries":505,"scripts_candidate_entries":506,
"baseline_sha256":sha(src),"candidate_sha256":sha(dst),
"adapter_sha256":sha(adapter),"bin_original_unchanged":sha(src)}
path=root/"vx_real_actor_20261031"/"a09_3"/"bridge_build.json"
path.write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps(report,indent=2))