# Forest Symphony F2_R3 / PMD 0001 P3_R3 — Source-first Progress Authority, 2026-10-26

## Status & provenance
User directive: **continue the actual project work**, do not return to concept-only image generation or geometrical monster mockups. This authority records production files/QA, not a finished Forest Symphony map or accepted monster.

### Frozen baseline
- F1R1 A04 accepted forest scene: USER_VISUAL_PASS, immutable ZIP SHA256 `0a407d9dce66183703fe957193a396cc59648d3b4502cd0c83e4f83e3035272b`.
- Previous wrong-style F2 house ART_FAIL, P2/P2R1 geometrical monster ART_FAIL, P3_R2 nearly recolor-only rejected as insufficient.
- Last paired image-only tool response identified FAIL_WORKFLOW_TOOL_ONLY_IMAGE_GALLERY, not production material.
- NO_DRIFT policy: `authority/AI_ART_NO_DRIFT_EXECUTION_LOCK_20261026.md`.

## F2_R3 actual scene semantic extraction — G2R1
- **Source**: user's actual `精靈森林小屋花園秘境.png` high-detail fantasy forest village reference. The scene is used as a coherent input; no new assistant-invented house geometry and no image generation in this continuation.
- **Working dimensions**: crop x=4..1444 and pad last 2 rows to **1440×1088 (45×34 tile grid at 32px)** without resampling. Original scene colors/ref are kept.
- **Actual independent editable PAR source objects**:
  - `HOUSE_PAR_SOURCE.png` (source-cropped image, independent binary semantic alpha mask `HOUSE_SEMANTIC_MASK.png`, `HOUSE_CONTACT_NATIVE_32PX.png` footprint). Closed door tile (26,14) = blocked; immediately south tile (26,15) = free in **semantic manifest only**.
  - `TREE_LEFT_PAR_SOURCE.png` (ancient left deciduous tree cluster extracted by source-assisted GrabCut with original-frame pixels; `TREE_LEFT_SEMANTIC_MASK.png`; `TREE_LEFT_TRUNK_CONTACT.png` blocking tree trunk, not canopy).
