"""A34 source-first FINAL private handoff with validated provider jobs and fail-closed visual result."""
from pathlib import Path
import json,hashlib,zipfile,sys
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
A33=B/"A33_HUMANOID_DIRECT_POSE_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def ld(p):return json.loads(p.read_text(encoding="utf8"))
def write(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding="utf8")
prior=ld(R/"A34_VIEW_MASTER_SUBMISSION_LOCK.json")
m=ld(R/"A34_R2_TWONATIVE_SUBMISSION_LOCK.json")
a=ld(R/"B2_DODGE_NATIVE_VIEW_POSES"/"SUBMISSION_LOCK.json")
qa=ld(R/"A34_FRAME_DIRECTION_AND_ANIMATION_QA.json")
assert prior['http']==422 and prior["job_id"] is None
jobs={}
for name,dat in [("two_native_battle_view_master",m),("F0_correct_Dodging_B2",a)]:
 jid=dat["job_id"]
 status,res=api(key(),"/background-jobs/"+jid)
 assert status==200 and res.get("status")=="completed",(name,status,res.get("status"))
 billing=(res.get("last_response") or {}).get("billing_usage")
 assert billing.get("generations")==10,(name,billing)
 jobs[name]={"job_id":jid,"provider_billing":billing,"status":"completed","output_status":dat["status"]}
 print("READBACK",name,jid,billing,flush=True)
