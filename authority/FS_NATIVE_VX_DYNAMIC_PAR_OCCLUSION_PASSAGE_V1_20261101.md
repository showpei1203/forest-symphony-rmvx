# FS Native RPG Maker VX Dynamic PAR Occlusion & ParaPassa Authority v1.0

Date: 2026-11-01, A30 isolated VX engineering verified. Status: ACTIVE ENGINE TEST PROCEDURE. Does NOT change any sealed FS production build; user aesthetic acceptance and Formal Seal remain NO.

## Required source precedence
1. Sealed production authority, Ground/PAR production V1 and current handoff.
2. FS_SOURCE_ASSET_LOCATION_REGISTRY_V1, original Ground/PAR scene manifest and SHA.
3. User-approved semantic original PAR art authority: independent complete original RGBA object generation permitted after style confirmation; not mandatory to copy exact Drive object.
4. THIS verified engine-specific adapter contract.

## Verified legacy scripts in this actual FS runtime
- HK Ultimate Overlay Mapping at old script index145 automatically loads Overlays/ground{map_id}.png and Overlays/Par{map_id}.png when found. The existing Ground Sprite default opacity145 and blend_type2 is NOT a full opaque true Ground under the new source-first pipeline; correct only in isolated test unless explicitly approved for production.
- Old riding/character extension script index323 overrides Game_Character#screen_z with baseline z100 plus floor(screen_y / 18) * 3. The usual simplistic PAR z99/z101 DOES NOT support actual front/behind.
- ISS::ParaPassa v0.9 script index342 overrides Game_Map#passable? and reads E layer data[x,y,2], special Tile IDs 768=blocked, 769=all-pass. Setting generic tile0/flag0x06 without E layer FAILED to make a player move in this runtime.
- Native VX RGSS2 uses Game_Character#passable?(x,y), move_down/move_right/move_left/move_up, not newer move_straight or three-argument passable. Do NOT assume RPG Maker VX Ace/MV API signatures.

## A30 proven assembly pattern
Keep GROUND_ORIGINAL opaque bitmap byte-unchanged, SHA checked. Keep PAR_BASE_RGBA, PAR_TONE_RGBA, PAR_FINAL_RGBA, each sprite independent. Test map 17x13 32px tile =544x416. Keep exact Scene Manifest for each object x/y top-left, footX/Y separate, width/height source, alpha, collision footprint, asset SHA & source ownership. Native Sprite should be placed at exactly x/y, nearest-native pixel art, with depth equal to existing actor-z scheme: z=100 + floor(object_foot_y/18)*3, with screen camera offset when map scrolls. A30 map camera did not scroll; validate scroll separately before releasing a larger Ground3-size map.

Generate Game Map E layer from manifest ground-footprint collision only, not opaque tree canopy. Mark 12 blocked E tile768 and other 209 E tile769, verify BFS all walkable cells. Do not modify actor's movement method as a replacement for actual tile E layer testing.

Test true original character at front/behind/partial, including one truly fully hidden case. Compare actor-visible vs actor-hidden native exact-target 32x32 tile region, not arbitrary stale coordinates. Test native movement using actual move_down/right, expecting blocked (2,4)->(2,4) and open road (8,6)->(9,6). Keep screenshot/hit-area proof, and **do not** imply forced teleport to positions tests player movement.

## Required visual capture and fail-closed gates
Screenshots of native Game.exe: enumerate HWND with class RGSS Player and use PIL.ImageGrab.grab(window=hwnd). A screen-coordinate desktop bbox captures whatever other app is in front and is NOT proof. Log full native client 544x416, screenshot SHA, actor pair ROI pixel counts; include no-actor reference plus real engine status, no modal. Compare residual engine/composite colors honestly: even >1 channel errors require reporting. At minimum front-visible, partial-overlap, full-hide, tree trunk/collision and actual open-road movement.

Rebuild with fresh independent project clone and file SHA checks; actual cold Game.exe map display and error-free startup is a separate gate from deterministic screenshot SHA parity. Never mark 24/24 screenshot exact cold parity when only files and cold map rendering were verified.

## A30 actual precedent
Actual game map installed Map050 in isolated clone. 12 independent assets; opaque original 544x416 Ground SHA256 35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce; 209/209 BFS, 12 blockers. Native Game.exe real 24 screenshots, 0 modal. Original FS actor 627 opaque pixels; east fully behind tree tile(14,3) changed 0 of 627, west partial 404, east partial 416, front 627. Player real obstacle and road tests PASS. Independent native cold copied 3395 files all SHA equal, cold Game.exe map rendered; exact screenshot cold SHA parity not proved. Prior A29 Godot 8/8 retained. Art pending. Formal Seal NO.

## Known failure patterns
- Layer-flattened visualization presented as true Ground/PAR: FAIL.
- Original tree crop with opaque boundary padded later: FAIL.
- Generic Tile0 walking assumption despite ISS ParaPassa: FAIL.
- z99/101 while installed actor-z override active: FAIL.
- Cropped desktop screenshot showing chat UI as game: FAIL.
- Reusing stale target ROI coordinates after moving cases: FAIL.
- Missing alpha mask, blocking entire tree crown, unverified foot: FAIL.
- CLAIM Full VX production PASS from A30 clone with TEST-only FS_BattleRegression alias harness excluded: FAIL.

## Provenance and release
Private legacy Drive sprites with licensing unknown stay for PRIVATE TEST ONLY; public GitHub hosts docs/QA/code but no uncleared original binary sprites. Preserve previous sealed builds unmodified. New original semantic PAR art is allowed as candidate after style lock. Full formal sealing requires original production startup and battle regression compatibility, genuine VX/Godot all-map proof, visual acceptance, licensing, and cold independent rebuild.
