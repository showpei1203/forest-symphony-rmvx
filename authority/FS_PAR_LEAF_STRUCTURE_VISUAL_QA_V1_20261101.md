# Forest Symphony PAR Leaf-Structure Visual QA — Fail-Closed v1.0
Effective: 2026-11-01; triggered by user rejection of A31/A32 upper broadleaf trees. Status ACTIVE. Does not alter sealed production builds.

## Why this exists
A31 increased foliage contrast, A32 hardened alpha/outer silhouette, and 24/24 native VX cases remained technically valid. Yet user explicitly rejected upper canopy because the leaves looked like an undifferentiated green mass, unlike the two lower trees whose small leaves, angled striations, clustered leaf fans and darker between-clump seams were perceptually readable. **Alpha = 0/255 and pixel-edge neatness are NOT proof of internal leaf-structure quality.**

## Mandatory four-axis visual acceptance, separately reported
1. Outer silhouette: intact, full transparent canvas, clean 1px pixel edge, no chopped crown or fake matte. Test source bounds BEFORE padding.
2. Internal leaf shapes: independently readable pointed leaflets / short angled strokes, appropriately varied orientation and scale, authentic native pixel width; not just green stippling, higher RGB contrast, 1px noise, diagonal stripes by themselves, or plain bright overlay.
3. Canopy composition: recognizable layered foliage groups with nonuniform grouping, dark gaps/occlusions between distinct leaf masses and directional rhythm; avoid mechanical evenly spaced horizontal "roof-shingle" shelves, tiling/pasted patches and uniform random crosshatching.
4. Ground+PAR at ACTUAL 544×416 / VX native 1x as well as 2x nearest neighbor crops: upper canopy must remain perceptually separate from grassy Ground and visually relate to lower two trees. Show full scene and individual RGBA tree side by side.

Reference hierarchy: use the REAL lower two independent tree sprites `A30_OBJ_pixel_lab_tree_southwest.png` and `A30_OBJ_pixel_lab_tree_southeast.png` as morphology and color-shape reference. Morphology matters more than color match. Note that southwest tree has semi-transparent foliage edges while southeast has binary alpha; choose based on relevant feature, not assume both have identical alpha.

## Engineering gates after artistic candidate, not substitutes
- Ground original A27 SHA `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce` unchanged in A32B.
- Only two upper PAR sprite native RGBA content changed; never modify other ten sprites, foot, map ID, collision, scripts, road, lighting/shadow ownership without separate authorization. Regenerate transparent Par50 exactly from independent assets; validate pixel equality.
- SHADOW/LIGHT are independent scene layers for environmental lighting & cast shadow; adding interior original leaf-color bands to object sprite is *object-intrinsic foliage texture*, not permission to bake drop shadows, glows, bloom or area lighting in PAR.
- True RMVX native Game.exe screenshot and player front/behind/partly occluded, open road and trunk blockage; screenshot via RGSS Player HWND, not synthesized hero or screenshot from desktop foreground.
- Cold separate copy SHA + real native startup; Godot fresh validation separately. Old Godot A29 PASS cannot be silently counted as A32B replay.
- Only the user can approve aesthetic suitability. Formal Seal stays NO when art not accepted or production/test-harness issue unresolved.

## A32B experiment rejection criteria and durable failure lessons
- F31: A31 foliage recolor or tone alone: change to tint, not leaf shape. REJECT.
- F32: A32 canopy alpha threshold + outer dark contour: structurally no new leaf motif. REJECT as artistic pass, retain as engineering branch.
- F32B-01: sparse procedural strokes only: density/structure may remain too fine; must inspect at 1x.
- F32B-02: authentic lower-tree pixel sample patch transfer: avoid tiled horizontal smear/obvious collage seams; do not mistake source authenticity for visually coherent composition.
- F32B-03: quantized leaf bars painted as regular horizontal tiers: roof/thatch appearance, not organic foliage. Reject despite high contrast.
- F32B-04: heavy hybrid sample+line transfer: flattened/dark canopy losing separation and natural clustering. Reject.
- Selected A32B prototype for private review: **structured_390** using original upper tree lobe geometry, short angular leaflets with source lower-right leaf-palette medians and irregular partial lobe seams, alpha exact; final art acceptance PENDING. If user finds it insufficient, edit morphology again, not strength of global sharpening.

## Next-stage constraint
User explicitly ordered: only after A32B visual acceptance, A33 work must start on PixelLab Ground vs Ground3 reference, especially edge softness. A33 source audit is prepared but Ground MUST remain unchanged during A32B. No Ground auto-edit triggered by A32B engineering PASS.
