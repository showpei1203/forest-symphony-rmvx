# Forest Symphony | T-C D13 | FS_04_VILLAGE 灰鑄工坊城：首次獨立透明完整 PAR 美術候選

**2026-11-22 (Asia/Taipei)** | Godot **4.7.2 NATIVE NOT_RUN** | formal ART **HOLD, 0/12**

## 1. What actually changed

This is **not only a hypothetical chroma converter**. A fresh independent volcano-town **ALL non-ground** transparent RGBA image was actually generated, containing forge buildings, smithy/tavern, smelting domes/furnaces, chimneys, bridges/railings, basalt cliff columns, cranes, ore carts, lamps, banners and workshop objects in ONE coherent scene. The original locked D11 Ground was NOT regenerated or reverse-extracted and not modified. The town's centered circular plaza remains mostly open.

**Source PAR** (new image generation): `1474 x 1067 RGBA`, SHA256 `b6d529b66d9ec71c87991e7e63abeb85f9d145e056e7bf675cd8ac0de3678f72`. Actual alpha histogram:
- alpha=0: **715393**
- alpha=1..8: **121578** (halo/soft-edge contamination)
- alpha=9..239: **93476**
- alpha=240..254: **641638**
- alpha=255: **673**

The original PNG really has zero-alpha background and object pixels; unlike D11's six invalid opaque full-Master attempts. It is a stand-alone non-ground foreground, not a Master with road/lava ground. It was generated directly as transparent RGBA and does **not** need the D12 chroma bridge. D12 deterministic chroma workflow remains available only as fallback.

**Locked D11 Ground:** unchanged `1280×928 RGB`, SHA256 `ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d`. Source Drive https://drive.google.com/file/d/1O8lKij4P8JgxczP2Q1Ykt-RKnhyk56RL/view

## 2. True technical processing, and honest limits

The generator did NOT return native world size. Original `1474x1067` cannot be declared formal 40x29 @32px. Two **distinct** preview candidates produced from one original image:
- **Native 1x center crop** `(97,69,1377,997)` to 1280×928 (no resampling); true zero alpha retained and PIL alpha composition completed, but it cuts visible workshop/edge props. Crop SHA256 `05ef52636c3df0ced5f600fb6075a991164d6e5fab671ead95f7b33e03f68a62`. Edge hits alpha≥225 top=462, bottom=398, left=468, right=221: **ART HOLD**.
- **Full composition LANCZOS resample** `1474×1067 -> 1280×928`, preserving major objects and source composition, PAR SHA256 `6ec03d35f23faa083d9df84cb7da78fa72bc0c264e0eec8b203b4c0eaee0e445`. Raw resampled alpha0=**541780**, alpha1..8=**90118**, alpha240..254=**484811**, alpha255=**1275**. Static PIL compositing visually promising, streets/plaza visible, bridges near lava. **NOT 1x NATIVE**; source scale/color edge style and semantically exact world XY remain unverified. It is a **technical art candidate**, not a passed production artifact.
- Separate optional alpha-clean version only: set ≤8→0 and ≥240→255, preserving raw original/source and unchanged other pixels. Clean alpha0=**631898**, alpha255=**486086**; its RGB/objects are not retouched.
- Static Preview is ONLY QA, not replacement Ground or independent authoring PAR.

**No Godot native rendering on this actual new image was run.** This environment has no verified Godot 4.7.2 binary for this source, and the native test has not been executed. No collision, actor occlusion, narrative/event work.

## 3. Private owner-only Google Drive source, QA and READBACK

- [D13 ZIP full original, 40x29 Ground, raw PAR, native crop, resampled and cleaned PAR, previews, checker preview, visual 4-up, QA JSON, Failure Log](https://drive.google.com/file/d/18IkobPFjRE4XqRFXZBLpX5-aqbz8H8IY/view): **22,036,770 bytes**, 12 entries, ZIP CRC PASS, SHA256 `1660e855135eabb4ce3a5153e53aa98c07895290448b6d464363ef6325286e49`.
- [Raw independently generated RGBA PAR 1474x1067](https://drive.google.com/file/d/1NuEbPwE4nJXZ1r6KLCaChxyAh4Pr58P-/view)
- [PAR resampled 1280x928 TECH only](https://drive.google.com/file/d/1AFUde89banf-Le7xRRrTVYArBoycQlIt/view)
- [Cleaned Alpha variant TECH only](https://drive.google.com/file/d/1X58oVvmX1bt6f3MNGUvXb3hRBxK0SvtJ/view)
- [Static composite 1280x928](https://drive.google.com/file/d/15VgqAHsx_CNVMDdfc-TABZsx5tnfR2Wp/view)
- [Original and derived source full QA JSON](https://drive.google.com/file/d/1bhT8xJhhfloMTLQTOf2E8WFyliHZ07Tu/view)
- [Four-way visual contact](https://drive.google.com/file/d/1tzAd7rDktyfCx-HXo7jg72s_9dBtcXFu/view)

Uploaded source, ZIP, preview, PAR variants and QA JSON verified via Google Drive metadata. `shared=false`, `permissions=[owner]`; ZIP file size matched upload. Private images/ZIP are stored in Drive, NOT added to public GitHub.

## 4. Verified / NOT VERIFIED

| D13 gate | Current |
|---|---|
| Independently generated non-ground PAR original exists | **PASS / source real** |
| True fully transparent alpha background in PAR | **PASS / 715,393 alpha0 source pixels** |
| Separate locked D11 Ground preserved | **PASS / SHA verified** |
| Technically possible static GROUND + PAR alpha compositing | **PASS / Python PIL** |
| Native 1280x928 independent PAR source without resampling/cropped props | **FAIL / 1474x1067 generated** |
| Proper Ground XY visual alignment and walkable routes | **HOLD / preliminary visual only** |
| Source alpha purity/opaque silhouettes | **HOLD / alpha fringes** |
| All non-ground objects visually art-certified | **HOLD / needs human review** |
| Godot 4.7.2 native QA | **NOT_RUN** |
| Formal ART PASS | **0/12, HOLD** |

## 5. Failure Log and next macro task

**BLOCKERS** (do not micro-fix trees or occlusion):
1. Image model output dimensions `1474×1067` vs true native 1280x928. Crop cut source props, resample keeps completeness but breaks accepted native 1x source contract. A native-size image-edit/scene generator or **full-object 1x origin/footprint-aware assembly** is needed, not an invented native-pass claim.
2. Source alpha fringes. Keep original and optional clean branch separate; inspect real preview for apparent halos.
3. Static QA cannot certify every object actually anchors to Ground world coordinates. Buildings and lava bridges should be approved at 1x against locked roads and distinct forge lots.
4. Source original was separately generated from textual scene/spatial guidance, not direct pixel-coordinate conditioning on exact D11 Ground, so **exact same-source XY is not proven**.

**NEXT FULL UNIT**: obtain a properly native aligned 1280×928 transparent **complete** non-ground scene with no clipped props; use D13 as strong composition/style reference and locked D11 Ground as world reference. Do not regenerate Ground. Inspect image, same-size 1× alpha composite, Godot 4.7.2 native then Human ART Gate. After actual acceptance continue `FS_04_MAZE` and 05/06 terrain pairs. Keep per-stage private Drive raw+QA, GitHub Handoff, and Linear SHO-39, total formal ART remains 0/12.
