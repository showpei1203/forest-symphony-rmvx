# Forest Symphony | Legacy terrain PAR must be derived from original FS source, not guessed
Date 2026-11-02. **ACTIVE BLOCKER ON TERRAIN OCCLUSION; NOT BLOCKER ON FLAT FOREST OR ELF VILLAGE.**

## Decision
A35/A35B/A35C 217 cliff-color mask, all-empty PAR, and guessed 1–2 top-lip patterns have NOT demonstrated the original FS gameplay algorithm. **Freeze terrain-par elevation/overhang attempts until original FS assets + RGSS scripts + actual foot positions are analyzed.** Never assume a fixed one/two tile band covers every cliff; user explicitly says current interpretation is incomplete.

## Grounded original project inventory (actual user's remote machine)
Original project root: `E:/遊戲專案開發/三大項目現行專案/FS project/`
- True scene images `Graphics/Parallaxes/groundN.png`.
- Separate `Overlays/groundN.png` images have identical dimensions but in many cases are **not** the true scene base (they can be effect/overlay material). Do not blindly use them for ground/par comparison.
- `Overlays/parN.png` scene-matched masks.
- Originals `ground3/par3` 1280×928: par3 nontransparent alpha 13.8563%; its alpha>=200 RGB matches true `Graphics/Parallaxes/ground3.png` in ~97.568% sampled pixels. The alternate `Overlays/ground3.png` matches only ~1.5%.
- Originals `ground8/par8` 1280×928: par8 alpha coverage 24.2858%, alpha>=200 RGB exact 100% match to true `Graphics/Parallaxes/ground8.png`, but only ~0.3% to alternate `Overlays/ground8.png`.
- Discovery scan located 14 actual Ground+PAR matched original map samples, including ground1/2/3/4/5/6/7/8/9/10/12/22/23/46. Important: paired source pixel match is NOT proof which cell should be occluded in runtime.
- User-mentioned `Paraxell` directory spelling/meaning NOT confirmed in these local scans, while `Graphics/Parallaxes` was found. Search exact repo/Drive/FS source project references to `Paraxell` and use all applicable layers, without guessing identity.

## Mandatory unresolved work items before any new terrain PAR
1. Inventory all FS original `Graphics/Parallaxes`, `Overlays` and folder named `Paraxell` if present. SHA and dimensions per same-number file; map variant animation frames separately.
2. Build source **before/after alpha overlay and 32×32 aligned 544×416 screenshot contact sheet** for representative ground3 / ground8 and additional canyon samples ground22/23/46. Analyze masks tile by tile, classifying object canopy, cliff top, cliff face, floor/front edge, water and effect layers.
3. Inspect original FS RGSS2 scripts for par load/z/layer names, map region maps and opacity behavior; distinguish `ground`, `PAR`, `SHADOW`, `LIGHT`, `Parallaxes` and original `Paraxell`.
4. Derive tested **actor foot tile -> expected occluder pixels** by actual native RPG Maker VX screen captures for opposite-facing elevations, rear/forward edges, stairs, and cave. Do not infer solely from color contours or number of pixels.
5. Only when a rule explains the original source triplets and gameplay without false overdraw, create an isolated reproducible terrain PAR; full visual/QA/handoff; independent user signoff.

## Active priority / freeze
**A36 onward: FLAT FOREST / ELF VILLAGE (zero terrain elevation/cliff occlusion).** Work on high quality 1280×928+ source Ground, natural grass and soil, standalone trees/foliage/buildings PAR, 32 grid collisions, native VX tests, double-engine QA. Keep previous terrain stages immutable as evidence, but no new cliff PAR in active map. Separate SHADOW/LIGHT. No PixelLab required by default.
