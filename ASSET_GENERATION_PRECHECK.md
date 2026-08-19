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
- For map authoring, preserve exact registration and export: `Master Scene + Ground + complete PAR`.
- **Ground** contains only true ground/terrain surfaces, floor/terrain tiles, flowers and grass.
- **PAR is everything else.** Buildings, walls, gates, towers, roofs, trees, trunks, canopies, bushes, rocks, statues, fountains, fences, flowerbed borders/structures, signs, stalls, furniture, bridges, structural stairs/steps, lamps, crates, barrels and every other non-Ground object must be in PAR.
- Occlusion is **not** the criterion for PAR membership. The user may later cut actor-covering regions from the complete PAR in Photoshop/Aseprite.
- Semantic depth remains useful only as metadata; it must never remove a non-Ground object from PAR.
- Derived map split layers should use true PNG alpha after cleanup. Chroma key is primarily for isolated generated source assets, not a substitute for final transparency.

## Layer-Split Quality Gate
A map split is still **DRAFT** unless all checks pass:
1. Master, Ground and PAR have identical dimensions and exact pixel registration.
2. Ground contains only true ground/terrain surfaces, floor/terrain tiles, flowers and grass, with no accidental non-Ground object or broken terrain seam.
3. PAR is exhaustive: every object not classified as Ground/floor-tile/flower/grass must be present. No statue, fountain, wall, gate, tower, roof, tree, bush, rock, landmark or small prop may be silently omitted.
4. Opaque objects have no accidental black holes, clipped chunks, broken alpha, chroma-key residue, colored fringe artifacts or unrelated ground fragments.
5. **Recomposition authority: `MASTER ≈ GROUND + COMPLETE PAR`.** Missing/extra objects must become immediately detectable.
6. Structural correctness alone is insufficient; visually dirty splits cannot be called Approved or Runtime-ready.

## Grounded SAM2 semantic audit authority
- Grounded SAM2 is a **QA / missing-object / candidate-mask assistant**, not final art or layer authority. A raw union mask must never be accepted as `Ground`, `PAR`, `Collision`, or Runtime truth by itself.
- Prefer category batches instead of one large mixed prompt. Default FS batches: Architecture = castle/building/wall/gate/tower/roof; Landmarks = statue/fountain/monument; Nature = tree/bush/flower bed/rock; Small Props = sign/lamp/crate/barrel/market stall/windmill.
- Thresholds are tunable benchmark profiles, not universal constants. Initial guidance: Architecture box≈0.28/text≈0.25; Landmarks box≈0.22/text≈0.22; Small Props box≈0.35/text≈0.28.
- Apply an oversized-bbox sanity filter before unioning masks. Normally localized classes covering roughly >20–25% of the whole canvas are suspicious by default and should be excluded/flagged unless human review accepts them.
- Use semantic aliases when recall is weak: `statue / monument / sculpture`, `gate / gatehouse / city gate / castle gate`, `building / house / shop / town building`.
- Compare SAM2 detections/per-class masks against both the Master Scene and the complete PAR to find probable omissions or false positives. A SAM2 miss does not authorize deleting an object; a SAM2 hit does not authorize putting it in a final layer without normal QA.
- SAM2-assisted outputs remain **DRAFT** until the normal Layer-Split Quality Gate and visual acceptance pass.
- Local SAM2 workers should follow Background Execution Authority: run on demand, process jobs in the background, and release VRAM after completion rather than permanently occupying the GPU.
- **Dense-map refinement:** bbox filtering alone is insufficient. Add post-SAM mask-canvas coverage sanity limits, and use overlapping tiled detection + global-coordinate remap + concept-level NMS for local objects when full-scene recall is weak or masks are implausibly broad.

## Binary split override
This rule supersedes older wording that treated PAR as only actor-occluding material:
`GROUND = true ground/terrain surfaces + floor/terrain tiles + flowers + grass`
`PAR = EVERYTHING ELSE`
Do not use perceived height, collision, occlusion, landmark importance, or SAM2 class as a reason to omit a non-Ground object from PAR.

## Required read order
`Shared Authority -> FS Precheck -> latest FS visual/asset benchmark -> confirm 32px world scale + required canvas -> generate/edit -> optional SAM2 semantic audit -> Layer-Split Quality Gate`

Version: 2026-08-19
