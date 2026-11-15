# FS A35 R1 | Failure Log | 2026-11-15

## Status
ENGINE PASS, NAV PASS, native framebuffer ROI PASS, ART HOLD.

## Recurrent failures avoided
- Previous A34 source-file/SHA mismatch: every appended tree now binds its original private PNG file hash; Godot verifies each on real scene startup.
- Previous incomplete ZIP: original sealed A32/A33/A34 scenes and original Ground bytes remain present; full ZIP CRC and SHA checked.
- Previous illustration misrepresented as runtime: A35 GPU-native screenshots clearly named `*_NATIVE.png`; Pillow A/B is labeled a composite.
- Previous Y-sort regressions: native back/front actor captures have 0/554 changed pixels; physical tree roots are independent 22x12 colliders.
- New tree roots could block village movement: native 16-pixel grid checks 4/4 established routes, 0 newly blocked protected road cells.

## Remaining failures / limits (not silently PASS)
- ART HOLD: new forest uses 15 pre-existing tree source families, so visible repetition and lack of new true tree silhouettes remain.
- Artist's final 1x assessment and exact biome transitions have not been accepted.
- Ground is the source-locked A34 pixel art, not a newly repainted 1x Ground3.
- A35 R1 addresses forest edge grouping only; new house interiors, quests, NPC events and terrain cliff masks are owned elsewhere or deferred.

## Next correction
A35 R2 should create several genuinely distinct full RGBA species assets (no one-shot giant crop or blurred downsampling), replace repetitive trees at full native size and maintain 1x Godot A/B, 16px physical navigation and SHA/source-locked PAR.
