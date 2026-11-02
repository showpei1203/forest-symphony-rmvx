# Forest Symphony A64 Critical Damaged | 2026-11-02

## Immutable status
A62 Moving to Close Attack USER PASS. A63 W3B Waiting TECHNICAL PASS but HUMAN ART PENDING. A64 C3 Critical Damaged TECHNICAL CANDIDATE, HUMAN ART PENDING. No native FS or A62 source changed, no VX tests by user direction.

## Reference evidence
Original actual 32x32 Critical Damaged three sprites are a low wounded curled-up/sitting figure, not upright and not the Waiting sway. F0 and F2 differ at ONLY one RGBA pixel; F1 differs from F0 at 350 pixels, mainly the head/hair/torso plus blue signs. Original alpha centroid F1 head shifts (+0.315,+0.292) px while pelvis and feet do not move. Original action does NOT require three visibly different silhouettes; the old A63 Waiting distinct-pose Gate would be WRONG here.
Blue iconic injury signs appear only F0/F2 and have been isolated into separate transparent FX sprites, never baked into character image.
Original A57 automatic 18-joint estimated NOSE y18 is inconsistent with native head alpha centroid y8. This makes A57 Critical skeleton UNRELIABLE for paid generation.

## Experiments & decisions
- A64 C0/C1: transformed user-approved A62 standing figure, looked standing, REJECT / examples retained.
- A64 C2: native Critical crouch exact 3 frame geometry transferred into 48px transparent frame, original brown body palette recolored to A62 character's teal/dark-green armor; true native F0/F2 remains 1 RGBA pixel different. Face still differed from user-approved actor.
- A64 C3: native crouch torso from C2, but exact A62 approved head/hair/face pixels transplanted, with 1px lower head on middle F1. Exact 336/336 alpha-visible source head pixels match A62. C3 after head replacement F0/F2 are identical; deliberate 1px detail loss from original, not an invented third frame. C3 three PNGs plus 144x48 spritesheet, four-phase 0-1-2-1 GIF. Main technical candidate.
- optional separate blue Critical FX reference layer and optional composed preview. Sprite remains character-only and FX independently rendered.
- C3 QA: 48x48 RGBA, all four edges alpha clear, body+head both change F0/F1, no paid PixelLab credits A64, VX not tested.
- User must still judge whether source physique and A62 face/body seam look natural; cannot auto-classify visual PASS.

## Deliverables
A64_C3_APPROVED_FACE_CRITICAL_8X.gif = character-only GIF
A64_ORIGINAL_C3_BODY_FX_SYNCHRONIZED.gif = original vs C3 vs optional external FX 3-way synchronized
A64_C3_ORIGINAL_CRITICAL_FX_SEPARATE_8X.gif = character+FX preview, independently maintained raw effects
A64_C3_APPROVED_FACE_CRITICAL_144x48.png = character-only 3 frame strip
A64_CRITICAL_DAMAGED_REUSABLE_ACTION_RECIPE.json = native semantics, loop, pose, FX, new-actor transfer method
A64_CRITICAL_ORIGINAL_PIXEL_AUDIT.json = source frame per-body-part measured evidence
A64_FINAL_C3_ART_QA.json = hard tests
A64_ORIGINAL_C2_VS_BAD_C0_ART_COMPARISON.png = transparent failure analysis and before/after
Other A64 source files and generated candidates included in verified ZIP.

## Subsequent stages
Do not make C3 official without human GIF approval. If face/body seam ugly, fix localized actor-colored torso without restarting native A57 analysis. Next candidate A65 Magi Skill Use should begin with ACTUAL FS original three-frame reference and keep magic FX separate; action-specific semantically valid gates. Do not blindly reuse waiting or running skeleton/loop.

## Permanent rules
Source original artwork first, then match character palette and identity, then animate with 3 stored poses and an action-defined playback; preserve original rather than demand artificial movement. Always keep first approved actor identity and native authority distinct. A64 original F0/F2 nearly identical proves third-pose distinct is not universal.

## 2026-11-02 NEW PERMANENT REFERENCE AUTHORITY: user-designated original asset libraries

- **FS permanent original/reference root**: [00_Reference_Original](https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr) (Google Drive folder ID `1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr`).
- **FS priority battle-character motion template library**: [人物戰鬥動作範本](https://drive.google.com/drive/folders/1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe) (folder ID `1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe`), a verified direct child of the above reference root.
- Direct folder inspection verified multiple `Kaduki*.png` and `Actor*.png` sprite families, with repeated numbered variants `_1/_2/_3`. More than 100 direct items are present; **full catalog, anatomy interpretation, and action compatibility have not yet been verified**. Treat file names as indexed candidates, not proof of an action's meaning.

### Mandatory actor animation workflow (source-first; avoid wasted PixelLab credits)
1. **Before devising any new action or prompt**, inspect the corresponding original `$actor01_1/_2/_3` action frames plus these reference-library sprite sheets. Identify suitable families and action poses; inventory contact sheets, frame counts, directions, perspective, source dimensions, actual root/feet, head/shoulder/chest/hip/arm/knee/boot movement, frame order, and FX layers. Use direct source images to constrain the motion, not generic descriptions ("breathing", "running", "damage").
2. Group same-character files and variants; do not assume `Actor###_1/_2/_3` means left/middle/right poses or the same action until reviewed. Build an annotated **reference selector**: original file ID/path, actor family, verified frame layout, camera, action semantic, recommended adaptation mode.
3. Reuse an already accepted motion rig/recipe first (A62 run USER PASS, A63 Waiting only technical, A64 Critical only candidate). For new actions, select one or more close examples from the library and use them as a visual template for PixelLab when suitable; alternatively retarget/edit/process the user-supplied original PNG locally. Maintain an exact named provenance link to the image used.
4. Preserve FS fixed **45° southeast battle perspective**, anatomical left/right, three stored frames per action (loop order defined *per action*), complete full-body motion, identity/wardrobe, alpha, fixed foot anchors when appropriate, and independent weapons/FX.
5. Make source-data and skeleton/action-semantic gates **before spending PixelLab units**. Prefer the source PNG + concrete pose references to repeatedly blind prompting. Deliver original-vs-candidate frame contact and animated GIF for human approval; no VX until explicitly requested. Record failures and successful reusable recipes so other characters do not repeat A43–A62.
6. Never replace user-approved art or sealed FS source; preserve the original Drive folder links, source permissions, local source hash when materialized, code and handoff; do not claim full library analysis complete until performed.

**Implementation state:** Both folders and example names verified live on Google Drive on 2026-11-02. This section registers the persistent authority and required selection process, not a claim that each sprite has already been studied.

### 2026-11-02 reference-library metadata inventory milestone
Completed a paginated Google Drive **PNG filename + file-ID inventory** of the registered battle-motion template folder: **364 unique PNG names**, **4 pages**, **122 filename-family groups** under simple suffix grouping. **Action interpretation, exact sprite-sheet slicing, individual perspective and visual quality are NOT yet proven**. The older statement about the full catalog being pending now refers specifically to **visual/semantic cataloging**, not to PNG-name enumeration.
- [Full 364-PNG Drive-ID manifest](https://github.com/showpei1203/forest-symphony-rmvx/blob/main/authority/FS_CHARACTER_MOTION_LIBRARY_MANIFEST_20261102.json)
- [Filename-family selector and source-first workflow](https://github.com/showpei1203/forest-symphony-rmvx/blob/main/authority/FS_CHARACTER_MOTION_LIBRARY_INDEX_20261102.md)
