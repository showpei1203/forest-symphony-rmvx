# A08 -> A12: Asset Factory execution queue and acceptance contract
Date 2026-11-08. Precedence: user brief, FS P0-P5, A08 report audit, Sprite SOP + Map SOP. This is NOT a calendar promise or autonomous background execution.

## Actual A08 deliverables (current stage)
1. Page-by-page 22p source audit, with unknown report assumptions replaced ONLY by verified native FS contracts.
2. Sprite SOP: approved references, archetype family, 4/8 directions, persistent character/pose/skeleton, native PMD vs Actor mapping, auto QA, exception-only repair, source/private cloud.
3. Map SOP: reusable Wang/path/decoration/source semantic object kit, coherent whole Master-first scene, correct 4-layer FS export, collision/depth/nav, scene-scale art QA.
4. Public machine-readable templates: FS_STYLE_BIBLE_V1.json, FS_SPRITE_ARCHETYPES_V1.json, FS_MAP_SEMANTIC_FAMILIES_V1.json.
5. Four cost-zero pilot manifests: A62 Actor run, PMD0001 Idle+Walk, elf village V3, independent (NOT GENERATED) bridge/forest second layout.
6. Executable production_gate.py + run_a08_pilot.py and synthetics that demonstrate budget/false-art/false-native and forbidden foreground semantics are rejected. They are not image engines.
7. Verified GitHub CI on latest feature-branch HEAD, Drive rule/Handoff and authority index readbacks. Keep main sealed and PR Draft.

## Four work lanes with shared batch template
| Lane | Inputs | First art-bearing output needed | Machine gate | Human/native gate |
| --- | --- | --- | --- | --- |
| S1 Actor | approved A62 48px run F0/3pose; 45-degree unarmed; source SHA | Canonical Moving_to_Close_Attack _1/_2/_3, independent weapon/equipment layers | 3 distinct frames, playback [0,1,0,2], anchor/delta/silhouette, approved pose source | true Tankentai native Game.exe + 1x art |
| S2 PMD | real PMD0001 XML Idle 3f Walk 6f, candidate A25 lava look pending binary lock | true appearance-approved 8-direction Idle and Walk with valid Anim/Offsets/Shadow | native frame counts, direction semantic IDs, offsets/events/shadow, no impostor rows | PMD native renderer/Game.exe and user art |
| M1 Elf village | FS Ground3 art source, V3 Master candidate, whole house and canopy families | NEW coherent whole-scene Master + semantic instance masks + 4 FS image layers | source RGB/ownership, 32px grid, roads, collision, visual-negative cases | 1x scene aesthetic approval + native Game.exe switch203 |
| M2 Forest bridge | same approved style and canonical family kit, DIFFERENT seed/layout from village | NEW second Master with bridge object kit split deck/near/far rail (not reusing V3 scene) | no bridge-deck/grass in near-rail, terrain transition, 4-way route, masks | 1x scene art + native 203 on legal footpoints |

## Work stages (not generic iteration numbers)
A08 FACTORY CONTRACT (now): approve source/schema/handoff, auto dry-run 4 manifests, zero provider charges.
A09 SOURCE-LOCK AND ART BRIEF: locate private A25 approved look and Ground3 exact visual style; choose source SHA and allowed palette; build archetype reusable rig + semantic scene object kits. If unavailable, record explicit SOURCE_HOLD and proceed on a different historically approved sample, not an unapproved substitute.
A10 TWO-LANE GENERATION PILOT: once explicit budget, perform one bounded PixelLab run per family, preserve provider IDs, references, seeds and exact credits; prototype two distinct maps with shared terrain/object kit and both canonical sprite targets. No unapproved calls; map can be partly generated with Tiled/accepted reference kit.
A11 NATIVE EXPORT/SEMANTIC QA: original PMD XML plus Actor format adapters; Master-first four images and collision. Independent Orca reviewers in verified safe read-only; native Windows clone only after separate authorization and cleanup. Each lane must show actual screenshots from Game.exe/native renderer and art verdict.
A12 CONTROLLED SCALING: only after S1+S2+M1+M2 reach native + art gates, do 5-10 seeded variants; then observe 20-asset first-pass success, exception ratio, credits and turnaround. Scale batch only if repeatability > one good example.

## Hard stop rules (per user's explicit feedback)
- A scene that looks unlike Ground3 at 1x STOP: global style-source/template issue, not locally repainting a roof corner.
- One bridge front-rail mask containing bridge-deck pixels STOP: source semantic object generation wrong. Do NOT try V3/V4 GrabCut tweaks.
- A monster's fifth candidate Idle frame vs three native XML expected STOP: action template mismatch; do NOT repeat/skip frames to fake native.
- A body motion with same foot moving twice STOP: shared locomotion skeleton/pose error, not per-character random patch.
- Any "CI PASS" claimed as user ART PASS or Game.exe PASS is prohibited.
- After one exception repair fails or the same class recurs in two assets, fix family/palette/prompt/source contract before further paid generation.

## Measurable pilot acceptance
Sprite per asset: correct native cell & action sequence; every required direction *visually* unique and identity consistent; anchor <=1px proposed advisory; silhouettes/normal frame deltas benchmarked against approved original, no duplicate-frame false positives; 1x review; correct gameplay action semantics; native loader.
Map per scene: composition/detail naturalness/roof integrated; full SOURCE semantic object ownership; foreground leak zero for forbidden classes; exact RGB/XY; collision graph + meaningful player route; 1x actor occlusion; native Game.exe true traversals. No "all Authoring PAR should occlude".
Business-like operation KPIs: first-pass technical rate, first-pass ART rate, average exceptions per accepted asset, credits per approved action/map, manual intervention minutes, native regression rate. Report's 30-80/day is aspirational, never treated as measured FS throughput.

## Role assignment and security
ChatGPT owner: source authority, profiles, code, dry-run CI, exception routing, cloud Handoff, verifies both work lanes.
PixelLab: style-controlled art, real directions, saved rig animation, terrain Wang/procedural kit only when budget explicitly approved and provider tool actually connected.
Tiled/Pixelorama/Aseprite: canonical editor and batch sheet/map export, not FS format source of truth.
Orca independent reviewer S1 (Sprite), M1 (Map): source-locked adversarial acceptance, read-only mode MUST be demonstrable; no unsandboxed write path to user PC. If unavailable, status NOT_LAUNCHED, not pretend delegation.
Native Windows Game.exe: requires separate explicit temp workspace authorization, upload hash-verified results and cleanup. Default NOT_RUN.

## Deliverable & rollback
Protected source PNG/ZIP in owner-only private Drive; GitHub only non-secret source/schema/CI and Handoff; master remains frozen. Use WRITE->READBACK source SHA for each artifact; never merge PR #15 or replace sealed main without explicit approval.
When new chat begins, read A08 audit, both SOPs, this queue, and CURRENT_HANDOFF. Advance each lane to its first actual asset, not more one-object masking.
