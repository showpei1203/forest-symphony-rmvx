# PMD 0002/0003 — G7R1 Reset: BACK-MOUNTED Rock Keyframes
Date 2026-10-26. Scope: PMD SOURCE ART ONLY. FS/F2 maps PAUSED. PMD0001 G3R1 user-liked juvenile SEALED FOR THIS TASK.

## Baseline decision
The user found G6R4R2 visually worse: creature-body pixels and stone parts missing, fragments and disconnected/static rock elements. **G6R4R2 ART FAIL, NOT A SOURCE OR PRODUCTION BASELINE.** Do not reuse old petal-centroid-position algorithm, G6 sprite masks or cleaned sprites.
This fresh G7R1 starts from authentic original `PMDCollab/SpriteCollab sprite/0002` and `sprite/0003`.

## Exactly what was actually edited
**KEYFRAMES ONLY, not a complete sheet or full animation acceptance.**
For EACH species: Idle/Walk 3 directions (front D0, side D2, back D4), frames F0 & F1. Total **12 changed original action-sheet cells per species, 24 total**. Other 10 full action sheets are byte-identical to original; untouched Idle/Walk frames also pixel-identical. Original PMD `AnimData.xml`, all `-Offsets.png`, all `-Shadow.png` bit-identical.
- 0002: three solid individual rounded basalt pieces with mineral outline/highlights, connected via a dark back saddle and small magma vent.
- 0003: five heavier rounded basalt pieces with thicker dorsal saddle, stronger magma vent and tiny lava runoff.
- Use each ORIGINAL SOURCE FRAME'S *body-blue silhouette median*, with a per-direction dorsal offset, as mount root. Move all stones as a single rigid body-driven mount; allow only subtle coherent bob in Idle. **Do not track source flower / leaf centroids for motion**. Keep original XML motion timing/rows and foot anchor.
- Every source cyan-body pixel alpha is protected and preserved (0 lost in all 24 selected cells), original lower-four rows alpha unchanged, no newly opaque frame-border pixels. Source flowering/color material in upper back changed only outside protected blue-body pixels. Abandon any broad alpha erase through frog body.
- Initial G7 contact-sheet visual review found small detached old petal-outline flecks, especially near 0003 top. A separate G7R1 derivative uses guarded 8-connected component cleanup for only small detached non-body components in the upper ornament region. Earlier G7 test retained for negative QA.

## Measured self-QA and runtime
- 0002 12 sample cells, 0003 12, no other action-sheet edits. Each selected cell has actual pixel changes. Native original 32×32 frame slots and original 128×256 Idle/Walk atlas layout untouched.
- 0002 and 0003 body pixels deleted = **0** according to original source cyan-body pixel mask; original lower foot alpha byte-identical per frame. Mounted rock centers ALL move in selected F0→F1 samples in Idle and Walk for all 3 source directions. This is a structural motion check, **not a substitute for User Human Visual acceptance**.
- Original PMD metadata preserved. Godot v4.7.2 XMLParser + native GPU test **PASS on both**; independent cold-unzip SHA, source QA, real Godot import/GPU replays **PASS**. Native original PMD game and RGSS2/VX Tankentai SBS: **NOT TESTED**. User Visual Art: **PENDING**. Original SpriteCollab fan asset commercial/license/attribution unresolved.
- Do not falsely claim the full 682/698 actions were rebuilt this turn. Only 24 original cells modified; all others original.

## Verified private delivery
[Complete source, G7R1 two-species partial sample atlases, original XMLs, preview PNGs, GIFs, QA/logs, Godot test projects, runnable CMD, Handoff ZIP](https://drive.google.com/file/d/1VQT4SmXjr3W00b14IK-76Ga24HiT4wBY/view?usp=drivesdk).
Exact ZIP size 1,956,903 bytes, 479 members, SHA256 `3f78720842e72bfac4a9cb3cef984763fc8b521333efa9050708d066fc608059`, cloud copy SHA confirmed.
[Drive samples folder](https://drive.google.com/drive/folders/1jegrw9p2unTEHZB0INweFULBrGsctemU).
[0003 original vs edited sample contact sheet](https://drive.google.com/file/d/12qiTmRAwCsP8jJKWXyOsRyapwIrcfW2I/view?usp=drivesdk).
[0003 Walk short motion preview](https://drive.google.com/file/d/1GUTB3qsFL1rIdV3bUv2wz8VPfoaqaxQx/view?usp=drivesdk).
[Rule updates and G7R1 Current Handoff](https://drive.google.com/file/d/1SejHnCix4UMW3SG36nEz00LweyhTN6t3/view?usp=drivesdk).

## Hard fail-closed gates
Gate 1: body/cyan skin pixels intact (exact source alpha), source feet unchanged, no newly opaque sheet edges.
Gate 2: all individual stones solid/complete, no isolated old red petal outline fragments.
Gate 3: boulders have a plausible dark back-contact saddle, not floating cap.
Gate 4: all stones follow body mount F0→F1, no static piece while body moves; optional slight collective motion.
Gate 5: 0002 small 3-stone stage vs 0003 larger 5-stone stage unmistakably distinct.
Gate 6: **User Human Visual approval of these selected Idle/Walk samples** is REQUIRED before extending to all original 682/698 frames.

Future work must reproduce tests, collect actual user feedback and only after user approves expand each species' original XML-aligned action sheets. No more plans-only turns. F2 maps remain paused.