now=balance(key())
assert abs(float(now["generations"])-1761.8)<.01,now
files={
 "wrong_direction_old":"A34_F0_FAILURE_VS_REAL_NATIVE_VIEW.png",
 "original_battle_view_grid":"A34_NATIVE_BATTLE_DIRECTIONS_ALL_ROWS_8X.png",
 "same_eye_native_comparison":"A34_FIRST_FRAME_DIRECTION_GATE_REVIEW.png",
 "old_vs_new_vs_exact_anchor":"A34_A33_VS_NEW_RAW_VS_F0_LOCK_REVIEW.png",
 "real_provider_3frame":"B2_DODGE_NATIVE_VIEW_POSES/A34_B2_REAL_PIXELLAB_3FRAMES.png",
 "exact_f0_anchor_3frame":"A34_NATIVE_F0_EXACT_VIEW_LOCK_CANDIDATE_3FRAMES.png",
 "raw_gif":"A34_B2_PROVIDER_RAW_ONE_SHOT.gif",
 "anchored_gif":"A34_VIEW_LOCK_ASSEMBLY_ONE_SHOT.gif",
}
for p in files.values():assert (R/p).exists(),p
# Ensure prior and user assets still unmodified.
assert (A33/"B_DODGING_DIRECT_POSES"/"PIXELLAB_B_DODGE_FRAME_00.png").exists()
assert qa["assembled_F0_master_identical"] and qa["assembled_F2_master_identical"]
report={
"stage":"A34","date":"2026-11-01",
"user_feedback":"A33 Dodging F0 wrong facing: HARD CAMERA FAIL",
"source_inspection":{"DODGE_F0":"input source is side-oriented; NOT used as F0 in A34",
 "DODGE_F1":"44 disconnected pixels from previous action row; removed only in CLEAN COPY",
 "DODGE_F2":"32-pixel vertical line contamination; NOT used as recovery frame",
 "original_actor":"source $actor01_1 r1c1 and r2c1 true pixels in 40x40 padded; battle view is art authority"},
"API_limits":{"transfer_outfit_v2_min_2_frames":"confirmed HTTP 422, no generation charged"},
"real_jobs":jobs,"quota":{"start":1781.8,"end":now["generations"],"spent":20.0},
"technical_gates":{
 "g0_sources_sha":"PASS source pixel hashes stored in each lock",
 "g1_first_frame_source_direction":"New first frame anchored to real FS _1 battle view; USER ART REVIEW PENDING",
 "g2_actor_ratio":"1:1 source-preserving, USER ART REVIEW PENDING",
 "g3_unarmed":"VISUAL REVIEW PENDING, no independent paper-doll weapons embedded intentionally",
 "g4_native_px":"40x40 transparent true pixel art, all frames no canvas right/bottom collision",
 "g5_dodge_action":"FIRST and LAST guard pose from true native view, middle crouch comes from real user reference and new provider frame; motion naturalness NOT PASSED",
 "g6_camera_each_frame":"F0 provisional; F1 downward tumble pose; F2 provisional, full 45-degree artistic validation PENDING",
 "g7_sbs_test":"NOT RUN; no engine/weapon overlay pass"},
"source_visual_notes":"A33 old F0 has a one-sided side profile; A34 new F0 displays both face planes using a real FS battle sprite as camera source. Middle crouch still has feet in air/top and abrupt 3-keyframe transition.",
"candidate_source":{"F0":"A34 master PixelLab API output, copied exact, not manual repaint",
 "F1":"A34 B2 real PixelLab reference-controlled output",
 "F2":"exact same A34 master source pixel as F0"},
"raw_provider_vs_assembly":"DISTINCT outputs clearly labeled; both preserved",
"files":files,"original_FS_PM_SBS_files":"UNCHANGED","formal_art_pass":False}
write(R/"A34_FINAL_QA.json",report)
handoff=f"""# A34 Handoff — native FS battle facing first frame and contaminated screenshot pose repair

## Why
A33 Dodging F0 is WRONG FACING (user feedback, hard FAIL); don't treat this as a mild improvement request.
A33 screenshot-derived Dodging reference pose F0 is itself side-facing; F1 has a foreign 44px disconnected fragment from the preceding row and F2 a 32px vertical line. Originals are preserved; only a COPY of F1 has the objective 44px component removed.

## Real FS native battle 45 view inputs
FS source $actor01_1.png r1c1 and r2c1 (32px originals) are each inserted losslessly at (x+4,y+6) into 40px transparent. Camera authority is original FS battle look, not $actor01.png row2 one-eye right-facing walk.
A31 teal/white-hair chibi appearance is reference. Do not put character-held weapons in sprite; SBS paper doll later.

## Actual PixelLab provider executions
- Trial with 1 frame /transfer-outfit-v2 returned HTTP 422, requires at least two frames, not billed.
- True FS battle-view identity transfer two real frames: job {jobs['two_native_battle_view_master']['job_id']}, 10 generations, two 40px PNG outputs. Used first for new F0 and F2.
- Source pose-controlled 3frame Dodging: correct native view F0, cleaned user crouch F1, correct view F2, + new true native-view identity master as reference: job {jobs['F0_correct_Dodging_B2']['job_id']}, 10 generations, three authentic returned 40px PNGs.
- Both jobs and billing verified read-back, A34 start 1781.8, end {now['generations']} /2000. No duplicate submits.

## Outputs
A34_FIRST_FRAME_DIRECTION_GATE_REVIEW.png: native original, user-rejected A33, A34 new master, provider raw new F0, raw crouch F1.
A34_A33_VS_NEW_RAW_VS_F0_LOCK_REVIEW.png: all action frames; old A33 wrong F0 vs A34 raw vs F0/F2 EXACT native master copy as clearly labelled assembly. This is not manual repaint and is NEVER claimed to be raw provider result.
A34_B2_PROVIDER_RAW_ONE_SHOT.gif and A34_VIEW_LOCK_ASSEMBLY_ONE_SHOT.gif: short action previews, no artificial seamless cycle.
A34_NATIVE_F0_EXACT_VIEW_LOCK_CANDIDATE_3FRAMES.png: source-locked candidate: genuine master, real provider F1, same master.
A34_FINAL_QA.json: per-frame gates.

## FAIL-CLOSED ART Status
The new F0 now visually resembles original native FS battle direction more than old side-profile A33 F0. Yet precise 45-degree artistic gate is PENDING user review, and F1 is a deep tumbling crouch with feet high; three-frame transition may be abrupt. DO NOT mark full Dodging PASS, DO NOT overwrite official SBS, DO NOT blindly generate all 16 actions. Next: more detailed F1 motion interpolation or source pose re-selection only after viewing, and validate each F0/F1/F2 facing independently.

Original FS/PMD/Tankentai game asset files were not modified.
"""
(R/"A34_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
z=R/"A34_NATIVE_F0_VIEW_AND_DODGE_PRIVATE.zip"
with zipfile.ZipFile(z,'w',zipfile.ZIP_DEFLATED) as arc:
 for f in sorted(R.rglob("*")):
  if f.is_file() and f!=z:arc.write(f,f.relative_to(R))
with zipfile.ZipFile(z) as arc:
 assert arc.testzip() is None
 print("ARCHIVE",len(arc.namelist()),"FILES")
print("ZIP_BYTES",z.stat().st_size,"ZIP_SHA",sha(z))
print("REPORT_QUOTA",report["quota"])
