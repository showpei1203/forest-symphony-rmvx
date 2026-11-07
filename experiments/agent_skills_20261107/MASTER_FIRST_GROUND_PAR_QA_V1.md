# FS Master-first Ground/PAR | Fail-closed Validation Protocol V1
Date: 2026-11-07. Scope: *new* AI-generated full elven village map -> Ground / PAR extraction for RPG Maker VX RGSS2, 32px tile.

## Change of strategy: one frozen master, not three independent paintings
1. Generate and visually review exactly **one coherent full MASTER image** (two architecturally consistent houses, forest, walkable paths, bridge, stream, pond, cliffs). Freeze SHA, native pixel dimensions, working transform. A new render is a **new candidate**, never an update of an approved master without new signoff.
2. Resize the WHOLE source consistently once to 1280×928 (40×29 tiles). The current trial output is 1473×1068, so use a single coordinate transform; do not independently crop/scale the proposed Ground and PAR.
3. AI Ground-only generation is *underpainting/inpainting proposal* below objects, not automatically the **runtime Ground**. Keep unchanged currently visible master-ground pixels locked by a source visibility mask. Do not claim ground geometry is still registered merely because trees and houses have been removed.
4. AI PAR generation provides a **semantic segmentation candidate** and perhaps an editable mask. It does **not** supply an authoritative independently redrawn RGB object layer. For an accepted object mask, take actual object RGB from the **frozen MASTER at identical XY**, retaining its alpha/edge only after a per-object contour review.
5. Keep FOUR separate outputs:
   - `Authoring_GroundOnly.png`: clean underpaint + visible native ground; completed only after visible ground registration review.
   - `Authoring_CompletePAR.png`: *all visually above-ground objects*, from MASTER exact RGB, reconstructed over GroundOnly, including walls and floor-level props.
   - `Runtime_FullGround.png`: **the frozen complete master**; nothing is cut out.
   - `Runtime_OcclusionPar.png`: ONLY parts that should draw **in front of the walking actor** (tree crown, roof overhang, cliff top lip, fence/rail portion depending on foot depth), master-matched RGB; never simply reuse whole Authoring CompletePAR as actor-cover.
6. Collision is separate from both authoring and runtime PAR: 40×29 32px tiles; terrain walkable by default, explicit water/cliffs/building/rocks block. Walkable bridge deck remains walkable. Native Map050 ground/passability checked by **real RGSS2 Game.exe**, not a scripted passable? override.

## Hard acceptance gates
| Gate | Evidence / strict predicate | Status of initial AI triple |
| --- | --- | --- |
| G0 Sources & dimensions | one original MASTER SHA; same original dims; one pixel transform; target exact 1280×928 and 40×29 | PASS, source 1473×1068 |
| G1 Art & composition | user approval of one-piece buildings/style, continuous forest group extending off boundaries, natural path, water/bridge, 1× sharpness | PENDING |
| G2 AI Ground+AI PAR recomposition | alpha-over at identical XY must reconstruct MASTER, target RGB MAE<=2.0 and >=99% pixel max-channel diff<=8 (candidate minimum). For final registered authoring, require exact visible pixels and explicitly compare alpha-fringes | **FAIL** |
| G3 AI semantics & PAR alpha | manually review source-registered masks for roof vs wall, distinct tree crowns, footpoints, bridge rail/deck, pond bank vs water. Positive and negative control positions; no whole-forest actor grid lattice; AI alpha alone never yields PASS | **FAIL/REVIEW** |
| G4 Runtime layer pixel ownership | ALL visible RGB under alpha of Runtime_OcclusionPar must be sampled from MASTER RGB at the same pixel coordinate, and Runtime_FullGround+Runtime_OcclusionPar recomposites **exactly**, zero wrong-background/halo pixels | PASS on RGB-only draft; semantic masks unapproved |
| G5 Underpaint | lock visible Ground against MASTER; independent AI generative ground can ONLY reconstruct hidden terrain. Paths should not bend, pond/water/bridge footing cannot relocate; same world coordinates | **FAIL/REVIEW** current AI ground |
| G6 Native collisions | compile 40×29 Map050, test native passability of all 1160 cells and every legal cardinal edge vs independent scene/collision spec; no standing-in-water or obstructed house entrance | NOT RUN |
| G7 Actor occlusion | Game.exe real screenshot with switch203 OFF/ON and actor move into/out of front canopy, behind roof overhang, and alongside bridge rail; camera stable, differences inside actor footprint (with small tolerance); walkway clear negative control 0 changed pixels; inspect 1× visual | NOT RUN |
| G8 Handoff & art seal | source SHA, masks, before/after, native screenshot, complete failures, rollback, QA JSON, explicit artist approval; no Final Seal if ANY blocking gate fails | NO |

