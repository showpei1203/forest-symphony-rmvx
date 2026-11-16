# FS A27｜真實 A21 地圖：語意／逐列深度遮擋實作與交接（2026-11-13）

狀態：**REAL INPUT / SOURCE BYTE PASS / STATIC QA PASS / ART HOLD / NATIVE VX NOT_RUN / FORMAL SEAL NO**。
唯一方法權威仍是 `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md` v1.1；本文件是測試證據與 Handoff，不覆寫規則。`main`、A36F／正式封版及私人來源均未修改。

## 一、本輪真正執行的程式

- `tools/asset_factory/a27_semantic_depth_occlusion.py`：在 A21 原始「同一世界 XY 像素複製」思想上，加上**真實來源遮罩、每個物件的畫面 Y 深度梯度提示、角色實際不透明輪廓與前後腳點條件**。回傳**原始 master PNG bytes**、每角色狀態對應的 Runtime PAR PNG、Pillow 畫面與 QA JSON；不能由相同 RGB 判斷物件身份。
- `tools/asset_factory/tests/test_a27_semantic_depth_occlusion.py`：18 個獨立 synthetic 正反案例；本輪隔離 Python 執行環境 18/18 PASS（不等於雲端 CI 或遊戲執行）。包含同 XY 原像素／Source SHA、錯誤物件語意、遮罩交疊、假 alpha、禁止地面／橋面區域、角色腳位與 x 範圍驗證，另有屋簷類別的 synthetic 合法案例。
- `tools/asset_factory/a27_real_a21_pilot.py`：真正重新下載 A21／A18 owner-only 原始 ZIP，先 SHA/ZIP CRC 鎖定，再從 A21 existing per-case PAR alpha 還原三種**歷史候選**物件遮罩，執行四站位 A/B 對照，輸出真正 PNG、原 Master/F0、來源 mask、比較圖、固定 F0 的 12 張位置變化 GIF（**不是新角色跑步動畫**），18 個檔案封入私人 ZIP。

技術說明：這是**根據人為明示的 screen-row 深度梯度提示**進行像素選擇，不是從平面 PNG 自動推導出可靠 3D z-buffer。使用 Pixel Plays 的幾何／深度思想，沒有使用其程式碼、畫風或音樂。

## 二、私人真實來源與核對

- A21 檔：`FS_A21_MASTER_OCCLUSION_REAL_INPUT_PILOT_PRIVATE_20261110.zip`，16,615,073 bytes，SHA256 `35a4268baf874c94ac8bd903f362410a8081933fa2d91a324f086908f2008981`，Drive ID `1yExuolr916gR3MAeTxvsT-FHDzUmeCMo`。
- A18 檔：`FS_A18_ACTOR01_RUN_PROVIDER_READY_PRIVATE_20261109.zip`，19,706 bytes，SHA256 `f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c`，Drive ID `1GEAmwpW2iB3ePpUJx2EKUWKlE76IAUAr`。
- Master：`Runtime_FullGround_UNCHANGED.png` 真正 **1280×928**，SHA256 `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530`；A27 Ground 返回原位元組，沒有重新壓縮或重畫。
- 真正 F0：48×48，SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`。
- 三個已知草稿遮罩 alpha 重新抽取：`left_tree_canopy` 33,600 pixels；`right_lower_canopy` 55,055 pixels；`bridge_near_rail` 1,421 pixels。三者互不重疊，合計 90,076 pixels；注意這些仍是 A11/A21 **未獲使用者核准的候選來源**，不是新的 SAM 或準確分割結果。

## 三、四站位真實 PNG A/B 結果

| 情境 | 角色腳點 | A21 舊版遮住角色 pixels | A27 新版遮住角色 pixels | 變化 | Ground | PAR 原 XY RGBA mismatch |
| --- | --- | ---: | ---: | ---: | --- | ---: |
| TREE_BEHIND | (232, 556) | 450 | 197 | -253（-56.2%） | 原 bytes 不變 | 0 |
| TREE_FRONT | (232, 596) | 0 | 0 | 0 | 原 bytes 不變 | 0 |
| BRIDGE_BEHIND | (735, 621) | 137 | 29 | -108（-78.8%） | 原 bytes 不變 | 0 |
| BRIDGE_FRONT | (735, 670) | 0 | 0 | 0 | 原 bytes 不變 | 0 |

**解讀**：遮擋量大幅減少是實際畫面差異，不代表一定更好。Tree Behind A21 的人物幾乎消失；A27 嘗試讓人物上半部露出，保留較少枝葉遮擋。Bridge Behind 的木欄遮擋也變少；這兩個應由使用者看 1x 畫面決定是否真的符合物件前後關係，再調整深度提示數值，不可直接稱作「美術已通過」。

## 四、交付位置與可信度

- 私人完整封包：`FS_A27_REAL_A21_GEOMETRY_DEPTH_PRIVATE_20261113.zip`，**17,412,710 bytes／18 files**，SHA256 `4dcec477b9300270ab4f7a0045fdd15b0c6673316c639fd0628cc899b8c85618`。owner-only Drive ID `1Icj3Zacfvf1WYWdMjZHqkEF3mSK7DNjs`。已實際上傳後重新下載，Size/SHA256/ZIP CRC 回讀 **PASS**。
- 1x 比較圖：`A27_A21_SIDE_BY_SIDE_REAL_INPUT_NOT_VX.png`，owner-only Drive ID `1Za6NOfI_EmIRW780TvLzXjs50ertx4Bx`。
- 所有私人 PNG、GIF、F0 與來源 mask 僅存在私人 Drive ZIP；GitHub 只放 Python 程式、synthetic 測試、文件。不把私人 PNG 或 base64 放公開 PR。
- GitHub：`https://github.com/showpei1203/forest-symphony-rmvx/pull/15`，分支 `feat/fs-asset-factory-v1-20261107`，保持 Draft。每次後續提交都要再查該 HEAD GitHub Actions 真實結果；不能把先前 166/166 直接當本輪 PASS。
- 使用者電腦沒有新增任何成果檔；所有原始真實來源從 Drive 讀入 ChatGPT 隔離環境，雲端封包經 Drive 回讀。付費 PixelLab 呼叫 0。

