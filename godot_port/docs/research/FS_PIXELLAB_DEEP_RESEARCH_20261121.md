# Forest Symphony｜PixelLab 2026 深度研究、生成路由與 QA 方案

日期：2026-11-21（Asia/Taipei）  
工作類別：網路研究／流程設計；**未呼叫付費 PixelLab 生成、未產生任何新美術，也未做 Godot 原生驗證**。  
專案引擎：依使用者 2026-11-14 以後的最新指示，**Godot 4.7.2 優先，不回到 VX 施工**。原 repo 2026-11-07 的「VX 為主」舊敘述僅為歷史權威；舊 Master-first 資產來源、座標、驗收概念仍可沿用。  
儲存：GitHub 文字規格，必要的私有圖片／原始工程放私人 Google Drive；不在使用者 PC 新增工作庫。

## 0. 最重要的結論

PixelLab 不是「一句話生成完成 sprite sheet」的工具，而是受參考圖、風格參考、指定姿勢、關鍵影格、色盤與後處理約束的資產引擎。建議實行：**approved reference → 受控候選 → 選圖與修正 → 固定關鍵姿勢 → 補幀 → 統一色盤 → 匯出規格驗證 → Godot 原生預覽 → 人工美術 Gate**。

不要把「動畫可播放」、「像素對齊」、「地圖可匯出」當作 Art PASS。可視化、工程/自動 QA、使用者審美三種 Gate 分開。

## 1. 官方已確認能力（按用途）

| 模組 | 官方能力 | FS 路由 | 風險 |
|---|---|---|---|
| Characters + Create 8-direction sprite | 4/8 方位、參考圖和方向；可輸出 sprite sheets | 主角／怪物靜態身份 anchor | 45° 透視與方向不代表每張完全一致 |
| Style References (Pro) | 多張風格參考生成同風格新資產 | 怪物家族、不同 PAR 物件 | 配色可近似，但輪廓與材質仍會漂移 |
| Animate with Text (New) / API v3 | 參考圖→4~16 偶數幀；預設首張保持原圖；64×64 的 4/8/16 幀範例同價 1 generation | Walk／Run／Idle 第一輪 | 不會保證前後姿態與左右腳邏輯 |
| PixMiniMax | 類文字驅動影格；第三方小樣本拳擊/跳躍較清楚 | Punch／Attack 的候選 | 容易自行加特效與姿態漂移 |
| Skeleton v3 | 3~15 個生成影格；可設定每幀骨架；先 estimate skeleton | 需要控制落腳、擊打、方向的動作 | 骨架正確≠輸出自然 |
| Interpolation / animation-to-animation | 兩端關鍵姿勢之間補幀；凍結合格影格局部重生 | Hit、Knockback、Recover | 中間幀需檢查武器/四肢 |
| Object Creator / create_map_object | 從文字或參考場景生成透明物件，風格匹配；物件狀態與動作 | 樹、屋、岩石、橋、火把 | 可能裁切、尺度不準、透明邊緣不一致 |
| Create tiles Pro | Tiles variations、18 款道路 autotile、16/32 款相接地形、Building kit；32px 建議 | 自然道路、森林地表、村莊建材 | 可接合 ≠ 複雜場景美術通過 |
| Map Workshop + MCP | 建立/讀取/編輯 map、path/rect 畫地形、物件分層與 world pixel 精確放置，Godot/Unity 匯出 | 地圖語意施工 **實驗分支** | 不等於自動滿足 FS 同源 MASTER/RGB/遮蔽契約 |
| Inpaint / Edit Image | 局部遮罩修復、道具/角色修改 | 小範圍瑕疵修補 | 面積限制；多次塗改可能累積漂移 |
| Reduce Colors/Correct Pixelart | 多影格共用色盤、清理雜點 | 全專案色盤一致 QA | 量化仍可能破壞小面積細節 |
| UI Asset/VFX Workbench | UI 元件、字體、VFX | Battle HUD、ATB、法術特效 | 需另做 Godot 對位、九宮格切片/動畫整合 |

官方重要範例定價（可能更新，以當下帳號顯示為準）：
- Animate with Text (New) 64×64／8 幀：1 generation；96×96／8 幀：2；128×128／8 幀：2。**它的幀數規則不直接等同 Pro 工具**。
- Style References (Pro) 43–64px 生成 4×4 候選：10 generations；86–128px 2×2 候選：10。
- Create Tiles (Pro) 依大小與類型 10／15，帶風格圖可能變動。預估報價不代替實際用量紀錄。
- 先低成本 V3／結構路由，只有看得到的限制才升 Pro；每個 job 必須保存 quoted cost 與 actual cost。

