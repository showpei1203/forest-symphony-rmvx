# Forest Symphony｜PixelLab 三項正式實驗目標與宏觀施工規範
制定：2026-11-21（Asia/Taipei）  
狀態：**正式納入 Roadmap / SPEC APPROVED；三項實驗本身均未完成生成或 Godot 美術實測**。  
適用：`T-C` 地圖、`T-A` 戰鬥角色、`T-B` 怪物家族。  
先後順序：**T-C 地圖 → T-A 角色 → T-B 怪物**（可預先準備其它兩項的素材，但同一時期只對一個方向進行深度施工）。  
專案引擎：使用者最新指示為 **Godot 4.7.2**；不回到 VX 新施工。過去 VX 資源作為風格／來源權威保留。  
研究依據：[FS PixelLab 深度研究](FS_PIXELLAB_DEEP_RESEARCH_20261121.md)；既有 A35／A52／A54 QA、Drive Handoff 與已批准素材優先，禁止覆蓋。

## North Star — 三項實驗共通的真實完成標準
**目標不是證明工具能生成，而是做出「可放入 Godot、風格合格、可以批次重複製作」的素材。**
- 每項先完成 **1 個完整且可驗收的成果閉環**，不把大量半成品視為進度。
- 同一場景/角色/怪物在原生 Godot 中能正確顯示或播放，技術 QA 與人工 ART Gate 分開。
- 素材來源 SHA／Prompt／模型／生成 job id／成本／拒收原因／輸出規格與 Handoff 可追溯。
- 完成第一個成果後，再生成第二個不同樣本，以驗證量產性；一個成功不等於可以量產。
- 已完成且通過的舊工程不可因新實驗退回重作。未驗證絕不能寫 PASS。

## 正式目標 T-C｜FS 精靈村／森林分層地圖（優先 P1）
**目的**：生產美術達標的森林與精靈村真實 Ground / PAR，優先解除 FS_01_VILLAGE、FS_01_MAZE 的 ART HOLD。不要拿 NAV、傳送、存讀檔當這輪進度。

### 步驟
1. **C0 鎖定視覺權威**：讀取已批准的 ground3/par3、現行 A35 R2/R3、Scene Manifest；固定 32×32 比例、3/4 鏡頭、自然地表、森林跨畫面邊界、村屋統一材質的具體樣貌；設計一張「必須出現的美術要素」清單。
2. **C1 先產生整體可觀賞候選**：PixelLab Create Tiles Pro/Map Workshop（地形道路／規劃）＋ Object Creator/風格參考（完整房屋、自然林群等），構圖先整體通過再凍結單一 MASTER，同批保留物件身份與語意遮罩來源。拒絕把碎片修到看似一棟房屋。
3. **C2 真正產出分層**：同一 MASTER 的 XY/RGB 建立 Authoring_GroundOnly、Authoring_CompletePAR、Runtime_FullGround、Runtime_OcclusionPAR；獨立記錄 footpoint/collision/depth。絕不把完整 PAR 當角色前景。若 Map Workshop 的內建 layer 不足以保持同源，改採 FS 自有 exporter，別勉強。
4. **C3 Godot Native Proof**：使用**獨立實驗分支/場景**展示有自然道路、草花、樹群和至少一棟完整風格一致建築的畫面；角色走入樹冠/屋簷後方的遮蔽，簡單碰撞不穿幫；附 1× 實際渲染截圖及分層對照圖。
5. **C4 從成功小樣擴張**：把已過的可重用樹型、房屋族、地表裝飾與遮蔽語意用於 FS_01_VILLAGE、FS_01_MAZE 的一個完整區段，再檢查整圖風格與密度，不在第 1 棵樹的葉尖花掉整輪。

### 第一可交付成果 / 判定
- 具有 **1 張完整視覺 MASTER + 4 種來源／運行層 + 可運行 Godot 場景／截圖 + 簡要 Manifest + QA/Failure Log** 的完整場景實驗。
- ART PASS 必須無明顯裁切、拼接縫、房屋材質衝突、草地模糊、樹木克隆網格；足點遮蔽與碰撞在 Godot 經抽樣測過。
- 若僅 RGB/技術 PASS 而藝術不合格，結果 **ART HOLD**，不能報完成。

## 正式目標 T-A｜ACTOR01 12 幀戰鬥動作（優先 P2）

> **2026-11-24 最新用戶 ART VETO：** R19–R25 舊人物攻擊美術全數 `ART_REJECTED_FOR_PRODUCTION`。R24/R25 RIG/SOURCE/Godot native 技術紀錄留存但不得當作美術 PASS。正式新增美術必須先走 PixelLab v2 API 的 `estimate-skeleton → animate-with-skeleton-v3`（真實生成整體 45° 白髮綠衣 A62 人物，非舊圖 Python 切手臂）、對關節及握柄 `inpaint-v3`；先小樣本五姿勢 1× 用戶藝術 Gate，再進正式 12 幀／Godot 整合。現 PixelLab Orca／API 連線和付費授權在本對話未證實，故仍 `GENERATION HOLD`，絕不假報已用 PixelLab。權威：`godot_port/docs/authority/FS_TA_PIXEL_LAB_V3_OFFICIAL_REBUILD_PROTOCOL_20261124.md`。


