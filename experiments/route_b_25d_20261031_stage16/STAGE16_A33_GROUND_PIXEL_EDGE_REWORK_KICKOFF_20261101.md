> **A33 REAL REFERENCE CORRECTION (2026-11-01):** A32B upper two trees received explicit user art approval. A33 R5 real Ground rebuilt and dual-engine verified. Earlier kickoff's `Overlays/ground3.png` is WRONG as visual reference (dark overlay map). Actual `Graphics/Parallaxes/ground3.png` source SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`; original 35-color vs Overlay reference metrics INVALID for art. New [A33 Current Handoff](CURRENT_HANDOFF_STAGE16_A33_20261101.md), [Permanent Ground3 Source Rules](../../authority/FS_GROUND3_TRUE_REFERENCE_AND_MATERIAL_EDGE_RULES_V1_20261101.md) and [A33 failure register](STAGE16_A33_GROUND_RETEXTURE_FAILURE_REGISTER_20261101.md) supersede kickoff source analysis. Formal Seal NO.

> **UPDATED USER ORDER 2026-11-01:** A32 technical boundary work was visually rejected. A32B upper-leaf structural sprite revision is now the immediate active work. **A33 Ground editing MUST NOT start until A32B tree art is visually accepted by user.** Existing A33 source audit is read-only and may be retained; no user permission to promote A33 Ground candidate before A32B visual signoff. Latest [A32B CURRENT_HANDOFF](CURRENT_HANDOFF_STAGE16_A32B_20261101.md). This note supersedes any older language suggesting an immediate A33 start when A32 only reached engineering PASS. Formal Seal NO.

# Forest Symphony Stage16 A33 — Ground pixel-edge style repair NEXT, not A32 PAR

Date: 2026-11-01 Asia/Taipei. User instruction: **after A32's upper-two-tree PAR crisp-edge engineering is done, next task must start correcting the PixelLab-generated Ground, especially too blurry boundaries relative to supplied example art.**

STATUS: A33 **INPUT AUDIT DONE; NO GROUND IMAGE HAS YET BEEN MODIFIED**. Ground style change will be made in a new A33 isolated branch. Do not falsely present an unedited Ground as a repaired image or mistake the A32 PAR-only result for this requirement.

## Ground source inputs actually checked
1. Existing A32 `Overlays/ground50.png` = A27 PixelLab native opaque original 544×416, SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`. **This original remains frozen.**
2. Existing FS `Overlays/ground3.png` reference 1280×928, SHA256 `a96efa5afdc01363050a542d600bbac5daf6c9d5d7d2816b1be9242ae23f236c`. Ground3 is a **larger and compositionally distinct reference**, not an exact layer-aligned replacement for current 544×416.
3. Actual read-only numerical audit in `E:\FS_STAGE16_A33_GROUND_EDGE_BASELINE_20261101\A33_GROUND_SOURCE_REFERENCE_AUDIT.json`: A27 has 35 distinct RGB colors (indexed-style palette) and adjacent-pixel horizontal mean max-channel gradient ~8.57; Ground3 has 3998 distinct RGB colors and mean gradient ~0.93. Because source composition, style, scaling and contents differ, these global numbers **CANNOT establish** that A27 is softer/harder than Ground3 visually. A27's perceived fuzziness may reflect dithering/noisy material boundaries rather than literal bilinear blur. Need inspect material-specific crops before choosing an algorithm.

## A33 mandatory steps
1. Read all A32/Ground/PAR authority, user style images, current Ground and Ground3 originals, source provenance/licensing. Collect 3–5 material boundary crops specifically grass↔path, grassy clump↔bare dirt, flower/grass detail, plus any rock/ground transitions. Check the natural native resolution of each source.
2. Diagnose **which pixels cause visual softness**, separating antialiased alpha/color, excessive adjacent blend colors, random dithering/noisy contour, inconsistent pixel scale and the shadows/highlights meant for separate SHADOW/LIGHT layers.
3. Select a deterministic, transparent Ground-first repair: crisp material region segmentation and clean 1px pixel-step path boundary, native-size pattern replacement where needed, scene-style grass texture variety; preserve road path geometry and playable cell footprint. Do **not** just unsharp-mask full image, flatten objects onto Ground, inject fake cast shadows, or change map topology unintentionally.
4. Create **new** A33 independent candidate(s), e.g. `A33_GROUND_EDGE_V1_544x416.png`, preserve original Ground under its sealed SHA. Track per-pixel differences and material-mask maps. Preserve user-approved style, source notes, native source PNG.
5. Composite each new Ground with EXACT A32 independent PAR sprites and independently retained SHADOW/LIGHT responsibilities. Confirm no PAR shift/color mistake. Test truly in native VX Map50 with 12 actor obstruction/occlusion positions and legal road movement; Godot native visual parity must be freshly tested for **A33**, not inherited pass labels. Cold copy/rebuild SHA and visual after state.
6. Deliver mobile before/after actual Ground+PAR images, material boundary zoom crops, revised isolated Ground PNG, per-layer manifest, QA and handoff. No formal seal without visual acceptance.

## Boundaries
- A32 frozen baseline (upper two tree B_crisp PNGs, recomposed PAR50 and native QA). No new tree PAR work as A33 deliverable.
- Do not modify any original production FS assets, A27/A28/A29/A30/A31/A32 assets or `ground3.png`. New files only in isolated candidate directory.
- Ground is all-walkable except intentionally blocked water/holes/terrain. Collision remains derived from actual independent PAR obstacle footprints (current ISS::ParaPassa E layer 768/769).
- SHADOW/LIGHT are independently owned layers, NOT GROUND or PAR pixel baking.
- Stage A32 still Formal Seal NO; A33 not yet visually accepted.

**A33 execution priority is now Ground, not more PAR alpha tuning.**
