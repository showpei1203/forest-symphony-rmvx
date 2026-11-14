# Forest Symphony Godot 4.7.2｜A36 Large Forest Ground-first (80×58)

Main scene `res://scenes/a36_large_verdant_forest_80x58.tscn`. Full original art and source-owned project are in an owner-only private Drive ZIP; **the public GitHub branch has intentionally NO private PNGs**. Old A35/A34 scenes are preserved for regression, but require corresponding owner-only art to run.

Full world 2560×1856; original generated Ground 1478×1064 resized with nearest to match 80×58 logic grid, explicitly ART HOLD for native pixel density. 326 fully independent complete PAR objects, separate contact shadow RGBA and tentative 148 water semantic candidate grid cells (NOT yet physical river-blocking). No NPC, event dialogue or battle written in this art conversation.

- Source files: `data/a36_large_verdant_forest_manifest.json`, `data/a36_terrain_semantic_candidates.json`.
- Visual: native Godot 2560×1856 framebuffer and four 1x quadrants, `qa_a36/`, private only.
- Rebuilder: `tools/a36/a36_build_large_forest.py` needs env `FS_A36_BASE_PROJECT` (A35 private project), `FS_A36_GROUND_SOURCE` (fresh original 1478×1064 image), `FS_A36_OUT_DIR` (new isolated output); NEVER overwrite A35 or user's PC.
- Source QA: `tools/a36/validate_a36_art_contract.py` (requires private art), `tests/test_a36_large_forest_real.gd` (Godot 4.7.2 real art), `tests/test_a36_large_public.gd` (source only, no private art).
- User request: prioritize visuals, large maps, six biome maze/village art. Events, NPC dialogue, story and combat are owned by another conversation.

See [CURRENT_HANDOFF.md](CURRENT_HANDOFF.md) and [A36 detailed failure log](docs/A36_LARGE_FOREST_GROUNDFIRST_HANDOFF.md). **Art HOLD / Collision HOLD / Formal seal NO.**

**Safety:** The R2 builder refuses to run if `FS_A36_OUT_DIR` already exists. Use an entirely new destination directory per rebuild. The published R1 ZIP is historical only; [safe R2 ZIP](https://drive.google.com/file/d/1LgUCJRi8i-NDz-EC1roXHWnBjNysjtuu/view) is authoritative.
