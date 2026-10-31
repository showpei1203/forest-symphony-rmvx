from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from PIL import Image
import hashlib,json,sys
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A11_LAYERED_RIG")
old=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A10_ONE_MASTER_RIG")
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
qa=json.loads((root/"A11_GODOT_PIXEL_PARITY.json").read_text(encoding="utf8"))
assert qa["samples"]==22 and qa["exact_pixels"]==22 and qa["status"]=="TECH_PASS"
clips={}
for case in ("T1_forest_scout","T2_moss_antler"):
 m=json.loads((root/case/"clips.json").read_text(encoding="utf8"))
 ep=json.loads((root/case/"engine_all"/"engine-export.json").read_text(encoding="utf8"))
 frames=list((root/case/"frames").glob("*.png"))
 assert len(m["clips"])==(6 if case.startswith("T1") else 5)
 assert len(m["clips"]["attack"]["frames"])==8
 assert len(frames)==(46 if case.startswith("T1") else 38)
 assert all(Image.open(f).getbbox() is not None for f in frames)
 clips[case]={"clips":len(m["clips"]),"source_frames":len(frames),"attack_playback_frames":8,"exported_frames":ep.get("frames"),"atlas_pages":ep.get("pages"),"strict_warnings":0,
 "original_master_sha256":sha(old/case/"master.png"),"a10_original_master_untouched":True}
report={"test":"A11 selective upgrade of 2 attack animations, 9 remaining action clips unchanged from A10",
 "status":"ASF_GODOT_TECH_PASS_ART_PENDING_I2V_NOT_RUN","source_lineage":{"T1":"One A10 actor master body; extra independent AI-generated sword accessory from earlier attack reference",
 "T2":"One A10 moss-antler creature master only; coherent full-body lunge/tilt; segmented head test discarded due floating fragments"},
 "rig":{"T1":"manual right arm alpha mask, shoulder pivot rotation, separate sword around inferred wrist; not model-synthesized pose",
 "T2":"rigid coherent lunge, no independent antlers to avoid detached source-pixel fragments"},
 "cases":clips,"native_Godot":{"engine":"4.7.2 OpenGL RX6700XT","clips":11,"captures":2,"matched_source_ROIs":22,"exact_RGB_pairs":22},
 "negative":{"test":"delete original T1 attack_03.png then --strict","exit_code":1,"published_directory":False,"pass":True},
 "constraints":{"human_art_gate_F":"PENDING","Full_I2V_from_master":"NOT_RUN","VX_new_assets":"NOT_RUN","sealed_FS_R17_LPC_PMD_unchanged":True},
 "known_visual_faults":["T1 arm/hand remains stiff; drawn scabbard is still visible while sword equipped in hand","T2 is coherent charge but lacks articulated paw cycle"],
 "qa_categories":["A11_T2_HEAD_ROTATION_FLOATING_PIXELS_FAIL_DISCARDED","A11_T1_SWORD_INDEPENDENT_ACCESSORY_REQUIRED",
 "A11_NO_EXACT_MATCH_OF_BATTLE_SCENE_YET"]}
(root/"A11_FORMAL_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
handoff="""# FS / ASF A11 Hand-off, 2026-10-31
Goal: GPT AI single Master -> acceptable animation -> ASF sprite sheet, format/Godot, then VX. A10 completed format but T1 attacks not visible. A11 revised 2 actions only; all original sealed work untouched.
A11 T1: true A10 master for body, independently sourced AI attack-pose sword accessory (not 'one source only'), hand/arm segmented + weapon pivot moved. 8 attack frames. T2: true A10 single moss-antler master, head-segmentation test FAIL for detached horn-leaves, revised attack uses coherent full-body charge, 8 frames, first and last same resting pose. T1 visual sword legible but hands stiff; T2 no dismemberment but still not a quadruped real attack. G7 not PASS.
Windows A10 original isolated master PNG SHA recorded in A11_FORMAL_QA.json; A10 original scripts/framing untouched. A11 selective copies A10 source frames and replaces only attack_00..07.
Real ASF build_animation_clips.py --strict PASS T1 6 clips/46 source frames warning0, T2 5 clips/38 source frames warning0. ASF export_engine.py --target all: Aseprite JSON + Godot SpriteFrames + Sprite3D, T1 46 exported frames, T2 37 exported frames (existing A10 faint dedup stays).
Real Godot4.7.2 RX6700XT OpenGL loads ASF .tscn, 11 actions × 2 samples -> 22/22 0 RGB delta vs exact referenced source RGBA pixels. Negative missing T1 attack_03.png strict exit1, zero published output.
MAIN LIMITATIONS: no actual I2V route on PC, no VX runtime test of this new art, Gate F human visual FAIL/PENDING. Do not claim formal scene quality/SEALED.
A11 master rig local script and sword source remain private/art and are in conversation ZIP; GitHub only reproduction code, QA text, hashes, no images with rights uncertainty. Cloud binary full Windows zip not uploaded.
NEXT A12: improve hand-specific actor attack/sheathed-vs-drawn sword, quadruped leg step, gated art; separately evaluate installing ComfyUI ROCm for RX6700XT without destabilizing system, no automatic large download.
"""
(root/"CURRENT_HANDOFF_A11.md").write_text(handoff,encoding="utf8")
files=[]
for case in ("T1_forest_scout","T2_moss_antler"):
 for f in (root/case).rglob("*"):
  if f.is_file() and ".godot" not in f.parts and f.suffix.lower() not in (".zip",):
   files.append((f,f.relative_to(root).as_posix()))
for n in ("A11_PREBUILD_QA.json","A11_GODOT_PIXEL_PARITY.json","A11_NATIVE_GPU_QA.json","A11_NATIVE_GPU_A.png","A11_NATIVE_GPU_B.png","A11_FORMAL_QA.json","CURRENT_HANDOFF_A11.md","A11_TRANSFER.json","build_inputs.py","verify_a11_gpu.py","capture_a11.gd","project.godot"):
 files.append((root/n,n))
archive=root/"A11_WINDOWS_COMPLETE_PRIVATE_20261031.zip"
with ZipFile(archive,"w",ZIP_DEFLATED,compresslevel=8) as z:
 for p,rel in files:
  assert p.exists(),p
  z.write(p,rel)
with ZipFile(archive) as z:
 assert z.testzip() is None
inventory={"files":len(z.namelist()),"bytes":archive.stat().st_size,"sha256":sha(archive),"crc":"PASS","location":"Windows private, not uploaded to cloud"}
(root/"A11_PRIVATE_ARCHIVE_INVENTORY.json").write_text(json.dumps(inventory,indent=2),encoding="utf8")
print(json.dumps({"qa":report["status"],"cases":clips,"archive":inventory},indent=2))