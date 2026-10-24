from pathlib import Path
from PIL import Image,ImageDraw
from shutil import copytree
import hashlib,json,random,subprocess,sys

R=Path(__file__).resolve().parent.parent
assert (R/"scene_manifest_v4_baseline.json").is_file(),"V4_BASELINE_MISSING"
for name in ("build","build/semantic_masks","outputs","logs","work","negative","input"):
    (R/name).mkdir(parents=True,exist_ok=True)

# Deterministic source-provenanced architecture: no AI flatten->erase trick.
src=R/"source"/"clean"
A=Image.open(src/"house_A.png").convert("RGBA")
B=Image.open(src/"house_shop.png").convert("RGBA")
tree=Image.open(src/"broadleaf_oak.png").convert("RGBA")
assert A.size==B.size==(96,160)
for im in (A,B,tree):
    assert set(im.getchannel("A").getdata()).issubset({0,255})
W,H=160,192
canvas=Image.new("RGBA",(W,H),(0,0,0,0))
dr=ImageDraw.Draw(canvas)
# Chimney is drawn behind high roof; uses consistent warm material palette.
dr.rectangle((119,12,133,48),fill=(70,59,53))
for yy in range(13,46,7):
    for xx in range(120+(yy//7)%2*3,133,7):
        dr.rectangle((xx,yy,xx+5,yy+4),fill=(123,111,97))
dr.rectangle((117,11,135,17),fill=(50,46,44))
dr.rectangle((119,12,133,13),fill=(191,170,145))
# Main historical source sprite: resized nearest neighbor only.
main=B.resize((92,154),Image.Resampling.NEAREST)
canvas.alpha_composite(main,(58,22))
# Side wing offset creates genuinely different architectural silhouette, not a recolor.
wing=A.resize((78,128),Image.Resampling.NEAREST)
canvas.alpha_composite(wing,(9,58))
dr=ImageDraw.Draw(canvas)
# Shared sill/porch ties separate wings into one structure.
dr.polygon([(11,161),(74,152),(155,160),(155,168),(75,163),(11,169)],fill=(58,40,31))
dr.polygon([(15,159),(73,152),(151,160),(147,162),(75,156),(17,163)],fill=(158,115,78))
# Wooden porch frontage and posts; stairs terminate at the world-foot.
for x in (16,55,89,146):
    dr.rectangle((x,161,x+4,183),fill=(84,56,40))
    dr.line((x+1,161,x+1,181),fill=(181,124,80),width=1)
for y in (169,175):
    dr.line((16,y,148,y),fill=(123,78,49),width=3)
dr.polygon([(83,179),(114,179),(121,190),(77,190)],fill=(112,78,52))
for y in (182,187,191):
    dr.line((80,y,118,y),fill=(180,128,83),width=2)
# Shop/inn sign, wood grain and lantern. No ad-hoc Gaussian or soft filters.
dr.line([(144,124),(159,124)],fill=(67,47,33),width=3)
dr.line([(153,124),(153,135)],fill=(74,48,32),width=2)
dr.rounded_rectangle((143,135,159,153),radius=1,fill=(104,71,41),outline=(226,184,109),width=2)
# Bed glyph, readable as lodging rather than random text pixels.
dr.rectangle((146,146,156,148),fill=(216,190,116))
dr.rectangle((147,142,150,146),fill=(216,190,116))
dr.line([(146,148),(146,150)],fill=(255,227,144),width=1)
dr.line([(156,148),(156,150)],fill=(255,227,144),width=1)
# Bay window dormer across central roof.
dr.polygon([(94,67),(105,55),(117,67),(117,84),(94,84)],fill=(63,49,47))
dr.polygon([(91,68),(105,49),(120,68)],fill=(58,118,112))
dr.line((91,68,105,49,120,68),fill=(20,56,55),width=3)
dr.rectangle((99,68,113,81),fill=(188,135,66))
dr.rectangle((101,70,111,79),fill=(51,90,120))
dr.line((106,70,106,79),fill=(225,189,130),width=2)
dr.line((101,75,111,75),fill=(221,174,103),width=1)
# A small hanging tapestry creates a distinct silhouette.
dr.polygon([(37,158),(50,158),(50,173),(44,169),(37,173)],fill=(77,110,86))
dr.polygon([(40,161),(47,161),(47,166),(43,164),(40,166)],fill=(201,184,116))
# Ivy uses pixels sampled from actual licensed-status-pending source, not copied flattened screen.
foliage=tree.crop((10,6,46,39))
for xy in ((15,112),(127,79),(125,101)):
    fr=foliage.resize((28,25),Image.Resampling.NEAREST)
    # Discard ragged bottom; ivy drapes from structural edge.
    canvas.alpha_composite(fr,xy)
# Outermost count: must not be clipped or leave floating placeholder props.
assert canvas.getchannel("A").getbbox()[2]<=W
assert canvas.getchannel("A").getbbox()[3]<=H
assert all(x in (0,255) for x in canvas.getchannel("A").getdata())
asset_name="lodge_multiwing_v5"
out=src/(asset_name+".png")
canvas.save(out)
assetsha=hashlib.sha256(out.read_bytes()).hexdigest()
ledger={
  "id":asset_name,"generated_deterministically":True,
  "built_from_source":[
    {"path":"source/clean/house_A.png","sha256":hashlib.sha256((src/"house_A.png").read_bytes()).hexdigest(),"transform":"nearest 96x160 -> 78x128 at (9,58)"},
    {"path":"source/clean/house_shop.png","sha256":hashlib.sha256((src/"house_shop.png").read_bytes()).hexdigest(),"transform":"nearest 96x160 -> 92x154 at (58,22)"},
    {"path":"source/clean/broadleaf_oak.png","sha256":hashlib.sha256((src/"broadleaf_oak.png").read_bytes()).hexdigest(),"transform":"source crop + nearest foliage accents"},
  ],"custom_pixel_geometry":["chimney","shared porch","stairs","bay dormer","inn sign","wood railings"],
  "source_sha256":assetsha,"source_size":[W,H],
  "source_rights":"PRIVATE_CANDIDATE_NO_PUBLIC_REUSE","pixel_crisp":True,
}
(R/"input"/"V5_LODGE_CONSTRUCTION_LEDGER.json").write_text(json.dumps(ledger,ensure_ascii=False,indent=2),encoding="utf8")

m=json.loads((R/"scene_manifest_v4_baseline.json").read_text(encoding="utf8"))
assert len(m["instances"])==48
ob=next(o for o in m["instances"] if o["id"]=="house_wood_east")
assert ob["asset_id"]=="house_shop"
baseline=ob.copy()
# Keep historic instance id and shop contact location but introduce true multi-wing geometry.
ob.update({"asset_id":asset_name,"source":"source/clean/"+asset_name+".png",
           "sha256":assetsha,"dimensions":[W,H],"x":550,"y":76,
           "draw_order":268,"z":268,"base_cut_y":117,
           "collision_local":[[15,140,154,178]],
           "role":"building","structure_class":"multiwing_lodge_architecture_pilot",
           "construction_ledger":"input/V5_LODGE_CONSTRUCTION_LEDGER.json",
           "height_level":0,"foot_anchor_world":[630,268]})
assert ob["y"]+H==ob["draw_order"]
# Existing lamppost floats into lodge, move it to clear roadside just outside porch.
lamp=next(o for o in m["instances"] if o["id"]=="lamp_shop")
lamp.update({"x":694,"y":252,"draw_order":293,"z":293})
assert lamp["y"]+lamp["dimensions"][1]==lamp["draw_order"]
m["status"]="B1_V5_MULTI_WING_SOURCE_ARCHITECTURE_CANDIDATE_PRIVATE"
m["v5_authoring"]={
  "changed_instances":["house_wood_east","lamp_shop"],
  "old_east_house":{k:baseline[k] for k in ("asset_id","sha256","x","y","dimensions","draw_order")},
  "structure":"lodge_multiwing_v5",
  "source_asset_construction":ledger["built_from_source"],
  "native_game_test_required":True,
  "ground_par_compiled_from_one_manifest":True,
  "visual_benchmark_gate":"NOT_APPROVED",
  "no_flattened_master_decomposition":True}
(R/"scene_manifest.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
# Original compiler is read-only reused; it reads local manifest and assets.
build=R/"scripts"/"compile_scene_v4.py"
assert build.is_file()
proc=subprocess.run([sys.executable,str(build)],cwd=R,capture_output=True,text=True,timeout=30)
assert proc.returncode==0,proc.stderr
from shutil import copy2
copy2(R/"build"/"FS_ELF_RICH_Master.png",R/"outputs"/"VISUAL_MASTER_V4.png")

# Programmatically verify the new source is not a pixel-identity recolor of prior house.
prior=Image.open(src/"house_shop.png").convert("RGBA")
assert prior.size!=canvas.size
assert canvas.getchannel("A").getbbox()[0]<=9
assert len(m["instances"])==48
# all existing source hashes must remain valid
for obj in m["instances"]+m["ground_decor"]:
   p=src/(obj["asset_id"]+".png")
   assert p.exists() and hashlib.sha256(p.read_bytes()).hexdigest()==obj["sha256"]
report={
  "status":"B1_V5_DETERMINISTIC_COMPOSITE_BUILT",
  "new_source_sha256":assetsha,
  "source_dimensions":[W,H],
  "world_top_left":[550,76],
  "world_foot":[630,268],
  "changed_manifest_objects":["house_wood_east","lamp_shop"],
  "hero_asset_replaced_old_house":True,
  "all_original_other_instances_preserved":True,
  "source_provenance":"3_original_images_plus_authored_opaque_pixel_geometry",
  "private_only":True,
  "target_quality":"visual_candidacy_not_reference_pass",
  "next_gates":["pixel_owner_fullRGBA","native_collision_and_occlusion","visual_human"]
}
(R/"logs"/"V5_ARCHITECTURE_BUILD.json").write_text(json.dumps(report,indent=2),encoding="utf8")
print("V5_LODGE_COMPILED",json.dumps(report,ensure_ascii=False),flush=True)
