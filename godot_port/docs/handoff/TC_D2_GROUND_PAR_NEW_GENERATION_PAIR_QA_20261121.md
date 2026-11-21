# Forest Symphony | T-C D2 新生成 Ground→完整 PAR 配對實測與 Failure Log

日期：2026-11-21（Asia/Taipei）  
分支：`feat/fs-pixellab-tc-map-20261121`  
遵守使用者最新指示：**先生 GROUND，再生 COMPLETE PAR；PAR 是所有非地表物件，不選擇性抽角色遮蔽**。

## 實際輸入

- Ground：本輪 in-chat image generation 獨立產生 1473×1068 RGB 純地表。
- PAR v1：本輪另行生成 1473×1068 RGBA，完整房屋、森林、樹、路燈、噴泉、石塊、灌木與裝飾，不是後來從 Master 逆向裁切。
- PAR v2：另一個獨立生成的備選 RGBA。人工完整合成比較後選擇 v1，v2 保留於本對話驗收 ZIP。
- 本輪先以 Python Pillow 做原生像素合成；**這不是已通過 Godot 4.7.2 原生運行的宣稱**。

## 幾何與 Art Gate

原圖尺寸 1473×1068 不整除 32，故同源雙圖以相同裁切 `(0,0,1472,1056)` 生成 **1472×1056，即 46×33 個 32px 世界格**。無尺寸縮放、無插值。兩張圖都從獨立素材生產，原始 Ground 未混入 PAR 物件。

另一個原定 1280×928、40×29 的測試，以同源中心裁切 `(96,70,1376,998)` 完成畫面及透明檢查，**但 ART HOLD / FAIL_CROP**：PAR v1 在中心裁切的上邊有 872、左 544、右 654 個高不透明 alpha 像素直接觸邊，會切掉既有樹木／非地表物件。不可以把這張 1280 視為完整合法 PAR，美術上的正確辦法是從一開始就按 1280×928 的 World Blueprint 重生成雙圖，或改用 46×33 的新地圖而非硬裁。

D2 46×33 源圖合成宏觀美術相當協調：左上、右下兩棟不同的精靈屋，森林路徑、攤位及中央噴泉景觀融合良好。Ground/PAR 風格統一，這是宏觀人工檢視，不代表 FS Ground3 原圖細節比較、人工作品批准或真 Godot 封版。

**關鍵透明 Alpha QA**：選用 PAR v1 在 46×33 範圍中有 974,358 個 alpha>0 像素、只有 402 pixels alpha=255，另有 147,430 個 alpha=1..8 偽透明雜點及 715,548 個 alpha=240..254 接近全不透明像素。純紅／綠／黃色污染主要在 alpha=1..3 邊緣。原 RGBA 及完全不修改的 raw composite **均保存**。為單獨 QA 技術候選，清理規則僅 alpha≤8→0、alpha≥240→255；其餘保留、可見像素 RGB 不修改。不能冒稱這是 AI 畫師自然生成的完美原始 Alpha。原始獨立 PAR 仍可下載復查。

**分項 QA：**
- GROUND_SOURCE_IS_SEPARATE_FROM_PAR：PASS
- GROUND_PAR_SIZE_AND_WORLD_XY（46×33）：PASS
- ALPHA_IS_REAL_RGBA：PASS
- GROUND_ALPHA_COMPOSITE_PIXEL_REPRODUCIBLE：PASS（Pillow 逐像素）
- PAR_VISUAL_ALL_NON_GROUND：CANDIDATE，沒有逐物件原生 Source Manifest，不把目視認定當數據 192／192
- PAR_ALPHA_EDGE_CLEANLINESS：ORIGINAL_FAIL / CLEANED_CANDIDATE
- FS_01_VILLAGE_40x29_CROPPING：ART_FAIL_CROP
- ART_1X_VS_APPROVED_FS_ORIGINAL：HOLD
- Godot_4_7_2_NATIVE：**NOT_RUN**（此執行容器沒有 Godot 4.7.2，無法對 Github release 連網下載）
- USER_ART_GATE：PENDING
- FORMAL_SEAL：NO

## Google Drive PRIVATE，已 WRITE→READBACK

1. Ground 46×33 `GROUND_46x33.png`：https://drive.google.com/file/d/1zop1sxdXiTfee_rpiSQCJXu5Uotikt4y/view ，3,190,655 bytes，SHA256 `226a0733dc92cd0023ddcd4a86afff9d8a469cc658b0a5e884c5667bcce36af1`。
2. 真正獨立透明原始 PAR： https://drive.google.com/file/d/17lUUXnCCNk4pQGWUGiRciSJW9qAVGbrl/view ，2,553,927 bytes，SHA256 `0a52c590e85086b29af37754bdbc9206d2aab96ec9d98e0c82f5d4d4dbd2f574`。
3. Alpha 技術清理 PAR 候選：https://drive.google.com/file/d/1nywEe4sG-KTtWFTpPC7VCoQjD_ANa6Lv/view ，2,300,090 bytes，SHA256 `80b6aee06908c3e8160881af28a3faa9cf0d3d09c85bac3f0b538de45e9e406c`。
4. 46×33 新版合成完整圖：https://drive.google.com/file/d/1cASgC0jbjiXbFOf_HSJPTanjgBHUfUrU/view ，3,373,243 bytes，SHA256 `09137573db960dead52bc599e859a7f5134b65366f13e371df39a1cd3f91e7a8`。

上述四件 Google Drive provider metadata 各自 READBACK，均 `shared=false`、`owner-only`，沒有動用使用者 PC。可編輯來源 PNG 在 owner-only Drive；GitHub 僅記錄本 QA/Handoff。當輪附加本對話 ZIP `FS_TC_D2_GROUND_FIRST_COMPLETE_PAR_46x33_QA_20261121.zip`，18,178,625 bytes，SHA256 `12251765bbc4d51420fa6033a26ba5a847665035e28480526b9cfc49d7d0283c`，ZIP CRC PASS；僅作本對話下載，不宣稱 ZIP 已存 Google Drive。

## 下一完整施工單位

1. 只修完整 Ground/PAR 來源共同 Blueprint 與輸出原生 1280×928 座標的產圖功能，不重回單樹/屋簷 occlusion 小修路線。若改讓 46×33 成正式新地圖則先明確定義地圖尺寸，不再不必要裁邊。
2. 讓 PAR 生成原始 RGBA 高品質真透明，避免 Alpha=1 的雜色、近全不透明非 255 的大面積邊緣；保留全部非 Ground 的物件。
3. 在可使用 Godot 4.7.2 的 CI 環境，以私人素材安全導入或可信任傳送方式跑真正 1× 雙圖 native 對照；未通過之前不聲稱 Engine PASS。
4. 美術取得使用者明確認可前，正式 FS_01_VILLAGE / FS_01_MAZE ART HOLD。

**核心原則：先生成整張 Ground，完成後才生成全非地表 PAR。不是逆切 Master，也不選擇哪些像素應遮人物。**
