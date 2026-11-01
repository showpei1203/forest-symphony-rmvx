# FS A46 | Moving to Close Attack (three-frame SE45 run candidate)

## Source truth
A43 90-degree-looking side profile is CAMERA FAIL. A44 leans frontal and is ART FAIL. A45 used three separate PixelLab east-to-southeast rotations, which avoided the profile but caused face/camera/identity drift across frames. A46 uses ONE real PixelLab-rotated A45 F0, estimated PixelLab 18 joints, and one real /animate-with-skeleton-v3 animation returning three 40x40 frames (original provider frames preserved). The displayed A46 source-anchored strip uses **exact A45 F0** plus original provider F1/F2. It is NOT described as all three unmodified provider frames.

## Rules
- Store exactly three cells F0 neutral, F1 left step, F2 right step, each 40x40, one row 120x40.
- Runtime sequence F0 -> F1 -> F0 -> F2, then repeat. Four timing phases, **three distinct stored frames**.
- In-place motion only. Tankentai SBS controls movement toward target. No weapon baked into the sprite.
- Head, gaze and shoulder direction must remain fixed throughout. Do not accept endpoint direction text as camera proof.
- Verify 45-degree camera, legs, clipping, identity, frame count, and actual runtime as independent gates.
- Never overwrite sealed original FS or promote to official action asset before human art review and SBS run test.

## A46 measured QA
The script writes A46_REVIEWER_METRICS.json with exact independent head/leg ROI pixel differences.
All three extracted cells have no right/bottom clipping; 120x40 strip, 3 cells and 0-1-0-2 transparent GIF are present.

## Visual reviewer result
A46 is a useful step forward: F0/F1/F2 keep facial silhouette and body facing markedly more consistent than independent A45 rotations. However it is still only a **candidate**. F1 is a visible wide stride and F2 is partly a crossing/tuck step, not a sufficiently unmistakable running stride. The appearance of exact 45-degree facing relative to original native FS battle masters remains subject to independent visual sign-off. Do not mark PASS based solely on the requested `south-east` direction.

**Final: Engineering format PASS; artwork PENDING; actual Tankentai SBS test NOT RUN; formal release FAIL-CLOSED.**

## Evidence
- A46_A43_A44_A45_CAMERA_REGRESSION_4ROW.png
- A46_45_DEGREE_RUN_LOOP_8X.gif
- A46_45DEG_RUN_0_1_0_2_TRANSPARENT.gif
- A46_SOURCE_ANCHORED_45DEG_RUN_3FRAMES_120x40.png
- A46_PROVIDER_RAW_THREE_45_RUN.png (authentic raw three frames)
- A46_STRICT_CAMERA_18JOINT_RUNNING_POSES.json (corrected integral z_index)
- A46_REAL_ANIMATION_R2_SUBMISSION_LOCK.json (one accepted job, no duplicate billing)
- A46_VISUAL_REGRESSION_QA.json and A46_REVIEWER_METRICS.json
- Source script(s) a46_*.py