# Forest Symphony — Asset Generation Precheck

**Mandatory before every image generation or image edit.**

1. Read the shared Google Drive authority: `SHARED_GAME_ASSET_GENERATION_AUTHORITY` (Drive file ID `1TF4wGLqwiALO-IJ_1R-5m9J7fGS-47tKmNi5yH_LMdc`).
2. Read the Forest Symphony Drive authority file `ASSET_GENERATION_PRECHECK_FS` in `Forest Symphony/00_Project_Authority`.
3. Identify asset mode: Runtime Asset vs Master Scene / Parallax Concept.
4. Apply the latest FS Style DNA / accepted benchmark / sealed visual decisions before generating.

## Inherited rules
- Runtime isolated assets: prefer chroma-key `#FF00FF` or `#00FF00`.
- Runtime pixel assets: `flat colors`, `no anti-aliasing`, `crisp edges`, approved limited palette.
- Perspective: `top-down 3/4 RPG perspective (Zelda-style)` or `orthographic top-down view`, unless later FS authority says otherwise.
- RMVX environment readability uses a 32x32 player/tile reference.
- **Monsters are not limited to 32x32 pixels.**
- Parallax depth remains semantic: D1 ground/root; D3 actor occluder; D4 canopy/high foliage. Do not use crude horizontal slicing.
- Master Scenes are not Runtime Assets; they must be engineered into Ground / Par / collision / metadata and final RMVX dimensions.

## Required read order
`Shared Authority -> FS Precheck -> latest FS visual/asset benchmark -> generate/edit image`

Version: 2026-08-19
