from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from PIL import Image
import numpy as np,json,hashlib
lab=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
out=lab/"A15_ART_REPAIR";final=out/"FINAL_CANDIDATE"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
prev=lab/"A14_OCCLUSION_RIG"
pre=json.loads((final/"A15_FINAL_VISUAL_SOURCE_QA.json").read_text(encoding="utf8"))
master=json.loads((out/"A15_R1_SOURCE_ART_QA.json").read_text(encoding="utf8"))
godot=json.loads((final/"A15_FINAL_GODOT_PIXEL_PARITY.json").read_text(encoding="utf8"))
assert godot["samples"]==22 and godot["exact_pixels"]==22 and godot["status"]=="TECH_PASS"
assert len(master["T1"]["removal_candidates"])==24
q={"status":"A15_REAL_PIXEL_ART_REPAIR_TECH_PASS_ART_REVIEW_PENDING",
 "date":"2026-10-31",
 "lineage":{"T1":"A10 single forest scout Master plus procedural sword already introduced A13; no generative video",
            "T2":"A10 single moss-antler Master; source-pixel leg masks; limited dust effects on collision frames"},
 "changes":{"T1":{"exact_source_hilt_pixels_replaced":24,"frames_modified":pre["T1_forest_scout"]["changed_attack_frames"],
   "removed_effect":"Broad cyan sweep across actor face rejected; final has no sweep arc"},
           "T2":{"new_leg_mask":"organic source-color filtered lower leg regions excluding light belly duplicate",
    "frame_changes":pre["T2_moss_antler"]["changed_attack_frames"],
    "head_antlers_matched_source_pixels":sum(x["source_head_pixels"] for x in pre["T2_moss_antler"]["head_antler_source_match"]),
    "head_antlers_mismatches":sum(x["mismatches"] for x in pre["T2_moss_antler"]["head_antler_source_match"]),
    "contact_dust_frames":[4,5]}},
 "actual_tools":{"ASF_strict":{"T1":{"clips":6,"input_frames":46,"warnings":0},"T2":{"clips":5,"input_frames":38,"export_frames":37,"warnings":0},
  "all_targets":["aseprite-json","godot-spriteframes","godot-sprite3d"]},
 "Godot":{"version":"4.7.2 stable","renderer":"RX 6700 XT OpenGL3.3","clips_played":11,"captures":2,"matched_source_ROIs":22,"exact_rgb":22}},
 "scope":{"G1_master":"A10 pass prior","G2_source_identity":"T2 head/antlers pixel-exact; T1 original actor source preserved except targeted hilt pixels",
 "G3_procedural_keyposes":"tech candidates","G3_image_to_video":"NOT_RUN",
 "G4_transparency":"PASS","G5_ASF":"PASS","G6_Godot":"PASS",
 "G7_art":"PARTIAL_IMPROVEMENT_NOT_FORMALLY_ACCEPTED","G8_native_VX_new_art":"NOT_RUN","FS_SEALED_unchanged":True},
 "known_faults":["T1 shoulder wrist motion still stiff; hand-on-hilt shape requires art retouch",
 "T2 middle frames still limited authentic four-leg biomechanical weight transfer",
 "Tiny impact dust embellishment does not prove correct attack anatomy"],
 "rejections":["ImageGen unexpectedly rendered comprehensive infographic, not clean single sprite keyframe; not used",
 "A15 R2 long slash arc crossed near face; rejected",
 "Unmatched source-pixel masks are fail-closed and cannot be force-painted"]}
safety={
 "K4":(lab.parent/"FS_FORMAL_RUNTIME_B0_ISOLATED_20261024"/"clone_project"/"K4_BASELINE"/"Data"/"Scripts.rvdata",
        "5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"),
 "N5":(lab.parent/"FS_FORMAL_RUNTIME_B0_ISOLATED_20261024"/"clone_project"/"N5_RUNTIME_CLONE"/"Data"/"Scripts.rvdata",
        "3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9")}
for key,(path,h) in safety.items():
 assert path.exists() and sha(path)==h,key
q["sealed_scripts_hashes"]={key:h for key,(_,h) in safety.items()}
for case in ("T1_forest_scout","T2_moss_antler"):
 p=final/case/"frames"
 src=prev/case/"frames"
 for f in p.glob("*.png"):
  if not f.name.startswith("attack_"):assert f.read_bytes()==(src/f.name).read_bytes()
 assert sum(1 for f in p.glob("*.png"))==(46 if case.startswith("T1") else 38)
 # Natural timing from original manifest
 man=json.loads((final/case/"clips.json").read_text(encoding="utf8"))
 durations=man["clips"]["attack"]["ticks"];assert len(durations)==8
 pictures=[Image.open(p/f"attack_{i:02d}.png").convert("RGBA") for i in range(8)]
 scale=4
 pics=[im.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST) for im in pictures]
 # Palette RGB mode GIF with solid backing for preview only, never used for texture source
 qframes=[]
 for im in pics:
  card=Image.new("RGBA",im.size,(35,45,57,255));card.alpha_composite(im)
  qframes.append(card.convert("RGB").quantize(colors=256,method=Image.Quantize.MEDIANCUT))
 dest=final/f"{case}_A15_attack_preview.gif"
 qframes[0].save(dest,save_all=True,append_images=qframes[1:],duration=[int(t*1000/60) for t in durations],loop=0,disposal=2,optimize=False)
 q.setdefault("previews",{})[case]={"path":dest.name,"frames":8,"width":pics[0].width,"height":pics[0].height}
