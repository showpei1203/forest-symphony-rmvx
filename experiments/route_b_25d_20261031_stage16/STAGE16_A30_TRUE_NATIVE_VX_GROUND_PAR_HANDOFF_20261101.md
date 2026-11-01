# Forest Symphony Stage16 A30: True Native RPG Maker VX Ground/PAR

2026-11-01 Taiwan. Scope: isolated FS Ground/PAR engineering benchmark, not SBS Sprite Sheet and not the sealed production game.

**Overall: native isolated VX Map50 occlusion/passability PASS, original A29 Godot 8/8 cold PASS retained, artistic signoff PENDING, unmodified production startup not tested, Formal Seal NO.**

## Authority and provenance

Read in order:
1. authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md
2. authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md
3. experiments/route_b_25d_20261031_stage16/STAGE16_A29_DETAILED_HANDOFF_A30_TEST_PLAN_20261101.md
4. Google Drive FS_SOURCE_ASSET_LOCATION_REGISTRY_V1_20261023, original A29 manifest.

A27 original native PixelLab opaque Ground 544x416 SHA256 35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce **unchanged**. 12 discrete A29 PAR RGBA objects (4 trees, 4 rocks, 2 barrels, 2 lamps) retained with exact x/y/foot/provenance. Three trees Drive sourced, one existing PixelLab. New paid PixelLab generations A30: ZERO. New user rule: after style is approved, author original individual PAR objects matching scene semantics; existing Drive atlas is a style/provenance reference, not a closed object whitelist. This does not waive RGBA, clipping, original Ground, dynamic occlusion, collision, licensing, or native engine QA.

## True isolated native VX build (not staging)

Remote private parent E:\FS_ROUTE_B_STAGE16_A30_SEMANTIC_PAR_VX_20261101. Actual test executable E:\FS_ROUTE_B_STAGE16_A30_SEMANTIC_PAR_VX_20261101\VX_NATIVE_A30_REAL_MAP50_LAYER_TEST\Game.exe.

- Genuine Data/Map050.rvdata 17x13; System start map50 x8 y6. No story events.
- Overlays/ground50.png is SHA-identical to A27, untouched RGBA/opaque. Overlays/Par50.png is separate transparent full composite retained as reference, but static PAR not used for dynamic depth. Twelve Overlays/A30_OBJ_<id>.png discrete sprites are loaded by native Cache.overlay, rendered with exact image x/y and per-object foot.
- Separate TEST-only RGSS script inserted before Main in copied Scripts.rvdata. Existing Hanzo Kimura Ultimate Overlay Mapping normally renders Ground opacity145, subtractive; test Ground corrected to opaque opacity255 normal blend; independent PAR sprites depth sorted. This is a test adapter only, NOT production change.
- Existing FS Game_Character#screen_z is overridden by old script index323: base z100 plus floor(screen_y/18)*3. First A30 fixed z99/z101 FAILED; corrected sprite z=100+floor(object_foot_y/18)*3. Real avatar moves in front or behind by native z.
- Existing ISS::ParaPassa v0.9 script index342 overrides native Game_Map passability. E-layer map.data[x,y,2] Tile ID 768 means impassable, 769 all directions passable. A30 wrote 12 obstacle foot tiles=768, 209 walkable=769 in ACTUAL Map050.rvdata, no custom temporary Game_Character collision override remains. All 209 reachable BFS.

## Native Game.exe test evidence

- Actual RGSS Player client 544x416; screenshot taken from ImageGrab(window=RGSS HWND), NOT desktop bbox. Real FS $actor01 character. Native Game.exe actual Map50 scene loaded, 12 original RGBA sprites. 12 actor cases, hidden/actor pairs, 24 actual screenshots, no RGSS error modal.
- Source actor alpha bitmap opaque count 627. Paired per-case actor target tile ROI changed coordinates: road 627/627; **fully hidden east broadleaf tile(14,3): 0/627**; partly behind west canopy 404/627; partly behind east canopy 416/627; southwest canopy 511/627; front actor 627/627. The 0-pixel full-hide case was corrected from an incorrect old west-location QA ROI. Source east tree alpha predicts 627 fully opaque overlapping pixels at true (14,3).
- Native walkability: blocked attempt from (2,4) down to (2,5) stayed (2,4); native road move from (8,6) right to (9,6) SUCCESS. These used true ISS ParaPassa E layer, not forced teleport collision test.
- No-actor native screenshot versus A29 static composite after ignoring upper left HUD [0,0,240,85] had 11,574 differing coordinates, 71 coordinates RGB channel error >1, maximum channel error 2. This is NOT a literal zero difference claim.
- Local QA: A30_VX_NATIVE_12_CASES_SCREEN_QA.json, A30_VX_NATIVE_VISUAL_PIXEL_QA.json, A30_VX_FINAL_MAP_COLLISION_ALPHA_QA.json, A30_VX_TRUE_PARAPASSA_E_LAYER_QA.json. Labeled 544x3122 actual seven-scene phone preview A30_VX_ACTUAL_GAME_MOBILE_VERTICAL_544W.png.