## 2. 角色與怪物動畫：FS 專用流程

### 2.1 Identity / View Contract
1. 取**實際已核准**的白髮 Actor01 或怪物母圖，不使用臨時概念圖取代原角色。保存來源 SHA、尺寸、中心軸、feet pivot、view、身體/武器/特效分層資訊。
2. FS 戰鬥是斜 45°／top-down 3/4，不得把 side-view、front-view 或正等距輸出混用；固定 SE / SW 朝向、光源、輪廓、身材比例。方向要由實際像素確認，不能只信 prompt 的「45 degree」。
3. 使用參考概念圖／PixelLab Character Creator 或 style references 生靜態候選；**先通過單張美術與 1× 像素品質 Gate，才進動畫**。
4. 統一 FS 實際核准的 palette；歷史 16 色目標為研究預設，不能在未測原素材前直接當成所有角色/地圖的強制色數。

### 2.2 動作路由（不要一個 API 做所有類型）
- Idle / Breathing：優先可控 Godot Transform/微姿勢，同一幀身份不漂移。確有服飾/髮絲動作需求才 PixelLab v3。
- Run / Moving to Close Attack：先定義足部 F0 兩腳平→F1 左腳領先→F2 兩腳平→F3 右腳領先；使用 V3 候選再以 Skeleton v3 控制步態，避免「四張只是身體晃」。
- Normal Attack：先定起手、接觸、收招 3 個關鍵姿勢，再補到 FS 當前 12 幀輸出；Body、Weapon、FX 各自圖層，不讓模型重新創造手上武器。保留 Godot 0.63s 命中點/70ms hitstop 的已核准行為。
- Cast / Guard：少量關鍵姿勢 + Godot shader／VFX，避免每幀整個角色亂畫。
- Hit / Knockback / Fall：先把受擊、落地、起身的首尾影格手動定好，必要時 Interpolate，不要文字提示一次完成。
- Monster states / evolution：用同一家族 style images 與 base reference 建不同階段；進化時形態可以改，但色彩、剪影與家族特徵必須追蹤。不同階段的素材分開保存，不要把「換色狀態」誤稱不同怪物。

### 2.3 Sprite Sheet Contract
- 最新 FS 戰鬥 12 幀／單幀 64×64；常用 atlas 為 256×192（4 列×3 行）。**PixelLab 產出不是最終 atlas**，要根據來源的 frame count 自動整理、生成 manifest，並驗證對應 Godot AnimationPlayer。
- 保持透明 alpha；禁止因裁切導致 64×64 範圍外手、腳、劍突然消失。
- 每影格 feet-pivot 相對固定；辨認 Loop 與 one-shot 兩類；排序和命中標記與 Godot 接口一致。
- 使用 Aseprite/Pixelorama 手動清理前後幀；輸出 PNG 之後再做自動檢查與 Godot 實際 GPU 連續播放測試。

### 2.4 QA Gates
S0 原始資產來源、視角、透明背景、SHA PASS；S1 靜態身份、色盤、尺寸符合；S2 左右腳交替、握劍/肩肘關節、人體完整；S3 12 幀尺寸/atlas 一致、不裁切，影格差異是動作而非雜點；S4 Body/Weapon/FX 同步且 pivot 正確；S5 Godot 動態播放與打擊時間、循環正確；S6 人工美術驗收。每項各自 PASS/HOLD/FAIL，不以 S3 代替 S6。 

## 3. Ground / PAR：現行 FS 規則與 PixelLab 新機會

**禁止**因看到 Map Workshop 可以輸出地圖，就推翻已存在的 Master-first 流程。repo 2026-11-07 明定：
- A: Authoring_GroundOnly：真地表（被遮物下需合理補畫）。
- B: Authoring_CompletePAR：所有獨立地上物件，同 MASTER 原座標。
- C: Runtime_FullGround：完整 MASTER 圖本身。
- D: Runtime_OcclusionPAR：只覆蓋角色應站在其後方的屋簷、樹冠、前欄杆等。
- 碰撞、通路、Y-sort/footpoint 另外定義。圖片 RGBA 與數學合成吻合都不等於語意/美術正確。

