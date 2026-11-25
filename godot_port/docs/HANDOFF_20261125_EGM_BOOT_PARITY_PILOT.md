# P538F EGM pilot — JSON disk-load parity correction (2026-11-25)
Status: isolated review branch; locally verified with official Godot 4.7.2; full mainline CI and merge NOT RUN. Independent EGM receipt HOLD. Phase 1 SEAL NO.

## Baseline
Parent bc88b10d37d4e3a9816cdfa6932e7aaefaf33666 (active feature/fs-godot-phase1). Existing source CI 45309636925, 102 workflow steps, source artifact 14882961087 (SHA256 6ec5c8654cce8d55dbfad4702437c1c6a505666def4677115c395971f28d207f) and engine artifact 14883025531 (SHA256 dd63336bfbfe8f54cd571446ecdec295485ba223bebcba8408e418eda061e706) retrieved and verified in isolated cloud. Official engine version 4.7.2.stable.official.ed1daf0bf. Original Python/Godot source blob hashes cf6fda19ed72bdbeca9633cc672475e63424b669 / 1772ddb80f2d72db1ccb642c3b68e6fb3f28884a match active branch. No original private database/art or user PC project files used.

## Reproduction
Same 16 synthetic rehashed 11-table bundles plus fabricated test-only witness/manifest run through actual Python validate_bundle and Godot FSDatabase.load_all from disk. Expected contract: JSON finite integer-valued numeric values accepted, bool/string/fraction rejected; zsize exactly 1; nonempty party array and valid references; malformed collections rejected without exception. Integral decimal 1.0 is treated as a valid numeric integer, not a string. This is an explicit candidate contract choice to match Godot JSON number representation.

| Case | Expected | Python before | Godot before | Python after | Godot after |
|---|---|---|---|---|---|
| valid | ACCEPT | ACCEPT | REJECT | ACCEPT | ACCEPT |
| zsize_2 | REJECT | ACCEPT | REJECT | REJECT | REJECT |
| party_null | REJECT | ERROR_TypeError | REJECT | REJECT | REJECT |
| party_empty | REJECT | ACCEPT | REJECT | REJECT | REJECT |
| party_scalar | REJECT | ERROR_TypeError | REJECT | REJECT | REJECT |
| troop_null | REJECT | ERROR_TypeError | REJECT | REJECT | REJECT |
| troop_scalar | REJECT | ERROR_TypeError | REJECT | REJECT | REJECT |
| id_bool | REJECT | ACCEPT | REJECT | REJECT | REJECT |
| id_string | REJECT | REJECT | REJECT | REJECT | REJECT |
| id_fraction | REJECT | REJECT | REJECT | REJECT | REJECT |
| class_bool | REJECT | ACCEPT | REJECT | REJECT | REJECT |
| class_string | REJECT | REJECT | REJECT | REJECT | REJECT |
| class_fraction | REJECT | REJECT | REJECT | REJECT | REJECT |
| enemy_bool | REJECT | ACCEPT | REJECT | REJECT | REJECT |
| skill_string | REJECT | REJECT | REJECT | REJECT | REJECT |
| integral_decimal | ACCEPT | REJECT | REJECT | ACCEPT | ACCEPT |

Actual before: EGM_PYTHON_DISAGREEMENTS 10; EGM_GODOT_DISAGREEMENTS 2. Native valid case errors: FS Actor #1 成長 Table 維度不合法; FS System 初始隊伍包含不存在 Actor. Existing direct in-memory fixtures did not exercise JSON decoding; negative Godot cases may have rejected for unrelated baseline errors. After: both disagreements 0, 16/16 each; old Python self-test PASS; old P538F Godot valid+12 negative controls PASS; boot-final 505 scripts / 22 MasterSetup / eleven-table SHA witness fail-closed PASS. Actual native process exit 0 for enforce run and previous tests. Godot ran headless Linux cloud, not Windows or physical GPU.

## Implementation/readback
- Python commit 9d12e7b5c9e9cef9fc75f06346ccf17c0e153e3e, tested blob 2ebe88846bf3692e26c4a39d32fcb0c4cd95d2d7. Integral-number/valid-reference functions, exact zsize, list validation, witness/manifest type checks.
- Godot commit b833d0d110935b2788054f55c8ecafcdbaaeab57, tested blob 365e8ebad263f201ea379dba720f46a8ff78a82f. Validate safe finite integral JSON number before conversion/indexing; reject bool/string/fraction; exact dimensions; normalized party keys; witness metadata checks.
- Shared fixture generator blob d19258bdfe8c086110a267b7abd5f77ab37abcde; native disk-load test blob 82fc4e24025693a5a3afb43292beafd0337e900f. Both local hashes match GitHub readback.
- Mandatory isolated pilot workflow commit d5fe465702f1d6ea88c0780ec1357452d8835d1f; actual hosted CI result not yet retrieved. Original migration branch untouched. Full mainline regression/merge approval not claimed.

## Failure log and remaining gates
This engineering defect was identified/reproduced by the ChatGPT-led review and actual tests, NOT credited to an accepted independent EGM verdict. Prior independent EGM smoke proved native delegation, but real-project automated review receipt remains HOLD. Do not assert original source authenticity from internally consistent synthetic hashes. Actual original post-apply 11 tables, 505 effective RGSS2, 22 MasterSetup, original VX same-state UI, owner GPU and art gate remain HOLD. No private files published, no PixelLab, Desktop Remote or Codex usage. Next: independent post-fix review, verify hosted pilot and full mainline tests, then integrate only after conflict/readback check with active workline. No fake runtime witness or automatic merge.
