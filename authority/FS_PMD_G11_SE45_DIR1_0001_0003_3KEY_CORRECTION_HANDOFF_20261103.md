# Forest Symphony / PMD 0001→0002→0003 — G11 SE45 source-native correction

Date: 2026-11-03 (Asia/Taipei). Status: user visual QA pending, original PMD/VX engine test pending.

## User correction and concrete root cause
- User: "改得還可以，但要45度角，你忘了這件事"
- G10 main 4-action preview explicitly said **DIR=2**, which is **east-facing 90-degree profile** in the original 8-direction PMD sprite atlas. Thus G10 did not meet the agreed **southeast (SE) 45-degree battle view** rule.
- For source atlas with 8 rows, front S = DIR_0; southeast diagonal = **DIR_1**; east profile = DIR_2; southwest diagonal = DIR_7. Verified against original Idle/Walk/Attack/Charge source in each of 0001, 0002, 0003.
- Do not regenerate sprites or rotate a rendered whole image. G11 selects exactly the *real original native* DIR_1 pixels from the previous user-approved G9/G10 production atlases.

## Actual G11 deliverables
- Native PMD0001, 0002 and 0003 all **58 original production animation atlases**, plus original versions and their respective `AnimData.xml`, offsets, shadows, exactly copied, unmodified.
- 43 actions truly have 8 direction rows, broken down 0001: 21, 0002: 11, 0003: 11.
- Their per-action `_1/_2/_3` source-aligned 45-degree selections are **129 existing production PNG keyframes** and another **129 exact original source references**; all crop pixels byte-identical to atlas frames. Original-native frame indices, source duration units and loop/sequence type are in `KEYFRAME_45DEGREE_MAP.json`.
- 15 more actions (0001: 13, 0002: 1, 0003: 1) have **ONLY ONE ROW** in the authentic PMD source, so they cannot claim genuine 45-degree source data. These are quarantined in `SOURCE_ONLY_SINGLE_DIRECTION_NOT_SE45`, marked PENDING, not faked. 0001: Sleep, Eat, Tumble, Pull, DeepBreath, Sit, LookUp, Sink, LeapForth, Cringe, LostBalance, TumbleBack, HitGround; 0002 Sleep; 0003 Sleep. Do not silently count these as true southeast 45-degree PASS.
- Core 4 movements `Idle, Walk, Attack, Charge` for **all three** species are fully corrected using DIR_1 and now have synchronized source-only 3-stage GIFs, 12 3-key per-monster GIFs and 12 full original native frame sequencing review GIFs (not a native engine pass).
- Native source images, original full 8-facing atlases, 43 true SE45 actions, 15 honest single-row exceptions, QA JSON, 8-dir preview, DIR2-vs-DIR1 proof image, generator script and SHA manifest in the package.
- No PixelLab/image generator use, no source pixel changes, no new body poses, no XML/duration/offset/shadow mutation. Human actor A68 work still PAUSED.

## Link verification
- Drive folder: https://drive.google.com/drive/folders/1pcFCu0-rmhtuLTFERpHJs-Im4MbqDg6c
- Drive main ZIP: https://drive.google.com/file/d/1jh4qmzu3vVD8Cr2mkPgPgU189eLohMRd/view
- Drive SE45 4-action contact: https://drive.google.com/file/d/1eCzDQOhCBCUo7vZR-R2tHu97401woCGX/view
- Drive wrong/right angle comparison: https://drive.google.com/file/d/11B1x2ZfdiRo3FOznQywspIJWmDUvog_s/view
- Name: `PMD_G11_SE45_0001_0003_COMPLETE_NATIVE_20261103.zip`
- ZIP bytes: 2,559,391; 742 entries; SHA256 `47fbdaa5c7088c5612c4e53d262a70e64017e965160bd50e55fcf5c12dfe921f`.
- ZIP CRC and all 741 premanifest file SHA256 values PASS.
- G10 baseline SHA256 `55a2246237f3a403c5515cd6f447720ca8f4276d8ec33ae3104c07bea5441b3c`; copied native files were all byte-identical; F2 map and unrelated pipelines remain untouched.

## QA GATES
- Eight-direction mapping / correct row for 43 source-supported actions: TECH PASS.
- 129 production + 129 original _1/_2/_3 frames exact source crops: TECH PASS.
- Single direction action 15/58: FACING PENDING. Do not solve by mere filename or fake transformed art.
- All three stages 0001..0003 source consistency: inherited user-approved 0001 G3R1 and source-based G9/G10 for 0002/0003; extended full animation ART PENDING.
- Original PMD native runtime and RPG Maker VX SBS: NOT TESTED; do not claim PASS.
- License/attribution of third party PMD source remains release gating.

## Prevention and next
- Never make a battle preview from DIR_2 again. Check source orientation visually at 8 directions before annotating "45°".
- For 15 one-direction source actions, preserve source until hand-edited to true 45-degree based on verified anatomy or until user expressly excludes these semantics. Never color these PASS by default.
- Preserve true native full action frames and XML; 3-key files only for sprite review and action semantics.
- Review 0002/0003 full southeast native GIFs for floating rock debris, feet, collision, silhouette and actual action. Only touch original native cells after a concrete observed failure, no concept art work.
