# Forest Symphony A65 Magi Skill Use | 2026-11-02

## Stage and sources
A62 Moving to Close Attack = USER PASS. A63-W3B Waiting, A64-C3 Critical = technical candidate; human art approval pending.
A65 Magi Skill Use = C2 recommended technical candidate / USER ART REVIEW PENDING. C3 alternate.
Authority: actual FS original 16_Magi_Skill_Use_REFERENCE_3POSE.png, native 96x32; A62 USER APPROVED F0 PNG (exact 48x48 identity). No change to VX or sealed original assets.
Permanent reference root: https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
Battle-motion image library: https://drive.google.com/drive/folders/1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe
Metadata inventory: 364 PNGs, 122 filename families in authority/FS_CHARACTER_MOTION_LIBRARY_MANIFEST_20261102.json. Only 3 samples were pixel inspected earlier; do not claim a 364-file semantic analysis.

## Original 3-frame measurement (actual source, not inferred)
Original frames show quiet upright combat stance with tiny upper-body/hair changes. Screen-left shoulder glows orange F0, intense orange-yellow F1, is dark F2. Lower body and feet almost still. Source RGB/A differences: head F0/F1=70, F0/F2=53 pixels; upper shoulders F0/F1=78, F0/F2=43; lower feet F0/F1=4, F0/F2=1. No dramatic raised-hand gesture or marching. This is NOT a generic giant casting action.
Original magic FX extracted from screen-left shoulder ROI native x7..13,y17..23 using specific orange/yellow pixels, 6/21/0 pixels in frames F0/F1/F2. Exclude skin color outside ROI. Separate FX source kept in own three PNG images.

## A65 produced (zero PixelLab credits)
- C2 and C3 genuinely rendered as 3 stored 48x48 RGBA character PNGs, 144x48 raw sheet, and 4-phase 0-1-2-1 loop GIFs.
- C2 F0 is BIT-EXACT A62 approved character, and F1 subtly shifts head+upper torso one original pixel screen-right. F2 hair crown drifts 1px screen-left. Feet pixel band y>=31 remains byte-identical in all stored frames, all character pixels' RGBA palette preserved. C3 extends these body shifts slightly lower; visually C2 fits source subtle motion better.
- Real original native magic FX moved x+7,y+6 to approved screen-left shoulder, overlay optional for preview; standalone FX never baked into character-only sprite sheet.
- Files: A65_C2_MAGI_WITH_EXTERNAL_FX_8X.gif (priority preview), A65_C2_BODY_ONLY_8X.gif (body audit), A65_ORIGINAL_C2_C3_SYNCHRONIZED.gif (FS original / C2 / C3), A65_ORIGINAL_A62_C2_C3_VISUAL_CONTACT.png, A65_C2_3POSE_144x48.png, A65_ORIGINAL_SHOULDER_FX_F0/F1/F2.png, A65_C2_C3_REAL_QA.json, A65_REUSABLE_MAGIC_SKILL_ACTION_RECIPE.json.
- Visual failure possibilities: row-shift 1px seams in hair/torso, orientation and magic-FX shoulder alignment. Technical pixels PASS but HUMAN aesthetic judgment pending. No VX testing, original game source unchanged.

## Later actor reusable method
Use each actor's separately accepted 45deg SE F0, verified camera/pose, then apply character-scale-subtle upper-body source reference motion, and attach shoulder magic overlay as its own FX layer with per-character shoulder anchor. Recheck actual silhouettes and do GIF human review. DO NOT repeat A43-A62 prompts, do not force unverified actor families to mean casting. For new action inspect the actual native actor01 three frames and relevant sampled battle motion reference PNGs first. Use PixelLab only if local pixel-control cannot produce acceptable visuals.

## Next
Human GIF acceptance of A65-C2 before classifying formal PASS; advance to other unfinished actions in isolated candidates. Always update Drive/GitHub source authority, failure log and before/after.
