# FS V6｜Forest Master Visual Pilot 與 Fail-Closed Handoff｜2026-10-26

狀態：**VISUAL MASTER CANDIDATE；GROUND-ONLY FAIL；NATIVE VX NOT RUN；USER ART PENDING**。

## 完成項目
- 本輪新生成一張精細森林環境 Source Art（原圖 1435×1096 px，RGB），以單一 1:1 原像素裁切成 **1280×928 px** 的 40×29 tiles 大型視覺母圖候選；未做模糊插值。Source SHA256 `24dbfc1795c39e6ad651159327f26d268533e12bdebc048b96ff78eebacc392e`；1280×928 World SHA256 `1e5ba45e6310e0176c507becf90abcf54866f8ad103200ac201443b79a01a1c2`。
- 另由世界母圖作 544×416 Exact Crop，與使用者 SCENE21(3) 在原尺寸並列比較；不是另一張獨立生成的 Ground。
- 從母圖以 RGB 青藍篩選水域 **107,084 像素（約 9.02%）** 的草稿語義遮罩；只用作 reviewer 視覺標記，**不是實際水碰撞、Source Alpha、完整 Scene Semantic Mask**。
- 本輪 ZIP 有 11 個檔案：Source、1280×928 候選、544×416 Detail、SCENE21 私有對照、RGB 水域初篩、32px Grid Preview、Manifest、README 與可獨立執行 `RUN_QA.py`。現有 QA 確認 SHA 完整、世界裁切未 resample、絕不宣稱 P2 Ground 過關。
- 已將母圖嵌入 Drive 私有審查文件：https://docs.google.com/document/d/1l2R_9AZFWEPtM-QaYOXXmP1N7_d7hfHns9TYZ2tzt6g/edit。原始私有參考圖片未上傳公用 GitHub。

## Fail-Closed 原因
母圖把岩壁直立面、瀑布與河面、樓梯、石頭及立體灌木混在畫面。符合使用者對未來最終場景的豐富度方向，但違反 **P2 地表必須只有乾淨水平 Ground** 的規範，無法直接用於 FS v3.2 Scene Manifest 編譯；不可從 RGB Mask 假造完整 PAR，亦不可用模糊/矩形 donor patch 移除立體物後宣稱藝術 PASS。含河/崖將造成水洞 Exceptions/遮擋/Height 與角色 Footbox 冲突。

## 獨立 QA 現況
```
WORLD_CONCEPT_40x29=EXACT_CROP_PASS
SOURCE_ORIGINAL_SHA=RECORDED
REFERENCE_COMPARISON_544x416=GENERATED
WATER_COLOR_SCREEN_DRAFT=107084px
SEMANTIC_PIXEL_OWNER=NOT_VERIFIED
GROUND_ONLY_ART=FAIL_WITH_WATER_CLIFF_STAIR_BAKED_IN
PAR_COMPLETE=NOT_EXTRACTED
VX_NATIVE=NOT_RUN
HUMAN_VISUAL=PENDING
```

## 下一步
1. 這張母圖當視覺密度/風格意圖與負向案例，和六張正式 Golden Scene 資料一起做 P1 Style Contract。
2. 單獨生成／取得 **無水域及岩壁立面、完整自然草地與土路的 544×416 Ground-only** 原生來源，先人工評比和驗收；若生圖輸出仍含石壁，立即退回重生，不得進 PAR。
3. Ground 通過後獨立製作完整石屋、樹、岩壁、灌木 Source，先消除 Source crop/Alpha/Scale，再用唯一 Manifest 編譯、原生 VX 負向測試。
4. 高品質 17×13 Visual Gate 過關後才擴展至 ground3 等級 40×29，另行比較 ground10 native Animated Parallax/ROI 候選。
5. 本輪不覆寫 F1R1 A04、FS SEALED、正在另一對話進行的地圖 candidate，亦不更新共享場景 CURRENT_HANDOFF；只有獨立 V6 supplemental handoff。

## 參考 Authority
- V6 正式規格：https://docs.google.com/document/d/1aypbyssZaYh1SG8cae0iK98JW5ufU__xcXA-q3gLZu8/edit
- Drive 本輪含實際插圖的獨立審查：https://docs.google.com/document/d/1l2R_9AZFWEPtM-QaYOXXmP1N7_d7hfHns9TYZ2tzt6g/edit
- Google Drive FS SOURCE REGISTRY：https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit
- Linear SHO-39。
