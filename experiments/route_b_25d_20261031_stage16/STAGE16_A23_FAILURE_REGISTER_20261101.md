# Stage16 A23 Failure Register — 2026-11-01

A23-01: Real 128px AI input has simplified/noisy material despite legitimate 128px sprite art. Corrective test separates geometry from color/texture using authentic FS source pixels; **this is procedural postprocessing**, not new model-generated 544×416 art.
A23-02: Periodic repeat exposes hard grass/sand texture frequency and stripe seams (contact sheet). Source sampling alone without scene-aware blending cannot meet FS natural ground aesthetic.
A23-03: Overlap-quilt seam score at fixed grass x64 improved 3/4 samples, **failed** 1/4: case #4 13.354→14.365. No universal seam continuity PASS; avoid treating visual reduction as formal seam gate.
A23-04: A22 botanical RGB high-contrast heuristic preserves only 513–875 pixels (2.6–5.3%) as RGBA, potentially incomplete silhouettes or detached plants. This is a decoration candidate, NOT a validated PAR or collision layer.
A23-05: Texture material source membership is exact RGB pixel membership, but it does not imply original ground3 scene composition, source image spatial continuity, or visual fidelity of plant and road arrangement. Numeric adjacent L1 close to FS is only a texture-frequency diagnostic.
A23-06: Ground3 original source high-resolution scene is not inside private ZIP, only its small verified grass/sand native crops. ZIP cold replay reruns deterministic Python scripts; not the paid model itself. The PixelLab real image input bytes are retained unchanged.
A23-07: A23 spent 0 generations. Last checked PixelLab balance A22 = 1,970. No additional API calls, no changes in production FS assets, no Godot or native VX renderer execution, Formal Seal NO.
A23-08: Engineering script first run failed because palette test assumed 3D image array after boolean indexing (actual Nx3). Fixed and executed with correct reshape(-1,3); error and remediation included to avoid repeated shape misuse.
A23-09: Source material quilt and botanical overlay are *separate traceable techniques*. Do not combine final image RGB SHA with raw model's PNG provenance, or declare freshly AI-generated original image. Keep claims distinct.

**A23 diagnostic pixels and semantic masks PASS; full art and engine integration NOT ACCEPTED / NOT RUN; Formal Seal NO.**
