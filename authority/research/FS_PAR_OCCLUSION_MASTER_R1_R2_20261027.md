# FS Parallax Master + Selective Foreground | R1/R2 重大研究｜2026-10-27

## 研究結論（請先讀）
正式建議採用「Master Ground 完整藝術圖 + PAR 只擷取角色上方遮擋區 + FS ParaPassa 通行 + Light/Shadow原有Overlay」。
原本以 Ground-Exclusive 所要求的「將每棟樹、屋、石從完整畫面全部刪除並補出Ground」只應用於需要分別移動、破壞、替換物件的特殊場景，不應強制套用一般 FS Parallax。
分層的真正需求是 **Occlusion（角色上方遮擋），而不是把場景依物件完整拆開。**
兼容與更新 Authority 需明確分開：R1/R2 是新候選研究，尚未經使用者核准更改既有 FS Ground-Exclusive 正式規範。其他對話及封版工程維持原狀。

## 運行資料與範圍
- 原始 Master: SCENE21.png 544x416（FS 原生展示尺寸）。
- 單一隔離路徑 E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027。
- 使用先前 R0 SAM2 的房屋、左樹與右樹（帶一個反例點精修）的三個遮罩，依預設上半部區域篩選 Occlusion 候選；**不是正式PAR全部物件，也不是已審核語義。**
- 複製 Ground = 原始整張 Master；絕不刪除物件、不補繪草地、不產生 ground seam。
- 真實 FS $001.png 32x32 角色圖，擷取單張後做離線重疊模擬；不代表原生 VX 行走驗證。
- Python PIL/Numpy 遮罩套色不改任何原始場景像素；源 Master 唯讀。

## R1：32px 全方格 vs 32px 格線引導＋局部alpha
- 地圖格網 17x13=221 tiles，tile=32px。
- 高層遮擋物候選遮罩（3個物件）合計 **25,565 pixels**。
- 任何有遮擋像素就整格複製為不透明 PAR → 54 格 / 55,296 pixels。
- 額外「非目標遮擋物」被帶入 PAR 的像素=**29,731**，占整格 PAR 面積 **53.77%**。這部分並非可見接縫（Master同畫面），而是潛在的角色遮擋錯誤。
- 全格模擬裡，角色腳點 (160,197)，actor 總271個非透明像素：全格 PAR 遮住271 / 使用同源物件遮罩只遮住93；無關背景造成多遮178 px。
- 角色腳點 (342,214)：全格多遮30 px；(471,240)：全格多遮112 px。
- 20%/tile threshold只是另一候選，不可認為可以取代邊界遮罩，因為會漏掉 sparse foreground。

## R2：靜態 PAR（甚至遮罩正確）仍不等於正確景深
- 假設每個物件有 foot_contact_y，角色腳點比物件深度靠前時，物件不可無條件前景壓角色。
- 角色腳點 (160,197)：固定遮罩 PAR 仍多遮93px；離線模擬依樹底 contact_y=190 切換前後後，修正這93px（static vs dynamic RGBA diff =93）。
- 注意：這是 **離線 single-actor 條件模擬**，不是 VX runtime 成功。**不能直接以單一$OverlayMap／PAR switch根據玩家位置全域切換，因同畫面的NPC可能站在不同深度！**
- 若未來要完整處理玩家/NPC，應建構 per-object source-aligned occlusion mask，並針對每個角色與物件排序繪製；或限定只對某些複雜走動區採用獨立 Y-sort object Sprite（FS isolated adapter）。
- 優先採用靜態 PAR＋碰撞圈調整來避免衝突；只有確實有穿行需求才引入這套動態處理。

## 三種不同「單獨生出PAR」的定義，不能混淆
1. **從完整漂亮 Master 複製畫面像素，產生透明 Occlusion PAR**：R1 已實際輸出 PAR_32PIXEL_GRID_SEMANTIC_MASK.png，0像素繪畫重算；可行，還有語義與角色深度驗收需求。
2. **先生成透明獨立物件（帶 alpha、統一風格），再用它們與地表融合成整張 Master，保存同座標 Occlusion Ownership**：技術可設計，有利長期全自動產線；但若最後藝術修飾重繪了物件位置，必須從 final Master 再擷取，不准用舊 PAR 搭新圖。
3. **對已畫好的 Master 再請圖像模型獨立『重畫同一位置同一像素 PAR』**：目前不可靠，屬於不應做的兩次隨機生成工作。僅可提供創作草稿，不能冒充 pixel-exact output。

