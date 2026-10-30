# Forest Symphony | Ground-only v2 Stage4 | R13–R15 | 2026-10-31

**Live checkpoint:** `GROUND_STAGE4_NATIVE_CANDIDATES_READY` / `GROUND_ART_FAIL` / `PAR_NOT_STARTED` / `FORMAL_SEAL_NO`.

## Work actually completed
- Preserved eight 544×416 v2 Masks, anchored door positions (144,208)/(400,208), sacred-tree root (272,304), crossing (272,240), west/east/south exits. No formal FS/K4 Map.rvdata, Scripts.rvdata, collisions, or passability changed.
- Replaced Stage3's fixed 64px repeating grass texture with deterministic overlap-error source patch quilting. Source is native 512×384 FS `A2_VSCliff.png`, SHA256 `1007b0245b9ca1235c2ad7b37474bd0b232fe75a1255f83c9fb4c9e5c5e1669b`.
- Actual RGB 544×416 outputs: `R13_QUILTED_NATIVE` and `R14_ORGANIC_CONTACT` using 187 acceptable native grass patch origins, 109 natural light-paver origins; `R15_FS_NATIVE_SOIL` replaces the visible paver road with original 16px terrain-dirt patterns sampled from A2 x192–256, y96–192 (142 acceptable origins). Output images, owner X/Y TIFF and 128×128 comparisons are inside the binary package.
- All RGB pixels in all three candidates are exactly original A2 pixels, not scaled and not extracted from full SCENE21/ground3 Master art. Per-pixel owner coordinates are shipped.

## Narrow quantitative improvement
- Stage3 R12: 178,821 nonroad output pixels, 4,107 distinct original source pixel addresses; reuse = **43.54**.
- Stage4 R15: 178,821 nonroad pixels, 6,750 distinct source addresses; reuse = **26.49**, approx **39.2% lower**. This is texture source diversity, NOT Art score.
- R15 mean RGB on semantic road mask approx (204.56,182.82,98.33), closer to original FS natural dirt than prior white-pink road (roughly 244,214,181).

## Verified independently
- Three native RGB PNGs, three X/Y pixel-owner pairs, unchanged source checksums and eight masks, six original road anchors and tree-root exclusion.
- Independent validator `verify_stage4.py`: **36/36 PASS**. Injected 1-pixel RGB flip and +16px source-owner X shift were both rejected.
- Cold unzip into separate directory and rerun `build_stage4.py`, `build_r15_softsoil.py`, `verify_stage4.py`: **35/35 source and generated PNG/TIFF SHA unchanged**, QA 36/36 again.
- R13 SHA256 `0e71de22d3265de3896057bdf2d291e689bb88ea1041f3a7abfdda4cccc17a18`.
- R14 SHA256 `a142656f97c90fed7a947290d08a7ce58aaa0f5f65fa4589ee7dc415986bc9a6`.
- R15 SHA256 `2ac21c4c5bb01afca9d729e01e9b1bdf2548100501669d2b019ad1d1a961f8c7`.

## Art Gate: FAIL (not HOLD alone)
- Visible 64px periodic grass stripes reduced; nevertheless the grass remains repetitive/too even at environmental scale.
- R14 original pavers are too uniformly hexagonal; R15 natural dirt is more appropriate but the full crossroads geometry remains excessively symmetric and mechanical, not FS `ground3` forest-village terrain.
- Low flora needs genuine natural clusters and character-scale validation. No Godot/VX render, PAR generation or formal Art Seal.

## Verified private binary backup
`FS_GROUND_V2_STAGE4_R13_R15_ART_HOLD_20261031.zip`: **3,281,164 bytes / 46 entries / CRC PASS**. SHA256 `d054902fb6aac240b7ad4c67416b7eb3f9dfd8a5525ba85259924f2aa86b7867`.
Uploaded and fetched back from Google Drive `FS_GameAsset_Backups`:
https://drive.google.com/file/d/1oC2BtbcJAWxLDXLtNz6e4VMvsfKs9ao6/view

The private binary contains all source art + full Python scripts, masks, owner TIFF, QA logs, comparisons. Public GitHub holds only this text record, not copyrighted/private images.

## NEXT_COMMAND
Keep existing Stage4 pixel-owner engine and regression tests. New work must focus on **R16 irregular Blueprint geometry**, not more fixed-cross roads: preserve the six hard anchors while replacing the symmetric crossing with a more natural curved route, path-width variability, FS-consistent grass/dirt intrusions and low flora. Re-run G0/G2/G3/G4 gates and real user-native-1x review. No PAR until `GROUND_ART_PASS` is explicitly reached.
