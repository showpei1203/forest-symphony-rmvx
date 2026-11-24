# FS T-A｜PixelLab 官方 v2/v3 新美術生產規範（2026-11-24）

**這是官方文件研究／工法更正，不是美術交付，也不是 PixelLab 已呼叫成功。** 使用者 2026-11-24 明確判定 R19–R25 攻擊美術「完全不行」；原先 ART_HOLD 更新為 **ART_REJECTED_FOR_PRODUCTION**。歷史 R24/R25 Godot 技術 QA 仍有效，但不得被稱為 ART_PASS、正式人物攻擊或上游 LPC 紙娃娃完成。

## 1. 真實根因
- R25 有 195 個原生測試 PASS、32 張真 Godot 截圖，但素材來自 A52 扁平圖，用 Python `build_r25_parts.py` 切開、以 Sprite2D 跟隨 Bone2D。**沒有呼叫 PixelLab 新生成任何人物攻擊影格；new_art_pixels=0**。
- 原 A52 F04 donor 近手僅 **1 可見像素**，F05 8 個。可見像素分層不是原畫藏在衣服下面的真實手臂、肩膀與袖子。旋轉會顯示斷裂和姿勢不連貫。
- 雖然 R24 大劍弧線機械驗證正確，角色沒有經過專業的逐幀生成和視覺關卡，原始臉部／腹部比例與人類揮砍動作難以保真。CI 只能檢測程式契約，不能代表「好看」。
- 在使用者正式視覺核准之前，**不得繼續拿 R22 改影格順序、R23 拆遮罩、R25 舊圖轉 Bone2D 當新攻擊美術**。也不得把 image-generation 的高解析度概念圖硬縮成 64px 來假裝真 PixelLab 作品。

## 2. 已查核的 PixelLab 官方工具（以 API v2 / 最新文件為優先）
1. `POST /v2/estimate-skeleton`：從現有角色估算原始關節；須人工修正肩、肘、腕、胸骨、重心和方向。來源 https://api.pixellab.ai/v2/docs 。
2. `POST /v2/animate-with-skeleton-v3`：**本專案第一優先的真正新畫動作工具**。把同一張核准 A62 原始參考和每幀不同的骨架關鍵點交給 PixelLab，模型生成新的完整人物像素影格。官方 3–15 幀、最多 256×256；Beta，預估 3/8/15 幀費用約 US$0.0436/0.0513/0.0622，不代表用戶帳號確切扣點。https://www.pixellab.ai/pixellab-api 。
3. `POST /v2/animate-with-text-v3`：先參考原角色產生 4–16 幀動作草案，若需要可當 Skeleton v3 的節奏輔助，但不能取代精確關節配置。https://www.pixellab.ai/docs/tools/animate-with-text-new 。
4. `POST /v2/inpaint-v3`：用 MASK 局部重新繪製真實手掌握柄、肩膀、袖口、肚子／腰帶接縫，保留已核准的其他內容。需另按 PixelLab 顯示的用量核定。https://www.pixellab.ai/docs/tools/inpaint-v3 。
5. `POST /v2/edit-animation-v2`、`POST /v2/transfer-outfit-v2`：跨幀統一衣服／樣式的 Pro 後處理；**不是保證輸出真的獨立上游 LPC 紙娃娃層**。https://www.pixellab.ai/docs/tools/edit-animation-pro ; https://www.pixellab.ai/docs/tools/transfer-outfit-pro 。
6. 舊 `animate-with-skeleton` 是**不同的舊模型**；2024/25 年編輯器教學中的 Freeze-1 / Custom / Fixed Head / Inpainting 是繪製工法，**不能直接假設 API v3 接受同名 JSON 參數**。v3 每一欄位須以現行 `https://api.pixellab.ai/v2/docs` 或 `https://api.pixellab.ai/mcp/docs` 實際查回的 schema 為準，不准編造。

## 3. 已讀官方教學及重要示範
- PixelLab 〈Animate with skeleton〉書面教學：從原角色 Set Reference → 自動 Estimate Skeleton → 人工 Edit Skeleton → 少幀試產、固定滿意幀、修錯誤姿勢與 Inpaint。https://www.pixellab.ai/docs/tools/animate-with-skeleton 。
- 官方 2024-10-26 影片〈How to animate pixel art using a skeleton〉：0:35 Skeleton；3:50 Freeze；6:44 Custom；8:30 Inpaint；11:00 Freeze 更多幀；14:50 Init image；19:15 Template。https://www.youtube.com/watch?v=zBfVT5pwCSs 。此片屬舊 UI 示範，勿當 v3 API 規格。
- 官方 2026-08-29 〈Level Up Your Game: Custom Sprite Animation Tutorial〉：先補完整關鍵動作，再用編輯與插幀建立更自然動畫。https://www.youtube.com/watch?v=r8ySiSRRvz4 。
- 官方 2026-03-13 〈How to Make Walking Animations for Pixel Art Characters in PixelLab〉：4:11 skeleton、7:25 animation-to-animation。https://www.youtube.com/watch?v=8TRHAC3fUpo 。
- 官方〈Animation to animation〉：初始 2 幀迭代，將喜歡的結果設 Reference、再修細節；Tier 2 編輯器功能可能不同於 MCP v3 API。https://www.pixellab.ai/docs/tools/animation-to-animation 。

