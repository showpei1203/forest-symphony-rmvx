# CURRENT_HANDOFF.md

## Purpose
This is the current conversation-independent handoff for Forest Symphony. New development sessions should first read:
1. `00_Project_Authority/MASTER_PROJECT_STATE.md`
2. this file
3. Google Drive `01_Current_Baseline`
4. GitHub `main` / `develop` once repository access is established
5. Linear open issues in the Forest Symphony project

## Most Recent Work
- Infrastructure migration was promoted above gameplay development.
- Google Drive authority folders were created under the existing `Forest Symphony` project folder.
- Linear project `Forest Symphony` was created in team `Showpei`.
- A Git source bootstrap was generated from the Phase49J SEALED `Scripts.rvdata`, preserving 505 script entries, original order, Script ID, Script Name metadata, raw Script Content, and per-script SHA-256.
- Git `main` is staged from Phase49J SEALED source.
- Git `develop` is staged from K5 and differs in Runtime script content only at TEST page478; Formal Runtime delta remains 0.
- GitHub remote publication is blocked because the connected GitHub App exposes no installed account / repository access.

## Latest Real-Machine Results
- Battle standalone: Phase48A `1388 PASS / 0 FAIL / 0 WARN` — SEALED.
- Nonbattle standalone: Phase49J `411 PASS / 0 FAIL / 0 WARN` — SEALED.
- Cross-Suite K4: `1851 PASS / 3 FAIL / 0 WARN`.

## Latest FAIL Classification
The K4 three FAILs are not three Runtime defects. They are all consequences of one TEST-only semantic invariant defect:
- stable keys were exact after Battle and POST;
- only `Graphics.frame_count` advanced from 205 to 236;
- frame is a timeline and should be monotonic, not restored to exact equality.

No current evidence supports Formal Runtime state leakage.

## Current Candidate
- Phase49K5 / Harness `v0.4k5`.
- `Scripts.rvdata` SHA-256: `ac8ebb85b2686c34a2715a3a656d2f3c4b4bffc09c377f9bdb0e580a33862917`.
- Candidate ZIP SHA-256: `c9f2c4ce147131ca33c4160760213c0fc69aa55539ab0453e1156e41738bc9d4`.
- Static status: PASS.
- Runtime status: UNVERIFIED. Do not call it SEALED/Baseline.
- Delta: page478 TEST only. Stable keys exact; frame guard `actual >= expected`; regression emits `:frame_regressed`; frame delta diagnostic retained.

## Next Step After Migration Gate
Use the K5 package from Google Drive `03_Test_Builds` on Windows / RPG Maker VX:
1. enter idle Scene_Map;
2. press Ctrl+Shift+F9 once;
3. collect AutoRegression + Validation evidence;
4. target `[SUMMARY] suite=CROSS_SUITE result=PASS pass=1854 fail=0 warn=0`.

If K5 passes, formally SEALED Phase49K and then run Final Integrated Soak XI in separate fresh processes. Do not nest the full 411 repeatability suite inside Cross-Suite again.

## Do Not Roll Back / Reopen
- Do not reopen SEALED Phase49B–J without new real-machine evidence.
- Do not reinterpret K4 frame advancement as gameplay leakage.
- Do not restore frame count merely to manufacture equality.
- Do not return to whole-root Marshal clone detection.
- Do not alter protected pages 482/483/484.
- Do not reintroduce `Thread.new` access to game/scene/sprite state.
- Do not weaken gameplay expectations to obtain green tests.

## Known Traps
- RGSS2 32-bit native/resource ceiling: K0 showed that nesting full 411 repeatability before Battle can hard-exit the process.
- TEST method/override chains are sensitive to page order; K1/K2/K3 already isolated helper-name and wrapper-chain defects.
- Version number alone is not authority. PASS/SEALED evidence outranks a newer unverified candidate.
- Same-name files exist in File Library with different creation dates/content. Preserve and hash before deduplication.
- The current handoff packages are not a complete runnable project. Do not treat legacy 2020 Drive assets as current Graphics/Audio/Data authority.

## Confirmed Design / Engineering Decisions
- Formal vs TEST separation is strict.
- Real-machine LOG is Runtime authority.
- `Scripts.rvdata` name is fixed.
- Battle snapshot design remains.
- Class Change gameplay is out of scope.
- Soul Art/equipment ownership cannot be faked via `learn_skill`.
- Native Tankentai popup color remains unchanged.
- Full release packaging must start from the user's current complete project source.

## Infrastructure
- Google Drive: https://drive.google.com/drive/folders/1FMDwuFeyzseu_UK7FKDt_rrl9CQwi-IH
- Linear: https://linear.app/showpei/project/forest-symphony-f0bfaea8775f
- GitHub: PENDING — `showpei1203` identity is readable, repository access is not yet granted to the connector.

## Last Updated
2026-08-18 08:23 +08:00