### 新的 PixelLab 生產方法（不改權威）
A. 鎖定 **approved ground3/par3 實際來源**與 32×32、top-down 3/4 色盤。  
B. 用 Create Tiles Pro／Map Workshop 建造道路/樹林配置與**可編輯的語意模型**，可當 master 場景候選之草稿或拆層來源，不是最終權威。  
C. 使用 Object Creator／Style References 產生**完整、不裁切**的樹、屋、橋，每物件固定 world XY、anchor、footpoint、collision、complete_mask、occlusion_mask。獨立整棟房屋+工坊一次處理，不拼接混搭屋頂；樹群設計成跨畫面外延伸，不複製單棵樹排方格。  
D. 帶有完整物件來源/遮罩和已通過風格驗收的整張高品質 MASTER 才能鎖 SHA。A/B/C/D 必須可從同 MASTER RGB 溯源，不能生成四張「看起來很像」的圖。  
E. 地圖臨時測試只在獨立 Godot 場景做，A35 R2/R3 原正式成果不覆寫；原本工作重點是 ART HOLD，NAV、傳送、存檔等已不作為本輪美術優先工作。  
F. 若使用 Map Workshop Godot 匯出，須比對圖層、座標、tileset padding、world pivot、遮蔽前後、碰撞和原始 source hashes；沒有 FS 四圖契約時只可作「候選」，不能報完成。

### 地圖 QA Gates
G0 Master 完整場景的構圖與來源；G1 1× pixel 視覺（無糊、無房屋縫、無樹被裁、地表自然）；G2 Master / GroundOnly / CompletePAR 來源完整與 XY/RGB 註冊；G3 Conditional Occlusion PAR 正確，不把整張 CompletePAR 當前景；G4 角色走到樹後、屋後、橋欄的遮蔽在 Godot 實際正確；G5 水域/樹幹/門口碰撞和腳點一致；G6 QA 截圖、源檔 SHA、Failure Log、人工 Art Gate。

## 4. PixelLab 生成提示詞規約

建議每次固定六欄：SUBJECT / VIEW / SILHOUETTE / MATERIAL & LIGHT / PALETTE / EXCLUSIONS。使用英文可避免歧義，但這是製程偏好，不是官方要求。

角色静態 Anchor：
> One full-body white-haired fantasy swordsman, fixed 3/4 top-down view facing southeast, consistent head-to-body ratio, neutral balanced stance, single character only, boots fully visible, crisp native pixel art, selective outline, existing FS reference palette, transparent background. No text, no shadow baked into background, no extra limbs, no weapons merged into the body layer, no cropped feet.

跑步 4 關鍵姿勢：
> In-place running cycle, fixed 3/4 view southeast. Pose order: both feet aligned, left foot leads with right foot trailing, both feet aligned, right foot leads with left foot trailing. One stable feet pivot, no sliding, no turning, no injury pose, no duplicated limbs.

建築/樹物件：
> One complete elf village cottage with attached side workshop, coherent continuous roof and wall construction, 3/4 top-down pixel art, same approved reference palette and 32px world scale, full object including roof and foundation, transparent background, sufficient padding, no cut edges, no isolated stitched wing, no ground grass baked under object.

只改局部時，採 inpaint 局部遮罩，**不得**把角色/地圖整張重生。

## 5. 生成資料與失敗防治

每一次付費 job 必須保存：
- asset_id, parent_id, source_sha256, job_id, model, version, seed, prompt, negative_prompt, style_refs, palette, dimensions, frame_count, view, direction, cost_quote, cost_actual, output_SHA, reviewer, result (CANDIDATE / HOLD / PASS / REJECT), rejection_reason。
- 錯誤類型：ANGLE_DRIFT / IDENTITY_DRIFT / GAIT_SAME_LEG / WEAPON_DUPLICATED / EXTRA_LIMB / BODY_DISCONNECTED / FRAME_CROP / PALETTE_DRIFT / ALPHA_JUNK / TILE_SEAM / HOUSE_STITCH / FOREST_CLONE / PAR_BAD_DEPTH / BACKGROUND_BAKED / UNVERIFIED_EXPORT。
- 不刪失敗範本；相似錯誤下一輪必須先查 Failure Log，不做完全重複的生圖。
- **付費背景工作逾時只重新查詢保存的 job_id，不重新提交**，避免重複扣款。
- 未做 PixelLab 實際生成、未做 Godot 實機的研究，所有上述流程狀態均為 PROPOSED / NOT RUN。

## 6. 下一輪三個最小可驗證實作（分開，不互相取代）

