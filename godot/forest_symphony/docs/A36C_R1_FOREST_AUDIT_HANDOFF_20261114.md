# A36C R1 | Godot-only forest ecology audit | 2026-11-14

## Authority and scope
- Active art branch: `feat/fs-godot-first-a29-20261113`, Draft PR #16.
- Godot 4.7.2 ONLY. No VX builds or VX testing.
- Current source: `godot/forest_symphony/data/a36b_ecological_tree_manifest.json`; real scene `scenes/a36b_large_forest_tree_ecology_80x58.tscn`.
- Active Master v1.3: Ground-only -> fully independent transparent PAR -> SHADOW/LIGHT/WATER -> Godot native runtime and 1x art gate.
- A36B R2 remains immutable baseline. Private images/ZIP owner-only Drive; public GitHub source-only.

## Changes in this round
- Added `tools/a36c/audit_tree_distribution.py`, a read-only stdlib script for 320x232 observation bins, species dominance, nearest foot distance, and intentional off-canvas tree positions.
- Initial assumption all tree footpoints were inside the world was invalid: off-canvas forest extension is intentional. Corrected script to accept -512..world+512 and preserve negative bin indices. No original art or scene mutated.
- GitHub commits `e8c27448`, `5f900612`.

## Direct manifest inspection
- 326 total independent scene objects; 310 tree objects; 6 tree families.
- a35_oak_summer 155 / 310 = 50.0%, a35_oak_golden 41, a35_birch_blush 39, a35_birch_cream 13, a36b_moss_pine 40, a36b_river_willow 22.
- This is a source-manifest distribution finding, not a visual art judgment.
- Do NOT blindly reassign trees. Existing ecological placement, walkable routes, roots and deliberate edge overhang must be retained.

## Gates and evidence
- Manifest parsing and counts inspected from live PR #16: PASS.
- Script committed: PASS.
- Script execution in Godot runner: NOT RUN.
- Native Godot A36C scene/1x screenshots: NOT RUN.
- New independent tree PNG species: NOT CREATED.
- Native collision, PAR, water, source hashes: unchanged and NOT RETESTED.
- Art HOLD, Collision HOLD, Water animation NOT_IMPLEMENTED, formal seal NO.

## Next concrete engineering step
1. Read back the current source and run the audit against the real private A36B manifest in a disposable environment.
2. Generate A36C placement proposal with ecological zone constraints and preserve exact old baseline. Produce manifest diff; no visual claims yet.
3. Add 2-6 truly distinct complete transparent RGBA species sourced from approved original reference art, not mere color swaps/mirrors. Validate full silhouettes, original size, source SHA, consistent palette.
4. Rebuild Godot scene as a new variant without overwriting A36B; keep original Ground SHA and independent PAR/SHADOW; run real native 1x comparison, walkability, footpoints, YSort.
5. Upload owner-only ZIP and evidence to Drive; GitHub safe scripts, QA, Failure Log and updated Handoff; only declare PASS with actual evidence.

## Failure log
- F-A37-001: prior assistant used obsolete VX handoff, wrong 1280x928 baseline, wrong Master-first; corrected and superseded.
- F-A37-002: prior assistant treated generated concept imagery as production progress; forbidden.
- F-A36C-001: audit initially rejected off-canvas tree feet; fixed without changing scene.
