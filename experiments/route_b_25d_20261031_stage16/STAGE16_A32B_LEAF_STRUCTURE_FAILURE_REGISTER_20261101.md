# FS Stage16 A32B — FAILURE REGISTER & ART LESSONS 2026-11-01
Status: archived failed experiments, source preserved. This is not a list of successful art deliverables.

## User-reported root cause
At A31 upper trees were too similar in hue/texture to grassy Ground. A32 cleaned alpha perimeter to 0/255 in canopy (west 1541 partial pixels→0, east 1838→0) and showed technical pass, but **FAILED visually**: the tree interior still looked like green masses without readable individual angled leaf strokes or foliage group boundaries. Lower left/right trees were the user's target for leaf shapes and directional stripe grammar. Prior assistant conflated *outer silhouette* with *internal leaf morphology*. Repeated claims of "visually fixed" based only on color, exterior alpha and native VX engineering QA were not authorized.

## A32B test records and decisions
- Original current A32 real isolated tree sprites retained immutable, alpha and foot exact.
- V1 `leaflet_180`: sparse pixels, leaf strokes too fine at native size, NOT selected.
- V1 `structured_280`: better short slanted strokes and lobe seams but somewhat low density, NOT selected.
- V1 `structured_390`: relatively coherent independent canopy groups, angular short leaflets and visible groove texture, retained as **A32B private VISUAL CANDIDATE**, not yet approved by user.
- V2 `reference_70`, `reference_90`, `reference_90_small`: took real lower-tree foliage RGB source patches but reflow produced unnatural smeared/tiled strips and loss of distinct leaf group geometry, REJECTED.
- V3 `leaf_shelves_65`, `leaf_shelves_85`: forced horizontal stacked green bands; looked like a thatched roof, not directional organic foliage, REJECTED.
- V4 `hybrid_70_leaf280`, `hybrid_70_leaf390`, `hybrid_90_leaf280`: combined too much patch transfer and strokes, darkened/flattened silhouette, REJECTED.
- V4 implementation initially errored on a non-full-width NumPy boolean geometry mask; fixed with broadcast to object mask shape. No source image modified by failed script; recorded as engineering tooling failure.

## Reproducible failure-prevention gate for every subsequent sprite
1. Before modifying a user-rejected sprite, restate exact VISUAL language, compare reference at **native 1x** AND enlarged 2x nearest-neighbor: outer silhouette vs inner motifs are distinct tests.
2. For a canopy, require visible pointed leaf groups, short angled stripes, dark crevice separating independent clumps, natural nonperiodic orientation. Dense random short lines, long parallel shelves and tiled lower-sprite patches are explicit FAIL candidates.
3. Physically render original Ground+all true PAR sources; never show a flattering single isolated sprite only. Keep user-reviewed visual status PENDING even if the engine shows 24/24 PASS.
4. Original A27 Ground SHA stays `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`; only two upper trees may change in A32B. Keep alpha/size/foot exact; no environmental SHADOW/LIGHT baked into PAR.
5. Recompile PAR50 **from same 12 independent sprites** and verify pixel equality. Native RPG Maker VX must retest front/full/partial canopy, root obstacle and open road; isolated cold clone SHA. Prior Godot A29 PASS cannot be silently inherited as newly-tested A32B.
6. If art signoff fails, reopen canopy morphology. Do not "fix" by globally increasing green saturation or sharpening the entire screenshot.
7. After A32B user's visual acceptance, start A33 Ground material-border style correction; not before.

## Rejected prototype image files
Private stage has `A32B_PROTOTYPES_TREE_DETAIL.png`, `A32B_V2_REAL_REFERENCE_LEAF_STRUCTURE_COMPARISON.png`, `A32B_V3_SHELVED_LEAF_GROUP_COMPARE.png`, `A32B_V4_HYBRID_REAL_LEAVES_COMPARE.png`, associated candidate RGBA and generator scripts. Keep these FAIL variants for future learning; do not promote to active scene.
