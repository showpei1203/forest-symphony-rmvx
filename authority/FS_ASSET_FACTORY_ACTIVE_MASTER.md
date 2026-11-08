# FS AI Asset Factory｜唯一現行施工規範
版本：ACTIVE-MASTER v1.0｜2026-11-08｜適用：RPG Maker VX／RGSS2／Forest Symphony
狀態：**ACTIVE on Draft PR #15 only; not merged into main**。更新規範不代表已生產合格美術。

> **從本檔開始。** 未來新對話先讀本檔、P0 雲端保護，再讀 `docs/asset_factory/CURRENT_HANDOFF.md` 查目前工程進度。其他 SOP／Axx 文件不是可自行覆寫本檔的「最新規則」。

## 0. 規則權限與「真實進度」分開

規則決策順序（由上到下）：
1. **使用者當次明確要求與已核准的美術／工程規格**；保留來源與核准範圍，不能猜。
2. **P0 雲端、保護正式封版、來源授權與 SHA**：`docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md`，原有 P1 Source Precheck。
3. **本檔 ACTIVE-MASTER**：兩條產線如何製作及驗收；若和舊 P2/P4/P5、A07/A08/A10 方法相抵觸，以本檔為執行入口。
4. **真正的 FS 原生來源契約**：Ground/Parallaxes、`AnimData.xml`、Anim/Offsets/Shadow、Actor SBS／Tankentai、Script／Switch203、32px world-grid。原生 XML 的實際數據優先於一般教學範例。
5. **技術附錄與實驗紀錄**：A08 22 頁來源研究、舊 SOP V1、A01～A10 Handoff／QA／失敗紀錄是證據或操作參考，不單獨擁有覆寫優先權。

規則≠進度：`CURRENT_HANDOFF.md` 只保留目前檔案、SHA、測試證據、待辦及確定的 PASS/HOLD；不得寫入與本規範相衝突的新政策。不要把 A10 的 Source-first 候選解讀成唯一美術生產法。

## 1. 共同生產架構：高品質母圖保真優先

兩條產線共享：
**美術母圖／角色 F0 → 凍結原始影像與核准範圍 → 分析語意／骨架（不重畫已核准的靜態部分） → 精確轉換 → FS 原生格式 → 自動技術 QA + 1x 美術 QA + 原生 VX QA → 小批次複現 → 才量產。**

目標不是「圖片能分層／能拼成表」，而是：**高品質外觀不退步、語意／動作正確、可在 FS 使用**。任何數據只是其一，禁止以 synthetic CI、SHA、0-pixel RGB mismatch 或漂亮預覽取代使用者 Art PASS、Game.exe PASS。

通用停止條件：
- 相同錯誤在兩個資產重複，或單次例外修整後仍未解決 ⇒ 停止單件 V0/V1/V2 連環修圖，修「母圖來源／骨架／物件家族模板／轉換器」。
- 未找到核准原圖、方向順序、原生 XML、合法足點或付費額度 ⇒ 明確 `HOLD`，不可自動補猜。
- **優先用已經過美術驗收的單張圖測轉換**；不要求每個階段先重畫一張美術較差但比較好切的圖。

## 2. 地圖現行兩條實驗路線與優先順序

### M-A（優先試驗）：高品質「完整 Master」→ 保真 Ground／PAR
1. 先選一張真正達到 FS 風格的完整場景。使用者已核准才標 `ART_MASTER_APPROVED`；其他候選標 `ART_PENDING`。以實際 PNG 尺寸和 SHA 凍結（世界格 32×32，常用視埠 544×416；大型場景可用 1280×928）。
2. **AI 提議**物件、屋簷／樹冠／橋前側欄、遠近、通行／足點及分層遮罩；AI **不重畫** Ground 或 PAR 來取代 Master。從原圖的原始 **XY 像素**直接產生 Runtime FullGround 和 PAR。
3. `Runtime_FullGround = 完整、未移位的 Master`。只有在合法人物位置應覆蓋人物的像素，才由同源 Master 原 XY 抽入 `Runtime_OcclusionPAR`；禁止橋面木板、水、道路、低地草花進前景遮擋。
4. 保留 `Authoring_GroundOnly`（必要時補全被物件遮住的地面）與 `Authoring_CompletePAR`（可追溯全部地上物件），形成 FS 四圖契約。但它們是**Authoring 資料**，不等同 Runtime 覆蓋人物的遮罩。
5. **雙獨立門檻**：
   - 像素保真：同大小、同原點、原始 XY、PNG 對齊；重組像素相同或記錄色彩轉換舍入容許值；不得因「看起來差不多」忽略移位。
   - 遊戲語意：合法人物腳位、不同方向與姿勢的前／後遮擋、Switch203、碰撞、水域與屋簷。這些不會因重組零誤差而自動通過。
