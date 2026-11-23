# Forest Symphony｜P538D 真來源編隊槽位、拒絕訊息、雙樣本 QA｜2026-11-24

**Workline:** Godot 4.7.2 主移植 `feature/fs-godot-phase1`；T-A 演出、T-B 怪物、T-C Ground/PAR 各自保留；原 VX 唯讀、不重安裝工具、不動本機 E:。

## M1：實際修改
1. **SOURCE ORIGINAL PARTY artwork defect**：重新打開私人 202 PNG 來源包中的原始 `Graphics/System/MenuBack_party.png` (544×416)，核對其 3 個已繪製數字角色槽，P538C 在 x66/113/160、y103 的通用文字 Button 真正壓在數字框上；Reserve 階段的 VBox 曾從 y333 開始覆蓋美術文字 `Reserve Squad` (約 y328..360)。
2. **SOURCE ART ROUTE FIX** `FSOriginalMenuPage.gd` commit `c193b91a62ec629afb9b97a80d5de41dbcf4f77d`：使用來源槽位候選 Rect `(77,73,41,62)`, `(127,73,41,62)`, `(177,73,41,62)`；真原始對應六位角色 PNG `menu_喬伊/米亞/泰勒/艾薇/薇娜/艾卓` 成為可點選 `TextureButton` 並加選取回饋；不合法/未知角色不亂套原版肖像，保留來源框+文字；後備隊使用 y362 的水平捲動選單，避免擋住原 `Reserve Squad` 字樣。人物圖仍由 `FSUIArtLibrary` 的原版 SHA gate 識別；不公開傳送私有 PNG。
3. **真 UX BUG FIX** `FSScreen.gd` commit `57d8cdda8f242e5fa808768d49cc3ed45989682c`：`_source_page_equipment_selected` 失敗先重建 `equipment_candidates`，再顯示 `_show_log` 的實際拒絕原因。原先先顯示訊息、再重建頁面會把訊息 Label 刪掉，玩家看到無反應。
4. `test_fs_p538d_original_party_slots.gd`（`74d023b`）以 Godot 原生 Control+signal 測試 **6 位不同演員**、3 current/3 reserve 的畫面來源座標、544×416/1088×832、真正按源 TextureButton 選取第一位並按 reserve 第六位交換，`world.party_actor_ids=[6,2,3,4,5,1]`、二次刷新與顯示裝備拒絕、不得重置隊伍。公用 CI fixture 為 synthetic generated-size flat textures，**不是私人原始美術 GPU PASS**。
5. 工作流加入 P538D 官方引擎 gate（commit `da785dc4f13f954e529e9b792bd2c213f746387b`），不移除既有 99 gate。
6. `capture_fs_p538d_private.gd`（commit `ea4975a9159d38b636b1df9ce8256b9a5781cfed`）：**僅供日後原版 PRIVATE Godot 真截圖**，Linux+明確 `FS_PRIVATE_UI_QA=1`、`FS_UI_QA_WIDTH` 544/1088、已存在的獲准私人輸出資料夾、202 SHA 原 PNG+六張肖像檢查；拒絕在 Windows PC 執行或覆蓋舊 QA。每一種尺寸 11 種畫面含 MENU/五子頁/ITEM TARGET/EQUIP候選/六人編隊/選取/備援交換/米亞狀態。**本輪未執行此原圖真截圖程式，僅提交安全可覆核的工具。**

