# Forest Symphony | A35 R4 Organic Grove / HD-2D Native Handoff | 2026-11-15

## Engineering boundary and baseline
- Godot 4.7.2 map-art workstream. No RPG Maker VX work. Do not alter A36C large-forest workstream, game systems or A35 R2/R3 historical scene.
- Owner-only base is A35 R3 complete native ZIP, Drive ID 1xWgVRNW2bLL9XUBZvc6I1vP7W8BQdX9-. R3 optional day/dusk/night FX is retained unchanged.
- Output lives in new independent scene: res://scenes/a35_r4_organic_groves_hd2d_scene.tscn.
- Original Ground SHA256: 3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000.
- Original R3 scene SHA256: 7e9c812e04da68f474eb47235c8e43014b4eaebea9838eb45612dca783eee85f.

## Real construction
1. Eight private one-piece, native-pixel, source-derived tree visual variants: cypress, willow, elder, fir, birch, oak, needle, maple. The source drawings are high-quality existing FS A36F trees. Tree canopy detail is not random repeated 8px mosaic. Some coloring and species-specific pixel accents applied without resampling.
2. Replaced 32 existing A35 R2 grove tree instances in R4 manifest and scene only. Kept 155 other PAR references, all 187 owner footpoints, 175 overall tree instances, all collision footprints and original Ground bytes exactly.
3. Retained independently toggleable R3 HD-2D day/dusk/night, rain, dust/glow, and 2D godray atmosphere. This is 2D ambience, not 3D volumetric lighting or final depth-of-field.
4. Added native source, real physical navigation and GPU A/B/actor occlusion testing, with deterministic FX-off tree-only ROI verification.

## Verified actual Windows/Godot QA
- Windows AMD RX 6700 XT; official Godot 4.7.2; OpenGL 3.3 compatibility.
- Cold import: PASS Exit 0.
- Native 32 source replacement /155 retained /187 original footpoints and collision shape equality /Ground SHA: PASS Exit 0.
- Physical navigation: **8/8 gates, 4/4 preserved routes**, newly blocked protected road cells zero, PASS Exit 0.
- Actual Godot GPU native captures: **7/7 original 1280x928 images** (day/dusk/night + R3-vs-R4 stable A/B + character behind/front), each capture script exit 0.
- Scene-only day A/B with atmosphere disabled, actual GPU source tree union ROI: **143,456 changed pixels inside**, **0 outside**.
- Actor behind sparse conifer: 184 visible pixels vs 576 visible in front, ratio 31.94%. Accept partial leaf transparency, requiring <=40% rear/front ratio. **PASS_PARTIAL_FOLIAGE**. This is not fully opaque occlusion; do not claim behind actor is completely hidden.
- All reported passes are actual Godot tests, no PIL image presented as native. Contact sheets are composed from actual GPU images but are not individual original renderer frames.

## Owner-only release and source code
- Source candidate ZIP: FS_A35_R4_ORGANIC_SOURCE_PRIVATE_20261115.zip, 109,185,907 bytes, SHA256 23086910449db4084f186508f1244f0f72c7f8edc0ab6507831b086eabee5359.
- Full native QA release: FS_A35_R4_ORGANIC_NATIVE_QA_PRIVATE_20261115.zip, 269 entries, 131,309,501 bytes, ZIP CRC PASS, SHA256 **51467d0a709bc7e6def518d79c25adbbd9de78c9123770e498e143e5ee446206**.
- Private Drive folder: https://drive.google.com/drive/folders/1_OAbjQ8-fsjli0jRv7EYDnQu629CUJms . Do not make PNG assets public.
- GitHub reproducible builder: tools/a35_r4_organic_build.py
- GitHub real native capture: tests/capture_a35_r4_ab_actor_native.gd
- GitHub exact pixel QA: tools/a35_r4_native_roi_qa.py
- GitHub finalizer: tools/a35_r4_finalize_native.py
- Source and QA docs on GitHub, complete owner-only PNG/ZIP/logs in Drive.

## Art acceptance
**ENGINE PASS · NAV PASS · PIXEL ROI PASS · PARTIAL OCCLUSION PASS · ART HOLD.**
R4 artwork blends with original Ground/village better than R2 repeated squares, but species silhouettes, realism and diversity are not yet genuinely distinct enough for formal art release. Cypress/fir/needle are visually small/similar. Existing R3 godrays/lamps lack real per-tree shadow-casting occluders, and no true 3D DOF.

## Required next work, no reset
A35 R5 ART: generate *genuinely distinct* 8 tree species at native sprite resolution with consistent leaf structure/wood anatomy and actual organic canopies; preserve 32 footpoints/collisions/187 PAR. Run source visual A/B, official Godot editor import, native 8/8 nav + 4/4 routes, GPU daylight native 1x, tree union ROI, front/back partial foliage QA and Handoff. Only after visual review PASS move to Ground3 grasses/flowers/roads, then HD-2D occlusion/light depth and seasonal system.

Every stage must include real outputs, explicit PASS/HOLD, Failure Log, Drive/GitHub Handoff. Never call a conceptual AI image a playable map.
