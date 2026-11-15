# FS Map Art Roadmap | 2026-11-15 | A33 village → A34+ (planning checkpoint)

## Scope and branch safety
Godot 4.7.2 only. This document tracks **village map art**; do not confuse A33 village with the separate A36B/A36C large-forest workstream already documented in CURRENT_HANDOFF.md. Do not overwrite CURRENT_HANDOFF, A36 scenes, sealed A32/A33 scenes, or private art. No VX production. Private PNG/ZIP remain owner-only in Drive; GitHub contains source, scene references, manifests, tests only.

## Verified baseline from supplied A33 handoff (not re-executed here)
A33: 4 independent 52x124 lamp PARs, footprint collisions, A32 ground preserved, native checks reported 760/760, A32 regression 734/734, clean import, three CI suites reported passing; private Drive archive reported 155 members/61.5MB. These are *handoff-reported*, not freshly verified. User 1x art approval pending. PR #16 remains open/draft (checked 2026-11-15).

## Execution roadmap / gates
- A34 VILLAGE_HOUSES: Read A33 private original art and reference right-hand house; capture native 1x baseline; create two full coherent house source images (not stitched roofs/walls), transparent isolated PAR, building footpoint, collision polygon, occlusion. Compare 1x side-by-side, ensure outside house ROIs pixel diff zero, original ground SHA unchanged. 2 houses, 2 source images, 2 PARs minimum. ART HOLD until approval.
- A35 VILLAGE_FOREST: Extend coherent forest groves beyond viewport; diverse isolated tree silhouettes, independent trunks/canopies, edge clipping only at viewport not source; depth and trunk collisions.
- A36 VILLAGE_GROUND_DETAIL: Ground-only native-resolution roads, grass, flowers, stones; avoid blurry resampling; no arbitrary edits to house PAR. Validate original vs candidate; keep baseline immutable.
- A37 VILLAGE_OCCLUSION_NAV: CharacterBody2D traversal, trunk/building collision, roof/tree foreground masks, passability, automated path tests and native screenshots.
- A38 VILLAGE_MAP_HOOKS: Entrance and interaction markers with stable IDs and scene-change interfaces only; event/story/NPC logic owned by other workstream.
- A39 MAP_FACTORY: Repeatable source→Ground/PAR/shadow/collision/scene/manifest pipeline; SHA, cold rebuild, ROI pixel diff, Godot native QA, Failure Log, Drive/GitHub handoff.
- A40 VILLAGE_ACCEPTANCE: full 1x visual review, navigation and occlusion, native render, no regression, portable ZIP cold rebuild, source-only CI, user acceptance.

## A34 immediate actionable checklist
1. Read back A33 owner-only ZIP and baseline screenshot; verify source SHA and image dimensions.
2. Compare both houses to right-hand-house style reference and Ground3 at 1x; document exact visual defects.
3. Reauthor whole-house art separately for each building; no patchwork collage; preserve perspective, palette and 32px footprint.
4. Generate RGBA PAR and collision/occlusion metadata; never bake house into Ground.
5. Rebuild native Godot scene and compare against A33 at 1x, validate diff only within both house ROIs, plus footpoint movement and occlusion.
6. Package private images to Drive and code/tests to PR #16; run CI, cold rebuild, record PASS/FAIL/NOT_RUN and handoff.

## Current gates
A34 implementation NOT_STARTED in this checkpoint; source files not yet inspected or edited. ART HOLD. This is a roadmap commit, not a claim of new house graphics or Godot execution.
