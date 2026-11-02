# FS 人物戰鬥動作範本：可重用索引（2026-11-02）

- 主要原始素材資料夾：[00_Reference_Original](https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr)
- 戰鬥人物範本庫：[人物戰鬥動作範本](https://drive.google.com/drive/folders/1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe)
- 檔名與 Google Drive ID 已完成 364 個 PNG 的完整初步盤點（4 頁）。
- 檔名分組不是動作解析；不代表視角、骨架或動作已獲驗收。

## 檔名系列數量前二十名（僅索引）

| 系列 | 數量 | 範例 |
|---|---:|---|
| Kaduki | 8 | Kaduki8.png, Kaduki7.png, Kaduki6.png, Kaduki5.png, Kaduki4.png |
| $Actor64_a | 5 | $Actor64_a_5.png, $Actor64_a_3.png, $Actor64_a_2.png, $Actor64_a_1.png, $Actor64_a.png |
| $Actor64_b | 5 | $Actor64_b_5.png, $Actor64_b_3.png, $Actor64_b_2.png, $Actor64_b_1.png, $Actor64_b.png |
| $Actor63 | 5 | $Actor63_5.png, $Actor63_3.png, $Actor63_2.png, $Actor63_1.png, $Actor63.png |
| $Actor50 | 5 | $Actor50_7.png, $Actor50_3.png, $Actor50_2.png, $Actor50_1.png, $Actor50.png |
| $Actor31 | 5 | $Actor31_5.png, $Actor31_3.png, $Actor31_2.png, $Actor31_1.png, $Actor31.png |
| $Actor30 | 5 | $Actor30_5.png, $Actor30_3.png, $Actor30_2.png, $Actor30_1.png, $Actor30.png |
| $Actor20 | 5 | $Actor20_5.png, $Actor20_3.png, $Actor20_2.png, $Actor20_1.png, $Actor20.png |
| $Actor16 | 5 | $Actor16_7.png, $Actor16_3.png, $Actor16_2.png, $Actor16_1.png, $Actor16.png |
| $Actor12 | 5 | $Actor12_7.png, $Actor12_3.png, $Actor12_2.png, $Actor12_1.png, $Actor12.png |
| $Actor7 | 5 | $Actor7_5.png, $Actor7_3.png, $Actor7_2.png, $Actor7_1.png, $Actor7.png |
| $Actor19 | 5 | $Actor19_5.png, $Actor19_3.png, $Actor19_2.png, $Actor19_1.png, $Actor19.png |
| $Actor8 | 5 | $Actor8_5.png, $Actor8_3.png, $Actor8_2.png, $Actor8_1.png, $Actor8.png |
| $Actor5 | 5 | $Actor5_5.png, $Actor5_3.png, $Actor5_2.png, $Actor5_1.png, $Actor5.png |
| $Actor4 | 5 | $Actor4_5.png, $Actor4_3.png, $Actor4_2.png, $Actor4_1.png, $Actor4.png |
| Actor783 | 4 | Actor783_3.png, Actor783_2.png, Actor783_1.png, Actor783.png |
| Actor780 | 4 | Actor780_3.png, Actor780_2.png, Actor780_1.png, Actor780.png |
| Actor778 | 4 | Actor778_3.png, Actor778_2.png, Actor778_1.png, Actor778.png |
| Actor777 | 4 | Actor777_3.png, Actor777_2.png, Actor777_1.png, Actor777.png |
| _Allimaj3 | 4 | _Allimaj3.png, _Allimaj3_1.png, _Allimaj3_2.png, _Allimaj3_3.png |

## 下一次製作時的必讀順序

1. 先看原版 $actor01 相關動作三幀與這份檔名索引，依角色系列取得參考 PNG。
2. 逐格解出實際動作類別、原生 frame layout、角色朝向、左／右肢體及頭肩髖膝足擺動，標記未驗證的家族；做接觸表與 GIF。
3. 優先套用 USER PASS 的 A62 動作範本。A63-W3B Waiting、A64-C3 Critical 只是美術候選，不視為已通過。
4. 對應參考圖可交 PixelLab 作圖像控制，或在保留色盤與風格前提下程式加工；先跑免費 skeleton/source QA，再花付費額度。
5. 每一個被真正解析的家族，寫回此索引：image Drive ID、方向、動作、每幀、適用角色、qa 記錄與失敗說明。

完整檔案 ID 清單請見 [JSON 索引](../authority/FS_CHARACTER_MOTION_LIBRARY_MANIFEST_20261102.json)。
