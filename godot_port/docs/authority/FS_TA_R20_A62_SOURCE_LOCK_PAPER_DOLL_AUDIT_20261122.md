# FS T-A R20｜A62 全身來源保真與紙娃娃真相稽核

> R21 2026-11-23 HISTORICAL CORRECTION: The R20 source A62_SOURCE_F0_48.png is PRE-provider and is NOT the approved 64px character baseline. Approved A62 64px F0 = A62_PROVIDER_RAW_F0.png (48px) padded by eight transparent pixels, RGBA exact, original source differs by 47 RGBA pixels. The R20 7-mask image parity test remains valid for its PRE-provider input only. For current T-A art reference use FS_TA_R21_A62_CORRECT_F0_SOURCE_CONTRACT_20261123.md, preserving the original R20 audit as a separate historical record.

2026-11-22; replaces R19 pending and source-only contract where results differ.
STATE = **VISIBLE_PIXEL_SOURCE_PARITY_PASS; COMPLETE_LPC_PAPER_DOLL_SOURCE_BLOCKED; ART_NOT_APPROVED**.

## Verified original and why R19 cannot continue
Owner-private [A62 full source archive](https://drive.google.com/file/d/168OaoQ2XJPgfUFldyIwPrWtvK4VjB4FV/view) contains original `A62_SOURCE_F0_48.png`, source SHA256 `0ca4ce9f55a718882b801114602c14e3d288ea4371806fe8afcb3d9b64510c37`, 48×48, 575 visible pixels, complete original belly/clothing/boots. Corresponding `A62_PROVIDER_RAW_F0.png` is **not byte/pixel identical** (47 RGBA pixels changed). 64×64 source reference previously used in R19 does **not** match any 48×48 padded crop of this original source (verified on owner PC). Thus 48/64/32px sources are NOT interchangeable.

LPC original downloaded male diagonal WALK .ora contains ONLY three actual source layers `torso`, `arms`, `head`; its original matching outfit/near-far sleeves/pants/boots 45° ATTACK parts have NOT been verified. General Universal LPC generator torso/arms/legs/feet folders do NOT prove same 45° action compatibility. Tankentai independent weapon/equipment overlay and LPC clothing layers are separate layer contracts.

## Actual newly produced R20 (not attack)
Produced 7 layer image assets by **copying exclusively original A62 F0 RGBA pixels** and partitioning visible ownership between head/hair, far sleeve, near sleeve, original torso/abdomen, belt/waist, pants and boots. A correct 48×48 OpenRaster ORA file, original F0, exact recomposite F0, each visible ownership mask, 1× and 6× contact sheet, machine manifest, source builder and validator and private QA ZIP are preserved.

**Proof:** exactly 575 source alpha pixels, each owned by EXACTLY ONE of 7 layers; 48×48 recomposed full F0 RGBA = source byte-for-byte (pixel delta 0); source SHA fixed. ORA zip stack parse, layer names, alpha ownership and zero-new-color checks PASS. Negative tests: source RGB pixel mutation rejected; falsely marking complete modular LPC source is rejected.

**Crucial limitation:** these seven work layers are extracted from a single FLAT source sprite; original hidden pixel/underpaint and genuine separate LPC clothes modules are missing. It is an exact-pixel AUTHORING decomposition, **NOT TRUE SOURCE NATIVE PAPER DOLL**. No R20 attack poses, no 12-frame atlas, no real animation, no Godot, no ART PASS. R16-R19 remain ART_REJECTED, R20 source/body baseline only.

Private [R20 Google Drive folder](https://drive.google.com/drive/folders/1xUplinX5tyL2CTRG7am_BZrpDgoFUoe-) contains [full private 18-item QA ZIP](https://drive.google.com/file/d/14R0rvUeds1CxQVxoAj7tluCRTG8Mht6s/view) SHA256 `3701ef97a82c54cab7ffee5942c0b503649c93b93a7a315a2940e4d352991704` / 31,470 bytes / CRC PASS. Source-only metadata/code on GitHub; third-party or private PNG stays in private Drive.

## Correct next source gate
Locate source-matched body/torso outfit/far+near sleeves/pants/boots for 45° attack, including underpaint, actual path, license, SHA, same pose and orientation. If unavailable, propose A62 full-F0 master-based high-quality complete artist repaint (not same as LPC modular) as an explicitly labeled alternate, not pretending it is sourced from missing images. Never reconstruct stomach via polygon palette fill. Stage art at native 1×, owner approval before inbetweens and Godot. No changes to A52/A62 original, T-B/T-C or main.

User's priority is natural beautiful art, not numerical CI/engineering completion.