**Warning**: map-wide alpha coverage is NOT a universal quality metric; a deep forest may cover a large canvas legitimately. The initial AI PAR alpha>=128 covers ~74.316% and needs detailed semantic audit. Avoid simplistic alpha-percentage PASS/FAIL thresholds.

## Actual first-trial evidence
Inputs: one generated MASTER (1473×1068 RGB), one independently inpainted AI Ground (1473×1068 RGB), one independently cutout AI PAR (1473×1068 RGBA).
- True alpha-over AI Ground + AI PAR, compared to MASTER: **only 12 of 1,573,164 pixels exactly equal**, mean absolute RGB difference **40.136**, pixels with any channel abs error>40 **54.8148%**, pixels max channel error<=8 **2.7726%**.
- AI PAR alpha==0 **8.925%**, alpha>=128 **74.316%**, alpha==255 **0.01081%**. Real transparency exists, but transparency alone is not a correct actor occluder.
- Source-pixel ownership correction demonstration: copy each visible PAR RGB pixel from MASTER, retain AI-proposed alpha ONLY as **unapproved mask candidate**. Master+this PAR then reproduces MASTER exactly **by construction**. That is a geometric RGB proof, NOT a semantic/engine PASS.
- AI inpainted Ground must not replace Runtime_FullGround because it has redesigned some visible road/terrain details. Final upper/lower geometry needs same-source alignment.
- No VX collision, actor occlusion, or Godot tests were performed on this new scene. Therefore **Full Layering FAIL / Art Signoff PENDING / Formal Seal NO**.

## Failure classification & next stage
F01: independent generative RGB edits reposition object details, violating same-source registration. Fix: master RGB source slicing with semantic masks.
F02: AI full PAR alpha is an authoring object guess, not actor occlusion front-only shape. Fix: generate/source-label roof, crown, rail, cliff-lip *separately*, verify object-visibility/footpoint before export.
F03: AI Ground inpainting changes already-visible terrain. Fix: lock unoccluded master pixels and only inpaint hidden regions.
F04: native RPG Maker VX layer collision and sprite occlusion untested. Fix: mandatory 40×29 Map050, switch203 and movement witnesses.
F05: avoid ghost object shadows. Exclude cast-shadow artifacts from upper-actor PAR unless intentionally part of object lighting; compare source RGB at boundary and zoom 1×.
F06: avoid false semantic pass of previously hidden-source tree_003: source PNG identity does not prove the object is actually visible in final MASTER.

## Reproducible QA package
The delivered `FS_MASTER_FIRST_QA_V1_20261107.zip` includes all three original generated images, `fs_master_first_qa.py` runnable with `pip install numpy pillow`, original/composite/registered candidate previews, difference heatmap, JSON report and 1280×928 candidate files. Registered candidate PAR is tagged **SEMANTICS_UNVERIFIED**, never certified VX output.

**Primary project: RPG Maker VX / RGSS2, 32×32. Do not route it as Godot-first.** Historic A36H R2/R3 draft source art and VX tests are unchanged.
