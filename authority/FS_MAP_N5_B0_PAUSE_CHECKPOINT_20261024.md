# Forest Symphony｜2026-10-24 Map Freeze & N5 Adapter Checkpoint
**Status:** `N5_B0_RUNTIME_ADAPTER_ISOLATED_SMOKE_PASS_VISUAL_GATE_F_PENDING`; map feature work paused at user's request; resume tool validation.

Authoritative FULL goals/provenance/handoff (Drive): https://docs.google.com/document/d/1Fwwert2ILfA2MLWdgQQJXMo9Sqhg-20Z5bjqWcYrdBY/edit
Mandatory source asset inventory (170 exact file IDs; NO REDISCOVERY): https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit

## Verified before freeze
- Rich Pilot v2.1: 864×640; 48 PAR, 19 Ground decorations; 12/12 isolated VX + Godot smoke. **Visual/style readiness only 2/9**. ZIP https://drive.google.com/file/d/1eD3UsILoHbYJfGecsXXOLkEBR_ZztEfH/view
- SCENE04 B0: 544×416 / 10 original procedural Source sprites / 17 PAR props / 2 upper plateaus and legal stair edges; 13/13 source/height checks, 10/10 dual-engine isolated smoke. ZIP https://drive.google.com/file/d/1qeoPSvbAW_0C_BC7ty37XMaxTwU1JQTe/view
- K4 project archive reconstructed by historical **3860/3860 uncompressed per-file SHA256+size+CRC matched**, despite outer ZIP SHA mismatch (archive packaging and legacy CP437/CP950 path-name issue). Preserve this distinction.
- K4 SEALED scripts sha256 `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`.
- Phase49N5 sealed script sha256 `3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9`.
- K4 baseline, N5 runtime baseline, and N5_B0_ADAPTER_CANDIDATE are **three separate directories** in `E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project`.
- Original N5 505 script entries byte-unmodified, candidate only adds 1 test adapter (script index 482, test Map900); 6/6 formal-N5 *isolated adapter smoke* passed. Real RGSS2 Game.exe actor climbs both stairs, cliff/water blocked, three interaction IDs recognized; upper/lower screenshots equal B0 Master outside actor and native title UI, N5 220-frame trace. **NOT final FORMAL PASS.**
- Failed adapter V1/root cause: ISS ParaPassa overrides `Game_Player.move_passable?`; only overriding `Game_Character.passable?` did not work. V2 explicitly delegates only test Map900 to B0 elevation rules. Keep FAIL log.
- Golden evidence: `E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\logs\N5_B0_FINAL_REGRESSION.json`.

## Resume targets
1. Non-destructive full N5 adapter install/undo and cross-map + battle regression; existing sealed scripts immutable.
2. B0 multi-height semantic regions, stairs, water, cliff sidewalls, dynamic actor/world-Y sorting and bridge over/under with two collision planes.
3. B1 actual quality from ground3 and reference six-pack; true distinct buildings, trees, river, bridge, sacred tree via provenance/rights-confirmed sources; not independent Ground/PAR drawing.
4. Same Manifest → Ground, CompletePAR, Base, Occlusion, Collision, Height, Tiled: byte-exact align, 1px negative, artwork density and distinct silhouette checks.
5. VX + Godot native moving actor acceptance and user Visual Gate F; no early FORMAL PASS.
6. Preserve asset license redlines: Hanzo is source candidate with unresolved redistribution rights, never push binary/art on public GitHub.

## Current user instruction
**Stop active map development and resume other previously integrated OSS tool testing** under `E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023`; older tool test handoff is `NEXT_CHAT_HANDOFF_V2_20261023.md`. Use https://docs.google.com/document/d/1XitoOS6llG9vlDL7vt2IoY0Wrm3gtk71ozc4RtVNEyo/edit and https://docs.google.com/document/d/1lx8pbTkwetZFowHWqLI9r4NtXb7WUxFswSq450Vrln4/edit. Per-tool results require runnable commands, real source/outputs, logs, limitations, and follow-up tasks.
