# CURRENT | A35 R4 native organic foliage candidate | 2026-11-15

- **ENGINE PASS / NAV PASS / ART HOLD.** This workstream is only Godot 4.7.2 map art. Main A35 R2/R3 and A36C forest separate and immutable.
- Private owner-only complete R4 native ZIP: `FS_A35_R4_ORGANIC_NATIVE_QA_PRIVATE_20261115.zip` (269 members, 131,309,501 bytes, CRC PASS, SHA256 `51467d0a709bc7e6def518d79c25adbbd9de78c9123770e498e143e5ee446206`). Find in Drive FS_AI_ASSET_FACTORY_Restricted_Binaries and verify metadata ID.
- 8 one-piece source-derived species candidates, 32 grove instances replaced, 155 other PAR preserved, 187 total objects/175 trees, original Ground SHA stable. Not genuinely new painted biology, so ART HOLD.
- Real native Godot 4.7.2: source PASS, NAV 8/8 and paths 4/4 PASS; 7 GPU images 1280x928 PASS; 143,456 changed tree pixels inside source union ROI, **0 outside**, behind/front actor 184/576 = 31.94% visible for partial evergreen foliage.
- [A35 R4 Formal Handoff](docs/A35_R4_NATIVE_HANDOFF_20261115.md) | [A35 R4 Failure Log](docs/A35_R4_FAILURE_LOG_20261115.md) | [reproducible builder](tools/a35_r4_organic_build.py).
- Next A35 R5: genuinely distinct 8 botanical pixel sprites, 1:1 native visual quality, keep anchors/physics, real screenshots + 8/8 NAV + ROI; only then Ground3 and per-tree HDR lighting/occlusion. Do not reset to A33, do not publish private PNGs.
 
---

# A35 R3 HD-2D | Godot native PASS / ART HOLD | 2026-11-15

- Official Godot 4.7.2 imported the candidate and passed source scene QA **Exit 0** on real AMD RX 6700 XT hardware. Original 187 PAR source/footpoints and Ground SHA immutable.
- Original 1280x928 GPU frames captured **3/3** for DAY, DUSK, NIGHT with Godot OpenGL compatibility renderer, **Exit 0**. Native pixel differences DAY vs DUSK 1,185,598; DAY vs NIGHT 1,187,405.
- **Owner-only sealed native release** `FS_A35_R3_HD2D_NATIVE_QA_PRIVATE_20261115.zip`, **236 members / 108,931,403 bytes / ZIP CRC PASS / SHA256 16a707417d65dc41eeb12919a52b560af26a9860d888f560f740e785c018797c** on mounted Google Drive folder `FS_AI_ASSET_FACTORY_Restricted_Binaries`. Before linking the individual file, wait for Drive metadata sync.
- [Formal GitHub Native Handoff](docs/A35_R3_HD2D_NATIVE_HANDOFF_20261115.md) | [Failure Log](docs/A35_R3_HD2D_FAILURE_LOG_20261115.md).
- Native imported/scene/GPU PASS does **NOT** mean ART PASS. Original R2 repeated-tree patterns unresolved; no physical light occluders, correct leaf-depth or true DOF. R3 full physics navigation not rerun. **ART HOLD**.
- Proceed with improved foliage native sprites, anchors/collision untouched, then 1x visual QA, original nav & occlusion and source ROI regression before Ground3.

---

# A35 R3 | HD-2D real-time layered candidate | 2026-11-15

