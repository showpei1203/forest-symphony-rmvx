# Shared AI Pixel Art Toolchain Pilot — 2026-10-25

## Scope and isolation
- Projects: Forest Symphony (map), P1G (creature animation), shared art pipeline.
- Windows device: DESKTOP-90VT437; isolated root `E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025`.
- Preserve all D32A3a/LPC/FS sealed baselines. **No edits** to current FS or P1G source. No payment, no account sign-in, no API keys stored in repo.
- Do not call smoke PASS a Human Visual Gate F, native RMVX pass, or commercial-use license approval.

## Installed/verified
1. Agent Sprite Forge source pinned at commit `5324342fdfab72430f4e9604f3fe427009f8596d`; downloadable archive SHA256 `2157EF33D092BDC3053C4E43B55F2632FC66AB69B28AC98A838E1203B108B8C5`.
2. Five skills deployed to **isolated** `agent_skills` folder: `generate2dsprite`, `video2dsprite`, `generate2dmap`, `generate2dmedia`, `codeart2d`. Python 3.11 venv with Pillow 13.0.0, NumPy 2.4.6, SciPy 1.17.1.
3. Core ASF tests initially showed 24 failures from missing TEST-only `jsonschema` package (plus 175 passes); after adding dependency, **199 passed, 3 skipped, 12 subtests passed**. Reference `reports/asf_core_test_v2.log`.
4. Tiled 1.12.2 official signed MSI downloaded (signature Valid; SHA256 `11A0E6C97CC105E07A57EA9995F2704617986722DE4AB699D286DAB0D2BECC3F`); administrative-image extracted portably under `editors/Tiled-v1.12.2/PFiles/Tiled/tiled.exe`. Tiled **native GUI export NOT YET PASS** (CLI exited 1/no PNG); exporter internal render round-trip passed.
5. Pre-existing Godot 4.7.2 at `E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe`, not reinstalled. Existing LibreSprite/Pixelorama/P1G projects preserved.

## Pilot A01, actual command results
- `map_bundle.v2` validation PASS; map `meadow`, 192x128 at 16px fixtures, no warnings.
- Navigation PASS: 7 targets, unreachable 0, thinGaps 0.
- ASF Tiled export PASS: ground/decorations/props/collision/interaction layers, internal rerender 0px difference, verified `map.tmj`.
- **This is an ASF fixture, NOT the FS 544x416 map.** Native Tiled GUI round-trip still OPEN.
- Actual **FS v2.1 user-accepted source** read-only regression: `build/Ground.png + build/PAR_COMPLETE.png = build/Recomposed.png`, 544x416, RGBA diff 0. Initial generic file-name test was invalid (assumed `PAR.png` and `Master.png`), documented and corrected.
- Actual **P1G A47 six-frame sheet** has 2 rows x 3 columns, 288x192. Initial incorrect 1x6 test rejected because frame 1 was empty; corrected split by action. Idle three-frame QA = WARN, head proportions 1.0/1.0/1.0. Attack three-frame QA = FAIL, head scale values 1.0/0.92/1.0 with threshold 0.95..1.05. Keep Art QA gate OPEN; do not modify approved P1G source.
- Tiled CLI renderer failure, attack-frame change and skipped ASF tests are recorded as OPEN/PENDING, not hidden.

## Services requiring user authorization / usage billing
- PixelLab API, SpriteCook REST/MCP, MagicPixel (`magicpixel.art/mcp`), AutoSprite MCP. Stage connector instructions, comparison prompts and env templates only; no credentials, no credits used.
- DO NOT confuse `magicpixel.art` (game pixel art) with unrelated `magicpixels.ai`.
- LDtk remains optional secondary editor; keep exporter schema compatibility planned, do not claim GUI verified.

## Next stages (strict order)
1. ASF fixture Tiled GUI native import/export round trip; fix portable executable dependency or record blocker.
2. Adapt FS approved `scene_manifest.json` and 32px Ground/PAR/Owner/Collision into ASF `map_bundle.v2`, preserving Ground default walkable; disallow unintended obstacle propagation.
3. Visual, silhouette and alpha checks on **one** FS house+tree+well; human visual acceptance before larger village. Never reverse-extract flattened master for new maps.
4. Monster experiment: one **original** three-stage young→adult→final dragon chain with the same 32px/PMD-inspired chibi Style DNA; Idle and Attack separate. Compare ASF, PixelLab, SpriteCook, MagicPixel, AutoSprite only where usable, with costs logged.
5. Human soldier equipment reuse: LPC/Tankentai `_1/_2/_3` weapon pivots and foot anchors; real SBS native acceptance required.
6. ZIP containing source/reference manifest, CMD, original logs, evidence and handoff; Drive+GitHub+Linear status as actually verified. No automatic promotion to sealed mainline.

## Important failure-prevention rules
- Never claim a test passed when script used wrong file names, frame grid or cross-action comparisons.
- An exact recomposition checksum says **nothing** about art quality, object crop or gameplay collisions.
- Use one source manifest and one owner coordinate system. Negative tests for wrong ROI, y-sort, missing props, 1px shift, collision blocking on walkable ground.
- Credit budget 0 until user connects account. Prefer original characters, respect provider asset licenses.
