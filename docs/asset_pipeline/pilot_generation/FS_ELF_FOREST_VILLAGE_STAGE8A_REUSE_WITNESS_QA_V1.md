# FS Elf Forest Village — Stage 8A Reuse Witness QA v1

Date: 2026-08-22  
Project: Forest Symphony / RPG Maker VX  
Workflow: FS Map Asset Prompt Workflow v1  
Stage: 8A — Reuse Witness Preparation  
Status: PASS FOR ANIMATED WATER PILOT

## Scope
Prepare only the deterministic reuse witnesses locked by Stage 7. No AI repaint, inpainting, smoothing, non-integer resize, or style modification.

Drive pilot folder: `FS_ELF_FOREST_VILLAGE_STAGE8_PILOT`  
Folder ID: `1JZ6ePun5hVhSf67RAPIKVexairLPuj0p`

## Accepted terrain witnesses

### `FS_TERRAIN_FOREST_GRASS_A_PILOT_V1.png`
- Source: current `Graphics/System/TILEA2.png`.
- 96x96 diagnostic repeat from original 32x32 grass pixels.
- No resampling.
- Result: **ACCEPT**.

### `FS_TERRAIN_FOREST_DIRT_PATH_A_PILOT_V1.png`
- Source: current `Graphics/System/TILEA2.png`.
- Deterministic 32x32 center dirt fill assembled from original 16x16 interior autotile quarters, repeated 3x3 to 96x96.
- No resampling.
- Diagnostic center-fill witness only, not a replacement VX autotile sheet.
- Result: **ACCEPT**.

## Broadleaf witnesses

### `FS_VEG_FOREST_BROADLEAF_A_01_PILOT_V1.png`
- Source: locked Reference `TileE.png`.
- 64x64.
- Crop + deterministic alpha threshold only.
- Hard alpha `{0,255}`.
- Result: **ACCEPT_WITH_SCOPE_LIMIT**.

### `FS_VEG_FOREST_BROADLEAF_A_02_PILOT_V1.png`
- Source: locked Reference `TileE.png`.
- 61x64.
- Crop + deterministic alpha threshold only.
- Hard alpha `{0,255}`.
- Result: **ACCEPT_WITH_SCOPE_LIMIT**.

Scope limit: these are short ~2-tile broadleaf witnesses for pixel-density, palette and relative architecture-scale comparison. They are not the complete production broadleaf family and do not replace the later taller common-tree target.

## Ordinary house scale witness

### `FS_MAP_ELF_VILLAGE_ARCH_HOUSE_SMALL_A_WITNESS_V1.png`
- Source: locked Reference `TileB.png` only.
- 96x160 = 3x5 RMVX tiles.
- Deterministic composition of native-pixel roof, wall, door and window components.
- No AI and no resize.
- Binary-alpha normalization only.
- Result: **ACCEPT AS SCALE WITNESS**.

This file is a scale/pixel-language witness, not final production house art.

## Montage
`FS_ELF_FOREST_VILLAGE_STAGE8A_WITNESS_MONTAGE_V1.png` shows the five witnesses together for quick visual comparison.

## Stage 8A gate
PASS because:
- current grass/dirt source pixels are preserved;
- no interpolation/resampling was introduced;
- tree/house hard assets use binary alpha;
- house witness lands exactly inside the locked 3–5 tile width / 3–5 tile visual-height small-house envelope;
- broadleaf scope limitation is explicit;
- the set is sufficient to evaluate new water texture density and treehouse scale.

NEXT: Stage 8B — generate `TERRAIN-WATER-STREAM-A` as 3 animation-family candidates. Each candidate must contain coherent A/B/C phases, pass per-phase spatial seamless QA, then pass temporal A→B→C→A loop QA. Final VX A1 packing remains deterministic postprocess after acceptance.
