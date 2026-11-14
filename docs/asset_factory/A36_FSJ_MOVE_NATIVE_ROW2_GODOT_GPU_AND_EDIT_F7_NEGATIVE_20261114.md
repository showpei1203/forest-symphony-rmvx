# A36｜FS 真正 RUN 圖集格式、三幀轉換、Godot 真 GPU 播放、F7 AI 局部修補反證
日期：2026-11-14。**素材已真正製作、私人雲端備份；Godot 4.7.2 真 GPU 載入 / AnimatedSprite2D PASS；美術 ART HOLD；RPG Maker VX 原生 Tankentai 尚未測；FS E: 工程/main 未改。**

## 從真實 FS 工程取得的決定性格式
- 從使用者原始 `E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Characters\$actor01_1.png` 真正檢查得到 **96×128 RGBA、3 欄 × 4 列、每格 32×32**。
- 從原始 `All_Scripts_Export.txt`，`FSJ_BATTLER_ANIME_V15` 當中直接確認移動動作 `FSJ_MOVE => [1, 2, 12, 0, 0, -1, 0, true, ""]`，註解說明 **`$actor01_1` 的 Row 2 為移動，FileNo=1；Row 1 是 TURN**。Row 2 是**零起算第三列 y=64..95 的三個畫格**。
- 原始 `$actor01_1.png` 四列有不同動作，且舊角色是棕色盔甲。**不可把 A35 的 8-frame 256×128 素材直接改檔名蓋掉它，也不可只把新綠甲移動列替換後便當成全表 ART PASS**。

## A36 實作的兩條圖集候選
1. **現行 32px 相容格式**：在原 96×128 PNG 上只替換 Row2 三格；其他 **9 格_RGBA 完全不變**，由程式逐像素驗證。已生成兩種 private lab：A62-approved baseline（三格皆為核准 RUN1/2/3）與 A35-AI alternative（三格為核准 RUN1、真 PixelLab A35 F3、F7）。各來源 48px RGBA 用透明背景與 nearest-neighbor fixed resize 38×38 後中心裁至 32×32，**美術細節確實損失，非原畫質**。
2. **48px cell 高保真實驗版**：144×192（每格 48×48，3×4），Row2 的三格完整貼入來源 48px，不縮放、逐 pixel identical。舊的其餘 9 格整張 nearest-neighbor 1.5x，因此**全表風格不統一且 Godot 可載入 ≠ VX 已可直接換裝**。
3. **A35 8-frame 局部替換測試**：將過度跨步的 F6 替成 exact A62 RUN1 neutral，剩餘 7 格原 PixelLab RGBA bytes unchanged，附 before/after GIF/PNG；**F7 手部原始問題仍未解**，不可宣稱修復完成。正式 FS RUN 三格 loop 應用順序為 **F0→F1→F0→F2**。

