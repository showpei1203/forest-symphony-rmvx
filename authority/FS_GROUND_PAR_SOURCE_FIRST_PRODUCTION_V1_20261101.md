# FS Ground/PAR Source-First Production Authority v1.0
Date: 2026-11-01 | Adopted baseline: Stage16 A27 R2 | Status: ACTIVE PROCEDURE, not formal visual seal.

## Purpose and precedence
This is the reusable production method proven by A27 544×416 prototype. On conflicts with SEALED FS production materials, **sealed authority wins**. Do not overwrite existing FS game/production builds. Apply in isolated stages; append failure log and handoff after each stage. This authority supplements FS_SOURCE_ASSET_LOCATION_REGISTRY_V1 and existing FS map V3.2 source-first/compiler gates.

### Rule 0 — Resolve indexed sources FIRST
Read FS_SOURCE_ASSET_LOCATION_REGISTRY_V1, Scene Intent, current Ground/PAR authority and CURRENT_HANDOFF before asset work. Go to the exact Drive IDs under 08_Assets/00_Reference_Original/01_Maps_Parallax. Trees folder ID: 1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw (17 sheet files indexed); Plants folder ID 1lem9jNNVOqmpXMpu1Ns90bbuT6XtK59U; Rocks folder 10gdWhmCjrZEroahJe8zeM90Q6wnjeYqI. Avoid unbounded Windows searches as substitute for indexed sources. Verify every binary source as genuine PNG: dimension/alpha/SHA256 and exact Drive ID; use SOURCE_CANDIDATE vs APPROVED vs CONCEPT_REFERENCE separately. Missing rights = PRIVATE TECHNICAL STUDY ONLY; no redistribution to public GitHub or commercial builds.

### Rule 1 — Unambiguous roles
GROUND: one complete PixelLab-native pixel-crisp, opaque 544×416 ground-plane layer; continuous walkable grass, soil paths, clusters of short ground-hugging grass, tiny low flowers, pebbles, leaf litter and natural variation; no upright or player-obscuring objects. Prioritize natural patches/drifts over uniform sparse motifs. Do not substitute a flattened scene generation for a ground engineering asset.
PAR_BASE: assembled from complete isolated alpha PNGs (real trees, lanterns, rocks, barrels, structures); record provenance, source sheet crop, scale and object metadata; no arbitrary scene strips.
COLLISION: independent object footprints, **GROUND walkable by default** (water/pits exception); no canopy-size blocking. Footprint 32×32 grid; separate from alpha.
SCENE_MANIFEST: single source of truth for exact x/y image position, footpoint, y-sort, sprite width/height, collision, links, sha and object type. No independent regeneration of Ground/PAR without manifest.

### Rule 2 — Complete trees; no chopped sprite crops
A tree sprite must contain entire canopy, trunk and roots, with no opaque border pixel at crop edge. For selected A27 `Trees1.png`, source crops (0,0)-(267,297) and (0,512)-(285,860) passed alpha edge threshold, padded 8px and NEAREST downscaled 50%. Record transformation accurately, avoid blur. A forest strip/panorama is not an isolated complete tree and may not satisfy this gate. A27 removed old offcanvas boundary strips and used Drive full-tree art.

### Rule 3 — Render positioning
Object `x/y` = top-left texture coordinates **only**. `foot` = separate y-sort, player occlusion and blocking anchor **only**. In Godot use sorted parent pivot at foot and a Sprite2D child offset to exact x/y; never use foot to reposition bitmap. Sort static PAR in ascending footpoint y for same-image comparisons; note actor-front/behind means a single flat PAR cannot encode all dynamic cases, so Godot sprite sorting or explicit PAR layer selection remains engine authority.

### Rule 4 — Keep editable non-destructive PAR render chain
Keep `GROUND_ORIGINAL.png`, `PAR_BASE_RGBA.png`, `PAR_TONE_RGBA.png` or `PAR_RENDER_RGBA.png`, `PAR_FINAL_RGBA.png`, `GROUND_PAR_COMPOSITE.png`, and per-object tone outputs. Tone pass MUST NOT change original Ground bytes or modify original PAR_BASE. Match object luminance/hue/saturation to neighboring ground in restrained object-class-specific fashion; optionally add contact-shadow to a separate aligned shadow layer if later tested. Never blur/resize, shift alpha silhouette, alter tree trunks/edges or inject a background. Tone must be **alpha unchanged per pixel**, original sprite dimensions unchanged, RGB-only adjustments bounded. Use 2–3 reversible strengths + original control; log metrics and human visual comparison rather than claim that a lower color-distance means improved beauty. Avoid expensive PixelLab calls for tone correction.

### Rule 5 — QA and return conditions
(1) PixelLab original native dimensions, opaque GROUND SHA; (2) each object full alpha silhouette, full oncanvas x/y; (3) PAR transparent outside objects; (4) all allowed 17×13 walkable tiles reachable and root tiles blocked; (5) actual Godot PNG screenshots with real FS `$actor01` standing front/behind/road, all walkable test locations legal; (6) compare no-actor Godot vs depth-matched compositing: exact count, max per RGB-channel error and source of residual; (7) cold-archive extraction and native GPU rerender with per-file SHA; (8) optional native RPG Maker VX test in **isolated copied** project, never confuse with Godot. Do not claim VX/Visual/FORMA​L Seal PASS until independently tested. Keep zero charge if no PixelLab call.

## Evidence from A27
- Real PixelLab full Ground 544×416, SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`; 25 generations. Separate native transparent tree job 15 generations; total A27 40.
- Authentic Drive `Trees1.png` SHA256 `d99c8bcc495b68ae1dc61e39047fb66ff7666dafaa704198d44e522fd0199635`, 2 full trees used; separate PixelLab tree PNG candidate from earlier job clearly flagged.
- 12 objects; 4 full trees; 209/209 traversable grid cells; 8/8 actual Godot 4.7.2 frames. Cold ZIP `FS_STAGE16_A27_PIXEL_LAB_GROUND_USER_DRIVE_FULL_TREES_PRIVATE_20261101.zip` size 4,368,561 bytes, SHA `d64f1a9e77b82016c6b600b56472f5aaa2acb9b46f2fd649ba7a5c0b3f804701`, cold-native screenshots 8/8 SHA identical.
- Critical error corrected: initial scene draw mismatch 46,345 px caused by mixing sprite x/y and foot; corrected to 2,640 px. Further sorted compile R2 2,613 differing pixels of at most 1 RGB code value per channel (zero >1), a minor rounding difference; NOT zero pixel-exact.
- User explicitly requested continued PAR tone integration, avoid new token/generation expenditures. Stage A28 is tone pass proof, not replacement of A27.

## Non-regression / failure register
- Never offer full-scene image generation as a Ground/PAR deliverable.
- Never pretend a same-size PAR panorama segment is a complete tree.
- Never use unverified example tiles as final instead of indexed Drive full-size assets.
- Never claim exact zero differences if 1-channel rounding discrepancy exists.
- Never mark render-only overlap standing on blocked foot tiles as playable motion.
- Never publish rights-unverified binary art on public GitHub.
- Keep fail-closed `Formal Seal=NO` until Ground3 aesthetics, true occlusion, native VX gates pass.

## Handoff provenance
Previous: `experiments/route_b_25d_20261031_stage16/STAGE16_A27_DRIVE_SOURCE_FIRST_PIXELLAB_GROUND_PAR_HANDOFF_20261101.md`
Next: `experiments/route_b_25d_20261031_stage16/STAGE16_A28_PAR_TONE_RENDER_HANDOFF_20261101.md` when results exist.
