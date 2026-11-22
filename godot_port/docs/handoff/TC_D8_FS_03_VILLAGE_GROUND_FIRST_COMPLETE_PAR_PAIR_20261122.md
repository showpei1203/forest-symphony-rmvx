# Forest Symphony｜T-C D8｜星井綠洲 Ground-first＋完整透明 PAR 配對｜2026-11-22

## 執行結果

**FS_03_VILLAGE 星井綠洲**：D7 Ground 保持不變、D8 真正獨立新生成透明 `CompletePAR`，兩張來源原始畫布 **1477×1065**，相同中心裁切 `(98,68,1378,996)` 成 **1280×928、40×29 格**。Pillow 真 Alpha 合成 PASS，**但 Ground 地表純度、PAR 邊界、部分建築落點與低 Alpha 噪點尚未正式美術驗收：ART HOLD**。Godot 4.7.2 真原生 GPU **NOT_RUN**，不能借 C8/D1 舊測試冒充。

### 製作規則

遵照使用者 Drive 規定：**先獨立生成整張 Ground，Ground 完成再生成包含全部非地表物件的獨立透明 PAR**。PAR 包括完整砂岩屋、棕櫚樹、布棚、路燈、岩柱、圍籬、水井、旗幟、雜物；非地表與是否會遮擋玩家無關。完全沒有從 Master 逆向挖像素；沒有先判角色遮擋再抽樹冠／屋簷。僅供 QA 才將 Ground+PAR 合成預覽。

### 實際來源、世界尺寸和位元組

- D7 Ground 新生圖：原始 `1477×1065 RGB` SHA256 `8f8c0ac66359bf8bc47e00beb889a4e66c5f2c9d339b00f9cf05957818556f91`；來源凍結後不變。
- D8 **獨立生成沙漠 PAR 原始 `1477×1065 RGBA`**，SHA256 `47e3225ddb6399b19647265220783197d06d57729e15c4ca13a2fbf182929988`；真的有 alpha=0 背景，和前兩次冰雪錯圖、無透明錯圖有重大區別。
- 兩張圖均一同精確裁 `[98,68,1378,996]`，無重採樣，世界尺寸 `1280×928／40×29 @32px`。
- 實際 Ground output SHA256 `ac3688112874cd45a38f484b8c37dbc0b8f6abd41b67cc0c578bc95f0935aa97`，與 D7 前一輪完全一致（真正 source-lock）。
- 真原始 PAR crop SHA `4fe7eacf0ba79f123963de2d03e15d14f4e2980287c0213d6744d3833c78c4b6`；clean-alpha 候選 `16e9b4ba8ecf201fd43185ac7092fe1603433069b86eb1ecc213797b696f85f2`。
- 真 Ground+RAW PAR composite SHA `f20dc99a6019bfa08a53ff5659bba5e92ec1e107fe2cf37ee0bc0f8a00b3e8c5`；CLEAN composite SHA `bd616d80613727233037b6c5f4baf28e22d009772ff979fc3147afa1eda757ba`。比較圖與兩張來源不同，沒有重新生完整 Master 充當圖層。
- 為保存未裁物件原貌，另保存同一原來源僅 `(0,0,1472,1056)` 裁切的 `46×33／1472×1056` 參考版本，**不會把這張改成 FS_03_VILLAGE 正式尺寸**，正式村落目標仍 40×29。

## 可驗 QA 與 Failure Log

| 檢查 | 真結果 |
|---|---|
| 先生成 Ground、再生成 PAR | PASS（不同實際生圖來源，SHA 已鎖） |
| 真 RGBA 透明 PNG | PASS，crop 後 alpha=0 有 **548,678 pixels** |
| 紅藍地形身份錯誤 | PASS，這次確實是黃金沙丘，不是錯誤冰雪 |
| 1280×928 兩圖同源世界座標裁切 | PASS（原圖都是 1477×1065；同 ROI） |
| 原始完整 PAR 類別目視 | PASS_CANDIDATE，完整屋、樹、帳篷、水井、燈柱；**非逐物件 manifest 資料核對** |
| Alpha 原生純度 | **HOLD**：alpha1..8 **185,051** pixels；alpha240..254 **357,713** pixels；alpha255只有206。另存技術清理版 alpha≤8→0、alpha≥240→255，RGB 位元組不動，原始 PNG 永不覆寫 |
| 40×29 世界裁邊 | **HOLD**：PAR alpha≥225 上402、下164、左485、右265 pixels，部分完整物件可能被切斷；46×33 參考版本保留原場景構圖 |
| Ground 作者地表純度 | **HOLD**：D7 新 Ground 已有直立砂岩崖壁／大型灌木，和「所有非 Ground 物件都在 PAR」嚴格規則衝突；需要下一次全圖 Ground-only 正確生成，不以局部挖遮罩解決 |
| 真角色前後、碰撞、門口／地形通行 | NOT_TESTED，後續系統不用阻礙本輪產圖，但正式封版要另驗 |
| 真 Godot 4.7.2 GPU／1× | **NOT_RUN**；此環境無 Godot binary 且不能連 Github release，不能臆測 PASS |
| 正式 Art Seal | **HOLD，六地形十二圖 0／12** |

## 私人 Drive WRITE → READBACK

1. **[D8 完整十三檔原始來源＋Ground＋PAR＋完整合成＋46×33 參考＋QA／Failure Log ZIP](https://drive.google.com/file/d/1SO1aVJu3KNDZIlAmgcOHc5nosSwJ0Q4w/view)**，**25,638,287 bytes**，13 entries，ZIP CRC PASS，SHA256 `84cdd9771c8fd2ebaf68378b218fcee324c79f7b5fa0c0159797777cfc5d9410`。
2. [D8 PAR 真原始 RGBA 1280×928](https://drive.google.com/file/d/1ojHRduBZIFyyys21Fz8irKNTLNV3I3C5/view)，1,525,635 bytes。
3. [D8 PAR Alpha 清理候選](https://drive.google.com/file/d/18v6Tnr-vomNMVgyUGjQz2LVLZF6lssez/view)，1,449,905 bytes。
4. [Ground＋PAR 清理後真合成 40×29](https://drive.google.com/file/d/1eJPmH9j4c_DjkKM8Bkx2bRQmzGznObfU/view)，2,515,700 bytes。
5. [46×33 參考構圖，不是正式世界大小](https://drive.google.com/file/d/1Zet8TxzEEYDg_NjWac-apIo6UJvExj0G/view)，3,256,409 bytes。

五檔 Google Drive metadata API 已獨立 readback **shared=false、user owner-only**；正式 PNG 封包與 QA 長期保存在私人 Drive。只在 GitHub 分支 `feat/fs-pixellab-tc-map-20261121` 寫此文字、stage tracking，不公開私有 PNG，不連接使用者 PC。

## 下一張圖

完成 03 風蝕金砂同系的 **FS_03_MAZE「風沙裂谷」**：一張全新**曲折砂岩峽谷路網純 Ground**（不是把星井綠洲十字廣場重塗），再以同一 scene Blueprint 生成全非地表立體岩柱、棕櫚、石崖、橋、遺跡透明 PAR。大型迷宮正式標準 80×58，不能直接拿 46×33 拉伸冒充原生美術。04～06 地形依 World Bible 順序。所有新圖仍須 source SHA、owner-only Drive、QA、Failure Log、Handoff、Linear SHO-39。

**最重要的流程不能又被推翻：Ground-only 先畫，CompletePAR 放所有非地表，不判斷誰遮住角色。**
