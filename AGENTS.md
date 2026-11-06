# Repository Agent Rules

For any image generation, image editing, game-art asset production, parallax/master-scene generation, sprite generation, icon generation, or visual-asset prompt work in this repository, **read `ASSET_GENERATION_PRECHECK.md` before generating or editing any image**. Follow its required read order and the linked shared Google Drive authority.

For any runtime, AutoRegression, validator, generator/compiler, long-running tool, automation, or test-harness design/change, **read `BACKGROUND_EXECUTION_AUTHORITY.md` before implementation**. Background-capable execution is a permanent project requirement; losing foreground focus must not unnecessarily stop automated progress. Do not use unsafe threads as a shortcut, and preserve existing SEALED/runtime safety rules.

Pure documentation work that changes neither visual assets nor executable/runtime/test/tool behavior does not add extra preflight beyond the existing project authority.

## Forest Symphony Agent Skills routing (2026-11-06)

For Forest Symphony / RMVX / RGSS2 / A36F-A36G Ground-PAR / PMD or ACTOR sprites, **read `.agents/skills/fs-rmvx-router/SKILL.md` first** before any generic `router`, `create-game-assets`, Godot, or procedural generation skill. It holds FS-specific precedence, engine identification, preserved art and runtime acceptance gates. A nested `project.godot` is not evidence that FS runs primarily on Godot.

Upstream game-dev skills are pinned and installed separately using `tools/agent_skills/fs_asset_pilot.py` into an isolated pilot directory; never silently auto-upgrade the upstream dependency. Reference evidence: `experiments/agent_skills_20261106/CURRENT_HANDOFF.md`. Installation is not artistic approval or proof of a new VX/Godot native test.