6. 整體場景 1x 畫面美術先驗收，**再量產**。不可為了拆遮罩而讓一棟房子或整群森林變醜。

### M-B（備選／量產路線）：獨立來源物件 → Master → 四圖
- 來源圖像和獨立物件 Alpha／Mask 在合成前建立，物件 Source ID、空間座標和遮擋語意可追溯；適用重複地圖、地形變體、同一族房屋／樹群。
- A10 已驗證來源 Alpha 歸屬技術，但**橋樑／河流水平未達美術**，所以不可因技術較容易 PASS 就壓過 M-A。
- 比較 M-A/M-B：完整 Master 美術保真、座標差異、遮擋語意、ART first-pass rate、native pass、人工修次數和單張成本。以同一組高品質參考＋至少兩張不同場景做公平試驗，勝者才升正式量產線。

### 必要解法界線
同一張 Master 的「前景物件身份」不可單靠相同 RGB 顏色猜。優先利用來源、物件邊界／幾何、語意遮罩和角色深度檢查；若扁平原圖內確實無法分出完整獨立物件，只允許**局部**重新生成來源物件或明確標記不足，不能重新畫整張 Ground/PAR 造成漂移。**RGB 零差≠PAR 語意正確**。碰撞格以合法可走路網驗證，不以 Alpha 有無判斷。

## 3. Sprite 現行轉換路線

### S-A（優先試驗）：高品質單張 F0 → 角色動作
1. 先產出／選用最好的**單張 45° 戰鬥視角 F0**，凍結來源 SHA、核准程度、角色比例、色盤、身體部位、武器紙娃娃規則。**F0 是美術真相**。
2. 從 F0 建立角色骨架（頭、軀幹、雙手、雙腳、尾巴、翅膀等視物種）與已核准 Rig／Motion 範本；模板負責姿勢／節奏／方向，不決定最終美術品質。
3. 對每個動作，平行比較兩種可行路線：**骨架產生姿勢後依 F0 重新繪製**，以及**參考 F0 直接生成指定姿勢**。用同樣的 F0 保真、肢體邏輯、左右腳輪替、重心、循環接點與 1x 像素質感挑選。
4. PixelLab、Aseprite、Pixelorama、其他 Rig 工具只是姿勢或批次編排工具，不能把已核准 F0 變成未核准的新物種／人物。A62 成功步態能重用於同拓樸的角色，但新拓樸另立骨架家族。
5. 先只做一個高品質 F0 的 **RUN + WAITING** 三關鍵姿勢 Pilot；第二個不同角色採同流程驗證複用，之後才拓展攻擊、施法、受傷、閃避、死亡、進化鏈及八方向。

### S-B（保留備選）：原生既有影格／動作模板 → 新造型
- 保留 A62/A63 與 P3_G9 原生來源等已核准動作供骨架與時間參考，但這不代表同物種新造型的美術已核准；不能把套色改名當新怪物。

### 原生格式 **兩套契約，不得混淆**
- **FS Actor SBS**：特定戰鬥動作存三關鍵影格 `_1/_2/_3`，Run loop 可 `0,1,0,2`，Waiting 等依行為實際設定。歷史核准 A62 Run 48×48；城鎮 32×32 是不同系統。
- **PMD native**：每隻、每動作的真實 `AnimData.xml` 才決定 cell、frame-count、duration、CopyOf／Action event、方向排列與 Anim/Offsets/Shadow。已知例：PMD0001 Idle3／Walk6／Attack11；PMD0002 Idle4／Walk4／Attack9；PMD0003 Idle4／Walk4／Attack11。生成時「三個姿勢」不能假裝已經是原生 PMD 三／六／十一幀。不能複製單方向影格冒充真實八方向。
- A25 僅外觀歷史核准；A26 五幀 Idle/Walk 候選未封版；A62 Run 某一動作過關不代表所有人物動作過關。

## 4. 量產 Gate（各欄獨立）

每次產物必填：
`SOURCE_VERIFIED | ART_MASTER/F0_APPROVED | TRANSFORM_PIXEL_GEOMETRY | SEMANTIC_OR_MOTION | FS_NATIVE_FORMAT | GAME_EXE_RUNTIME | USER_ART_RESULT | CLOUD_SHA_READBACK | PAID_BUDGET | FORMAL_SEAL`

