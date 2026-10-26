from pathlib import Path
from PIL import Image
import numpy as np,json,zipfile,hashlib,shutil,subprocess
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
S=R/"outputs/F2_R3_G4_INPUT_20261026/REFERENCE_NATIVE_1440x1088.png"
O=R/"outputs/F2_G5R2_CONTIGUOUS_NATIVE_GROUND_20261026"
Z=R/"deliveries/F2_G5R2_NATIVE_CONTIGUOUS_GROUND_20261026.zip"
assert S.is_file() and not O.exists() and not Z.exists()
O.mkdir(parents=True);(O/"tiles32").mkdir()
im=Image.open(S).convert("RGB")
assert im.size==(1440,1088)
x,y,w,h=610,578,320,256
ground=im.crop((x,y,x+w,y+h))
ground.save(O/"GROUND_SOURCE_320x256.png")
records=[];compose=Image.new("RGB",(w,h))
for ty in range(8):
 for tx in range(10):
  tile=ground.crop((tx*32,ty*32,tx*32+32,ty*32+32))
  p=O/"tiles32"/(f"R2_{ty:02d}_{tx:02d}.png");tile.save(p)
  compose.paste(tile,(tx*32,ty*32))
  records.append({"id":f"{ty:02d}_{tx:02d}","file":p.relative_to(O).as_posix(),
                  "scene_position":[tx*32,ty*32],"original_position":[x+tx*32,y+ty*32]})
compose.save(O/"RECOMPOSED_ORIGINAL_NO_INTERPOLATION.png")
arr=np.asarray(ground)
assert np.array_equal(arr,np.asarray(compose))
black=int((arr.max(axis=2)==0).sum())
assert black<41
metadata={"stage":"FS_F2_G5R2_AUTHENTIC_GROUND_EXPANSION","native_dimensions":[w,h],
"original_reference":str(S),"source_rect":[x,y,w,h],"tile":[32,32],
"number_of_native_tiles":80,"ground_default_walkable":True,"blocked":[],"repeated_patch_synthesis":False,
"used_original_pixels_at_1x":True,"rgb_recomposition_difference":0,
"original_isolated_black_pixels":black,"dark_pixel_rule":"<0.05% source shadows accepted; NOT proof no PAR intrusion",
"source_first":"fixed-coordinate native source tiles; NOT randomly repeatable seamless tiles",
"human_style_gate":"PENDING","full_map_ground":"ART_FAIL_DONOR_SEAMS",
"native_vx_test":"NOT_RUN_G5R2","tiles":records}
(O/"SCENE_MANIFEST.json").write_text(json.dumps(metadata,ensure_ascii=False,indent=2),encoding="utf-8")
(O/"README.md").write_text("""# F2 G5R2 native Ground source 320x256, 10x8 tiles
A real, uninterrupted 320x256 terrain source directly from approved elf-village reference at source x610,y578. +25% real area versus prior 256x256 source benchmark, 80 adjacent native 32x32 tiles. No resampling, quilt, independent random patch assignment or image generation. Each tile has an ownership coordinate in the original native crop. Reassembling yields RGB drift zero.
IMPORTANT: this is only a fixed-location native 320x256 source bank, not an infinitely repeatable tileset and NOT an approved 1440x1088 Ground! Close-up still contains grass flowers; visually review any edge that might include foreground floral props. Full original full-scene G4 underpaint remains ART FAIL. Not native VX compiled. G4 collision already native verified separately; F1R1 sealed unchanged.
Next: independently author more complete native same-style ground with known source ownership and no random cloning. Do not promote a crop to full functional scene.
""",encoding="utf-8")
(O/"CURRENT_HANDOFF.md").write_text("""# F2 G5R2 CURRENT_HANDOFF
Source-first direct 320x256 native crop, 80 coordinate-owned 32px tiles, reconstruction zero RGB drift, source pixel art at original resolution; all ground default WALK. Previous 256x256 G5 crop only 64 tiles. This is 25% larger, NOT repeatable nor complete ground; original G4 full-scene donor patch ground remains ART FAIL. Human art style PENDING. F1R1 approved sealed unaffected.
PMD 0001 P3_G3R1 separate: lava-cracked dark gray rock, warm orange body, full 34 action sheets, 1123 original frame cells, XML/Offsets/Shadow intact; true native Godot XML bridge; user visual PENDING. Future 0002->0003 evolve gradually cracked basalt to exposed lava core.
""",encoding="utf-8")
(O/"RULES_DELTA.md").write_text("""# Strict source-first
Never use clone-donor patch repair as production Ground. A native contiguous original crop is source for fixed coordinates ONLY; no image smoothing, no projection stretch, no repeating arbitrary tiles. Road/grass/flower are walkable. Native collision inherited G4 engineering TECH PASS applies only to that version, not automatically this crop. Source fidelity ≠ art acceptance.
""",encoding="utf-8")
(O/"VERIFY.py").write_text('''from pathlib import Path
import numpy as np,json
from PIL import Image
p=Path(__file__).parent;m=json.loads((p/"SCENE_MANIFEST.json").read_text(encoding="utf-8"))
a=np.asarray(Image.open(p/"GROUND_SOURCE_320x256.png").convert("RGB"))
b=np.zeros_like(a)
for t in m["tiles"]:
 x,y=t["scene_position"];b[y:y+32,x:x+32]=np.asarray(Image.open(p/t["file"]).convert("RGB"))
assert len(m["tiles"])==80 and np.array_equal(a,b)
assert m["ground_default_walkable"] and not m["blocked"]
assert m["full_map_ground"]=="ART_FAIL_DONOR_SEAMS"
print("F2 G5R2 native SOURCE PASS 80 actual tiles, zero source pixel drift; full map ART FAIL")
''',encoding="utf-8")
(O/"RUN_QA.cmd").write_text('@echo off\r\npy -3 "%~dp0VERIFY.py"\r\npause\r\n',encoding="utf-8")
test=subprocess.run([str(R/".venv/Scripts/python.exe"),str(O/"VERIFY.py")],capture_output=True,text=True,errors="replace")
(O/"QA_LOG.txt").write_text(test.stdout+test.stderr,encoding="utf-8")
assert test.returncode==0
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
with zipfile.ZipFile(Z,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for file in O.rglob("*"):
  if file.is_file():z.write(file,file.relative_to(O).as_posix())
with zipfile.ZipFile(Z) as z:assert z.testzip() is None
u=next(p for p in Path("G:/").iterdir() if p.is_dir() and not p.name.startswith("."))
folder=u/"AI_ART_TOOLCHAIN_PILOT_20261025/F2_G5R2_NATIVE_SOURCE_20261026"
folder.mkdir(exist_ok=True)
shutil.copy2(Z,folder/Z.name)
for n in ("CURRENT_HANDOFF.md","GROUND_SOURCE_320x256.png","SCENE_MANIFEST.json","QA_LOG.txt","RULES_DELTA.md"):
 shutil.copy2(O/n,folder/n)
assert sha(Z)==sha(folder/Z.name)
print(json.dumps({"zip":Z.name,"size":Z.stat().st_size,"sha256":sha(Z),"tiles":80,"black_source_px":black},flush=True))
