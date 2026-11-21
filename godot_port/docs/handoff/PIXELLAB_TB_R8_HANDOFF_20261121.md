# Forest Symphony | T-B R8: TB02 Leaf Bat mouth-only attack correction

Date: 2026-11-21 Asia/Taipei; branch: `feat/fs-pixellab-tb-monster-20261121`; issue: Linear `SHO-37`.

## 1. User's corrective art direction (authority)
> 攻擊需要改成用嘴巴攻擊，現在這樣很像身體突然長出一隻手

This instruction supersedes the R7 attack's art candidacy. **R7 leaf bat Attack ART FAIL (wrong action semantics)** despite R7 Godot technical PASS. Do not confuse PMD0001 lava frog V6 ATTACK (separately explicitly user-approved) with TB02 Leaf Bat R7 (never approved).

## 2. Exact failure and corrected method
R7 source code `tb02_bat_attack_pad128_provider.py` directed `claw and bite`, rigged `left talon` and `right talon` to extend forward, and used a `mannequin` template for a winged creature. The resulting F5/F6 looked like a long purple arm emerging horizontally from the chest. Thus the root cause was action semantics and skeletal anatomy, *not* resolution, rendering, or Godot timing. Changes must not waste credits on polishing the phantom arm.

R8 uses a new source-locked 13-joint PixelLab Skeleton v3 rig: body/head/upper jaw/lower jaw/ears/wing roots, elbows, tips/tail, **NO front-leg/arm/talon strike joints**. New prompt explicitly requires **MOUTH BITE ONLY**, two visible fangs, wide dark open mouth, head-led lunge, tiny legs tucked and wings just stabilizing. Eleven specific keypoints: F2 rush, F3-F6 visible opening/snap, F5 bite damage, F7 recover, F10 rest. Same first-frame bat source image, same style and three evolutions, same Idle, 128×128 cell, 4×3 atlas, 11 distinct frames. No source art or original R7 archive overwritten.

## 3. REAL PixelLab job, cost and source chain
- Endpoint: `v2/animate-with-skeleton-v3`
- Job: `ef8135ef-2a6e-4992-8125-6c4ca2fb631a`
- Generation ID: `6ca82361-d5b6-4506-a13f-34acdd75787d`
- Completed and charged exactly **3.0 subscription generations**. TB02 cumulative: **25.0 generations** (22 R7 + 3 R8); real USD equivalent not reported.
- Original TB02 stage1 SHA256: `208e28e4f7732233c75456e9e5de671f5616fb68ef735165219a4b3aa2a959a2`. First animation frame padded to 128px canvas by 16px on each side with exact RGBA check, no reinterpreted art.
- New unmodified provider output (11×128px, 512×384) SHA256: `b258678a7a4b59251b13126ed905c47afd9b9dffd0a618fbb64f584ad9ceeee7`
- Rejected old 128px Attack SHA256: `0a4327d1a951673f2fea6ce982f5b9790a9398066d614d9a85809d9daad5da58`.

## 4. Objective comparison and results
Independent `tb02_r8_bite_qa.py`: **11/11 PASS**.
- F5 horizontal chest protrusion purple pixels **30 (R7) → 0 (R8)**, F6 22 → 0. Defined count: purple pixels x > median amber-eye x+14 in y=69..86. This detects the rejected arm morphology, not total silhouette.
- F5 dark mouth-cavity pixels **21 → 101**, and source-style visible fang pixels **0 → 5**; F3/F4/F5/F6 all have visible fangs. Actual mouth geometry, not a fireball or recolor.
- 11/11 full RGBA frames; **0 edge contact** on all 11; no crop. 11 consecutive frames visually distinct, eyes present, source and Idle SHA unchanged.
- Original approved frog PMD0001 V6 not edited.

