# A10 | REAL Source-first Map and Actor Pilot — 2026-11-08

Status: ACTUAL 2 × 4-layer PNG scene candidates created. Static source-owned alpha ownership verified; user ART PENDING / river and bridge style FAIL; actual VX NOT RUN. This is not a release seal.

## Source-backed production, not flattened-image color guessing
A09 had only two Tiled geometry layouts. A10 now created TWO actual 1280x928 scene sets from independent transparent source PNGs, with semantic owner IDs registered BEFORE composition. A complete Master is composited from ground underpaint plus registered independent houses, tree groups, shrubs, and bridge objects. For bridge, deck / far rail / near rail / support posts are FOUR distinct generated source objects. Neither bridge nor trees use GrabCut or RGB color thresholds to classify pixels from an already flattened Master.

## Private source and provenance
- A36H R3 197-source-art ZIP: 31,567,182 bytes, SHA256 d0ecbe0c82ed12a4431f38564c03a1827f701ad90e2979b76e503e0f0a93f2c5. Original A36H scene user ART still pending.
- A32B historic user-accepted tree ZIP: 10,366,572 bytes, SHA256 219e8c771c8ac8cf027c73c72cea9ee22618b03cd15670508643044764eab633.
- A63 actor 48px three-pose archive: 327,601 bytes, SHA256 154b3970778ab758008139b19e7dd15c62614c947889a66dd9b31d1e94ba9be9. Historical A62 Run was approved; A63 W2 Waiting is technical candidate, not user ART approved.
- Authentic original ground3 style reference Graphics/Parallaxes/ground3.png SHA256 ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13. The A10 underpaint reuses A36H R3 grass/path candidate, NOT raw approved original Ground3 pixels.

## Actual sealed-content-but-not-approved-art archive
FS_A10_DUAL_FACTORY_REAL_MAP_AND_SPRITE_PRIVATE_20261108.zip: 22,536,082 bytes / 270 members / CRC PASS / SHA256 3aa93b84190c4b4af63167b9e249a2c69bbe142a0b195ee27a92b75c9cb22eea. Uploaded to owner-only restricted Drive, downloaded back and independently SHA/CRC verified. Protected PNG/ZIP/Drive file ID are NOT present in the public GitHub repository. The full rebuild scripts are included in ZIP BUILD_SCRIPTS/.

Each of ELF_VILLAGE and FOREST_BRIDGE includes: Authoring_GroundOnly.png, Authoring_CompletePAR.png, Runtime_FullGround.png, Runtime_OcclusionPAR_CANDIDATE.png (all 1280x928), per-object local occlusion alpha masks, semantic owner manifest, seed, collision candidate, 640px preview and local bridge debug contact. Two scenes differ in 1,184,871 distinct RGB pixel positions.

| Measured pilot metric | ELF_VILLAGE | FOREST_BRIDGE |
| --- | ---: | ---: |
| Placed source art instances | 105 | 132 |
| Visible instances | 102 | 118 |
| Eligible source-owned PAR alpha pixels | 249,372 | 232,123 |
| Forbidden bridge deck or ground decoration source pixels in PAR | 0 | 0 |
| PAR RGB mismatch to same-XY FullGround | 0 | 0 |
| GroundOnly + CompletePAR reconstruction maximum 8-bit channel delta | 1 | 1 |
| Pixels exceeding 1-channel delta | 0 | 0 |
| Collision candidate blocked tiles | 96 | 186 |
| Candidate reachable tiles from spawn | 1,062 | 974 |
| User art status | PENDING | FAIL_STYLE: bridge and river material weaker than reference |

Independent source identity QA verified 72 Elf and 79 Bridge foreground masks, each mask alpha subset of its OWN independent registered RGBA art (including mirrored placements). Strict source provenance and no color extraction from Master. Collision BFS and debug actor composite do not prove native legal footpoint, RGSS2 z-sort or switch 203.

Actor01 has TWO actual historical-action source output folders: RUN with 48x48 F0/F1/F2 + playback [0,1,0,2], historically approved A62; WAITING with 48x48 F0/F1/F2 + playback [0,1,2,1], A63 W2 ART PENDING. They are source REUSE, NOT new sprite generation or completed native Tankentai animation.

## Next A11: whole-family quality, not pixel tweezers
1. Replace entire bridge source family and river terrain recipe at once with a style-matched component system; never resume near rail V1/V2 pixel cropping.
2. Compare full-scene at 1x against authentic original Ground3 and the accepted A32B tree; fix source style for broad family, not individual leaves.
3. Verify actual A10 legal actor footpoints and per-object 203 switching in a separately authorized isolated RPG Maker VX Game.exe test, not a Python illustration.
4. Start genuinely NEW Sprite Pilot only from an approved real source, using locked reusable rig and action-specific PMD XML; do not count A62/A63 source reuse as new generation.
5. Track first-pass user ART success and exception ratio before expanding batch. PixelLab new calls 0, Orca agents 0, PC persistent files 0, formal seal NO.

Public machine-read receipt: ../../config/asset_factory/FS_A10_REAL_DELIVERY_RECEIPT_20261108.json
Public cold validation program: ../../tools/asset_factory/validate_a10_private_delivery.py
Existing SOPs: FS_SPRITE_FACTORY_SOP_V1_20261108.md and FS_MAP_FACTORY_SOP_V1_20261108.md
Full private rebuild implementation is in restricted Drive A10 ZIP, not in publicly exposed proprietary assets.
