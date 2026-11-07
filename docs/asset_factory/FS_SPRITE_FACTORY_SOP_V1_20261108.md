# FS Sprite Factory SOP V1 — PMD / Actor production, not one-off image retouch
Authority: A08 report audit + actual FS sources + user approval. Version 1.0, 2026-11-08.
Goal: reproducible series of 45-degree battle Actor sprites and PMD monsters with evolution/family identity. Production loop: spec -> approved templates -> batch -> QA exceptions -> native export -> art/native seal.

## S0 source rights, approved art, and immutable reference
Inputs MUST be referenced by source ID, actual source SHA256, approval scope (appearance, pose, animation, native), and private Drive path. Never guess missing images or call old original_0001 lava art.
For A25 monster: approved LOOK/reference only, actual binary missing verification. A26 five-frame Idle/Walk art is NOT approved and differs from native 3f/6f. Halt production generation until approved concept source is actually located or new concept is explicitly approved; record SOURCE_HOLD.
For A62 Actor: 48x48 run keypose reference accepted for one action; do not extend to all Actor/PMD/magic motions.

## S1 style bible; freeze once per family
Required: source-approved character concept, 45-degree combat camera, scale/proportion relative to original character, silhouette readability at 1x, allowed palette or palette reference SHA, outline/lighting method, transparency rule, species/evolution visible change, unarmed base for humanoid; paper-doll weapon attach point stored separately.
Do NOT invent exact HEX colors, anchor pixels or user-approved family identity. Lock first 1x contact sheet and palette before batch.
A visual change must be recognizably a different species/evolution, not hue swap. Three evolution tiers must show distinct silhouette/parts with cohesive family traits.

## S2 asset family archetypes / safe parameterization
Template family ID -> rig and ranges -> approval:
- humanoid_small, humanoid_medium, humanoid_large (3-keypose Actor family; unarmed base);
- quadruped_small/large, flying, blob, serpent, boss (PMD source XML per monster).
Parameterize species, palette ID, equipment layers, proportion bounds, camera and approved seed. If body topology changes, create a new rig family rather than distorting old bones. Separate base body from independent effects/weapon/shadow layers.
A monster evolution chain has a shared family-style anchor but independent approved topology per level.

## S3 exact native capability profile BEFORE PixelLab
There are two DIFFERENT FS export targets:
(A) PMD native: consume real AnimData.xml; per-action FrameWidth/FrameHeight, Index, Durations, Rush/Hit/Return events, CopyOf aliases; 1 or 8 physical rows, separate Anim/Offsets/Shadow. Example source PMD0001: Idle 32x40/3 frames, Walk 40x40/6 frames, Attack 64x72/11; PMD0002 Idle+Walk 32x32/4f each; PMD0003 Idle+Walk 32x32/4f each. Never replace native timings with PDF's sample FPS or universals.
(B) FS Actor battle: three STORED PNG keyframes named action_1.png/_2/_3.png, action-specific playback sequence. Loop can be 0,1,0,2 for left/right run cycle; linear attack/death may be 0,1,2 etc. Approved A62 reference is 48x48, while separate original VX town-walking char is 32x32. Distinguish exports. The battle renderer's actual sheet layout must be separately verified.
Action direction-row ordering and weapon-layer anchors MUST come from approved FS sample/runtime, not inferred from compass convention. "8 rotations produced" is NOT automatically "native 8-row order correct".

## S4 canonical source asset bundle (tool-agnostic)
Private project:
  approved_concept.png + style_reference.png + reference_sha256
  archetype_motion.json + palette_reference (or pending)
  canonical_manifest.json
  directions/<explicit_direction_id>/source.png
  animations/<action>/<direction>/<pose_or_frame_index>.png
  rig/<family>.json or reference skeleton images
  preview spritesheet / GIF with unchanged actual scale
Public metadata may contain SHA, ratios and rules, but never protected pixels.
Source manifest must distinguish generated-by provider ID/version, seed, batch, edits, chosen output, credit cost and approval status.

## S5 generation strategy in PixelLab (non-automatic paid stage)
After S0-S4 pass and an explicit bounded budget:
1. Create ONE approved reference per family (or use approved original for an Actor replacement instead of generating a concept).
2. Generate/preserve actual needed 4 or 8 directional views using compatible camera/top-down, body type, one style profile. Prefer PixelLab persistent character / 8-direction Pro if supported; retain ID. NEVER fabricate directions by mirroring or repeated 45-degree pixels and call them distinct.
3. Choose saved skeleton/motion template by archetype and action; match original reference pose, body size and key-pose anatomy. Use skeleton->model pixel redraw, not fractional mesh warp.
4. Batch produce only a bounded small PILOT: one Actor three-pose loop and PMD one Idle+Walk pair as distinct tasks. Save generation result and all provider metadata to private Drive.
5. For special evolution family, use persistent character state/skin/controlled proportions rather than restart unrelated text prompt. Escalate topology when needed.
6. Never generate more entire actions to fix one bad pixel: exception-only local inpaint after QA identifies the frame + direction + exact failure.

