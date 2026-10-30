# Forest Symphony Route B Stage4 | Native Ground Texture + 1x / 2x Pixel Style A-B-C | 2026-10-31

## Governing Authority / scope
R17_DIRECT_GROUND_PAR_AUTHORITY: true separately-authored native Ground and transparent PAR with identical 544x416 world coordinates; user will separately overlay PAR into their own final full Ground and set VX passability personally. NO source extraction from a completed master, NO FS sealed content edits. Stage3 214-node FS_Elf_Cottage.tscn is retained unchanged. New research folder is separate.

## Actual work
- Reused verified Stage3 214-node editable cottage prefab and Godot 4.7.2 capture scripts.
- Built a NEW 1024x1024, independently authored textured terrain source (assets/terrain_stage4.png) from deterministic seed and native landscape masks. It includes natural multiscale color variation, a curved dirt path in world coordinates, organized flower/grass biomes, leaf litter, irregular pebbles and soft cottage/tree contact shadows.
- Loaded ground texture as native Godot PlaneMesh material with nearest filter; rendered A_NATIVE Ground RGB and PAR RGBA by independent camera cull-mask in the SAME 3D scene.
- Preserved native source geometry and authored texture; no reverse Ground/PAR segmentation or 2D completed-master extraction.
- Applied separately to both exported native layers three reproducible style probes (style_abc.py): A_NATIVE original 544x416, B_PIXEL_2X 272x208 nearest downscale -> 544x416 nearest upscale, C_PALETTE_1X full resolution 5-bit/channel posterization preserving original PAR alpha mask. These are non-destructive derived art tests, not replacement of original Ground/PAR.
- Generated side-by-side PNG and QA JSON comparing actual PAR mask preservation.

## Real Godot render / image QA
Engine: Godot 4.7.2 stable / OpenGL 3.3 / AMD Radeon RX 6700 XT on user's desktop.
A_NATIVE dimensions: 544x416. Ground is native RGB, PAR native RGBA; PAR transparent pixel count=175467 and nonzero alpha=50837, canvas-edge nonzero=0.
Ground UNIQUE_RGB = 5751 vs Stage3 Ground 16 (more nuanced, but texture currently visually too soft).
A native alpha composite vs separate full-scene render: RGB MAE 0.05923, differing pixels 2719 / 226304 (~1.201%), max channel difference 61; exact pixel pairing still FAIL.
A Ground unique colors=5751; PAR opaque silhouette unchanged.
B nearest 2x: Ground unique colors=4259, PAR mask mismatched pixels=1235 compared with A, PAR original coverage loss fraction ~0.01043; pixel-crisp but fails PAR 1px completeness authority -> REJECT.
C fixed full-resolution 5bits/channel: Ground unique colors=187, PAR mask mismatched pixels=0 compared with A, alpha preserved exactly -> SOURCE-SAFE STYLE CANDIDATE. Does not prove reference art quality.
All three C/A/B composites derive from independent original Ground and transparent PAR, never a full-scene crop.

## Visual judgment
- A 3D textured terrain materially less flat than Stage3 but still broad blurred noise patches; geometry cottage and low-poly trees still lack quality close to original Ground3 and elven-village references. ART FAIL / HOLD.
- B post-pixelation destroys detailed PAR outline: Technical REJECT.
- C preserves silhouette and can be compared, but palette limitation is NOT a substitute for high-density artist-quality source. ART FAIL / HOLD.
- Tree base 32x32 grounding remains incomplete: old GLB tree trunk is PAR and cannot yet be considered a formally split tree source. Do not claim G-GROUND tree-foot pass.
- 2D authoritative Final Seal, VX character occlusion and passability remain UNTESTED/UNMODIFIED.

## Next measured step
1. Preserve Stage4 C as style test, NOT formal output.
2. Replace soft procedural grass texture with artist-quality high-density source ground, maintaining truly native separate Ground/ground tree-contact marks (using reference only when licensing and source provenance permit).
3. Split each tree's 32px bottom trunk into Ground authoring while preserving canopy/trunk PAR and true alpha, then test with actor before/behind.
4. Improve cottage roof silhouette and material lighting, and resolve source full-vs-composite differences only after source art passes.
5. No larger map until one small crop art accepted.

## SEAL
RENDERED_REAL_GODOT=YES
SOURCE_2_5D_LAYERED=YES
GROUND_ALPHA=PASS
PAR_ALPHA=PASS
PAR_BORDER=PASS
PIXELATION_B=FAIL_MASK_LOSS
PALETTE_C=PASS_MASK_PRESERVATION
PAIR_PIXEL_EXACT=FAIL_2719
REFERENCE_ART_STYLE=FAIL
FORMAL_SEAL=NO