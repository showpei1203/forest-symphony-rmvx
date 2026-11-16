# FS A47 | Failure Log
- A65 older technique cut/shifted rigid horizontal scanlines, producing disconnected-looking torso and legs. A47 uses blended continuous 2D coordinate deformation instead.
- R1 technically failed in frame F04: detached 10-pixel Alpha Body component. R2 similarly failed in F02. Both rejected independently of waist stripe gate (which still passed), proving two different validators are needed.
- R3 holds a single connected 8-neighbor Body alpha component in all 12 frames and stable planted foot pixels; F6 sword grip/tip anchors are preserved.
- 18-joint A47 design guide manually measured/derived from A62/A46 and A57 naming, not from PixelLab API. A47 generation was offline; no paid provider calls.
- More torso changed pixels and successful GPU screenshot comparison do not prove true artistic naturalness. Overall ART HOLD.
- Isolated practice-target HP and Godot playback PASS, but formal FS migrated combat ATB NOT RUN.
- No overwrite to A42-A46, GitHub main, map/migration branches or E: RMVX original. P0 cloud-only output, temporary native QA files deleted.
- A47-QA09: First clean archive extraction successfully regenerated sprites and selected R3 but promotion script was not idempotent after A47 runtime paths were already rewritten. Cold validation intentionally FAIL. Promoter now supports both fresh A46 and already-A47 states and returns original source SHA; original failed ZIP is kept as negative internal candidate, new distinct COLDPASS archive will be revalidated from scratch.
