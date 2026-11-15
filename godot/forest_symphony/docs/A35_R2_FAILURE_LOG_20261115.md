# A35 R2 | Failure Log

1. First Godot headless run failed: PNG `load()` returned no loader because the cold ZIP had never run `--editor --import`. Recovered with official Godot `--headless --editor --import` exit 0 then source/COLLISION test exit 0. Always import before tests.
2. First native OpenGL image ROI reported 187 pixels outside change region. Cause: R2 trees change dimensions, so old R1 sprite pixels can lie outside new R2 rectangle. Fix: union R1 and R2 bounding ROIs. Re-test 149,047 changed pixels within union, 0 outside, exit 0.
3. ART HOLD: new tree crowns, though eight full new native-size PNG silhouette shapes, inherit repetitive 8px foliage-patch patterns and smooth blob contours, visibly less consistent than original high-quality tree artwork. Do not seal art or claim final visual quality.
4. Native screenshots exist on authorized PC test temp, not mirrored to owner-only Drive package yet. GPU test logs are included in ZIP. Final proof not closed.
5. Reproduction source script currently defaults to the `/mnt/data` temporary paths; make CLI parameters before treating as generalized map factory.