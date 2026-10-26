# Art Pipeline Authority — F2 G5R2 Source-first Ground / P3 G3R1 Volcanic PMD0001
Recorded: 2026-10-26
Branch: feature/ai-art-toolchain-pilot-20261025

## Frozen baseline and prior negative gates
- F1R1 A04 original Forest: USER VISUAL PASS, SHA256 `0a407d9dce66183703fe957193a396cc59648d3b4502cd0c83e4f83e3035272b`, SEALED, do not overwrite.
- F2 full-scene clone donor underpaint remains `ART_FAIL_GROUND_PATCH_SEAMS` even though F2G4 original RPG Maker VX 1,530/1,530 collision/native technical PASS.
- Previous P3 rock recolor/art candidate still lacked amber lava; this update implements new user-directed orange+gray first-stage volcanic form.

## F2 G5R2 actual new source results
- Source: user elf-village high-detail reference, already in F2G4 complete private source. Extract source coordinate rectangle `(610,578)-(930,834)` at **native 1x** (320×256 px). This is a 25% larger contiguous terrain source than previous 256x256 Ground DNA. No pixels generated, blurred, interpolated, or filled with donor-patch quilting.
- Created **80 fixed-coordinate 32×32 tiles**, 10×8. Bit-exact reassembly against the original continuous source: **0 RGB pixel drift**. No arbitrary rotation/scaling or tile-repeat synthesis. Grass, dirt paths and low flowers are WALK. Potential small PAR flora/edge contamination is still `HUMAN_VISUAL_PENDING`; 13 pure black source shadow pixels are explicitly recorded (not treated as void). Original first zero-black gate failed because isolated dark source pixels were forbidden; fixed gate to require source dark/black incidence lower than 0.05% and to retain inspection status.
- The 80 tiles are **scene-owned and nonrepeatable**; do not claim globally seamless autotile, 1440x1088 full-map Ground, completed architecture, new VX test, or user art acceptance. Broader expansion still needs independently authored terrain beyond the original flattened concept instead of just more cropping.
- Private [F2 G5R2 source+tile ownership+QA+CMD+handoff ZIP](https://drive.google.com/file/d/1DpVxXpp1lJYbTeNVCMPyoJhABKIMDEML/view?usp=drivesdk), 595,580 bytes, SHA256 `d06297b8eca44aea4aa2f87a056efa6ec8859f156aba9395428da36b952f665b`.
- [Actual 320x256 Ground](https://drive.google.com/file/d/1xr-ZtPZ9BTQ0FowPlhUU3W-vFSqh3bd0/view?usp=drivesdk).

## P3 G3R1 PMD0001 actual new edited original 34-action asset
- User's explicit design: orange/gray juvenile volcanic rock + fire, back-stone cracks open gradually through 0001→0002→0003, faint magma in 0001, larger split basalt in 0002, final open lava core 0003.
- Based on original PMDCollab SpriteCollab `sprite/0001` authentic AnimData.xml + 34 native action -Anim.png sheets, offsets and shadow assets; **1,123 original action/direction/frame cells**. Created orange-toned warm body, deep gray sharp rock shell and consistent orange/yellow magma fracture in all 1,123 cells. This is original source derivative, not an image-generation mockup.
- Source XML, -Offsets.png and -Shadow.png **byte-for-byte unchanged**, every atlas frame grid and cell size preserved; alpha rock silhouette inherited unchanged from P3R3 true-morph previous, source frog → rock derivative had genuinely new alpha silhouette. Lower foot shape/pivot not moved. Source model checked every cell for orange/yellow magma (at least 2 pixels) and rock morphology; every cell present and no newly cropped edges. User visual gate `PENDING`, commercial sprite contributor permissions and attribution review pending.
- Local first P3 G3 test required bottom RGB unchanged, conflicting with user's body-color change. Archive the failed strict check, revise to **preserve foot geometry/alpha rather than color**. Self visual QA then found the body too yellow; archive and darken toward warm orange.
- Actual **Godot 4.7.2 XMLParser + OpenGL GPU native test PASS** loading these modified action sheets alongside the real PMD original XML. This is a Godot bridge, not proof of official PMD engine or RPG Maker VX Tankentai SBS import. No paid API calls.
- Private [P3 G3R1 complete original+rock-fire+native Godot test+LOG+handoff](https://drive.google.com/file/d/1iopQqJ7qtefob-57eJXgjRwhCPEOclGQ/view?usp=drivesdk), 734,082 bytes, SHA256 `2405d28857f03b55f597ecbdc7526ffbebb83edf49a3ef432b63557b881d40bb`.
- [Original / rock / rock-fire comparison](https://drive.google.com/file/d/1SXLaRwqbo-XjrM4vX8TUvlqdzA3SJpmQ/view?usp=drivesdk).

## New mandatory rules
1. Maintain strict progression: 0001 sparse magma hairline fractures + gray basalt/ember orange body; 0002 thicker crust with wider glowing splits; 0003 exposed molten core. Do not duplicate 0001 atlas for subsequent species; each PMD ID will have its own original XML/actions and must be edited frame-by-frame.
2. Original action/frame cell widths/heights and metadata remain fixed; allow visible *internal* outline morphology when needed but no changing cell boundaries, timings or pivots. Per-cell magma/rock QA and RGB visual comparison required.
3. Do not treat crops from an old whole-scene concept as a repeatable Ground system. G5R2 improves source-fidelity and continuous source area, but still needs honest source-first independently owned terrain and scene construction. Never blur donor pieces over occluded house areas or infer complete Ground from 0px same-source reconstruction.
4. Every improvement must retain SOURCE, QA, fail cases, ZIP/CMD/Handoff, Drive/GitHub/Linear sync. USER VISUAL PASS requires user explicit approval. No image-only tool results substituted for production.

## Next specific engineering gates
- F2 G5R3: author terrain beyond the existing flattened reference as independently owned extended Ground source, maintain exact style, remove hard rectangular repeats and prove full Ground quality before mapping. Investigate independent source art generation/pixel-style asset authoring and semantic road blending; preserve original accepted F1R1.
- P3 G4: user visual review of orange-gray lava cracked 0001, then true PMD-loader or isolated RPG Maker VX SBS integration using original action frame and offsets. 0002 derivative creation only after 0001 style gate approved.
