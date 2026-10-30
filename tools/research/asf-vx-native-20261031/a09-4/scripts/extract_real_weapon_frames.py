from pathlib import Path
from PIL import Image
import json,re,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
lab=root/"vx_real_actor_20261031"/"a09_4"
native=root/"VX_A09_4_N5_RUNTIME"
engine=root/"vx_real_actor_20261031"/"a09_2_actor_poses"/"engine"/"godot"
src=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Graphics\System\IconSet.png")
icon_index=548
atlas=Image.open(src).convert("RGBA")
icon=atlas.crop((icon_index%16*24,icon_index//16*24,icon_index%16*24+24,icon_index//16*24+24))
icon.save(engine/"weapon_icon_548.png")
lines=(native/"ASF_A094_DIAGNOSTIC.log").read_text(encoding="ascii").splitlines()
p=re.compile(r'^A094_WPN i=(\d+) tick=(\d+) angle=([-.\d]+) x=([-.\d]+) y=([-.\d]+) z=([-.\d]+) ox=([-.\d]+) oy=([-.\d]+) mirror=(true|false) icon=(\d+),(\d+)$')
samples=[]
for line in lines:
 m=p.match(line)
 if not m:continue
 i,t,angle,x,y,z,ox,oy,flip,icon_x,icon_y=m.groups()
 samples.append({"profile":int(i),"tick":int(t),"angle_rgss":float(angle),"x":float(x),"y":float(y),"z":float(z),"ox":float(ox),"oy":float(oy),"flip":flip=="true","icon":[int(icon_x),int(icon_y)]})
assert len(samples)==12 and all(s["icon"]==[96,816] for s in samples)
report={"characters":["p01","p03","p05"],"origin_x":[90,270,450],"origin_y":145,"native_source":"RGSS2 Sprite_Weapon dynamic trace on isolated N5 507-script runtime","icon":{"weapon_id":2,"icon_index":548,"crop":[96,816,24,24],"atlas_sha256":hashlib.sha256(src.read_bytes()).hexdigest(),"crop_sha256":hashlib.sha256(icon.tobytes()).hexdigest()},"samples":samples}
(lab/"native_weapon_12_samples.json").write_text(json.dumps(report,indent=2))
(engine/"native_weapon_12_samples.json").write_text(json.dumps(report,indent=2))
print(json.dumps({"samples":len(samples),"icon_sha":report["icon"]["crop_sha256"],"area":icon.getbbox(),"t0":[x for x in samples if x["tick"]==0]},indent=2))