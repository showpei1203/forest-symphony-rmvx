# FS V6 Art Target + Ground10 Animation QA | RELEASE HANDOFF | 2026-10-26

**VERDICT:** USER VISUAL TARGET SPECIFICATION RECORDED / 6 PNG REFERENCE PIXEL IDENTITY VERIFIED / ANIMATED ROI STATIC RECONSTRUCTION TECH PASS / REAL VX ANIMATION & HUMAN ART PENDING.

## Canonical user target
- SCENE001, SCENE05, SCENE06, SCENE14, SCENE18 and SCENE21 are art density/style references, not pre-split runtime Ground/PAR. Disc shape/black surround not required.
- Village/wilderness target: ground3 **1280x928 px (40x29 tiles)**.
- Dynamic source: ground10 and numbered frames **960x1280 px (30x40 tiles)**.
- Full detailed layered buildings/forest/cliffs/props/ground transitions at those sizes; 544x416 is camera viewport.
- Ground green/dirt default walkable; water/holes/void exceptions; solid blocker semantics applied only after PAR placement. Source-first, one Scene Manifest, sealed baselines untouched.

## Read-only Windows evidence
- FS Animated Parallax 2.1: _1 suffix needed, map10=40,map8=20,other maps default=30 frames, preload=true, FS_LegacyScripts_SafetyPatch v1.0.14.
- All six user Ground PNG uploads and original FS isolated source images match byte-for-byte when compared as **decoded RGBA pixels** (raw PNG bytes may differ).
- Four numbered frame's only motion region: [0,928,640,1280] (640x352), outside strictly identical. Static source ground10_1 + ROIs reconstruct all **four 960x1280 images with 0 RGBA drift**.
- _2/_4 duplicate in pixel data, timeline [1,2,3,2], three unique patch bitmaps.
- 4 full images=19,660,800 uncompressed RGBA bytes vs static+three ROI=7,618,560 (61.25% theoretical reduction); unknown actual FPS/VRAM. Wrong-frame negative test detected 91,656 pixel changes.
- Base file without numbered suffix differs from frame1 outside animation region by 8,733 pixels; keep it separate.
- Portable QA scripts re-executed, clean cold extraction of private ZIP (16 file SHA checks + re-run source+dedup) PASS.

## Files and authority
- Drive: https://docs.google.com/document/d/1aypbyssZaYh1SG8cae0iK98JW5ufU__xcXA-q3gLZu8/edit
- GitHub art authority: https://github.com/showpei1203/forest-symphony-rmvx/blob/main/authority/handoff/FS_V6_HIGH_FIDELITY_LARGE_MAP_AND_ANIMATED_GROUND_20261026.md
- GitHub Source/Style inventory: https://github.com/showpei1203/forest-symphony-rmvx/blob/main/authority/art/FS_V6_BIOME_STYLE_DNA_AND_SOURCE_INVENTORY_20261026.md
- GitHub QA tools: tools/fs_map_v6/audit_ground10_animation.py and optimize_ground10_roi_dedupe.py
- Linear: SHO-39
- Local working: E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261026
- Local complete PRIVATE QA ZIP:
  E:\GameAssetToolLab_20261023\deliveries\FS_V6_HIGH_FIDELITY_ANIMATION_REFERENCE_PRIVATE_20261026.zip
  bytes: 15,093,640; SHA256: 23587D39065DF9AC26C863F2959737D1639AD6E3DD0DF01518E220ED0FBF5F70
  Source PNGs private test ONLY, never upload raw pictures to public GitHub.

## Next steps (keep order)
1. P1: revise style golden comparison per biome; SCENE21 17x13 high-fidelity Ground-only art candidate. Current rough F2 G5R4 source crop **not** adequate art quality.
2. P2: approve Ground-only 1x+2x human art prior to transparent architecture/trees/props.
3. P3: original-source integrity, shadow/contact/occlusion/collision, single Manifest, Tiled and native VX test.
4. P4: target village/field 40x29 world and camera scroll.
5. P5: isolated Mode A legacy animated parallax 4 frames vs Mode B 3-ROI dedup runtime benchmark. Compare FPS/memory/native pixel reconstitution and animation plane ordering in RGSS2, do not modify sealed.
6. P6: final user art and native Gate, ZIP with test commands/log/Drive/GitHub/Linear.

Not accepted: 40x29 actual new art, animated ROI loaded into actual VX runtime, engine perf gains, formal user visual art acceptance. Existing sealed baselines, shared projects and another conversation's F2 map engineering remain untouched.
