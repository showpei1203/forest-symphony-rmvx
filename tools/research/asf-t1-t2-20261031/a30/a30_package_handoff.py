from pathlib import Path
import json,zipfile,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A30_FS_SOURCE_MOTION_RIG_LOOP_20261101")
a29=Path(r"E:\GameAssetToolLab_20261023\A29_FS45_UNARMED_PIXELLAB_LOOP_20261101")
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
raw=json.loads((R/"A30_RAW_LOOP_QA.json").read_text(encoding="utf8"))
base=json.loads((R/"A30_SOURCE_KINEMATICS.json").read_text(encoding="utf8"))
idj=json.loads((R/"A30_IDLE_SKELETON"/"SUBMISSION_LOCK.json").read_text(encoding="utf8"))
wlk=json.loads((R/"A30_WALK_SKELETON"/"SUBMISSION_LOCK.json").read_text(encoding="utf8"))
for label,meta in (("IDLE",idj),("WALK",wlk)):
 assert meta["status"]=="RAW_GENERATED_REVIEW_PENDING"
 assert (R/f"A30_{label}_SOURCE_RIG_FINAL_SHEET_40.png").exists()
assert raw["raw"]["IDLE"]["vertical_idle_gate"]=="PASS"
assert raw["raw"]["WALK"]["floor_bottom_range"]["range"]==0
assert raw["final_IDLE"]["loop_seam_diff"]==1 and raw["final_WALK"]["loop_seam_diff"]==1
report={"stage":"A30","date":"2026-11-01","approved_source":"A26 1:1 FS actor01 user PASS; A29 45degree unarmed visual candidate",
"original_source_hashes":{k:v["sha256"] for k,v in base.items()},
"native_motion_analysis":{"base_native_right_row2":"3-phase walk: r2 c0 / r2 c1 / r2 c2",
 "idle":"r2,c1 full bbox bottom y32 constant, head top 0",
 "walk":"r2 c0,c1,c2 foot-bottom always 32, hair top 1/0/1, leg steps short",
 "skeleton":"Original PNG files contain no joint skeleton; 18-joint PixelLab estimated on unarmed A29 sprite and motion constraints inferred from original silhouettes."},
"real_pixelLab_jobs":{"IDLE":{"job_id":idj["job_id"],"provider_usage":idj["provider_usage"]},
 "WALK":{"job_id":wlk["job_id"],"provider_usage":wlk["provider_usage"]}},
"pixelLab_budget":{"previous_A29":1838.9,"A30_skeleton_estimate":0.1,
 "A30_idle_skeleton_v3":3.0,"A30_walk_skeleton_v3":3.0,
 "A30_total":6.1,"live_end_balance":1832.8,"plan_total":2000},
"stage_gates":{"native_source_sha":"PASS",
 "user_approved_character_preserved_source":"PASS, original source untouched",
 "new_actions_provider_pngs":"PASS 6 RAW frames per action",
 "idle_vertical_stability":"PASS foot bottom [38]*6 head top [4]*6",
 "walk_floor_stability":"PASS foot bottom [38]*6 head top [4]*6",
 "loop_seam":"PASS final F_last to F0 1pixel for both",
 "true_45degree":"PENDING USER ART REVIEW - A29 chosen SE candidate not formally passed",
 "natural_step_appearance":"PENDING USER VISUAL REVIEW",
 "SBS_engine_visual_integration":"NOT DONE",
 "weapon_paper_doll_compatibility":"Character unarmed; separate weapon composite not tested"},
"raw_metrics_file":"A30_RAW_LOOP_QA.json",
"final_selected_frames":{"IDLE":[0,1,2,3],"WALK":[0,1,2,3,4]},
"all_raw_provider_frames_kept":True,
"original_$actor01_and_SBS_untouched":True}
(R/"A30_FINAL_SOURCE_GUIDED_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
handoff=f"""# A30 FS actor01 Native Motion Rig / Real PixelLab Loop (2026-11-01)
 
## Core fix
User rejected A29 Idle floating and Walk unnatural. DO NOT repeat generic prompt or use external ImageGen illustration.
Real Forest Symphony source is E:\\RPG MAKER\\260724桌面\\rpg maker 2024\\RPG MAKER\\綠曲-V2.9\\Graphics\\Characters\\$actor01.png and _1/_2/_3. Image geometry 96x128 (3 columns x 4 directions, 32x32 each). Source SHA verified against A23.
 
## Analysis
Right-facing r2, c0/c1/c2 native body and feet; foot bottom =32/32/32; hair top y=1/0/1; head is huge and torso/legs tiny. Native idle is center column c1, WALK is 3 poses. No actual rig joints are stored inside PNG; we infer regions from pixel silhouette, then compute genuine PixelLab 18-point estimated skeleton on A29 unarmed character.
A29 Idle bottom varied 38,37,36,38,38 (2px floating), Walk bottom 38,38,38,37,38 and unnatural free-form body sway.
 
## A30 PixelLab generation (genuine provider API)
- New A30 18-bone estimate based on the actual unarmed A29 diagonal candidate, charged 0.1 generation.
- Idle v3 bone poses: feet, hip, knees, neck, face and eye coordinates fixed; only tiny 1px shoulder/chest breathing. Job {idj['job_id']}; charged 3 generation; six authentic 40x40 transparent PNGs.
- Walk v3 poses: neutral, near-leg step, neutral, far-leg step, neutral, neutral. Root, neck/head and planted foot Y stable; knee/foot move only 1-2px and arms counter-swing 1px. Job {wlk['job_id']}; charged 3 generation; six real 40x40 transparent PNGs.
- No post-drawing or image-generation substitutions. Real frame0 is identical to approved A29 unarmed 40px source.
 
## Objective Loop QA
A30 RAW Idle bbox top y4 for all 6, bottom y38 for all 6; A30 RAW Walk same. No vertical bob. All source PNG originals and failed A29 output intact.
Final candidate cuts only duplicate idle and walk terminal poses: Idle provider indices [0,1,2,3] durations [240,150,150,240] ms; Walk indices [0,1,2,3,4], each 150ms. Last-to-first pixel diff =1 for both, substantially below internal step diffs. Complete six source frames preserved.
- Source rig raw review: A30_TRUE_SKELETON_PIXELLAB_12FRAMES.png
- Final GIFs: A30_IDLE_SOURCE_RIG_FINAL_LOOP.gif; A30_WALK_SOURCE_RIG_FINAL_LOOP.gif; A30_FINAL_IDLE_WALK_COMBINED_LOOP.gif.
- Before/After GIF: A30_A29_VS_A30_RAW_LOOP_COMPARE.gif (old and new both RAW).
- Native image reference: A30_REAL_ACTOR01_ORIGINAL_WALK_IDLE_REFERENCE.png
- QA: A30_RAW_LOOP_QA.json and A30_FINAL_SOURCE_GUIDED_QA.json
 
## Gate and next
- Engineering source/geometry/loop anchoring PASS, human animation naturalness/art angle PENDING.
- A29 diagonal view is visually selected, NOT formally accepted 45-degree southeast view. Preserve direction caveat.
- Weapon-free actor, weapon layer intended as Tankentai SBS paper-doll; NOT tested with overlay.
- Original FS $actor01.png, $actor01_1/_2/_3.png and ALL engine scripts unmodified. No formal engine PASS claim.
- PixelLab quota after A30: 1832.8/2000, A30 spent 6.1 (0.1 + 3 + 3).
- Use this stage as source-guided animation proof and do not revert to A29 hopping.
"""
(R/"A30_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
z=R/"A30_REAL_SOURCE_RIG_LOOP_PRIVATE.zip"
with zipfile.ZipFile(z,"w",zipfile.ZIP_DEFLATED) as archive:
 for p in sorted(R.rglob("*")):
  if p.is_file() and p!=z:archive.write(p,p.relative_to(R))
with zipfile.ZipFile(z) as archive:
 assert archive.testzip() is None
 print("ZIP_TOTAL",len(archive.namelist()))
print("ZIP_BYTES",z.stat().st_size,"ZIP_SHA",sha(z))
print("A30_GATES",json.dumps(report["stage_gates"],ensure_ascii=False))
