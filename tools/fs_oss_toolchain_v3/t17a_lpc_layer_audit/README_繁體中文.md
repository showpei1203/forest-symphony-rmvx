# Forest Symphony｜T17A LPC Base 原生方向／圖層對位測試
日期 2026-10-24；測試是獨立工具研究，不變更 SEALED Forest Symphony、PMD、CG 或 Tankentai SBS 腳本。

## 結果
官方 2012 LPC Base 原始素材包，共78 entries，來源 https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles
原 ZIP SHA256 69efec8a26ef20b26cfd7a8de370e87d0e667136eba2d00392dde13d2ac52465；附 CREDITS.TXT（本包另存 CREDITS_original.TXT）。
64×64 逐格、不縮放、RGBA alpha 合成；male body + male pants 逐格與一次合成整張 Sheet 的 RGBA 完全相同。
Walk 9×4=36、Slash 6×4=24、Spellcast 7×4=28；總88格，3/3 結構 PASS。
故意讓 Pants 偏1px或交換 up/down 方向列，全部均檢測出像素差異。
注意：褲裝 alpha 在部分像素超出原 body 非透明範圍，不可誤以為所有此類像素屬錯位。必須以原始幀視覺與角色結構驗收。
方向列採 LPC up / left / down / right 慣例；本輪未手動視覺核對所有原始 2012 sheet，也未實測武器對位。

## 授權
LPC Base Assets 官方提供 CC BY-SA 3.0 / GPL 3.0 雙授權，需逐檔遵守各作者署名與衍生授權，版權聲明見同包 CREDITS_original.TXT。
身體及褲子來源作者 Redshrike 在官方清單另記 OGA-BY 3.0 選項；不能類推至其他 LPC 配件。
不得把這個技術測試包當作 Forest Symphony Approved Assets 或直接丟入商業成品。武器/坐騎/PMD來源另行嚴格授權檢查。

## 執行
雙擊 RUN_T17A.cmd（需 Python3/Pillow）；測試重用本資料夾 lpc_base_assets.zip，不連網不重下載。
報告 T17A_LPC_LAYER_ALIGNMENT.json，輸出 outputs/ 三張整表和 12 張方向動畫列 PNG。
報告要 PASS 必須三種動作全部像素一致、故意錯位成功被抓。
本輪無 SBS 武器圖層測試，不得宣稱 T17 整體或真實遊戲 Gate F PASS。
