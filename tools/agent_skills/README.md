# FS Agent Skills | Isolated integration

The canonical Forest Symphony engine is **RPG Maker VX / RGSS2**. Godot is only a supplementary rendering/test adapter. Read [FS routing skill](../../.agents/skills/fs-rmvx-router/SKILL.md) and project authority before using generic upstream skills.

## Installed pilot
Machine: `DESKTOP-90VT437`
Working directory: `E:\FS_AGENT_SKILLS_PILOT_20261106`

The isolated pilot contains these complete upstream skill folders in `.agents/skills/`: `router`, `create-game-assets`, `procedural-gen`, `level-design`, `godot-tilemap`, `godot-gdscript-headless-testing`, `rpg`, plus the project-specific `fs-rmvx-router`. It does **not** modify A36F, PMD sources or sealed FS runtime.

Upstream: [gamedev-skills/awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) at immutable commit
`19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9` (Apache-2.0). Preserve upstream `SKILL.md`, subdirectories (assets/references/scripts) and license.

## Reproduce
Requirements: git, Python 3.11+ and Pillow 10+.

1. Clone upstream into a distinct, untracked pilot folder, and check out the exact commit (never use a floating `main`):
   `git clone https://github.com/gamedev-skills/awesome-gamedev-agent-skills.git E:\FS_AGENT_SKILLS_PILOT_20261106\upstream`
   `git -C E:\FS_AGENT_SKILLS_PILOT_20261106\upstream checkout --detach 19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9`
2. Use `tools/agent_skills/fs_asset_pilot.py` (copy from this repo into the pilot folder or run in place), providing `--upstream`, `--pilot`, `--fs-skill`, `--a36f`, `--pmd`. Set `--fs-skill` to the tracked `.agents/skills/fs-rmvx-router/SKILL.md`.
3. The script writes `outputs/FS_AGENT_SKILLS_PILOT_QA.json` and `outputs/PMD0001_0003_3FRAME_CONTACT.png`. Review each check; negative transparency gate must fail its deliberately opaque test input.

## What was actually demonstrated on 2026-11-06
- All 7 upstream skills copied with their complete source folders, plus 1 FS routing skill.
- A36F 1280x928 Ground/PAR/true-composite recomposition matched **exactly** in RGB.
- PMD0001-0003 three frames each, nine 128x128 RGBA PNGs; alpha checks and per-monster dimensions passed; QA contact sheet produced.
- Source SHA256 unchanged, negative alpha test correctly failed.
- **Not** demonstrated: agent auto-activation, new art production, native VX/Godot execution in this pilot, art acceptance, or improvement in rework rates.

## Guardrails
- Do not overwrite existing A36F or PMD source files.
- New map work follows Drive FS Precheck **v3.2** and the shared game-asset authority before generic skills.
- Skill QA is only metadata/read-only baseline QA. No artistic or in-engine PASS is implied.
- Rollbacks are isolated: removing the `E:\FS_AGENT_SKILLS_PILOT_20261106` pilot does not touch the FS source projects, GitHub main or canonical archives.

## 2026-11-06 follow-up: actual FS runtime PAR contract

Read [V2 validation handoff](../../experiments/agent_skills_20261106/VALIDATION_V2_HANDOFF.md) before claiming that Ground/PAR is engine-ready. The original RMVX Hanzo overlay uses full-scene `Graphics/Parallaxes/ground3.png` plus a smaller duplicate-pixel occlusion `Overlays/par3.png` controlled by `$game_switches[203]`. Authoring Ground-only + Complete PAR is a separate, valid source/manifest contract, **not** a drop-in native overlay. A36F R1 and A36G R5 failed this *runtime* contract even though their full scene pixel recomposition passed.

The read-only `fs_runtime_contract_v2.py` measured five source pairs and identified the false positives. The isolated `fs_vx203_locked_cases_v5.py` used real Game.exe and locked camera/actor positions; cases 4, 6 and 8 each passed OFF/ON actor occlusion, with source hashes unchanged. The `fs_pmd_motion_v2.py` report found foot-lock vs loop-motion tradeoffs; **PMD art, step alternation, full VX coverage and Formal Seal are not approved**.

Use named verdicts: `AUTHORING_PAR`, `NATIVE_203_ACTOR`, `COLLISION/TRAVERSAL`, `GODOT_SUPPLEMENT` and `ART_REVIEW`. A passing pixel comparison never upgrades another gate automatically. V2 screenshot/QA evidence and reproducible scripts are in the isolated Google Drive validation package.

V2 evidence folder (actual native screenshots, 22-member ZIP, SHA manifest and full QA): https://drive.google.com/drive/folders/1DWzNW1DPTeGzpoHtsgCFtdF3ySImiALV

## V3 native RPG Maker VX movement and full-grid verification (2026-11-07)

The next isolated run tested **real** RGSS2 `Game.exe` movement, not only the composite PNG. Native `move_*` sampled 12/12 passable/blocked cases with switch203 toggles. Four canopy exits received native start/end OFF/ON screenshots, with changed pixels W 625→119, S 368→0, N 627→232, E 454→1. The north exit remains partially occluded, so these results are **sample engineering gates**, not final art approval.

