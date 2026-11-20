## T-B Round 3 | 2026-11-21 | PMD0001 V4 articulated attack candidate

- Status: **M3 ACTIVE, TECHNICAL_QA_PASS, ART_HOLD, GODOT_NATIVE_NOT_RUN**.
- Original R1 8-frame whole-body warp **remains ART FAIL** and must never be promoted.
- V4 is a new 11-frame **source-locked procedural deformation** with separately controlled rear leg, near front leg, far front leg, upper-head anchors, and lower jaw. It is **NOT PixelLab Skeleton output** and not proof of PixelLab pipeline; this is a fallback candidate for controlled visual review.
- Exact input: approved candidate `PMD0001_STATIC_64.png`, SHA256 `fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c`, Drive ID `1jDRbwUfk-Y_5wk_8JVSXMygTun2OfSAR`. Output: 11 frames × 96×96; 384×288 RGBA atlas SHA256 `08327c031e3962c50623aeb15f11961b5c7795c8794ad359dafb54e7315686d7`.
- Frame 0 and 10 are pixel-exact source; other 9 frames distinct; 10 unique images total. Original timed events F2 Rush, F5 Hit, F7 Return; original tick sequence 4,2,4,2,2,2,2,2,2,2,4 at 60 ticks/sec.
- Actual QA: **16/16 local technical assertions PASS** for source hash, 96×96 bounds, alpha, F0/F10 identity, keypoint deltas, nonrigid displacements and timing. At F3/F5/F7 the image differs by >=70 source-visible pixels from a merely rigid translation. This **does not prove good anatomy or Godot playback**.
- Preview still indicates some toe/leg stretch from mesh retargeting and imperfect lower-jaw separation. User ART Gate not passed. V4 is a **visual candidate**, not final.
- Godot 4.7.2 comparison scene, 12-file PRIVATE ZIP CRC PASS, SHA256 `0625508b4c6aed76bb6348cd4540d8ebbc7cb79edbd3699613aa036e52ec8d17`. Headless GDScript validator included but **NOT_RUN**. No falsely claimed Godot screenshot.
- PixelLab paid generation: **0 jobs / 0 generations**, no API call. Access unavailable in current runtime; the approved official v3 Skeleton keypose contract is unchanged for future actual PixelLab run.
- Source sprite and derived PNG/GIF/ZIP stored PRIVATE Drive ONLY. GitHub PUBLIC branch stores code/QA text, not protected private raster. No user PC changes. T-A/T-C/main untouched.
- Future macro: obtain real PixelLab keypose-driven 11-frame output (record job and cost), assess leg joints and jaw at 1× in native Godot 4.7.2, and conduct user ART review. Do not start unrelated second creature or mass production until the first complete Attack is acceptable.

### Cloud evidence
- [V4 11-frame atlas](https://drive.google.com/file/d/1cuLHQ64Dx1QLFF1CpXVUwTjdG6nhPwRN/view)
- [V4 animated GIF](https://drive.google.com/file/d/17PRN7eSUSKXguNdtC2G4xxEoSSbfVFol/view)
- [V4 contact sheet](https://drive.google.com/file/d/1kpCc-1TK5n4uJ3ntYhItvkfmadKi7uYB/view)
- [V4 private Godot review ZIP](https://drive.google.com/file/d/1Fhnc4q6_gnc-2cySRdeJ8uyYf4eqtmLt/view)
- [V4 QA](https://drive.google.com/file/d/1DmPZKnTJIDw5Y5NAx7YRKcaWnoAqFxY4/view) / [manifest](https://drive.google.com/file/d/1j3cu9FGEH3MTp_yCCupj_sdmloSvF4m7/view)
