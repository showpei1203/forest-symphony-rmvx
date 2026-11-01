# FS A40 Handoff, native 45-degree, 18-joint severe damage, 3-frame source-first PixelLab

2026-11-01. User instructed continue from A39 (Critic Damaged weak silhouette). Dodging T4 is user-selected; must NOT regress.

## What changed
A38 and A39 /edit-images-v2 produced broadly similar neutral silhouettes differing mostly in facial expression. A40 discovers actual PixelLab /estimate-skeleton and /animate-with-skeleton-v3, which accept 18 real humanoid keypoints per frame, explicit 'south-east' facing.
A40 first /estimate-skeleton request incorrectly sent data:image/png;base64 prefix and got HTTP422; not billed. Corrected request uses raw base64 and returned 18 keypoints from A34 40x40 battle-view actor, charged 0.1 generation, saved full point record.
Source skeleton generated 3 actual 18-joint motion targets: F0 original stance, F1 hit reaction, F2 strong severe stagger with head/neck/shoulders falling diagonally, hips lowering and knees splaying while feet remain planted.
True /animate-with-skeleton-v3 job c0f23f1e-15a0-419a-a819-cb7a2c94cda6 yielded 3 REAL 40x40 PixelLab PNG frames, charged exactly 2 generations, status readback completed. Balance before 1701.8, after 1699.7/2000, total spent 2.1.
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
