# Forest Symphony | A35 R7 REAL Godot Tree Shadow Study | 2026-11-15

## Owner and baseline
- Godot 4.7.2 map-art HD-2D workstream. **Do not use RPG Maker VX**. Parallel A36C, combat systems, sealed R2–R6 scenes and original Ground remain untouched.
- Input owner-only complete R6 native ZIP `FS_A35_R6_CONIFER_NATIVE_QA_PRIVATE_20261115.zip`, SHA256 `20411549004f0931517a1016e07e0511ed9c61916e6888999c40fa6bbd0ee2f2`, 335 entries. R6 source-only ZIP also exists in private Drive.
- R7 lives in a **new independent reversible Godot scene** `res://scenes/a35_r7_shadow_study_scene.tscn`, not an in-place edit of R6.

## Actually implemented (not a concept mockup)
- `scripts/a35_r7_shadow_study.gd`: instantiates **175 LightOccluder2D nodes** with actual `OccluderPolygon2D` trunk polygons under the 175 original tree-asset nodes. Uses existing `source_semantic="tree"` and footpoint dimensions. No collision/physics or asset sprite mutation.
- Adds one **test-only** PointLight2D at (260,785), forest border, with `shadow_enabled` toggle via **O**. This lamp is used because original R3 village lanterns are >160 px from tree roots and their default light radius cannot validate nearby tree shadows. This test lamp is **not** claimed to be part of final permanent village lighting.
- `tools/a35_r7_shadow_build.py`: reproduces a new reversible .tscn with script attachment while keeping all previous Ground and PAR sources byte-identical, plus native source/nav/GPU tests.
- `tools/a35_r7_shadow_qa.py`: reads **actual Godot GPU OFF/ON screenshots**, validates controlled real pixel delta localized near test lamp. Derivative A/B contact is not an original renderer screenshot.
- `tools/a35_r7_finalize_evidence.py`: produces a **compact private evidence ZIP**, rather than duplicating >175MB of previously sealed PNG art for every technical probe. Reconstruct full source from original R6 full ZIP and GitHub builder; the complete R7 source ZIP is also retained on owner-only Drive.

## Native Godot 4.7.2 evidence
- Hardware: authorized workstation AMD RX 6700 XT, OpenGL 3.3 compatibility.
- Cold Godot editor import **Exit 0**.
- Godot **real native source + 175 occluder child nodes** (no fake masks) **PASS Exit 0**. Full 187 PAR instance paths, original source SHA, footpoint/collision geometries unchanged; study shadow on/off property toggled and tested.
- Godot real physical navigation **8/8 gates, 4/4 routes**, 0 newly blocked protected roads, **PASS Exit 0**.
- Two genuine Godot 1280×928 GPU images, study PointLight2D `shadow_enabled=false` and `true`: **2/2 PASS Exit 0**.
- Exact GPU A/B: **17,943 changed RGB pixels**. **17,943 of 17,943 inside** 263px radius around forest study lamp (260,785); **0 outside**, mean RGB absolute delta 0.09443, peak channel difference 104, pixel QA Exit 0.
- This proves **actual 2D light occlusion** is running and changing the scene, not just object count. It does **not** prove natural canopy/leaf shadows, realistic volumetric light or visually accepted HDR depth.

## Private release, reconstructibility
- Complete R7 **source** owner-only ZIP `FS_A35_R7_SHADOW_SOURCE_PRIVATE_20261115.zip`: 343 entries, 176,207,023 bytes, CRC PASS, SHA256 `9e32a559fc40b90c38a573c227106f9f33c6c48a5165ccd55ca96af7f55fb3eb`.
- Compact original Godot evidence ZIP `FS_A35_R7_SHADOW_NATIVE_EVIDENCE_PRIVATE_20261115.zip`: 18 entries, 5,969,885 bytes, CRC PASS, SHA256 `fac653f0e1bca3529cb2fe9bff10038ce681726d6437563d9daf301079aecb81`. Contains both original native PNGs, source/nav/GPU logs, QA JSON and all source code required for shadow layer reconstruction. It is **not** a standalone full art ZIP; use R6 base/full R7 source to reconstruct map.
- All private release files written under Google Drive-mounted `FS_AI_ASSET_FACTORY_Restricted_Binaries`. Do not supply a guessed external file link until Google Drive provider confirms the exact file ID, size, and sharing.
- Ground SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`. Original R6 scene SHA256 `621c4357898428c03f47435f6989818b2a9c10c5e9c9dd1594f61486f76345c9`.
- GitHub source/hand-off is public text only; no private tree or Ground PNG on GitHub.

## Official status & next work
**ENGINE PASS · NAV PASS · ACTUAL GPU SHADOW PASS · ART HOLD · FULL GAME HD-2D NOT SEALED.**
- 175 occluders are simplified **tree trunks**, not detailed canopy alpha outlines. R3 lanterns remain unchanged. Additional forest lamp is a lab fixture in isolated R7 scene.
- Required next: shadow mapping linked to actual tree canopy+trunk shape with controlled polygon detail (not a naive large full-rectangle shadow). Test front/back player occlusion, 2D shadow PCF filtering at 1:1 and performance, then decide whether to migrate into production scene.
- R6 conifer art still HOLD due spiky edge outlines and one-point actor rear visibility 53 vs R5's 0; need refine botany before ART seal.
- Ground3 grasses, flower density, organic roads on additive independent scene **after** tree ART gate; preserve original Ground and NAV.
- Every future stage must have code, real native Godot screenshots, source/physics/ROI QA, Failure Log, Handoff, private Drive artifacts, all previous scene hashes.

## Code
- [R7 real Godot LightOccluder2D nodes](../scripts/a35_r7_shadow_study.gd)
- [R7 reversible full scene builder](../tools/a35_r7_shadow_build.py)
- [R7 real GPU shadow pixel QA](../tools/a35_r7_shadow_qa.py)
- [R7 compact evidence sealing script](../tools/a35_r7_finalize_evidence.py)
- [R7 Failure Log](A35_R7_FAILURE_LOG_20261115.md)
