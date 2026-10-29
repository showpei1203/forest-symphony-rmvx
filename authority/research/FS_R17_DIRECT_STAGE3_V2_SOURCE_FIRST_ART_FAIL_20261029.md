# FS R17 Direct Stage3 V2｜Source-first Ground/PAR technical candidate, Art FAIL
Date: 2026-10-29 (Asia/Taipei)
Issue: SHO-34
Status: **TECH CANDIDATE / VISUAL ART FAIL / FORMAL SEAL NO**.

## Action taken
- Executed an actual two-image production script in Windows Python 3.11 + Pillow + NumPy.
- Authored a new **continuous Ground-only image** in native 544x416 coordinates, from multiscale terrain textures, an independently drawn curved stone path, ground-level flora and three tree contact pieces. **No completed Master was read, inpainted, or used as Ground**.
- Authored native **transparent RGBA PAR** separately on the same 544x416 canvas: 1 house, 3 trees, 2 lamps, 2 fence segments, 1 sign. Trees' foot contacts and raised canopy/trunk art were authored separately using shared source coordinates. Other objects use already-existing independent R14 source sprites, **not R17 Stage2 mask crops**.
- First candidate V1: structural checks passed but visual QA rejected excessive scattered texture, square tree-foot artifacts and mismatched market style.
- Corrected V2: reduced texture noise, removed market, replaced old square-contact tree sprites with three separately authored tree species, kept Ground/PAR 1x independent and unscaled. This is a better structural baseline, but **still not close enough to ground3/R17 Stage2 painterly detail**.
- Checked both exports with fail-closed `tools/r17_direct_ground_par_source_validator.py`, output `TECH_CANDIDATE_ONLY_NO_ART_PASS` / exit code 0. This checks the declared provenance, SHA hashes, image dimensions and transparency; it does **not** prove all visual semantics or user art acceptance.

## V2 measured output
| Field | Value |
|---|---|
| GROUND.png | 544x416 RGB, 222,654 bytes |
| GROUND SHA256 | `afe788742140344bcefe3c3f03dd28d7c9e80d86465ea31799846a259314b875` |
| PAR.png | 544x416 RGBA, 60,054 bytes |
| PAR SHA256 | `e9b48d895bfffc6b9818a30dbf20b3a4a103528dd415db105325e2a52b74ee8b` |
| PAR alpha=0 | 194,111 px |
| PAR alpha>0 | 32,193 px |
| Ground 32px patch uniqueness | 192/192 observed sampling positions (not an art-quality score) |
| ZIP | 636,298 bytes; 22 files; CRC PASS |
| ZIP SHA256 | `75c5c315426649c9ae8a88f9f242178bacee31022aa7711ab2cd16ae0fb4afbc` |
| Source provenance | `independent_direct_layers` manifest, generator & source sprites retained |
| GROUND ART | FAIL, compared with user reference |
| PAR ART | FAIL, artistic finish/style consistency |
| PAIR TECH | candidate, shared size/origin and verified Alpha |
| Final Seal | NO |

## Source and delivery
- Executable generator: [build_r17_stage3_source_first_v2.py](../../tools/r17_direct_stage3/build_r17_stage3_source_first_v2.py)
- Google Drive private [Stage3 V2 folder](https://drive.google.com/drive/folders/1DDs8NPle60OAYFTUs-kgRwZdBOUrMTNJ)
- [GROUND.png](https://drive.google.com/file/d/1aCbJVpmx_gQO2e9cm3qO75arzX8MO2mp/view)
- [PAR.png](https://drive.google.com/file/d/13LafoTIDMdLB6X6idFvF_qAoVG_7Co72/view)
- [QA Composite, NOT output Ground](https://drive.google.com/file/d/1LyyCKIFY5uiv3YmSW_2LEWe8M72b_MXn/view)
- [Private full reproducibility ZIP](https://drive.google.com/file/d/1TzoHecVGEj6iKeb2hRvFJ3DhV0FcNPM4/view)
- [Human visual gate](https://drive.google.com/file/d/13g4fwwou8ghnTxVdJ0IGi04sBeZ1WqCN/view)
- [Machine technical gate](https://drive.google.com/file/d/1v3V7M6TjIHor-5BO4pOvv9IoJJIg20Xj/view)

E: authoritative local candidate and G: Drive sync folder show **byte-identical SHA256 for Ground, PAR and ZIP**. Google Drive cloud files were **re-downloaded** and SHA-256 hashed independently in the working container: Ground=afe788742140344bcefe3c3f03dd28d7c9e80d86465ea31799846a259314b875, PAR=e9b48d895bfffc6b9818a30dbf20b3a4a103528dd415db105325e2a52b74ee8b, ZIP=75c5c315426649c9ae8a88f9f242178bacee31022aa7711ab2cd16ae0fb4afbc. All match E/G originals. ZIP CRC check returned no errors and contained 22 members. **Cloud content integrity verified; this does NOT elevate visual Art FAIL or formal Seal.** All assets remain under private Drive; GitHub contains source, status, documents, hashes, not private FS PNGs.

## Findings requiring further work
1. **Quality gap:** Ground is recognizably procedural, no natural cobblestone/grass material richness comparable to the user-approved reference; don't increase random grass density as a substitute for coherent art.
2. **Mixed artistic finish:** Existing high-pixel-detail house versus newly authored geometric trees look inconsistent.
3. Source-first technical success is NOT final art success; the next valid iteration requires *new higher-quality independently authored materials*, not a return to R17 Stage2 Master-first segmentation.
4. Preserve 1x, shared world coordinates, independent source artifacts, human Art F; no collision compiler, VX Map.rvdata/Scripts.rvdata modifications, or unnecessary actor tests.

Authority priority: `FS_R17_DIRECT_GROUND_PAR_AUTHORITY_20261029.md` still governs this candidate. R14 and Stage2 historical successes/failures unchanged.
