# A06 / V4 real collision and bridge PAR candidate QA (2026-11-08)

Status: SOURCE_PIXEL PASS / COLLISION_GRAPH PASS / NATIVE VX NOT RUN / ART FAIL-PENDING / FORMAL SEAL NO. Public GitHub contains no licensed game-image bytes.

## Private cloud-delivered real artifacts
- A06 layered master-first trial, candidate collision and before/after ZIP (restricted private Drive; locate by filename in 05_Handoff). Size 10,457,859 bytes. ZIP SHA256: 48af22427d0ba7560c19b8c16dbaf23f15d2076c5af7073155b66b5a469ecaf6.
- Deterministic rebuild and failure-history scripts (restricted private Drive; locate by filename in 05_Handoff). Size 11,497 bytes. ZIP SHA256: ab7a51bf367d67f92853663a6eaea9bef84d0cb8bb1bc79a0372afa601d29876.
- Source private frozen V3 archive SHA256: b38c08109e25299fa9f4ceabd7f34b42cc82531ba56c8f09cc9f3a4af0429511; Master SHA256: 091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530.
- Full trial ZIP was fetched back from Google Drive, passed ZIP CRC and exact SHA256 verification. The source-only deterministic rebuild reproduced bridge mask alpha exactly, 0 pixel difference; no PC files or PixelLab usage.

## Actual V3 collision error
Frozen V3 real native draft 29x40 has 1,160 tiles: 370 blocked and 790 walkable, but center-point BFS (20,15) reaches only 787.
- Disconnected walkable cells (7,6),(8,6),(9,6) are painted on the left house roof, not a legitimate walking surface.
- Under-bridge (21,19),(22,19),(23,19) were marked walkable despite 1x screenshot-derived actor being drawn over river water. This is an art/collision candidate mismatch, not a native runtime pass on those tiles.
- V4 candidate changes exactly six cells to blocked, making 376 blocked / 784 walkable, all 784 reachable, while preserving an 8-vertex 4-way bridge-deck path from (20,18) through (24,18),(24,19),(24,20) to (25,20).
- No V4 Map050.rvdata or Game.exe test was run. Candidate masks and collisions do not overwrite original V3 or main.

## Original QA's false-zero threshold bug
Original REBUILD/build_masterfirst_v3.py called the threshold condition fraction > 0.2 but named the resulting count walkable_actor_candidates_with_any_roof_overlap. It reported zero when strict any-pixel overlap really finds 4 left-roof and 9 right-roof draft-walkable candidate tiles using the very same 23x30 player rectangle. This was a **label/threshold false PASS**, not proof that any roof position is actually legal to stand under.

- New tools/asset_factory/adapters/collision_review.py checks true nonzero mask-pixel overlap separately from >20% significant overlap; handles L-mode masks as grayscale rather than falsely treating their RGBA-converted alpha as opaque; reviews graph connectivity and attributed candidate patches.
- New tools/asset_factory/tests/test_a06_collision_review.py: 6 new synthetic positive/negative regressions. Together with A01-A05 57 tests: 63 total. Check final PR branch head's actual Actions before claiming final CI.

## A06 fifth object, genuine source-registered raster
- Existing four-object runtime overlay: 118,425 alpha pixels. Full Authoring PAR: 864,528; never blanket-copy broad Authoring to runtime.
- New bridge near/front railing object candidate full-canvas 1280x928 L alpha mask: 3,845 pixels, SHA256 7a3d36087062fb4118da594318ba719f079e49f291bde54aa120d116c0d8d9b6. Source RGB exact frozen Master same world XY. Overlap with previous runtime masks = 0; alpha outside Authoring = 0.
- Trial five-object Runtime PAR alpha = 122,270 pixels. Kept separate from existing V3 approved source.
- First V0 GrabCut broad-selection wrongly included bridge deck and plants. Manual rail-specific V1 narrowed to 4,075; V2 removed 230 green-dominant suspect pixels = 3,845. V2 silhouette STILL has incomplete posts/holes and minor stray pixels, **ART FAIL/PENDING**.
- The actual actor overlay comes from V3 historical native Game.exe screenshot diff (25x32, 627 silhouette pixels). Synthetically projected on source master, underbridge (22,19) overlaps 221 bridge candidate pixels, while bridge-deck (23,18) overlaps 180. These are PYTHON SYNTHETIC witnesses, not new native screenshot runs.
- The 1280x928 image is still painterly, not proven to meet FS Ground3 1x pixel art appearance.

## Correct A26 approval/provenance
Original 2026-11-01 [A26 Handoff](https://docs.google.com/document/d/1d6PViz9qJHUzepjPzbQHBxHNY5pNJY9AqZQb6BoqQwk/edit): A25 lava monster **appearance** was approved as reference, not the five-frame A26 Idle/Walk candidates. Raw Idle had artifacts, repairs were proposed, user art review still pending; native Idle XML requires 3 frames, Walk XML 6 frames, unlike candidate 5 frames. A26 was not exported in complete native XML, offsets, shadow or eight-direction system.
A26 private archive source SHA 460b8ca230e579e78d2f3350f0f10c0ba0ab5af2fbaee063faf3bdb3baee1399 remains SOURCE_NOT_VERIFIED, do not substitute generic original PMD source.

## Orca and next stage
Historical Orca A36F dual reviews exist, but no new S1/M1 agent was started for this A06 source. An installed Codex CLI supports explicit read-only sandbox; that is not proof the Orca GUI agent is in approval-required mode, and no unsafe autonomous PC process was started.
A07 sequence: review bridge silhouette at 1x, validate physically walkable river/roof tiles and source-matched 5-object Runtime in isolated real Game.exe once temporary Windows workspace/cleanup is authorized. Preserve strict per-object Authoring ownership and full Native 203 checks. Locate approved A25 lava source before attempting true native new monster sheets.


## Private-art security rule (A06 correction)
Public source documents must NEVER contain direct download URLs for protected PNG/ZIP or private Drive documents that expose those links. The private Drive artifacts and named source archives are located through the owner's private FS authority index. During A06 Drive metadata verification both new artifact ZIPs had anyone-with-link reader permissions; this is **NOT restricted access**. Owner must change sharing to Restricted in Google Drive; no permission-revocation tool was available in this session. No raw image bytes are in public GitHub.
