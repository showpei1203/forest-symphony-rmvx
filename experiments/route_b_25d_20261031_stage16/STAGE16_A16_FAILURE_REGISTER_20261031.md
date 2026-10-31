# Stage16 A16 Failure Register (2026-10-31)

- F16-01: Prompt asking for original pixel art produced high-resolution 1434×1097 RGB, not requested game native 544×416. Model source generation != native pixel ability.
- F16-02: A dedicated 2–16px grid-periodicity test (validated against 4px synthetic positive control) returns max 1.0361, below predefined 2.0. This does not establish a source logical pixel lattice.
- F16-03: Reducing color count to 128 yields proper PNG dimensions but leaves aliasing and inconsistent 32px flower/grass clusters. It cannot rescue detail.
- F16-04: Original Ground3 small grass/sand reference crops were used only in post-generation comparison, never full Ground3 in the model. Don't claim source-conditioned generation.
- F16-05: PixelLab/Retro Diffusion/Pixel Art XL researched only; no specialist model was actually run. Any A17 result must include authentic model response + original PNG.
- F16-06: All native 544x416 variants are *diagnostic downscales*. No approved Ground, no PAR, Godot, or VX; Formal Seal NO.
- F16-07: Drive folder creation succeeded but artifact binary upload failed because the file tool container session expired; DO NOT claim A16 ZIP/PNG uploaded to Drive. The conversation artifact is verified and GitHub text authority is maintained.
- STOP: no additional generic image-to-smaller-image loops in A17; test direct specialized pixel-art generation in a finite two-option trial.

**Technical reproducibility PASS / native pixel modeling FAIL / full art FAIL / Formal Seal NO.**