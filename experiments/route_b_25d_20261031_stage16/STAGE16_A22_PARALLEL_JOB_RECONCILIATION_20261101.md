# Forest Symphony Stage16 A22 — Two Real Paid PixelLab Job Reconciliation
Date: 2026-11-01 (Asia/Taipei)

**Two separate authenticated PixelLab `generate-with-style-v2` jobs are independently evidenced by separate job IDs and original PNG hashes. Total reported usage 20 subscription generations. Current observed balance 1,960. No new paid requests authorized by this reconciliation. A20 remains the stronger visual-art baseline. Formal Seal NO.**

## Accounting / concurrency
- A20 baseline, last confirmed balance 1,980 after original four-variant A20 10-generation job.
- **A22 controlled A/B trial**, job `d1d7e89d-571f-41a2-ac79-286171edced2`, seed 161902. Official usage 10 generations, account balance check 1980→1970. Original 4 PNGs in existing private folder `STAGE16_A22_CLEAN_STYLE_AB_20261101` and SHA-aligned QA `A22_A20_CONTROLLED_AB_QA.json`. Used unchanged A20 original prompt and style description, replacing FS reference crops with A21 native 96/128/64 images.
- **A22 A21-spec trial** (this conversation), job `5d982789-69a5-41aa-ab7c-1d6c45b26712`, seed 162101. Official usage 10 generations. Its overlapping balance observations were 1980→1960. Four different original 128×128 provider PNGs in `STAGE16_A22_FS_CLEAN_STYLE_20261101`, with SHAs listed in `A22_MODEL_JOB_RECEIPT.json`.
- The two unique jobs together report 10+10=20 subscription generations. This reconciles the net 1980→1960 subscription balance decrease, barring other unobserved account activity. A per-job billing ledger was not retrieved, and asynchronous overlap can obscure attribution from balance snapshots. Do not claim the second job itself cost 20 or that this proves a billing defect. USD credits remain 0.

## Ground3 art comparison (original 128×128 source, no resize, display-only nearest 2×)
The combined 3-row contact sheet `A22_THREE_ACTUAL_TRIALS_4X3_NEAREST2X.png` compares four A20 original images, four controlled A22 images, and four A21-spec A22 images. Every source is genuine PixelLab API output; no generated previews were recreated or retouched.

| Four-variant batch | Mean local neighbor RGB L1 | Human-visible observations |
|---|---:|---|
| A20 original FS mixed composition refs | 13.467 | Visible curving roads, richer high-contrast plants; still ground3 style FAIL |
| A22 A/B same prompt/seed, cleaner original FS refs | 9.103 | Roads remain readable, but flatter grass and less intricate visual texture |
| A22 A21 spec changed prompt+seed as well as refs | 6.157 | Broad flat greens, large sparse road zones or no road; clear regression |

Neighbor RGB L1 is **not** a perceptual-quality score. It is a local contrast diagnostic consistent with the visual audit. Neither A22 batch fulfills full Ground3 high-density 1px grass, soil and coherent decorative detail. Cleaning references alone did not solve native style fidelity. The A22 spec trial is NOT a controlled one-variable experiment since prompt and seed also changed.

## Failure root cause hypotheses (not proved)
Removing the mixed-source village context may also remove useful path/composition and native botanical-vocabulary cues; the 96/128/64 asymmetric source dimensions may change model emphasis; and sampling is nondeterministic despite fixed seeds across model versions. The evidence does NOT prove cluttered references are intrinsically better, only that this finite A20→A22 change did not improve the art.

## Authority and next anti-duplication policy
- Preserve both A22 jobs and their separate original PNGs, seed, prompt and account receipts; never overwrite either Handoff. This is **parallel-run reconciliation** authority, not a superseding model result.
- Before any next charged request, check existing stage folders, Job IDs and account balance for duplicate concurrent work. Require one workstream/one explicit stage job at a time to prevent parallel spending.
- Stop further PixelLab expense. In A23, prefer **offline comparison and texture material study** of A20's stronger composition before one narrowly-budgeted inpainting/content-control experiment. Do not call arbitrary extra prompts.
- No new 544×416 Ground, no PAR, collision, Godot or VX engine test. The formal FS game and sealed baseline are unchanged. **Formal Seal NO.**
