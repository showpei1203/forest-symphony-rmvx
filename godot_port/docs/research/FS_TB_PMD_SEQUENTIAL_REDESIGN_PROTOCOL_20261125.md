# Forest Symphony｜T-B｜PMD 編號順序改造規範（SOURCE-LOCKED）

> **2026-11-26 最新使用者追加：** 新怪物製程須與新版高解析 ACTOR01/Mia 母圖同畫風，優先高解析母圖→Flow 單動作 pilot→64/96/128px 同源試驗（128px 優先，未定稿）→美術驗收；大型怪物允許更大畫布，世界比例與像素密度獨立，禁止全體填同格。原 PMD 編號／骨架／相對體型硬條件不變。詳見 [高解析美術與尺寸新規範](./FS_TB_HIGH_RES_ART_STYLE_AND_SCALE_20261126.md)。舊 64px 尺寸為歷史參考，不是新製程限制。

生效：2026-11-25｜狀態：**SPEC ACTIVE / PMD0001 SOURCE QA PASS / 新改造 ART 尚未驗收**  
權威：使用者 2026-11-25 最新指令；適用所有未來 **T-B 怪物靜態生成、進化、技能動畫、素材命名與排序**。與舊 R21「下一步霜晶狼 CHARGE/RELEASE」或舊「每一 PMD 再憑空生三階」相衝突時，以本規範為準。

## North Star：從來源改造怪物，不是自由捏造怪物
- **PMD0001 → PMD0002 → PMD0003 → PMD0004 → ……**。每個 PMD 編號對應該 PMD 原始物種的一隻改造怪物。先做 PMD0001 來源、靜態定稿、QA／必要動畫，再進 PMD0002；不可跳號，也不得同時生成任意其他物種來充數。
- 若原始 PMD 編號屬於一條自然進化家族，可在新 FS 世界觀改寫成新進化線，但**骨架／物種／大小成長關係**必須繼承原 PMD 每一編號的來源。**不能把 PMD0001 自由生成三個非來源階級，再聲稱這樣完成 PMD0001～0003。**
- **鎖定**：動物／生物類型、骨架拓樸、頭／身／四肢連接、主要剪影與背部負重佈局、原物種生長階段、各 PMD 的相對 size、SE45 戰鬥方向、腳點。不同物種應使用對應的腳／鰭／翼／尾，而非每隻預設四足。
- **可以自由改**：配色、元素屬性、紋理、表面材質、背部構造的**語意**、眼睛／裝飾及世界觀。例：「PMD0001 原背部種子」可換成熔岩核心、冰晶囊、機械能量槽等，但原本「小型低伏四足、背上有較大構造」的型態識別與比例不能被洗掉。此例**不是**規定所有怪物必須熔岩化。
- **品質拒收**：物種變成別種、四肢消失／多出、頭身形狀全改、相對 size 顛倒、45° 變正面／正側面、來源無法追溯、僅重新配色就充當新進化，皆 **ART HOLD**，不可只憑 PNG、SHA 或 Godot 載入成功宣稱美術通過。

