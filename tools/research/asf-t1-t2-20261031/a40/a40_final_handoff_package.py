"""A40 pack and final fail-closed QA, re-verify real PixelLab jobs and quota.
Original FS, PMD and SBS never modified. A37 approved T4 selected variant remains intact.
"""
from pathlib import Path
from PIL import Image
import sys,json,zipfile,hashlib
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding="utf8"))
def save(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding="utf8")
est=read(R/"ESTIMATE_SKELETON_R2_LOCK.json")
anim=read(R/"A40_CRITICAL_V3_SUBMISSION_LOCK.json")
geometry=read(R/"A40_CRITICAL_3POSE_18JOINT_CONTROL.json")
qa=read(R/"A40_SOURCE_ANCHORED_COMPARE_QA.json")
assert est["status"]=="KEYPOINTS_RECEIVED" and est["count"]==18
assert anim["status"]=="THREE_REAL_PROVIDER_FRAMES_READY_ART_QA_PENDING"
assert len(geometry["keyframes"])==3 and all(len(f)==18 for f in geometry["keyframes"])
res_status,res=api(key(),"/background-jobs/"+anim["job_id"])
assert res_status==200 and res.get("status")=="completed",(res_status,res.get("status"))
bill=(res.get("last_response") or {}).get("billing_usage")
assert bill and bill.get("generations")==2,bill
balance_now=balance(key())
assert abs(float(balance_now["generations"])-1699.7)<.01,balance_now
frames=[Image.open(R/f"A40_REAL_SKELETON_V3_FRAME_{i:02}.png").convert("RGBA") for i in range(3)]
assert all(f.size==(40,40) for f in frames)
raw=Image.open(R/"A40_RAW_REAL_PIXELLAB_3FRAME_120x40.png").convert("RGBA")
sheet=Image.open(R/"A40_CRITICAL_SOURCE_ANCHORED_3FRAME_CANDIDATE.png").convert("RGBA")
assert raw.size==sheet.size==(120,40)
gif=Image.open(R/"A40_CRITICAL_ANCHORED_3FRAME_ONESHOT.gif")
assert gif.n_frames==3 and gif.info.get("loop") is None
full={
"version":"A40","date":"2026-11-01","action":"Critic Damaged (severe damage)",
"source_baseline":"Real original FS actor01_1 native battle view -> A34 true provider art 40px",
"source_first_frame_sha256":sha(B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"),
"estimate_skeleton":{"real_api":"/estimate-skeleton","count":18,"cost_generations":0.1,
 "first_rejected":"HTTP422 data URL instead of raw base64, not billed","result_file":"A40_ESTIMATED_NATIVE_BATTLE_SKELETON.json"},
"animation":{"real_api":"/animate-with-skeleton-v3","job_id":anim["job_id"],"real_provider_billing":bill,
 "requested_3_skeletons":True,"real_generated_frame_count":3,
 "raw_frames":["A40_REAL_SKELETON_V3_FRAME_00.png","A40_REAL_SKELETON_V3_FRAME_01.png","A40_REAL_SKELETON_V3_FRAME_02.png"],
 "raw_sheet":"A40_RAW_REAL_PIXELLAB_3FRAME_120x40.png",
 "selected_sheet":"A40_CRITICAL_SOURCE_ANCHORED_3FRAME_CANDIDATE.png",
 "selected_source":"A34 original battle-view F0 followed by actual PixelLab skeleton F1/F2, no raster repaint",
 "cost_generations":2},
"quota":{"before":1701.8,"after":balance_now["generations"],"spent":round(1701.8-balance_now["generations"],2)},
"motion_and_camera_gates":{
 "exact_three_frames":"PASS","native_40x40_rgba":"PASS","width_120x40":"PASS",
 "no_border_clipping":qa["canvas_crop_gate"],"stronger_body_stagger_vs_A39":"VISIBLE: head sinks, torso rotates, hips/knees actually move",
 "severe_hit_semantic":"PROVISIONAL CANDIDATE, visually improved, final user art acceptance PENDING",
 "45_degree_every_frame":"PENDING artist review, no 90deg side-facing guaranteed",
 "no_embedded_weapons":"VISUAL PROVISIONAL; actual Tankentai paper doll not tested",
 "same_identity_all_frames":"PENDING, frame2 head and clothing need scrutiny",
 "VX_SBS_integrated":"NOT TESTED","formal_game_pass":False},
"pose_source_and_QA":"A40_CRITICAL_3POSE_18JOINT_CONTROL.json, A40_ACTUAL_18JOINT_CRITICAL_POSE_QA.png",
"visual_comparison":"A40_NATIVE_VS_NORMAL_VS_CRITICAL_SKELETON_COMPARISON.png",
"single_shot_3frame_GIF":"A40_CRITICAL_ANCHORED_3FRAME_ONESHOT.gif",
"unmodified_project_assets":True,
"prior_user_approved_T4":"A37 Dodging fourth variant retained untouched",
"test_controls":"18 labeled joints, critical F2 torso lean, neck descent, hip lowering, knee spread, grounded feet, explicit direction south-east"}
save(R/"A40_FINAL_QA.json",full)
handoff=f"""# FS A40 Handoff, native 45-degree, 18-joint severe damage, 3-frame source-first PixelLab

2026-11-01. User instructed continue from A39 (Critic Damaged weak silhouette). Dodging T4 is user-selected; must NOT regress.

## What changed
A38 and A39 /edit-images-v2 produced broadly similar neutral silhouettes differing mostly in facial expression. A40 discovers actual PixelLab /estimate-skeleton and /animate-with-skeleton-v3, which accept 18 real humanoid keypoints per frame, explicit 'south-east' facing.
A40 first /estimate-skeleton request incorrectly sent data:image/png;base64 prefix and got HTTP422; not billed. Corrected request uses raw base64 and returned 18 keypoints from A34 40x40 battle-view actor, charged 0.1 generation, saved full point record.
Source skeleton generated 3 actual 18-joint motion targets: F0 original stance, F1 hit reaction, F2 strong severe stagger with head/neck/shoulders falling diagonally, hips lowering and knees splaying while feet remain planted.
True /animate-with-skeleton-v3 job {anim['job_id']} yielded 3 REAL 40x40 PixelLab PNG frames, charged exactly {bill['generations']} generations, status readback completed. Balance before 1701.8, after {balance_now['generations']}/2000, total spent 2.1.
The v3 first_frame is an INPUT reference and can be redrawn; the final source-anchored 3-frame candidate explicitly uses genuine A34 original F0, real v3 F1 and real v3 F2. Raw v3 frame00 is preserved separately. No manual pixel edits and no fabricated body poses in finished output.

## Visual finding
Compared to A39 text-only critical animation, real skeleton-driven frame2 shows much lower head, tilted torso, visibly deeper hip/knee slump. The improved severity is credible *candidate*, not user-confirmed art PASS. Body texture/hair identity, southeast 45° each frame, and paper-doll weapon integration need human review. Raw frames geometry, 120x40 sheet, 3-frames-only and no clipping are VERIFIED PASS.

## Full artifacts
- A40_ACTUAL_18JOINT_CRITICAL_POSE_QA.png: F0/F1/F2 original source with estimated/modified skeleton diagram (diagnostic only).
- A40_NATIVE_VS_NORMAL_VS_CRITICAL_SKELETON_COMPARISON.png: true source A34 and A38 normal, A39 old severe, A40 real skeleton F0/F1/F2 in comparable size.
- A40_RAW_REAL_PIXELLAB_3FRAME_120x40.png: raw provider exactly 3 frames, unchanged.
- A40_CRITICAL_SOURCE_ANCHORED_3FRAME_CANDIDATE.png: exact source F0 + 2 real v3 generated poses, three native40x40 columns only.
- A40_CRITICAL_ANCHORED_3FRAME_ONESHOT.gif: exactly 3 frames one-shot, no loop extension.
- A40_ESTIMATED_NATIVE_BATTLE_SKELETON.json and A40_CRITICAL_3POSE_18JOINT_CONTROL.json: original skeleton, controlled poses with all 18 joints, and camera setting.
- A40_FINAL_QA.json, pre-submit locks with SHA, real job id and quota, scripts/preview/ZIP.

## Acceptance and following work
Engineering source and bone-control technique PASSED. Critic Damaged ART CAM 45, facial identity and animation aesthetics USER REVIEW PENDING. No Tankentai SBS overlay or VX/Godot scene integration done. Original FS/PMD/actor01_1/_2/_3 source and all sealed A31/A37 T4 untouched.
The promising next steps are to refine pose-based A40 F1/F2 within exactly 3 frames and apply this skeleton-controlled workflow to human Damage/Attack, only after per-frame camera QA.
"""
(R/"A40_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
z=R/"A40_FS_CRITICAL_18JOINT_REAL_PIXELLAB_PRIVATE.zip"
with zipfile.ZipFile(z,"w",zipfile.ZIP_DEFLATED) as arc:
 for p in sorted(R.rglob('*')):
  if p.is_file() and p!=z:arc.write(p,p.relative_to(R))
with zipfile.ZipFile(z) as arc:
 assert arc.testzip() is None
 print("ZIP_FILES",len(arc.namelist()),flush=True)
print("ZIP_BYTES",z.stat().st_size,"ZIP_SHA256",sha(z),flush=True)
print("PROVIDER_VERIFIED",anim["job_id"],bill,"BAL",balance_now["generations"],flush=True)
