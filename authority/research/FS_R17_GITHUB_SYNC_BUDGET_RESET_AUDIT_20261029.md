# FS R17 Direct Layers | GitHub sync and research budget reset audit
Date: 2026-10-29 (Asia/Taipei)
Scope: Forest Symphony Ground/PAR documents, fail-closed source checks and research-stage spending baseline.

## Confirmed remote state
- GitHub `main` contains `authority/research/FS_R17_DIRECT_GROUND_PAR_AUTHORITY_20261029.md`.
- GitHub `main` contains `authority/research/FS_PAR_OCCLUSION_CURRENT_HANDOFF_R17_20261029.md` and `FS_PAR_OCCLUSION_CURRENT_HANDOFF_R17_DIRECT_20261029.md`.
- GitHub `main` contains `FS_R17_DIRECT_PAIR_PROVENANCE_GATE_20261029.json` and `FS_R17_DIRECT_LAYER_SOURCE_PROVENANCE_GATE_20261029.json`.
- Drive folder `FS_R17_ELF_CORNER_20261029` contains the corresponding Authority, report, R17 handoff, source JSON and private evidence package.
- Linear `SHO-34` has the 2026-10-29 latest rule-correction handoff. No modification to sealed FS/K4 runtime.
- Existing named direct-layer Authority/Handoff URLs were accessible through authenticated GitHub contents reads; the formerly reported 404 is not reproduced for those exact paths. This does not assert every past link is repaired.

## Research budget reset: meaning and limits
The research-stage ledger is **rebased for R17_DIRECT_STAGE3**: at the start of this new stage, stage-local tracked spend = 0, prior-stage records retained without alteration; amount authorized to spend = **UNSPECIFIED**. This is a planning baseline, not an assertion that real compute or API usage returned to zero.

Do not state that GitHub Actions minutes, GitHub billing, OpenAI/tool-call allowances, image-generation credits, remote machine budgets, or rate limits have been reset. Those are provider-controlled and **NOT VERIFIED / NOT RESET BY THIS DOCUMENT**. This workflow has no verified provider-side reset action or quota readback. Never alter provider billing settings or delete usage history to simulate a reset.

Suggested counters for the next candidate: `candidate_id`, `creation_method`, `GPU_minutes`, `AI_generations`, `human_review_minutes`, `bytes_synced`, `failed_retries`, `commit_sha`. Record actual measured values, not assumed zeros.

## Source validation gate
- Executable source: `tools/r17_direct_ground_par_source_validator.py`.
- Manifest contract: `authority/research/FS_R17_DIRECT_PAIR_SOURCE_MANIFEST_TEMPLATE_20261029.json`.
- Requires genuine separate Ground and PAR file sources, matching SHA-256, scene/style/origin metadata and matching PNG sizes. PAR must have real transparent and nontransparent RGBA.
- Source manifest is *self-declared*: passing file/hash checks only produces a technical candidate. It does not authenticate image creation history, prove visual art quality or approve an R17 pair.
- A pure 0-pixel composite diff is not acceptable evidence of provenance. No human Art Gate F => no FORMAL PASS or Final Seal.

## Current truthful Gate status
GROUND_LAYER = HOLD (no newly approved direct high-detail ground)
PAR_LAYER = HOLD (no newly approved matching native transparent PAR)
PAIR_ALIGNMENT = HOLD (no approved new pair)
SOURCE_FIRST_AUDIT = REQUIRES_ARTIFACTS
FORMAL_SEAL = NO

## Next workflow
1. Produce 544x416 independent creative Ground and PAR with common blueprint/style lock; no master-first reverse split or 2-tile ground.
2. Record both source artifacts and SHA-256 in template; run validator and review its JSON.
3. Human review at 1x: ground density, object completeness, PAR fringes/1px details, tree contact foot, shared coordinates.
4. Deliver only original GROUND.png + PAR.png; user handles composite and VX collision. Expand to 1280x928 only after all three visual gates pass.
5. Sync result to GitHub/Drive/Linear; do not overwrite SEALED files.

## 2026-10-29 validator smoke test (Windows Desktop Commander)
- Downloaded the published main-branch validator into Windows TEMP (7803 bytes); Python + Pillow available.
- Synthetic 544x416 independent Ground RGB + PAR RGBA with correct manifest/SHA256: process exit 0, status `TECH_CANDIDATE_ONLY_NO_ART_PASS`.
- Altered `ground.creation_method` to `master_first_segmentation`: process exit 2, both `UNACCEPTABLE_CREATION_METHOD` and `REVERSE_SPLIT_LINEAGE` flagged.
- Synthetic PNGs and manifest deleted from TEMP after the test. The validator file remains in TEMP. This is **functional smoke testing only**, not validation of new R17 village art, real provenance or visual Gate F.
