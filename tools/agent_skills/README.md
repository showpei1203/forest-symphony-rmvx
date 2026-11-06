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
