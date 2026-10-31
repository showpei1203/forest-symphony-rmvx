# Forest Symphony / ASF A15: actual pixel-art repair, not another fake motion pass

**Date 2026-10-31. Final outcome: corrected private candidate assets, ASF+Godot TECH PASS, ART QUALITY STILL PENDING.** Unsealed FS/R17/Tankentai/LPC/PMD sources remain untouched. Source branch is an isolated prototype, not production-ready sprite sheets.

## Core objective

Start with one GPT-generated Master for each character/monster, design new credible motions with consistent art identity, then use ASF to compile transparent PNG frames and sprite sheets; only after visual human Gate F proceed to native FS/VX. Prior A10–A14 already proved file format, shader-nearest rendering and Godot playback; A15 prioritizes *real pixel corrections*.

## What was materially improved

**T1 forest scout (A10 original Master 64×80):** The earlier attempted scabbard mask x49..55/y60..66 was in a transparent region; A15 enlarged the original Master with 18× coordinate grid and identified a small gold-coloured visible hilt cluster at **x40..41/y63..64**. In the 6 post-draw attack frames (02–07), **24 source-identical RGBA pixel matches** were verified before replacing those 4 per-frame hilt-colour pixels using an adjacent, actual source brown leather palette. Sheathed frames 00/01 are untouched. Other T1 actions are byte-identical to A14. This is *partial scabbard-state repair*, not a full new arm/sword rig. Main remaining issue: hand grips, shoulder/forearm articulation and force transmission still look stiff.

An experimental **cyan slash arc** was also drawn, but close visual inspection revealed the effect crossing the character's face region. That entire arc iteration was **REJECTED**, and none of its cyan sweep is present in the final accepted prototype.

**T2 moss-antler (A10 original 64×64):** A14's oversized *rectangular* source leg crops included bright belly/face pixels and created ghost light-coloured belly bands when moved. A15 instead uses **four smaller organic polygon masks** to retain darker lower-leg/hoof pixels, preserves torso/belly as the source-backed base, then composites far legs / body / near legs at the known A13 foot targets. Collision/impact dust is a small pixel accent confined to attack_04 and attack_05. Launch/recovery dust candidates were rejected. Rest frames 00 and 07 remain original source Master, and other nine nonattack action clips remain identical to A14. **Across all eight attacks, 10,160 translated opaque pixels of the source head and antlers matched the original Master exactly (0 mismatches).** Midmotion seams/weight distribution still need human review; this does not establish real four-legged gait.

Actual changed attack PNGs versus A14: **T1 six frames (02–07); T2 six frames (01–06)**. Unchanged files retain exactly their prior bytes.

## Real output and engine tests

- **ASF** real `build_animation_clips.py --strict`: T1 **6 clips / 46 source frames**, T2 **5 clips / 38 source frames**, **0 warnings** each.
- **ASF `export_engine.py --target all`**: Aseprite JSON, Godot SpriteFrames, Godot Sprite3D, both PASS. T2 has 37 actual exported frames due to earlier faint-frame dedup.
- **Godot 4.7.2 stable, Radeon RX 6700 XT, OpenGL3.3**, loaded and played all 11 ASF exported clips in a real graphical runtime. Two GPU captures, **22/22 exact source RGB image comparisons; 0 pixel errors**. This is transport/assembly fidelity, not an automated art approval.
- Final two 8-frame attack preview GIFs are in the private ZIP; their RGB preview backgrounds are not used as final RGBA source.
- K4/N5 formal script SHA values remain unchanged as rechecked during this package build.
- T1/T2 art G7 **NOT PASSED**; actual image-to-video/model-generated animation **NOT RUN**; FS/VX new sprites **NOT RUN**. Production merge **PROHIBITED**.

## Rejected and retained trial stages

1. **A15 R1:** 24 safe source pixels of T1 hilt cleaned. T2 lower-leg polygon/source-palette segmentation reduced copied belly band.
2. **A15 R2 experimental:** long T1 cyan slash was rejected because it appeared over face; T2 brief contact dust retained on 04/05 only.
3. **A15 FINAL_CANDIDATE:** **T1 R1** + **T2 source-leg R1, limited contact-only R2 dust**, all other actions unchanged.

Original image generation also returned another infographic rather than a clean single-keypose sprite; it is **not used as source art**.

## Files and source provenance

The original AI-created sprites, graphic previews and actual Godot GPU screenshots remain private in the authorized Windows machine. Only original code, structured QA, design decisions and hashes are committed here.

Windows working root:
`E:\GameAssetToolLab_20261023\ASF_Test_20261031\A15_ART_REPAIR`

Final candidate and 2 8-frame GIFs:
`E:\GameAssetToolLab_20261023\ASF_Test_20261031\A15_ART_REPAIR\FINAL_CANDIDATE`

Complete **Windows-private** archive: `FINAL_CANDIDATE\A15_FINAL_PRIVATE_20261031.zip`. **636 files, 2,943,655 bytes, ZIP CRC PASS, SHA256 `ebe074d87cc242bbeab5d4e3061a5db0333a6db2bff2abac6c60f870aa5956b5`**. It has **NOT been uploaded to GitHub or Google Drive**. Public GitHub does not contain the original frame images.

Important reproducible tools/data:
- `scripts/a15_source_art_r1.py`: source-verified hilt and polygon leg masks
- `scripts/a15_r2_effects.py`, `scripts/finalize_a15.py`: rejected broad slash & selected impact-only dust
- `scripts/package_a15.py`: source hash integrity checks, 8-frame previews, provenance and private ZIP CRC
- `data/A15_FINAL_QA.json`: final TECH vs ART gates
- `data/A15_FINAL_VISUAL_SOURCE_QA.json`: head/antler pixel identity and unchanged clips
- `data/A15_ARCHIVE_INVENTORY.json`: reproducible Windows-only archive

## A16 focus

**Stop repeating export-only G5/G6 validations as supposed art progress.** Need true hand-to-hilt occlusion masks and neutral source body under the animated shoulder; T1 backfill with exact leather/skin palettes and four distinct well-staged poses; T2 continuous heel-to-ground leg and back-body interface, contact/shadow simulation. Test at actual 1× and upscaled 3×, *then* run ASF on approved art. Keep immutable source A10 and archive all rejected keyframes.

A15 verdict: **specific source-art correction and limited impact readability improved, full art gate still NOT PASSED**.
