## Verified 1:1 native GPU art A/B closeups
- [R4 vs R5 1:1 tree-closeup comparison derived from the actual GPU frames](https://drive.google.com/file/d/1fg2KxReXDCmz6EMc2qX4HJCkGCXQv8Sc/view), owner-only, verified exists. Shows southwest trees, northeast conifer and northwest canopy from exact same-frame coordinates, FX off. This is an *illustrative contact sheet*, NOT one original native renderer screenshot.
- Visual finding: scale and silhouettes of the three conifers improve materially, but nearest-neighbor enlarged leaves have visibly blockier pixel clusters than native broadleaf/house art. Keep **ART HOLD**, refine the three conifer texture families before sealing.
- [Fully read-back verified private R5 native ZIP](https://drive.google.com/file/d/1249K95NDG_eJ4jvNOS50TI_h2VDhnrMR/view), 153,836,761 bytes, shared=false, owner only, CRC PASS and original R2/R3/R4/Ground SHA retained.

# Forest Symphony | A35 R5 Botanical Forest Native Handoff | 2026-11-15

## Baseline and protection
- Engine: **Godot 4.7.2 stable**; map-art workstream, NOT RPG Maker VX. Do not overwrite parallel A36C, Godot combat system, or historical A35 R2/R3/R4 scenes.
- Authoritative input: [private A35 R4 Native QA full ZIP](https://drive.google.com/file/d/1wdVrsfVcF47j5FtDYxm_pKPWZ9GWtpoz/view) SHA256 `51467d0a709bc7e6def518d79c25adbbd9de78c9123770e498e143e5ee446206`.
- New reversible scene: `res://scenes/a35_r5_botanical_forest_hd2d_scene.tscn`. Its native manifest is `res://data/a35_r5_botanical_forest_manifest.json`.
- Original immutable Ground SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`. R4 scene SHA256 `eb6b1b1214258cf9ef60b27f73dea2013cb54229f1d9093fa3cf27b45aa7ce83`. R2/R3 scene SHA also verified in final package.

## Actual build
- Added `tools/a35_r5_botanical_sprites.py`: eight species generated as complete coherent trees using the owner-only existing A36F high-quality original pixel art (cypress, willow, elder, fir, birch, oak, needle and maple).
- Added `tools/a35_r5_build.py`: rebuilds owner-only R5 PNG art, R5 Godot scene and R5 manifest. Exactly **32 tree owner instances** changed from R4, **155 other PAR unchanged**, **187 independent PAR owners total /175 tree instances**, all original object footpoints/collision geometries untouched.
- Three formerly tiny conifers corrected by **nearest-neighbor resizing entire original artwork** (not a no-resampling claim) plus 1-pixel needle texture restoration; five broadleaf species stay at native 1x source pixels. The 8x8 repeated foliage texture technique from R2 is not used.
- Actual painted alpha-bbox height from source QA: cypress **93→141 px**, fir **83→144 px**, needle **76→137 px**. New all-species: willow 146, elder 104, birch 115, oak 143, maple 106 px. Original 32×32 logical map grid remains unchanged.
- Keeps R3 optional day/dusk/night, lamp glow, atmospheric beam/dust/rain controls unchanged; no claim of final 3D light, depth-of-field or complete HDR shading.

## Actual Godot 4.7.2 QA
- On authorized Windows remote workstation, AMD Radeon RX 6700 XT, OpenGL 3.3 Compatibility.
- Cold Godot editor import PASS **Exit 0**.
- `tests/test_a35_r5_native.gd` source-SHA, 32 replacements, 155 untouched, 187 anchors/collision equivalence and unchanged Ground SHA: PASS **Exit 0**.
- `tests/test_a35_r5_navigation.gd` **8/8 physical navigation gates, 4/4 main paths, protected roads newly blocked=0**, PASS **Exit 0**.
- `tests/capture_a35_r5_native.gd` actual native day/dusk/night 1280×928 OpenGL GPU screenshots **3/3 PASS Exit 0**.
- `tests/capture_a35_r5_ab_actor_native.gd` R4 baseline/R5 candidate with atmosphere disabled and rear/front character checks, actual native GPU screenshots **4/4 PASS Exit 0**.
- `tools/a35_r5_native_roi_qa.py`: 98,693 tree-only changed pixels strictly inside the union of 32 replaced-tree bounding rectangles, **0 changed pixels outside**. R5 one actor placement behind foliage **0 visible pixels**, in front **576**; this is a tested position, not proof of every canopy point. All checks PASS.
- 7 original Godot GPU screenshots are in the owner-only final QA ZIP, not inferred from software composites.

## Deliverables, verified private Drive
- **[A35 R5 full native Godot QA ZIP](https://drive.google.com/file/d/1249K95NDG_eJ4jvNOS50TI_h2VDhnrMR/view)**, 304 files, 153,836,761 bytes, ZIP CRC PASS; SHA256 `cedd6e8162352f443eddca851a291ae08e97bc0aa71c32096fbde39e9eba1931`. Google Drive provider readback confirms actual file ID and owner-only shared=false.
- Source candidate: `FS_A35_R5_BOTANICAL_SOURCE_PRIVATE_20261115.zip`, owner-only Drive.
- Original 1x Godot screenshots, private and individually accessible: [DAY](https://drive.google.com/file/d/1oUIFtDqEEZHvZhj4xz7Giz1jmIrRI9aV/view), [DUSK](https://drive.google.com/file/d/1sGPbqLO-Qsmq7OF1yBxQEDan_D1H_5SO/view), [NIGHT](https://drive.google.com/file/d/159arCgw_2i0L_O8_gQgD3v0ExV6s-9HD/view).
- Direct FX-off [R4 baseline original native screenshot](https://drive.google.com/file/d/1c6R9-BV3rhlYglm3EErgSAbqJZDRMz-z/view) vs [R5 new botanical native screenshot](https://drive.google.com/file/d/1v5eqeB7pgtYz1nd_5I3uqP-8y1csMMGs/view).
- Actual Godot native [behind](https://drive.google.com/file/d/1uNpLGrUKdOXE18bWNnOeMJeGAGMIqCpY/view)/[front](https://drive.google.com/file/d/1UNDu1wZ_B-lUHB3WeF9AaUmQAERiH5NT/view) actor frames and [pixel ROI JSON](https://drive.google.com/file/d/1kdNCvSx1PevG8g3Nv3JwVUKbPKoESlhQ/view).
- Owner-only Drive workspace: https://drive.google.com/drive/folders/1JhrZiJ8xdiwgsdCPq0MzR3sQFOJu-6dt . No private PNGs or original 154MB ZIP on public GitHub.

## Failure Log and acceptance
- First experimental R5 composite crowns generated ghost tree blobs / clipped alpha; these were **rejected**, not committed to production.
- The corrected R5 candidate uses whole painted tree images. First native A/B baseline filename accidentally said R3 when the actual source was R4; corrected to R4 and reran GPU 4/4 before QA/seal.
- In original R5 native 1x screenshot, resized needle/fir/cypress still show comparatively coarse enlarged pixel blocks versus some original HD-2D foliage. Botanical identities are more distinct and forest scale improved, but **ART HOLD**, not formal art seal.
- Physical light occluder shadows and true 3D depth-of-field not implemented. R5 character behind occlusion validated at one coordinate only.

**Status: ENGINE PASS · NAV PASS · REAL GPU PASS · TREE ROI PASS · ART HOLD.**

## Next stage (do not reset to R3 or A33)
1. R5 R2 art refinement: conifer leaves 1px high-frequency native detail or new directly painted silhouettes; avoid simply stretching low-resolution art. Preserve stable 8 species bounding box limits, root anchors and collisions.
2. Recheck A/B screenshot at 1x, total 32 replacements, real navigation 8/8 and 4/4, actor occlusion, source hashes. Do not declare ART PASS solely on numeric scores.
3. After visual tree approval, expand Ground3 grasses/flowers/organic road borders **without degrading current Ground**; separate candidate, QA and rollback.
4. Later HD-2D workstream: explicit per-tree LightOccluder2D / ground shadows, controlled bloom/DOF, seasons/weather, test before and after.
5. Every stage: code on GitHub, private binary art/complete ZIP in owner-only Drive, full Failure Log and CURRENT_HANDOFF. No speculative concept renders as engineering evidence.
