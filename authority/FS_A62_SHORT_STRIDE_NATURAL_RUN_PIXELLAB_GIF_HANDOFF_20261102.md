# FS A62 Natural Run | 2026-11-02 | 45° SBS three-frame GIF art benchmark

## User's request
Continue actual production, after A61 fixed same-foot stride. Keep the character's left/right foot identity and three whole-body poses. Now prioritize natural short-stride motion resembling native FS $actor01_1 moving-to-close-attack. User currently requests GIF previews rather than VX runtime.

## Original source authority / baseline
Original FS $actor01_1 row 3 contains three stored frames, source columns left-step, neutral, right-step (for preview ordered F0=neutral, F1=left, F2=right). 0→1→0→2 loop. Native actor is 32×32. The A62 sample is a **48×48 ART-only trial**, not directly compatible with VX. Original sealed FS assets and scripts remain untouched. A57 measured original whole-body motion, but its automatically estimated left/right foot identity was mistaken; A61 fixed this with explicit semantic checks.

## A62 actual motion correction vs A61
- F1 left-front boot screen-depth gap +5.66px → +3.416px (66% of A61 relative leg offset after neutral bias)
- F2 right-front boot screen-depth gap −6.34px → −3.370px (45% of A61 relative leg offset after neutral bias)
- Both knees and ankles scaled together to remain coherent, and opposite front-foot signs preserved.
- Arms scaled to 78% (elbows 80%) to keep hands near torso.
- Head/face 75%, NECK 78%, shoulders 86% so the upper body still moves without exaggerated head sway.
- Pelvis/hips 92% of A61 dynamic motion, maintaining balanced weight-shift.
- Facial identity, colors, clothing and native southeast battle view are asked to remain locked in source-first-frame.
- GIF order 0,1,0,2. Separate real frame sources F0/F1/F2. No imagined 'extra fourth sprite'.
- Explicit new fail-closed semantic prepay gate passed. Files A62_PREPAID_NATURAL_GAIT_SPEC.json and A62_PREPAID_A61_VS_A62_FULLBODY_18POINT_COMPARE.png show source, pose identities and whole-body changes.

## Actual provider trial
One once-locked real PixelLab /animate-with-skeleton-v3 request was submitted as job 44c04ae8-5768-458a-ad31-8d7fb145442c; source 48×48 A61 first-frame. Three raw provider frames received and saved unchanged. Balance before 1667.099999999999; after 1667.099999999999. Do not duplicate job.
- Actual 3 frames + 144×48 sheet: A62_PROVIDER_RAW_F0/F1/F2.png and A62_REAL_PIXEL_LAB_3POSE_144x48.png
- GIF: A62_NATURAL_RUN_8X_0_1_0_2.gif
- Synced comparison: A62_A61_VS_A62_SYNCHRONIZED_GIF.gif
- Reference contact: A62_ORIGINAL_A61_A62_VISUAL_CONTACT_SHEET.png
- Pixel QA: A62_REAL_RENDER_QA.json
- All 3 frames edge-clipping gate: True
- Upper-body remains dynamic: True
- Format technical gate: PASS

## Honest approval status
All paid-generation visual candidates require human review. Neither the 45° view's artistic match, natural running quality nor anatomy accuracy is automatically certified. Real native VX/Tankentai NOT TESTED (user earlier requested GIF-first).
If A62 visibly looks unnatural, do NOT immediately submit more paid prompts. Diagnose from the GIF whether failure is camera, foot length, arm swing, weight-shift, or PixelLab not following coordinates. Update offline 18-joint template first. Keep F1 foot gap strictly positive, F2 negative, within ±3-4px.

## Files and check
Local stage: E:\GameAssetToolLab_20261023\A62_NATURAL_GAIT_REFINEMENT_20261102
Original FS and A61 remain unchanged. This ZIP contains raw generated frames, GIFs, exact paid request, prepay skeleton comparison, scripts, QA, SHA256 file manifest.