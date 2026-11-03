# FS / PMD G12: native source-pixel PMD0002 Hurt basalt consistency repair
Date: 2026-11-04 (Asia/Taipei)

## Authority, scope
- User: "好，繼續" after G11 0001→0002→0003 SE45 DIR_1 correction.
- Continue in **original source PMD native 8-direction sprite atlas**, DO NOT regenerate role/monster concept art.
- A68 actor recolor remains PAUSED. PMD0001 user's approved G3R1 and PMD0003 prior G9/G11 candidate untouched.
- G11 baseline: `PMD_G11_SE45_0001_0003_COMPLETE_NATIVE_20261103.zip`. G11 43 genuinely 8-direction actions/15 source-single-row actions preserved.

## Identified specific art problem
- G11 / PMD0002 / Hurt / DIR_1 / frame0,frame1: injury pose becomes mostly plain orange round rump. The split basalt plating and magma from the approved evolution's Idle/Walk are absent in this action.
- Verified vs original PMD0002 Hurt geometry: original underlying source also presents the turned rump, so pose change is authentic, **the missing geology is the issue**.
- Preserving source motion beats reconstructing body anatomy via AI. Do not overwrite natural original Hurt pose.

## G12 actual sprite correction
- Exactly one full PMD production atlas modified: `PMD_NATIVE/PRODUCTION_0002/Hurt-Anim.png`; native cell=48×56, eight direction rows × two frames (16 cell positions). 14 cells changed, two DIR_4 cells remained byte-equivalent because source rock/region already occupied it.
- A total of **404 color pixels** retouched on the existing opaque source flesh; 0 alpha changes, **no new pixels outside source silhouette**.
- Native gray source basalt palette reused, with two small faceted rock plates and orange molten seam on the missing back area. Pixel-edit polygons anchored to native cell alpha bounding boxes, no resampling/rotation/invention of new limb geometry. Source art remains an imperfect human visual candidate.
- The three SE45 (_1,_2,_3) review frames are regenerated directly from patched original image at 0-based indices [0,1,1]; repeated key3 reflects PMD Hurt's actual 2 frame count. No fake third pose.
- All remaining **57** production action atlases are G11 byte-for-byte unchanged; all original source anim atlases, `AnimData.xml`, `*-Offsets.png`, `*-Shadow.png` byte-for-byte unchanged.
- Existing 45° SE direction is source DIR_1; **15 single-direction source actions remain not 45° and are still PENDING**, no "all complete" claim.
- Main reconstruction script `g12_retouch_hurt.py` in local workspace can regenerate the retouch; embedded G12 archive contains full raster, regenerated 3-keyframe and QA/checksum data.

## Delivery and verification
- G12 ZIP: https://drive.google.com/file/d/1IwZ8SO29p59iDXrTAy0JA_N33MIi7DJ9/view
- G12 Drive folder: https://drive.google.com/drive/folders/1warGGjKyqFZpo-YULcrFz_S7LxmQsvej
- G12 3 evolution stages Hurt before/after: https://drive.google.com/file/d/1oi6XBkTkCYPUg9QIxfe9OG8X6gaR7Mzp/view
- G12 eight directions before/after: https://drive.google.com/file/d/1QP9Bfr2kkTB_tySnBUJCPn4NDM_hzpw8/view
- G12 two-original-frame Hurt SE45 GIF: https://drive.google.com/file/d/1jtBLQC_1dduKFVRXzHjX-MBWdqZajwNe/view
- File: `PMD_G12_0001_0003_SE45_HURT_PATCH_20261104.zip` (2,625,602 bytes; 748 entries)
- SHA256: `53dc86b08a8b5d45ec498ffe24da7f2fb882914c17e68ac9f578bf2d1723c0cc`
- ZIP CRC PASS, internal G12 manifest 747/747, 737 retained original files proven byte-identical, all 354 source support + original atlas metadata unaffected.
- Independent pixel-alpha comparison: 0 changed alpha pixels across all source-selected 16 cells. Original native source dimensions, action list and frame timing unchanged.
- No PixelLab credits/AI image generation.

## Status and fail-closed next steps
- **Engineering structural PASS**. **0002 Hurt visual art PENDING**, including manual check for inorganic banding and plate continuity at native 1x. No false claims of full artwork approval.
- Godot/G11 XML bridge had historical checks, but **G12 itself has NOT run native PMD game or RPG Maker VX Tankentai**. Original engine integration still PENDING.
- Prioritize further **original native** action visual sampling of 0002/0003 for missing species motifs, orphan stone patches, or false facings; edit only demonstrably failed native cells, never replace original source with flat recolor or newly generated illustration.
- 15 source single-direction actions may not be labelled 45° without genuinely 45° source pixel work; retain them in quarantine.
- Third-party PMD sprite licensing/attribution must be confirmed before redistribution or commercial release.
