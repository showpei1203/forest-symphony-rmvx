#!/usr/bin/env python3
"""Read-only scan: actual FS MapXXX.rvdata third layer usage of ISS ParaPassa 768..799."""
from pathlib import Path
from rubymarshal.reader import load
from collections import Counter
import struct,json
BASE=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data")
OUT=Path(__file__).resolve().parent/"R5_FORMAL_READONLY_AUDIT";OUT.mkdir(exist_ok=True)
maps=[]
for p in sorted(BASE.glob("Map[0-9][0-9][0-9].rvdata")):
 try:
  m=load(p.open("rb"))
  b=m.attributes["@data"]._private_data
  dim,w,h,depth,n=struct.unpack_from("<5i",b,0)
  assert n==w*h*depth and len(b)==20+2*n
  ids=struct.unpack_from("<"+str(n)+"H",b,20)
  z2=ids[w*h*2:w*h*3] if depth>=3 else []
  counters=Counter(z2)
  directional={str(k):v for k,v in sorted(counters.items()) if 768<=k<=799}
  top_non_passa={str(k):v for k,v in counters.most_common(10)}
  maps.append({"map_id":int(p.stem[3:]),"size_tiles":[w,h],"third_layer_passa_tiles":directional,
               "third_layer_passa_total":sum(directional.values()),"total_tiles":w*h,
               "third_layer_non_passa_count":w*h-sum(directional.values()),
               "third_layer_common":top_non_passa,
               "parallax_name":str(m.attributes["@parallax_name"]),
               "animated_parallax_named":bool(m.attributes["@parallax_name"] and str(m.attributes["@parallax_name"]).endswith("_1'"))})
 except Exception as e:maps.append({"map_id":int(p.stem[3:]),"error":str(e)})
agg={"status":"FORMAL_FS_MAPS_READONLY","maps_scanned":len(maps),
 "maps_with_passa":sum(x.get("third_layer_passa_total",0)>0 for x in maps),
 "all_passa_tiles":sum(x.get("third_layer_passa_total",0) for x in maps),
 "maps":maps}
(OUT/"R5_TRUE_FORMAL_PASSPASSA_THIRDLAYER_USAGE.json").write_text(json.dumps(agg,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"maps_scanned":agg["maps_scanned"],"maps_with_passa":agg["maps_with_passa"],"all_passa_tiles":agg["all_passa_tiles"],"top_maps":[{"id":x["map_id"],"size":x.get("size_tiles"),"passa":x.get("third_layer_passa_total"),"ids":x.get("third_layer_passa_tiles")} for x in maps if x.get("third_layer_passa_total",0)>0][:18]},ensure_ascii=False),flush=True)