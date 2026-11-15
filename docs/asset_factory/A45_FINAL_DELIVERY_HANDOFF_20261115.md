# Forest Symphony｜A45 完整工程與自驗收 Handoff
2026-11-15

## 工程定位
這輪是對 A44 的**實際動作美術**進行自行檢查與修正，不是重做 A42 戰鬥時間軸，也不是正式 FS ATB 系統移植。
- 引擎：Godot 4.7.2
- 角色：A62 核准的 45° 白髮 Actor01
- 來源：A44 正式 ZIP，SHA256 `a1433c135d6963082259c8573e6004a4ef35d263fe956eb379e34d60f7288443`
- GitHub 分支：`feat/fs-asset-factory-v1-20261107`
- GitHub A45 實際程式／素材 Commit：`aa0d3e00c81f6a238eab003c639a3a02cde4c02b`
- GitHub 工程：[tools/asset_factory/godot_a45](https://github.com/showpei1203/forest-symphony-rmvx/tree/feat/fs-asset-factory-v1-20261107/tools/asset_factory/godot_a45)
- 私人 Drive 完整專案：[A45 ZIP](https://drive.google.com/file/d/1_WyaQzVi6hJqSxayRu1Xy_h9BGQR67dk/view)

## 逐幀自行發現的 A44 真問題
1. F6 身體輪廓旁有不應存在的 **7px 分離浮點**，座標 x55–56／y40–43。
2. F5–F8 大跨步令腿長、角色重心和腳步比例不自然。
3. F6–F7 長金色「L」折線特效形成像第二把劍的視覺殘影。

## A45 已完成的真實修改
- 重畫 12 幀 Body（修正股腿比例、支撐腳／前腳落點）、FX（短弱透明追蹤），保留與角色相配的劍身 Weapon 和 A62 頭部美術。
- 雙腳間距從原本誇張跨步縮至 10–14px；F3/F4 蓄力、F6/F7 命中時腳步原地固定，不再在延續幀滑動。
- 不以手繪報表冒充檢查：用**實際輸出的圖片**重新偵測棕色靴子的色塊重心，逐幀確認落地；確認每幀 Body 都只有一組 8-connectivity 連續像素輪廓。
- 全 10 個持劍幀，Body 手腕和 Weapon 劍柄距離 0px；Weapon 原劍尖和幾何錨點距離 0px。
- FX 最大 Alpha 130、明亮殘影距劍尖最多 6.08px，不再留下長鉤狀光痕。
- 頭髮／臉部上方 34px 原始貼圖與 A44 全 12 幀完全相同。
- 另有 A44 vs A45 12 幀 1×／3× PNG 和真正 Godot GPU 擷取組合的 12 幀 GIF。
- <https://drive.google.com/file/d/1Lh9lBSNsaczy-nFaW4wQySKgQIQq2gVh/view>：12 幀美術比較
- <https://drive.google.com/file/d/1r9Npv04KGMHIqOb7CtPuKJUoJhZe88yH/view>：A45 真 Godot 動態 GIF

## 驗收數據
- 原生 Godot 4.7.2 + RX6700XT / OpenGL 3.3：12/12 GPU 幀渲染對照，RGBA premultiplication 修正後 0 pixel diff；11 種不同姿勢。
- F6／0.55秒命中、70ms hitstop、A39 呼吸待機恢復：PASS。
- 獨立練習靶 HP 100→75→50、超出範圍 MISS、重複 serial 防重扣、二倍速／取消／回呼中取消防幽靈傷害：PASS。
- ZIP 冷啟動測試：172 entries、其中 171 檔 SHA 零不符；美術腳本在全新解壓目錄重新產出 Body／Weapon／FX 並 SHA 一致、獨立像素幾何 QA、Godot editor import、GPU QA、接觸傷害 QA、主場景 smoke 全數 EXIT 0。
- 正式 ZIP：`FS_A45_ACTOR01_MOTION_SELF_AUDIT_GPU_PASS_ART_HOLD_20261115.zip`
- ZIP 大小 **665026 bytes**，SHA256 **`5913dc77ed3bbb0942585c8f491a4dbd3e6fa1b56464dcb72e478eaf264dddbc`**，CRC PASS，Drive provider metadata `shared=false` owner only。
- 工程原始碼、兩種自動美術檢查、失敗紀錄、原生 QA log：GitHub `tools/asset_factory/godot_a45/`。
- QA 證據：`qa/A45_ART_SELF_AUDIT.json`、`qa/A45_INDEPENDENT_VISUAL_GEOMETRY_QA.json`、`qa/A45_COLD_EXTRACTION_QA.json`、`qa/A45_FAILURE_LOG.md`。

## 不可隱瞞的限制
- **動作基本缺陷修正：PASS。**
- **Godot 原生動畫與獨立命中流程：ENGINE PASS。**
- **完整美術演出：ART HOLD。** 肩膀、胸甲和上半身的蓄力／旋轉仍不夠明顯，尤其 F1–F4 的身體變化小；目前只解決了腳步、漂浮像素與不自然刀光，不可宣稱所有動作已達商用美術標準。
- **正式 Forest Symphony Godot 移植戰鬥 ATB／技能／敵人 HP 整合：NOT RUN。** A45 場景是**獨立練習靶 demo**，不是 FS 全系統。
- A42–A44、E: RMVX 原始素材、GitHub main 和其他 Godot migration／地圖分支沒有修改。PixelLab 0 付費使用。

## A46 專注方向
真正改善**上半身動力學**（肩膀起手、胸廓／腰部扭轉、握劍手和下盤協調），逐幀證明無身體接縫／手腕失連與腳掌滑動，然後原生 Godot QA。不得為了成功率只增加 FX、重跑舊工程或假稱 ART PASS。