## 5. Real Godot 4.7.2 native QA
- Engine exact: `4.7.2.stable.official.ed1daf0bf` on isolated Linux cloud/container, not user's Radeon GPU.
- R8 new Godot private project loads original 3 stages, original Idle 8 frames, new 11-frame Attack 128px atlas, emits `rush=F2`, **mouth bite hit=F5 exactly once**, `return=F7`; hit contact local offset corrected from old frog-specific (29,12) to new bat **(14,0)**.
- Headless native regression PASS: `TB02_R8_MOUTH_BITE_NATIVE_472_PASS 3STAGE 8IDLE 11ATTACK HIT_EXACT_ONCE`.
- Actual Mesa llvmpipe OpenGL/Xvfb native capture: **8 Idle + 11 Attack screenshots = 19/19 PASS**, GIF and full viewport PNG retained privately.
- Regression of original first PMD0001 family: `TB_FIRST_FAMILY_NATIVE_472_PASS` (3 stages + Idle 3F + user-approved V6 Attack 11F, hit exact once).
- Exact production FS 45° camera integration is NOT tested here. R8 new visual is **ART_REVIEW_PENDING**, not falsely claimed user-approved.

## 6. Art Gate
The separate attack art deficiency reported by user is corrected in R8 technical and close-up visual comparison. **Still awaits owner visual approval** of real Godot GIF. If owner accepts, lock R8 and continue to true FS battle-camera integration and production of third species. Do not retry for two-pixel artifacts without an actual blocker. Source/Idle/evolution/PMD frog remain unchanged.

## 7. Deliverables, security and handoff
Private Drive T-B folder: `https://drive.google.com/drive/folders/10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`.
Only upload PRIVATE raster imagery, native renders and ZIP to Drive. Only code/QA/handoff text to GitHub on T-B branch. PixelLab provider ran transiently in authorized PC `%TEMP%` for API credential; delete and verify R8 temp folder after transfer. No artifact repository installed on owner's PC.

R8 source code: `godot_port/tools/pixellab_tb/tb02_bite_r8_provider.py`; independent QA: `godot_port/tools/pixellab_tb/tb02_r8_bite_qa.py`; Godot scene and test under `godot_port/experiments/pixellab_tb/`. Zip contains full copy of isolated private project, generated atlas, F5 comparison, native GIF, 19 screenshots, log, QA manifest, and rejected old R7 graphic for honest comparison.

NEXT COMPLETE UNIT: owner art review of R8 mouth bite; upon approval lock it, then import into real FS ATB/SBS battle scene with 45° camera, source-aligned mouth hit contact, sprite animation events and damage once. Do not touch T-A, T-C or main.

## Final cloud deliverables verified on readback
- **R8 98-entry ZIP / 2,317,074 bytes**, CRC PASS, SHA256 `24ad0556d53213bf8e04a30a62ff729a3f798d06905118e99b0280b44d42d0ee`; [private Drive ZIP](https://drive.google.com/file/d/1lEMQoZ6ayaNC6UV3IorvXjQPGuIBQ2mA/view). The ZIP contains `r8_evidence/` with standalone rerunnable `python tb02_r8_bite_qa.py` and exact source+Idle+old/new sprites; this standalone extraction check passed **11/11**.
- [R8 final 11F genuine PixelLab sheet](https://drive.google.com/file/d/1hr50GCxcvsKZ_LGGaJbRyF4hjfhqrmjg/view); [R7 rejected vs R8 accepted technical comparison](https://drive.google.com/file/d/1t3iXet3N5BOUPXzf_2rg2Oz5LVdaxWDi/view); [Godot real native bite GIF](https://drive.google.com/file/d/1Th_NZ6CFAxFfFiFim41U_NMCgFx-xyVq/view); [isolated animated sheet GIF](https://drive.google.com/file/d/1SiCPf4Sl2LcHWUeDNdYlFw-roMmBwZxn/view).
- The first-family PMD0001 user-approved V6 Attack has not been modified. R8 Attack visual remains **USER_ART_REVIEW_PENDING** until explicitly approved by the owner.