## 技術策略優先級（非實測百分比）
A 高可行：Master完整 PNG → AI建議32px前景候選tile → 透過 SAM2 alpha 複製 Master 原像素 → 人眼快速驗收 → VX既有Overlay。先不引入 Ground 修補或其他引擎。
B 次要：A 方案在少數確有多方向穿行樹、廊柱/房屋周圍追加 per-object foot contact / Y-sort depth adapter。
C 特殊：需要能獨立改建築、移動物件、破壞場景時才用從完整圖分離物件並重建背景；不要用它解決所有 PAR。
D 最不建議：兩次獨立生圖（美術 Ground 與透明 PAR）指望自動對位。兩次生成的物件不可能可靠 pixel-identical。

## 完整生產線（建議）
1. **Master scene 先行**：AI以 SCENE21 / ground3 正式美術標準繪製一張精緻完整圖，尺寸符合32x32網格。
2. **Occlusion design**：輸出重要高度物件的語義檢索框＋foot_contact；以32px map選取遮擋區，優先處理角色可以靠近的區域。
3. **只複製 Master Pixels**：PAR 用RGBA零底只含其可遮擋像素；安全整格可以整格複製；角色可能接觸的混合格採局部alpha遮罩，不准單純把草地複製壓角色。
4. **禁止改 Master**：master_ground.png 以來源RGBA逐位元檢查；任何 style/inpaint 均在 final Master 完稿之前完成。
5. **通行**：地圖第三層 768..799 特殊tile / ISS ParaPassa，合理阻擋屋、石、樹根，路面預設可走。
6. **景深**：靜態 PAR 在玩家可進入格做腳點掃描；若玩家在物件前方仍被固定PAR遮擋、或多NPC深度衝突→另開isolated dynamic adapter，不要篡改sealed核心。
7. **動畫**：原FS Animated Parallax v2.1 在 Graphics/Parallaxes 的 _1..N 名稱輪播；動畫區域外須保持原像素不變，靜態 PAR 不動，不可在 overlay Ground(減算)取代 base。
8. **原生驗收**：1×人物巡迴／腳點／四方向／縮放 nearest／場景 scroll／switch201-205／光影／動態檢查；Gate A-F及使用者美術審核。
9. **批次推進**：先17x13，正式視覺通過再做40x29(1280x928)，不能把技術成果誤認藝術完成。

## 檔名與腳本注意
- 美術主圖：Graphics/Parallaxes/<name>.png；動態序列 <name>_1.png... (目前map10每40 frames)
- 遮擋：Overlays/Par<map_id>.png（HK-UOM ParSwitch203；獨立 viewport 位於角色上）
- Light/Shadow：Overlays/LightX.jpg、ShadowX.jpg（官方FS現有檔案契約；201/202、205）
- GroundX.png Overlay 204 是額外混色疊圖 opacity145 blend_type2 **不是完整 Master 底圖**，不可混用！
- 實際核心 145 HK-UOM、146 Animated Parallax、342 ISS ParaPassa、470 Legacy SafetyPatch, protected page 482/483/484 不動。

## Gate 狀態
- 靜態Master完整保留：PASS（流程上，Ground不改圖）
- R1 32px overdraw診斷：PASS DETECTED，證實純方格錯誤
- 同源alpha透明候選 PAR輸出：TECH PARTIAL
- SAM2語義完整性：ART HOLD，右樹仍混入其他灌木
- R2角色景深：單人離線模擬成功／正式FS原生 NOT RUN
- 17x13正式美術及40x29大地圖：NOT BUILT / NOT ACCEPTED
- 商用素材授權：PRIVATE RESEARCH ONLY

## 可重跑與輸出
- occlusion_grid_r1.py : 17x13網格以及32px整格 vs 同源alpha候選＋角色實物覆蓋。
- actor_depth_r2.py : 單人依接地點相對深度切換前後之離線模擬。
- make_occlusion_contact_sheet.py : 1×角色截圖 nearest 3×對照拼圖。
- OCCLUSION_GRID_R1_20261027/OCCLUSION_GRID_R1_METRICS.json、R2_DYNAMIC_DEPTH_SIMULATION.json、FS_R1_ACTOR_OCCLUSION_COMPARE_CONTACT_SHEET.png。
- 上游 R0 SAM2研究資產見隔離目錄；封版腳本未修改。