# FS v2.9 G3/G4 Source and Contact Candidate | 2026-10-25

**State: G2 User Art Ground APPROVED; G3 HOUSE SOURCE FAIL; G4 Contact blend trial; G5 Static PASS; G6 cold rebuild PASS; G7 V29 native NOT RUN; G8 user art PENDING. Release BLOCKED.**

G2 OPEN_FIELD 544x416 approved viewport, native full source 544x576 by direct noninterpolated crop of G1B generated source (x800,y240). Full extension lower 160px not separately visually approved. Reused 3 full RGBA source sprites, preserve raw SHA, no source collage extraction.

One newly generated full village scene was explicitly REJECTED as a flattened sheet, not sliced into assets. Reused house alpha border is mathematically valid but **source contains baked-in rectangular dirt/grass patch**. A/B edge blending does not repair source semantics, therefore G3 Visual **FAIL**, G4 contact transition remains research candidate. The ground itself is not blamed for this defect.

Layer data: clean GroundBase; independent GroundContactDecals + GroundContactShadows (always walkable); PAR objects house, sacred broadleaf, flower; PixelOwner16, Occlusion, Collision and Master. `TerrainExceptionMask` contains zero blocked pixels. Obstacles only PAR contact footprints, not canopy/roof alpha. 20 blocked tiles, 286 reachable, spawn (8,13); 544x576 17x18 32px. All 4 channel RGBA Master source recomposite differences = 0; 3/3 deliberate mutations detected. **Technical consistency does not equal art quality**.

Isolated Windows VX Game.exe packaged based on successful v2.5 tested runtime geometry with images substituted and Game.ini changed to V29, but **not tested in real Windows this turn**. No new native pixel/actor/camera claims.

Private 159-entry portable ZIP created and CRC tested, **22,394,347 bytes** SHA256 `9b7ada2600a0b1dbe5c81417f955959fef12ba93ea2aa8771f51f384a7ffc0a4`. Independent cold-extract re-run of build, packaged VX, checker and negatives produced identical Master PNG SHA256 `627ed65e0284aa3a3a88c8923c56d3d2697e46be5e7d574d86f3b0b07161c1d3`. The ZIP is available in the user conversation, not verified as uploaded to Drive.

Handoff: https://docs.google.com/document/d/13sBxgyiJ3ad6bL0DFyDspB4lMqbSjkN2tfFQ5MBhlBI/edit

Next mandatory G3 action: create or otherwise source a **genuinely isolated complete building without baked Ground**, validate roof/walls/door/steps/chimney and full silhouette, then re-run Ground Contact and native visual gate. Retain v2.4/v2.5 visual negative fixtures; formal FS, v2.1/v2.2/v2.3.3 unchanged.