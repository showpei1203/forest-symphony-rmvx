# A13 | F0 to articulated actor poses: actual candidate and ART self-review FAIL (2026-11-08)

**Art status: FAIL, not sealed.** This turn delivered real 48x48 PNGs/GIF and a source-locked pose guide, NOT an approved new animation.

## Real source and measured deliverable
- A62 previously accepted Actor01 45° battle F0 PNG exactly preserved, SHA256 a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba. Existing A62 144×48 three-frame Run used only as visually accepted comparison.
- New _1 neutral F0, _2 LEFT lead with right leg trailing, _3 RIGHT lead with left leg trailing. Stored frames 3 × 48×48 transparent RGBA; loop 0,1,0,2; 144×48 strip and GIF. 3-poses have different lower limb joint placements, unlike A11/A12 entire-row/six-part breathing shifts.
- A13 V1 legs too wide (art fail). V2 manually reconstructed sleeves as chunky tubes (art fail). V3 moves real source sleeve patches 1-2px with smaller knee/ankle stride, but visual quality STILL below A62 accepted original (art SELF REVIEW FAIL). Original upper 33px of F0 matches source; frames _2/_3 changed 129/140 pixel locations; no colors outside source F0 palette. Such numeric metrics do not certify natural animation.
- Pose spec JSON now records independent left/right hip, knee, ankle, elbow, wrist keypoints and model conditioning constraints, alongside a source F0 + overlaid pose guide PNG. These are real target poses for a future pose-conditioned generator, not final art.
- A free image-generation attempt also made an unrelated generic elf infographic, not Actor01. Rejected, excluded from deliverable; cannot treat identity-unspecified generator output as usable source.

## Protected private file / audit
- Owner-only restricted Drive: FS_A13_ACTOR01_ARTICULATED_RUN_ART_FAIL_AND_POSE_JOB_20261108.zip, 84,797 bytes, 31 members, SHA256 0aa0792667f3bfc88c96bd81796ced072538ee2c32bd09a3fff80d8d90c40867.
- Local CRC, individual SHA256 pass. Cloud upload succeeded to pre-existing private FS_AI_ASSET_FACTORY_Restricted_Binaries; actual Google Drive metadata: 84,797 bytes, shared=false, only owner. Public GitHub has no protected Sprite PNG or private download URL.
- ZIP includes exact approved A62 F0 binary, accepted A62 3-pose source for visual QA, new V1/V2/V3 48px PNGs and animated GIFs, contact sheets, deterministic build scripts, pose_spec.json, keypoint guide, SHA manifest, fail report.

## Architecture conclusion and HARD STOP
Source-only palette and joints can make visible alternating feet, but cannot reconstruct occluded anatomy/material and natural whole-body motion at the accepted visual standard. STOP A13 V4/V5 pixel block/sleeve patch experiments. This is a template-level production fail, not a missing per-frame tweak.
Next correct tool-level trial: SOURCE-IMAGE-CONDITIONED + SKELETON/POSE-GUIDED PIXEL-ART REDRAW using the exact approved F0, pose_spec.json, 3-keyframe map and original source face/outfit. It must generate whole coherent poses, not warp/draw rectangular parts, and preserve 45°/48px/transparent art, left-right alternating feet, separate paper-doll weapon rule. Only after human art approves attempt native FS export and expansion to Waiting/PMD.
No paid PixelLab call (not authorized with bounded credits or direct provider linkage), Orca new agents 0, native Tankentai/Game.exe NOT_RUN, user PC new workfiles 0, main untouched, formal seal NO.