> **R25 source-bound 附註（2026-11-24，後於 R24）：** 在正式 T-A 工作線已實際把 A52 核准人物來源的 9 個可見部件 Sprite2D 掛到原 R24 8 Bone2D（胸腹／近側肩肘腕／遠側手臂／頭／腰／腿等），來源完整 F0 0 pixel 差。Godot 4.7.2 原生 195 PASS + 32 PNG；隱藏武器的人物 F3→F7 確實改變 643/610 px。**這不是源生 LPC 可活動換裝素材**，因遮蔽袖子／手臂背面 underpaint 尚缺，F04 原始手只 1px，ART HOLD。原 FSBattle ACT/ATB 未跑。下一優先工程：真正新畫可活動 source-matched 袖子和手腕握柄，再連正式戰鬥，不能回到 R22 時序重排。R25 private Drive: https://drive.google.com/drive/folders/1CQSo09VKNLHB5_r5n0P_wqfQ-omWmeBs



> **R24 分支最新補充（2026-11-24）：** T-A isolated Bone2D bone-chain ARMED SLASH 機械工程已完成兩組 12-key／24 原生影格及 F7/Hitstop QA；主角目前仍是靜態 A62 參考圖，尚未真正將可見服裝層綁定活動骨架，原生隱藏衣裝 underpaint 缺件，ART HOLD。最新使用者說明「動作太小，不像揮砍」覆蓋這個新增攻擊實驗的舊版 UNARMED 限定；不覆寫歷史拳擊線。下階段 A1/A2 要做真正可變形的來源服裝／手臂綁骨架與新獨立鍵姿，而不是 R22 重排舊影格。正式 FS Battle/ATB 仍 NOT RUN。詳見 R24 Authority/Handoff 及私人 Drive。

**目的**：使用 PixelLab + Godot 已存在的 A52/A54 技術，產出白髮主角同身份、45° 戰鬥視角、具有真正步態／攻擊的可用 sprite sheet。

### 步驟
1. **A0 鎖定 Actor identity**：讀 A52/A54 最新通過的 45° 角度、角色母圖、Body/Weapon/FX 分層、64×64 / 12 幀 atlas 256×192、foot pivot 和攻擊時序，不重新設計主角。
2. **A1 先做兩個完整動作**：RUN（兩腳平／左腳前／兩腳平／右腳前的真循環）和 ATTACK（起手／命中／收招的可讀動勢）。用 Animate with Text v3 出 1 版候選，Skeleton v3 校正關鍵姿勢；必要時使用 interpolation。
3. **A2 建立最終圖集**：保留合法原圖／同款配色、獨立 weapon/FX、腳底 anchor；生成 12×64×64 影格，檢查肢體完整和每張的實際姿勢。
4. **A3 Godot 動態驗收**：角色在原生 Godot 連續播放 RUN/ATTACK，武器接觸、命中事件與已認可的時間點維持；錄製/截圖正反例，同時驗證模型沒有把傷害動作誤生為跑步。
5. **A4 複製到第二角色或動作**：把通過的 prompt、姿勢、atlas、QA 規格套用到另一個角色／戰鬥動作，不為第二個案例從頭想新架構。

### 第一可交付成果 / 判定
- **ACTOR01 RUN + ATTACK** 兩組真動作、12 幀 atlas 與分層、原生 Godot 播放證據、Motion Manifest、QA/Failure Log。
- 方向正確、左右腳實際換位、身材/頭髮/武器身份一致、無截肢、非靜態晃動。任何「能載入但動作語意錯誤」都是 ART HOLD。

## 正式目標 T-B｜PMD0001 熔岩蛙可量產怪物家族（優先 P3）
**目的**：建立能夠迭代進化／合成系列的穩定怪物資產系統，先做一條鏈，再考慮十條、一百條。

### 步驟
1. **B0 鎖定怪物身份**：讀取 PMD0001 既有原圖與實驗 Handoff，保留頭身特徵、型態、視角、色盤規則；聲明哪些地方可進化變異。
2. **B1 建立一條最小進化鏈**：母體 + 兩個有辨識度的進階形態，共用一致的 lava-frog Family DNA；不得三張只是換色，先做靜態視覺對照與身份 QA。
3. **B2 兩種必要動畫**：先為合格母體做 Idle + Attack；必要時 Skeleton/Text v3、Animation-to-animation，規範與角色線相容的 frame、anchor、alpha。
4. **B3 Godot 及重用測試**：原生 Godot 顯示三形態並播放 Idle/Attack；從同一模板生成另一隻同家族不同個體，檢查風格可複製。
5. **B4 批次模板封存**：整理「生成→挑選→修復→圖集→QA→Godot」模板和 generation cost、失敗類型，不提前大量生成 500 隻。