- **Map-art workstream only.** Godot 4.7.2. The latest user-authorized base is A35 R2 (187 independent PAR / 175 trees / 8 new R2 species), not obsolete A33/R1, and not parallel A36C.
- New independent branch: `feat/fs-a35-r3-hd2d-20261115`.
- New source: `scripts/a35_r3_hd2d_fx.gd` and `tools/a35_r3_hd2d_build.py`. Builder takes owner-only R2 ZIP and adds `scenes/a35_r3_hd2d_layered_scene.tscn`, native verification, three phase native GPU capture script. Does **not** replace any PAR image or Ground and does **not** overwrite R2 scene.
- Private produced package filename: `FS_A35_R3_HD2D_LAYERED_PRIVATE_20261115.zip`. Source/package integrity PASS (229 ZIP entries, CRC PASS, original Ground SHA 3348d4..., original R2 scene immutable, source-only pipeline).
- **Native Godot PASS**: editor import, source QA 187 unchanged PAR, 3/3 GPU day/dusk/night images, all exit 0. ART HOLD; see formal R3 Handoff.
- ART HOLD remains: R2 crown patch repetition is not solved by adding effects; organic-canopy art is a **separate candidate**, not sealed.
- Runtime keys: N cycle daylight/dusk/night, V toggle rain, L toggle atmosphere, G existing editor grid. Light occluder shadows off pending authoring. No finished postprocessing/DOF claims.
- Original archive kept separately; only owner-only Drive for binaries and captures. GitHub only source/Handoff/failure logs.
- Next: native import/QA/capture complete; inspect 1x visuals and replace repetitive tree crowns before Ground3. Then integrate refined independent R3 tree species with unchanged anchors/collision and rerun navigation/front-back ROI tests.

---

