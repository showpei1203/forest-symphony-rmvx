# FS R11｜Village-size 40×29 true ground3 + five source-aligned PAR layers｜2026-10-28

## Verdict
**R11 40×29 actual native renderer/map and SAM2 five-object dynamic foreground technically PASS. New village art-quality automated generation is NOT YET PROVEN. Human Visual Gate F HOLD. Full unchanged 505-page original FS boot still BLOCKED.**

### Source authority (read-only)
- K4 genuine official `Data/Map003.rvdata` corresponds to `Graphics/Parallaxes/ground3.png`, 40×29 tile cells, exactly 1280×928 RGB pixels.
- Map003 SHA256: `118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4`.
- Actual Map003 third layer: 503 cells ID 769 walk, 642 cells ID 768 block, other 15 cells with original special values, preserving all data source bytes.
- Map003 contains **25 original events**. Existing R5 adapter clears them for testing and injects one NPC900. Therefore full original Map003 event path was NOT exercised.
- Original full K4 FS `Data/Scripts.rvdata` 505 pages SHA256: `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`. Never changed in R11. Isolated test harness preserves 504 original tuples, only #480 pre-existing NameError harness suppressed and one test page added.

### Two native village-size test branches
**Branch A: native Map003 ground3-only scale regression**
- Byte-for-byte original `Map003.rvdata` copied under `Map001.rvdata` in an isolated K4 harness (test harness originally maps ID1).
- Ground display is original `ground3.png`; SCENE21-only PAR objects removed from visibility, HK `Par1.png` set to transparent in isolated runtime; avoids wrong-scene foreground.
- Ten test poses in northwest, middle, east and south, using actual `Game_Player#move_{up,down,left,right}`, native screen capture after move and normal scrolling; blocked edge and terrain cases included.
- 2 independent Game.exe PID sessions, each 10/10 one-step moves with 10 screenshots, 20 native frames total.
- The source file is **existing original ground3**, NOT AI-generated new village.

**Branch B: ground3 5-object guided SAM2 + native dynamic PAR**
- Source `K4/Graphics/Parallaxes/ground3.png` original full 1280×928, do NOT alter or re-render.
- Guided SAM2.1 Hiera Small CPU with human-authored bboxes and +/- prompt seeds for four buildings (northwest, middle, northeast, south) and one central-right tree. Five candidate masks, all 5 pass prompt-seed consistency. **That is not independent artistic segmentation correctness.**
- Combined opaque candidate PAR = 275,834 source-derived pixels. Every opaque RGB pixel exact match with the original ground3 at the same coordinates.
- 5 independent original-color transparent PNG sprites are loaded by real VX Cache.picture; each has 1280×928 canvas; foot anchors set sprite Z. `Spriteset_Map#update` scroll compensates every frame via `sp.x=-($game_map.display_x/8), sp.y=-($game_map.display_y/8)`.
- Two independent Game.exe PID sessions each 10/10 real player moves and 10 native screenshots; total 20 additional native frames. Last formal fail-closed gate tests 4 sessions/40 screenshots in total.
- Camera offset test nonzero in both dimensions and reaches `display=[5888,4096]`; 5 PAR sprite positions verified to equal `(-display_x/8,-display_y/8)` for all logged captures, not just at the spawn.
- Native screenshot still shows FS's normal custom map HUD/message portrait overlay; this is **not** a clean artwork visual acceptance frame, no 1:1 foreground contour proof.
- No native static⇄dynamic A/B/A during camera scrolling; only DYNAMIC mode trial. No full 40×29 ground3 complete PAR extraction or multi-NPC collision routing completed.

### Technical conclusion: what is proven
1. Actual original **40×29 / 1280×928** loads in isolated FS VX, scrolls and supports real test moves.
2. The SAM2 pipeline can take actual full-size ground3, output original-source RGBA foreground objects; 5 current coarse prompted objects passed machine checks.
3. 5 large transparent 1280×928 sprites render in VX with correct mathematical display scroll compensation in this isolated test.
4. Both branches reproducible in independent Game.exe launches (2+2 sessions, 40 PNG); source FS 505 pages untouched and byte hash guarded.

