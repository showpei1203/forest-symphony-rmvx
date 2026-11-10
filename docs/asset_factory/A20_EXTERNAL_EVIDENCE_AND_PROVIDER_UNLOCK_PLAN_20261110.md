# A20｜PixelLab 實務經驗交叉驗證與真正產出解鎖計畫（2026-11-10）

**性質：EXTERNAL_RESEARCH + HANDOFF，不是 ART PASS。** 唯一方法權威仍為 `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md`；真實工程狀態仍依 `docs/asset_factory/CURRENT_HANDOFF.md` A19。不得覆寫它們或修改 main。來源日期：2026-11-10；網路經驗僅作候選，未在 FS 正式實驗。

## 0. 目前真正瓶頸

A19 經私人來源回讀與官方 API 核對，A18 Actor01 RUN 三幀請求已準備（F0: 48x48；18-joint x 3；A18 私人 request SHA256 `e392291d626ff37bb6038d40e0b63d17a7be0fc54df0835d848e50fba546fbfe`）。但 PixelLab POST = **0**；新 PNG = **0**；VX = **NOT_RUN**。2026-11-09 遠端確認 PixelLab MCP enabled，但 enabled_tools 僅六個唯讀，**沒有** `animate_with_skeleton_v3`。A19 GitHub Actions 137/137 synthetic OK 不是美術成果。

**根因排序**：
1. 真實生成通道尚未在授權／付費上打通，骨架與驗證器不等於作品。
2. 自由文字動畫不保證每影格姿勢、步態、方向、loop 和原始 F0 身分。
3. 完整 Master 的物件辨識／語意遮擋不是「讓 AI 重新畫一張 PAR」；重畫將導致原像素不一致。
4. PMD AnimData.xml 和 Actor _1/_2/_3 是兩套不同 native contract。

## 1. 官方能力與規格核查

- PixelLab REST v2：`POST /v2/animate-with-skeleton-v3` 從一張 reference + 第一幀 18 joints + 3～15 組完整 joints 生成影格；`POST /v2/estimate-skeleton` 僅預估一張姿勢，不能取代動作設計。REST 非同步回 job ID，需查 `GET /v2/background-jobs/{job_id}`。https://api.pixellab.ai/v2/docs
- 官方 Skeleton 教學：以舊動畫建立 template；Set reference → Set animation → 對齊、改骨架 → rescale；可固定頭來降低臉部漂移。https://www.pixellab.ai/docs/tools/animate-with-skeleton
- 官方「Animation-to-animation」可利用原始動畫參考；需清楚區分風格參考、首幀、骨架模板，不能保證直接將舊角色動作一鍵轉換為新角色。https://www.pixellab.ai/docs/tools/animation-to-animation
- 新版 Animate with Text 最少 4 幀且偶數，**不符合 Actor 直接輸出三幀**；應用 Skeleton v3 三姿勢原生路線，不要把 4 幀硬說成 3 幀。https://www.pixellab.ai/docs/tools/animate-with-text-new
- PixelLab 官方地圖生成教學是局部 inpaint、保留先前區塊重疊像素來擴充地圖，**沒有自動理解 FS 的 Runtime OcclusionPAR 語意**。https://www.pixellab.ai/docs/guides/map-tiles

## 2. 外部實際踩雷紀錄與可移植教訓

- 2026-09 的獨立開發者經驗：64x64、四方向 idle/walk/attack，PixelLab／GPT Image 出現方向錯、影格不一致、無法使用；提出 LPC 混合方案作替代。這是個人經驗，不是產品整體成功率統計。https://www.reddit.com/r/aigamedev/comments/1wo6frq/best_aiworkflow_for_pixel_art_characters_and/
- 2026-10 的另一位開發者表示 PixelLab 單一提示比純程式補間順暢，但**嚴格限制生成呼叫、先做好原圖與 prompt**，提醒大量亂試消耗資源。此為個案。https://www.reddit.com/r/aigamedev/comments/1xfh1lf/walkthrough_of_setting_up_pixel_lab_for_sweet_2d/
- PixelLab 社群實驗筆記記錄：從 idle 單幀生成的走路 loop 容易接點不連續、僵硬、陰影變異、漂移；**將整張 atlas 當一張輸入，模型未必遵守每格邊界**；先選單一 48px F0，再組 Native Sheet。https://github.com/Shilo/pixellab-pip/blob/main/skills/pixellab-pip/references/animation.md
- 針對 Skeleton v3，按 18 joints 三關鍵姿勢可硬性編排換腳；但 v3 重新繪圖不保證與 F0 pixel-exact，因此 QA 必須保留 source 和 provider 原圖分開。https://github.com/Shilo/pixellab-pip/blob/main/skills/pixellab-pip/references/preset-skeleton-template-animation.md
- RPG Maker 官方 parallax 教學採 **ground background + independent foreground overlay**，不是要求生成第二張不同畫風的地圖。https://www.rpgmakerweb.com/blog/parallax-mapping-in-mz-basics-and-tips

## 3. 下一件「真正會產出」的單次 Sprite Pilot

