# PMD 0002 Stage-2 Volcanic Evolution G4R1 — Formal handoff and stage lock
Date: 2026-10-26 | Scope: P3 only, F2 map PAUSED BY USER

## Accepted family reference
PMD `0001` latest **orange/gray volcanic juvenile G3R1** is visually *direction-approved* by user: a small dark basalt rock shell with thin cracks and faint orange magma, warm-orange frog body. This authorizes stage-2 source work, not final approval of every animation or original PMD/VX SBS engine import.
- 0001 approved-direction real three-way atlas comparison: https://drive.google.com/file/d/1SXLaRwqbo-XjrM4vX8TUvlqdzA3SJpmQ/view?usp=drivesdk
- 0001 existing source ZIP unchanged: https://drive.google.com/file/d/1iopQqJ7qtefob-57eJXgjRwhCPEOclGQ/view?usp=drivesdk

## New G4R1 authentic PMD 0002 derivative
**Do not reuse 0001's action or atlas structure.** The actual upstream `PMDCollab/SpriteCollab/sprite/0002` fetched from GitHub `master` returned **40 directory items, 37 relevant XML/animation/offset/shadow files**, **14 XML action names** (12 genuine animation PNG motions plus 2 CopyOf), **682 native animation frame locations**. Initial assumed ">=60 source files" assertion failed: recorded as `FAIL_ASSUMED_0001_FILE_COUNT_FOR_0002`, corrected to actual 37 without inventing animations.

For ALL 12 original actions and ALL 682 frame slots:
- Preserve exactly original 0002 canvas dimensions, action names, per-action frame dimensions, frame counts, facing direction rows, original XML durations, filenames, origin/pivot/foot placements and exact `AnimData.xml`, `-Offsets.png`, `-Shadow.png` bytes.
- Transform green leaf-backed seed/flower into visibly changed split **thick charcoal/gray basalt plates** with different silhouette. Two rocks sit either side of a visibly wider **hot orange/yellow magma fissure**, a clear next-stage change from the 0001 thin crack. New shell extends within the original frame cell, no newly added pixels on the frame boundary. Rock+lava colors are used in every frame.
- Warm orange/ash-gray body, not a beige-only recolor; original G4 draft had body too beige on side-by-side self-review, archived as visual self-fail. `G4R1` adjusts body toward the already user-approved 0001 orange/gray color direction.
- Every frame's alpha silhouette changes from its own original frame, and every frame has a measurable orange magma core. Source-level frame, alpha and original XML checks PASS: `12/12 genuine actions, 682/682 cells`.

Native runtime **Godot 4.7.2 XMLParser/OpenGL bridge** directly parses actual original PMD 0002 `AnimData.xml`, decodes and renders all 12 motion sheets + 682 original cell positions, produces three distinct GPU captures (original -Anim and revised -Anim share XML metadata), no engine ERROR or WARNING. Cold-unzipped ZIP used to rerun native Godot and source checks: PASS. This is **native Godot XML bridge compatibility**, NOT the original PMD game engine or RPG Maker VX Tankentai SBS import, so those latter gates remain PENDING.

## Downloadable actual source assets and QA
- Private **full source + edited atlas + Godot playable XML bridge + 3 GIFs + preview + scripts + QA LOG + Handoff ZIP**: https://drive.google.com/file/d/1PfvC7pNr6dASKSmHVkCUGoYO1h5J2XmK/view?usp=drivesdk
- 583,034 bytes, 176 files, SHA-256 `309a19d3be249411e7ec9e2c3d546638a00660c7e34a76bf4c8ac5b373f46818`, ZIP CRC, all cold SHA checks, cold source validation, cold Godot XML/GPU replay: PASS.
- [Actual original 0002 vs stage-2 orange-gray lava, 8 directions](https://drive.google.com/file/d/1IzdSZ9MBhKB-WNpqkHWnbfT54hWWX4Ht/view?usp=drivesdk)
- [Authentic 0001→0002 stage comparison](https://drive.google.com/file/d/1J9v9QoZI0TfiQ1_MeWAhNNEJUJUTjRnm/view?usp=drivesdk)
- [Idle XML-timed GIF](https://drive.google.com/file/d/1G57Vl7MK9tjf_ZPT2rg8CU5lOkmDUimM/view?usp=drivesdk)
- [Attack XML-timed GIF](https://drive.google.com/file/d/14cVtdYNJGW4bkqrAnxzu7D8QMiOUFnv4/view?usp=drivesdk)

## Status
- Stage1 `0001` **USER STYLE DIRECTION APPROVED**, native Godot XML bridge TECH PASS, official PMD and VX SBS PENDING.
- Stage2 `0002` **SOURCE/STRUCTURAL/NATIVE GODOT PASS**, **USER VISUAL PENDING**. Do not imply artist approval.
- Stage3 `0003` **NOT MADE**. Final stage design target: large fractured rock shell reveals substantial internal molten core, distinct stronger orange rock+fire species. When moving to it, fetch authentic *0003* source and own XML/offsets/shadows and inspect per-action frames instead of guessing a universal atlas or cloning 0002.
- Fan source distribution in private connected Drive only; copyright/attribution/commercial rights not established; no original PNGs on public GitHub.

## User scope / project safety
**F2 map production PAUSED** on user's request. No changes to Ground/PAR, actor-scale QA, VX native sealed F1R1 A04, or other project branches. Do not resume map work until user asks. Next PMD work: visually review G4R1 0002 candidate and/or begin actual 0003 source inspection, then stepwise morphology and genuine loader tests. Always ZIP + runnable CMD + LOG + Handoff, sync Drive/GitHub/Linear.