## 真正引擎顯示與動畫（非 Photoshop）
- 遠端真實桌機 `DESKTOP-90VT437`，Godot `4.7.2.stable.official.ed1daf0bf`，真 **AMD RX 6700 XT / OpenGL 3.3 Compatibility** 啟動。
- **GPU Sprite2D/texture-region QA PASS**：從三組候選 PNG 讀圖，在 Godot 的 `SubViewport` 依 Row2 裁切並 nearest-neighbor 顯示。三組格位為 A62 32px approved、A35 32px AI、A35 48px；全部圖集尺寸與 region 正確，輸出**實際 GPU 畫面 1152×1008**，每 4px sample 的非背景像素數 **9,061**。真 [GPU 截圖](https://drive.google.com/file/d/1XlOa2TUYFkX0bCS6F1rYfgdF9Knp4sFZ/view)。
- **GPU AnimatedSprite2D 4-phase playback PASS**：另在 Godot 以真正 `SpriteFrames` 由 Row2 建立四相位貼圖 region `[0,1,0,2]`，播放速度 8fps，**frame_changed 取得 12 events：`[1,2,3,0,1,2,3,0,1,2,3,0]`**，意即三個完整循環。引擎列印 `GODOT_FSJ_MOVE_ANIMATEDSPRITE_4PHASE_PASS events=12`、退出碼 **0**，並寫入[真 GPU 截圖](https://drive.google.com/file/d/13hP4zOOlqgLELMCb-R39gmKU6eLGLsFU/view)。
- Godot 測試放在 owner-only Drive [A36 可重跑 Godot staging 專案](https://drive.google.com/drive/folders/1xN-DBM58Vs-TFgzftXrmupFT0aghhrJT)，含 `project.godot`、`qa_stage.gd`、`qa_loop.gd` 和候選圖集。第一輪 `Color.distance_to` 的 Godot API parse FAIL 已修成 RGB component abs comparison 後真正渲染 PASS，Failure Log 保留。
- **VX 原生戰鬥（Tankentai）NOT_RUN**：沒有打開或覆蓋 E: 原始遊戲工程；本回測試僅證明 Godot GPU 可以載入、正確裁剪與循環。

## PixelLab 對 F7 單格修手實測及否決
- 用真正 A35 原生 F7（SHA256 `6b8c351f6e42bdccbdc4fcfe0fe5d7ee1a2b25853eaa136bb5076d02169e921a`）於 PixelLab 已登入 Creator `Edit image: Standard` 做「**只修左手套下的幾個多餘膚色像素**」測試，UI 顯示 **1 generation**，已正式提交、Gallery **99→100**，保存私人 [原始結果](https://drive.google.com/file/d/1qAUORGXZ1xcDDwYjzGHXYhhMVa6sPWRs/view) SHA256 `d8dc1260f7ead6b4caa8d2be489fb5b578c3e1ff02eb97da558a8a6ce3ce038c`。
- **FAIL**：在 64×64 輸出中**646 RGBA 像素與原 F7 不同**，其中頭部 y=8..30 有 **329 px 改變**；可見 RGBA 色數 **42→76**。模型不是局部修手，而是重描了大量頭／衣／身體；**結果否決、不以 AI 變更替代正式 F7、不以局部貼補掩飾失敗**。PixelLab 的 v3 mask inpainting 官方最低 10 generations，故沒有繼續浪費點數反覆重畫。
- 本輪使用 **1 次訂閱內 generation**。檔案由 E:\Downloads 移入 G: 私人 Drive，Windows TEMP 暫存 F7 已刪。

## QA、備份與接續
- [A36 最終完整 21 檔私有 ZIP](https://drive.google.com/file/d/1KZTywv67UR4SId-kzkLwASeDQvv5kc0V/view)，**161,431 bytes／SHA256 `f384e1453614092970f72df065a60605ddfe6205b7b756b3d3af4e3591aed01a`／Zip CRC PASS／Drive 上傳→回讀 metadata size 與 SHA/CRC 通過／shared=false**。包含 A36 96×128 & 144×192 測試圖集、對照圖、可重跑 Python/GDScript、真 Godot GPU 截圖、PixelLab F7 負例、逐檔 SHA manifest、A36_QA_FINAL.json。
- [A36 圖集 96x128 原圖/核准/AI 三排對照](https://drive.google.com/file/d/12oS2WooyeQKe00SkpY8N-gW8g0CflQ3N/view)、[48px 保真 vs 32px 縮小失真](https://drive.google.com/file/d/1PZHKedtNVSZ_2V9bOKXiUMNmrNttVOIE/view)；[原工程四張真圖集的私人來源保留](https://drive.google.com/drive/folders/1yrJkVRl7RxBfr3A-CdxCTBqgLXGk7sDz)；私人來源與主專案無任何改寫。
- **A37 建議**：不要進一步嘗試以一兩張新綠甲畫格取代已存在且風格不同的棕甲戰鬥表；先選擇統一 Actor01 四列視覺的方式，明確確定以 48px 原稿提升品質並經過 Tankentai 引擎尺寸相容測試。另保留 A35/A36 已成功的雙端 Interpolate，避免 F7 區塊用整圖 Edit 重做。使用者已決定未來走 Godot-first，可先將 A36 的 48px 正版動作優先接入 Godot 正式 BATTLE 系統，再返回 RMVX 校對兼容。

**A36 Seal：SOURCE PASS／Row2 non-target PRESERVATION PASS／Godot GPU+AnimatedSprite2D PASS／Pixellab F7 Edit ART FAIL／visual style ART HOLD／VX native NOT_RUN／main unchanged。**
