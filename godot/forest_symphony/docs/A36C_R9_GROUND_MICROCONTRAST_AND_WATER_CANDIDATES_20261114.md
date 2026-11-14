# A36C R9 | Real Ground visual candidates + independent R8 water, additive Godot scenes

**Date:** 2026-11-14. **Status:** CANDIDATE / ART HOLD / GODOT NATIVE NOT_RUN / COLLISION HOLD. **Policy:** ACTIVE MASTER v1.3 Ground-first.

## Real produced work
- Source is authenticated Drive A36B R2 original 2560x1856 Ground SHA `ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911` unchanged.
- Produced TWO full-resolution reversible Ground-only pixel-aligned local microcontrast variants. Soft SHA `e446609aa7910466ed00cdbd275e8c33826b19353674c3cbb341289bb4f44bb9`, Crisp SHA `9cfa36f4d3f089bbb890d926e07ef6030b3e19b8bd8674af109b0d912ab48874`. No resizing, max absolute channel delta soft 21, mean abs delta 4.412, original retained. **This is NOT a newly hand-drawn native 32px Ground; original resampling flaw remains and must not be falsely called fixed.**
- Produced three real Godot scene variants with 326 original independent PAR object owners each: soft, crisp, and soft+R8 four-frame independent river animation. Ground source unchanged; original A36B scene untouched.
- 1x river Ground comparison sheet (original/soft/crisp), complete 1x soft Ground, QA source checks, and self-contained additive 17-member ZIP.
- [Owner-only Drive R9 Godot scene and private PNG package](https://drive.google.com/file/d/1hYB7gLADEXsnkji7rn6Is84DI5OLcxPl/view), ZIP SHA256 `8808c161827d006fb15e3c82d597185a4a8f37f601ddb20471193a2986219c1a`. Keep private PNG out of public repo.

## QA / Failure Log
- Source SHA / unchanged A36B scene: PASS. PNG pixel dimensions and exact alignment: PASS. 326 owner instances each: PASS. ZIP CRC: PASS. R8 4 distinct water frames: source check PASS.
- Godot 4.7.2 native parse/render and play: **NOT_RUN**; 1x user art: **HOLD**; physical river collision and navigation: **HOLD**.
- Current candidate is only detail sharpening. It may introduce oversharpening or pixel-scale mismatch; compare 1x before selecting. Next primary art deliverable must be a genuinely reauthored native-resolution Ground riverbank/roads, not additional tree swaps, coordinates or sharpen filters.

## Cloud and integration
- Owner-only Drive ZIP is additive to the verified A36B R2 private Godot project. Do not overwrite original baseline or sealed VX. GitHub PR #16 stores this handoff and public scripts/scenes only; original artwork stays private.