## Independent cold native rebuild

- Fresh E:\FS_STAGE16_A30_VX_NATIVE_COLD_20261101 copied from finished native map test. **3395/3395 file-by-file SHA256 identical**; original Ground SHA retained.
- Cold native Game.exe entered MAP50 (17x13) with 12 independent objects and no modal errors. Cold HWND captures at 8 and 9 seconds are actual 544x416 native map images, with actor and correct textures; 7 seconds was only transition/blank and is NOT evidence.
- Cold exact frame-to-frame SHA identical screenshots NOT YET PROVED; timing/frame-dependent screenshot captures differ. 3395/3395 file integrity and real native cold map launch PASS, but pixel-perfect cold screenshot parity remains PENDING.

## Failure log and non-regression

1. Original A29 VX bootstrap NameError p45b_prepare_resources and later p45b_restore_battle_skill_slot in TEST-only FS_BattleRegression_AIEdgeI. A30 map-only sandbox omits that TEST-only battle regression script; this is NOT a full production script fix or combat signoff. Do not patch sealed game.
2. Initial A30 native Spriteset_Map.update ran before @a30_assets was created, causing nil.each; nil-safe first update corrected in sandbox.
3. VX RGSS2 move_down/move_right and passable?(x,y), NOT newer move_straight/passable?(x,y,d).
4. First desktop-grab screenshots were of unrelated foreground text UI; invalid. ImageGrab(window=RGSS hwnd) only.
5. Native FS actor screen_z override requires matching per-foot Z formula; avoid fixed 99/101.
6. ISS::ParaPassa E-layer special Tile 768/769 controls passage; blank Tile0 and generic passable flag setup alone are insufficient.
7. Exact-case QA must update ROI coordinate when changing a scenario. A30 false 382 count arose from ROI at old west(2,2) instead of new east(14,3); corrected target ROI is ZERO.
8. Drive source assets licensing unresolved; private test only, no binary sprites on public GitHub.

## Native gates and next A31

A30 engineering PASS: source Ground; separate RGBA layers; native in-game map; full/partial/front occlusion; native blocked/road walk; 209/209 BFS; native cold file 3395/3395 and real cold map launch; A29 Godot 8/8 predecessor retained.

Still NOT PASS: pixel-perfect 24/24 cold screenshot replay; commercial art license; user visual Ground3-level acceptance; full unmodified sealed production battle harness startup and regressions. **Formal Seal NO**.

A31: compare art against user-approved Ground3/elf-village style; then use newly authorized semantic independently generated PAR objects (distinct intact trees/rocks/structures) with exact RGBA, footprints, tone and provenance. Run actual VX and Godot with collision/occlusion; investigate original BattleRegression test harness alias compatibility separately. Keep new art PRIVATE until rights settled; no paid generation presumed.

A30 private stage Drive folder: https://drive.google.com/drive/folders/1D_CJM5BQpMTkzWz3zzkh-oP3tNdLgwIe
A29 native original source Drive folder: https://drive.google.com/drive/folders/1Rqdo_qw1Vdvpfcx2a5iOf7joH83ncVtT

No Formal Seal promotion in this handoff.

## VERIFIED A30 private Google Drive delivery links (readback 2026-11-01)

- Mobile true RGSS Player 544px-wide labeled seven-case vertical preview (544×3122): https://drive.google.com/file/d/1_1LgD1UKQ12KHJbFZiBSu9EI6ScZRDW4/view
- Actual independently cold-booted VX 544×416 game screenshot: https://drive.google.com/file/d/1YDJBTNccUw0NTfDomqbL09_ynwhGx4OA/view
- PRIVATE A30 native map QA complete ZIP (92 entries, 9,314,909 bytes, ZIP CRC + per-file SHA + independent extraction PASS, SHA256 c8a7cb9655cec25d7c67e70633b16857a4ec8155bb71c08bcf2ef7bd757ad4c5): https://drive.google.com/file/d/1qa9vyl2HS9ESmzjxVllkJzWqH96ZX9gV/view
- Stage full detail: https://drive.google.com/file/d/1sDVp79McmN0f_OI5qX8ZemZ72B6lOmam/view
- Latest A30 current entry: https://drive.google.com/file/d/1w-ZtFMSTPR9_hxBzkdyXYhL2BwguEc_g/view
- A30 permanent native VX engine rules: https://drive.google.com/file/d/1F-RVxIEK2nRYaMvn3hXRbm2PBoArxN4q/view
- Drive stage folder: https://drive.google.com/drive/folders/1D_CJM5BQpMTkzWz3zzkh-oP3tNdLgwIe

Cloud metadata readback confirms exact files and sizes. Zip CRC, member SHA256, and independent extract validation are local, not an additional claimed remote full ZIP hash readback.
