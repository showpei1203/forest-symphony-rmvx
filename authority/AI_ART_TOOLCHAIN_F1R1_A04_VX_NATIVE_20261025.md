# F1R1 A04 — New 32px Forest from Source → Tiled + Godot + RPG Maker VX Native

Date: 2026-10-25. Authority branch: `feature/ai-art-toolchain-pilot-20261025`.

## Result (strict scope)
- F1R1 new forest scene remains a **human ART candidate**, not FORMAL SEALED FS.
- Source: 544×416 new procedural pixel Ground with new grass/dirt-road topology (source texture training from approved V21 samples, not old Ground bitmap copy), 8 separate **reused approved** sprites. No claim of new AI-generated monster evolution chain or new commissioned props.
- 18 blocked/203 walkable on 17×13 grid. ASF built-in compiled image, Tiled native rasterization and Godot 4.7.2 RX6700XT actual GPU all RGBA exact 0 vs F1R1 reference, after 191-pixel art order bug was fixed.
- Godot direct physics 221/221 native point tests PASS, Y-sort tree behind/front 6/384 magenta indicator visibility. Godot cold unzip reimport + physics PASS.

## NEW: Actually executed RPG Maker VX Game.exe on Windows
- Copied **only the legacy isolated VX native test template**, never altered sealed FS game or other project's P1G source.
- RGSS2 `FSRich` script adapted into isolated `Data/Scripts.rvdata` from separate 8 props, new Ground bitmap and 18 blocked tiles.
- Native VX `Game.exe` was launched and wrote signed on-disk log:
  - `RICH_SCRIPT_LOADED sha=...`
  - `RICH_VX_BOOT spawn=[8, 11]`
  - `STYLE_VX_LAYERS ground=544x416 props=8`
  - `STYLE_VX_CAMERA offset=0,0 world=544x416`
  - `F1R1_VX_TILE_GRID result=0 blocked=18 walkable=203`
  - `F1R1_VX_NATIVE_GATE steps=true denied=true props=true camera=true`
  - `F1R1_VX_NATIVE_221_221_PASS`
- Native test harness only terminated **its own Game.exe** after signed PASS. Process termination exit code 1 is expected harness-initiated, not a crash and not an image Gate.
- Cold extracted A04 bundle into a fresh directory, reran **actual native VX Game.exe and its 221/221 RGSS2 verification** successfully. Independently reran fresh Godot texture import and its 221/221 physics tests, also PASS.
- Native VX **human visual acceptance not proven**. An attempted system screenshot was obscured by another foreground window, was discarded immediately and excluded from all deliverables. Do NOT claim that attempt validates the VX screen. User can open the included VX executable and inspect it safely.

## Failure taxonomy
- F1 first build PAR input order contradicted Y-sort: 191 wrong pixel; corrected in F1R1 canonical sorting.
- Godot import may report success while graphics failed first cold start: force `--headless --import` and assert real GPU pixel parity.
- GDScript physics canary Node/Node2D and JSON float-key discrepancies fixed; test logs need signed PASS (not mere exit code).
- PowerShell UTF-16 logs mislabeled as UTF-8: BOM-aware decoder used.
- VX native test template copied **31 old FSOBJ sprite PNGs**, 23 unused source images were removed from **only isolated F1R1 candidate**, leaving exactly 8 referenced sprites. Re-ran live native RGSS2 PASS after pruning. Failed packaging attempt preserved in separate local stage.
- Do not capture user desktop for visual evidence; image QA must use isolated game application rendering or user-supplied screenshot.

## Deliverables
- Private Google Drive folder: https://drive.google.com/drive/folders/1SjHCqFd1AWpLCawXbkkCvvrmTyCiK3uI
- Latest ZIP: `FS_F1R1_A04_NEW_FOREST_VX_GODOT_NATIVE_20261025.zip` (9,102,910 bytes; SHA256 `0a407d9dce66183703fe957193a396cc59648d3b4502cd0c83e4f83e3035272b`; 176 entries; CRC SHA and cold extraction PASS; pre-bundle 22/22 source/GPU gates + actual cold native VX and Godot both PASS).
- Four prior Godot/Tiled/source check entrypoints plus `START_F1R1_NATIVE_VX.cmd` and `RUN_F1R1_VX_NATIVE_AUTOTEST.cmd`. Native project at `VX_NATIVE_PLAYABLE`; original `Game.exe`, sprite/picture resources, RGSS2 and data included.
- Standalone `CURRENT_HANDOFF.md`, `NEXT_CHAT_PROMPT.txt`, README, 22-gate QA script, full source/manifest, all previous failure logs and new native VX test logs. Private artwork never committed to public GitHub.
- Source scripts preserved in `tools/ai_art_toolchain/` on this feature branch; latest A04 build/acceptance source is bundled in private ZIP.

## Next
1. Human Visual Gate: ask for actual visual inspection, no default promotion to FORMAL PASS.
2. First genuinely **new** original monster juvenile/adult/final evolution chain with distinct original consistent style art and Idle/Attack frame QC, isolated from other live P1G branch. PixelLab/SpriteCook accounts not authorized; no paid model requests.
3. Stress a more complex new map with buildings, occlusion and source-based collisions, no flattened-scene masking; maintain two-world source manifest and native Game.exe walkability QA.
4. Keep A04 sealed as reproducible technical candidate (do not affect existing mainline).
