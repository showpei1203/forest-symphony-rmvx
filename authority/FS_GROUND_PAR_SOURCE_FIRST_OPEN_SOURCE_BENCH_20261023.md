# FS Ground / Complete PAR Source-first Benchmark | 2026-10-23

**Track:** SHO-39 | Forest Clearing Benchmark I  
**Authority:** `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_2` (2026-09-21), current v3 prompt workflow, A–F validation gates.  
**Status:** COMPILED CANDIDATE / Godot HEADLESS LOGIC TEST PASS / HUMAN VISUAL & VX UNVERIFIED. **NOT FORMAL PASS.**

## Failure-mode prevention

- **Never independently generate Ground and PAR:** all pixels originate from accepted terrain/prop source assets, an integer-coordinate Scene Manifest, and a deterministic compiler.
- **Binary authoring export:** Ground is terrain only (grass/dirt/flowers); complete PAR contains **every** non-Ground object (including tree trunks, signs, rocks). Actor Occlusion is only a derived subset; collision is separate.
- **One-instance origin:** one source SHA and placement produce complete PAR, base, occlusion mask, collision, and Tiled tile-object.
- **Registration proof:** independently rasterize canonical scene TMX using open-source Tiled `tmxrasterizer`; compare **entire RGBA bytes** with compiler Master, canvas 544×416. No rescaling, independent repaint, or subpixel coordinate.
- **Strict content equality:** Pillow `ImageChops.difference(RGBA).getbbox()` can mask RGB defects when alpha matches; use `Image.tobytes()` equality across full RGBA.
- **Semantic witnesses:** audit high-risk object pixels and explicit structural contact geometry. Grounding DINO/SAM2 are **optional candidate/witness QA only**, never categorical Ground/PAR truth.
- **Negative regression:** inject 1px PAR drift, missing sign, Ground contamination, shifted occlusion, RGB-only difference with same alpha, fake checkerboard, blocked spawn, non-integer placement, and stale source hash. Fail-closed validator rejected all 9/9.
- **Source-art micro-repair:** cropped legacy rocks contained stray detached pixels; repair the smallest source crop, recompute hash, rebuild. Do not regenerate the entire map.

## Benchmark evidence (private Drive delivery; no copyrighted art in public repo)

- 544×416; 32px world grid; one dirt path; 3 short-tree **scale witnesses**, 2 rocks, 1 sign, 1 spawn.
- **Gate A–E: 50/50** checks positive.
- **Tiled** independent image strict RGBA exact equality: confirmed.
- **Godot 4.7.2** headless test: actor switches tree-canopy draw order front/behind; tree-trunk collision blocks actor; path motion remains clear; assets load. `GODOT_GATE_F_LOGIC_PASS`.
- **Gate F:** Godot interactive visual QA still pending. VX dedicated runtime import, collision/movement/occlusion still pending.
- Source license acceptance and larger FS style-family art are pending; pilot grass/dirt and two short broadleaf trees are scoped witnesses only.

## Local/private delivery

- Dedicated Windows lab: `E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2`
- One-click: `RUN_ALL.cmd`
- Reports: `logs/GATES_A_TO_E.json`, `logs/NEGATIVE_REGRESSION_TESTS.json`, `logs/GODOT_SMOKE.log`, `logs/RUN_ALL_SUMMARY.json`
- Google Drive: Forest Symphony / 08_Assets / 06_Compiler_Output / `FS_GROUND_PAR_V32_COMPILED_CANDIDATE_20261023.zip` (94 files, SHA in delivery log).
- Source-only GitHub text files may be stored in `tools/fs_map_v32_forest_smoke/` on the SHO-39 branch; no raw maps, graphics, or binaries should enter public GitHub.

## Next acceptance gates

1. Open the Godot scene with a visible renderer; inspect actor-under-canopy occlusion from several positions, stone/sign collisions, and no pixel blur.
2. Identify the original accepted VX runtime map adapter; create a standalone test build without touching SEALED Scripts or altering live `MapXXX.rvdata`.
3. Promote actual production tree family only after Style DNA and source license checks; benchmark remains intentionally limited to the one-path/tree mechanism.
4. Legacy flattened masters: validate witness structure, true alpha, source-pixel fidelity and recomposition; do **not** revive separate layer-generation calls or entire SAM2 union threshold shortcuts.
