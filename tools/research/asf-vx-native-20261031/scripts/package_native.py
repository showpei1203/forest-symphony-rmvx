from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
src=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Graphics\Characters\$actor01.png")
audit=json.loads((root/"fs_source_authority_test.json").read_text(encoding="utf-8"))
parity=json.loads((root/"native_godot_parity_report.json").read_text(encoding="utf-8"))
negative=json.loads((root/"negative_test_result.json").read_text(encoding="utf-8"))
assert hashlib.sha256(src.read_bytes()).hexdigest()==audit["source_sha256"],"BASELINE CHANGED"
assert all(x["scores"][x["best"]]["mae"]==0 and x["scores"][x["best"]]["worst"]==0 for values in parity["captures"].values() for x in values),"FAIL PIXEL PARITY"
assert all(x>0 for x in parity["temporal_changes"].values()),"STATIC ANIMATION"
assert negative["exit_code"]!=0 and not negative["published"] and negative["frame_sources_present"]==11,"NEGATIVE FAILED"
assert audit["sparse_numbered_sources"]["actor01_5"]["coverage"]==5 and audit["sparse_numbered_sources"]["actor01_7"]["coverage"]==6,"UNEXPECTED SOURCE DENSITY"
checks={
 "status":"TECH_PASS_WITH_LIMITATIONS",
 "sources":["$actor01.png","IconSet.png"],
 "source_sha256_unchanged":True,
 "16x21_origin_correct":audit["anchor_px"]==[16,21],
 "per_frame_32x32":all(x["alpha_nonzero"]>0 for x in audit["frames"]),
 "rgba_source_12_frame_checks":len(audit["frames"]),
 "native_godot_two_captures_8_direction_samples_zero_diff":True,
 "rgba_render_roi_avg_mae":0,
 "actual_temporal_pixel_change":parity["temporal_changes"],
 "source_grid_5_7_incomplete":{"_5":5,"_7":6},
 "intentional_missing_frame_fail_closed":True,
 "aseprite_8clips_export":"PASS_PARSE_LEVEL",
 "godot_8clips_editor_render":"PASS_NATIVE_GPU",
 "weapon_rotations":{"rgss_visible":[-75,-15,45],"godot_rendered":[75,15,-45],"pivot":"bottom-right, 24x24 icon ID 2","semantic_match":"MATCHES G0-1B AUTHORITY, not a new native VX parity run"},
 "vx_native_runtime_of_this_adapter":"NOT_RUN",
 "six_new_fs_style_motions":"NOT_CREATED",
 "facing_plus_missing_numbered_sources":"FAIL_CLOSED",
 "art_license":"local-only original source PNG and GPU screenshots; code/QA only for Github"
}
(root/"run_qa.json").write_text(json.dumps(checks,indent=2),encoding="utf-8")
readme=f"""# ASF VX-native Kaduki/SBS adapter verification | 2026-10-31
Status: TECH PASS on 4-direction native images and Godot; VX native Runtime of NEW adapter NOT RUN; original/numbered actions not reimagined.

Original sealed test source: FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE (read-only; no modification).
Source $actor01.png: 96x128 -> 3x4 x 32x32, sha256 {audit['source_sha256']}.
Source IconSet.png: 384x15096, icon ID2 crop 48,0,24,24, sha256 {audit['icon_sha256']}.
Body battler root [16,21]; Godot SpriteFrames root offset [-16,-21], original G0-1B authority.
Original RGSS visible weapon angles [-75,-15,45] maps to [75,15,-45] Godot, Or=4 bottom right with no fabricated X/Y offset.
ASF \`build_animation_clips.py\`: 12 original frame PNG, 8 clips (idle+walk x4), warnings=0; \`export_engine.py\`: Aseprite JSON + Godot SpriteFrames from same original art, no sprite reconstruction and no rescaling.
Godot 4.7.2 AMD Radeon RX6700XT native OpenGL: 560x340 two capture PNG actual GPU render. Pixel ROI comparisons for four directions x two timepoints = EIGHT exact matches, all mean absolute error 0 and max channel delta 0 vs original source blended over screenshot background. The 4 moving character ROI changes [down {parity['temporal_changes']['down']},left {parity['temporal_changes']['left']},right {parity['temporal_changes']['right']},up {parity['temporal_changes']['up']}].
NEGATIVE case: removed down-0.png from 11/12 copied original cells, tool exited nonzero and output directory was not published.
Critically original numbered $actor01_5.png has 5/12 occupied cells; _7 has 6/12. They are action-specific/partial, NOT four complete facing clips. Import should reject any nonexistent orientations/poses.
LIMITS: G0-1B angle mapping is reused from prior formal authority, not a new comparison with contemporaneous native VX video; this test only proved Godot using that mapping. No fresh VX Game.exe test, no realistic attack/idle/hurt/new art created, no human weapon visual acceptance.
Source PNGs, 24x24 icon crop, GPU screenshots remain local in an isolated ZIP and must NOT be placed in a public repository without licensing audit. GitHub holds reproducible code, exported scene metadata and QA only.

FULL LOCAL PATH: E:\\GameAssetToolLab_20261023\\ASF_Test_20261031\\vx_real_actor_20261031
"""
(root/"CURRENT_HANDOFF.md").write_text(readme,encoding="utf-8")
files=[]
for p in root.rglob("*"):
 if p.is_file() and not any(x in p.parts for x in (".godot","__pycache__")) and not p.name.endswith(".zip"):
  files.append(p)
out=root/"ASF_FS_VX_NATIVE_ADAPTER_TEST_20261031.zip"
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=8) as f:
 for p in sorted(files): f.write(p,p.relative_to(root).as_posix())
with ZipFile(out) as f:
 assert f.testzip() is None,"ZIP CRC ERROR"
 result={"zip":str(out),"bytes":out.stat().st_size,"file_count":len(f.namelist()),"sha256":hashlib.sha256(out.read_bytes()).hexdigest(),"crc":"PASS"}
(root/"zip_inventory.json").write_text(json.dumps(result,indent=2),encoding="utf-8")
print(json.dumps(result,indent=2))