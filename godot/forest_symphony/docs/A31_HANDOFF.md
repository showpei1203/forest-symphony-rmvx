# FS A31｜Godot 原生樹冠視線輔助實測／Failure Log／Handoff
日期：2026-11-14（Asia/Taipei）
狀態：SOURCE_LOCKED / A30 REGRESSION PASS / A31 PRIVATE NATIVE PASS / GODOT FRAMEBUFFER PASS / USER_ART_HOLD / FORMAL_SEAL_NO

## 來源與限制
- 從 Drive owner-only A30 真實可運行封包，單獨在隔離環境建立 A31 候選；保留 A11 1280×928 Master PNG SHA256 `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530` 與核准 Actor01 F0、A62 三幀原始 PNG。
- A30 的 180 個 32×32 碰撞**候選**格、外部可編輯 TileSet、四站位 197／0／29／0 源遮擋邏輯完全保留。
- 只變更 `scripts/fs_occlusion.gd` 的可選參數 `tree_alpha`、`scripts/fs_character.gd` 的 `assisted_canopy_visibility`（預設 false）/ `assisted_tree_alpha`（預設 0.35），`scripts/fs_world.gd` 增加 `H` 快捷鍵。非樹物件，包含橋欄/屋簷/岩壁，**不作 alpha 變更**。
- Godot 運行時才對角色大小的 PAR overlay 透明度調整；原始 Master 的 RGB、SHA 與獨立 PAR 來源 PNG 的任一像素**絕不改動**。只有選中的 `tree_canopy` 覆蓋角色畫素透明度按倍率改變。視覺不等於物件重新建模。

## 真正執行過的測試
1. Godot 4.7.2 official `--headless --editor` 解析工程 PASS。
2. A30 不變基準 `res://tests/test_a30_real_runtime.gd`，原生 **221/221 PASS**，含真實 `CharacterBody2D` 接觸碰撞、A62 動作、Camera2D、四站位來源圖、動態 PAR。
3. A31 公開程式/人工小型 source-only 影像 `res://tests/test_a31_canopy_public.gd` **133/133 PASS**：預設回傳與顯式 alpha=1.0 位元組一致、樹前遮擋不增加、所有源 RGB 不變、橋欄任一 RGBA 位元組未改。
4. A31 原始私有素材 Godot `res://tests/test_a31_canopy_real.gd` **4627/4627 PASS**：原始 Master SHA、F0/A62、197 原樹後遮擋 mask footprint、透明輔助來源 RGB 不變、關閉 H 復原 byte-identical、樹前 0、橋後 29 且 RGBA 不變、換 Run2/Run3 幀時前景重算。
5. Godot 4.7.2 Mesa llvmpipe／Xvfb 原生 OpenGL 544×416 六場景以上截圖 PASS：樹後（A30 100%、A31 65%、35%、20%）、樹前、橋後。樹後 100% 與 20% 有 181 個 framebuffer RGB 像素改變，樹前與橋後對照 0 差。附 4 倍最近鄰放大圖方便人類作視覺判定。
6. 所有測試都在隔離執行環境，無使用者 PC 新檔案；未花 PixelLab 費用，GitHub 不保存私人原圖。

## 真正的 Failure Log
- A31-F01：初版新測試把 0.65 乘 255 誤判為 167，實際 RGBA8 為鄰近 166；改用 1.01/255 容忍量而非錯誤硬編定點。不得依 synthetic 假設宣稱 Godot RGBA 串流精度。
- A31-F02：原生擷取 GDScript 型別推導失敗（`PackedScene.instantiate()` 動態型別）；修正 `Node2D` 顯式型別後取得 6+ 張真實截圖，沒有把解析錯誤當通過。
- A31-F03：純 65% 樹冠 alpha 的 1x 差異很小（僅 181 framebuffer 像素），視覺幫助有限。以 35% 作可切換候選，20% 作對照，不當作美術驗收成功或唯一正解。
- A31-F04：試跑期間隔離 Linux Godot 的 ALSA 音訊設備錯誤，只因測試機無硬體音訊；使用 `--audio-driver Dummy` 生成 native frame，音效系統仍沒有實測。

## 仍未完成：不可宣稱正式封版
- **Art HOLD**：亮白頭髮可能仍像漂浮頭，主因是角色 F0 48×48 簡化畫風與高精度 A11 Master 不合、樹冠遮罩語意粗糙。alpha 輔助只是可切換的視線友善候選。最終應以 source semantic 和 art 本身改善，而不是用調色蒙混。
- **碰撞 HOLD**：180 個禁行格只是 A11 候選，水岸、樹腳、門口完整可走語意尚未人工核准。
- **城鎮四方向移動 NOT_RUN**：A62 是 45 度戰鬥 Run 三幀，不是四方向 overworld 步行素材。
- **Windows export / gameplay events / save / combat NOT_RUN**。舊 VX 封版與 `main` 不動。

## 下次接續施工
- 在 Godot PR #16 保留 A30 基準，進一步用 source-owned 樹冠、樹幹分層修正 head-only 的 Art Gate，不要無限調 alpha。樹冠語意優先，再處理水岸碰撞與門口路網。
- 若原始美術不適配，探索真正世界城鎮行走用 Actor 素材；不能把 A62 戰鬥 45° 冒稱全方向城鎮動畫。
- 每輪需 GitHub + Drive 回讀、真實 Godot scene/frame QA、Failure Log、Handoff；原始 SHA 與私有美術權限保持不變。

## Cloud delivery readback (2026-11-14)
- Owner-only complete 79-file project ZIP: [FS A31 Godot private R3](https://drive.google.com/file/d/1ENyWqKdqQkmENbQNXUdFOZxt8lHddiQK/view), 28,297,484 bytes, SHA256 `56696d0abe47e2176d2a1624fb4a4a914cb8ffe4b5aaf46cea1deb259dcdcde6`, uploaded/downloaded, SHA/ZIP CRC verified PASS.
- Owner-only [native A31 fourway crop](https://drive.google.com/file/d/1avAhO6gUJjcKHs_jgfI_n7rSbm29NHiX/view), and [Drive Handoff](https://drive.google.com/file/d/1hPCDlIJ57MDryOyRdz2keLoEduVTjUyB/view).
- Exact numeric summary: A30 real 221/221, A30 public 389/389, A31 public 133/133, A31 private 4627/4627, 8 Godot native framebuffer captures. A31 tree RGB framebuffer changed 181px, front and bridge 0px. User art HOLD.