A new 40×29 exhaustive native `Game_Player#passable?(x,y)` grid audit matched **1160/1160 cells** (927 free, 233 blocked); `move_passable?(xo,yo,xt,yt)` matched **3576/3576 valid directed edges**. A first V10 scan had a false-negative at player spawn (20,14) caused by self-collision; in V11 the actor was temporarily parked at known blocked (3,6) inside a fresh isolated copy. The V6 script also failed with a three-argument `passable?` call because FS inherits `ISS - ParaPassa`; this was corrected in V7. A place-name HUD animation polluted early screenshots until V8 introduced a 280-frame warmup. **Preserve these failure logs as part of the test specification.**

- [V3 Handoff](../../experiments/agent_skills_20261107/VALIDATION_V3_HANDOFF.md)
- [Native grid QA evidence](../../experiments/agent_skills_20261107/FS_V11_NATIVE_COLLISION_FULL_GRID_QA.json)
- [Full Drive archive, screenshot contact sheets and SHA manifest](https://drive.google.com/drive/folders/1LMcN1IhvvhcY09i2IWUFJuDdE6eyHlWF)

A36F/A36G visual acceptance, full semantic occlusion signoff, PMD motion art and Formal Seal remain **NO**. Do not use any V3 results to approve A36G R5 or any newly generated art.

## V4 canonical visual/style benchmark and negative occlusion gates (2026-11-07)

After V3 native movement/collision PASS, the next focus was A36G art and PAR semantic quality. The true canonical **`FS project/Graphics/Parallaxes/ground3.png`** is the visual authority; `Overlays/par3.png` is the same-coordinate original HK-UOM actor occlusion, and **`Overlays/ground3.png` is not the visual master**. R5's thatched cottages and dark/dense forest have **not** passed user art acceptance. No new PixelLab generation was performed.

Two isolated A36G R6 technical derivatives were generated from **192 source object PNGs** and same-source full-scene RGB without mutating R5: C1 had a severe 32px pixel lattice and 34.419% occlusion coverage; C2 smoothed sampled actor foot rectangles but grew to 52.761% with blocky regions. Both are **FAIL** on mask semantics despite exact source registration. They were **not engine-tested** under fail-closed gates.

The actual reusable deliverable is a **4-view exact-source 544×416 Ground3/Par3 registered reference kit**, cropped on 32px boundaries, with original Ground + Alpha PAR, witness visualizations, per-pair SHAs, and diagnostic coverage. Read [V4 Handoff](../../experiments/agent_skills_20261107/VALIDATION_V4_STYLE_HANDOFF.md) and [C1/C2 artifact gate](../../experiments/agent_skills_20261107/R6_C1_C2_MASK_ARTIFACT_GATE.json).

Google Drive original reference kit, V4 ZIP, screenshot and SHA manifest: https://drive.google.com/drive/folders/1RoEMM8zihWvYhwf6tdM6rnpOsShkYgRt

**Do not re-enable PixelLab style-reference chains or automatic forest_group footprint-only occlusion** without per-tree/per-roof source semantic masks, 1× art confirmation, and original HK-UOM switch203 proof. Current R5 art = FAIL. Formal Seal = NO.

## V5/V6 true original roof/tree witnesses + A36G per-object native switch203 (2026-11-07)

The canonical original `ground3.png/par3.png` was used to extract *two narrow native occlusion witness ROIs* (house roof and tree crown), preserving original RGBA alpha, original exact witness pixels, and a separate same-source Ground-RGB-normalized test overlay. On **actual RPG Maker VX Game.exe**, fixed view, and genuine HK UOM ParSwitch203, roof (8,4) changed **627 actor pixels**, tree (14,1) **625**, and clear negative control (11,10) **0**: **3/3 sampled native PASS**.

The same per-asset method was applied to genuine independent A36G R5 sources: **one integrated left house/workshop PNG** and **one source tree_003 PNG**, with source-specific roof polygon/HSV masking and tree crown/HSV alpha semantics, no 32px walkable-actor grid lattice, no forest_group footpoint-derived mask. Preserve Authoring GroundOnly/CompletePAR while making `RUNTIME_FULL_SCENE_GROUND50` + `RUNTIME_PAR50_ROOF_TREE_ONLY` from exact same-scene RGB. Native house (15,10) changed **627**, tree (22,1) **434** (partial concealment), clear control (20,14) **0**: **3/3 sampled native PASS**. Candidate combined mask coverage **1.5584%** pertains to **only those two objects**, not whole map.

**Limits:** original witness ROIs are not whole isolated art assets. A36G V6 C1 roof polygon was incomplete; revised C2 mask remains ART UNVERIFIED. The 203 tests use a Map50 cloned from A36F with **A36F collision metadata**, not A36G R5's 241-blocked-cells manifest, so no A36G movement/collision Gate is proven. Historical R5 rejected-house style is still **ART FAIL** compared to approved FS Ground3. No Godot rebuild this round, no paid image generation, Formal Seal **NO**.

All reproducible scripts, JSON QA, real OFF/ON screenshots, exact source-masks, separately preserved Authoring/Runtime layer PNGs, full SHA manifest and failure history are in [Drive V5/V6 complete package](https://drive.google.com/drive/folders/1icyJePPf_nglB6ZUfJqrB4NE2tIzpeqa) and [V5/V6 Handoff](../../experiments/agent_skills_20261107/VALIDATION_V5_V6_PER_OBJECT_NATIVE_203_HANDOFF.md). Avoid scaling to all 192 objects until per-source semantic QA is approved and collision data is built for the matching scene.

## R7 source-owned semantic masks and **real A36G Map050**, 2026-11-07

The earlier V6 `tree_003` sample was a **source-ownership false positive**: RGSS ParSwitch203 toggled, but only **5.12%** of its opaque original source pixels actually survived in the final master scene; `tree_056` only **1.92%**. Do not promote an invisible source alpha into foreground merely because its native ON/OFF sample hides a character. See the [V6 Handoff erratum](../../experiments/agent_skills_20261107/VALIDATION_V5_V6_PER_OBJECT_NATIVE_203_HANDOFF.md).

V12 rebuilt a real cloned RMVX `Map050.rvdata` table layer-2 (tile ID 768 blocked / 769 walkable) from the **A36G R5** manifest (12 cells differ from A36F). Original engine `Game.exe` + ISS ParaPassa validated **1160/1160 tiles and 3544/3544 directed edges**, with 919 walkable and 241 blocked, no engine method override. R7 compiled a candidate of **two house roof sources and three truly visible tree source masks** with source ownership >99%, keeping authoring GroundOnly+CompletePAR separate from the runtime full-scene Ground50 and five-object Par50. Native real-R5 Map050 static OFF/ON **6/6**, dynamic step-to-clear **5/5**. Only five of 192 object overlays were tested and A36G's existing art remains rejected.

[GitHub R7 Handoff](../../experiments/agent_skills_20261107/VALIDATION_R7_REAL_MAP050_5SOURCE_HANDOFF.md) | [Drive full 51-file package including source PNG, native Map050 and contact images](https://drive.google.com/drive/folders/1ZDnzVEtFh2SbcJ4vyZqOkFrGjPJ9AOBl). Formal Seal **NO**.

## A36H R2: **real** visual Ground/PAR art candidate from approved FS Ground3, 2026-11-07

Unlike detached concepts, this trial edited actual **one-piece left/right RGBA house sources**, **59 real tree sources**, **44 forest-group depth slices**, and actual semantic **GroundOnly** color with the canonical `Ground3` wood/grass/path palette as reference. Initial brown-roof V1 failed visual inspection because of the inherited shaggy green thatch; V2 rebuilt native-sized wood plank pixels and fixed much of the missed mask. Building outlines are *still* the generated R5 architecture, so final art acceptance is pending. R1 **recompiled R5 192 original sources with 0 pixel difference** before modifying **105 independent sources**, then R2 authoring Ground/Complete PAR and runtime FullGround/5-source Par were compiled and exact RGB checked. R2 grass medians [120,161,10]→[104,146,21], path [214,185,100]→[198,161,81]; actual VX Game.exe 203 6/6 PASS, A36G R5 Map050 collision unchanged. **Not** full-map occlusion, not R2 dynamic movement, not complete ground/forest structural improvement, not art signoff or Formal Seal.

Review the [true before/after screenshot](https://drive.google.com/file/d/1DmKASErGKYu-Kd1SfomH_Xr_pOunzvB7/view), [source-layer ZIP (247 files)](https://drive.google.com/file/d/1qFIL_AYRSw6mdos2uTa1pnaD-S_tQGEo/view), and [A36H handoff](../../experiments/agent_skills_20261107/VALIDATION_A36H_R2_ART_GROUND_PAR_HANDOFF.md) before any promotion. Do not use unrelated automatically generated stock art as the proof image.

## A36H R3 private art trial (2026-11-07)
R2→R3 actual pixel source edits: roof rake/eave trim (floating fascia and alpha-hole variants rejected), 44 forest depth slices restored into seven coherent edit canvases and re-sliced after 9,040 tiny hole repairs, five 1× actual tree sprite additions on native-blocked roots, 197 full scene source RGBA files and exact GroundOnly/CompletePAR/runtime FullGround recomposition. Full-scene 50,590 changed pixels; **quality still PENDING**, not full silhouette repair. Native Game.exe existing 5+1 static 203 gates = 6/6 PASS, new trees and full 197-object occlusion NOT RUN. Formal Seal=NO.
[Actual R2/R3 visual comparison](https://drive.google.com/file/d/13eFAh5OELi78DPHjTLg_9q4EvQdfDcp2/view) | [Full private 277-file artifact](https://drive.google.com/file/d/14jk6aMntJSIQU7mLXZWfGafmlJEPHxXn/view) | [R3 Handoff](../../experiments/agent_skills_20261107/VALIDATION_A36H_R3_ROOFS_SEVEN_FOREST_HANDOFF.md).
