from pathlib import Path
from rubymarshal.reader import load
import zlib,re,json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
base=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
scripts=load((base/"Data"/"Scripts.rvdata").open("rb"))
cfg=zlib.decompress(scripts[225][2]).decode("utf-8","replace")
pose_ref=json.loads((root/"a09_2_actor_poses"/"native_pose_lineage.json").read_text(encoding="utf-8"))
# Regex fixed 12 weapon fields from Tankentai 3.4d; do not infer timing from angle endpoints.
pattern=re.compile(r'(?m)^\s*"([^"\n]+)"\s*=>\s*\[\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(true|false)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(\d+)\s*,\s*(true|false)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(true|false)\s*\]')
weapons={}
for m in pattern.finditer(cfg):
 k=m.group(1)
 if k in ("喬伊普攻武器","喬伊普攻武器2","正常武器待機"):
  v=m.groups()[1:]
  weapons[k]={"xa":int(v[0]),"ya":int(v[1]),"za_front":v[2]=="true","angle_start_rgss":int(v[3]),"angle_end_rgss":int(v[4]),"origin_id":int(v[5]),"invert_horizontal":v[6]=="true",
   "scale_x":float(v[7]),"scale_y":float(v[8]),"pos_offset_x":int(v[9]),"pos_offset_y":int(v[10]),"weapon2":v[11]=="true","line":cfg[:m.start()].count("\n")+1}
assert "喬伊普攻武器" in weapons and "喬伊普攻武器2" in weapons,weapons
pose_pattern=re.compile(r'(?m)^\s*"([^"\n]+)"\s*=>\s*\[\s*(\d+)\s*,\s*(\d+)\s*,\s*(-?\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(true|false)\s*,\s*"([^"\n]*)"\s*\]')
lookup={m.group(1):m.groups() for m in pose_pattern.finditer(cfg)}
bindings=[]
for p in pose_ref:
 key=p["pose_key"]
 v=lookup.get(key)
 assert v is not None,key
 w=v[9]
 bindings.append({"pose_key":key,"clip_id":p["clip_id"],"file_no":p["file_no"],"row":p["row"],"fixed":p["fixed"],"weapon_key":w,
 "weapon_defined":(not w) or (w in weapons), "weapon_data":weapons.get(w)})
assert all(a["weapon_defined"] for a in bindings)
report={"origin":"K4 original compressed Scripts.rvdata entry 225 SBS Battler Configuration (K), not a generated config",
"source_script_sha256":hashlib.sha256((base/"Data"/"Scripts.rvdata").read_bytes()).hexdigest(),
"script_entry_name":scripts[225][1].decode("utf8","replace") if isinstance(scripts[225][1],bytes) else str(scripts[225][1]),
"weapon_fields":["Xa","Ya","Za","A1","A2","Or","Inv","Xs","Ys","Xp","Yp","Weapon2"],
"weapon_table":weapons,"poses":bindings,"validated":True,
"limits":"This maps exact Tankentai source definition values only. Time interpolation and dynamic runtime actor equipment, mirroring/position math are NOT independently verified by VX Game.exe."}
dest=root/"a09_3"/"joe_weapon_authority.json"
dest.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"weapons":weapons,"bindings":[{"clip":x["clip_id"],"name":x["pose_key"],"weapon":x["weapon_key"]} for x in bindings]},ensure_ascii=True,indent=2))