(final/"A15_FINAL_QA.json").write_text(json.dumps(q,ensure_ascii=False,indent=2),encoding="utf8")
handoff="""# A15 — actual pixel-art correction, source-shape repair (2026-10-31)
Primary goal: improve existing GPT-generated single-Master character/monster art, not merely rerun ASF. No formal FS art gate reached yet.
T1 A10 forest scout master: A14 mistakenly sought sheath at x49..55,y60..66; those pixels are transparent. Inspected enlarged 64x80 Master: hilt-color 4-pixel cluster x40..41,y63..64. A15 confirmed source RGB exact and replaced four colored handle pixels using nearby original brown leather color in six frames (attack_02..07), total 24 source-pixel-safe corrections. Sheathed attack_00/01 unchanged. Other actions untouched. A larger cyan motion arc was generated as A15 R2 experiment but touched near character face and was REJECTED; final uses T1 R1 without broad slash stroke. Sword/hand grip animation still stiff; ART NOT PASSED.
T2 A10 moss-antler master: A14 source leg boxes included bright cream belly pixels, causing ghost duplication during stride. A15 uses tighter polygon part masks and thresholded source dark hoof colours, preserves belly/torso Master as a more complete underlay. Four leg source patches drawn near/far with existing semantic foot anchor table, no antler/head reconstruction. For 8 action frames, 10,160 original opaque head/antler pixel samples compared to matching translated A10 Master were 100% identical. Frames 0/7 exact original master, middle 1..6 rebuilt. R2 dust from actual contact only retained on attack_04/05, not launch/rest. Human video visually suggests less pale belly duplication, but some seam/weight transfer issues persist; G7 pending.
Actual tools: ASF strict T1 6 clips/46 input frames, T2 5 clips/38 input frames (37 exported due preexisting faint dedup), zero warnings; Aseprite/Godot SpriteFrames/Sprite3D outputs succeeded. Actual GPU render on Godot 4.7.2 RX6700XT, 11 animations x 2 captures, 22/22 exact source RGB ROIs. This proves source-to-render, not natural movement. I2V not tested, original FS/VX SEALED unchanged.
Handoff follows fail-closed: rejecting stale mask and bad arc matters more than another PASS table. Next A16 visual priority: draw genuine arm/hand grip key poses and quadruped deformation/contact in source pixel art. Do not attempt Source-to-I2V without video route.
Windows-only private ZIP, cloud text QA/GitHub scripts separately. No source sprites uploaded to public repo.
"""
(final/"CURRENT_HANDOFF_A15.md").write_text(handoff,encoding="utf8")
files=[]
for case in ("T1_forest_scout","T2_moss_antler"):
 for f in (final/case).rglob("*"):
  if f.is_file() and ".godot" not in f.parts:files.append((f,f.relative_to(final).as_posix()))
for p in final.iterdir():
 if p.is_file() and p.suffix.lower() in (".py",".json",".gd",".md",".png",".gif",".godot"):files.append((p,p.name))
for fname in ("a15_source_art_r1.py","a15_r2_effects.py","finalize_a15.py","compare_a15.py","A15_R1_SOURCE_ART_QA.json","A15_R1_vs_R2_T1_forest_scout.png","A15_R1_vs_R2_T2_moss_antler.png"):
 pp=out/fname
 if pp.exists():files.append((pp,"research/"+fname))
zpath=final/"A15_FINAL_PRIVATE_20261031.zip"
with ZipFile(zpath,"w",ZIP_DEFLATED,compresslevel=7) as z:
 for f,rel in files:z.write(f,rel)
with ZipFile(zpath) as z:assert z.testzip() is None
inv={"archive":str(zpath),"file_count":len(files),"bytes":zpath.stat().st_size,"sha256":sha(zpath),"CRC":"PASS","scope":"PRIVATE_WINDOWS_ONLY_NOT_UPLOADED"}
(final/"A15_ARCHIVE_INVENTORY.json").write_text(json.dumps(inv,indent=2),encoding="utf8")
print(json.dumps({"status":q["status"],"A15_T1_hilt":q["changes"]["T1"],"A15_T2_head":q["changes"]["T2"]["head_antlers_matched_source_pixels"],"archive":inv},ensure_ascii=False,indent=2)[:2500])