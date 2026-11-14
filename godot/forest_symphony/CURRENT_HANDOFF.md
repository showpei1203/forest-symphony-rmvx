# FS CURRENT_HANDOFF｜A33 Ground-first standalone lantern | 2026-11-14

**Production Rule:** Active Master v1.3: Ground-only first, independent full transparent PAR sources, Godot scene composition, 1x visual-art parity. Never default to Master flatten→mask crop. No main merge and no owner PC writes.

- **Latest A33:** `scenes/a33_groundfirst_lantern_scene.tscn` becomes main scene; A32 remains unchanged for baseline. Ground **1280×928 SHA256 3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000** untouched. 146 editor nodes, 27 independent source PAR families, 4 independent fully generated tall lanterns 52×124 SHA256 6e0bed07a735cba3c908a5da4c81863222363cab01325aeeaaf1f821d63a6991, original generated 887×1774 stored in private art.
- Native QA Godot 4.7.2 A33 **760 checks PASS**, actual base contact, old A32 **734 checks PASS**, public source-only contract PASS. Four actual 1280×928 native framebuffer PNG, 7,964 RGB pixels changed exactly within old/new four-lamp ROIs; outside **0**. One lamp repositioned from (496,473) to (438,473) to avoid covering original well.
- **ART HOLD**: lamp candidate not user approved; two houses and tree style mismatch, full grid passability/NPC/4-direction overworld/ATB Windows export not yet complete. Formal Seal NO.
- [Owner-only A33 full ZIP](https://drive.google.com/file/d/1mIJVMUsdHJu0oVUqBbVqvGhhJ582o7zl/view) (61,517,282 bytes, SHA 50729302db83d920d55f131c69f1f671001664af86fad1099dab1b09c1d4b224) uploaded and roundtrip validated; [native A/B image](https://drive.google.com/file/d/1lrB7aoIgCFSbfeGMnk5hP5P3HT8Qix8Q/view).
- Detailed QA + Failure Log: `docs/A33_INDEPENDENT_LANTERN_NATIVE_HANDOFF.md`. Next A34 focus: real high-quality **complete independent house PAR family**, Ground and other PAR unchanged, followed by Godot native comparison.

# Forest Symphony｜Godot-first CURRENT_HANDOFF（A32）

Latest: **A32 Ground-first + independent complete PAR** | 2026-11-14. Active Master v1.3 **overrides** A11/A21 old flattened-Master source-crop default.

**Entry points:** `project.godot` -> `scenes/a32_groundfirst_scene.tscn` main scene. Older A31 original `/scenes/elf_forest_map.tscn` remains separately executable for historical comparison, not a future production art source.

**Actual new art:** New Ground-only authored before any upright object, crop from 1536x1024 to **1280x928 without resampling**, file `private_assets/ground_only.png` SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`. Includes lush grass, irregular winding dirt path, small flowers, stones, ferns; no tree, roof or building sprite. Full image-gen source privately preserved as `private_assets/a32_ground_creation_source_1536x1024.png` SHA256 `ca406a73350f325d2da5541770c6a3c3da075dcf8f5635b03f1f5063fee77910`.

**Actual new independent scene:** 27 separate independent RGBA source families (not source crops from this generated Ground), 146 editor-placeable Godot `Node2D` objects (134 complete trees, 2 moss-roof complete same-family houses, 10 props); source provenance = preexisting owner-only A36F independent RGBA source archive + FS v2.3.3 standalone Graphics/Pictures sprites, source and processed PNG hash tracked. 136 tree/house object-root rectangular physics footprints; independent actor 48x48 F0 and Camera2D. All original objects may be individually repositioned in Godot scene inspector. Ground source not modified by compositor, flat PAR alpha preview only QA, not runtime layering.

**True native Godot 4.7.2 QA:** `--headless --editor` no parse errors, `test_a32_groundfirst_real.gd` **734 PASS**, source-only without ANY art `test_a32_public_contract.gd` PASS; native OpenGL full 1280x928 screenshot, plus two 544x416 tree-front/behind screenshots. RGB comparison native/full vs static Pillow source composite: 10,965 changed pixels, 720 >1, max per-channel 16, MAE 0.005118; native YSort alpha order differs minimally from a static crop. Not pixel-perfect and not claimed as such.

**Current gates:** `GROUND_ART=CANDIDATE`, `PAR_ART=HOLD` (moss house roof and front are less detailed than rich ground, tree pixel density consistency still unapproved), `REAL_COLLISION_SOURCE=HOLD` (136 tree/house root footprints only, 40x29 path graph/door transitions not mapped), `OVERWORLD_FOUR_DIRECTION=NOT_RUN` (legacy 45deg A62 battle RUN explicitly not reused as overworld walk), `USER_ART=HOLD`, `NPC/EVENTS/BATTLE/SAVE=NOT_RUN`, `FORMAL_SEAL=NO`.

**Next real work priority:** Create *independent* detailed house family PAR transparent RGBA matching the actual 1x pixel-rich Ground, using art tools or authorized user originals. Do not fall back to cutting from full scene. Improve tree color/lighting consistency and clustered forest, compare source-ground-only + PAR + Godot native 1x composite vs complete image reference. Then fill source-faithful 32px navigable geometry and a working NPC/entrance; do not waste time only on pixel-diff numbers.

**Safety:** No new user PC files; no paid PixelLab credits; owner-only private art to Drive; source, manifests and tests to GitHub Draft PR #16, original VX sealed assets and main branch protected. Always make Handoff/Failure Log and native capture. Keep this A32 ground-only PNG SHA frozen while testing independent PAR replacements.

## A32 VERIFIED CLOUD ART AND QA LINKS

- **Owner-only full portable Godot R4**: https://drive.google.com/file/d/10oUrfTbgohCHuCq0GO36vyQ3kCABIlBc/view, **228 ZIP entries, 47,995,335 bytes, SHA256 `28a52f2a901f8ea4ca2bcffe53646dcafe619a3d6ef365b6152efcc77b36b544`**, upload → raw Drive download, SHA256/ZIP CRC verified PASS; contains new 1536 ground original, 1280 Ground-only, 27 RGBA PAR, 146 editable Godot scene objects, true native screenshot and old A31 baseline.
- **Real Godot 4.7.2 1x framebuffer**: https://drive.google.com/file/d/1YVEJozXA_4GyLO1T1647CvJFJAi9YXyg/view ; **Ground / independently authored PAR / composite**: https://drive.google.com/file/d/1mV1P1M0gn8CHFvuVrFEdDdbGtUQjACop/view.
- **A32 full Failure Log and Handoff owner-only Drive**: https://drive.google.com/file/d/1-Cfnv_7QuVgShWZaLQftfrz-fADRIW3x/view .
- Private Drive metadata confirmed user-only. Public Godot PR #16 only source/script/manifests/CI; image files never pushed to GitHub. User PC untouched; PixelLab paid credits not used.
