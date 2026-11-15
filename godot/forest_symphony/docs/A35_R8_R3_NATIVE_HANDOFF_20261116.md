## Verified cloud artifact (not merely mounted local file)
- [Complete R8 R3 Godot playable native QA ZIP](https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view): provider returned exact 199,988,204 bytes, shared=false, owner-only; local CRC PASS and SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830.
- This ZIP contains all original GPU 4/4 frames, corrected source/nav/GPU QA, official logs and historical assets. Preferred handoff artifact.
- R8 R3 full native release is now **Drive cloud verified** and no longer pending sync.

# Forest Symphony | A35 R8 R3 | Official Godot HD-2D Grove Lighting Handoff
Date 2026-11-16, Asia/Taipei. Godot 4.7.2 official, AMD RX 6700 XT, OpenGL compatibility.

Status: ENGINE PASS / NAV PASS / REAL GPU 4/4 PASS / PIXEL QA PASS / ART HOLD.

## Correct baseline
- Current stage is R8 R3 from complete A35 R8 R2 source, not R7, obsolete A33 or VX.
- Owner-only R8 R2 complete baseline: https://drive.google.com/file/d/1qPRcM1uT-4Ep9cglVcUzHsz0kvd8CQ-p/view
- Baseline R8 R2 SHA256 1217c36f9e19ece3d104f6cdf3b8973474c472fd62a7f5e6cd0b94013ffab37c.
- Original R8 R2 scene remains unchanged, SHA256 e0d42f256e9e268d548420dc68bf78009b93d5613cfa70f5889d3de4855fd3b1.
- Original Ground SHA256 3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000.
- Do not modify independent A36C, game systems, or sealed R2–R8 R2 scenes.

## Actual R8 R3 construction
1. New independent Godot scene: scenes/a35_r8_r3_grove_balance_scene.tscn.
2. Source controller: scripts/a35_r8_r3_grove_light.gd. Second light moved from (1090,280) to forest (805,90). Total energy 0.66 -> 0.29; radius scale 3.4 -> 2.2; unshadowed fill fraction .22 -> .14. Existing O/P/F/M toggles remain. This is an art-directed approximate light blend, not physical partial-alpha shadow transmission.
3. tools/a35_r8_r3_build.py builds the reversible project, native source/physics/navigation tests and original GPU capture test from sealed R8 R2.
4. tests/test_a35_r8_r3_native.gd verifies 187 PAR owner locations, sprite SHA and collision unchanged, 175 trunk + 175 canopy LightOccluder2D and zero-ghost shutdown.
5. tests/capture_a35_r8_r3_native.gd captures four original 1280x928 night scene GPU frames with fixed camera: R2 fill-only baseline, R3 grove OFF control, R3 grove ON, original R2 overbright cottage light ON.
6. tools/a35_r8_r3_gpu_qa.py analyzes original GPU pixels, zero-effect control, forest illumination, right-cottage ROI. Four-way contact sheet is DERIVED from original Godot images, not a native single frame.
7. tools/a35_r8_r3_finalize_native.py packages original frames, native logs/QA, full art sources and all old scenes into owner-only release.

## Actual native Godot 4.7.2 results
- Cold editor import PASS Exit 0; native source scene PASS Exit 0; physics/navigation 8/8 protected gates, 4/4 original roads PASS Exit 0.
- Original native 1280x928 OpenGL GPU 4/4 frames captured PASS Exit 0.
- 187 PAR and 175 trunk+175 canopy blockers, all original Ground and collision equivalent to R8 R2.
- With new grove light OFF, original R8 R2 primary fill screen identical: 0 changed pixels, max absolute RGB delta 0.
- New grove ON: 45,608 altered pixels, all inside new lamp radius 190 pixels, 0 outside. Of these, 43,667 in upper forest ROI; average signed forest RGB +4.55691, max channel delta 47.
- Old R8 R2 northeast light changed 65,972 pixels in east cottage rectangle (968,100)-(1240,348); new R8 R3 light changed 0 house ROI pixels, removing this specific visual defect in the fixed night scene.
- At 1x screenshot, right house retains original tonal balance while upper grove has restrained extra illumination. ART still HOLD for conifer spikes, day/dusk variation, actual 3D DOF and overall visual approval.

## Owner-only artifacts, exact files
- Full reconstructible source ZIP: FS_A35_R8_R3_GROVE_SOURCE_PRIVATE_20261116.zip, 387 files, 188,126,672 bytes, CRC PASS SHA256 14d7a30dc6d44291d8206d18156169cfe1f8d228d5aba05df83bd386ee4adf3c, Drive-provider-verified private: https://drive.google.com/file/d/1y5mkwx4LUGXdAQH7hCuziXTA7G6u3jah/view
- Full native QA project ZIP: FS_A35_R8_R3_GROVE_NATIVE_QA_PRIVATE_20261116.zip, 398 files, 199,988,204 bytes, CRC PASS SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830. Written to owner-only G: Drive mounted folder; link only after exact provider ID/permission readback.
- Private four-way derived GPU comparison: https://drive.google.com/file/d/1w6bmiMwzyZGcbJIrgTSGty1TaztmfzDd/view
- Owner-only Drive workspace folder: https://drive.google.com/drive/folders/1TB5YWKzYOhF0kAjzNg--tzOATFfeE6p0
- Public GitHub contains code/documentation only. Original PNG artworks and archive remain private Drive.

## Next stage
1. Run native day/dusk/night comparison for the new light, verify right-cottage brightness across phases with consistent camera and weather.
2. Continue real 1x art improvement of R6 conifer needle sprites/organic forest shape, including more than one actor concealment test. Keep ART HOLD until actual visual acceptance.
3. Ground3 after foliage art gate: design richer grass/flower clusters, naturally eroded road edges in separate reversible candidate with unchanged original Ground, nav/ROI/native QA.
4. Existing R8 R2 and parallel A36C untouched. Every stage must have real native output, Failure Log, GitHub/Drive Handoff and SHA/CRC proof.

This stage fixes cottage glare objectively but does not seal full HD-2D art.
