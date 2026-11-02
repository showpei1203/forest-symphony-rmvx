# Forest Symphony A63-W3B | Original Waiting lateral choreography correction | 2026-11-02

## Decisive answer to the user's objection
Original $actor01_1 Waiting is **HORIZONTAL left-center-right-center body sway**, not simple breathing up and down. A63-W2 "Waiting" was designed as generic inhale/exhale and is **action-semantics FAIL**, even though its three frames were distinct and its earlier technical pixel gates had passed. The user's correction supersedes all earlier technical PASS statements for W1/W2.

## Real original-frame evidence
Measured directly on exact 32×32 original FS Waiting PNGs (no generated reference):
- Head alpha centroid horizontal: F0 13.699px -> F1 14.667px -> F2 15.423px; right displacement +0.968 and +1.724px.
- Shoulder/chest centroid horizontal: F0 13.545 -> F1 14.412 -> F2 15.100px; +0.867 and +1.555px.
- Head vertical alpha centroid F0 9.428 -> F1 8.903 -> F2 8.958px, only -0.525/-0.470px (secondary).
- Pelvis/feet centroid movement <0.6px horizontal and ~0px vertical, supporting stable standing anchor.
- Playback is F0->F1->F2->F1, **left -> midpoint -> right -> midpoint**, not up/down breathing.

Primary measured values in A63_ORIGINAL_WAITING_MOTION_AUDIT.json; supplementary checks in W3/A63_W3_SOURCE_MEASURED_HORIZONTAL_SWAY_SPEC.json.

## W3 PixelLab skeleton actual paid experiment & FAIL
Actual 18-joint skeleton was rebuilt with correct reference-defined horizontal direction and y changes below 0.5px, boots fixed in input skeleton. One locked real PixelLab v3 paid job was submitted, with real three provider PNG output and no duplicate resubmissions.
Provider drew F1 and F2 essentially identically: F0->F1 head +1.034px horizontally but F1->F2 only 2 changed head pixels and no changed shoulder/body pixels.
This is a **provider collapse of the third fine-motion pose**, NOT the A63 original semantics. Detailed QA/PNG/GIF/job lock in W3_ORIGINAL_LATERAL_SWAY. It must NOT be promoted.

## W3B deterministic source-pixel correction, no new PixelLab expense
Using A62 user's already visually-approved actor F0 transparent 48×48 original pixels, created three stored PNG images by mathematically controlled per-row pixel translation, nearest-neighbor integer shift only, no blur / palette changes / hallucinated outfit:
- F0: original approved character exactly (bit-identical).
- F1: head/shoulder/upper torso +1px horizontally, lower legs and shoes fixed.
- F2: head and shoulder +2px horizontally, mid-waist transitions +1px, shoes still fixed.
- 0->1->2->1 loop, 175ms per phase.
- Four canvas edges clear, three distinct images.
- QA alpha head centroid offsets: +0 / +1 / +2px; shoulder/torso +0 / +1 / +1.801px; feet and lower legs x/y centroid = 0 for every frame.
- Pixel multiset exact identity (original RGBA colors preserved), and y >=38 foot-region pixels identical to accepted F0.
- At generated GIF stage this is a **technical movement fidelity PASS**, but character naturalness, joints/pixel seams, original style and full art review remain PENDING USER.
- This technique gives a reproducible way to reproduce subtle lateral Waiting motion without paying a generative model per actor.

Primary GIF: W3B_PIXEL_PRECISE_LATERAL_SWAY/A63_W3B_PRECISE_LEFT_RIGHT_SWAY_8X.gif
Original vs corrected loop: W3B_PIXEL_PRECISE_LATERAL_SWAY/A63_W3B_ORIGINAL_VS_NEW_SYNCHRONIZED.gif
Pixel source sheets: W3B_PIXEL_PRECISE_LATERAL_SWAY/A63_W3B_PRECISE_SWAY_3POSE_144x48.png
Complete QA: W3B_PIXEL_PRECISE_LATERAL_SWAY/A63_W3B_DETERMINISTIC_WAITING_RECIPE.json

## Forever-reusable production, no repeat of research
Under REUSABLE_RIG:
- A62_APPROVED_RUN_MOTION_RECIPE.json is USER PASS baseline; do not mutate.
- A63_WAITING_W2_VERTICAL_MOTION_REJECTED.json preserves old wrong-action data as failure case.
- A63_WAITING_SIDE_SWAY_MOTION_RECIPE.json now holds corrected lateral movement skeleton semantics.
- A63_WAITING_SIDE_SWAY_PIXEL_RULES.json holds W3B mathematically proved raw-pixel operation.
- retarget_waiting_pixels_offline.py applies the pixel method to a new actor's own approved 32/40/48/64 transparent F0 PNG. Returns 3 PNG, strip and GIF, no 18-joint estimate or PixelLab cost required for Waiting (for simple humanoid idle; review any unusual robes/tails).
- retarget_any_actor_offline.py references new action skeleton recipe for general provider motion; never uses rejected vertical Waiting data.
- prepare_new_character_actions_offline.py creates two cached pose recipes (A62 Run and A63 Waiting), AND generates the new character's 3-frame Waiting PNG/GIF immediately, all no paid calls. One-time character F0 + 18 joints still needed for run and other action bone retarget. It does NOT redo A57 original 45 skeleton estimates.
- Run action remains A62 PASS, separate playback 0->1->0->2; Waiting 0->1->2->1. Other action classes (critical damaged, magic) need new recipes from the original corresponding animations, not generic breathing invented by the assistant.
- Every future 16-action generation must first audit the ACTUAL ORIGINAL 3-frame motion, including head/shoulder/leg locus; no automatic model-generated generic action semantics.

## QA status
A62 Run USER PASS and SEALED.
A63 W1 Waiting: F2 collapsed to F0, FAIL.
A63 W2 Waiting: vertical motion despite original horizontal, SEMANTIC FAIL.
A63 W3 Waiting: skeleton horizontal but provider collapses F1/F2, GENERATION FAIL.
A63 W3B Waiting: deterministic correct horizontal motion, FULL technical QA PASS; artistic naturalness PENDING USER GIF APPROVAL; not tested in VX, and original sealed FS project unchanged.

## Future handoff
When user accepts W3B, promote A63 W3B to approved Waiting baseline and proceed Critical Damaged next. Do not call A63-W3B "formal art PASS" until then. Preserve source SHA. No extra PixelLab attempts for Waiting without evidence that this offline method has an unrepairable specific art defect.
