from pathlib import Path
from PIL import Image,ImageDraw
from shutil import copy2
import json,hashlib,math,random,subprocess,sys
R=Path(__file__).resolve().parent.parent
for dn in ("build","build/semantic_masks","build/height","outputs","logs","work","negative"):
 (R/dn).mkdir(parents=True,exist_ok=True)
assert (R/"scene_manifest_v7_baseline.json").is_file()
S=R/"source";C=S/"clean";T=S/"terrain"
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

grass=Image.open(T/"grass_tile.png").convert("RGBA")
path=Image.open(T/"path_tile.png").convert("RGBA")
assert grass.size==path.size==(32,32)
W,H=864,640
water=Image.new("RGBA",(W,H));q=ImageDraw.Draw(water)
rng=random.Random(20261024)
# Creek north-south. Shallow center (x16) is a ford beneath the elevated bridge.
# Deep water occupies x15/x17 and cannot be entered while on level0.
for y in range(432,589,4):
 phase=(y-432)//4
 center=528+int(round(4*math.sin(phase*.24)))
 radius=44+int(round(2*math.sin(phase*.41)))
 left=center-radius;right=center+radius
 shore=(109,94,65,255) if phase%3 else (127,112,75,255)
 q.rectangle((left-9,y,right+8,y+3),fill=shore)
 q.rectangle((left-5,y,right+4,y+3),fill=(74,113,99,255))
 q.rectangle((left,y,right,y+3),fill=(36,101,141,255) if phase%4 else (31,89,131,255))
 # Parallel ripples and foam in 4x2 hard-edged pixels. No resampling.
 for i in range(6):
  xx=left+6+((phase*7+i*19)%(radius*2-16))
  if (i+phase)%4==0:
   q.rectangle((xx,y,xx+7,y+1),fill=(76,153,170,255))
  elif (i+phase)%7==0:
   q.rectangle((xx,y,xx+3,y+1),fill=(49,125,167,255))
