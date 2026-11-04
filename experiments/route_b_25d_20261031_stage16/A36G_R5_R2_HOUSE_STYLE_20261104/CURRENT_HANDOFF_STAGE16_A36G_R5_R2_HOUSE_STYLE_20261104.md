# Forest Symphony | A36G R5 R2 | 統一兩棟精靈村房屋風格 | 2026-11-04

**狀態：實際 Ground／PAR 工程已修改；VX+Godot ENGINE_SMOKE_PASS；美術簽核 PENDING；正式封版 NO。**

## 工程定位
- 上游不可變更：A36G R4 R3 六林群 E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104，Scene SHA256 4f30983eeb27d2ae43ddcace39ac2304eaa96e7ac3734411ccf309aa3d210a07。
- 本輪新獨立工程：E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104。
- 新 VX 實機工程：E:\FS_STAGE16_A36G_R5_VX_NATIVE_20261104。
- Godot 實測工程：E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104\GODOT_A36G_R5_40x29。
- 舊 A36F、R3B、R4 和左屋、原始六林群來源都完全不覆寫。

## 使用者美術回饋與原因
「兩棟房子的美術不同調」。左屋為新 PixelLab 高密度單片建築，苔蘚金橄欖綠屋頂、黃棕屋樑、苔石基座。右屋使用 A36F 舊版平面、偏冷亮綠、對稱三角屋頂與弱像素材質，與左屋視角和細節均不同。
正確解法：**以左屋的材質/像素風格為權威，對右屋做整棟重新生成**，但保留右屋獨立小屋的建築身份，不能複製左屋側工坊，也不准用拼貼。

## 真正施工與 Fail Log
1. R5 R1 首張 PixelLab (198x236) 完整單片來源存 SOURCE_INDEPENDENT_RGBA/A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_RGBA.png，但視覺近乎直接複製左屋工坊，並且側邊被畫布裁切；嚴格美術 FAIL，沒有匯入正式工程，請勿恢復/引用此版本當成功案例。
2. R5 R2 改善方法：先從左屋完整獨立來源取 **135x190 材質風格局部** A36G_R5_LEFT_HOUSE_MATERIAL_STYLE_PATCH_RGBA.png。右屋舊圖僅作門口和單一建築比例參考，不允許複製舊綠屋頂。單次 PixelLab 生成 256x272 畫布，全新的單一斜屋脊、雙坡屋頂住宅，不帶側工坊。
3. R5 R2 真正來源：SOURCE_INDEPENDENT_RGBA/A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png，原生完整透明 RGBA 256x272，alpha bbox (21,23,188,220)，四角透明，不裁切。源 SHA256 **4794a89cb06029112e6581c85a47bdcf6a84b7f636e05755825a989793585206**。來源生成鎖：A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_SUBMISSION_LOCK.json，禁止重新消耗額度。左屋原生來源 SHA256 不變：964fe9bf9fe4048bc4b96fab573285cc9a2042faeefe38f1fde9501a23ccb699。
4. 新右屋繪製座標 (743,376)，256x272，實際非透明世界範圍 (764,399)-(931,596)，房門落點保持 (869,596)，讓門前路徑不偏移。新增基座阻擋框 [778,535,921,588]，替換舊右屋阻擋框 [801,542,946,590]。919/919 可行走格靜態 BFS 連通，241 格阻擋。不要沿用舊右屋比新圖更寬的碰撞框。
5. Scene Manifest：A36G_R5_SCENE_MANIFEST.json，192 個物件；只有右屋原生 PNG/位置/足點/碰撞變更，左屋/所有森林素材/Ground 保持上游雜湊。
6. 真 Ground：A36G_R5_GROUND_1280x928.png，SHA256 與 R4 相同：8c4acbfe3c7201de5f66c51f84af8b568972c5a09d97ebc0a76e3152d764e371。
7. 真 PAR：A36G_R5_PAR50_RGBA_1280x928.png，SHA256 9079fecdf2d0301817a3e06854a3ab1ffec691de6dac29f28102d9e4833bbe6d。
8. 真 Ground+PAR 合成：A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png，SHA256 7350d3d8dd34602f8aa2799d2ad76c9bb84ec24f68cdb321c19d3329804743db。
9. 右屋原生 before/after：A36G_R4_VS_R5_RIGHT_HOUSE_1X_BEFORE_AFTER.png。兩棟真正原生建築並排：A36G_R5_TWO_ACTUAL_RGBA_HOUSE_SOURCES.png。全圖真實 Ground/PAR 前後：A36G_R4_VS_R5_FULL_MAP_TRUE_GROUND_PAR.png。全圖新預覽 A36G_R5_PREVIEW_640.png。

## 原生引擎工程測試
- RPG Maker VX 原生 RGSS Player Map050，40×29，11 組 actor 路徑，22 張真實 544×416 截圖：R5_VX_CAPTURES/A36G_VX_NATIVE_CASE_*.png。
- 無錯誤視窗、192 物件載入，真阻擋 before=11,11 after=11,11，真道路 before=11,8 after=12,8。
- 真正 Godot 4.7.2 RX6700XT GPU：6 張全圖 1280×928 + 6 張 544×416 裁切；跟實際 Ground/PAR 合成比對 RGB 單通道最大誤差 1，誤差大於 1 的像素 0。
- 原生 QA：A36G_R5_R2_NATIVE_GPU_SCENE_QA.json，ENGINE_SMOKE_PASS True。
- 碰撞、遮擋分離 Gate：屋後案例 06 現有 348 個人物像素可見，因新屋頂較窄人物頭部露出屋頂輪廓，不可拿來當「完全遮蔽 PASS」。這個位置的真實視覺遮擋與房屋根部阻擋仍需後續逐格驗收。左屋舊測試保持屋後隱藏 0 與屋前顯示 38 差異像素。
- 美術 R5 R2 兩棟房屋統一材質風格，仍需使用者在 1× 地圖正式驗收。封版 NO。

## 可重製步驟與禁止重跑
- r5_prepare.py：從 R4 鎖定資料建立 R5 結構。
- r5_pixellab_right_house.py：第一次失敗原型，已鎖定；禁止重送。
- r5_prepare_pixellab_right_r2.py：切左屋 135×190 材質局部參考。
- r5_pixellab_right_house_r2.py：第二次成功原生小屋來源；請勿再次 POST 消耗額度。
- r5_r2_integrate_house.py：Scene Manifest + PNG 物件 SHA/透明 alpha/座標/基座碰撞 + Ground/PAR 真合成。
- r5_prepare_builders.py / r5_build_native_engines.py：新建 VX + Godot，不覆寫上游。
- r5_capture_native.py / r5_native_validate.py：真實原生 actor screenshot + Godot GPU delta 門檻。
- r5_cold_verify.py：獨立冷重建測試（若未成功完成，保持 PENDING）。
- A36G_R5_R2_INTEGRATION_QA.json 完整工程驗證記錄。
- **下一步**：美術 1× 正式視覺驗收；如要新增建築，先沿用 R2 成功的「局部材質風格圖+獨立建築形狀」雙參照方法，嚴禁直接用完整左屋為 style reference 複製建築。

正式封版：NO。不能將可載入和視覺品質混成同一 PASS。
