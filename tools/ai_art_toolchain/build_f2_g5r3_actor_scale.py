from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
from rubymarshal.reader import load
import numpy as np, json, shutil,hashlib,zipfile,subprocess,sys
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
PREV=R/"outputs/F2_G5R2_CONTIGUOUS_NATIVE_GROUND_20261026"
G4=R/"outputs/F2_R3_G4_VX_REAL_GAME_20261026"
SOURCE=Path(r"C:\Program Files (x86)\Enterbrain\RPGVX\Graphics\Characters\Actor1.png")
REF=R/"outputs/F2_R3_G4_INPUT_20261026/REFERENCE_NATIVE_1440x1088.png"
D=R/"deliveries/F2_G5R3_ACTOR_SCALE_AND_FLORA_AUDIT_20261026"
Z=R/"deliveries/F2_G5R3_ACTOR_SCALE_AND_FLORA_AUDIT_20261026.zip"
assert not D.exists() and not Z.exists()
D.mkdir(parents=True)
im=Image.open(PREV/"GROUND_SOURCE_320x256.png").convert("RGB")
full=Image.open(REF).convert("RGB")
assert im.size==(320,256) and full.size==(1440,1088)
m=json.loads((PREV/"SCENE_MANIFEST.json").read_text(encoding="utf-8"))
assert len(m["tiles"])==80 and m["number_of_native_tiles"]==80
actor=load((G4/"Data/Actors.rvdata").open("rb"))[1]
assert actor.attributes["@character_name"]==b"Actor1" and actor.attributes["@character_index"]==0
s=Image.open(SOURCE).convert("RGBA")
assert s.size==(384,256)
# RGSS2 format Actor1 is 8 separate character sheets in a 4x2 grid, each 3 cols * 4 dirs.
cell_w=s.width//12;cell_h=s.height//8
actorimg=s.crop((cell_w,0,cell_w*2,cell_h))
actor_bounds=actorimg.getchannel("A").getbbox()
assert actor_bounds and cell_w==cell_h==32
vis=[actor_bounds[2]-actor_bounds[0],actor_bounds[3]-actor_bounds[1]]
assert vis==[28,32],vis
actorimg.save(D/"VX_ACTOR1_FACING_DOWN_CANDIDATE_FRAME.png")
# First independently verify 80 authentic tiles: no tech drift from G5R2.
tiled=Image.new("RGB",im.size)
for tile in m["tiles"]:
 x,y=tile["scene_position"]
 source_tile=Image.open(PREV/tile["file"]).convert("RGB")
 tiled.paste(source_tile,(x,y))
assert np.array_equal(np.asarray(im),np.asarray(tiled))
# Tile classification is a manual, reproducible SCREENING based on user-observed flower area.
# No computer vision pretense: 9 hard exclude tiles, surrounding source GROUND remains review-only.
reject={(col,row) for col in range(7,10) for row in range(5,8)}
tiles=[]
for row in range(8):
 for col in range(10):
  hit=(col,row) in reject
  tiles.append({"tile":[col,row],"status":"NOT_GROUND_FLORA_REVIEW" if hit else "SOURCE_CONTINUITY_ONLY_ART_PENDING",
                "reason":"Truncated tall lower-right flower mass occupies this source envelope, with background mixed" if hit else "No actor-relative semantic human check yet",
                "bbox":[col*32,row*32,(col+1)*32,(row+1)*32],
                "original_asset":f"tiles32/R2_{row:02d}_{col:02d}.png"})