> **2026-11-15 A35 R2 village forest native candidate (separate from A36C large forest):** Eight new native-pixel full-RGBA tree silhouettes, 32 R1 border-tree replacements, 187 PAR / 175 trees unchanged, sealed Ground unchanged. [Formal Handoff](docs/A35_R2_NATIVE_HANDOFF_20261115.md) / [Failure Log](docs/A35_R2_FAILURE_LOG_20261115.md) / [source builder](tools/a35_r2_build_new_species.py). Owner-only [complete 222-member ZIP including 4 authentic Godot GPU screenshots](https://drive.google.com/file/d/16HaP7PUWKbP9SPvsYtdmT6dULJtr4dIy/view) (99,577,322 bytes SHA256 `cc97180661e1ad1e3fa7c47f8aed239c4ef75e94d02edddea9cdb46c6b6f5be8`, ZIP CRC PASS, Drive readback SHA PASS, shared=false); [private native screenshot folder](https://drive.google.com/drive/folders/1uaEPlL5FAfNJki_j73AMRVNKT2FR22r6). Godot 4.7.2 native import/source/collision PASS, physical NAV 8/8 with 4/4 routes, GPU 1x ROI diff inside=149047 outside=0, depth behind=0/front=576. **ENGINE/NAV/ROI PASS; ART HOLD** due to repeated canopy patches and smooth artificial contours. Five old redundant QA screenshots omitted from new complete ZIP to stay below uploader size limit (older sealed Drive archives retain them). Does not overwrite separate A36C source-of-truth.

> **2026-11-15 A35 R1 ELF VILLAGE FOREST NATIVE CHECKPOINT (separate from A36C 2560×1856 workline):** Real Godot 4.7.2 GPU-rendered additive 1280×928 village scene `scenes/a35_r1_forest_groves_scene.tscn`; +41 completely independent tree PAR owners in 8 grove continuations, 146→187 total owners, existing A34 houses/objects and A32 Ground byte-exact. Native real-source 1601/1601 PASS; physical navigation 8/8, 4/4 routes PASS (0 newly blocked protected road cells); native A34/A35 ROI 95,610 changed inside added tree regions, 0 outside; actor tree behind/front 0/554. **ENGINE/NAV PASS, ART HOLD**: 15 existing tree families reused, fresh true 1x silhouettes still needed. [Owner-only full 195-file native ZIP](https://drive.google.com/file/d/1sr4ewzX-U_VBVLGrvbInaejhZX-Dd6GE/view), [private native images, QA and failure log](https://drive.google.com/drive/folders/1pfTUIXgOfVlV_12_G8SD8q_udNJM9Vjv), [GitHub official A35 handoff](docs/A35_R1_NATIVE_HANDOFF_20261115.md). **Do not overwrite A36C large forest or sealed A33/A34 scenes; PR #16 code-only, no private art.**

> **2026-11-14 A36C R10 source-derived water collision candidate:** From original A36B private full project, created additive 326-PAR Godot scene, source-based 148 water tile runtime StaticBody2D shapes (default collision OFF), 1x water diagnostic, static BFS from player tile (41,32) reaching 4488 of 4492 candidate walkable tiles; 4 isolated tiles remain. [Owner-only full 58.8MB ZIP](https://drive.google.com/file/d/1rZtAEdy2-vxfQSkr5xl6qqGTX2m7DS8i/view), SHA256 `61cfe0470ad63ec68578752b8bd311e3bc3e2d50f98426b69e042ec3017d8b63`; [source script](scripts/a36c_r10_world.gd), [handoff](docs/A36C_R10_NAVIGATION_CANDIDATE_HANDOFF_20261114.md). **Godot native NOT_RUN, river bridge/collision HOLD, art HOLD.** This is a navigation candidate, NOT native-pixel Ground art progress. Original A36B source untouched.

> **2026-11-14 A36C R9 Ground-only A/B candidate:** Two actual full 2560x1856 original-aligned reversible microcontrast Ground PNGs (soft/crisp), three additive Godot scene variants preserving 326 independent PAR owners, and soft+R8 four-frame river overlay. [Private 17-file ZIP](https://drive.google.com/file/d/1hYB7gLADEXsnkji7rn6Is84DI5OLcxPl/view) SHA `8808c161827d006fb15e3c82d597185a4a8f37f601ddb20471193a2986219c1a`; [QA/Failure Log](docs/A36C_R9_GROUND_MICROCONTRAST_AND_WATER_CANDIDATES_20261114.md). Source Ground unchanged. **Not a native-resolution repaint; art HOLD, Godot native NOT_RUN, collision HOLD**. Priority remains genuinely reauthor Ground-only riverbanks and roads, then Godot native 1x art test. No main/VX overwrite.

> **2026-11-14 A36C R8 independent WATER animation candidate:** Downloaded original SHA-verified A36B R2 private project and generated 4 actual 2560x1856 transparent water glint frames + water region mask + copy of 326-object scene with AnimatedSprite2D 5fps. [Private ZIP on Drive](https://drive.google.com/file/d/1XGVDveCJlbWgYDUF6xR6mw6adA4PyiB6/view); [public script](scripts/a36c_r8_world.gd); [QA/Failure Log](docs/A36C_R8_WATER_ANIMATION_HANDOFF_20261114.md). Original Ground SHA unchanged. **Native Godot NOT_RUN, water/collision/art HOLD**. Primary next priority remains Ground-only native pixel density and riverbank, NOT another tree shuffle. Do not overwrite A36B baseline.

> **2026-11-14 A36C R6 actual scene:** [R6 handoff](docs/A36C_R6_GROVES_HANDOFF_20261114.md), `res://scenes/a36c_r6_forest_groves_80x58.tscn`, manifest `data/a36c_r6_forest_groves_manifest.json`. R6 shifted 39 tree positions, 68 cumulative movement events since R4, 310 trees and 326 independent PAR owners unchanged. Live source comparison PASS; native Godot R6 render, road/river collision, art approval NOT RUN. **ART/COLLISION HOLD.** Do not mistake scene file edits for visually accepted map. No VX.

> **2026-11-14 A36C R5 REAL GEOMETRY UPDATE:** [R5 handoff](docs/A36C_R5_FOREST_GEOMETRY_HANDOFF_20261114.md), actual new scene `res://scenes/a36c_r5_natural_forest_clusters_80x58.tscn`, real manifest `data/a36c_r5_natural_forest_clusters_manifest.json`. R4 1 + R5 28 = 29 actual tree footpoints repositioned toward nearby forest clusters; six existing species, 310 trees/326 PAR owners, immutable A36B baseline. CI source contract added but not confirmed run. **NATIVE GODOT R5 1x NOT RUN, PATH/COLLISION HOLD, ART HOLD, WATER NOT IMPLEMENTED, NO SEAL.** Next: native Godot private A/B screenshot and path validation before promoting any movement, then add genuinely new full RGBA silhouettes.

> **2026-11-14 A36C R3 continuation:** [A36C R2 actual scene handoff](docs/A36C_R2_GODOT_SCENE_HANDOFF_20261114.md). New scene `res://scenes/a36c_r2_ecology_variant_80x58.tscn` with 40 same-footprint source substitutions (310 trees, 326 owners), immutable A36B R2 preserved. CI regression step added to `.github/workflows/fs-godot-a36b-tree-ecology.yml` at commit `5fc4224f`. **No native A36C Godot render yet, no new silhouette assets; ART/COLLISION HOLD.** Workflow runs queried for commit and none returned, so CI PASS must not be claimed. Continue by verifying CI, creating independent 8-12 silhouettes and owner-only native 1x render. This note supersedes the earlier "Stop new art work at A36B R2" instruction for new variants; do not modify sealed A36B.

> **2026-11-14 CHECKPOINT / USER REQUESTED HANDOFF:** [A36B R2 formal checkpoint](docs/FS_A36B_R2_CHECKPOINT_HANDOFF_20261114.md) and [owner-only Drive mirror](https://drive.google.com/file/d/1zZNfqOIHrfYuhBzn4PBtfN-MMWNcOnd0/view). **Stop new art work at A36B R2**. Read the checkpoint for source SHA, all seven source-only CI, native real-art proof, private ZIP, failure log, and A36C safe start. ART/COLLISION/WATER HOLD, no formal seal. Godot PR #16 Draft/main untouched.
# Forest Symphony｜Godot Ground/PAR Art CURRENT_HANDOFF｜A36B R2｜2026-11-14

This conversation creates **Ground-only art, fully independent PAR, SHADOW/LIGHT/WATER visuals, biome art and large maps only**. **NPC/events/story/combat are owned by another conversation.** Never replace with flattened Master crop.

## Source of truth
- Master policy: FS Active Master v1.3 Ground-first + complete independent standalone PAR, Godot 4.7.2; private art owner-only Drive, source-only GitHub Draft PR #16.
- **Current actual scene:** `res://scenes/a36b_large_forest_tree_ecology_80x58.tscn`, **2560×1856 / 80×58@32**, 326 independently selectable object owners. Original A36 scene stays preserved.
- Original A36 Ground-only SHA **ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911** unchanged. Original generation source **1478×1064 nearest-scaled** remains an honest ART HOLD.
- Four original A35 tree variants + two genuinely different full isolated A36B trees: **40 pine (148×194), 22 willow (208×190)** replacing 62 old trees, preserving 264 other object owners. 326 total PAR, 11 independent source families; independent new SHADOW layer SHA **752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa**.
- True Godot 4.7.2 private 2621 checks PASS, public 1973 checks PASS, two native OpenGL 2560×1856 framebuffer renders. A36→A36B pixel delta **910,260 RGB pixels**, zero outside modified PAR source/footprint shadow ROIs.
- Cold generation **6/6 SHA exact**, rejects existing destination paths without deleting anything; rejected cropped/overlapping bottom-row sprite assets, not counted.
- **ART HOLD** (bright yellow willows vs pine/ground, tree repetition, nearest-resampled Ground); **COLLISION HOLD** (148 candidate water cells, never claimed physical), **WATER ANIMATION NOT_IMPLEMENTED**; no full user 1x acceptance or final seal.
- [A36B real QA/Failure Log](docs/A36B_TREE_ECOLOGY_HANDOFF_20261114.md) and original [A36 native owner-only R2](https://drive.google.com/file/d/1LgUCJRi8i-NDz-EC1roXHWnBjNysjtuu/view).

Next: A36C improve **real ground pixel resolution and riverbank art**, increase independent tree silhouettes to 8–12, then WATER layer and six biomes. Do not devote this art lane to events/quests.


## A36B R2 owner-only Drive and real GitHub delivery
- Full private 173-member A36B portable Godot ZIP: https://drive.google.com/file/d/15t5Yn6zdTC8vG1dOYrLmMEHGVYqjEjwO/view , **54,150,993 bytes SHA256 `7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b`**. Drive upload→download original bytes, ZIP CRC PASS, 172 member SHA PASS; owner-only, `shared=false`.
- True independent A36/A36B Godot OpenGL 1x framebuffer A/B: https://drive.google.com/file/d/1XvFNe8auahjunwSm1x_Rz3ot8IznhjR5/view ; new 2560×1856 true Godot frame: https://drive.google.com/file/d/1fVCS0ut1RBnfVz_sv2X9ToyBP4xYUq8V/view .
- Private Drive Handoff/Failure Log mirror: https://drive.google.com/file/d/1Q6FjCjlnOgIGRQauFmkhz3kHr4CvotRb/view .
- Public Draft GitHub Godot PR #16 branch `feat/fs-godot-first-a29-20261113` for only source, editor scene references, tests, art source manifests. GitHub Actions latest-head status must be independently checked after commit; no pre-claim of CI success.
