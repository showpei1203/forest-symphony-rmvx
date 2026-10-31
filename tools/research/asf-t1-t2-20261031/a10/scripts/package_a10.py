from pathlib import Path
import json,hashlib,zipfile
from PIL import Image
import numpy as np
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A10_ONE_MASTER_RIG")
gpu=json.loads((root/"A10_GODOT_PIXEL_PARITY.json").read_text(encoding="utf8"))
assert gpu["status"]=="TECH_PASS" and gpu["samples"]==22 and gpu["exact_pixels"]==22
fixed=json.loads((root/"A10_STRICT_REPAIR_QA.json").read_text(encoding="utf8"))
assert sum(x["before"]-x["after"] for x in fixed)==2
report={"stage":"A10_TRUE_AI_MASTER_TO_RIG_MOTION_TO_ASF_TO_GODOT",
 "source_masters":{"T1":"Original independently generated AI still; keyed/32-colour/64x80",
 "T2":"Original independently generated AI still; keyed/32-colour/64x64"},
 "motion_method":"DETERMINISTIC_PIXEL_RIG_FROM_ONE_MASTER_NOT_I2V",
 "input_stills":2,"source_motion_frames":84,"published_motion_frames":82,"ASF_clips":11,
 "ASF_strict_initial":"FAIL due to T1 attack near-duplicate [1,2] and T2 faint [6,7]",
 "ASF_strict_after_repair":"PASS 0 WARNINGS; combined near-duplicates preserve clip total ticks",
 "ASF_engine_outputs":["Aseprite JSON","Godot SpriteFrames","Godot Sprite3D"],
 "real_GPU_engine":"Godot 4.7.2 AMD Radeon RX 6700 XT OpenGL",
 "real_GPU_captures":2,"ROI_pixel_exact":22,"ROI_pixel_total":22,
 "AI_video_route":"NOT CONFIGURED_NOT_TESTED",
 "model_generated_attack_pose":"A separate prompt-only test image exists in conversation; not used in production sprite frames, not identity-locked",
 "formal_visual_gate":"FAIL/PENDING: T1 attack is not clearly a sword swing; leg animation is subtle; T2 faint physically rotates but may not meet intended style",
 "official_FS_asset_seal":False,
 "sealed_game_sources_touched":False}
(root/"A10_FORMAL_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
handoff="""# ASF A10 REAL ONE-MASTER RIG experiment | 2026-10-31
Corrected objective: AI generates one clean image per actor/monster; tool creates movements and spritesheets; game imports follow visual approval.
NEW G1 TECH PASS: independent AI-only single T1 green-hooded forest scout and T2 moss-antler forest creature; not cut from fake infographic. Both magenta keyed into RGBA, 32-colour original faces and gear remain.
NEW ALTERNATIVE ROUTE A10-RIG (not I2V): deterministic nearest-neighbour skeletal pixel mesh sampling from ONE master. T1 6 actions/46 trial frames; T2 5 actions/38 trial frames; all 84 RGBA frames no canvas-edge contacts and preserve original source palette.
Native Windows ASF strict first FAIL (T1 attack near duplicate, T2 faint last duplicate); corrected each clip manifest by dropping redundant playback entry and adding its ticks to the previous entry, preserving duration. ASF strict second PASS 0 warning. Build source=84, actual clips=11 / 82 frame references (T1 45, T2 37). Actual ASF export_engine --target all: Aseprite JSON, Godot SpriteFrames and Sprite3D 1 atlas per case.
Native Godot 4.7.2/OpenGL RX6700XT loaded ASF scenes, ran 11 clips and captured 2 real GPU images. 22/22 frame crops pixel-exact matched original source RGBA over same background. One initially apparent mismatch was QA bug comparing Godot PLAYBACK ordinal to original Frame Number after merged pose. Fixed by resolving manifest clip.frames ordinal -> frames[].file. GPU itself was correct.
REMAINING: Full image-to-video has NOT RUN, because video route not configured; rig is programmatic movement of master pixels, not model-synthesized new motion. T1 attack is NOT clear sword swing, run/walk too subtle. T2 faint more legible but art quality G7 pending. Only engine Technical PASS, not FS formal visual PASS.
SOURCE FROZEN: main FS K4/N5/R17/PMD/LPC not edited; all tests in separate E:\\GameAssetToolLab_20261023\\ASF_Test_20261031\\A10_ONE_MASTER_RIG.
NEXT: isolate/rig body arm/leg motion more precisely or use real I2V on RX6700XT via comfyui-rinsei (community reported, not installed/tested). Human approve master and action quality before formal import. No artificial claims about I2V or sprite-set AI capabilities.
"""
(root/"CURRENT_HANDOFF_A10.md").write_text(handoff,encoding="utf8")
files=[]
for f in root.rglob("*"):
 if not f.is_file():continue
 if ".godot" in f.parts:continue
 if f.suffix.lower()==".zip":continue
 files.append(f)
archive=root/"A10_WINDOWS_TRUE_MASTER_ASF_GODOT_PRIVATE_20261031.zip"
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED,compresslevel=7) as z:
 for f in files:z.write(f,f.relative_to(root).as_posix())
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 inv={"archive":str(archive),"count":len(files),"bytes":archive.stat().st_size,
 "sha256":hashlib.sha256(archive.read_bytes()).hexdigest(),"CRC":"PASS","storage":"LOCAL_PRIVATE_WINDOWS_ONLY"}
(root/"A10_WINDOWS_ZIP_QA.json").write_text(json.dumps(inv,indent=2))
print(json.dumps({"QA":report,"ZIP":inv},ensure_ascii=False,indent=2))