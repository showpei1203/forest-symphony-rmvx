# Forest Symphony | A35 R8 R3 D1 | Native Day / Dusk / Night Handoff
2026-11-16 | Godot 4.7.2 stable official | RX 6700 XT, OpenGL compatibility
ENGINE PASS / 6 ORIGINAL GPU FRAMES PASS / DAY-DUSK-NIGHT HOUSE QA PASS / ART HOLD.

## Protected baseline
- Uses fully native-GPU/physics-tested A35 R8 R3 scene and previous full-release ZIP. R8 R2, R8, A36C, Ground and all PAR/175 tree occluders remain immutable.
- Playable/private complete R8 R3 Godot project: https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view (199,988,204 bytes, 398 files, SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830, Drive owner-only).
- See full R8 R3 original source/nav/4-frame Handoff A35_R8_R3_NATIVE_HANDOFF_20261116.md. This D1 stage adds independently tested day-cycle evidence, does not rewrite that sealed archive.

## Actual implementation and GPU testing
- New test source: tests/capture_a35_r8_r3_daycycle_native.gd.
- New pixel QA: tools/a35_r8_r3_daycycle_qa.py.
- Native Godot 4.7.2 SubViewport makes SIX actual GPU screenshots 1280x928 at fixed camera, actor hidden, rain OFF. Day (phase=0), Dusk (phase=1), Night (phase=2), each with new grove secondary PointLight2D OFF and ON.
- Actual GPU capture Exit 0, six original frames PASS. Exact phase-specific comparison below from real GPU frames:

  DAY: 43,285 total changed pixels inside grove light region, 0 outside, 41,964 in upper forest, 0 pixels in east cottage. Mean signed RGB in forest +4.51211.
  DUSK: 45,756 total changed pixels inside light region, 0 outside, 43,818 in upper forest, 0 pixels in east cottage. Mean signed RGB +4.57976.
  NIGHT: 45,608 total changed pixels inside light region, 0 outside, 43,667 in upper forest, 0 pixels in east cottage. Mean signed RGB +4.55691.

- Across all three phases, PointLight2D new grove accent (805,90), energy .29/scale 2.2, changes only within radius 190px and **never brightens the right cottage** ROI (968,100)-(1240,348).
- Original overall day vs night base frame: 1,187,582 changed pixels. Phase color changes remain active rather than being replaced by a static lighting image.
- Godot native source 187 PAR, 175 trunk +175 real canopy LightOccluder2D and physical navigation 8/8 gates, roads 4/4 passed in R8 R3 original full release, not silently rerun in D1.

## Original evidence and cloud verification
- [Six-original-frame day/dusk/night evidence ZIP](https://drive.google.com/file/d/1txh9Veip2mVf6mji_KEvD4hRPAc3-Rtc/view) is compact EVIDENCE ONLY, not a full playable Godot project: 13 items, 27,184,687 bytes, ZIP CRC PASS, SHA256 e2f85b888024fc68ebfd390faa13d992a2616df2b9afe99f1209e62c41c2c975. Drive provider readback confirms shared=false and owner only.
- Includes all six original GPU PNG images, exact phase QA JSON, native stdout, native capture/QA sources and SHA-based reference to complete R8 R3 playable project.
- [Six-way day-cycle derived comparison](https://drive.google.com/file/d/1BLL-KJH5rlR4X4oXGwXJrubsU1LQ_Yzk/view) is composed of original frames, not itself one original Godot framebuffer.
- [Complete Godot R8 R3 playable ZIP](https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view). [R8 R3 formal Handoff](A35_R8_R3_NATIVE_HANDOFF_20261116.md). [R8 R3 D1 Failure Log](A35_R8_R3_D1_FAILURE_LOG_20261116.md).
- All private artwork and GPU screenshots are owner-only Drive. Public GitHub contains only source code and text docs. Historical scene hashes unchanged.

## Open ART HOLD and next development
- Frame-by-frame inspection: day is bright/high-saturation, dusk still relatively vivid and night noticeably dimmer. That is working tonal variation but **not proof of natural HD-2D lighting**. No final art approval.
- No rain or moving camera/actor permutations tested here; current shadow translucency remains an artistic unshadowed fill approximation; R6 conifer needles still coarse and some spiky.
- The next art task should evaluate conifer/leaf silhouettes at original 1x and multiple actor positions, then progress Ground3 (organic edges, flower/grass clusters, leaf litter) in a separate immutable-Ground candidate. Later actual 2.5D depth/parallax+postprocess can be layered without corrupting physical Ground/PAR.
- Every stage requires real Godot screenshot, source/nav if modified, ROI, Failure Log, Handoff, owner-only Drive, and public code GitHub.

Status: DAY/DUSK/NIGHT LIGHT CONTROL PASS, overall ART HOLD.
