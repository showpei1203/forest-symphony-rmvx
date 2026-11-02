# FS A68 | Native original example 3-frame sprite edit (NO REGEN)
Date: 2026-11-03

## User-required strategy switch
A65-V3C not visually accepted. Stop regenerating human figures from imagined source bones. Only directly edit authentic, saved original example sprite frames, one 3-frame action at a time. A68 is a **small controlled source-based pixel-edit pilot**, not a claim that full body casting biomechanics are solved.

## Source and implementation
- Source from FS A65 original/reference bundle (`FS_A65_MAGI_SKILL_C2_ORIGINAL_FX_SEPARATE_GIF_QA_20261102.zip`), file `A65_FS_NATIVE_MAGI_SKILL_USE_REFERENCE_96x32.png`. 96x32 PNG: original 3 frames × native 32x32 (NOT the rejected 48x48 PixelLab V3 body).
- Three _1/_2/_3 frames are exact crops of source with only source-native pixel jacket/armor colors edited to dark teal / steel blue. 7 explicit leather color substitutions, y>=14 to keep face and hair original. No AI generation, interpolation, pose change, or body mirroring.
- F1's native shoulder magic flame is preserved. Original alpha masks byte-identical in every frame.
- Pixel edit counts frames 1/2/3: 103 / 94 / 102, head and pose otherwise unaffected.
- The original 96x32 source, 3 exact untouched source frames, 3 edited 32x32, combined 96x32 strip, 8x GIF, before/after compare, SHA256, QA JSON included.

## Outputs and verification
- Drive package: https://drive.google.com/file/d/1cqak4ibL-44D6Wzi_jsRCQfv1pS1mQca/view
- Drive source/edit comparison: https://drive.google.com/file/d/1tGVXbop83sRhhuj_K0mDS9GfOXjwdmaw/view
- Local: `/mnt/data/FS_A68_SOURCE_FIRST_3FRAME_DELIVERABLE.zip`
- ZIP SHA256: `4bf7c1748592fd781186a20401d5974cb1a09837723adedac4356b2dc465ede7`, 46737 bytes, 13 files, ZIP CRC PASS.
- F0/F1/F2 alpha mask exact: PASS. User art: PENDING. Native VX test: NOT TESTED.
- Only Magi Skill Use tested. Waiting, Critical Damage, Moving to Close Attack etc **not** silently modified or claimed complete.

## Related PMD source-first development
- A67 PMD0001 native source edits: `authority/FS_A67_SOURCE_NATIVE_SPRITE_EDIT_PMD0001_3FRAME_SEMANTICS_HANDOFF_20261103.md`.
- PMD's _1,_2,_3 convention is a review-key scheme; original PMD action source XML retains 3/6/11/10 (and other) frames unchanged.

## Next action
1. Evaluate original 32x32 source-pixel costume edit at real 1x and 8x.
2. Once the source-derived style is approved, apply same native source edits to remaining FS original example animations, strictly avoiding painted/AI-inferred joints.
3. Rebuild full sheet and test in native RMVX, not a concept-only screenshot.