## M2｜官方真 Godot QA
- `test_fs_p538d_original_party_slots.gd` 全部 assertion 通過；完整官方 pinned **Godot 4.7.2 CI** [run #45285372065](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45285372065) 在 `da785dc4f13f954e529e9b792bd2c213f746387b` **100/100 steps SUCCESS**。這是 QA steps，**非 100 個已完成 FS 原版功能**。保留先前 P538A/B/C MENU、Battle、ACT、ATB、地圖、事件、Boss 完整回歸。
- 以上 PASS 包含合成尺寸 Texture 的 source-frame geometry、party actions、denied equipment。**不包括新私有 source-art 的 Godot 原生真畫面**，不能偷換成藝術 PASS。
- 最新 private capture harness commit `ea4975a` 的後續完整 native import/CI status，核查 GitHub Actions 後才註冊，勿引用較早 run 代替。

## M3｜實際失敗
- P538C source UI 的實際遮擋錯誤：文字按鈕擋原版上場欄位，Reserve 行切入原字標；修正 `c193b91a`，來源位置圖實測。
- P538C 裝備拒絕訊息在再次 `configure()` 時被清空：修正 `57d8cdda`，獨立 Godot native 斷言「刷新後顯示拒絕」PASS。
- 私人離線像素 QA 初版 **測試腳本本身 FAIL**：誤用 RGBA 的 getbbox / 反轉 alpha mask，導致即使外區 RGB 差為 0 仍當成變動。修正為 RGB 差值與反選 source slot mask 交集，再算真正外區 bbox；兩套不同角色 source composite 外區像素差 **0**。這是離線稽核程式的錯，不是 Godot RGBA 繪製 bug。
- 本輪 native 公開 CI 首次新增 P538D gate **PASS，沒有虛構引擎 FAIL→FIX**。

## M4｜兩套原始人物 SOURCE 素材、兩個尺寸/真安全儲存
- 直接從 owner-only Drive 真下載原始 202 PNG（archive SHA `c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6`），Python PIL 在隔離空間做**離線**來源座標 QA：第一組喬伊/米亞/泰勒上場、艾薇/薇娜/艾卓候補；第二組上場艾薇/薇娜/艾卓、候補喬伊/米亞/泰勒。每組有 544 候選、1088 兩倍最近鄰參考、來源框選偵錯圖；另外 Before/After、Manifest 檔案 hash、Failure/Hold。原始 `MenuBack_party.png` 在角色槽框外每一個像素 RGBA 精準一致；Reserve title 區不受任何改動。
- PRIVATE Drive 真實 upload + download SHA readback ZIP **421,290 bytes**，SHA256 `119d7bf30e5e1df4f68f2cb66dd8964a33f9eeb51da26005ba694d0d48e1ae8c`，owner-only shared=false：
  https://drive.google.com/file/d/1MIPFJVDgHMcI3DILgGIgvIaOSkoACblQ/view
- **注意**：PIL 產物是來源原始圖畫面合成/座標核對，**不等於 Godot 4.7.2 私人真 GPU 影像**；1088 是離線 NEAREST 放大，不是 1088×832 Godot 真視埠截圖。

## P0／HOLD／下一完整單位
- PRIVATE 202 UI PNG 不寫公開 GitHub，原始 Drive 身份保持；新 GitHub 只有可讀 GDScript/Python 測試與 QA docs。使用者 PC `E:\\` 零新寫入、PC Bridge 零、Codex 零、Desktop Remote 零；工具的 SHA + QA binary 保存在 owner-only Drive。
- 隔離環境沒有可執行 Godot 4.7.2，嘗試從官方 GitHub release URL 取用被沙盒網路 DNS 阻擋；GH-hosted 公開 CI 無權載入 owner-only 真圖，不能把私有 PNG 放上公開倉庫繞過。故 `capture_fs_p538d_private.gd` **NOT RUN／PRIVATE SOURCE ART HOLD**。
- 真 VX 同狀態 1:1 字型/原視窗皮膚/槽位、實機 RX6700XT 現行 P538D 螢幕、RGSS2 505 完整有效方法與 `FS_DB_AUTOSET.apply_all` 後 11 表正式 DB witness **HOLD**；SOURCE ART Gate HOLD；PHASE 1 SEAL NO。
- **下一單位 P538E**：取得已授權同時具 source-original 和 official Godot 4.7.2 的私人隔離 GPU 環境時，明確 544/1088 跑 `capture_fs_p538d_private.gd` → 私人 Drive 22 張真引擎視埠+manifest/hash → VX 同狀態 UI/Skin 對照；平行取得 postApply 11 表實際 VX boot-final witness，然後才解除完整來源相容 HOLD。不得在沒有事前許可下把 GH PC Bridge 的 T-A 白名單用來執行 Godot 主線。
