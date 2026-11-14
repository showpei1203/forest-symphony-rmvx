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


## A32 user visual feedback｜2026-11-14
User confirms Ground-first + independent full PAR **direction is correct and a significant improvement**, but flags street lamps visually **half-height**. Source audit: legacy `FSOBJ_post_lantern.png` is an original **16×41** sprite, A32 PAD-only **32×57** with alpha bbox (8,8)-(24,49); four independent instances use it. This is an **ART/source proportion issue**, not evidence of Godot cutting a full lamppost or an excuse to alter Ground/PAR architecture. **A32-F05 ART HOLD**; construct a coherent complete tall lamp family, retain original SHA, and compare actual Godot 1x; no art fix claimed. Other A32 ART HOLD (two house detail/style, tree-tone diversity) remains.
