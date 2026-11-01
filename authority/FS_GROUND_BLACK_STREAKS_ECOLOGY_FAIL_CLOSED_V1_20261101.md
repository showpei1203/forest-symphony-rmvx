# Forest Symphony Ground dark-streak / ecological community QA — fail-closed v1
2026-11-01. ACTIVE process authority. A33C after user explicitly rejected A33B R8 ground black-looking curved bands and inadequate meadow macro ecology.

## User's visual rule
- On a FLAT Ground scene with no intended geological relief, **NO black/dark elongated curved/contour lines**. Do not interpret image artifacts as a design request for altitude.
- If relief is intentionally authored, implement full geometry: raised platform edge, coherent dirt-face/cliff pixels, height separation, collision and optical hierarchy following true Ground3. An arbitrary dark paint stroke is NEVER an elevation system.
- SHADOW and LIGHT environmental layers must remain distinct, never use PAR/Ground stroke shadows to fake ecological dimensionality.
- Prefer coherent **community-scale, nonperiodic grass habitats** with 2–5px organically clustered leaf sprouts to random uniform point scatter. Weed/flower density belongs to grounded semantic vegetation regions, not all over tile grid.
- Ground is NOT flattened Ground+PAR. A32B two user-approved upper trees + all 12 approved PAR independent objects, foot/collision E layer and original Map050/scripts must remain SHA-locked during A33C.

## Failure root cause now VERIFIED
A33B R8's grass was generated using mirrored 64px source Ground3 grass and displaced nearest-neighbor texture coordinates. Dark-green leaf/streak pixels in that SOURCE texture recur at similar rows across the map; periodic sampling/displacement arranges them into repeated horizontal curves/bands. **Earlier assistant incorrectly attributed the whole visual problem only to random grass-blade strokes.** Real R8 diagnostic threshold `R<105 && G<124 && G>1.12R && B<46 && grass_only` isolates 8,084 dark-green abnormal band pixels; if road excluded differently a broader preliminary count 8,137 occurs. These counts are **a detection class, not all possible near-dark colors**, so numerical zero is not proof all human-visible bad stripes disappeared. Always inspect 1x original screen.
- Diagnostic includes 2x full actual R8 image with detected pixels in red `A33C_DARK_LINE_DIAGNOSTIC_ORIGINAL_HIGHLIGHT_2X.png`, exact black-band detection mask `A33C_R8_DARK_CURVE_FAULT_MASK.png`. Reuse them for regression.
- Preserve authentic native 1px pixel detail: remove only detected dark band values via 7x7 pixel median replacement and nearest palette floor for residual dark pixels. This is **selective pixel repair**, not image-wide Gaussian blur/bilinear and not false elevation/shadow strokes. Confirm road pixels untouched.

## A33C tested workflow
- Use actual A33B R8 544x416 original and authentic Ground3 64x64 grass / 48x48 sand provenance. R8 source SHA256 `dba346a620a15d7ddd9995273bac55c977c5e179c0bbcb8f9f986dd23e1c84fe`, A27 original SHA `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`.
- R10 only removes 8,084 detected dark class pixels; not enough macro visual variation.
- R11 / R12 tried 11 habitat centers and several hundred grass leaves, but visually insufficient distinct landscape patches. Retain as recorded underwhelming prototypes, not signoff.
- R13 macro-meadow selected A33C candidate: 11 coherent irregular habitat shapes, 41,200 mapped habitat pixels (substantial partly behind PAR), 176 clump centers, 1,365 tiny native pointed grass-leaf strokes, source 1,885 original bright ground-flora pixels preserved in same positions. Four grass-species style color palettes differentiate patches, not cast shadows or lights. Original road RGB exact, 12 original PAR SHA exact. R14 higher density variant is alternative only.
- R13 Ground SHA256 `d76bd016017fd6adcd4f767f2972fb2dc3f97e1f26d11b36cef2cc280e9b4043`.
- Do not claim noise-based habitat patches are automatically natural. User visual approval gate is ALWAYS separate from native engine success.

## Verification and bans
- One single PNG differs in A33C isolate vs A33B map test: `Overlays/ground50.png`. All original 12 independent PNGs and full transparent `Par50.png` unmodified. Ground size 544x416, no extra PAR on Ground, collision/foot unchanged, environmental SHADOW/LIGHT unchanged.
- Actual native RGSS Player Map50 12 placements / 24 screenshots, actor full-cover 0/627, partial 351/627 and 357/627, front 627/627, road move and tree obstacle; 0 modal. **Early test screenshots can have moving “米亞” map-title fade** causing whole-frame RGB differences; validate actor ROI and use late case05 hidden images for visual Ground comparison.
- Godot 4.7.2 real RX6700XT OpenGL native 8 frames, independent Ground+approved PAR target comparison maximum RGB delta1, report exact changed pixel count; do not call literal zero parity.
- Independent cold clone 3395/3395 original file SHA, actual cold Game.exe Map50 12 objects and no modal. This isolated map-only RGSS script bypass does NOT resolve formal production BattleRegression tests. Formal Seal NO.
- Archive rejected candidate PNGs, original reference, dark-band fault mask, source scripts, QA, and GitHub Handoff; original rights-unspecified art stays PRIVATE Google Drive only, no public sprite redistribution.
