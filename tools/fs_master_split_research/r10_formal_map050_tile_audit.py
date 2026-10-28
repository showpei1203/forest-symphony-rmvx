from pathlib import Path
from rubymarshal.reader import load
from collections import Counter
import json,struct,hashlib
R=Path(__file__).resolve().parent
SRC=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
p=SRC/"Data"/"Map050.rvdata";obj=load(p.open("rb"))
w=obj.attributes["@width"];h=obj.attributes["@height"]
table=obj.attributes["@data"]._private_data
dim,xx,yy,depth,n=struct.unpack_from("<5i",table,0)
assert (w,h,xx,yy,depth,n)==(17,13,17,13,3,17*13*3)
data=struct.unpack_from("<"+str(n)+"H",table,20)
layers=[]
for k in range(depth):
 z=data[k*w*h:(k+1)*w*h]
 counts=Counter(z)
 layers.append({"index":k,"tiles":{str(i):v for i,v in counts.most_common(30)},
 "nonzero":sum(q!=0 for q in z),"first_6_rows":[list(z[y*w:(y+1)*w]) for y in range(6)]})
summary={"status":"R10_FORMAL_MAP050_SOURCE_LAYER_AUDIT",
"formal_map_id":50,"width":w,"height":h,
"map_file_sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
"parallax_name":str(obj.attributes.get("@parallax_name")),
"tileset_id":obj.attributes.get("@tileset_id"),
"layers":layers,
"event_count":len(obj.attributes.get("@events",{})),
"parallax_flags":{x:str(obj.attributes.get("@"+x)) for x in ["parallax_show","parallax_loop_x","parallax_loop_y","parallax_sx","parallax_sy"]},
"note":"Formal third-layer no ParaPassa 768..799; check native VX Game_Map#passable? before editing any tile."}
d=R/"R10_FORMAL_MAP_AUTHORITY"/"R10_MAP050_SOURCE_LAYER_AUDIT.json"
d.write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"tile_count":[x["tiles"] for x in layers],"map050_sha256":summary["map_file_sha256"],"events":summary["event_count"],"tileset":summary["tileset_id"]},ensure_ascii=False))