# FS AI Asset Factory — CURRENT_HANDOFF A06 (2026-11-08)

**ACTIVE next-chat entrypoint: begin A07 from this document, not A01-A05.** Preserve all A01-A06 history, sealed FS main, and private raw Drive art. User wants actual native assets and pixel-art quality, not CI numbers as a proxy.

## Authority and exact deliverables
- Public repo showpei1203/forest-symphony-rmvx / branch feat/fs-asset-factory-v1-20261107, **Draft PR #15**, unmerged to main.
- Global P0 Cloud-Only: https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit
- [A06 private full Handoff](https://docs.google.com/document/d/1_FV0wfG1o9gxe1r2cznJLfvRggwU7i3HE19EY_SHP34/edit)
- [A06 private real-image and grid QA](https://docs.google.com/document/d/1Tf8bNLr2zASrZfyafSpuH2QKeKBZxoVzXzPxknCABgc/edit)
- [A06 private layered V4 image/collision candidate ZIP](https://drive.google.com/file/d/12xCWLfj1EFDOlNEAZkOl47wswppVdhBf/view): size 10457859 bytes; SHA256 48af22427d0ba7560c19b8c16dbaf23f15d2076c5af7073155b66b5a469ecaf6. Uploaded via authenticated Drive, fetched back and SHA256 + CRC passed. Never publish game-art PNGs in public repo.
- [A06 private deterministic rebuilding scripts ZIP](https://drive.google.com/file/d/1dvrRObpv2t2oZcW69W0cUOjg3tIWl2gs/view): size 11497 bytes; SHA256 ab7a51bf367d67f92853663a6eaea9bef84d0cb8bb1bc79a0372afa601d29876.
- [Public source-independent technical QA (no artwork)](A06_V4_REAL_COLLISION_BRIDGE_PAR_QA_20261108.md), [A05 predecessor](A05_REAL_EXPORT_AND_AUTHORING_GAP_QA_20261108.md), [original source metadata](SOURCE_INVENTORY_A02_20261107.md).

## A06 actual progress (isolated real SOURCE images, not a Game.exe update)

1. Found **V3 semantic collision error** from actual source V3 private ZIP SHA b38c08109e25299fa9f4ceabd7f34b42cc82531ba56c8f09cc9f3a4af0429511. Actual 29x40 grid had **370 blocked, 790 walkable but 787 reachable** from (20,15). Isolated roof tile pocket (7,6),(8,6),(9,6) is incorrectly walkable on painted left-house rooftop. Underbridge river candidate (21,19),(22,19),(23,19) visually shows player in water, also erroneously walkable in the draft.
2. Created V4 six-tile **proposed** blocked change ONLY on the above six cells: **376 blocked / 784 walkable / 784 reachable**; eight-node 4-way bridge route from (20,18) through (24,18) to (25,20) still exists. Candidate JSON and visual map evidence in private ZIP. This is static/visual; **NO NEW V4 NATIVE VX TEST** and no edits to V3.
3. Found original V3 QA false-negative: code compared roof overlap **ratio >0.2** but labelled count "any roof overlap"; reported zero. Correct any-pixel count on same 23x30 actor box = **4 left roof + 9 right roof draft-walkable tiles**, all legal-footpoint semantics still PENDING.
4. Built real **fifth Runtime PAR object** from frozen full Master RGB (not artificial concept image). ID BRIDGE_NEAR_RAIL_CANDIDATE_V2, source L mask **3845 pixels**, SHA256 7a3d36087062fb4118da594318ba719f079e49f291bde54aa120d116c0d8d9b6. It is binary alpha, same world 1280x928 and source RGB, intersects no previous four-object Runtime mask, lies wholly within Authoring CompletePAR. Trial combined Runtime PAR **122270 pixels** (was 118425). Both distinct mask and overlay PNG in private ZIP. **ART FAIL/PENDING** because rails still have holes/stray colors and source painting is not accepted FS Ground3 1x pixel style.
5. Logged and rejected V0 generic GrabCut which accidentally captured wooden bridge deck and grass. V1 manual rail silhouette 4075 pixels; V2 excludes 230 green-dominant suspect source pixels, 3845. This is a narrow art study, not a validated production layer. V3 original Authoring-only 746103 pixels must NOT be blindly copied to Runtime.
6. Produced synthetic switch-style bridge actor ON/OFF previews using 25x32 actual native actor diff from existing V3 Game.exe screenshot (627 pixels), with 180 pixels affected at bridge deck candidate (23,18), 221 underbridge (22,19). These are **Python projections**, not actual new native VX captures.
7. Uploaded candidate ZIP and separate rebuild scripts ZIP to private Drive and **read back the exact original candidate bytes**. Deterministically regenerated 3845 mask with **0 pixel delta** and resulting 122270 runtime and 784-reachable collision; no user-PC persistent files, no PixelLab credits.
8. GitHub public modules: tools/asset_factory/adapters/collision_review.py plus tests/test_a06_collision_review.py (six positive/negative fixtures for tiny overlap, proper L/RGBA alpha, no isolated walking tiles). Total **63 synthetic tests**, first successful run 42419322008 at source commit 3d3f92d8b675160e4a0c4145738234eef15c49cf. Recheck final PR head after later document commits; do not claim old run covers new HEAD.

## Corrected PMD A26 approval semantics
Original A26 2026-11-01 Handoff: https://docs.google.com/document/d/1d6PViz9qJHUzepjPzbQHBxHNY5pNJY9AqZQb6BoqQwk/edit
- A25 lava creature **appearance** was accepted as the reference. Do NOT claim A26 Idle/Walk five-frame candidates have already passed user animation art.
- A26 generated five-frame Idle and Walk candidates (some Idle raw artifacts cleaned), but **real native PMD XML Idle = 3 frames; Walk = 6 frames** and full eight-direction Anim/Offsets/Shadow was not completed.
- A26 old private ZIP source SHA 460b8ca230e579e78d2f3350f0f10c0ba0ab5af2fbaee063faf3bdb3baee1399 is still SOURCE_NOT_VERIFIED. Do not substitute old original/rock PMD images and do not waste PixelLab calls without a source-authority plan.

## Orca status (do not fake agent delegation)
- Historical Orca A36F dual agents ran and found important semantic/9px misclassification. Current A06 new Orca S1/M1 **NOT LAUNCHED**, because approval policy of Orca UI not yet verified. Codex CLI has explicit read-only sandbox, but a direct CLI call is not the Orca UI orchestrator. Do not launch unsandboxed autonomous file writes to user's PC.
- Orca assignment remains [taskboard](ORCA_A04_TASKBOARD_20261108.md). Native VX Windows clone needs **independent explicit PC temp scope and cleanup approval**; worktrees aren't OS sandboxes.

## Gate matrix
- Frozen source ZIP / 5th object Master RGB identity / private Drive byte SHA: PASS.
- 5th Alpha provenance and no ownership overlap: PASS.
- V4 patch collision BFS static: PASS.
- Bridge front railing complete silhouette/1x FS art: **FAIL/PENDING**.
- V4 new Map050/Game.exe switch203/continuous movement: **NOT_RUN**.
- PMD new lava 8direction/3f+6f native animation: NOT_CREATED, art NOT_APPROVED.
- Orca A06 new agents: NOT_LAUNCHED.
- FORMAL_SEAL: NO. PixelLab charge 0. Main untouched. PC new work files 0.

## A07 exact order
1. Starting at the private A06 ZIP (not rebuilding source from memory), fix real front railing silhouette at native 1x without copying deck/grass. Every new object mask needs authoring subset + zero double-ownership + Master RGB registration + actual sprite overlap visual.
2. Finish realistic river/bridge and roof contact collision: use V4 6-candidate proposal as a test input, but native Game.exe/Map050/Switch203 must be executed separately in permitted isolated Windows temp and cleaned. Only pass if actual player path and semantic footpoints are legal.
3. Grow Authoring PAR inventory by actual source/geometry objects (bridge, gazebo, rocks, roof eaves, canopy family) rather than mask from whole flattened composited ground; keep V3 and A36H tracks distinct. Document full source SHA and human art gate.
4. Recover or recreate *source-approved A25 64px lava creature* in private Drive before any costed motion attempts; make action-specific native 3/6 frame and eight-direction art with genuine human acceptance, no fake frame duplication.
5. Bring true Orca S1/M1 under verified read-only/approval settings for independent adversarial reviews. Deliver another Drive + GitHub versioned Handoff with final-head real CI and native/art outcome.

Rollback candidate branch only. No sealed source overwritten.
