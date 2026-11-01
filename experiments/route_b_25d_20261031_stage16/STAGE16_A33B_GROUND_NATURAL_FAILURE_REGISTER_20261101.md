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


## Verified A33B private Google Drive delivery (2026-11-01, metadata readback)
- **Native RPG Maker VX R5 vs R8 actual before/after 544×2950**, includes four 2x material-edge comparisons: https://drive.google.com/file/d/1NwNvc9D7rxksKuYsDCL33u0zn3N96-Pl/view
- **New A33B R8 Meadow opaque Ground PNG 544×416**, SHA256 `dba346a620a15d7ddd9995273bac55c977c5e179c0bbcb8f9f986dd23e1c84fe`: https://drive.google.com/file/d/1VLtESxsUX6MX_KUmuPwLGUF6JIfDA1Zc/view
- **Four-way real Ground+original A32B PAR composite** R5/R7/R8/R9: https://drive.google.com/file/d/1I8krkesxZiSihGPoFt3anVGNNQtYj37q/view
- **Enlarged material edge comparisons**: https://drive.google.com/file/d/17DsaU7ypIIowW6l2mqyMJ94O97iPfQnb/view
- Alternative ground R7 original pixel source: https://drive.google.com/file/d/1nEns5BU2m4xJteofz8zgOT2BMn2-IDmY/view
- Alternative R9 stronger meadow: https://drive.google.com/file/d/11GUMSGblYMOY8G6cfzOOPn6sk1W0qfwd/view
- Ground3 historical reference overview (image kept PRIVATE): https://drive.google.com/file/d/17rVkH9bgjB_QqOHOjFJKy8EGLnwvV-WP/view
- **A33B private ZIP**, 100 entries, 24,868,685 bytes; local ZIP CRC, every member SHA256 and separate cold extraction SHA verified PASS; Drive filename and byte size metadata read back. Remote ZIP SHA download NOT additionally claimed: https://drive.google.com/file/d/1_iZeDj64FWu6WgfPSfcni4ZDZOUkpXDg/view
- Actual native VX QA: https://drive.google.com/file/d/1SMFeGeziOF5FC6fLDD3ir-tDJH9-cNmN/view
- Actual GPU pixel QA (2946 coords diff maximum RGB1): https://drive.google.com/file/d/1nSWwzan7mW3I2AE6ZB5cM7M-PYlS0P7H/view
- Native cold 3395 SHA file and startup QA: https://drive.google.com/file/d/1TwT48eO00Gu0ifiZ13RzxpRsLcLHew17/view
- Permanent native Ground terrain naturalness gate: https://drive.google.com/file/d/11b826lJSIGEVv4LQhUJGTrLY0LB7VIwj/view
- A33B failure register: https://drive.google.com/file/d/1IuKCughUMI0eLYjuEyuTX5-WOtf5ZdAU/view
- A33B detailed Handoff: https://drive.google.com/file/d/1rETS6bVxVF-3B9waB4ggYNXP7LyALGAo/view
- Latest A33B CURRENT_HANDOFF: https://drive.google.com/file/d/1XLVtiYnpZNtXpGgjGjcXD34Bb7MY95rE/view
- Private stage folder: https://drive.google.com/drive/folders/1J5Z8wwV5lCHxS9r8MJlUT1orXo0Ps_6V

**A32B art approved, A33B R8 engineering PASS but Ground art user signoff PENDING; Formal Seal NO.**
