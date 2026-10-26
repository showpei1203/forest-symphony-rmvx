# FS / AI Art Toolchain — Ground × Player-Scale Rules v1.0
Authority date: 2026-10-26 | Task: F2_G5R3_PLAYER_SCALE_SEMANTICS
Status: AUTHORITATIVE RULE UPDATE. No art or engine PASS is implied by this document.

## Reason for correction
The user detected that a flower/flower cluster near the bottom-right of the G5R2 contiguous Ground source might visually approach the size of a playable character. Ground source-continuity QA alone (320×256 crop; 80 native 32px tiles; zero reconstruction drift) did NOT test on-screen scale or semantic ownership. This is a distinct failure class:
`F2_G5R2_FAIL_OR_PENDING_GROUND_ACTOR_SCALE_AND_FLORA_SEMANTICS`.
Do not claim that reassembling a crop proves a game-ready Ground.

## Mandatory ground production order
1. **Authoritative visual source**: preserve the user's high-detail elf-village concept and matching authorized assets; do not substitute a generic or geometry-built cottage. Work **source-first**: coherent Ground source first, independently owned flora/rocks/trees/house PAR source second, then scene assembly and VX.
2. **Actor scale calibration FIRST, before accepting any expanded Ground**:
   - Locate the real, currently playable VX $character sprite and measure its displayed **visible silhouette bounding box** in the intended native scale; record pixel width, height, and collision-foot position. Do not confuse the sprite bitmap or a 32px map grid with body size.
   - Compose an exactly 1× nearest-neighbor preview with this actual avatar standing immediately adjacent to, then partly in front of, any suspect vegetation; use the same camera scale, not independently scaled mockups.
   - Quantify suspect plant/flower-cluster bounding boxes relative to actor visible height and foot width; record object ID/rect, scale ratio, and decision. If actor art is inaccessible, gate becomes `BLOCKED_ACTOR_REFERENCE`, not PASS.
3. **Three semantic plant classes**:
   - **GROUND**: flat grass, earth path, small scattered petals/flowers and genuinely flush ground accents; passable by default.
   - **SCALE_REVIEW**: any coherent tuft/flower cluster that reads as raised rather than soil, or that visually competes with the actor, must be isolated and reviewed before placement.
   - **PAR_FLORA**: clustered flowers, bushes, upright rocks, plant structures or any decorative group approaching the actor's apparent leg/body bulk, including the reported G5R2 lower-right flower. Move to a separately positioned source-owned PNG/PAR with alpha, bounding rect, foot anchor, and independently adjustable scale. Decoration may remain walkable if soft; collision ONLY if actual hard physical contact merits it.
4. **Provisional automated flag thresholds (not artistic approval)**: inspect a cluster occupying >= 25% of actor visible height or >= 50% of the actor foot-width. If >= 50% of actor visible height, or approximately actor-footprint sized, require PAR_FLORA classification unless a documented side-by-side proves it is a flat ground pattern. Actual avatar measurements supersede any assumed 32px hero height. These thresholds flag review; they do not automatically label assets valid.
5. **Ground cleaning**: remove only object-owned artwork from Ground and reconstruct terrain with legitimate consistent source. No geometric donor squares, blur, clone quilt, pasted flower ghosts, hard edge seams, or ungrounded huge flowers. Preserve native crisp pixels, color/detail richness and natural paths. Do NOT shrink the whole scene as a shortcut to fix vegetation scale.
6. **Collision/depth**: Ground defaults walkable; explicit water/holes/void are exceptions. Hard PAR contacts block by foot only; flowers/soft grasses can be walkable PAR with y-sort/occlusion. Closed house door blocks, its immediately adjacent front tile is walkable. Check actual VX player `passable?` and exact one-step movement.
7. **Fail-closed gates, in order**:
   A. real actor source + 1× visual comparator, documented size ratio;
   B. semantic per-object masks (flower material cannot be permanently burned into Ground if PAR-owned);
   C. native Ground source continuity, no visible stitching/oversized decorations, side-by-side style inspection;
   D. 32px tile/foot collision, occlusion, native VX;
   E. user Human Visual acceptance. A test of one gate never promotes later gates.
8. **Regression fixture**: record G5R2 lower-right flowers as `NEEDS_PLAYER_SCALE_REVIEW`. Revisit all 80 32px source tiles, report flags per tile, and do NOT overwrite the sample: produce a new isolated G5R3 candidate with before/after, masks, QA, and screenshot with actual actor.
9. **Preservation**: keep F1R1 A04 USER PASS SEALED. Older F2 full-size Ground art retains `ART_FAIL_DONOR_PATCH_SEAMS` even though native VX G4 collision TECH PASS. Every revision must include ZIP, runnable QA CMD, LOG, `CURRENT_HANDOFF.md`, source manifest and Drive/GitHub/Linear sync.

## P3 monster status (new user feedback)
The user explicitly **loves the P3_G3R1 orange-gray volcanic-rock direction**. Lock `PMD0001_VOLCANIC_ORANGE_GRAY_STYLE_DNA_APPROVED`. Preserve its juvenile warm-orange/charcoal rock shell with fine glowing magma cracks. The 0001→0002→0003 evolution should gradually fracture the rock with brighter magma and final rock+fire core. This is **approval of visual direction**, not a substitute for end-to-end every-animation Human Gate, commercial licensing, original PMD game loader or VX SBS native validation.