assert sum(t["status"]=="NOT_GROUND_FLORA_REVIEW" for t in tiles)==9
# 1x player display uses *actual* 32x32 source cell, feet at bottom of frame.
comparison=im.convert("RGBA")
def put_actor(canvas,foot_x,foot_y):
 canvas.alpha_composite(actorimg,(foot_x-cell_w//2,foot_y-cell_h))
put_actor(comparison,226,225)
put_actor(comparison,288,235)
comparison.save(D/"G5R3_ACTUAL_VX_ACTOR_1X.png")
marked=comparison.copy()
draw=ImageDraw.Draw(marked)
draw.rectangle((224,160,319,255),outline=(235,70,65,255),width=2)
draw.rectangle((0,0,290,29),fill=(23,33,31,220))
draw.text((4,3),"Actor 28x32 visible; red = flora REVIEW",fill=(255,255,233,255))
marked.save(D/"G5R3_PLAYER_SCALE_WITH_FLORA_REVIEW.png")
diagnostic=im.convert("RGBA")
draw=ImageDraw.Draw(diagnostic)
for t in tiles:
 col,row=t["tile"]
 x,y=col*32,row*32
 draw.rectangle((x,y,x+31,y+31),outline=(255,98,80,190) if (col,row) in reject else (240,239,212,85),width=1)
 if (col,row) in reject:
  draw.text((x+9,y+7),"!",fill=(255,62,44,255),stroke_width=1,stroke_fill=(10,10,11,255))
diagnostic.save(D/"G5R3_FULL_80_TILE_SOURCE_AUDIT.png")
roi=Image.new("L",im.size,0)
ImageDraw.Draw(roi).rectangle((224,160,319,255),fill=255)
roi.save(D/"G5R3_NOT_FINAL_PAR_MASK_REVIEW_ENVELOPE.png")
# Source context uses truly wider full ref, not the damaged sample's cropped flower edge.
original_x,original_y=610,578
full_crop=full.crop((original_x+180,original_y+120,original_x+475,original_y+390))
full_crop.save(D/"G5R3_UNCUT_WIDER_FLORA_SOURCE_CONTEXT.png")
# Separate, genuinely foreground-free pre-made slice is not inferred: no inpainting or pseudo-PAR PNG.
# Mark exact boundaries so future isolate tool can use source beyond current crop.
data={"id":"F2_G5R3_ACTOR_SCALE_AND_FLORA_REVIEW",
"runtime_character":"Actor1 character_index0 from actual F2G4 RGSS2 Data/Actors.rvdata",
"asset_source":str(SOURCE),"actor_RTP_source_sha256":hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
"actor_cell_size":[cell_w,cell_h],"actor_visible_aabb":[*actor_bounds],
"actor_visible_size":vis,"foot_anchor_in_frame":[16,32],
"ground_source_size":list(im.size),"tile_size":[32,32],"tile_count":len(tiles),
"source_contiguity_pixels_different":0,
"flagged_flora_area":[224,160,320,256],"flagged_flora_tile_count":9,
"flagged_is_screening_roi_not_pixel_matted_object":True,
"flagged_area_includes_soil_and_grass":True,
"not_final_PAR_flora":True,
"flower_truncated_by_current_ground_crop":True,
"wider_original_context_extracted":True,
"plant_exact_sprite_size":"NOT_MEASURABLE_FROM_CROPPED_GROUND; requires source semantic isolation",
"status_actor_reference":"PASS_MEASURED",
"status_ground_semantics":"FAIL_PENDING_OBJECT_SEPARATION",
"status_full_ground":"ART_FAIL_DONOR_PATCHES",
"status_new_visual":"USER_REVIEW_PENDING",
"pmD0001_style":"USER_APPROVED_DIRECTION_UNCHANGED",
"records":tiles}
(D/"F2_G5R3_ACTOR_SCALE_TILE_MANIFEST.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf-8")
(D/"CURRENT_HANDOFF.md").write_text("""# F2 G5R3 actor-scale flora audit — 2026-10-26
Real F2G4 RGSS2 actor is Actor1 index0, inspected directly from Data/Actors.rvdata. RPGVX default Actor1 384x256 source, frame 32x32, nontransparent actor body 28x32 and bottom-foot anchor(16,32). New native 1:1 screenshot OVERLAY verifies actual body looks tiny beside right/lower source flowers. Original 320x256 G5R2 contiguous Ground reassembles exactly from all 80 source tiles, zero RGB drift. BUT lower-right tall flowers are too large/3D for Ground and are cropped at x=320,y=256. 3x3 source tile region x224..319,y160..255 flagged as NOT_GROUND_FLORA_REVIEW (9 tile flags); other 71 source tiles have only SOURCE CONTINUITY PASS, semantic art PENDING.
A full-width reference context crop beyond the damaged edges is included so next stage can segment ENTIRE flower owner. Warning: the 96x96 ROI is NOT exact plant size, NOT a real isolated sprite/mask and cannot be treated as a PAR asset. No source-backed clean Ground underpaint or full map visual pass was fabricated. Next F2 G5R4: use full original reference, segment complete flowering cluster with alpha/foot anchors and noncropped mask. Only then replace from actual coherent Ground source, not inpainting/clone donor squares. All existing accepted F1R1 immutable.
User approved P3_G3R1 orange/gray volcano frog STYLE DIRECTION; preserve original sprites unchanged this round. 0002/0003 later family progression, official PMD/VX runtime pending.
""",encoding="utf-8")
(D/"RULES_DELTA.md").write_text("""# Actor-relative Ground gate enforced
Ground source continuity (pixel parity of tile recompose) must not promote art. Calibrate against source-backed actual RPG Maker VX player sprite, visible alpha 28x32 for Actor1 index0, actual frame32x32. Large flowers that look like 3D props or approach actor visual size cannot stay baked into Ground: classify as independently owned PAR_FLORA with translucent/masked pixels, depth/foot placement; if soft, allow passability; hard trunk/rock contacts may block. Any source ROI touching crop edges must consult original uncropped reference. Source ROI is NOT alpha-segmented ownership mask.
Flag specific 9 suspect flower-zone tiles and audit the rest 71 before final. Do not create fake underpaint or clone donor squares. F1R1 sealed baseline unchanged. P3G3R1 orange-gray volcanic juvenile design direction USER APPROVED but original source XML/import remains a separate technical gate.
""",encoding="utf-8")
qa="""from pathlib import Path
from PIL import Image
import json,numpy as np
p=Path(__file__).resolve().parent
r=json.loads((p/"F2_G5R3_ACTOR_SCALE_TILE_MANIFEST.json").read_text(encoding="utf-8"))
assert r["runtime_character"].startswith("Actor1")
assert r["actor_visible_size"]==[28,32]
assert r["tile_count"]==80
assert r["flagged_flora_tile_count"]==9
assert r["source_contiguity_pixels_different"]==0
assert r["flower_truncated_by_current_ground_crop"]
assert r["not_final_PAR_flora"]
assert r["status_ground_semantics"]=="FAIL_PENDING_OBJECT_SEPARATION"
assert r["status_full_ground"]=="ART_FAIL_DONOR_PATCHES"
a=np.asarray(Image.open(p/"G5R3_ACTUAL_VX_ACTOR_1X.png").convert("RGBA"))
assert a.shape==(256,320,4)
assert Image.open(p/"G5R3_UNCUT_WIDER_FLORA_SOURCE_CONTEXT.png").size==(295,270)
assert len(r["records"])==80
assert sum(t["status"]=="NOT_GROUND_FLORA_REVIEW" for t in r["records"])==9
print("F2_G5R3_ACTOR_SCALE_AUDIT_PASS actor28x32 source80cells flagged9 REAL_FLORA_PAR_PENDING; Ground ART FAIL")
"""
(D/"VERIFY_G5R3_ACTOR.py").write_text(qa,encoding="utf-8")
(D/"RUN_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY_G5R3_ACTOR.py"\r\npause\r\n',encoding="ascii")
run=subprocess.run([str(R/".venv/Scripts/python.exe"),str(D/"VERIFY_G5R3_ACTOR.py")],capture_output=True,text=True,errors="replace",timeout=30)
(D/"G5R3_QA.log").write_text(run.stdout+run.stderr,encoding="utf-8")
assert run.returncode==0,(run.stdout,run.stderr)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
checks=[{"filename":f.name,"sha256":sha(f),"bytes":f.stat().st_size} for f in D.glob("*") if f.is_file() and f.name!="CHECKSUMS.json"]
(D/"CHECKSUMS.json").write_text(json.dumps(checks,indent=2),encoding="utf-8")
with zipfile.ZipFile(Z,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in D.iterdir():
  if f.is_file():z.write(f,f.name)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None
C=R/"COLD_F2_G5R3_ACTOR_SCALE_20261026"
assert not C.exists()
with zipfile.ZipFile(Z) as z:z.extractall(C)
for x in checks:assert sha(C/x["filename"])==x["sha256"]
test=subprocess.run([str(R/".venv/Scripts/python.exe"),str(C/"VERIFY_G5R3_ACTOR.py")],capture_output=True,text=True,errors="replace",timeout=30)
assert test.returncode==0,(test.stdout,test.stderr)
result={"zip":str(Z),"size":Z.stat().st_size,"sha256":sha(Z),"CRC":True,"cold_SHA":True,
"real_actor":"Actor1 index0 28x32 visible","tile_technical":80,"flagged_flora_tiles":9,
"ground_ART":"FAIL","PAR_flora_alpha":"NOT_YET_SEGMENTED","human_visual":"PENDING"}
(R/"reports/F2_G5R3_ACTOR_SCALE_RELEASE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
print("DELIVERED",json.dumps(result,ensure_ascii=False),flush=True)
