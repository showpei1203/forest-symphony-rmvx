# T-A ACTOR01｜紙娃娃來源契約修正與 R19 正式拒收
2026-11-22 | STATUS: SOURCE_LAYER_BLOCKED + ART_REJECTED. 此規則取代 R19「ART GATE 待核准」的過時判斷。

## 1. 根本錯誤，已由實際來源與程式核對
R19 生成程式 `godot_port/tools/ta_r19_five_key_boxing_redraw.py` 僅從 `FS_ACTOR01_A62_APPROVED_REFERENCE_64.png` 裁切 HEAD(x17..46,y15..34)；胸腹、腰帶、雙臂、褲子、靴子全部透過 Pillow `ImageDraw.polygon`、`line`、`point` 自行重新建造。
這不是「保留 A62 的原始全身造型」；只是在未經允許的新身體上貼了原 A62 頭部。因此腹部出現巨大的綠色幾何塊、胸腰比例失真、腳步像兩個硬色塊。R19A/R19B 五張都退回，**ART_REJECTED**，不得從它們擴增 12 幀。

## 2. 混淆了兩種紙娃娃／分層系統
- **Forest Symphony／Tankentai SBS 紙娃娃**：武器圖與人物 Body 獨立。原 RPG Maker VX 原始 `$actor01` 32×32×3×4 等圖集和 `$actor01_1/_2/_3` 的動作來源、角度、pivot、裝備錨點皆有契約。只保持 Weapon/FX=0 不等於人物服裝分層完成。
- **LPC／Universal LPC 換裝來源**：官方 pin commit `86a3719ee4a7e2e9fb27c7c152e29a741d3e930a` 的根目錄 `spritesheets/{body,torso,arms,legs,feet,head,hair,...}` 真有多部件來源。但需同動作、同方向、同畫格的原始 component+mask、由正確 draw order 疊合；不是從色盤推測重畫。
- 另外下載的 `LPC_male_diagonal_walkcycle.ora`（真正 8 向 WALK）`stack.xml` **只有 torso、arms、head 三層**，不能冒稱已持有相應的 ACTOR01 深綠上衣、褲子、靴子或原生八方向 ATTACK 分層。
- 歷史 LPC Military P1 模板可複用但當時的完整 equipment_slot compositor **尚未實證完成**，缺原始 layer index 對應實檔時應 FAIL_CLOSED，不能把 recolor 當成完整換裝。

## 3. 新規則：先取得紙娃娃全部同源模組，禁止 AI 自行補腹部
1. 主體 F0 必須是核准的完整身體／服裝／鞋／髮型比例，逐層列出 `approved_head, base_body, torso_outfit, near_arm_outfit, far_arm_outfit, legs_pants, feet_boots` 的原始來源 path、SHA、pose/frame、45° view、alpha 及原始像素映射；配件／武器／FX 另由獨立層處理。
2. 如果只有 A62 head raster 或 LPC 裸身 ORA torso/arms/head，不得自行為 torso_outfit 或 pants 畫綠色多邊形以填補缺來源；`SOURCE_LAYER_BLOCKED`。
3. 先用 source compositing 得到同一套衣裝一致的 **F0**；逐層 1× 核對腹部布料紋理與 A62 approved 的正確前後遮擋，再處理 F3/F5/F7/F9。
4. 不把 32px FS 原版角色、48px A62 Run、64px LPC 8dir WALK 規格混成「全都是 64×64 12 幀原生」。Godot 可用較大 Atlas 做前端，但輸出契約與原始視角需有明確 Adapter。
5. 若完整相容 45° 服裝／前後臂來源不存在，依 ACTIVE MASTER S-A：使用使用者核准的完整 F0 為**單一身份母圖**，再做局部移動、獨立衣料重繪與來源映射；這是待批准的二級路線，絕不可宣稱已完成 LPC 模組式紙娃娃原生 ATTACK。
6. 所有正式 ART / Godot 交付須經 1× 演出、源像素與遮擋 QA、使用者 ART PASS，不能用 CI / SHA / 73/73 GPU 相等代替。

## 4. 稽核與停工
- 新工具 `godot_port/tools/ta_actor_paper_doll_source_gate.py` 對現有 R19 manifest 執行**負向測試**，證明缺衣裝來源、褲鞋與前後手臂 slots，且本體以多邊形重畫，必須拒收。
- 其回報的 `source_schema_complete` 只是格式檢查；就算全部欄位填齊，`production_allowed` 仍須 FALSE，直到 owner-only 真實圖源讀回 SHA、完整遮擋、引擎與 USER_ART_RESULT 審核。
- 因目前驗到的 8 向 ORA 不含衣裝／鞋子，同源套件 **SOURCE_LAYER_BLOCKED**。暫停 R20 主觀重畫，不得刪除舊包、不合併、不得計算美術通過。
- 原 F0/A52/A62、T-B/T-C/主分支不動。私人圖像維持 Drive，GitHub 只存程式、規則、provenance。

## 5. 可核對來源
- Drive MASTER: https://docs.google.com/document/d/1_-R1zP89nwy8nCGtDiGjAgnZaJLSIVXcwiPJBD2rxC8/edit
- A30 原始 FS 角色與 Tankentai： https://docs.google.com/document/d/1k31iFcKx-_lRH6g28NkJGn902JS25utFKNat1Fpg2cU/edit
- A57 原始 18 關節／原版姿勢： https://docs.google.com/document/d/1RMSrLQn9MaW9HcLeFEwUC98Um9KGYWHV/edit
- P1 LPC Military 裝備 source slots： https://docs.google.com/document/d/1gReEG-SxZhqbCuMa2ImSvcre1b8Wbxjj/edit
- R19 舊 Handoff 需以本文件優先（R19 status REJECTED）。
