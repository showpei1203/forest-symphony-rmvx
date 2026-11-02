# 2026-11-02 ACTUAL TEST RESULTS (supersede original prepay-only state)

A65-V1 REAL PIXELLAB: F0/F1=312 changed pixels, F0/F2=1; provider F2 collapsed and visual/technical motion FAIL. See [V1 failure handoff](./FS_A65_V1_REAL_PIXELLAB_F2_COLLAPSE_FAILURE_HANDOFF_20261102.md).

A65-V2 REAL PIXELLAB: Reused A57 already-saved genuine PixelLab estimate-skeleton on ACTUAL FS native Magi 32px three-frame sprite, retargeted relative displacements to approved A62 48px F0, rather than the manually conjectured V1 motion. F0/F1=30, F0/F2=45, F1/F2=40 changed pixels; THREE DISTINCT FRAMES technical PASS, but full-body artwork and animation naturalness USER ART PENDING. See [V2 latest full handoff](./FS_A65_V2_ACTUAL_ORIGINAL_ACTOR_SKELETON_PIXELLAB_RESULTS_HANDOFF_20261102.md).

Google Drive [A65-V2 full archive and actual GIFs](https://drive.google.com/drive/folders/1FKOnHUdTX1wqb7E-jPU7iTvj2vQskcbh).

Actual original three-frame ACTION IMAGE is **not** a second direct image input to v3; it contributed the A57 actual source-estimated 18-joint poses. A62 user-accepted F0 was the single visual identity input to PixelLab. Both A62 sealed and native FS original untouched. Do not describe these V2 results as formal art PASS or native VX tested.

---

# FS A65-V1 FORMAL PixelLab Action Specification (2026-11-02)

## STATUS / AUTHORITY
- A62 Moving to Close Attack: USER VISUAL PASS. Approved 48x48 first-frame identity and 18-joint human rig retained unchanged.
- A65-C2 / C3 Magi Skill Use: USER REJECTED for unnatural upper-body horizontal cut-line movement. Any earlier "technical PASS" refers only to pixel format and is NOT action/art PASS. DO NOT use the A65-C2/C3 scanline displacement method again.
- A65-V1: original-source semantics + full-body 18-joint source-specific movement + PixelLab FORMAL PROMPT constructed and verified OFFLINE. Provider-generated three-frame sprite has **NOT** been rendered or accepted yet.
- A63-W3B Waiting and A64-C3 Critical: acceptance still PENDING, do not silently promote.
- DO NOT modify sealed FS original or A62, and do not initiate PixelLab paid generation until the pose is checked.

## SOURCE OF TRUTH (TWO DISTINCT SOURCES)
1. ORIGINAL ACTION and frame timing: E:\GameAssetToolLab_20261023\A57_FULL_BODY_MOTION_RIG_20261102\ACTION_REFERENCE_32\16_Magi_Skill_Use_REFERENCE_3POSE.png
   Actual PNG 96x32, 3 adjacent 32x32 frames, SHA256 992f32546a4f2806cb241efc0aab7fe0e71ca8c6561af99297e8635bcea3e515.
2. APPROVED IDENTITY / 45deg camera: E:\GameAssetToolLab_20261023\A63_REUSABLE_RIG_WAITING_20261102\REUSABLE_RIG\APPROVED_ACTOR01_SE45_F0_48.png
   PNG 48x48, alpha bbox (13,7,36,42), SHA256 a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba.
Source original sprite has a much larger relative head/body than the 48px approved actor. Adapt motion action via skeleton, not by transplanting original 32px proportions or shifting rectangular scanlines.

Permanent folders:
- Original materials https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
- Combat actor templates https://drive.google.com/drive/folders/1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe
- Indexed PNG inventory: https://github.com/showpei1203/forest-symphony-rmvx/blob/main/authority/FS_CHARACTER_MOTION_LIBRARY_MANIFEST_20261102.json

## OBSERVATION VS ANIMATION DESIGN
Native F0: source weak orange FX around image-left shoulder, guarded/focused stance.
Native F1: intensified yellow-orange shoulder effect and changes in hair/head/upper-body pixels.
Native F2: no yellow-orange effect and source silhouette returns to calmer pose.
Exact original changed pixels F0-F1: head 70, shoulder/chest 78, feet 4. F0-F2: head 53, shoulder/chest 43, feet 1. Those are changed-pixel counts, NOT measured independent body-joint movements. Source FX mask pixel counts F0/F1/F2 = 6/21/0.
We CANNOT infer a giant two-arm casting throw, hand-held fireball, running motion or full-body leap from original. We CAN define a stronger coherent 48px rig so generated actor has visible connected joints, torso and pelvis compliance, and no panel cut.
18 keypoints inherit ACCEPTED A62 F0; the manually designed F1/F2 offsets are labeled DESIGN PROPOSAL in pixels, NOT source-derived measured displacements.
At this particular approved 45deg SE view, SCREEN-LEFT shoulder maps to target anatomical RIGHT shoulder; confirm again if new actor/facing changes.

## 3 STORED FRAMES / PHYSICAL ACTION
F0 - Preparation / focus: guarded feet, elbows near chest, tiny weak shoulder-area magic.
F1 - Charge apex: RIGHT shoulder screen-left rises by ~0.65px; right elbow screen x-0.74/y-1.42px, hand x-0.16/y-1.55px, left shoulder counters gently, head follows connected neck, hips +0.3px down, knees adjust +0.18px. Both shoes anchored at same coordinates.
F2 - Release / settle: right shoulder and elbow lower back through neutral, opposite shoulder counters, neck/chest/hip re-centers, knee angles naturally uncompress; separate magic FX entirely absent. Do NOT require stepping.
The source action's body motion is subtle but fully joint-connected. Output shall be three 48x48 RGBA sprites; review loop [0,1,2,1] to compare with source timing.

## PIXELLAB CAPABILITY / IMPORTANT INPUT RESTRICTION
Official PixelLab /v2/animate-with-skeleton-v3 uses ONE first_frame image and its first_frame_keypoints, then 3-15 joint frames. It DOES NOT support a second native action reference PNG input field as a separate visual source in the same request. The original ACTOR three-frame strip is used to drive pose extraction/retargeting, NOT magically seen when its filename is typed in prompt.
For actual TWO-IMAGE SOURCE workflow: PixelLab editor Animate with skeleton -> set original ACTOR animation frames as Animation template ("Set animation"), set A62 approved character image as Reference ("Set reference"), correct 18-joint camera/alignment, validate, then generate. For API v3 translate extracted 18-joint 3 poses into keypoints array and use A62 F0 as first_frame. If using legacy PixelLab API with init images, check documented schema first.
Official docs:
https://www.pixellab.ai/docs/tools/animate-with-skeleton
https://api.pixellab.ai/v2/docs

## FAIL-CLOSED, REGRESSION
A65_V1_18JOINT_PIXELLAB_INPUT.json has exactly 3x18 labeled joints, with unique labels and preserved anatomy labels, shoulder-elbow-hand chains and hip-knee-foot chains each within 48px connectivity limits; camera fixed south-east, both feet bit-identical joints in every frame, F0 joints exact A62 F0, F1 charging hand and F2 release distinct.
F0 image identity hash and original action PNG source hash verified. The pixel preview clearly separates SOURCE reference and DESIGNED rig under the approved actor portrait.
Still must inspect provider output for actor identity and expression, no upper-body cut line, no disconnected elbow/hand, no unnatural rigid hips, no facial rotation away from 45deg, proper VFX separation, alpha clipping and 3 true source frames. Human GIF approval necessary before marking PASS or Tankentai VX use.
Generated FX reused from previous A65 native extracted ORIGINAL_SHOULDER_FX_F0/F1/F2.png; those are external transparent layers.

## FILES / CARRY FORWARD
- A65_V1_SEMANTIC_RIG/A65_PIXELLAB_FORMAL_PROMPT_V1.txt (2072 English characters)
- A65_V1_SEMANTIC_RIG/A65_V1_18JOINT_PIXELLAB_INPUT.json (poses and source provenance; not a direct HTTP payload)
- A65_V1_SEMANTIC_RIG/A65_ORIGINAL_VS_V1_18JOINT_PREPAY.png (original/target skeleton comparative 3-frame contact)
- A65_V1_SEMANTIC_RIG/FS_ORIGINAL_MAGI_3FRAMES_96x32.png
- A65_V1_SEMANTIC_RIG/A62_APPROVED_F0_48.png
- a65_v1_rebuild_pose.py reproducible free local baseline and hard gate.

Decision: A65-V1 SOURCE ANIM SEMANTIC PASS and 18-JOINT PREPAY PASS, ACTUAL PIXELLAB and HUMAN ART PENDING. Avoid repeated blind prompts; use original reference animation directly in editor and accepted A62 actor as separate identity reference.