from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import hashlib,zlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
clone=root/"VX_A09_4_N5_RUNTIME"
control=root/"VX_A09_4_N5_CONTROL"
script=root/"vx_real_actor_20261031"/"a09_4"/"stage1_real_native_weapon.rb"
orig=load((control/"Data"/"Scripts.rvdata").open("rb"))
test=load((clone/"Data"/"Scripts.rvdata").open("rb"))
assert len(orig)==len(test)==507
assert all(a==b for a,b in zip(orig,test))
assert b"ASF A09-4" in test[483][1]
test[483]=[999995,b"ASF A09-4 NATIVE WEAPON TESTONLY",zlib.compress(script.read_bytes(),9)]
with (clone/"Data"/"Scripts.rvdata").open("wb") as f:write(f,test)
again=load((clone/"Data"/"Scripts.rvdata").open("rb"))
assert len(again)==507 and all(a==b for i,(a,b) in enumerate(zip(orig,again)) if i!=483)
assert zlib.decompress(again[483][2])==script.read_bytes()
out={"stage":"A094_1","original_505_N5_and_B0_script_untouched":True,"test_script_index":483,"baseline":hashlib.sha256((control/"Data"/"Scripts.rvdata").read_bytes()).hexdigest(),"candidate":hashlib.sha256((clone/"Data"/"Scripts.rvdata").read_bytes()).hexdigest()}
(root/"vx_real_actor_20261031"/"a09_4"/"stage1_build.json").write_text(json.dumps(out,indent=2))
print(json.dumps(out))