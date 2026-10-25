from pathlib import Path
import json
src=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025\outputs\FS_V21_ASF_NATIVE32_BRIDGE_A03\tiled\map.tmj")
data=json.loads(src.read_text(encoding="utf-8"))
changed=[]
for layer in data["layers"]:
 if layer.get("name") in ("interactions","collision"):
  layer["visible"]=False
  changed.append(layer["name"])
dst=src.with_name("map.runtime_hidden_meta.tmj")
dst.write_text(json.dumps(data,indent=2),encoding="utf-8")
print("PATCHED",dst,"layers",changed)
