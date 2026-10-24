from pathlib import Path
from shutil import copytree,copy2
from PIL import Image,ImageDraw
import hashlib,json,subprocess,sys
R=Path(__file__).resolve().parent.parent
assert (R/"scene_manifest_v6_baseline.json").exists()
assert (R/"source"/"clean"/"treehouse_grove_v6.png").exists()
for dn in ("build","build/semantic_masks","outputs","logs","work","negative"):
 (R/dn).mkdir(parents=True,exist_ok=True)
img=Image.open(R/"source"/"clean"/"treehouse_grove_v6.png").convert("RGBA")
assert img.size==(160,192)
W,H=192,192
out=Image.new("RGBA",(W,H),(0,0,0,0))
dr=ImageDraw.Draw(out)
# Elevated deck extends east of house, backed by wood beams and two slanted struts.
# Physical raised-level footprint: world tiles (15,8) and (16,8), not a ground tile.
dr.polygon([(124,112),(186,106),(191,110),(191,133),(126,139)],fill=(77,54,37))
dr.polygon([(119,114),(188,108),(191,114),(128,125)],fill=(184,137,81))
dr.line([(125,134),(188,127)],fill=(44,37,28),width=4)
for x in range(128,191,9):
 y=124-round((x-128)*0.09)
 dr.line([(x,y),(x+1,y+9)],fill=(94,66,44),width=2)
for a,b in [((133,137),(119,170)),((178,130),(159,168))]:
 dr.line((a,b),fill=(69,49,31),width=7)
 dr.line((a,b),fill=(154,105,55),width=2)
# East-side railing, deliberately drawn at edge and not through platform floor.
for x,y in ((145,112),(173,108),(189,106)):
 dr.rectangle((x,y-13,x+3,y+7),fill=(106,67,42))
 dr.line([(x+1,y-12),(x+1,y+4)],fill=(195,145,78),width=1)
dr.line([(143,103),(189,99)],fill=(183,133,68),width=3)
# Original source-backed treehouse overlaid in exactly its original local coordinates.
out.alpha_composite(img,(0,0))
# Two short horizontal rail segments tie legacy platform into new extension.
dr=ImageDraw.Draw(out)
dr.line([(130,115),(145,112)],fill=(187,132,74),width=3)
dr.line([(132,133),(156,129)],fill=(64,43,30),width=3)
assert set(out.getchannel("A").getdata()).issubset({0,255})
asset=R/"source"/"clean"/"treehouse_grove_v7.png"
out.save(asset)
ledger={
 "id":"treehouse_grove_v7","base_source":"source/clean/treehouse_grove_v6.png",
 "base_sha256":hashlib.sha256((R/"source"/"clean"/"treehouse_grove_v6.png").read_bytes()).hexdigest(),
 "source_sha256":hashlib.sha256(asset.read_bytes()).hexdigest(),
 "source_dimensions":[W,H],
 "authored_extensions":["east raised wooden deck","independent beams","hand rails"],
 "source_license":"PRIVATE_TEST_ONLY",
 "draw_origin_same_as_v6":True}
(R/"input"/"V7_PLATFORM_LEDGER.json").write_text(json.dumps(ledger,ensure_ascii=False,indent=2),encoding="utf8")
m=json.loads((R/"scene_manifest_v6_baseline.json").read_text(encoding="utf8"))
hero=next(o for o in m["instances"] if o["id"]=="grove_tree_south")
assert hero["asset_id"]=="treehouse_grove_v6"
hero.update({"asset_id":"treehouse_grove_v7","source":"source/clean/treehouse_grove_v7.png",
 "sha256":ledger["source_sha256"],"dimensions":[W,H],
 "construction_ledger":"input/V7_PLATFORM_LEDGER.json",
 "structure_class":"elevated_treehouse_level1_platform_v7",
 "level_adapter_state":"LEVEL1_RGSS2_MANUAL_INTERACTION_CANDIDATE"})
assert hero["y"]+H==334
m["height_layers"]={"treehouse_deck":{
 "object_id":"grove_tree_south","level":1,
 "ground_ladder_tile":[15,10],
 "platform_landing_tile":[15,8],
 "platform_walkable_tiles":[[15,8],[16,8]],
 "visual_elevation_px":30,
 "actor_z_on_platform":800,
 "level0_trunk_collision_local":[[63,165,98,190]],
 "allowed_transition":"Input C at [15,10] to [15,8] and Input C at [15,8] back to [15,10]",
 "outside_platform_passage":"BLOCKED",
 "no_side_entry":"LEVEL1_ONLY_VIA_LADDER"}}
m["height_layers"]["treehouse_deck"].update({
 "upper_occlusion_ids":["grove_tree_ne"],
 "upper_occlusion_z":900,
 "upper_occlusion_mode":"visible_owner_mask_at_pixel_resolution"})
m["v7_authoring"]={
 "status":"LEVEL1_SOURCE_BACKED_ENGINE_CANDIDATE_NOT_FORMAL",
 "changed_instances":["grove_tree_south"],
 "source_ledger":"input/V7_PLATFORM_LEDGER.json"}
m["status"]="FS_B1_V7_LEVEL1_TREEHOUSE_PLATFORM_TEST_CANDIDATE"
(R/"scene_manifest.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
ret=subprocess.run([sys.executable,str(R/"scripts"/"compile_scene_v4.py")],
 cwd=R,capture_output=True,text=True,timeout=35)
assert ret.returncode==0,ret.stderr
copy2(R/"build"/"FS_ELF_RICH_Master.png",R/"outputs"/"VISUAL_MASTER_V4.png")
print("V7_PLATFORM_SOURCE_BUILT",json.dumps({"sha":ledger["source_sha256"],"size":[W,H],"level1":m["height_layers"]["treehouse_deck"]},ensure_ascii=False),flush=True)
