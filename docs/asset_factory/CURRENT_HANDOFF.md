# FS AI Asset Factory CURRENT_HANDOFF A03 | 2026-11-08

Mandatory next-chat entrypoint. Do not restart A01/A02, never merge Draft PR without approval, do not regenerate concept art instead of producing real native assets.

## Authority and links
- Global P0 storage: https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit
- Main rules: authority/FS_CURRENT_RULES_INDEX_20261107.md; FS router and Asset Factory V1 plan.
- Current repo (public code only): showpei1203/forest-symphony-rmvx.
- Branch: feat/fs-asset-factory-v1-20261107; PR #15 https://github.com/showpei1203/forest-symphony-rmvx/pull/15 remains Draft, unmerged.
- A02 real source SHA detail: docs/asset_factory/SOURCE_INVENTORY_A02_20261107.md.
- A03 REAL PRIVATE QA: https://docs.google.com/document/d/11fCR2Z6gmIAZzDTHZbnSse5jFwi4v0sVuYnj_mz1byg/edit
- A03 FULL private Handoff: https://docs.google.com/document/d/1YtPce0j-Sy86H335TuLdeGDMEgFFkQ0QdvroAHBjPIo/edit
- Previous A02 Drive Handoff: https://docs.google.com/document/d/10co8RTL-WXb2fhiiExLOfxmoasTg8kgjl7wb9rcnvXw/edit

## A03 actual verified results, not plans
1. Executed exact same committed GitHub blob PMD adapter, plus A03 private ZIP scanner, over three real historical private ZIPs. Tested original_0001, rock_0001, ORIGINAL_0002, VOLCANIC_0002, ORIGINAL_0003, VOLCANIC_0003: all PASS_STATIC_ONLY. 6 source sets / 116 concrete action atlases / 348 original Anim/Offsets/Shadow PNGs, matching actual native XML size, frame count and 1-or-8 row atlas geometry. No private art in public CI.
2. Executed exact same committed GitHub blob runtime_masks.py on private Master-first V3 ZIP (whole ZIP SHA256 b38c08109e25299fa9f4ceabd7f34b42cc82531ba56c8f09cc9f3a4af0429511). Master 1280x928 SHA256 091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530; Runtime PAR SHA256 e2486f7a780d260ccfceadac024b94ee37108371c91c7a73f2cf254463c76edb. 4 source masks (2 roofs + 2 canopies), 118425 alpha pixels exactly accounted for, 0 overlapping owner pixels, 0 visible RGB drift, binary-alpha PASS. This is NOT semantic roof occlusion or full Authoring CompletePAR proof.
3. Executed exact same committed GitHub blob actor.py on real A62 approved 144x48 three-pose strip extracted from private A63 ZIP. Approved 48x48 F0 is pixel-identical to frame0; three frames distinct; loop 0-1-0-2; PASS_STATIC_ONLY. This 48px reference is NOT original VX 32px nor Tankentai integration.

## Exact code and CI
- A02 native adapter Git blob: tools/asset_factory/adapters/pmd.py = a97778e8c886b839d5dd9a4993e9dabf4177b739.
- Existing Actor adapter Git blob = 396df40f2acd966cfcd2bdfa10dde90a77926205.
- New A03 tools/asset_factory/adapters/private_zip_scan.py Git blob = fff75ae47a71099919a12ad8f2d101409fc13245. Source-lock and safe in-memory ZIP reader; no extraction and no protected PNG commits.
- New A03 tools/asset_factory/adapters/runtime_masks.py Git blob = 4e53047097c245b1498da1cdeb078684ac81a4f3. Compare full canvas source mask ownership and Master RGB registration.
- New tests tools/asset_factory/tests/test_a03_private_runtime.py: 11 synthetic positive/negative cases. A01 14 + A02 15 + A03 11 = 40.
- Actual successful GitHub Actions run 42412650688, source commit 9ba9cf7bb3a11481c05dfd414e7431d81efcb343. Log: Ran 40 tests in 0.040s, OK. Any further documentation commit means recheck current branch head Actions, never present old run as latest.
- PixelLab paid calls 0. No user's PC files, no main overwrite, no freshly approved artwork.

## Gate matrix, must stay distinct
- Source file SHA and native PMD original grammar: PASS for six historical source sets.
- New same-blob Adapter over actual private source: PASS static, not game.
- A62 existing approved run reference: SOURCE_STATIC PASS, USER HISTORICAL APPROVAL for this specific run.
- Four-object V3 Runtime PAR source ownership: PASS_STATIC_ONLY.
- CompletePAR authoring objects and legal-footpoint occlusion semantics: NOT_TESTED / PENDING.
- A26 *new lava-frog* approved Idle/Walk exact private binary SHA/Drive source: NOT LOCATED here; old Handoff points to historical E drive. Do not pretend original_0001/rock_0001 is approved A26 lava art.
- Eight-direction species identity and animation aesthetics: PENDING.
- Native Windows VX / switch 203 / Tankentai new data this iteration: NOT_RUN. V3 prior historic native test remains historical separate evidence only.
- User ART acceptance of new asset: PENDING. Formal seal NO.

## Next A04 exact order
A. Find SHA-verified authorized A26 actual approved Idle/Walk PNGs, or file a missing-source exception. No source guessing.
B. Start only one PMD0001 Idle/Walk original-XML, per-action dimension, Duration, Offsets/Shadow compliant native export; forbid one-direction-to-eight-direction fake rotation.
C. Actor use original sample source as base, preserve approved A62 animation recipe, three real _1/_2/_3 45-degree unarmed paper-doll anchors. Avoid large concept generation.
D. Expand full Authoring CompletePAR source owners and witness one legal walkable roof/bridge/canopy plus negative clear tile; V3 and A36H R3 must not be merged. Avoid grass duplicated under runtime PAR.
E. Keep human art, native VX, source static, and cloud delivery as separate gates. PC Windows temporary file operations require prior explicit scope/cleanup approval. PixelLab requires explicit capped batch generation approval.
F. Write versioned private Drive QA/Handoff, current GitHub Handoff, main authority Drive index, verify real CI head and readbacks.

Rollback only commits on this feature branch. Main and original source ZIPs are sealed, untouched.