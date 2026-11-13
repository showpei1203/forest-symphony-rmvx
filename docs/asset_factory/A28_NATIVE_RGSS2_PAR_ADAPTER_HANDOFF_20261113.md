# FS A28｜真實 Ground/遮擋 PNG → RGSS2 逐角色覆蓋適配器（2026-11-13）

**本輪結論：** REAL SOURCE INPUT PASS；CROPPED PAR OUTPUT PASS；A27 FOUR-CASE RUBY PIXEL PARITY PASS；RGSS2 HOOK MOCK PASS；VX Game.exe **NOT_RUN**；Switch203 **NOT_CONNECTED**；ART **HOLD**；FORMAL SEAL **NO**。請勿把沙盒 Ruby Mock 冒稱原生 VX 實機證據。

## 1. 為何實作這條路線

A27 的每站位 Runtime PAR 只填入角色輪廓範圍（例如左樹後 197 pixel）。這種 per-character PAR **不能直接當成一張固定的全局 PAR** 上線，否則玩家走到物件前面仍被遮住。A28 的核心是 **保留 A21 原始完整 Master Ground、把同源 PAR 物件裁為僅含該物件的 RGBA 小圖，並在 Sprite_Character 的角色畫格局部繪出角色後面應有的遮擋像素**。絕不重新畫地圖，不能套用 Pixel Plays 的 30 度造型。

## 2. 實際可交付程式與私人圖像

Public GitHub Draft PR #15（不碰 main）：
- `tools/asset_factory/rgss2/FS_A28_RUNTIME_OCCLUSION_EXPERIMENTAL.rb`：**Ruby 1.8 oriented / opt-in disabled** 的 Sprite_Character overlay（`update`、`dispose` alias）；使用 `Cache.parallax` 同源物件裁圖；逐畫格 Actor Alpha＋世界座標＋逐列深度提示比較；裁圖坐標、`display_x/y` 轉換及 overlay z，避免角色前方被全局 PAR 強制覆蓋；只在位置/畫格改變時重繪。
- `tools/asset_factory/a28_export_source_locked_par.py`：驗證 A27 ZIP SHA、Master SHA、F0 SHA、ZIP CRC，從真實 1280×928 Master 對三個 source-provenance 遮罩做**保原始 RGB / Alpha 的世界同座標裁切**；並建立四組私人 A27 影像 x Ruby paint! 對照 fixture。
- `tools/asset_factory/tests/test_fs_a28_rgss2_adapter.rb`：12 synthetic cases ＋ 1 private real replay（沒有私人 fixture 時自動 SKIP）；驗證來源 pixel、半開邊界、foot/depth、alpha、異常、禁用預設。
- `tools/asset_factory/tests/test_fs_a28_rgss2_runtime_mock.rb`：6 個 Ruby 類 RGSS2 mock 行為（繪圖初始化、場景捲動保持世界一致、map switch hide、tile char skip、Bitmap/overlay dispose、未知 map fail closed）。**只是 mock，不是跑真正 Game.exe**。

Private owner-only Drive A28 ZIP：

- Drive owner-only: https://drive.google.com/file/d/1epHrNLXsXSW-9GH0n0O8wUug6NdTZjAC/view
- 7 files; 829,396 bytes; SHA256 `bb3757f4e5a69eb0954b5c8f0176bfcdeff58c0aef6f8c4e84a53ca5a8f92177`; upload → download → size/SHA/ZIP CRC **PASS**。
- Public GitHub PR #15 retains code / tests; private PNG/cross-language fixture remain Drive-only。
- `FS_A28_LEFT_TREE.png`，世界原點 (75,413)、尺寸 360×138，來源 33,600 α pixels。
- `FS_A28_RIGHT_TREE.png`，世界原點 (1039,645)、尺寸 241×283，來源 55,055 α pixels。
- `FS_A28_BRIDGE_RAIL.png`，世界原點 (667,582)、尺寸 106×72，來源 1,421 α pixels。
- 私人四案例 RGBA pixel fixture、QA manifest、兩角色同圖示例 PNG（**Pillow simulation not VX**）。不把任何真實來源像素、base64、私人 fixture 公開推 GitHub。

## 3. 實際驗證（Cloud/isolated）