### Production blockers / incomplete technical scope
- New AI-generated village **has not been authored**. Testing already beautiful `ground3` does not prove that new art at the same quality can be made.
- Full foreground object detection/selection and manual Visual Gate F for all 40×29 assets NOT achieved.
- Ground3 source has many more trees, houses, slopes, cliffs, fences, rocks and small foliage than five sampled entities; occlusion completeness NOT tested.
- R10 SCENE21 collision compiler only foot anchor, building polygon / stairs approach collision incomplete; no equivalent new map collision compiler for newly generated 40×29.
- Official Map003's 25 original event pages not preserved by existing test harness, so script/event gameplay and multi-NPC are not fully verified.
- Same-session native source static PAR⇄per-object dynamic PAR in several camera regions NOT run.
- Anim Ground water/cloud (`ground10_1..4`), Light, Shadow, normal weather and long play performance / FPS not measured; the captured frames only show normal boot/movement at test intervals.
- Full original 505-page source regression harness #480 still has old pre-Main alias boot error and was only disabled in isolated copy.

### Fail and fix record
- First SAM2 full-size 5-object run generated PNG but failed during JSON serialization of NumPy int64 (repeat from prior R8 class). Fixed via explicit JSON numeric serializer and **reran full 5-object pipeline** successfully; must add linter/gate to avoid recurrent error.
- SCENE21 R8 PAR assets were initially present in the copied large-map test harness; corrected R11 Ground-only test to blank PAR and switch HK STATIC. Never display a wrong-scene foreground on ground3. R11 five-object branch isolated from it.
- Native test overlay message/portrait masks parts of ground3; do not treat screenshot as all-art visual proof. Future art Gate must capture unobstructed 1× pure game view.
- Windows native package file sizes and GPU workload vary; no sustained FPS number was measured and no invented metrics permitted.

### Final classification
| Gate | Status |
|---|---|
| 40×29 file + Map003 authority | PASS |
| 40×29 native Game.exe movement/scroll | PASS (2 independent sessions) |
| 5 guided large masks source RGB original | PASS (technical provenance) |
| 5 dynamic PAR world-scroll compensation | PASS (2 independent sessions) |
| 1280×928 new village MASTER art at ground3 quality | **NOT CREATED / HOLD** |
| All object PAR semantic coverage + clean 1× visual gate | **HOLD** |
| 40×29 auto collision full architecture footprint | **HOLD** |
| Original 25 events + unchanged formal 505-page boot | **HOLD / known boot failure** |
| Native long run FPS + animated ground + light/shadow | **NOT TESTED** |
| User Human Art Gate F | **HOLD** |

### Deliverables
- `r11_ground3_authority_audit.py` and `R11_VILLAGE_SIZE_TECH/R11_GROUND3_FORMAL_AUTHORITY.json`.
- `build_r11_ground3_native.py`, `capture_r11_ground3_native.py`: original 40×29 source native test.
- `r11_ground3_large_source_par_experiment.py` and `R11_VILLAGE_SIZE_TECH/R11_GROUND3_5OBJECT_SAM2_GATE.json`, mask RGBA + source overlay PNGs.
- `build_r11_ground3_5object_native.py`, `prepare_r11_5par_capture.py`, `capture_r11_ground3_5par.py`: source-aligned 5 object dynamic native test.
- `r11_final_gate.py`: fail closed 4 native sessions, K4 SHA and source RGBA match, all 40 PNG, camera offset exact.
- `R11_VILLAGE_SIZE_TECH/R11_FINAL_GATE.json`, `R11_GROUND3_40x29_NATIVE/NATIVE*`, `R11_GROUND3_5OBJECT_NATIVE/NATIVE*`.
- `R12_NEW_VILLAGE_001_PRODUCTION_GATES.md`: authorized trial plan, NOT a claim the image exists.

**Scope invariant: sealed FS source Map003 and Scripts.rvdata + other dialogue's map art never edited.**