**P0 授權、安全先決**：需取得使用者對 A18 指定 SHA 一次 PixelLab 收費呼叫及最高金額的明確許可，並驗證安全 approval 模式下可用 `animate_with_skeleton_v3`；不能為通過實驗而自行偷讀 token、改 allowlist、跳過預算 gate 或暗中提交 REST。

取得授權後，直接使用 A18 既有私人 JSON；**禁止重新花一輪時間改骨架**。
1. A19 one-shot provider gate 核 SHA、F0、approval、budget、job-identity 和 private intent ledger，記錄 POST_MAY_HAVE_OCCURRED；僅一次 POST；未知回應不得重 POST。
2. 保存原始 job ID 與 provider RAW 三張 PNG 到 owner-only Drive，回讀 SHA；主 repo 只放去識別 QA metadata。
3. 量測每幀 48x48 / Alpha / RGB 漂移 / 靜態外觀，顯示 1x GIF 按 FS Run `0→1→0→2→0` 演示；判斷腳、反擺臂、頭／武器、自然度。不能以骨架座標 PASS 代替視覺 PASS。
4. 若 artwork PASS，再輸出 Actor `_1/_2/_3`，在授權 VX Game.exe 驗證；若 FAIL，先定 failure class（model redraw identity、gait、weapon hand、camera、artifact），只改最接近根因的一項，限制重試與預算。
5. 同一 rig 必須在**第二名 45° 同體型角色**複現，才能說量產；PMD 怪物須按實際 `AnimData.xml` 的 Idle/Walk/Attack 幀數另做測試，不可冒充三幀。

## 4. 地圖優先方案：同源保真 + SAM 遮罩「候選」+ 遮擋語意

1. 以真正美術達標且有授權的完整 32px-grid Master 當權威。Runtime FullGround = **原版 Master 逐像素不改**。
2. **SAM 3 / 3.1 只作候選 mask proposer**：可用文字／點／方框找出樹冠、屋頂、橋近欄等物件，回傳分割遮罩；不是自動判斷何時該遮擋角色。https://ai.meta.com/research/sam3/ ; https://dev.meta.ai/docs/sam/overview
3. Scene Blueprint/物件來源 ID 指定 `tree_canopy / front_eave / near_rail` 的合法遮擋，並排除 grass, water, deck, path, shadow 等；對每個物件 mask 以語意與 1x 像素輪廓 QA 修正，禁止用色彩相似閾值把草地混進前景。
4. Runtime OcclusionPAR 的每一個不透明像素直接擷取 Master 原 XY 的 RGBA/RGB；**不可重新生成 PAR 紋理、不可縮放模糊、不可移動**。遮擋需依人物足點／深度條件與 Switch203，碰撞獨立驗證。
5. 匯出 4 圖 Authoring_GroundOnly / Authoring_CompletePAR / Runtime_FullGround / Runtime_OcclusionPAR + collision + instance registry；至少測 2 張不同風格場景的 8 個人物站位（樹前/後、屋簷前/後、橋前欄/後、道路及草地負例），並做 VX 原生截圖。
6. 若 SAM 無法在像素低解析準確分物件，不以模型名義強行 PASS，改用原來源物件 alpha / 手工稀疏引導 / 物件族重構。SAM 提供物體分割，不提供 FS 深度邏輯。

## 5. 真正可複現的替代技術（僅候選；未在 FS 測）

- **SpriteKiln** https://github.com/LucasJRamos/spritekiln ：Python/YAML 描述 3D skeleton / shape / animation，輸出 3/4 view、八方向、固定鏡頭的像素圖；無 GPU 或 Blender 必要條件，但風格能否達 FS 48px 需嚴格 1x A/B。源碼 MIT，範例與展示素材授權不同。
- **PixelOver** https://docs.pixelover.io/tutorials/sprite_sheet_8_directions/ ：已有可重現的 3D rig → 8 方向 sprite 工作流；正式 PNG Sheet 匯出需付費，非免付費解法。
- **pseudo-pixel** https://github.com/craigrusselltiu/pseudo-pixel ：參考圖→3D 模型/rig→Blender 多方向 sprite，但其 TripoSG 方案要求 NVIDIA CUDA；使用者 RX 6700 XT 主機不適合當即刻首選。
- **LPC**：成熟 2D 角色構件／動作庫可作骨架或保底美術，卻不保證符合 FS 45° 戰鬥視角或原版角色造型，應獨立驗收授權與風格。

## 6. 嚴格建議的止損機制

- A18 真 PixelLab 首次供應商輸出以前，不增加 A21/A22 只做幾何驗證的階段，也不宣稱新 Sprite。
- 地圖首先只檢驗一張 Master 的 **正確 Runtime FullGround/Runtime OcclusionPAR**，不再次要求 AI 生成獨立美術 PAR。
- 兩條產線分開統計：`raw_provider_images`、`1x_art_pass`、`native_VX_pass`、`credits`、`minutes_manual_fix`、`cross_character_reuse`。任一階段沒有 raw 結果，就實話 `NOT_RUN`。
- 本 A20 僅研究與 Handoff，**生成 PNG 仍 0、PixelLab POST 仍 0、Native VX NOT_RUN**。本輪不修改 P0 保護、ACTIVE MASTER、A19 的 SHA 或 Draft PR 的既有成品。
