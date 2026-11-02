# FS PMD Evolution 0001→0002→0003 | G10 Native Source / 3-Keyframes
Date: 2026-11-03 Asia/Taipei

## Scope and authoritative source
- User rejected incomplete FS Actor recolor; **A68 human character work PAUSED**. No Actor01 edits were made in G10.
- User requested finishing authentic **PMD 0001–0003 lava evolution** rather than regenerating concept images.
- Recovered **P3_G9_FULL_EVOLUTION_CHAIN_0001_0003_20261027.zip**, SHA256 `74061d61a7fde6650699ee30ad1339ff255924a9cae13c98cb1703478eae260f`. Retained full accepted/previously modified original-native pixel art **unchanged**; A67 simplistic Stoneback recolor does NOT supersede the more mature G9 0001 G3R1 / 0002 G8R4 / 0003 G8R5 derived art.
- G10 does NOT claim to have repainted 2503 new frames today. The native artworks were completed in G9; G10 **re-audits, organizes and extracts** the per-direction native action-specific 3-keyframe convention across all 3 evolution stages.

## Full native evolution chain preserved
| Stage | User-authoritative visual identity | Actual source action atlases | Native source cells |
| --- | --- | ---: | ---: |
| PMD0001 | Approved baby basalt/lava G3R1 exact art | 34 | 1123 |
| PMD0002 | Split basalt juvenile G8R4 + extended G9 frames | 12 | 682 |
| PMD0003 | Erupting full-grown basalt G8R5 + extended G9 frames | 12 | 698 |
| **Total** | | **58** | **2503** |

- For each species, **original AnimData.xml, all original Offsets and Shadow PNGs remain byte-identical**. Native full animation atlas shape, frame count, facing rows and event frames unchanged.
- New `KEYFRAMES_1_2_3/<species>/<action>/DIR_<row>/PMD<species>_<action>_1.png`, `_2.png`, `_3.png` and three exact `ORIGINAL_PMD...` references for all actual source actions and directions. **359** distinct native action/direction groups and **2154** individual keyframe PNGs (1077 edited + 1077 original).
- Source GIF: **21 original native full-animation references** preserved. Added four synchronized three-stage comparison GIFs for Idle/Walk/Attack/Charge.
- `KEYFRAME_FRAME_MAP.json` records original action, semantic FS action equivalent, 0-based native frame indices, original native frame counts, image sizes, direction row, original XML duration units and whether duplicate frames were necessary.
- **54** group exports repeat one or more existing source frames because original action genuinely had fewer than 3 frames. No fake intermediate frames or generated limb poses.

## Independent G10 technical QA
- Re-ran recovered G9's `VERIFY_FULL_EVOLUTION.py` against all 2503 source cells: PASS.
- Re-read source/production XML/Offsets/Shadow: byte-identical across all 3 species, PASS.
- Checked all 2503 production atlas cells for source geometry and new-alpha border gain: **0** added alpha pixels on cell canvas edges, PASS.
- Exact source provenance SHA and per-file SHA256SUMS contained in ZIP; ZIP CRC verified. No PixelLab or image generation invoked.
- Full native source checks 2503 / 2503; production source-vs-original changed cell count 1123/682/698. This is a technically distinct sprite source, not a colorless placeholder.
- QA file: `G10_QA.json`. 58 native animation assets + original support metadata and direct source versions delivered.
- **Do not confuse G9 Godot XML/GPU bridge historical pass with a newly re-run G10 native engine test.** Original PMD game/VX Tankentai SBS still NOT TESTED. Human visual acceptance for previously newly-built G9 0002 and 0003 frames remains PENDING.

## Package links and integrity
- Google Drive folder: https://drive.google.com/drive/folders/13dTeALXuIkQ_raDEeMBYlRnCp2pGXfQL
- Complete ZIP: https://drive.google.com/file/d/19DUM6s66KutlYQMFp_zdo-K4qS23wd4F/view
- Four action evolution comparison: https://drive.google.com/file/d/1t_sBjSQXqJPGF_fEJWojlb7w93GVX_q3/view
- ZIP name: `PMD_G10_0001_0003_COMPLETE_NATIVE_AND_3KEY_20261103.zip`
- ZIP bytes: **4,452,361**
- ZIP SHA256: `55a2246237f3a403c5515cd6f447720ca8f4276d8ec33ae3104c07bea5441b3c`
- ZIP entries: **2,544**, ZIP CRC PASS and all pre-manifest entries SHA256 verified.
- G10 generated locally in `/mnt/data/PMD_G10_NATIVE_0001_0003_20261103`, and ZIP copy in local `/mnt/data/PMD_G10_0001_0003_COMPLETE_NATIVE_AND_3KEY_20261103.zip`. Those local paths are artifact references, not guaranteed paths on user PC.

## Handoff / Fail-closed next action
1. Review actual G10 `QA_PREVIEWS/PMD_0001_0002_0003_4_CORE_ACTIONS_3KEY_COMPARE.png` side-by-side at native or nearest-neighbor pixel scale, plus `QA_PREVIEWS/PMD_000{1,2,3}_12_ACTIONS_X3_KEYFRAMES.png`.
2. Inspect each species native full action GIFs, particularly 0002 and 0003 Attack/Charge/Rotate, for detached rock debris, body/leg readability, changing species silhouette, overlaid magma covering sprite face and border clipping. Fix *source native cells* only on actual failures; track exact positions and before/after, keep approved 0001 untouched.
3. Import copy of production 0001–0003 as original PMD source and test actual original PMD engine or isolated VX Tankentai if relevant. Do not claim game PASS before proof.
4. No new unrelated human actor coloring or imagegen conceptual PNGs, and no paid PixelLab quota.
5. Remember third-party PMD sprite license attribution/distribution permissions before any commercial/public release.

**STATUS: ALL THREE STAGES COMPLETE AS SOURCE-NATIVE GRAPHIC SETS; THREE-KEY CONVERSION AND QA PASS; FULL HUMAN ART APPROVAL PENDING; ORIGINAL GAME INTEGRATION PENDING.**
