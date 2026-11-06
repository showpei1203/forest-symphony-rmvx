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
