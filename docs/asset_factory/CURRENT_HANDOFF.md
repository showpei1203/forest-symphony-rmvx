# FS AI Asset Factory CURRENT_HANDOFF — A11-M1/M2/S1（2026-11-08）

**現行規則只有 [ACTIVE_MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)**，本檔僅記錄真實進度和下一個實驗。A10 已有四圖與獨立來源組件候選，歷史 QA 不覆寫或刪除。PR #15 繼續 Draft，不合併 main。

## 1. A11 已真實產出（非新單張 AI 美術）
已直接從**既有真正封存** `FS_MASTERFIRST_V3_NATIVE_GROUND_PAR_COLLISION_QA_20261107.zip` 取出美術豐富的 1280×928 Master，並沿用 A62 已核准 45° Actor F0 作轉換基準，沒有重新生成任一來源美術。
- Master 檔原 PNG SHA256 `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530`，`Runtime_FullGround` **PNG 檔案二進位一致**。
- `M1_RUNTIME_PAR_TWO_CANOPY_SEMANTIC_DRAFT.png` 使用既有 V3 的**兩處樹冠提議遮罩**作 Alpha，88,655 個前景像素，真正 RGB 直接從 Master 相同世界 XY 取樣，位移與 RGB 不一致為 0。
- `M2_COMBINED_TWO_CANOPIES_PLUS_BRIDGE_PAR_DRAFT.png` 新增用物件語意向量繪出的**近側橋欄**提案，合計 90,076 Alpha 像素，Master 同 XY 的 RGB 不一致 0。
- **橋欄反證**：保守標定的橋面核心負例 ROI 上，A06 舊橋欄提案有 **494** 個污染像素，A11 新橋欄提案為 **0**。但新橋欄線條仍有漏描／偏差，這只是保守 ROI，**不能宣稱整座橋的語意成功**。
- 人物橋上 OFF/ON 只是 Pillow 模擬（僅供看層次），不是 RPG Maker VX Game.exe 或 Switch203 真實測試。
- V3 舊 Authoring GroundOnly+CompletePAR 在本次 Master 上重組 0 差異，但它們沿用**舊 Authoring DRAFT**，不是全新的精準分層作品。

**Sprite S1**：
- A62 已核准 Actor F0 48×48 真 PNG SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`；直接複製，不改 F0。
- **新** Waiting 3 姿勢 48×48 + GIF，播放 `0,1,0,2`。由相同 F0 像素色盤做整數位移，3 幀與原 F0 差異 0／407／381 像素；Alpha IoU 1／0.8893／0.8896。這是限制條件實驗，非高品質 AI 逐姿勢重繪，**不可以宣稱 Waiting 自然度或美術通過**。已核准 A62 Run 原 strip 僅是動作參考，本輪沒有新 Run。

## 2. 真正私人交付，GitHub 公開方法
Owner-only Google Drive Binaries 檔案：
`FS_A11_MASTER_F0_TRANSLATION_PILOT_20261108.zip`；
**19,807,540 bytes／32 檔／SHA256 `3131fc99ba5d19f5d6328cfd43068ebea2ddda2d50486576b430df71fe7bc910`**；
已上傳＋重新下載＋SHA256、CRC、數量回讀一致，shared=false／owner only。ZIP 含真 PNG/GIF、QA JSON、反例視覺比較、三支可在隔離環境重新跑的完整 Python 腳本，並通過另一個輸出資料夾的確定性冷重跑檔案位元比對。**公開 GitHub 不張貼私人圖像或雲端 ZIP ID**。

GitHub 公開模組：`tools/asset_factory/a11_master_f0_transform.py`；負向測試 `tools/asset_factory/tests/test_a11_master_f0_transform.py`；真實 QA [A11 實料報告](A11_REAL_MASTER_F0_TRANSLATION_PILOT_QA_20261108.md)；機器收據 [FS_A11_M1_M2_S1_SOURCE_PRESERVATION_RECEIPT.json](../../config/asset_factory/FS_A11_M1_M2_S1_SOURCE_PRESERVATION_RECEIPT.json)。

## 3. Gate：不要把工程數據當藝術成功
- SOURCE_SNAPSHOT: **PASS**，原始美術 PNG SHA 鎖定且未改。
- COORDINATE_SOURCE_PAR_RGB: **PASS**，前景保留原世界座標，來源 RGB 誤差 0。
- SEMANTIC MASK：**PARTIAL / ART HOLD**。V3 樹冠 MASK 原就是舊提案；新橋欄仍不精準，僅「保守橋面負例」無污染。
- SPRITE F0 SOURCE + PALETTE：**PASS**；NEW WAITING motion / ART：**PENDING**，不夠替代真正姿勢重繪。
- Native PMD Actor Tankentai、VX Game.exe、Switch203、正式碰撞/合法足點：**NOT_RUN**。
- Paid PixelLab calls 0、New Orca agents 0、使用者 PC 新工作檔 0、Formal Seal NO。main 未改，僅 PR #15 Draft。

## 4. A11 下一件真正高價值工作
1. **M-A 語意物件遮罩標準化**：AI/工具以高品質 Master 為不動 RGB 唯一權威，產出屋簷、樹冠、前側橋欄等正確來源 Mask/合法 footpoint，尤其需要「橋面不可遮擋」負例；優先整個物件模板，而不是再局部修木條像素。此輪 M2 向量 mask 還不具藝術可用性。
2. **S-A 真正重繪動作**：F0/物種身份鎖定後，從 rig 姿勢生成 Run/Waiting 候選再以 AI 重繪角色材質，不是把全圖向左向右挪一格。需使用者對 1x 姿勢連貫性 ART 驗收，並對 PMD 檢查原生 AnimData.xml 不同幀數。
3. 第二個不同完整 Master/F0 做同模板跨素材試驗，計算先前問題是否可**重現地**消除。
4. VX Game.exe 原生需要使用者明確授權隔離臨時範圍、清理方式，禁止動 main／封版資產。
5. 新成果依舊：私人圖片 ZIP → Drive owner-only 並回讀 SHA，公開程式/QA → PR #15，更新這份 CURRENT_HANDOFF；規則未變不再擴寫 ACTIVE_MASTER。不要宣稱 CI 代表美術。

**上一階段 A10 歷史成果**：完整報告 [A10 真實四圖兩場景 QA](A10_REAL_FOUR_LAYER_TWO_SCENES_AND_ACTOR_QA_20261108.md)，私有封包 SHAs 原紀錄保留。A10 ELF ART PENDING、FOREST_BRIDGE ART FAIL_STYLE；A11 這輪未直接改善或封版它們。
