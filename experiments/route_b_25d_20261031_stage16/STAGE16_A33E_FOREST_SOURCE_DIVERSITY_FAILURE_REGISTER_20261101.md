# Stage16 A33E | Failure register and preventative steps
Date 2026-11-01. All source/candidate files are independent, A33D sealed as predecessor engineering candidate but art not formally user signed off.

F-01 A33D visual diversity LIMITATION: A33D passed native VX and Godot engineering with 13 trees/21 PAR, but many of 9 new trees came from mirrored/rescaled variants of only four existing broadleaf sprites. A33E introduces two genuinely different **Drive source conifer shapes**, tree01.png (dark triangular fir) and Hanzo-VSTrees03.png (tall serrated conifer). Four repeated A33D clone slots replaced by source-diverse images, plus two additional pines; old A32B 12 accepted sprites untouched. Avoid falsely claiming six new species: six conifer images use only TWO novel source species. Slight foliage intrinsic tone/nearest scale is not a new species.
F-02 alpha crop/canvas: Hanzo sheet contains multiple conifers and mirrored palettes; source crop `(206,29,338,248)` had alpha bbox `(6,15,115,201)`, borders empty. Retain exact parent SHA and preserve native RGB leaf structure. Complete standalone canvas must have transparent top/bottom/left/right; `tree01.png` source RGBA 64x96. No blurry edge filter, no fake ground shadow and no truncated object.
F-03 bright/dark mismatch: first source-normalization comparison left Hanzo pale/neon and tree01 too dark relative to accepted broadleaf canopy. Source-leaf internal RGB-only adjustment changed Hanzo foliage G multiplier 0.90->0.80 and fir 1.20->1.45; alpha/feet/collisions unchanged. Save comparison evidence and review at actual 1x.
F-04 first native VX build failed because script assumed exact trailing newline bytes while patching test-only script483. The failure clone was retained under `E:\FS_STAGE16_A33E_VX_FAILED_BOOTSTRAP_20261101`, then reran copy from immutable A33D and replaced tail via `rfind('  end\\nend')`. No hand edits to actual production. Scripts Marshal roundtrip / native startup checked.
F-05 original A33D fixed new blocking 21 cells, A33E 2 NEW tree feet (7,5) and (16,6) are not on roads and are distinct new collision E=768. 23 blockers /198 passable, BFS198/198. New smaller 9 shrubs are **nonblocking**. Never make shrubs impassable solely because their PAR art is present.
F-06 visual limitation: 9 small programmatic shrub sprites are clear when isolated on checkerboard but several are too subtle in actual 1x native forest due to scale/background texture. Therefore art remains **PENDING**, not 'fully realistic'. Next improve some shrubs as multi-sprite distinct berry fern/clump species at 1x rather than simply adding another dozen miniature dots.
F-07 Native sprite data integrity: 32 actually independent Cache.overlay in isolated Map050 test, source A32B 12 PNG immutable, 5 A33D tree sprites unchanged, four replaced in the isolated candidate. A33E Godot 16 GPU frame proof and true VX 18 cases/36 frames. Godot native noactor differs at 3,908 positions max 1 RGB, 0 >1, **NOT exact-zero parity**.
F-08 formal seal: original project VX battle regression previously blocked and isolated map-only test script uses old A30 test-only bypass. Cold clone startup of this isolated scene, even perfect, does not prove legacy production. Formal Seal NO; user Ground/PAR art review PENDING.


## Verified A33E Private Google Drive source and 2026-11-01 QA
These exact links and ZIP byte count were read back from connected Drive after local Windows G:\ sync:
- **Actual RPG Maker VX native BEFORE/AFTER**, 544px wide + 4 terrain quadrants: https://drive.google.com/file/d/18z1Sf9PRKw3G-PmqZtvUSoN2zMwOgX1d/view
- **True Ground+PAR A33D vs A33E side-by-side**, 13 vs 15 trees, source-composited: https://drive.google.com/file/d/1I1rSNEwf6onKXFuwPRf4drm0UFkR5q5s/view
- **New A33E Ground** 544×416 opaque PNG SHA `d129d229a1d5b75e3ab9ae061c9d42eea3a1014cbaa1b581c360b0b6b57c3fa5`: https://drive.google.com/file/d/1Ufj6R1be3wgFCE8v-0L2w33OYUOLXhE-/view
- **New A33E Par50** 32-object transparent PNG SHA `0bb510b71ab5ad7c265b464d2aacfe228f3a4e98df2430bb8fc2a2e14c5b6b9c`: https://drive.google.com/file/d/1IWUoaPtfNFilv9W7t0hxK7FyMDrKCrbh/view
- Ground + 32 PNG PAR real composition: https://drive.google.com/file/d/1AUuwglBIRFXRmToLuy_7tSZxPOQIWwDI/view
- **New source-conifer vs 9 individual shrub RGBA contact**, inspected original alpha: https://drive.google.com/file/d/19j-PNfBfZOiM7DBn49k00gZP3Pj_r1fN/view
- **Actual new 15 standalone RGBA source PNGs + scripts + tests** in private ZIP: https://drive.google.com/file/d/1TbdBhZUqjCddpbQskZTNHjY_HfvNv5U0/view , 143 members, 35,053,988 bytes. Local ZIP CRC, ALL SHA256 and independently re-extracted SHA PASS; actual Drive name/byte metadata readback PASS, but no additional full remote ZIP download checksum claimed.
- A33E provenance/source manifesto: https://drive.google.com/file/d/1hP7uFX7xdUOg3ugtiy6mlQKTcxWj6vp6/view
- Native VX 18-case/36-frame QA: https://drive.google.com/file/d/1M4JhrqGSsGfeEnPqG7jUW8Uo1xnbDEtE/view
- Native GPU numerical RGB QA 16 frames: https://drive.google.com/file/d/18-nAyJvTU2TQFZO75MciQ8KmMEofyMlh/view
- Native independent 3415 SHA files cold verification: https://drive.google.com/file/d/1PUP0lgulkejYg1ZRA-sROGgtm0KzQzhl/view
- New permanently active species/shrub visual QA: https://drive.google.com/file/d/1E6rnVxRhsNHqmnkeOv_UoZ0L85DmOVJl/view
- A33E failure register: https://drive.google.com/file/d/1WWaDNDkw7IrT6Rz9_DTo7bXUchs3bGcn/view
- A33E detailed Handoff: https://drive.google.com/file/d/1hTsgMiOfsTAUmGJ6s_pQrRMApcYpHraI/view
- Latest CURRENT_HANDOFF: https://drive.google.com/file/d/10niiBdMJFxEZ3chUoyi2rxX5sMzjQVPM/view
- Stage 16 A33E folder: https://drive.google.com/drive/folders/1d2gz2oaPmedmhPrA33mpfmZ5pOmKGN1R

**Engineering PASS: 18 native VX cases/36 frames, Godot GPU 16 native frames RGB tolerance1, cold 3415 SHA files; A33E forest art user approval PENDING and Formal Seal NO.**
