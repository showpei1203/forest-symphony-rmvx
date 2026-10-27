from pathlib import Path
from rubymarshal.reader import load
import struct,json
R=Path(__file__).resolve().parent
src=R/"R5_FORMAL_ADAPTER_ISOLATED"/"FULL505"/"Data"/"Map001.rvdata"
map=load(src.open("rb"))
b=map.attributes["@data"]._private_data
dim,w,h,depth,n=struct.unpack_from("<5i",b,0)
assert (w,h,depth)==(30,25,3)
vals=struct.unpack_from("<"+str(n)+"H",b,20)
passa=[[int(vals[x+y*w+2*w*h]) for x in range(17)] for y in range(13)]
assert passa[6][5]==768 and passa[7][10]==768 and passa[8][14]==768
out=R/"R7_SEMANTIC_MASK_CANDIDATES"/"R5_ISOLATED_MAP001_THIRD_LAYER_17x13.json"
out.write_text(json.dumps({"source":"R5_ISOLATED_MAP001_NOT_FORMAL_FS_MAP","dim":[17,13],"ids":passa},indent=2),encoding="utf8")
print("EXPORTED_ISOLATED_17x13",sum(sum(v==769 for v in row) for row in passa),flush=True)