- Both objects use the same single source scene. Source-owned masks have **zero overlap**, with source-backed pixel ownership, not two independently generated flattened images. Recomposition over **provisional Ground** matches original source image exactly: **RGB 0 pixel drift**.
- Actual scene source includes `SCENE_MANIFEST.json`, PNG masks/sprites/Ground/recomposed source, per-version source-build scripts, repeatable `VERIFY_F2_G2.py`, test CMD, QA LOG, `CURRENT_HANDOFF.md`, and `FAIL_TAXONOMY.md`.
- [Private complete F2 G2R1 source release ZIP](https://drive.google.com/file/d/1flMFKH__zwpd9KWFKYN4kEiR632d_5t8/view?usp=drivesdk): **10,240,498 bytes**, SHA256 `0b92618edc38a8d3257d0f973015302d76106ba42215cc124ec9c36b4ee7c2d1`; ZIP CRC and fresh extracted QA all PASS. Source scripts included.
- [Composed original-provenance visual](https://drive.google.com/file/d/1Kv6b8FJw9riXbtCIPHFd_upqVtZcXiLD/view?usp=drivesdk) (G2 visual unchanged in G2R1); [G2R1 Handoff](https://drive.google.com/file/d/1RA4x1wVwa9IV40emM0yGhuwBP9zR4gVc/view?usp=drivesdk); [failure ledger](https://drive.google.com/file/d/11cCX5hkbWV5Y6a-myby8CyKDmcZvrPxK/view?usp=drivesdk).
- **Important failure gates**: Global foliage, other trees, rocks, flowers, fence, stone perimeter, outside-black-void still remain provisionally embedded in Ground and are NOT separately semantic yet. Removing house/tree reveals **unfinished underpaint with seams**; Ground art is NOT human accepted. Semantic 32px door gate is calculated, real VX `Game.exe` path/camera/roof sorting NOT TESTED. Do not claim final Ground/PAR, pixel-perfect engine layer, or a playable benchmark.
- G1 OpenCV inpainting under the house was visibly blurred (FAIL_UNDERPAINT_BLUR); G1R1 source hard 80px tiling produced checker seams (FAIL_GROUND_VISIBLE_SEAMS); G1R2 improved by 80px original-source patch quilting with 16px hard pixel seam; still underlay candidate only. Initial G2 PIL NumPy readonly write error corrected using writable array; failed staging retained. No old versions overwritten.
- Next F2 `G3_FOREGROUND_CLASS_EXTRACTION`: right-side trees/rocks/flower planters/perimeter class masks, separate owned PNG/contact masks, build ground void-exclusion and coherent underpainting; only then actual VX collision tests and user visual gate.

## P3_R3 — PMD0001 original XML-timed source sprite morphological transformation
- **Source**: `PMDCollab/SpriteCollab` `sprite/0001` real complete source and `AnimData.xml`, action `-Anim.png`, `-Offsets.png`, `-Shadow.png`.
- Previous P3_R2 changed green seed body mostly to gray and added small facets with identical alpha, user considered almost recolor-only. This new P3_R3 changes **creature silhouette** by adding faceted angular raised stone crystals over the carried seed in **every cell** of **34 original action images, 1,123 original animation cells**. Keeps real original action-specific atlas dimensions/layout, original per-cell rect and untouched lower actor foot regions, not a false global collage grid.
- Source `AnimData.xml`, ALL original offsets and shadows byte-for-byte identical; every action image original full size and action timings unchanged. Each cell has nonzero alpha silhouette change and no **new** border crop. Source and derived folders independently preserved, after cold ZIP extraction QA rerun.
- [Private P3_R3 full source derivative ZIP](https://drive.google.com/file/d/1KhC86p3TIWBXwt1bJIXIa7_heRm2fKlw/view?usp=drivesdk): **510,600 bytes**, 215 files, SHA256 `3352d68d39ded4dcc4c880180c0fab58471f7b88cfc91b1e7f5d60c05f00db15`, CRC SHA and cold 1,123-cell QA PASS.
- [Original vs revised real 24 direction-cell visual comparison](https://drive.google.com/file/d/1IK1x4XqCmF8nDZnWXgPRiOADnRhxvt9i/view?usp=drivesdk) | [P3 Handoff](https://drive.google.com/file/d/1vygXrRWrr_Jd4jEzaP8UscJ0k8NJ5zm9/view?usp=drivesdk).
- **Limits**: No actual PMD engine parser or VX SBS animation player has been run on this modified 0001 yet. **Human species quality remains PENDING**. PMDCollab contributor and commercial permissions must be respected and separately verified.

## Rules delta required for next iteration
1. **Do not fake completed Ground** just because owned PAR composited exactly to original scene: explicitly list any remaining flattened object classes and fill quality.
2. Each PAR object needs independent source sprite, transparent ownership mask, depth/foot anchor, and *contact-only collision*, not automatic pixel-wide solid footprint. House closed door blocked, immediately prior tile walkable, real foot movement requires native VX confirmation.
3. For PMD derivative, XML/action row/column/pivots are fixed, while alpha may change inside cell to produce an actual species silhouette. Per-cell clipping and foot position tests required, original XML/Offset/Shadow byte invariance.
4. Every milestone ships ZIP, source scripts, tests, logs, CURRENT_HANDOFF, errors; sync GitHub Authority, Google Drive and Linear. Do not promote user art status or modify accepted F1R1, parallel P1G.
5. No extra standalone concept images unless explicitly asked; user asked for engineering progress.

## Actual next gates
F2_R3_G3_FOREGROUND_CLASS_EXTRACTION; P3_R3_G2_XML_PLAYER_NATIVE_IMPORT (a real animation player using original XML timing and action grids, not an illustration). User human review continues separately.
