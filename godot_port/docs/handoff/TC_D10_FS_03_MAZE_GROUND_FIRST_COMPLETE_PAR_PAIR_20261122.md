# Forest Symphony｜T-C D10｜風沙裂谷 Ground-first → 真透明 CompletePAR 成功配對｜2026-11-22

**狀態：FS_03_MAZE 本輪首次成功產出真正獨立透明 RGBA CompletePAR、與 D9 已鎖定 Ground 合成 1472×1056／46×33 來源候選；STATIC COMPOSITE PASS，但源物件在原地貌的橋樑／道路對位、透明雜點、正式 80×58 尺寸仍 ART HOLD。Godot 4.7.2 NATIVE NOT_RUN；12 張正式 Art-Sealed 仍 0／12。**

## Ground-first 全景來源及實際新生成 PAR

- Ground **不重畫也不覆寫**：D9 原獨立 Ground 1477×1065 RGB SHA256 `b9ddee18bf3eb4386363a2d6321b0ad745c64cb1149b862489d4160defaa9e59`。同樣 crop `[2,4,1474,1060]` 之 46×33 Ground SHA `2e78610422ff373f07382b2bcb4980d3f11bf63c3e078cf489e2bc42f55b66fd`（和 D9 完全一致）。
- D10 新真正 image-generated **全非地表 PAR**：1477×1065 RGBA，獨立原來源 SHA `2c71dae5d32b9ff0465d9863f5de74fc6561f58e6f1e84f00141696cd4426768`；含整棵棕櫚、砂岩立柱、石拱、吊橋、遺跡、仙人掌、枯木、化石、旗幟與附屬岩塊，**不按角色遮擋挑選 PAR 物件**，沒有從 Master 反向裁層。
- Ground 與 PAR 各自原畫布都是 1477×1065，均採 **同一原像素 crop [2,4,1474,1060]** 得 1472×1056，即 46×33 @32px；原圖完全不插值、不變形。完整合成圖是供視覺 QA 的衍生預覽，不取代兩張可編輯來源 PNG。
- 原始 cropped PAR SHA `811cebe3a1e57b9fd470e412dbd382e8310e5e4ace536bdb7ec1be146ce5cb37`；透明 Alpha 技術清理候選 SHA `149bee6b2d3ed8b2b6687fbd769523908a2e885610d5774205904843a351a174`；RAW RGB 合成 SHA `12a5a7adbd72d804b9ac90eaa11f2fa664ab1dfae50ed9b0e38957f0b044261b`；CLEAN RGB 合成 SHA `873303bdd35095ab230c0f7ac07355b957b146cb0fa6e64217337e3bed50a169`。

## 真實 QA、風險與 Failure Log

- 本輪新 PAR 不再是 D9 的三張 RGBA 假透明完整 Master（各 alpha0=0），而是**真正透明背景**：裁切 46×33 RGBA 有 **883,411 pixels alpha=0**、**206,896 alpha1..8** 雜色、**99,040 alpha9..239**、**364,768 alpha240..254**、**317 alpha255**。技術 clean 候選只對 alpha≤8 歸 0、alpha≥240 歸 255，**不改 RGB、不覆寫原圖**。
- PIL `Image.alpha_composite(GROUND, PAR)` 真實繪製 RAW + CLEAN 兩個版本，合成圖重新讀回逐像素一致 **PASS**。透明背景 checkerboard PAR 可辨識所有非地表物件真實覆蓋，而非貼一張全地圖海報。
- **Art HOLD：真正獨立生成不保證世界座標語義對位。** 雖兩張 PNG 原畫布、crop 完全一致，局部吊橋與石拱不一定剛好跨過原 Ground 的裂谷或接續道路；完成版應檢查橋兩端地面落點與中心走道。這是全圖 Scene Blueprint/source reference 問題，**不要退回逐棵樹／局部角色遮蔽修理**。
- **裁邊阻斷**：PAR alpha≥225 來源觸邊像素 top250/bottom461/left319/right688，可能截斷完整非地表物件。原 Ground 自身也有部分直立砂岩崖壁混在地表層，嚴格 Ground-only 語意需重新審核。不能當作正式 Art-Sealed。
- **世界正式尺寸**：FS_03_MAZE 原規則 **80×58／2560×1856 @32px**；本次是 46×33 **來源候選**。禁止 nearest 放大這張小圖充當原生正式迷宮。Godot4.7.2 真 GPU NATIVE 本輪 **NOT_RUN**，不可借 D1/C8 綠燈宣稱 D10 過關。

## 私人 Google Drive 真實 WRITE→READBACK

- **[完整十檔 Ground／原始透明 PAR／清理版／RAW+CLEAN 合成／四圖對照／源 SHA／QA ZIP](https://drive.google.com/file/d/1JG8UpKDYCvMlxWghZSxxk1sKvnlvdpxa/view)**，**20,827,804 bytes**、**10 entries ZIP CRC PASS**，SHA256 `eaca8acea98383897433cbdc21c5c14b96f97ac611c93184566dd30bc655c2d0`。
- [原始真透明 CompletePAR](https://drive.google.com/file/d/182WGOsWuA0cPO106lLS1I2O3uq9hTCqI/view)、[Alpha 技術 clean 版](https://drive.google.com/file/d/1x0AoC0-qJy3N2Q34WMcs6C7KXEWyfftf/view)、[真 Ground+PAR 合成](https://drive.google.com/file/d/1jhTW5JeNQkjRJY-r0B1tfXqAFD4bXTIL/view)、[Ground／PAR／兩版合成四圖對照](https://drive.google.com/file/d/1ykZHCfxt9mm-eSMFrIAkmk7hl_x1_8WM/view)。
- 上述五項 Google Drive metadata 寫入後 readback 均 **shared=false、permissions user owner only**。只有 GitHub 文字 QA、Blueprint、Handoff 與 workflow；私有 PNG 留 Drive，不碰使用者 PC。

## 12-map 後續施工單位

先保留 D10 成功的**真兩圖原生可合成流程**，讓下一次新模型能根據鎖定 Ground 的同一 World Blueprint/Style 生成完整透明 PAR，並明確錨定橋樑／遺跡／道路落點。對正式迷宮以原生 80×58 輸出，不能重新開始局部遮蔽。

下一批地形按原 Drive 世界設定：**04 赤焰火山（FS_04_VILLAGE 灰鑄工坊城 → FS_04_MAZE 熔脈裂橋）、05 幽霧水澤、06 星晶浮島**，每張 Ground-first → 所有非地表 CompletePAR，ART Gate 與 Godot Native 各自驗收。正式 12圖 Art pass 目前仍 **0/12**。
