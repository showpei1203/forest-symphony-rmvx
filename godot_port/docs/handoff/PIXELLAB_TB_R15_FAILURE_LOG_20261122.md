# Forest Symphony T-B｜R15 Failure Log｜2026-11-22

## ART-ONLY scope
No battle code, FSBattle/ATB/ACT, gameplay UI, main, T-A or T-C changes. Stage identity source remains pixel/SHA locked. R14 original ZIP remains immutable: SHA256 `07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575`.

## Failure R15-001 | PixelLab `/v2/edit-image` 422 rejected long description [FIXED]
- True PixelLab Stage1 Glacier Jackal original source **was successfully generated first**, via `create-image-pixen`, with provider-reported **1.0 generation** and real 128px source sprite. The stage2 edit call was rejected `HTTP 422 string_too_long` with `body.description` over the documented 500-character maximum; no stage2 source had been generated.
- Fixed both Stage2 and Stage3 evolution edit descriptions to <=500 characters, retaining all identity anchors (canine ears, eyes, muzzle, four paws, tail, southeast 3/4 view and added crystal morphology). Re-ran the script from existing temp ledger, **did not re-generate or re-charge stage1**.
- In corrected execution PixelLab successfully completed two source-chained `edit-image` jobs for Stage2 and Stage3, each provider-reported **1.0 generation**. All three third-family source files have unique source SHA/lineage in protected TEMP. **Do not infer owner art approval** from valid size/alpha.

## Failure R15-002 | Source KO and Idle atlas cell mismatch [FIXED]
- R14 has **different actual cell sizes** for Bat S1 KO 128px / Idle 96px, Bat S3 KO 224px / Idle 192px, and Lava Frog S1 KO 128px / Idle 64px. Direct `start.size == end.size` assertion failed in the first six-Revive anchor submission stage, after the three Glacier Jackal original source images had successfully been produced.
- Exact source files identified directly from R14 manifest and original ZIP; no random image scaling or invented creature. Changed `locked_revive_sources` to **center the unaltered RGBA Idle frame on KO's larger transparent canvas**. The correct phase is explicit in the current source-controlled provider, commit `63622cbeb09078820ee08017c10d4d2d169733f4`.
- Reuse all three already-produced original Glacier Jackal source files and SHA-linked provenance. This canvas repair required **zero new PixelLab image calls**, because the old process failed before animation submit. R14 KO and Idle assets remain byte-identical and unchanged.

## Failure R15-003 | Actual visual art gate remains distinct from technical QA
- R14 Leaf Bat Revive off-direction is a visual defect detected by comparing true 11-frame KO/Revive/Idle. R15 requests 10-frame anchored `animate-with-text-v3` source transition KO last → Idle first, including both exact-original endpoint frames (padding only for source-size difference). Avoid claiming full visual quality acceptance based on PNG padding, source hashes or Godot headless import.
- Older R14 Revive candidates are **not deleted or overwritten**, and final user art review is required for the corrected clip and for the new ice-wolf lineage.
- The third family should be described honestly as having **4 of 12 baseline actions per stage initially**, until later PixelLab batches fill the remaining eight. Its third-stage forms are genuine PixelLab source chains, not sprite recolors.
- Two newly requested third-family evolution effects are deterministic source-exact pixel transitions, **not AI-generated transformation morphing**.


## Failure R15-004 | PixelLab `animate-with-text-v3` returns input-echo frame [FIXED]
- Six requested 10-frame Revive requests returned **11 actual PixelLab PNG frames** from the API, unlike prior Skeleton v3's direct frame counts. Strict validation intentionally failed without claiming success or re-generating images.
- Recovered the **same completed provider job IDs**, taking ten equally spaced real output frames inclusive of both endpoints (one redundant frame discarded). The original KO and Idle boundary pixels are then applied as exact source anchors, and preserved provider frame SHA/usage is reported. Fix commit `c67300f09a8cc47b9bf7006dd30e4172ee7bc9f2`. No extra PixelLab generation charges for this handling bug.
- Keep distinctions clear: provider raw frames versus R15 exported frame slots and the two exact-original source anchors; never call the two anchor pixels freshly AI generated.

## Failure R15-005 | Real visual clipping in Frog Stage1 Revive first v3 output [QUARANTINED]
- Genuine PixelLab Frog S1 Revive first job reported **3.0 generations**, but two of ten exported frames contacted canvas boundary (frame indexes **7 and 8**). QA rejected the result as `ART_TECH_HOLD`, **not** as a pass.
- The original rejected PNG and complete first provider job/cost metadata are kept under `%TEMP%/fs_tb15_provider/REJECTED_ART` and `R15_REJECTED_PROVIDER_QA.json` pending private release. Source-controlled retry patch `c0d5c075be34d05b9cd6a5b5b479af3ba69dc1fa` permits **at most two** documented regenerated candidates, with distinct seed and a contained-silhouette prompt. Accepted output must have zero edge clipping. Extra rejected-generation cost must not be hidden from final accounting.
- Running actual revised provider job `d2802e41-aae7-4f3e-8be3-f6f250208ceb` at time of this update. Do not state final acceptance before QA.