# Stone riverbed for north-south lower underpass; still looks like shallow water.
for y in range(448,576,8):
 center=528+int(round(4*math.sin((y-432)*.06)))
 q.rectangle((center-15,y,center+15,y+7),fill=(61,133,152,255) if (y//8)%2 else (67,139,153,255))
 for j in range(3):
  xx=center-13+((j*11+(y//8)*5)%26)
  yy=y+(j*3)%6
  q.rectangle((xx,yy,xx+5,yy+2),fill=(147,148,110,255) if j%2 else (131,157,142,255))
 # foam at shallow channel edges
 q.rectangle((center-17,y+1,center-16,y+4),fill=(184,211,196,255))
 q.rectangle((center+16,y+3,center+17,y+5),fill=(148,193,186,255))
# decorative river rocks at banks, not colliders.
for x,y in [(479,453),(575,478),(485,548),(567,559),(480,582),(573,445)]:
 q.polygon([(x,y+5),(x+3,y),(x+10,y+1),(x+14,y+7),(x+9,y+10),(x+2,y+9)],fill=(113,111,89,255))
 q.line([(x+2,y+4),(x+5,y+2),(x+10,y+3)],fill=(177,162,117,255),width=2)
assert set(water.getchannel("A").getdata()).issubset({0,255})
water_file=T/"river_patch_v8.png";water.save(water_file)
# Build a self-contained raised timber bridge across the source-backed water channel.
BRW,BRH=160,108
im=Image.new("RGBA",(BRW,BRH));draw=ImageDraw.Draw(im)
# Deep underside beams and supports are separate, so actors on level0 can be occluded.
draw.polygon([(2,57),(158,55),(157,77),(2,79)],fill=(55,40,28))
draw.polygon([(5,59),(157,57),(155,66),(5,68)],fill=(101,68,43))
for x in (6,149):
 draw.rectangle((x,74,x+8,106),fill=(67,50,37))
 draw.rectangle((x+2,75,x+5,105),fill=(146,104,62))
 for yy in (80,93):
  draw.rectangle((x-1,yy,x+9,yy+3),fill=(113,84,55))
# Deck slats from left bank through the water to right bank, not a flat single gradient.
draw.polygon([(0,46),(160,44),(160,62),(0,65)],fill=(141,99,58))
for x in range(0,BRW,9):
 draw.polygon([(x,45),(x+7,45),(x+6,62),(x,63)],fill=(157+(x//9)%3*8,113+(x//9)%2*8,69))
 draw.line([(x,45),(x,64)],fill=(66,49,31),width=2)
 draw.line([(x+2,48),(x+6,47)],fill=(194,155,93),width=1)
# Emphasize planking deck edge and rail with stylized knotted ropes.
draw.line([(0,65),(159,61)],fill=(50,36,24),width=4)
draw.line([(1,43),(159,41)],fill=(208,160,93),width=3)
# Regular posts and rope handrails in front/back of the corridor.
for x in range(9,159,23):
 yy=36-int(x/60)
 draw.rectangle((x,yy-18,x+5,yy+19),fill=(104,72,41))
 draw.rectangle((x+2,yy-17,x+3,yy+16),fill=(175,122,68))
 draw.rectangle((x-1,yy-18,x+6,yy-15),fill=(218,170,95))
for x in range(0,140,4):
 y=int(15+2*math.sin(x*math.pi/22))
 draw.rectangle((x,y,x+3,y+2),fill=(163,119,74))
 # lighter upper rope
 draw.point((x+1,y),fill=(220,173,103))
# Attach a decorative wooden sign at east abutment, not a collision stand-in.
draw.line([(148,19),(148,36)],fill=(115,81,51),width=3)
draw.rounded_rectangle((137,25,159,40),radius=2,fill=(100,65,37),outline=(206,158,87),width=2)
draw.line([(141,30),(153,30)],fill=(215,191,126),width=2)
draw.line([(143,34),(151,34)],fill=(170,198,150),width=1)
# Use actual source timber pixels as a non-overwriting bridge center texture accent.
timber=Image.open(C/"treehouse_grove_v7.png").convert("RGBA")
sample=timber.crop((124,112,147,125))
# Inherit recognizable source plank pattern only where the original sample is opaque.
tile=sample.resize((46,13),Image.Resampling.NEAREST)
im.alpha_composite(tile,(57,45))
assert set(im.getchannel("A").getdata()).issubset({0,255})
bridge_name="bridge_timber_upper_v8";bridgefile=C/(bridge_name+".png");im.save(bridgefile)
# Exact scene-space footprint: x448..607; sprite y419..526, foot+height=527.
scene=json.loads((R/"scene_manifest_v7_baseline.json").read_text(encoding="utf8"))
assert len(scene["instances"])==48
scene["instances"].append({
 "id":"ford_timber_bridge","role":"bridge_upper","asset_id":bridge_name,
 "source":"source/clean/"+bridge_name+".png","sha256":sha(bridgefile),
 "x":448,"y":419,"dimensions":[BRW,BRH],"draw_order":527,"z":527,
 "base_cut_y":78,"collision_local":[[3,87,15,107],[146,87,157,107]],
 "structure_class":"bridge_upper_over_shallow_ford",
 "height_level":1,"foot_anchor_world":[528,527],
 "construction_ledger":"input/V8_BRIDGE_AND_RIVER_LEDGER.json"
})
# This flower was growing in the river. Replant on the east grassy bank.
for obj in scene["ground_decor"]:
 if obj["id"]=="flower_f":obj["x"]=589;obj["y"]=448
scene["water_semantics"]={
 "source":"source/terrain/river_patch_v8.png",
 "sha256":sha(water_file),"full_canvas":[W,H],
 "water_deep_tiles":[[x,y] for y in range(14,18) for x in (15,17)],
 "lower_ford_tiles":[[16,y] for y in range(14,18)],
 "lower_ford_entry_north":[16,13],"lower_ford_exit_south":[16,18],
 "river_orientation":"north_south","deep_water_level0":"BLOCKED",
 "ford_level0":"NORTH_SOUTH_ONLY",
 "bridge_draw_before_level1_actor":True}
scene["height_layers"]["timber_bridge"]={
 "object_id":"ford_timber_bridge","level":2,
 "approach_west":[14,15],"approach_east":[18,15],
 "upper_landing_west":[15,15],"upper_landing_east":[17,15],
 "platform_walkable_tiles":[[15,15],[16,15],[17,15]],
 "actor_visual_elevation_px":30,"actor_z":820,
 "upper_footprint_v8":"horizontal_east_west", "underpass":"lower_ford_16_y14_17",
 "upper_overlay_mask":"BRIDGE_SELF_RENDER_BEHIND_ACTOR",
 "same_xy_independent_level_at":[16,15]}
scene["status"]="B1_V8_CROSSING_BRIDGE_SOURCE_LAYER_CANDIDATE_PRIVATE"
scene["v8_authoring"]={
 "parent":"B1_V7_LEVEL1_PLATFORM","scene_instance_count":49,
 "source_bridge_sha256":sha(bridgefile),"source_river_sha256":sha(water_file),
 "changed_from_v7":["add bridge instance","river terrain overlay","water collision tiles","replant flower_f"],
 "actual_bridge_ford_level_split_required":True,
 "sealed_fs_unchanged":True}
(R/"scene_manifest.json").write_text(json.dumps(scene,ensure_ascii=False,indent=2),encoding="utf8")
ledger={
 "bridge_source":"source/clean/"+bridge_name+".png","bridge_sha256":sha(bridgefile),
 "bridge_dimensions":[BRW,BRH],"bridge_origin":[448,419],
 "river_source":"source/terrain/river_patch_v8.png","river_sha256":sha(water_file),
 "derived_source_images":{
 "grass_tile":sha(T/"grass_tile.png"),"path_tile":sha(T/"path_tile.png"),
 "treehouse_plank":sha(C/"treehouse_grove_v7.png")},
 "authored_pixel_geometry":["deterministic water bank/ford/wave palette","wooden bridge, rope railing, pillar, knots","wood plank source crop"],
 "rights":"PRIVATE_CANDIDATES_DO_NOT_PUBLIC_RELEASE",
 "overlay_sequence":"grass/path->water->ground_flora->PAR","water_collision_authority":"scene.water_semantics"
}
(R/"input"/"V8_BRIDGE_AND_RIVER_LEDGER.json").write_text(json.dumps(ledger,ensure_ascii=False,indent=2),encoding="utf8")
p=R/"scripts"/"compile_scene_v8.py"
assert p.is_file()
proc=subprocess.run([sys.executable,str(p)],cwd=R,capture_output=True,text=True,timeout=60)
assert proc.returncode==0,(proc.stdout,proc.stderr)
copy2(R/"build"/"FS_ELF_RICH_Master.png",R/"outputs"/"VISUAL_MASTER_V4.png")
(R/"logs"/"V8_SOURCE_BUILD.json").write_text(json.dumps({
 "status":"V8_SOURCE_RECOMPILED",
 "bridge_sha256":sha(R/"source"/"clean"/"bridge_timber_upper_v8.png"),
 "river_sha256":sha(R/"source"/"terrain"/"river_patch_v8.png"),
 "instances":49,"semantic_ford":"north_south_level0","bridge":"east_west_level2",
 "formal_fs_sealed":"UNTOUCHED"},ensure_ascii=False,indent=2),encoding="utf8")
print("V8_SOURCE_DETERMINISTIC_REBUILT",sha(R/"scene_manifest.json"),flush=True)
