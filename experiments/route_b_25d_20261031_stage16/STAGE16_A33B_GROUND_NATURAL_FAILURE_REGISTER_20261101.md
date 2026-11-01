# FS Stage16 A33B Ground Natural-Terrain — FAILURE REGISTER
Date: 2026-11-01. User ordered further revision after A33 R5 remained visibly far from actual Ground3.

## Historical failures to preserve
- A33 source identity ERROR: `Overlays/ground3.png` is a dark/shadow map, not the official art reference; use `Graphics/Parallaxes/ground3.png` and original A10 grass/A06 sand source crops, record SHA.
- A33 R1–R3 quilt checkerboard: source tiles stitched with visible square seams, failed visual quality. Real material references alone do not ensure natural ground.
- A33 R5 mirrored 64/48px source textures: native engineering passed, yet original road edges appeared clipped/cookie-cutter, grass too evenly textured with periodic mirror rhythm, ground flora sparse relative to Ground3. Never equate 'cleaner' with 'matching Ground3'.
- A33B R7 candidate: cleaner nonrepeating-appearing grain with 171 new native blade strokes; open field still sparse, not selected.
- A33B R9 candidate: 456 blade strokes and more obvious green/dirt invaders can clutter the path; held as stronger comparison, not selected.
- **A33B R8**: selected *engineering* candidate with 345 short blade strokes, preserved original 1885 bright flora pixels, irregular path fringes, multi-scale NEAREST texture coordinate displacement; visual quality **PENDING user signoff**. If rejected, iterate material macro clusters and source tile diversity, not Gaussian blur or same recolor.

## Prevention and gate upgrade
1. At 1x, look at full Ground+approved PAR, ensure road recognizable and grass not flat; at nearest 2x/4x, inspect 4 distinct road/grass edges and meadow patches. Do NOT rely on engineered source count or gradient alone.
2. Protect A32B accepted PAR plus existing collision, overlays, foot and `Data/Map050.rvdata`, `Scripts.rvdata`; hash-check every actual clone and cold copy.
3. Ground should be pixel-perfect native 544x416 in the technique benchmark; authentic Ground3 village size 1280x928 remains aspirational later. Do not mistake a successful benchmark for full reference fidelity.
4. Strictly no environmental light, glow, vignette, drop/cast shadows in Ground or PAR; those belong in SHADOW/LIGHT scene layers.
5. Actual RPG Maker VX case capture must use RGSS HWND, not desktop foreground; no forced teleport counted as legal movement.
6. Actual Godot GPU no-actor compared with independent image composition with numeric delta measured. Tolerance<=1 is not exact zero.
7. Stage A33B original source R5 and the immutable A27 Ground must remain available and SHA unchanged. New ground R8 gets new SHA.
8. User art approval remains the only gate for aesthetic promotion; real VX/Godot technical PASS is NOT aesthetic PASS, Formal Seal stays NO.
