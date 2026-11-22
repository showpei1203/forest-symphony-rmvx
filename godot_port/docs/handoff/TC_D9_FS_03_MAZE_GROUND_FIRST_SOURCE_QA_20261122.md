# Forest Symphony｜T-C D9｜FS_03_MAZE 風沙裂谷 Ground-first 來源與 PAR 阻斷｜2026-11-22

**最新實作狀態：新 Ground-first 砂谷迷宮真來源已獨立產出，原圖與 46×33 原像素來源候選已存私人 Google Drive；完整 PAR 尚未成功。正式 80×58/2560×1856 未達成，Godot 4.7.2 native NOT_RUN，正式 ART HOLD。**

## 使用者批准的不可變規則

- **Ground 先獨立生成完整地表**，然後**PAR 獨立產生所有非 Ground 物件**。PAR 包含岩柱、完整棕櫚與仙人掌、拱門、木橋、遺跡、立體岩塊等，**不依角色遮蔽與否挑選**。
- 不以 Master 反向裁層；不借用別的村莊或雪原圖，不以圖片內的「PASS」字樣作為 QA 證明。
- 正式場景名稱 FS_03_MAZE 風沙裂谷（風蝕金砂），正式尺寸 **80×58 tiles @32px = 2560×1856**。目前只能將較小新來源標為 ART CANDIDATE。

## 本輪真獨立 Ground 圖片

- D9 首次正確生成**沒有房屋、市集、噴泉與棕櫚**的砂岩路網：蜿蜒岔路、環狀通道、沙丘、裂紋、石板地貌。
- 原始 PNG **1477×1065 RGB** SHA256 `b9ddee18bf3eb4386363a2d6321b0ad745c64cb1149b862489d4160defaa9e59`。
- 不重新插值、不拉伸：從原始圖精確 crop **[2,4,1474,1060]**，得到 **1472×1056（46×33 tiles）** 候選 Ground，SHA256 `2e78610422ff373f07382b2bcb4980d3f11bf63c3e078cf489e2bc42f55b66fd`。
- 另保存 32px Grid QA （格線未寫入真 Ground）與 half-size 預覽（不等於原始解析度）。
- **美術來源仍 ART HOLD**：砂岩地形中的崖壁帶有立體側面，可能違反「所有非地表都在 PAR」，須對原生 Ground 圖層語意另行審核；正式迷宮尺寸仍未符合 80×58。

## 3 次失敗 PAR 的真像素驗證

三次 PAR 生成皆返回 1477×1065 **完整合成地圖**，而不是不含地面的真 RGBA 完整非地表 layer，不從這些錯誤圖片反切物件：

| 嘗試 | 原圖 SHA256 | 影像格式 | Alpha 極值 | alpha=0 像素 | 結論 |
|---|---|---|---|---|---|
| D9-a | `982c44b760fc5ec6f6c143cdd70d31ccd59bec54f0f2556837fcd915e6384206` | RGBA 1477×1065 | 205..249 | 0 | REJECT |
| D9-b | `29308ff1cae4bb0244ba37fddea1948165e1c22b0912f5c54642f08d865414f1` | RGBA 1477×1065 | 181..248 | 0 | REJECT |
| D9-c | `40baccf00f8ef8c6569f4378f9389a26c332d03c19c3f81778d68497740b7e67` | RGBA 1477×1065 | 214..249 | 0 | REJECT |

即使 RGBA 形式存在，也不代表真透明圖層；**此三次所有像素都非完全透明**，另含地面、峽谷、河流、洞窟及橋樑等完整場景，無法與 locked Ground 正確對位。因而 PAR = **NOT_GENERATED**，Ground+PAR native/composite 未進行。拒收圖只留下 SHA／形式／失敗原因，不把它們混進私人正式 PAR 資產。

## 私人 Google Drive WRITE→READBACK

- **[D9 原圖／46×33 Ground／Grid QA／Failure Log 與來源 JSON 六檔 ZIP](https://drive.google.com/file/d/1HC6r2i0Dcd3mLizGZRG9HzGUtMSh8Yc4/view)**，10,819,294 bytes、6 entries ZIP CRC PASS，SHA256 `3cf8250c084b9498233748eccaff664b9bfd1f63a50976ddbbf5ad6bc56c5227`。
- **[D9 原始 Ground RGB](https://drive.google.com/file/d/1LUumF1zF--hjBfREqpAlNoMUHQtbzMs-/view)**，3,530,740 bytes。
- **[D9 Ground 46×33 原像素候選](https://drive.google.com/file/d/1KoPtJ47HDSDtYEmt2s_sMd0pwh7jdC16/view)**，3,202,492 bytes。
- 三者 Google Drive metadata 真實 READBACK **shared=false、permissions user owner only**。私人 PNG 不放在公開 GitHub，也沒有操作使用者 PC。

## 下個宏觀單位

最優先是**換成能嚴格分兩次生成、真正支援 Alpha=0 透明背景、原生世界尺寸的藝術來源**，而非繼續重試會完整繪製 Master 的生成器。以前面 D8 星井綠洲真正 Ground/PAR pair 作樣本驗收，再對風沙裂谷完成 Ground-first 的全部非地表 PAR。任何新工具未連接或實際執行者不可宣稱 API 生成成功。

如果製作正式 `FS_03_MAZE`，Ground 與 PAR **必須以原生 80×58 / 2560×1856 輸出**；不可將本次 46×33 的美術樣本最近鄰放大後寫成正式 ART PASS。後續按六系世界規劃繼續 04 火山、05 水澤、06 星晶浮島。

**本輪獨立 Ground 來源 PASS、尺寸與地表純度 HOLD、PAR NOT_GENERATED、Godot 4.7.2 native NOT_RUN、正式 ART SEALED 0/12。**