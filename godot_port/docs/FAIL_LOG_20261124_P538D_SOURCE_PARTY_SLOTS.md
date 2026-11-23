# Forest Symphony Godot｜P538D Failure Log｜2026-11-24

主線：`feature/fs-godot-phase1`，不涉及 T-A／T-B／T-C。上一筆 `FAIL_LOG_20261123_P538C_SOURCE_UI_GEOMETRY.md` 仍有效。

## ACTUAL R1｜來源位置覆蓋錯誤
- SOURCE：私有 202 PNG original `Graphics/System/MenuBack_party.png` 是 544x416，有 three numbered current slots (來源圖 x 約 75..220、y 約 69..142)，下方 Reserve Squad 字樣約 y328..360。
- BUG：P538C 三個文字 Button 固定放 x66/113/160,y103，直接橫蓋原版三個高直角色槽與數字；Reserve VBox y333 落入來源 `Reserve Squad` title。
- FIX code `c193b91a62ec629afb9b97a80d5de41dbcf4f77d`：current x77,127,177,y73,41x62 做 source portrait TextureButton，未知 ID 未授權肖像不套假人物，Reserve HBox+Scroll 由 y362 開始，保住原始來源標題。
- TEST：獨立 Godot4.7.2 source-frame geometry fixture 6 source-shaped actors, two resolutions, actually pressing current/last reserve swaps world party IDs. SUCCESS [#45285924622](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45285924622) (100/100 workflow steps)，但 fixture 合成單色尺寸 source art，非原版真 GPU screenshot。

## ACTUAL R2｜裝備拒絕回報在重建 UI 時消失
- BUG：`_source_page_equipment_selected` 先 `_show_log` 然後 `_show_equipment_candidates`，後者叫 `configure()` 刪掉原 feedback Label。
- FIX `57d8cdda8f242e5fa808768d49cc3ed45989682c`：先重新建 candidate page 再顯示拒絕。已由 `test_fs_p538d_original_party_slots.gd` 真 native 原始 callback 路徑測試「頁面重繪後仍 visible 且包含拒絕」，並確認隊伍未被重置。PASS final #45285924622。

## ACTUAL R3｜離線稽核自身 false positive
- 首次跑 offline RGBA 比對腳本，`ImageChops.difference(...).putalpha(inverted_mask).getbbox()` 將「RGB全為0但 alpha 非0」誤判為外部像素變動，FAIL 並發現原因是 QA 比對方式。
- 修正稽核為 RGB difference 乘上 slot 區外的 inverse mask，不把不相關 alpha 當像素差；source art 套用 2 套 original actor PNG 實測 slot 外 **0 變動**；原 Reserve title 像素保持精準一致。此為離線 source pixel gate PASS，不是 engine GPU PASS。

## Truthful official tests
- Full native at source code/head `da785dc4f13f954e529e9b792bd2c213f746387b` #45285372065 SUCCESS 100/100, includes new P538D test.
- Full native **after** private capture harness commit `ea4975a9159d38b636b1df9ce8256b9a5781cfed` [#45285924622](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45285924622) SUCCESS 100/100. The owner-private capture harness was committed but **NOT RUN**; merely passing regular public CI does not prove original sprite capture.
- Private source art: new ZIP [Owner-only P538D source formation audit](https://drive.google.com/file/d/1MIPFJVDgHMcI3DILgGIgvIaOSkoACblQ/view), 421,290 bytes; SHA `119d7bf30e5e1df4f68f2cb66dd8964a33f9eeb51da26005ba694d0d48e1ae8c` verified by real Drive download and ZIP CRC. `shared=false`. Contains 2 separate party lineups, 544 source-native pixel compositions, 1088 offline nearest-neighbor enlarged references, source boundary reference, manifest and THIS IS OFFLINE warnings.
- No invented GODOT native failed screenshot in this cycle; Godot image capture of original PRIVATE 202 sprites remains **NOT RUN / HOLD**, VX same-state/source Windowskin comparison, 505 effective RGSS2 aliases and 11-table postApply boot-final witness, RX6700XT physical P538D screen, user art acceptance all HOLD. Phase1 SEAL NO.
- Godot Linux binary absent from ChatGPT isolated environment; external GitHub release DNS fetch unavailable. No private art in public CI. No Codex, Desktop Remote, PC Bridge, Windows PC file writes or new tools installed; original source SHA-locked and preserved private Drive.
