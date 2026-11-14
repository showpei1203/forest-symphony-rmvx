# FS Ground/PAR Source-First Production Authority v1.0

> **2026-11-14 使用者 v1.3 最高優先：已恢復並強制 Ground-first → 獨立完整 PAR → Godot 動態合成 → 1x 最終美術豐富度驗收。** 任何 2026-11-07 的「全圖 Master-first → source crop」均為舊實驗歷史，**不得用作新地圖正式產線**。請先讀 `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md` v1.3 的 0c；本頁保留可重用的尺寸、alpha/footpoint/碰撞/素材來源和冷驗證方法，但被 0c 覆寫的工序不再有效。

Date: 2026-11-01 | Adopted baseline: Stage16 A27 R2 | Status: ACTIVE PROCEDURE, not formal visual seal.

> **2026-11-07 新版指令補充：SOURCE-FIRST 的 SHA/ROI/Manifest/Alpha 是有效技術，但「必須先 Ground 再生成物件」已不適用目前 FS 新精靈村。** 新路徑是 Master-first（完整高品質 Master→AI mask/隱藏地表→Master RGB 分層）後仍依 Source-first 技術執行 Alpha、碰撞、footpoint、權利和原生 VX 驗證。所有必要保留文件/PNG/ZIP 必須存雲端；舊本機 workspace 為歷史，只准必要 runtime 的短期副本。[P0](../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)。

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

## 2026-11-01 User-approved extension — semantic original PAR generation (A30+)
The source-first rule is an evidence, style and provenance rule, **not** a prohibition on new original PAR art. Once the target style has been established, the generator MAY create full, independent transparent RGBA PAR objects to fit scene descriptions and semantics without being restricted to exact objects from the Drive asset catalog. Preserve source_type/provenance as DRIVE_SOURCE vs AI_GENERATED/PIXELLAB_NATIVE/PROGRAMMATIC, style reference and rights status. This does not permit full-scene flattening, clipping, Ground corruption, wrong collision/foot, unreversible alpha/tone changes, or passing a test without actual engine screenshots. Original A27 Ground remains SHA-locked, and A29 remains Visual PENDING / native VX BLOCKED / FormalSeal NO.

Binding detailed authority: [FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md](FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md).


## A32 user mandate — dedicated SHADOW / LIGHT ownership and crisp PAR silhouettes (2026-11-01)
Scene/environmental cast shadow, area shadow, bloom, lamp glow, day-night light and global light modulation MUST be separate SHADOW and LIGHT layers. They MUST NOT be baked into PAR as a false fix for alpha edge blur, nor merged into Ground. PAR exclusively owns object-intrinsic painted pixels, alpha geometry, Y-sorted occlusion and foot/collision metadata; intrinsic sprite texture color/shading (part of the artwork rather than an added scene light layer) must be distinguished from separable environmental illumination. Ground only owns continuous terrain and truly flush terrain textures. The engine compositor and manifest must assign every rendered effect to the right layer explicitly.

For original or source-derived PAR, especially FS A32 top two broadleaf canopies: use lower object trees as a pixel-step contour reference; trim soft alpha fringe and low-opacity stray leaves in isolated RGBA, maintain full tree canvas, crown/trunk/root, foot, 32px collision and native front/behind visual QA. Alpha changes are allowed solely when visually justified by edge cleanup; do NOT claim alpha-identical when it was intentionally sharpened. Never use Gaussian blur / generic full-scene sharpening / fake dark outside silhouette or shadow to hide an unclear tree outline.

**NEXT USER-ORDERED STAGE AFTER A32: A33 must work on the too-soft native PixelLab GROUND edges vs reference Ground3, not keep polishing PAR.** Original A27 Ground SHA256 35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce stays locked in A32; A33 Ground candidate receives separate new filename and digest, with fresh native VX / Godot revalidation. Reference [A32 detailed Handoff](../experiments/route_b_25d_20261031_stage16/STAGE16_A32_PAR_TREE_CANOPY_PIXEL_EDGE_NATIVE_VX_HANDOFF_20261101.md) and [A33 Ground kickoff](../experiments/route_b_25d_20261031_stage16/STAGE16_A33_GROUND_PIXEL_EDGE_REWORK_KICKOFF_20261101.md). Formal Seal NO.
