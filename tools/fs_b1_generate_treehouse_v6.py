from pathlib import Path
from PIL import Image,ImageDraw
from shutil import copytree,copy2
import json,hashlib,subprocess,sys,math

R=Path(__file__).resolve().parent.parent
for name in ("build","build/semantic_masks","outputs","outputs/dynamic","logs","work","negative","input"):
 (R/name).mkdir(parents=True,exist_ok=True)
assert (R/"scene_manifest_v5_baseline.json").is_file()
assert (R/"baseline"/"v5_Master.png").is_file()
src=R/"source"/"clean"
orig=src/"tree_A.png"
spr=Image.open(orig).convert("RGBA")
assert spr.size==(64,64)
house=Image.open(src/"house_A.png").convert("RGBA")
leaf=Image.open(src/"broadleaf_oak.png").convert("RGBA")
spruce=Image.open(src/"conifer_spruce.png").convert("RGBA")
roof_part_path=R/"source"/"roof_green_kit.png"
assert roof_part_path.is_file(),"ROOF_SOURCE_MISSING"
roof=Image.open(roof_part_path).convert("RGBA")
assert all(sum(img.getchannel("A").histogram()[1:255])==0 for img in (spr,house,leaf,roof))
W,H=160,192
im=Image.new("RGBA",(W,H))
d=ImageDraw.Draw(im)
# Natural, slightly irregular trunk/roots extend below the elevated platform.
d.polygon([(68,76),(84,70),(99,155),(93,171),(95,182),(112,189),(108,191),
           (84,183),(79,191),(61,191),(68,177),(68,149),(64,110)],fill=(81,55,37))
