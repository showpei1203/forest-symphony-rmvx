# A35 R5 Botanical Native | Failure Log | 2026-11-15

**ENGINE PASS · NAV PASS · GPU PASS · ROI PASS · ART HOLD**

1. **R4 undersized foliage**: R4 native source PNGs had conifer valid alpha heights cypress 93 px/fir 83/needle 76 despite logical canvases 172/185/179 tall. As a result, some actual village trees looked like tiny bushes. R5 increases actual heights to 141/144/137 while preserving exact original footpoints.
2. **First candidate rejected**: A procedural multi-source collage generated clipped/ghostly top-crown fragments and ugly rectangular overlap. User-facing engineering candidate was NOT built with it. Replaced with coherent single-source full trees + bounded needle reconstruction.
3. **Nearest-neighbor resizing caveat**: R5 conifers legitimately enlarge original source images with nearest-neighbor. They are no longer pure native 1x source painted pixels, although 1px texture is reconstructed. Actual R5 Godot screenshot still exhibits relatively blocky needles compared with richly detailed surrounding trees. **ART HOLD**. Avoid claiming all eight freshly hand-painted or no resizing.
4. **Baseline naming bug repaired**: Generated Godot GPU A/B test initially named its R4 source as `A35_R5_R3_BASELINE_NATIVE.png`. Corrected builder and test to `A35_R5_R4_BASELINE_NATIVE.png`, reran 4 real GPU captures Exit 0 and exact ROI. No stale misnamed frame used in final seal.
5. **Unchanged art protection**: Godot 4.7.2 verified 187 PAR position/source/collision constraints, 32 replaced/155 preserved. Actual FX-disabled GPU difference R4 versus R5 98,693 inside swapped-tree union, **zero outside**. Ground SHA remains `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`. All historical R2/R3/R4 scene files byte-identical.
6. **Actor occlusion scope**: At test point, rear 0 pixel change versus front 576, good for current fixed tree. Test does not establish visibility behind every tree crown. Need broad spatial sampling for later seal.
7. **Navigation scope**: 8/8 protected gates, 4/4 roads valid, no newly blocked protected road. Terrain beauty, future dynamic shadow occluders and actual 3D DOF remain unproven.
8. **Privacy and reproducibility**: Full 304-member native ZIP with 7 original GPU frames and logs stored private owner-only Drive, not in GitHub. SHA256 `cedd6e8162352f443eddca851a291ae08e97bc0aa71c32096fbde39e9eba1931`. Regenerate from owner-only R4 source and GitHub builder.

**Do not release ART.** Next refine botanical textures, then Ground3 and 2D light occlusion/HD-2D depth on separate reversible scenes.
