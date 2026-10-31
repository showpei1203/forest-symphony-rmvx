# Stage16 A24 — Failure Register / Rules
2026-11-01, zero new PixelLab calls. Formal Seal NO.

F24-01: Initial scene generator attempted Image.fromarray(RGB, mode='RGBA'), causing Pillow ValueError 'buffer not large enough'. Fixed by Image.fromarray(RGB,'RGB').convert('RGBA'), rerun PASS. Do not change channel interpretation merely by passing mode.
F24-02: A22 road model mask #1 last row sometimes contains no path pixels; naive 'all rows have road' assertion failed. Repaired by interpolating center and width only across nonempty rows, preserving connected macro geometry, rerun PASS.
F24-03: Copying A23 flower sprites into 544×416 introduced bright white rectangular border artifact, detectable even at original 1x. Removed only the 2px hard source-card perimeter alpha before composing; distinct source PNG still saved for provenance. No invisible repair/claim of raw model image.
F24-04: Existing FS par12 right-edge crop (95px wide) included broken fence and branch fragments. Use narrower x1210–1280 70px crop, keep original sprite source credentials; original 95px intermediate excluded from final deliverables.
F24-05: Source FS grass texture is authentic and mathematically traceable, but quilted material is visually granular/repetitive and full village object density absent. Image-source fidelity != full Ground3 art fidelity. Formal art FAIL.
F24-06: A24 composite Pillow vs Godot actual differs at 641 pixels / 226304 (0.283%), 0.0010266 mean RGB channel. Do not claim exact engine composite.
F24-07: Front/behind actor tests cover original lamp object with a surrogate diagnostic sprite, not FS actor; tree canopy/base occlusion not tested. Static PAR front/back layers are demonstration at one actor footpoint; engine must sort by object foot dynamically.
F24-08: 17x13 32px collision model is a logical foot-tile grid, not VX native passage flags, not source pixel alpha mask collision, and does not yet verify actual game player movement. VX NOT RUN.
F24-09: A24 full size Ground is an assembled image using A22 AI road-derived geometry, original FS grass/sand and an A23 floral overlay. Not authentic 544×416 PixelLab original image. Future PixelLab Ground test requires actual returned 544×416 provider PNG and authorized budget.
F24-10: Avoid public release of original user-private FS Ground3 source crops, par12, Character sheets, engine screenshots showing private assets. GitHub only docs and code; Drive ZIP private.
F24-11: User's proposed division is preferred: PixelLab Ground-only, assistant PAR. If model outputs houses or trees inside Ground, reject or use exact same-art overlay extraction; independently creating a mismatching PAR introduces seams. Default Ground walkable, except marked water/chasm. PAR object bases define 32px blocking.
F24-12: Do not touch sealed FS v2.3.3 or project Ground/PAR/Collision; all A24 rendered in isolated folders. Formal Seal NO.