**T-A Character**：用已核准 Actor01 SE 角度源 64×64；A/B 比較 Text-v3 8／12 幀與 Skeleton v3 3 個 key pose；檢查左右腳和身份；導出 12×64×64 atlas；Godot 連續預覽 + Failure Log。  
**T-B Monster**：現有 PMD0001 熔岩蛙參考→64px 同家族三個候選；選出母圖後同色盤產 Idle/Attack；比較有無 style references 的漂移與成本。  
**T-C Map**：不動 A35 基準圖，獨立 12×12/16×12 個 32px 格子概念驗證；Create Tiles Pro grass/dirt path + map object tree/house + frame-safe 原位 source mask；Master-first 兩個 runtime layer 的遮蔽 Godot 證據。僅在合格後放大至 FS_01_VILLAGE／FS_01_MAZE。

成功標準：不是「有圖、可執行」，而是「明確的素材標準和 1× 視覺 Gate 通過，且可重複複製到第二個資產」。先算每個**合格成品**花費多少，別拿每次生成費用冒充效率。

## 7. 已參照官方教學與第三方實測

官方：
- 官方介紹：https://www.pixellab.ai/docs
- API v2：https://api.pixellab.ai/v2/docs
- MCP：https://www.pixellab.ai/mcp
- 官方創建角色與導出：https://www.pixellab.ai/docs/ways-to-use-pixellab
- Text-v3：https://www.pixellab.ai/docs/tools/animate-with-text-new
- Skeleton 工作流：https://www.pixellab.ai/docs/tools/animate-with-skeleton
- Pro Animation：https://www.pixellab.ai/docs/tools/animate-with-text-pro
- Animation to animation：https://www.pixellab.ai/docs/tools/animation-to-animation
- Style References：https://www.pixellab.ai/docs/tools/consistent-style
- Create Tiles Pro：https://www.pixellab.ai/docs/tools/create-tiles-pro
- Create Tileset：https://www.pixellab.ai/docs/tools/create-tileset
- Create Map Guide：https://www.pixellab.ai/docs/guides/map-tiles
- Inpaint：https://www.pixellab.ai/docs/tools/inpaint
- Object Creator video：https://youtu.be/Hhx9QZwYoZY
- Custom Sprite Animation video：https://youtu.be/r8ySiSRRvz4
- Skeleton video：https://www.youtube.com/watch?v=zBfVT5pwCSs
- Tileset tutorial：https://www.youtube.com/watch?v=jPPznIEK7HY
- Tileset Pro video：https://youtu.be/MbkqpDUFkEg
- Palette tutorial：https://www.youtube.com/watch?v=WSbBuAwRm18
- Character States：https://youtu.be/oCJWxfEwX-o
- RPG UI：https://youtu.be/BdoUMKhZ1Ys
- Map Workshop Interiors：https://youtu.be/qVDkp1baJkU
- Vibe Coding API/MCP：https://youtu.be/fvPmuk-usgw

第三方（不視為官方承諾）：
- 2026-09 Skeleton v3 54-job comparative test：https://github.com/Shilo/pixellab-pip/blob/main/docs/pixellab/pixellab-skeleton-v3-research-spike.md
- Map MCP vs REST：https://github.com/Shilo/pixellab-pip/blob/main/docs/pixellab/pixellab-mcp-vs-rest-route-parity.md
- 2026-11 dungeon crawler asset workflow：https://www.reddit.com/r/aigamedev/comments/1xxwec7/gameplay_footage_of_our_tactical_dungeon_crawler/
- Eight direction actor art workflow：https://www.reddit.com/r/aigamedev/comments/1woi95h/results_of_a_generated_8_direction_character/
- Frame consistency：https://www.reddit.com/r/aigamedev/comments/1wyx1rr/how_do_you_make_pretty_and_consistent_2d_sprites/
- Independent PixelKiln tutorial audit：https://github.com/gfargo/pixelkiln/blob/main/skills/pixelkiln/references/pixellab-roadmap.md

## 8. 本輪 Handoff
- 完成：官方文件交叉核對、教學連結索引、模型/成本路由、FS 角色／怪物／地圖生產建議、QA/Failure Log 欄位。
- 未做：PixelLab 真實付費 job、個人 API key 調用、Godot 工程改動、任何新圖片或 sprite、人體／地圖美術 PASS；以上一律 NOT RUN。
- 最高下一步：以 T-A 或 T-C 獨立試驗，將真實生成資產與原生 Godot 截圖回存私人 Drive，再做人工 Art Gate。
- 存檔方式：本文件只保存公開技術研究與抽象 FS 規範，不含私人圖像／Token。成果僅在雲端。
