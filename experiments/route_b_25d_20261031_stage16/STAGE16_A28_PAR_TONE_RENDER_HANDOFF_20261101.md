# FS Stage16 A28 — Source-first PAR Tone Render / Real Godot Cold Handoff
Date: 2026-11-01 (Taiwan). **Execution COMPLETED**. Engineering provisional PASS; user visual review PENDING; native VX NOT RUN; Formal Seal NO.

## Predecessor and permanent rules
A27 full true source-first Ground/PAR authority and proof: `STAGE16_A27_DRIVE_SOURCE_FIRST_PIXELLAB_GROUND_PAR_HANDOFF_20261101.md`.
New **mandatory reusable procedural rule**: `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md` (Drive source registry read first, independent original native Ground, 32-px passability, complete uncut trees, x/y vs footpoint separation, 1× native sprite QA, real-GPU Godot, cold rebuild).
All original A27 project files, PixelLab Ground and the sealed FS original game remain untouched. A28 is strictly an isolated **non-destructive, zero-generation** PAR appearance experiment.

## User's requested correction: extra PAR color-render pass
A28 adds independent RGB-only per-object render passes to align tree leaves/props with native grass color without generating artwork and without degrading Ground:
1. Retain `A28_GROUND_ORIGINAL_UNTOUCHED_544x416.png` copied byte-identically from PixelLab **A27 ORIGINAL**.
2. Retain `A28_PAR_BASE_RGBA_544x416.png` from the latest A27 R2 foot-y-sorted true PAR, byte-identical to source.
3. Produce `A28_TONE_SPRITES_SOFT` and `A28_TONE_SPRITES_BALANCED`: 12 independently recolored object sprites per option, separately packaged and labeled.
4. Compile depth-sorted `A28_PAR_TONE_SOFT_RGBA_544x416.png` and `A28_PAR_TONE_BALANCED_RGBA_544x416.png`. Each tone layer is a complete standalone transparent PAR layer, not a flattened game scene.
5. Copy BALANCED as provisional `A28_PAR_FINAL_RGBA_544x416.png`; produce true `A28_GROUND_PAR_PREVIEW_FINAL_544x416.png`, 3-up 1× `A28_PAR_TONE_BEFORE_SOFT_BALANCED_3UP_1X.png`, and 8 new native Godot screenshots `A28_GODOT_8_REAL_SCREENSHOTS_1X_CONTACT.png`.
6. Keep alpha value **bitwise identical per sprite pixel**, preserve exact object dimensions and x/y, footpoint y-sort, 32×32 collision map, nearest-pixel filtering, nonblurred source. No shadows or terrain painted into Ground in this first tone gate.
7. Color treatment: per-object RGB channels. For green tree leaf pixels, sample ground green near the tree's footpoint; blend small bounded per-channel shifts toward local ground median (SOFT strength 0.22; BALANCED 0.46). Wood, barrel, rock and lamp use conservative category-specific luminance/environmental tint, retaining material identities and glow. Transparent pixel RGB unchanged. Source and derived images remain separate.
8. The new appearance is still a **human-reviewed candidate**, not user-approved.

## Measured facts
- PixelLab true Ground SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`: original unchanged, 544×416. A27 R2 PAR_BASE SHA256 `f369f11b8cdb247e1f1cbb895c81bc6b9d8a998cacbb0131ad49a749dda4bea6`: unchanged.
- Source objects 12, tree objects 4 (two derived from actual user's original Drive `Trees1.png`, two isolated original PixelLab candidates). Same source license restriction: private technical use only, rights unresolved.
- Transparency changed: 0 object sprite pixels; transparent RGB changed: 0. Source dimensions and top-left positions unchanged.
- Mean local grass-vs-leaf RGB color distance across four trees: original 41.365, SOFT 22.872, BALANCED 13.885. **A numerical color-distance reduction is NOT a visual quality verdict.**
- Actual **Godot 4.7.2 OpenGL native 8 screenshots** rendered with real `$actor01`; all seven actor foot tiles legal under A27 32-px passage grid. Godot BALANCED no-actor screenshot vs depth-y-sorted standalone static BALANCED composite: 2694 pixels differ, **per-channel maximum RGB error 1/255 and exactly 0 pixels with error >1**. Thus alpha/geometry pass within 1 RGB step, not pixel-exact zero.
- Archive cold reconstructed from independent extracted copy at `E:\FS_STAGE16_A28_TONE_COLD_VERIFY_20261101`: actual GPU re-render native 8 frames; **8/8 screenshots SHA256 exact**. ZIP CRC and every bundled file SHA checked.
- PixelLab API generation calls in A28 **ZERO**. No charged generations. No production VX runtime test. Formal Seal **NO**.

## Private delivery
Local Windows E stage directory: `E:\FS_ROUTE_B_STAGE16_A28_PAR_TONE_RENDER_20261101`.
Isolated Godot project: `GODOT_A28_ISOLATED_TONE_BALANCED`.
Full SHA-verified private ZIP: `FS_STAGE16_A28_PAR_TONE_NO_PIXEL_LAB_COST_PRIVATE_20261101.zip`, **4,851,938 bytes**, SHA256 `3ceeafc2c2240ec390afacd6dfb2069cd00cc8ccf6bfb2edb6f0a2479228a6f6`, **87 members**. Includes code, native test screenshots, full private raster layers and editable object sprites. Not for public GitHub commit due uncertain license.
QA: `A28_PAR_TONE_QA.json`, `A28_COLD_REBUILD_QA.json`, `A28_PRIVATE_BUNDLE_MANIFEST.json`.
Master image/scene provenance: A27 original scene manifest, A28 tone manifests SOFT and BALANCED.
Next: select visually accepted tone strength, evaluate larger/denser real Drive trees and more naturally varied small plant clusters, then start separate **isolated** native RPG Maker VX test. Do not burn additional PixelLab generations for PAR tone tweaking.

## Final stage gates
| Gate | Status |
|---|---|
| Read original indexed Drive asset provenance | PASS inherited A27 |
| Original PixelLab Ground SHA and native dimension unchanged | PASS |
| PAR_BASE preserved byte-identical | PASS |
| Two non-destructive tone options, each separate full transparent PAR | PASS |
| Every original sprite alpha and transparent RGB preserved | PASS |
| Native Godot 8-case re-render | PASS |
| All seven standing positions on walkable tiles | PASS |
| Engine vs composited image tolerance <=1 RGB code value | PASS, 2694 pixels diff each at most 1 |
| Pixel-exact no difference | FAIL (2694 pixels differ) |
| Fresh ZIP cold native Godot screenshot SHA | PASS 8/8 |
| Real native VX engine tests | NOT RUN |
| Final visual art and user aesthetic approval | PENDING |
| Formal Seal | NO |

## Avoid repeating earlier failures
- Never claim true render-layer engineering success from a single generated flattened scene.
- Never let unindexed example source replace full original Drive trees.
- Never allow tree sprite x/y positions to depend on footpoint. They are separate scene coordinates.
- Never modify source Ground for PAR color matching; never blur or resize complete alpha sprites. Ensure alpha preserved exactly.
- Keep same-object y-sort in static composition and real engine, report residual RGB threshold exactly.
- Never conflate real Godot GPU 8/8 with VX native or final beauty approval.