## 五、明確未完成的工程與 Failure Log

1. **ART HOLD**：A11／A21 地圖本身還不是已獲核准的 FS Ground3 成品；A27 只改善可見的角色遮擋。樹冠露出的頭部／橋木欄前後仍需人工看圖校準。
2. **ROOF REAL NOT_RUN**：本輪 A21 ZIP 沒有獨立屋簷來源遮罩；僅通過屋簷 semantic synthetic 單測。不能拿橋欄當屋簷驗收。
3. **NATIVE VX / Switch203 NOT_RUN**：目前輸出是一個角色在某個腳點對應的**逐角色動態 PAR 預覽**，還沒有真正 RPG Maker VX 的 RGSS2 Sprite/viewport/switch203 融合。**禁止把這些條件式 PAR 當一張永遠啟用的全局 PAR 上線**。需要在 VX 原生 Game.exe 測人物每幀腳點、樹前後、橋前後、屋簷前後及 Collision。
4. **四圖 Authoring 不完整**：本輪只做不動的 FullGround + 逐角色 Runtime PAR；`Authoring_GroundOnly` 與 `Authoring_CompletePAR` 仍須從有來源歸屬的獨立物件建立，不能用這個 runtime preview 冒充完成四圖量產。
5. **不代表泛化成立**：目前深度提示 440/575（左樹）、610/641（橋欄）、700/927（右下樹）是針對 A21 真實現場的候選，不能原封不動套到任何地圖；須建立 object-family calibration 與負例。
6. **不重畫母圖**：若同物件兩次出現遮擋方向錯誤，應回到 source mask/footpoint/depth template，不用重新生成 Master。

## 六、下一輪施工入口

- 本輪確定交付了真實 A21 Ground + 來源分割遮罩 + 條件式 PAR PNG + 1x A/B 比較 + F0 位置測試 GIF；先請使用者看畫面評價 Tree Behind／Bridge Behind 的遮擋。
- 下一工程應針對 FS 已有 Native VX RGSS2／Switch203 的原始腳本建立 **read-only mapping / 獨立測試適配器**，確認是否能做 per-actor 的 PAR 遮擋，而不是只做 Pillow 截圖。如果必須使用使用者 PC Game.exe，需先取得 P0 明確的短暫隔離臨時檔授權。
- 再尋找真正已核准森林／精靈村母圖和可追溯的屋簷遮罩，在不重新畫 Ground 的前提下驗證樹冠＋屋簷；有成品後再評估通用地圖量產。
- 每輪更新 `docs/asset_factory/CURRENT_HANDOFF.md` 頂端，留 failure log、實際 CI 連結及 Drive SHA；不合併正式 main，未通過的 Art/VX 保持 NOT_RUN。

**A27 判定：真正地圖遮擋程式與 PNG Pilot 完成；A/B 技術 QA PASS；ART HOLD；Native VX、Switch203 NOT_RUN；正式封版 NO。**