d.polygon([(73,87),(81,78),(88,162),(82,185),(74,182)],fill=(137,90,47))
d.line([(71,103),(73,146),(72,180)],fill=(161,117,65),width=3)
d.line([(90,119),(88,151),(92,176)],fill=(42,47,33),width=3)
# Bridge limbs support canopy, not a resized flat trunk.
for pts,width in [
 ([(76,130),(53,108),(27,102)],11),
 ([(87,119),(111,95),(141,89)],10),
 ([(74,158),(50,148),(38,135)],8)
]:
 d.line(pts,fill=(86,57,35),width=width,joint="curve")
 d.line(pts,fill=(146,99,53),width=max(2,width//3),joint="curve")
# Canopy built from actual source pixel foliage, nearest-neighbor scaling only.
canopy=leaf.resize((90,92),Image.Resampling.NEAREST)
im.alpha_composite(canopy,(0,12))
spruce_crop=spruce.crop((0,0,min(58,spruce.width),min(49,spruce.height)))
spruce_crop=spruce_crop.resize((62,56),Image.Resampling.NEAREST)
im.alpha_composite(spruce_crop,(100,17))
im.alpha_composite(leaf.resize((62,60),Image.Resampling.NEAREST),(86,2))
# Raised habitation, recognizable roof from private reusable sprite source.
hut=house.crop((4,26,92,138)).resize((79,92),Image.Resampling.NEAREST)
im.alpha_composite(hut,(41,31))
# Additional green roof texture from a separate clean source candidate.
if roof.width>65 and roof.height>35:
 roofimg=roof.crop((max(0,(roof.width-78)//2),0,min(roof.width,(roof.width+78)//2),min(roof.height,57)))
 roofimg=roofimg.resize((71,49),Image.Resampling.NEAREST)
 im.alpha_composite(roofimg,(45,23))
d=ImageDraw.Draw(im)
# Floating platform has true frame, triangular brackets, visible above actor at foot.
d.polygon([(23,120),(128,113),(142,121),(142,133),(36,137),(23,131)],fill=(62,42,29))
d.polygon([(25,120),(130,113),(137,117),(36,129)],fill=(162,116,71))
for k in range(28,135,8):
 yy=121-int((k-25)*.06)
 d.line((k,yy,k+3,yy+11),fill=(78,57,36),width=2)
d.line((31,136,73,172),fill=(104,69,44),width=7)
d.line((133,131,94,174),fill=(104,69,44),width=7)
d.line((36,136,74,168),fill=(162,112,57),width=2)
d.line((130,131,95,167),fill=(162,112,57),width=2)
# Ladder down to ground - vertical ladder intentionally visual-only until level-aware climb implemented.
d.line((105,133,106,188),fill=(89,60,39),width=5)
d.line((126,130,127,188),fill=(89,60,39),width=5)
for yy in range(141,188,8):
 d.line((107,yy,126,yy-2),fill=(193,138,80),width=3)
d.line((108,136,110,186),fill=(217,163,98),width=1)
# Walkway rails and shutters.
for x,y in ((24,114),(48,112),(130,108)):
 d.line((x,y,x,y+16),fill=(109,69,43),width=4)
d.line((25,114,130,109),fill=(185,142,83),width=3)
# Distinct hanging spiral symbol sign, anchored to raised balcony.
d.line((132,106,144,111),fill=(100,64,40),width=3)
d.line((141,109,141,118),fill=(119,70,39),width=2)
d.ellipse((135,119,151,135),fill=(83,111,73),outline=(229,208,128),width=2)
d.arc((138,122,148,133),20,300,fill=(242,227,171),width=2)
# trunk base / small roots
for x,y in ((56,179),(92,183)):
 d.polygon([(x,y),(x-7,y+8),(x+4,y+5)],fill=(115,78,47))
# center foot is solid; canopy/house upper portions have alpha-source owner masks.
assert im.getchannel("A").getbbox()==(0,2,160,192),im.getchannel("A").getbbox()
assert sum(im.getchannel("A").histogram()[1:255])==0,"V6_SEMIALPHA_NOT_SUPPORTED"
name="treehouse_grove_v6"
asset=src/(name+".png")
im.save(asset)
sources=[
 "source/clean/house_A.png",
 "source/clean/broadleaf_oak.png",
 "source/clean/conifer_spruce.png",
 "source/roof_green_kit.png"
]
hashes={f:hashlib.sha256((R/f).read_bytes()).hexdigest() for f in sources}
ledger={"name":name,"mode":"source_backed_composite+original_pixel_details","parts":hashes,
 "construction":["wooden trunk/branches and roots","two foliage families+source spruce","elevated hut",
                 "green roof cut","wooden deck, stilts, rails, ladder, hanging treehouse sign"],
 "native_climb_logic":"NOT_IMPLEMENTED_ONLY_COLLISION_BASE",
 "alpha":"BINARY_0_255","source_sha256":hashlib.sha256(asset.read_bytes()).hexdigest(),
 "private_asset_licenses":"NOT_CLEARED_FOR_PUBLIC_RELEASE"}
(R/"input"/"V6_TREEHOUSE_LEDGER.json").write_text(json.dumps(ledger,ensure_ascii=False,indent=2),encoding="utf8")
m=json.loads((R/"scene_manifest_v5_baseline.json").read_text(encoding="utf8"))
ob=next(o for o in m["instances"] if o["id"]=="grove_tree_south")
assert ob["asset_id"]=="tree_A"
# Same approximate anchor as old tree, preserve sacred grove and ring road.
ob.update({"asset_id":name,"source":"source/clean/"+name+".png",
 "sha256":ledger["source_sha256"],"dimensions":[W,H],
 "x":361,"y":142,"draw_order":334,"z":334,"base_cut_y":139,
 "collision_local":[[63,165,98,190]],
 "role":"building_treehouse","structure_class":"elevated_treehouse_no_climb_v6",
 "height_level":0,"upper_structure_level":1,
 "level_adapter_state":"VISUAL_ONLY_NOT_PLAYABLE_ABOVE",
 "foot_anchor_world":[438,334],
 "construction_ledger":"input/V6_TREEHOUSE_LEDGER.json"})
assert ob["y"]+H==ob["draw_order"]
m["status"]="B1_TREEHOUSE_V6_SOURCE_COMPOSITE_CANDIDATE"
m["v6_authoring"]={
 "parent":"B1_MULTI_WING_LODGE_V5",
 "replaced_instance":"grove_tree_south",
 "source_kit_ledger":"input/V6_TREEHOUSE_LEDGER.json",
 "real_roof_climb_and_height_level":"NOT_IMPLEMENTED",
 "do_not_label_formal_pass":True}
(R/"scene_manifest.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
ret=subprocess.run([sys.executable,str(R/"scripts"/"compile_scene_v4.py")],cwd=R,capture_output=True,text=True,timeout=30)
assert ret.returncode==0,("SCENE_COMPILER_FAIL",ret.stdout,ret.stderr)
copy2(R/"build"/"FS_ELF_RICH_Master.png",R/"outputs"/"VISUAL_MASTER_V4.png")
(R/"logs"/"V6_GENERATION_STATUS.json").write_text(json.dumps({
 "source_sha256":ledger["source_sha256"],"new_asset_dimensions":[W,H],
 "replaced_id":"grove_tree_south","foot_world":[438,334],"level1_physical_climb":"NOT_IMPLEMENTED",
 "source_part_sha256":hashes,"source_rebuild_status":"PASS",
 "formal_runtime":"NOT_TESTED"},ensure_ascii=False,indent=2),encoding="utf8")
print("V6_TREEHOUSE_BUILT",ledger["source_sha256"],"dims",W,H,"foot",438,334,flush=True)
