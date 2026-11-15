# Forest Symphony A35 R8 R3 D1 | Daycycle Failure Log | 2026-11-16

ENGINE/GPU PHASE QA PASS, ART HOLD.
1. Prior R8 R2 northeast lamp overbrightened the right cottage. R8 R3 relocation to forest was verified at night, but night-only proof could mask day/dusk regressions. D1 adds genuine Godot GPU paired OFF/ON frames at ALL three existing lighting phases.
2. For day/dusk/night, new lamp effects remain fully inside circle radius 190 at (805,90) and 0 pixels outside. Right-cottage ROI affected pixels are **0 for every phase**. Native GPU day=43,285 changes, dusk=45,756, night=45,608. Exact QA all three PASS.
3. Godot day/night baseline differences are 1,187,582 pixels. Day-phase palette is bright and saturated; dusk phase still quite vivid. These are aesthetic review targets, NOT engine errors. **ART HOLD**.
4. Captures use fixed 1280x928 viewport, player hidden and rain=false. Dynamic rain/wind/moving camera/real player depth across lighting phases remain UNTESTED, do not assert broad coverage.
5. R8 R3 original full playable ZIP remains unchanged SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830. D1 adds only test scripts, pixel analysis and PRIVATE 13-file evidence ZIP. No asset changes, no A36C changes.
6. Reproducible compact evidence ZIP 27,184,687 bytes, SHA256 e2f85b888024fc68ebfd390faa13d992a2616df2b9afe99f1209e62c41c2c975, ZIP CRC PASS, Drive provider shared=false/owner-only, ID 1txh9Veip2mVf6mji_KEvD4hRPAc3-Rtc.
7. R6 conifer silhouette pixellation/needle spikes remain ART HOLD. Real HD-2D DOF/physical leaf translucency not yet implemented; PointLight2D unshadowed fill is a practical visual approximation.

Next: original pixel art polish and wider actor/occlusion QA, then separate Ground3 layer after visual acceptance, without overwriting Ground.
