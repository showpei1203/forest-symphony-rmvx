# FS AI Asset Factory CURRENT_HANDOFF — A13 / 2026-11-08

CURRENT ENTRYPOINT: [ONE ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md) and [A13 honest ART failure QA](A13_ARTICULATED_POSE_F0_SOURCE_PROTECTION_FAILURE_QA_20261108.md). This file describes actual project state, not new policy.

## A13 happened; do NOT resume A11/A12 same-pose warps
- Original Actor01 F0 45°/48×48 from A62 historical user approval: exact binary SHA256 a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba (source unchanged). Also compared against approved 144×48 A62 Run strip.
- Three new real pose candidates _1 neutral, _2 LEFT leading stride, _3 RIGHT leading stride, loop 0,1,0,2. V1 overwide legs ART FAIL; V2 manually redrawn arm tubes ART FAIL; V3 narrower stride with original sleeve pixel patches, **still visibly below approved A62 art**, ART SELF-REVIEW FAIL. It is NOT a valid new sprite asset even if left/right feet actually alternate.
- V3 each PNG 48×48, 144×48 strip and GIF. V3 frame changes vs F0: 0/129/140 pixel locations; face/hair upper 33px pixel identical; all palette pixels belong to F0. None of those numeric invariants prove visual quality. No native Tankentai/Game.exe run.
- New `pose_spec.json` and pose-overlay guide records actual left/right hip/knee/ankle/elbow/wrist targets to feed a SOURCE-IMAGE-conditioned + skeleton-guided pose redraw generator next. The pose guide is a tool input, NOT accepted art.
- One non-reference-constrained image generation created unrelated elf instructional graphic; rejected and NOT included in candidate or private package. Do not mistake it for the user's Actor01.

## Real private ZIP — byte-level Drive verification
`FS_A13_ACTOR01_ARTICULATED_RUN_ART_FAIL_AND_POSE_JOB_20261108.zip` — 84,797 bytes / 31 entries / SHA256 `0aa0792667f3bfc88c96bd81796ced072538ee2c32bd09a3fff80d8d90c40867`. Stored under owner-only `FS_AI_ASSET_FACTORY_Restricted_Binaries`. Cloud metadata `shared=false`, only owner. **Actual Drive bytes materialized back into isolated container and SHA256 + ZIP CRC confirmed exactly equal**, not metadata-only verification. Protected source JPG/PNG/GIF/ZIP and Drive private binary download ID are NOT embedded into public GitHub.
- Contents include exact approved F0, previously approved A62 reference strip, all V1/V2/V3 source PNG/GIF, comparison/contact and 12x pose guide, repeatable Python build scripts, exact frame/pose JSON, QA+CRC manifest.

## Stop conditions and next real production task
- Actual ART gate failed for V1–V3. Stop any V4/V5 pixel-warp, manual patch, leg-splitting or shoulder-shaking approach; this was an explicit user preference and repeated source of wasted time.
- Next single generation experiment: actual F0 reference image + explicit 3-pose skeleton guide into an **image-conditioned / pose-guided animation tool** (PixelLab if callable and budget authorized, or comparable). Generate whole pose sprites at native 48px preserving F0 material and 45-degree camera; verify two legs alternate and opposing arm motion. Only then choose image generator vs rig-assisted branch and normalize to FS three frames.
- Provider generation was **NOT** executed by this A13 pipeline. No direct proven PixelLab integration or explicit per-run credit ceiling; cost 0, new Orca 0. Native VX/Tankentai NOT_RUN. Main/sealed source untouched and no new user PC workfiles. Formal seal NO.
- Ground/PAR tracks remain at A11 Master-first source-pixel QA with bridge mask semantics still ART HOLD. Do not claim they improved in A13.

## Authority boundaries
ACTIVE_MASTER remains the sole rule, no extra SOP created. [A11 actual source-preserving map/F0 QA](A11_REAL_MASTER_F0_TRANSLATION_PILOT_QA_20261108.md) stays historical. PR #15 Draft branch feat/fs-asset-factory-v1-20261107, not merged. After this handoff, verify latest branch HEAD Actions run and Mirror handoff to owner-only Drive.
