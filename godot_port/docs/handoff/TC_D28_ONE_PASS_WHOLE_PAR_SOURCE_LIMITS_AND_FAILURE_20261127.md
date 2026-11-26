## D28 真私人證據 WRITE→READBACK（2026-11-27）

- [**D28 十四檔全原始來源／三版完整 PAR／整張 QA／五項程式測試／失敗 Handoff 私人 ZIP**](https://drive.google.com/file/d/1okgdbVIN6FHq4-iGa34M62uWg9CJfrI_/view)，**15,536,143 bytes，ZIP CRC PASS，SHA256 `5fb6bc2b372ba147ad9e1b2bdeb630b5cbba757f1026cfa0a1c15269a6dd17c6`**。
- [A 真透明整張來源](https://drive.google.com/file/d/1DgASyFvIyqGSSuPTlihGiGJNzjBVI-du/view)／[B 整張來源](https://drive.google.com/file/d/1WF3yuh7dbGa6xFPXvWMphiYNkgJgJr_h/view)／[C 整張來源](https://drive.google.com/file/d/1zJIQf0Ya55Aaltnxaa-S1jMbri8nRD6Z/view)（三張均**不符合原生畫布**）。
- [整張 Ground+PAR QA-only 三版對照](https://drive.google.com/file/d/1gl9Eks--UiIhwox7qzXvvo8ljYlveLYn/view)、[完整實測來源數據](https://drive.google.com/file/d/1enflNxTEVkZeVVhJPDIurgM8K-k2DebQ/view)及[SHA Manifest](https://drive.google.com/file/d/1XYOcAFPoH2nAlsjntYJ-hdtiLNXq4Shm/view)。
- 已逐項 Drive metadata 回讀，`shared=false`、權限只有 `owner`。私人 PNG 未進公開 GitHub，正式 ART 仍 **0/12**。

---

# Forest Symphony｜T-C D28｜整張一次生成 CompletePAR：來源尺寸再三拒收、能力限制查證及正式經驗｜2026-11-27

## 最新使用者目標／不可退讓規則
以 D17 `1280×928 RGB` Ground 作世界唯一基準，直接**單次生成整張、單作者、獨立、真正透明 CompletePAR**。一次包含橋、鍛造工坊、吊車、倉庫、燈、旗、岩柱、欄杆等全部非地表物件；不允許分件生成、連通物件群位移、單件修橋或單件縮放。這輪未把錯誤尺寸來源用縮放/裁切冒充正式畫布。

## 實際施工 D28-A/B/C
三次都生成了一整張真正 RGBA 全非地表源圖、原始畫面未改。與固定 D17 Ground 同畫布 **FAIL**：

| 來源 | 原始尺寸 | Alpha=0 | Alpha>32 位於原生 1280×928 範圍外 | 原生尺寸 Gate |
|---|---:|---:|---:|---|
| D28-A | 1473×1068 | 952,350 | 77,882 | **FAIL** |
| D28-B（嘗試透明安全範圍） | 1474×1067 | 815,928 | 70,867 | **FAIL** |
| D28-C（嘗試 D17 Ground 視覺參考） | 1474×1067 | 989,336 | 66,627 | **FAIL** |

任何直接 `1280×928` 裁切都會砍掉現有物件，不能憑數字改標為原生輸出；把整張來源等比例 resize 到該尺寸只建立**QA-only 整張合成預覽**，不得宣稱 Godot Native 或正式遊戲可用。D28 任何圖片均未做到凍結 Ground 的世界錨點精準吻合；工坊、橋等仍明顯偏大，源圖有紅色邊緣雜訊，**ART HOLD 0/12**。

原 Ground `LOCKED_D17_GROUND_1280x928.png` SHA256 `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`，全程未修改。三份原始來源 SHA 詳見 `D28_ACTUAL_WHOLE_SOURCE_GATES.json`。未進 Godot 4.7.2，正式 Native `NOT_RUN`，不是失敗後假裝已跑。

## 根因：工具輸出約束而非單一物件形狀
D27 已有 1474×1067 真透明單次全景，D28 三次換整張生成構圖／以凍結 Ground 參照仍輸出 ~1474×1067，且大幅超界。**此生成介面沒有在本輪實測能精準輸出 1280×928 且保持單張真透明和世界像素對位**。再試更多同路提示的效益極低，先阻斷無效上游。

### 另一條候選工具 PixelLab 的官方功能邊界（公開資料查核，不代表有權使用付費 API）
PixelLab 官方 v2 API 文件 `https://api.pixellab.ai/v2/docs`：快速 Pixen `create-image-pixen` 規格最多 768px，部分圖片模型更小；官方 
`https://www.pixellab.ai/docs/options/general` 提到 Remove Background 真 Alpha 的畫布約 200×200 面積限制（超過背景以單色補足）。
`https://www.pixellab.ai/pixellab-api` 包含多個圖片模型與尺寸上限。**依官方限制，不能把現有 PixelLab 單張圖片生成能力宣稱已驗證可完成原生 1280×928 的完整透明 PAR。** 未在 PixelLab 發起付費工作，也未在使用者 Windows E: 施工。

## 本輪真正新增的可重用工程防線
- `fs_tc_d28_whole_plate_source_gate.py`：直接讀原始整張來源，核實 `RGBA` 真 Alpha=0、原生尺寸是否 **恰為** 1280×928、超畫布可見像素、Ground SHA；從不分群、重排、縮放生產素材。
- 當場對 D28 A/B/C 真來源執行，三張均準確標 `SOURCE_NOT_EXACT_NATIVE_CANVAS` ＋ `VISIBLE_PIXELS_OUTSIDE_NATIVE_CANVAS`。
- `test_fs_tc_d28_whole_plate_source_gate.py` 五項正反測試通過：真原生尺寸候選仍須 HUMAN ART、較大來源即使外圈透明仍拒收、越界像素拒收、RGB 假透明拒收、整張 QA 預覽不能修改任何原始作者 PNG。
- 三張 `QA_ONLY` 是**整張圖片一次 resample 後**和原 Ground 靜態合成來比較布局，不是正式 1× PAR，也不能增加 ART 完成數。
- 原 PNG 和完整 QA 存私人 owner-only Google Drive，GitHub 僅存源碼、測試、Handoff、來源 SHA。

## 下一個完整施工單位 D29
**只研究整張畫布控制的實際作者方法，而非零件補丁：**必須先有官方和實機證據，能把整張 Ground 的 1280×928 世界畫布傳給生成器、讓一次生成的全部非地表物件落在正確坐標並原生真透明輸出。若新工具需要付費或安裝，遵守權限與已存在工具鏈，不能假設已調用。沒有真正原生 1280×928 時來源必須 `HOLD`，不要拿圖像上或 CI 上的 PASS 當 ART PASS。

**正式狀態：SOURCE FORMAT PASS（真正整張透明圖）、SOURCE NATIVE CANVAS FAIL、WORLD ALIGNMENT NOT PROVEN、GODOT NATIVE NOT_RUN、HUMAN ART HOLD、0／12。**