- SOURCE：真實來源 PNG/ZIP/XML 名稱、SHA、位置、權利、核准範圍。無原檔不得以說明稿當作原檔。
- TRANSFORM：Ground/PAR 相同世界座標重組；Sprite F0 對所有影格的身份、比例、骨架一致性；所有修改有目標來源與差異報告。
- SEMANTIC/MOTION：遮擋、legal footpoint、自然走路與方向、重要負例；由人看 1x 畫面／動畫，不得僅藉 RGB 或 bbox 自動過。
- FS_NATIVE：真正 RPG Maker VX RGSS2／Tankentai、PMD Adapter + XML、Switch203 狀態與動作；Godot 與 Python 預覽只算輔助。
- COST：額度授權前 `PixelLab 新付費呼叫=0`；須先明確上限再執行。Orca 必須證實 read-only／approval 安全權限才能投入新 Agent。
- DELIVERY：程式／規則／合成測試放 GitHub Draft 特徵分支；授權受限制的圖片、PDF、ZIP 在 owner-only Drive；寫入後回讀 SHA／ZIP CRC。PC 只做必要安裝或另有明確授權的短暫隔離 Game.exe 驗證，正式 FS main 與原版封版不得覆寫。
- 不明確的結果一律 `PENDING / NOT_RUN / FAIL_CLOSED`，禁止合併不同 Gate 的 PASS。確認兩張地圖及兩種 Sprite 的轉換及 1x ART/真正 Engine 均達標後，才測 5–10 變體與批次量產。

## 5. 目前 A10 實際工程狀態（不是新政策）

- A10 兩張 1280×928 四圖 candidate 已保存私有 Drive，驗過來源遮罩和靜態合成，但**ELF ART PENDING、FOREST BRIDGE／RIVER ART FAIL_STYLE、Game.exe 203 NOT_RUN、Formal Seal NO**。
- Actor01 Run A62 已有歷史核准動作；Waiting A63 W2 待美術；**A10 沒有新生成 Battle Sprite 動作**。
- 下一施工階段 A11 為**母圖轉換基準試驗**（M-A 與 M-B 對照、S-A 與 S-B 對照），而不是先盲目重新修橋／增加測試數量。
- 每輪實際成果／版本／指令請看 `docs/asset_factory/CURRENT_HANDOFF.md`，不要照 A01～A09 的「下一輪」執行。

## 6. 舊規範檔案的效力與用途（不刪舊證據）

| 檔案／族群 | 目前身分 | 說明 |
|---|---|---|
| `docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md` + 授權 Precheck | **ACTIVE SAFETY** | 僅保護／權利／雲端，與本檔共同執行 |
| `authority/FS_CURRENT_RULES_INDEX_20261107.md` | **ENTRY REDIRECT** | 應先轉本檔；舊 P0–P8 完整文本保留供溯源 |
| `authority/FS_ASSET_FACTORY_BOTH_LANES_RULES_V1_20261108.md` | **SUPERSEDED_METHOD** | 舊 A08 Template-first 方法；不能壓過本檔 F0／Master 保真優先 |
| `docs/asset_factory/FS_SPRITE_FACTORY_SOP_V1_20261108.md` | **REFERENCE_ONLY** | 原生 XML、來源與例外流程仍可參考；作畫優先順序依本檔 S-A |
| `docs/asset_factory/FS_MAP_FACTORY_SOP_V1_20261108.md` | **REFERENCE_ONLY** | 來源物件、32px、四圖、QA 可參考；路線 A/B 優先依本檔 M-A |
| `docs/asset_factory/A08_REPORT_22PAGE_IMPLEMENTATION_AUDIT_20261108.md` + 原始 PDF | **RESEARCH_SOURCE** | 研究依據，非每條範例數值都已獲 FS 驗證 |
| `docs/asset_factory/A08_DUAL_FACTORY_EXECUTION_QUEUE_20261108.md` | **HISTORICAL_PLAN** | 階段時間與優先序由 A11 實驗覆寫 |
| `docs/asset_factory/A01～A10*`、舊 Stage／R17／A36* | **IMMUTABLE_EVIDENCE** | 測試數據／失敗／SHA 真實紀錄；不得把當時判斷當現行方法 |
| `authority/FS_16_ACTION_POSE_REFERENCE_FAIL_CLOSED_SOP_20261101.md` | **NATIVE_POSE_REFERENCE** | 45°姿勢與三關鍵影格規則限適用範圍，不能覆寫 PMD 原生 XML |
| `docs/asset_factory/CURRENT_HANDOFF.md` | **CURRENT_PROGRESS** | 只描述目前工程與下一個實驗，不得獨立生規則 |

### 新對話真正最短讀取路徑
**本檔 → P0／安全 → CURRENT_HANDOFF → 只有當次作業需要才讀特定 XML／技術附錄／私有 QA**。不要先讀完數十份歷史檔再從頭規劃。

## 7. 本規範治理方式
- **唯一方法權威**：只改本檔；任何新用戶方向先在本檔升版本號／記錄變更。原始 A08/A10 SOP 僅註明覆寫，避免「一份規則多個版本都喊 ACTIVE」。
- **資料分層**：規則／實驗計畫／目前進度／已封存證據／美術來源彼此不同。保留差異與反面證據。
- 每次變更至少核對 GitHub 對應 Draft PR HEAD + CI、Drive 鏡像版內容與可存取權限，交接不得聲稱已通過未執行的真正 VX 或使用者 Art。