## 4. 正確的 FS T-A M1/M2/M3/M4
**輸入**：使用正式核准 A62 64×64 3/4 東南 45° 原圖，SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`。鎖定原始白髮、臉型、綠／炭灰衣服、腰、黑靴、整體頭身比例和視角。保留 R24 獨立 Weapon 原素材和 F7 單次命中，避免把刀身烘進 Body。

**M1：先真正用 PixelLab 生成 5 個全身新關鍵姿勢**：F00 準備（原參考不變）、F03 身體回旋＋劍手後拉、F05 肩胸髖帶動斬擊、F07 大幅伸臂、手掌明確握住劍柄中心、F09 斬擊穿過後收招。可以先用 3–5 幀小樣本確認來源與品質。真實 provider invocation / model / tool / cost / seed / image hashes 必須留下；未呼叫請標 NOT_RUN。**不能先對 R24/R25 舊分層繼續程式拼圖**。

**先設藝術門檻**：提供透明背景的 64×64 原生 1×、4× 最近鄰放大、F03/F05/F07/F09 對照及連播 GIF；全身同身份、胸腹穩定、腿部重心自然、肩肘腕相連、握柄對得上真 A52 劍。若任一關鍵姿勢像拿東西、手部只有一個像素、劍身不連／臉髮跑版，標 **ART_REJECTED**，不要進下一階段。

**M2**：5 個新真實人物關鍵姿勢確實 ART PASS 才用其補全 12 幀（v3 或官方建議的修圖／插幀），保持同一 45° 角；輸出 Body 12×64×64 Atlas 256×192，Weapon 原素材獨立，FX 獨立，F00/F11 角色一致。透過 Godot 4.7.2 原生測試真正的動畫、劍柄跟隨 F07、Hitstop。任何大幅劍弧可用獨立 128px 渲染層，不以 64px 裁切劍尖。

**M3**：使用 PixelLab Inpaint/edit animation 對失敗影格局部修正，保留核准角色細節，逐幀正反測、再次 ART Gate。**M4**：第二個真正獨立生成的斜向揮砍新樣本，不可改排列舊 A52 影格冒充第二種動作。

**實際 Godot 全版 FS Battle/ATB/HP integration**：只有真正通過上述 ART 才解除 hold，進主遊戲整合；舊 source/engine native PASS 不能自動流入主分支。

## 5. PixelLab 操作路由和費用
- 本次核對可用當前 ChatGPT 連接器：無直連 `pixellab` 工具。使用者歷史曾透過 Orca 啟用 PixelLab，但不等於本對話已呼叫，也不代表已有可用受權 Proxy。
- PixelLab 官網明確公布遠端 MCP `https://api.pixellab.ai/mcp`，Bearer token 由用戶端保管。https://www.pixellab.ai/docs/ways-to-use-pixellab 。
- 優先：已驗證的 Orca PixelLab MCP；或由使用者明確授權的 API／MCP 路由。現有 GitHub PC Bridge 若非白名單，不得臨時執行任意指令、讀取 secrets 或 GUI。Desktop Remote 0、Codex 0。密鑰不得上傳 GitHub/Drive 或直接回傳對話。
- **在可查證真實額度、支出與用戶授權前，PixelLab generation = HOLD / NO SPEND**。費用估算僅供規劃，不會擅自發送付費呼叫。
- 產生的真正美術、模型回傳、逐幀 PNG、供應商收據、QA 放 PRIVATE Drive；GitHub T-A 分支只存無私密圖像的工具碼、schema、來源 Manifest、CURRENT_HANDOFF、Failure Log。每次回讀真實證據與 SHA。

## 6. ART_REJECTED 與 QA 是兩條獨立軸
Owner R25 ART_REJECTED supersedes prior ART_HOLD wording for production suitability. **R24/R25 technical SOURCE and Godot QA remain PASS with their original scope; their rendered attack art is NOT ACCEPTED**. Prior PixelLab generation in A52 is historical, **no new PixelLab call was made in R23–R25**. R26 本文件只是官方研究規範更正，不得標示為已完成新攻擊美術。
