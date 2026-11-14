# Forest Symphony｜Godot-first Current Handoff A35 (2026-11-14)

**This conversation owns only Ground/PAR production, authored art quality, larger map scaling, and six biome maze-village art.** **Other conversation owns events, NPCs, quests, door scripting, combat**. No event code is to be produced here.

## Single source of policy
[Active Master v1.3 Ground-first + independently authored complete PAR](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-asset-factory-v1-20261107/authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md). Godot 4.7.2 remains the main development engine. Legacy VX and flattened-Master-based A29–A31 are reference/compatibility only, not new map production.

## Real newest state A35
- `project.godot` opens `res://scenes/a35_independent_tree_family_scene.tscn`. Old A34 and A33/A32 scenes remain independently available.
- A34 independent opaque 1280x928 Ground unchanged SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`.
- Original A33 four independent complete lanterns, A34 two complete houses preserved byte-for-byte. **No flattened Master source cutting**.
- A35: **2 source tree-art sheets, each with 2 COMPLETE isolated transparent trees; 4 new RGBA full tree variants**. Replaced exactly **8** representative tree instances among **134**; **138** unrelated scene objects remain original source SHA/footpoints. Total scene 146 editable object owners, **31** family assets. Keep 140 original physical footprint colliders; not a full map traversal seal.
- **Real private Godot 4.7.2 source tests: 1063 PASS**, 2 true native OpenGL A/B source scenes + 2 native tree front/back actor cases. Unchanged Ground exact; **65,992 native framebuffer RGB pixels changed, only within replaced-tree object ROIs; 0 pixels outside**. Cold rebuild of **all 4 art PNGs + scene + manifest** SHA identical. Public source-only Godot **788 checks PASS**; strict failure accumulator fixed after first test false-positive, recorded in A35 Failure Log.
- **USER ART HOLD**: new foliage brighter/more detailed, some trees partially beyond viewport (deliberate forest edge), other older family trees still pixel-density mismatched. Cannot claim entire forest completed or 1x Art PASS.

## Forward road map (not completed content)
- **A36 first larger map**: target **2560×1856 = 80×58 @32px**, **four times current area**. Must author a **genuinely continuous and non-repetitive** Ground-only source, followed by independent complete PAR scene objects. Never mirror/quilt 4 copies of A34 Ground and pretend visual success. 80×58 is a **target design contract, not actual A36 artwork**.
- Six biomes × maze and village = **12 desired maps**, spec file `data/fs_six_biomes_world_catalog.json`, readable version `docs/FS_SIX_BIOMES_WORLD_ART_PLAN_20261114.md`. Six types: forest, frost, desert, volcano, marsh, astral crystal isles. This is a **style and world spec only**, not 12 generated maps.
- All future scenes: independent Ground-only, complete transparent PAR, independent SHADOW/LIGHT/WATER FX, separate semantic footpoint + collision. **Event team receives scene IDs / 32px collision / door geometry only when validated**; no events authored here.

## Cloud and protection
- Full private Godot project and original generated tree source pages: owner-only Drive. Only code/test/JSON/docs and public scene references to SHA go on GitHub Draft PR #16. No user PC writes, no public copyrighted/private PNG, no changes to sealed VX or GitHub main, no paid PixelLab calls.
- Cloud ZIP/CI proof and owner-only A/B links appended after verified upload/readback. See `docs/A35_TREE_ART_AND_BIOME_PLAN_HANDOFF_20261114.md` for QA/Failure Log.

## A35 Owner-only Drive completed + readback
- [158-file complete original art + Godot 4.7.2 A35 project](https://drive.google.com/file/d/1gNjkqvo_I8KbT4siEolsAWflyIRBPVim/view): **40,467,666 bytes**, SHA256 `f1de2a44f89e580620b86e154904907e484fea5610d10da83d895b54c20f4c98`. Uploaded + raw downloaded; ZIP CRC **PASS**, every 157 report-member SHA **PASS** (plus report itself in archive). Owner-only Drive.
- [Native Godot A34 vs A35 art A/B](https://drive.google.com/file/d/19K82PK8_F5W_riClWDdF302UZ6TKzYRR/view) and [native actor standing tree behind/front](https://drive.google.com/file/d/1mTgJ8EgrdoJZ4q0l1sPKjtOQhmI1jAO0/view).
- [A35 real QA / failure log Drive Handoff](https://drive.google.com/file/d/1BBWccz2iTXHt5Mu9QtBBGFtWdXb9ftGW/view); [six biome/12 scene art world plan](https://drive.google.com/file/d/1hQEUuEGcuFunJVkQfREjdfLWSaMvU4Fz/view).
- **Important:** 2560x1856 A36 and 12 map artworks remain **NOT_BUILT**, only source-validated art contract exists. Do not state otherwise.
