#!/usr/bin/env python3
"""READ-ONLY FS actual script/map authority and potential display/passability interactions."""
from pathlib import Path
from rubymarshal.reader import load
from collections import Counter,defaultdict
import hashlib,json,zlib,re
FORMAL=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
OUT=Path(__file__).resolve().parent/"R5_FORMAL_READONLY_AUDIT";OUT.mkdir(exist_ok=True)
source=FORMAL/"Data"/"Scripts.rvdata"
a=load(source.open("rb"))
scripts=[]
for ix,row in enumerate(a):
 try:
  name=row[1].decode("utf-8","replace") if isinstance(row[1],bytes) else str(row[1])
  data=zlib.decompress(row[2])
  txt=data.decode("utf-8","replace")
 except Exception as e:
  scripts.append({"ix":ix,"error":str(e)})
  continue
 scripts.append({"ix":ix,"name":name,"bytes":len(data),"aliases":len(re.findall(r"(?m)^\s*alias\b",txt)),
 "map_def_methods":re.findall(r"(?m)^\s*def\s+(create_parallax|update_parallax|create_characters|update_characters|passable\?|move_passable\?|setup_parallax|create_viewports|update_viewports|start|terminate)\b",txt),
 "overlay_refs":len(re.findall(r"\$OverlayMap|HK_UOM|Overlay_Map|ParaPassa",txt)),
 "key_snippets":{tag:len(re.findall(re.escape(tag),txt)) for tag in ["@par_viewport","@character_sprites","@viewport1","@viewport2","@viewport3","@ground","@parallax","@shadow2_viewport","Layer","Ground"]}
 })
index={s["ix"]:s for s in scripts}
matched=[x for x in scripts if any(term in x.get("name","") for term in ["HK -","ParaPassa","Animated Parallax","Neo Light","LegacyScripts","Spriteset_Map","Game_Map"])]
print("FS_ACTUAL_SCRIPTS",len(a),"names",[(v["ix"],v["name"],v["bytes"]) for v in matched],flush=True)
# inspect actual Map01 and map collection for RPG Map data data Table encoding
maps=[]
for path in sorted((FORMAL/"Data").glob("Map[0-9][0-9][0-9].rvdata")):
 try:
  z=load(path.open("rb"))
  ivars=getattr(z,"attributes",None)
  if not isinstance(ivars,dict):ivars=getattr(z,"__dict__",{})
  def get(*names):
   for n in names:
    if n in ivars:return ivars[n]
   return None
  data=get(b"@data","@data","data")
  width=get(b"@width","@width","width");height=get(b"@height","@height","height")
  para=get(b"@parallax_name","@parallax_name","parallax_name")
  tinfo={"type":type(data).__name__,"attrs":str(type(data)),"repr":repr(data)[:230]}
  if hasattr(data,"__dict__"):tinfo["attrs_keys"]=[str(x) for x in data.__dict__.keys()]
  item={"id":int(path.stem[3:]),"width":width,"height":height,"parallax":str(para),
        "map_object_type":str(type(z)),"map_keys":[str(k) for k in list(ivars)[:26]],
        "table":tinfo}
  maps.append(item)
 except Exception as e:maps.append({"id":int(path.stem[3:]),"error":str(e)})
print("FS_MAPS",len(maps),"first",maps[:3],flush=True)
result={"status":"READ_ONLY_VERIFIED","actual_scripts_sha256":hashlib.sha256(source.read_bytes()).hexdigest(),
"actual_scripts_count":len(a),"scripts_matching_relevant_names":matched,"map_files":maps,
"notes":"Only statically extracted actual formal K4 baseline; NO game files modified."}
(OUT/"R5_FORMAL_SCRIPT_MAP_AUDIT.json").write_text(json.dumps(result,ensure_ascii=False,indent=2,default=str),encoding="utf8")
(OUT/"R5_SCRIPT_INDEX_FULL.json").write_text(json.dumps(scripts,ensure_ascii=False,indent=2),encoding="utf8")