原 A27 Archive SHA256 `4dcec477b9300270ab4f7a0045fdd15b0c6673316c639fd0628cc899b8c85618`、Master PNG SHA256 `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530`、F0 PNG SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，核對通過。

| 真實 A27 站位 | A27 Alpha | A28 演算法 Python 複驗 | Ruby 從真實像素重播 |
| --- | ---: | ---: | --- |
| TREE_BEHIND | 197 | 197 | **逐像素 SHA256 等於 A27** |
| TREE_FRONT | 0 | 0 | **逐像素 SHA256 等於 A27** |
| BRIDGE_BEHIND | 29 | 29 | **逐像素 SHA256 等於 A27** |
| BRIDGE_FRONT | 0 | 0 | **逐像素 SHA256 等於 A27** |

- 原本 Master 沒有重新壓縮或改色。裁切層的所有非透明 RGBA 均來自原 Master 的同世界 XY。左樹、右樹、橋欄的裁切 mask 無互相重疊。
- Ruby 3.3.8 沙盒執行 `ruby -c` **Syntax OK**；兩份 Ruby 單測合計 **19 tests，36 assertions，0 failures**，其中真實 4 案例內容受私人來源鎖定；這不代表 Ruby 1.8 RGSS2 的真正引擎能正確解譯、負載順序安全，或 FPS 達標。
- 兩角色在同一森林區的 PNG 測試已輸出，但用 Pillow 模擬，**非 Game.exe 畫面**。
- GitHub [A28 Ruby synthetic CI run 43424236999](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43424236999) **completed/success**；[FS Factory CI run 43424236992](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43424236992) **completed/success**。以上均不是 Game.exe 測試。

## 4. 重要技術／美術 HOLD

1. **FS Native Game.exe / scripts 未驗證**：尚未以真正 FS `Scripts.rvdata` 確認 Sprite_Character alias 順序、map_id、World XY 原點、scroll 算法、Viewport z／tone、Switch203 開關、原 PAR 初始化。不得在正式專案中打開 `ENABLED`。`MAP_ID=0`、`ENABLED=false` 兩層 fail closed。
2. **真實屋簷資料缺失**：A27 ZIP 只有兩個樹冠及橋欄。屋簷類別不能拿橋欄代替驗收，也不能宣稱已完成精靈村。
3. **原地圖 ART HOLD**：A21/ A27 樹蔭後的白髮人物有可見「只剩頭」的視覺風險；未經使用者批准前不要叫做美術完成。
4. **效能 HOLD**：暫以 `get_pixel`逐角色輸出局部覆蓋，每個角色最高角色 cell 像素數次的 RGBA 讀取，更新關鍵幀才重繪。未測真實 RGSS2 FPS、NPC 多數量、畫面大小與事件破壞性腳本。
5. **四圖 Authoring 未完成**：本階段產出 Runtime FullGround 同源對應的「裁切物件前景」，尚未重建可做素材編輯的 Authoring GroundOnly／CompletePAR；不能把三張裁圖當作完整四圖完成。
6. **封版與使用者 PC 保護**：僅在 ChatGPT 隔離環境與 private Drive／GitHub Draft；沒有碰使用者 PC 或 Game.exe。本次禁止直接啟用任何自動部署。

## 5. 下一個最短施工 Handoff

- 先讀 `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md` v1.1、P0、`docs/asset_factory/CURRENT_HANDOFF.md` 頂端與本檔。原 A21/27 的實際驗證需保留，不要覆寫。
- 待實際取得原 FS `Scripts.rvdata` / PAR 載入位置後，**唯讀解出 map display_x/y、Sprite_Character、Switch203 真正用途、場景地圖 ID**；對應實際腳本後做一個經授權的**隔離 VX Game.exe 小地圖**，不再修改正式 Scripts.rvdata。
- 用兩個移動中的人物測同樹前/後、橋前/後、另一個 NPC 及一個屋簷真正來源，確認視角、穿模、fps、地圖捲動；失敗停在適配器層，不退回重畫整張 Master。
- Ground/屋簷來源若未真正達到 Ground3 美術，仍維持 ART HOLD。以真正遊戲截圖和使用者驗收決定量產，不以 synthetic PASS 取代。
