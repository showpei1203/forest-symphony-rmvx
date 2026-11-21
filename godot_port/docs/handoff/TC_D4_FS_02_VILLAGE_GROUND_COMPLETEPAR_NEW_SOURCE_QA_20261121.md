# T-C D4｜FS_02_VILLAGE 霜燈聚落｜GROUND-FIRST → COMPLETE NON-GROUND PAR 新生成候選｜2026-11-21

## 實際施工（對照 D3 Ground SHA 凍結）

- 正式場景：`FS_02_VILLAGE`「霜燈聚落」，地形凜霜雪原，world blueprint 40×29、32px／tile、1280×928。
- D3 上輪真正獨立 AI Ground：`GROUND.png` 1280×928 RGB，SHA256 `475f7883c1fe23245198198029da3ac37dc479176e3dc8ddc8a81aba4054f5ea`，原 Ground 不變，沒有改成混合 Master。
- D4 新一輪獨立 image-generation PAR source：1473×1068 RGBA，原始 source SHA256 `f8799684c508c9f4bb8047e21eee98cecfe246b50d3397521325e26da1636895`。實際生成完整非地表候選：不同設計的三棟覆雪木屋、完整帶樹幹冷杉、木柵、路燈、旗幟、石拱、冰晶、雪人與村莊物件。**不是先合成 Master 再反切，亦沒有依物件是否會遮玩家決定 PAR 內容**。
- 統一 D3 Ground 已使用的 source crop：`(95,71,1375,999)`，D4 PAR 同樣依像素原比例 1× 裁切成 1280×928。無畫素拉伸，沒有把 1473×1068 不等比例近鄰變成 Godot 40×29。
- `PAR_COMPLETE_RAW_RGBA_1280x928.png` 原始 cropped SHA256 `3717e0a4076d788befa1b2afb85f786b2abdc99e4a6c4fa8792e4d3024aa257a`，技術 alpha 清理版 SHA256 `44aee78ef02329018237e9750ee22012c08cea443ae4bf6f977bfc8af36238f3`，合成畫面 SHA256 `62baac926a41178edd072ed3d977b7225fdbe83a2516e8e7689a0b64efbc4378`。
- Pillow 逐像素 `Image.alpha_composite` 真實進行 D3 RGB Ground + D4 RGBA PAR 原始及修正版各一組；輸出全尺寸 1× 合成畫面和 50% 接觸比較圖（QA 接觸圖不是 native Godot 截圖）。

## 真正執行的 QA／失敗警示

| 項目 | 結果 |
|---|---|
| Ground 真獨立、先前已生成且 SHA 不變 | PASS |
| 另行生成真正 RGBA PAR | PASS |
| 全物件種類非地表包含（目視） | CANDIDATE；沒有可驗 192 個 source owner 的獨立 manifest |
| Ground／PAR 同裁切、原像素、1280×928 | PASS |
| 真透明（包含 alpha=0） | PASS |
| 原始 PAR Alpha 純淨度 | **FAIL**：482,226 pixels alpha=0；190,971 px alpha=1..8 雜點；419,163 px alpha=240..254、46 px alpha=255 |
| 技術透明度清理 | CANDIDATE；alpha≤8→0，alpha≥240→255，原始 RGBA 不變 |
| 40×29 世界裁切完整性 | **FAIL_CROP**：原 PAR 裁切後邊界仍有大量 alpha>224：top 731、bottom 357、left 593、right 480；部分森林/岩石超出實際地圖框 |
| 逐物件實際對地足點／進出門 | ART HOLD |
| Godot 4.7.2 本輪真正 native GPU／physics | **NOT_RUN**，不能拿 D1/C8 歷史通過結果冒稱 D4 |
| FORMAL ART GATE | **HOLD** |

**美術宏觀審查**：雪原地表、三棟互異雪屋、冷杉與雪燈在冷暖光色語言上相容，中央十字路口也保持清楚。仍不可因合成看起來不錯就宣稱完成正式場景；透明度與裁邊是完整性阻斷。

## Drive WRITE → READBACK → VERIFY（使用者 owner-only）

1. [完整 Ground / 原始 PAR / 修正版 PAR / QA / 合成 ZIP](https://drive.google.com/file/d/1ZNxOAya0UZe8y8DC1KEfhOCJXDCSo9Uh/view) 14,185,535 bytes，內 9 entries，ZIP CRC PASS，ZIP SHA256 `32d0ca6354e09408aba1a5edc1b94b05f1c4b3ea6ded9664550b9648dd4580ef`。
2. [PAR 原始真正 RGBA](https://drive.google.com/file/d/13p62_ZjVAS7FvZKzBj1XydCwqrKLmULn/view) 1,625,792 bytes。
3. [PAR Alpha 清理技術候選](https://drive.google.com/file/d/1-H6ZO1eRhRpy27DdJYwh35ywIq-0l5ym/view) 1,529,566 bytes。
4. [Ground＋PAR 實際合成 QA 圖](https://drive.google.com/file/d/1C3pw0Xn5BTGCTNbIuoPZ6S-VNpxPulNw/view) 2,375,728 bytes。

上述四個 Google Drive 檔案讀回均 `shared=false`、只有 `user owner`。原 Ground 在 [D3 私人 Drive](https://drive.google.com/file/d/1YQt0dkI2AR9VFYMMrFYP3h4KUPJ_ka9T/view)。所有新源 PNG 保存在私人 Drive；GitHub 只存碼、QA 報告、場景 Blueprint 與 Handoff，**沒有上傳圖片到公開 Github**。

## 六地形十二圖繼續量產的優先順序

- FS_01_VILLAGE 苔光村：D2 新生成 46×33 完整 Ground/PAR 技術合成候選，原 40×29／Godot 艺術 HOLD。
- FS_01_MAZE 幽葉迴廊：歷史 R12 80×58 Godot 機制測試有基準；藝術仍 HOLD。
- FS_02_VILLAGE 霜燈聚落：**D4 完整 Ground＋非地表 PAR 新生成技術候選 PASS，正式 ART HOLD**。
- **下個整張圖：FS_02_MAZE 冰脊迷谷**，以同一雪原地形 palette/style DNA，先完成全新彎曲冰道、岔口／背風谷的獨立 Ground，再另生成 COMPLETE PAR；雪原迷宮不能複製村莊的十字廣場，也不能只將森林重新調成白色。
- 其後依原世界設定 03 風蝕金砂 → 04 赤焰火山 → 05 幽霧水澤 → 06 星晶浮島，每種迷宮＋村莊各完整 Ground-first/CompletePAR。不得在這個美術工作線施工事件／NPC／對話／戰鬥。
