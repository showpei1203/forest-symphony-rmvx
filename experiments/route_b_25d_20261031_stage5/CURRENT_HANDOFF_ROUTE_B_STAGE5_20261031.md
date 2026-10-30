# FS Route B Stage5 | Native Grass Art + True 32x32 Tree Contact Split | 2026-10-31

## Authority and sealed baseline
R17 DIRECT GROUND PAR AUTHORITY controls this work. Native separate Ground RGB and PAR transparent RGBA, same 544x416 camera/world coordinates. The user alone will composite final Ground and manage VX passability. Never reverse-cut from full master. Do not modify existing sealed VX map, scripts, collision, K4, Stage3, or Stage4 baselines.

## Actually executed
1. Forked Stage4 into E:\\FS_ROUTE_B_STAGE5_GROUND_TREE_20261031 and used the real Godot 4.7.2 rendering executable on RX 6700 XT.
2. Built a first-class ground-author source author_ground_stage5.py -> assets/terrain_stage5.png (1024x1024) with lower-amplitude biome color/noise plus planted hard-edged clustered grasses, wildflower groups, walkway edge vegetation, independent ground shadows. Ground source never includes PAR objects.
3. First Stage5A variant used much too many triangular grass clumps, retained as assets/terrain_stage5_dense_variant.png and out/STAGE5A_DENSE_COMPOSITE.png as ART FAIL negative example.
4. Second Stage5B variant reduced tuft density and softened color contrast while retaining genuine native ground authoring; output used for current candidate.
5. Implemented real native 3D model split for trees: each Nature Kit GLB tree is instantiated twice in EXACT same world transform. A world-space height clipping shader with uniform split height 0.56 renders the lower trunk/roots into exclusive contact layer 4 (part of Ground only) and upper trunk/canopy into PAR layer 2. This is not a post-crop of a completed image.
6. Added fourth native TREE_CONTACT_MASK.png RGBA source-layer capture and independent audit_tree_contact.py using the actual captured alpha mask.
7. Iterated cutoff, tree sizes and camera/world positions until both rendered contact stumps fit inside ONE correct 32x32 screen tile each. Preserved upper 3D geometry in PAR.
8. Independent Ground RGB 544x416, PAR RGBA 544x416, COMPOSITE_PREVIEW.png, SCENE_FULL.png and QA_4PANEL.png all actually rendered by Godot, with QA reports.
9. The 214-node FS_Elf_Cottage.tscn remains reused from Stage3, still art HOLD.

## Measured results on Stage5B final
Ground: RGB 544x416, unique RGB=3057.
PAR: RGBA 544x416, alpha=0 pixels 176,398; alpha>0 pixels 49,906; no nontransparent border.
Tree contact mask: native RGBA 544x416, alpha-zero 225,624, nonzero 680.
WEST contact rect x78..92,y134..158, width15,height25, 291 pixels; all in 32px grid tile (2,4) => PASS.
EAST contact rect x449..478,y130..159, width30,height30, 389 pixels; all in 32px grid tile (14,4) => PASS.
A native Ground+PAR composite vs independent full 3D render = 2667 different pixels / 226,304 = ~1.179%, RGB MAE=0.05396, maximum channel error=65. Pixel-exact = FAIL. Does not affect finding that both tree contacts fit a tile.
Visual: Stage5B less blurry/less spike-dense than Stage4 and Stage5A, but still low-poly tiny cottage+cartoon trees not the user's high fidelity 2D elven-village reference. GROUND_ART=FAIL, PAR_ART=FAIL. User approval has not been granted. No Formal Seal.

## Source/provenance
Nature GLBs source: Kenney Nature Kit CC0. Fantasy/house from previous standalone Stage3 3D prefab and code; no protected source image copied to GitHub. Project README/code sources include explicit shaders, masks, terrain authoring and QA. Original FS asset Ground3 comparison is a *target*, NOT a proven art match.
The 32px fitting applies to this viewport/camera and only these two trees. World transform, resolution, rotation or scale changes demand regeneration + re-verification. Do not extrapolate blindly to 1280x928 or arbitrary tree presets.

## Next actions / ordering
1. Test character front/behind the canopy & junction before production; retain the Ground-contained single-tile base.
2. Source truly high-quality 2D ground artistic materials consistent with ground3; stop using procedural foliage as the entire art source.
3. Upgrade 3D cottage roofing and trees' low-poly silhouette; test coherent, non-smudged 1x native sprite projection.
4. Independently investigate the remaining 2,667-pixel 3D-full vs two-layer mismatch. Avoid imposing full-render exact match as substitute for user art approval.
5. Build larger village ONLY after the single map art gate has actually passed, which it has not.

## Gates
GODOT_REAL_RENDER = PASS
GROUND_NATIVE_RGB = PASS
PAR_NATIVE_RGBA = PASS
TREE_BOTTOM_NATIVE_SOURCE = PASS_TWO_TREES
TREE_BOTTOM_ONE_TILE_32 = PASS_TWO_TREES
GROUND/PAR_SIZE_ALPHA_BORDER = PASS
COMPOSITE_PIXEL_EXACT = FAIL_2667
HIGH_FIDELITY_ART = FAIL
VX_ACTOR_OCCLUSION = NOT_RUN
FS_PRODUCTION_INTEGRATION = NOT_RUN
FORMAL_SEAL = NO