### 第一可交付成果 / 判定
- **3 形態一致的怪物鏈 + 母體 2 組可播放動畫 + Godot 證據 + Family Manifest + QA/Failure Log**。
- 形態足夠差異，保持家族辨識性、同鏡頭、清晰像素與透明背景；仍需 Art Gate。

## 施工節奏：宏觀優先，禁止被細節拖死（正式硬規則）

### 1. 四個大里程碑，不能跳回細節無限循環
1. **M1 可見成果**：先做出完整場景／完整 RUN+ATTACK／完整怪物鏈，不停在參數研究或 1 張候選。
2. **M2 Godot 整合**：能看到真的地圖及角色動作、怪物播放，附 Native Evidence。
3. **M3 致命問題修正**：集中處理會使整件素材不可用的錯誤，像錯誤視角、錯誤步態、斷肢、大幅風格漂移、裁切、大片糊掉、圖層遮蔽錯位。
4. **M4 量產性證明**：相同生成模板第二次成功，才算工作流程可用。

### 2. 細節處理上限（預設施工規則，不降低驗收標準）
- 一個非阻斷小問題，**最多連續修 2 輪**；若仍無法根治，記錄 Failure Log、留下狀態 HOLD，**立即回到更高層的完整場景或下一個大成果**。
- 單一非阻斷細節不得吞掉單輪的主要施工篇幅；規劃資源參考配比：**70% 真實資產與 Godot 整合／20% 品質與驗收／10% 文檔**。配比是優先順序提醒，不能以趕時間取代 QA。
- 小瑕疵：幾個孤立色點、局部陰影偏差、個別不影響辨識的裝飾，列為 backlog 後繼續大方向。
- **不可跳過的阻斷錯誤**：素材身份不符／45° 變成側面／動作實質不成立／肢體或物件被裁到不可用／房屋主體拼接衝突／MASTER 和 PAR 不同源／來源與授權不可追溯／角色深度遮蔽顛倒。遇到這些**換方法或回到上一個完整 checkpoint**，不是同一個 prompt 硬修二十遍。
- 同一原因連續失敗兩次，必須改變方法、模型、輸入參考或生成單位；不得用一樣的參數繼續重複碰運氣。
- **品質 H​​OLD 不等於停工**：當一條做法卡關，保留證據，進行該方向另一個獨立可交付成果。阻斷問題不可升版，不可偽稱修復。

### 3. 每次工作回合的最小有效產出
每輪工作至少嘗試完成**一個完整、可評估的大單位**，而不是只修幾個像素就交代完成。應報：
- 今天完成的**真實新增資產／可運行 Godot 場景／驗證**與所在雲端連結；
- 對照前一個 checkpoint 新增了什麼，未過哪個 Gate，下一個大單位是什麼；
- 若卡在無法存取 PixelLab/Drive/Godot，報明真正阻礙，**不把研究／敘述冒稱實際施工**；
- 任何失敗至少一行分類記錄；一階段完成一定產生 Handoff。
- 使用者最新指示直接覆寫與其牴觸的舊歷史 SOP。

### 4. 範圍界線
- 現階段不要新增存讀檔、地圖傳送、劇情事件、NAV 大改、戰鬥 UI 大改，除非直接阻斷本次美術結果。
- 不反覆修改已認可的原地圖/角色基準；用獨立實驗枝管理新候選。
- 不以 VX 做新施工；所有最終驗證以 Godot 4.7.2 可用程度為主。
- 只在 Google Drive/GitHub 持久保存，避免在使用者 PC 另建資產工廠；有必要 PC 暫存先取得明確授權。
- 模型 API 費用要有當次實際成本；不能依網路舊價格假稱已付費。
- 不設假日期或自動背景承諾。正式狀態由每次實際生成／原生 Godot QA 證據推動。

## Handoff 模板（每次施工結束都填）
- TARGET：T-C / T-A / T-B
- PHASE：M1/M2/M3/M4
- INPUT：素材名／雲端來源／SHA
- DELTA：本輪實作並成功保存的產物、尺寸、影格／圖層數量
- PIXELLAB：使用模型、prompt/ref/seed/job id、generation cost（未執行填 NOT RUN）
- QA：技術／Godot Native／Art 各自 PASS/HOLD/FAIL/NOT RUN，附雲端證據
- FAILURE LOG：缺陷與是否阻斷，對應下一輪方法
- NEXT MACRO STEP：下一個完整成果，不是待修的微小像素清單
- STORAGE：GitHub commit／Drive id／READBACK VERIFY

## 目前看板（2026-11-21）
| 目標 | 優先 | 施工階段 | 驗證 |
|---|---|---|---|
| T-C 分層地圖 | 1 | 正式排定，沿用既有 A35 ART HOLD | 本實驗 NOT RUN |
| T-A 角色與動作 | 2 | 正式排定，沿用既有 A52/A54 | 本實驗 NOT RUN |
| T-B 怪物家族 | 3 | 正式排定，沿用既有 PMD0001 | 本實驗 NOT RUN |

備註：此次僅建立 Roadmap，不宣稱已完成新的 PixelLab 生圖、Godot 原生測試或 FS 美術驗收。