## S6 normalization / canonical sheet
Preserve transparent straight alpha and fixed target cell per action. Nearest-neighbor integer rescale ONLY when a separately approved FS conversion calls for it; otherwise no rescale. Fixed feet_center / source-derived pivot and shadows, body baseline, no naked/suddenly missing armor frames.
One canonical frame is not one PMD native cell: normalizer may add padding/reposition within authentic frame geometry without altering source silhouette; each conversion maps explicit direction row IDs.
Store action FPS/duration as metadata; do not infer from sheet row count. PMD native durations remain XML values unless formal animation design revision is approved.

## S7 automated technical and motion QA
HARD FAIL (objective): missing filename, missing/duplicate direction, wrong native XML counts/size, invalid PNG/alpha, empty frame, inconsistent atlas rows, unpinned source SHA, missing shadow/offset, wrong CopyOf, frame exceeds bounds, incorrect loop sequence, unauthorized budget, unapproved generation source.
ADVISORY/MOTION EXCEPTION (threshold calibrated from approved asset, not one universal number): palette drift, pivot vertical jitter (>1px proposed baseline), adjacent bounding-box change (>15% suggested), silhouette IoU, alpha centroid, suspicious frame change ratio, loop closure, arm/leg swapping and sex/naked frame. Report PDF thresholds as initial proposals only; original legit nearly static PMD frames must not be automatically rejected.
VISUAL HUMAN/ORCA: actual 45-degree face, one left and one right advancing foot, torso movement, correct weapon anchor, 1x pixel crispness, identity and evolution distinctness, attack/crit/idle action semantics.
Review output is exception entries, not entire repeated contact sheet inspections.

## S8 exception-only repair and stop rule
Each failure entry includes source SHA, family, action, direction, frame, actual vs expected, whether fix is generation / skeleton / export / approved source, and number of retries. Permit ONE localized inpaint/correction after a template has passed. Repeated same-class failures across >=2 assets mean STOP batch, fix archetype template, no more individual frame edits.
Regression test that exact earlier naked frame, same-left-foot run, incorrect dodging facing, PMD CopyOf and duplicate 8-direction faces do not recur.
High-level art disagreements (proportion, identity, style) always return to concept/style reference, not minor repairs.

## S9 native exporter and native checks
PMD: call existing pmd.py and native_action_export.py, matching XML dimensions and native per-direction row order; reconstruct full Anim, Offsets, Shadow; do not invent unsupported frame count or events. Technical PASS_STATIC_ONLY says nothing about accepted art.
Actor: action_1/_2/_3 with declared playback, keep unarmed body and independent weapon paper-doll; verify native Tankentai/SBS, not just a Python GIF.
Do actual RPG Maker VX Game.exe (not only Godot) with separate scoped Windows temp authorization. Capture true 1x direction/pose/switch/loop/native logs, source sha and artifact title. If not authorized: NATIVE_NOT_RUN, no formal seal.

## S10 batch scaling and measured KPIs
Before volume production: two distinguishable sprites, minimum two actions each, user approves 1x identity and motion, native loader accepts one representative sheet. Track source approval rate, real direction coverage, frame reuse, first-pass technical PASS, first-pass art PASS, average exception count, actual credits per approved action, actual time/asset and native regressions.
PDF capacity targets 30-80 sheets/day etc are research goals, not production commitments. First calibrate on >=20 assets. Trial budget starts at zero until explicit capped authorization.
Never use quantity of synthetic CI tests as productivity metric.

## S11 version/provenance and deliverable gates
GitHub: code, canonical profiles, public non-sensitive manifest schema, synthetic fixtures, CI and Handoff.
Restricted private Drive: original copyrighted sources, all sprite PNGs/GIFs and actual provider receipts. Write -> readback -> SHA.
Separate statuses for SOURCE, TECH_FORMAT, MOTION_AUTO, ART_HUMAN, NATIVE_VX, CLOUD, COST. APPROVED requires all relevant gates, not just a green workflow.
No new PC persistent files; if Windows temporary runtime is necessary, request separate explicit scope/cleanup approval.

## S12 pilot acceptance / immediate job IDs
S-P1: ACTOR01 A62 known source 48px run: reconstruct action_1/_2/_3 and loop 0/1/0/2 via canonical manifest, verify historical approval and native target distinctly. NO regeneration of concept.
S-P2: PMD0001 original XML Idle 3f Walk 6f: metadata-only build and native roundtrip now, ART_SOURCE_HOLD for A25 actual lava concept. Do not pass "8-dir new creature" without 8 true approved appearance views.
S-P3: reusable humanoid_small and quadruped_small skeleton templates (from genuinely approved poses) with PixelLab no-pay dry-run generation plan. One controlled provider batch only after budget and source approval.

## Official docs checked
PixelLab Pro 8-dir https://www.pixellab.ai/docs/tools/create-8-rotations-pro
Skeleton https://www.pixellab.ai/docs/tools/animate-with-skeleton
PixelLab Characters https://www.pixellab.ai/docs/ways-to-use-pixellab
Aseprite CLI https://www.aseprite.org/docs/cli/