## PMD 原始來源（已實際讀取，非猜測）
- **來源 G11 原生 PMD 8-dir SE45 DIR_1**：[742-entry owner-private 原始／Production／XML 封包](https://drive.google.com/file/d/1jh4qmzu3vVD8Cr2mkPgPgU189eLohMRd/view)，SHA256 `47fbdaa5c7088c5612c4e53d262a70e64017e965160bd50e55fcf5c12dfe921f`，ZIP CRC PASS。PMD `ORIGINAL_0001/0002/0003` + `SE45_KEYFRAMES/PMD000{1,2,3}/Idle/ORIGINAL..._1.png` 是真正**未改造原生視角**參考；勿把既有熔岩改造圖當成「最原始 PMD」。
- G11 來源：**SE45 = DIR_1，東 E90 = DIR_2**。僅 43 個有真 8 方向動作，其他 15 個單方向動作不可假稱原生 SE45；Godot 4.7.2 是新工程引擎，原 PMD 原生遊戲／VX 引擎 QA 另計。
- 既有改造案例：`PMD0001_STATIC_64.png`、`PMD0002_STATIC_64.png`、`PMD0003_STATIC_64.png` 是先前 lava-frog/basalt 重製**參考案例，不是原始 PMD 圖**。同一 64×64 參考畫布內，alpha-bbox 各為 **38×32、48×45、59×49 px**。沿用後製 body-occupied ratio 參考約 **1.00 : 1.26 : 1.55（寬）**及 **1.00 : 1.41 : 1.53（高）**。G11 ORIGINAL 三階 SE45 Idle 原始本體尺寸另為 **20×19／22×22／26×25 px**；原圖框尺寸 0001=32×40、0002/0003=32×32，**不能拿不同畫布高直接當成生物 size**。
- 已驗證正式私人參考包：[PMD0001～0003 原始／既有改造對照與來源 Manifest](https://drive.google.com/file/d/1p1itnEuUnbZkqe6pRy012tZk8GIR-Avh/view)，8 entries、58,692 bytes，SHA256 `d9d8d4fb292e0122d02acdba497ead947217fb4ec19be117bee1b1bfad32c004`，Google Drive original owner-only。來源 metrology [QA 檔](https://drive.google.com/file/d/1k_jSj8FObcCxWaSgb_m2YcRhD0g7rMxt/view)。
- **目前僅能具體確認 PMD0001～0003 的原始像素與 64px 改造版。PMD0004 以上真正來源尚未查核**；未驗證的 ID 一律 SOURCE HOLD，不可創造一張相似圖片並宣稱對應該編號。
- 私有／第三方 PMD 原始像素不得放公開 GitHub；授權、來源、商業發行條款與非侵權辨識仍是正式對外上架的獨立門檻。

## 固定施工：一隻怪物一個完整閉環
1. **B0 Reference Register**：先查下一 PMD 原始 PNG／native action XML／SE45／生物分類／肢體數／源身體 bbox 和腳點；保留原圖 SHA、來源合法性、PMD 編號、已有改造對比。未驗證 source ⇒ STOP（不扣 PixelLab 額度）。
2. **B1 靜態改造**：以原始一隻 PMD 的**骨架與 silhouette 參考**餵給核准的 PixelLab／圖像生成工具，Prompt 明寫不可換物種、不可憑空改比例、不得另生肢體；用新配色與材料重塑背部／角／冠等特徵。只做一隻完整候選，不同概念不用一次大量抽卡。
3. **B2 Morphology QA**：原始 vs 改造並排（必要時 alpha bbox／重心／腳點／頭身四肢／背負構造示意覆圖），**人工 1× ART Gate** 與原始影像來源 hash 分開；禁止把「像素不同」當成「結構合格」。同一錯誤最多 2 次修改候選，保持 FAILURE LOG、可回復。
4. **B3 動作／Godot**：靜態身份足夠穩定後再做 Idle、Attack、Hurt、KO 或適合物種的動作；真 provider Job ID/usage/原始回傳和首次 seed，Source lock，原始 PNG 不覆寫。獨立 Godot 4.7.2 SpriteFrames/native gallery 與真正 FS Battle integration/owner ART Gate 分開。
5. **B4 Next ID**：PMD0001 以上必要 Gate 依照批准狀態通過後，下一筆 `PMD0002`；**不得為了追求動畫數量而一直在單一創作的霜晶狼／蝙蝠上追加動作、跳過 PMD 系列。** 家族共通 DNA 可以連續，但編號 source authority 始終逐隻生效。

## 自動化硬閘與現狀
- GitHub 可執行 `godot_port/tools/pixellab_tb/fs_tb_pmd_source_gate.py`：官方 G11 原始 ZIP SHA、742-entry CRC、原始 Idle 第一 SE45 frame pixel SHA、序號連續、64px 改造來源與比例、PMD0001 初次 generation plan。負測：跳號／兩足冒充四足／未驗證 PMD0004 **3/3 REJECT**，不消耗生成費。
- 程式／規則：[catalog](../../tools/pixellab_tb/PMD_SEQUENTIAL_SOURCE_CATALOG_20261125.json)｜[首隻 PMD0001 生成規格](../../tools/pixellab_tb/PMD0001_FIRST_REDESIGN_PLAN_20261125.json)；初次 Source/Plan 實際 QA **PASS，paid provider jobs=0，new ART output=NOT_RUN**。既有 lava-frog 檔是 legacy 候選，不可改稱本輪新生成完成。
- **R21 已完成的 108 clips／982 frames、原始私人驗證 ZIP 與 native QA 保留不變；R22 Frost Wolf CHARGE/RELEASE 從「下一優先」改列 HOLD／legacy backlog。** 2026-11-25 起所有 T-B **新怪物**一律 PMD0001 起順序生成。已經合格的 T-B 蝙蝠／狼不刪除、不事後偽裝 PMD 原型。
- 下一個可驗證施工單位：**PMD0001 來源鎖定的完整新靜態改造候選 + 原始 PMD vs 候選 1× anatomy/size ART review + source/hash/cost ledger**。若繼續沿用 lava-frog，須明確標 `REUSE_EXISTING_VARIANT` 並重新對照原始 PMD；如選新元素則須真實生成並保留 job ID，不能當作已完成。

> 一句話：**PMD 給骨架與物種，AI 換外衣和能力；不換掉原本是誰。**
