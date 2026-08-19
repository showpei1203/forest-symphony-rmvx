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
- **32x32 is the RMVX world-scale/player/tile reference, not a total canvas limit.** `544x416` is only a viewport reference. Large villages, castles, dungeons and parallax Master Scenes may be substantially larger while preserving 32px world-scale consistency.
- **Monsters are not limited to 32x32 pixels.**
- Parallax/Master Scene remains the art authority.
- For map authoring, preserve exact registration and export: `Master Scene + Ground-Only + All Non-Ground Objects`.
- **Ground-Only** contains true terrain/surfaces only: grass, dirt, stone road/floor, water surface and terrain base. It must remain visually coherent and should not show obvious object-removal scars.
- **All Non-Ground Objects is exhaustive.** It includes every building, wall, gate, tower, roof, tree, trunk, canopy, statue, fountain, fence, flowerbed structure, sign, stall, furniture, rock, crate, barrel and environmental prop, even if an object is not expected to cover the actor.
- Runtime `Par/Occlusion` is derived later from All Non-Ground Objects by Photoshop/Aseprite or an approved compiler/mask tool. Do not replace the complete upper-object layer with an AI-trimmed occlusion-only layer. Do not use crude horizontal slicing.
- Semantic depth remains useful: D1 root/ground-contact; D3 actor occluder; D4 canopy/high foliage.
- Derived map split layers should use true PNG alpha after cleanup. Chroma key is primarily for isolated generated source assets, not a substitute for final transparency.

## Layer-Split Quality Gate
A map split is still **DRAFT** unless all checks pass:
1. Master, Ground-Only and All Non-Ground Objects have identical dimensions and exact pixel registration.
2. Ground has no accidental upper objects, broken terrain seams or obvious removal scars/fake footprints unless intentionally part of the terrain.
3. All Non-Ground coverage is exhaustive. No statue, fountain, wall, gate, tower, roof, tree, landmark or small prop may be silently omitted.
4. Opaque objects have no accidental black holes, clipped chunks, broken alpha, chroma-key residue, colored fringe artifacts or unrelated ground fragments.
5. Recombining Ground-Only + All Non-Ground Objects closely reconstructs the Master Scene and exposes missing/extra objects immediately.
6. Structural correctness alone is insufficient; visually dirty splits cannot be called Approved or Runtime-ready.

## Required read order
`Shared Authority -> FS Precheck -> latest FS visual/asset benchmark -> confirm 32px world scale + required canvas -> generate/edit -> Layer-Split Quality Gate`

Version: 2026-08-19
