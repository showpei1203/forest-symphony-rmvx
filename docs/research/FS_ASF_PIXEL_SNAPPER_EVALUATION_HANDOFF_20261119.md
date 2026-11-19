# Forest Symphony｜Agent Sprite Forge × Sprite Fusion Pixel Snapper｜研究與導入 Handoff

日期：2026-11-19（Asia/Taipei）
類型：**工具技術評估 / 試作規格**。不等於實際安裝、不等於美術產出、不等於 Godot 原生測試通過。
正式狀態：**RESEARCH COMPLETE / INTEGRATION NOT RUN / ART HOLD**。
工作分支：`research/fs-asf-pixelsnapper-20261119`，自 `feature/fs-godot-phase1` 分出，不修改現有已驗收素材或遊戲程式。
原則：本使用者最新指定以 **Godot 4.7.2** 為正式新開發引擎（覆蓋舊版文件中 VX 為主要引擎之敘述）；既有 VX 是只讀兼容參考。所有永久成果只存 Drive／GitHub。

## 1. 上游證據（2026-11-19 GitHub 連接器直接讀取）
- **Agent Sprite Forge** https://github.com/0x0funky/agent-sprite-forge
  - README.zh-TW.md、LICENSE、`skills/generate2dsprite/references/pixel-looks.md`、`skills/generate2dmap/SKILL.md` 已讀。
  - 許可證 MIT。技能包含 master still、同源角色姿勢/視角、pixel looks、hibit、image-to-video 動作、keying / palette lock / loop / retiming / anchors / package、Godot sprite export；地圖側有 `map_bundle`、props/tiles、navigation and export。
  - 真正關鍵：**一個被核准的 Master → 多動作同一身份 → 影片逐格回讀到固定網格／固定色盤 → 可匯入引擎的動畫資料**。
  - 需外部圖像／影片生成能力（可能需要 API 或本機 CLI，並涉及費用）；不是完全離線生圖器。上游展示數字不是 FS 的實測。
- **Sprite Fusion Pixel Snapper** https://github.com/Hugo-Dz/spritefusion-pixel-snapper
  - README.md、Cargo.toml、src/main.rs 已讀。
  - MIT，Rust CLI / WASM，可批次轉換圖、像素網格校正、色盤量化、指定 `--pixel-size` 或 `--palette`。預設調色盤為 16 色。
  - 它**不生成新動作、不保證人物身份一致、不做 Ground/PAR 的語意分層**；是 pixel-cleanup 候選，不是地圖生成引擎。

## 2. FS 限制與不可破壞的契約
1. **角色工作線**：45° 戰鬥角度；現行 Godot 動畫不受 VX 三幀限制。以 A52 已通過的 12 幀 Body/Weapon/FX 分層與事件計時為對照基準；不可無聲把武器烘焙進 Body。64×64 frame / 256×192（4×3）atlas 僅是現有案例規格，應檢查每個角色 fit 並以 Manifest 記錄，而不是讓模型自行改尺寸。
2. **畫面語意**：同一角色母圖控制臉、衣飾、體型、身高比例；每個動作有共享腳底 anchor、尺度、透視和一致色盤。不得把 45° 角色自動改成側面站姿（上游 walk 的 side-view 建議只適用側向移動 demo）。
3. **動作語意**：idle/waiting/run 類為 loop；attack/hurt/cast/death 為 one-shot 或按設計處理。雙腳交替、命中接觸幀、背部與手部連續、持武器連接、起手-接觸-收招均需對照現有 FS baseline。
4. **地圖工作線**：Godot 的精靈村／幽葉迴廊 Art HOLD 專注美術達標；**Master-first** 單一完整畫面定位 → Ground underpaint / semantic mask → 依 Master 原始 XY + RGB 拆分 CompletePAR / OcclusionPAR → 角色遮蔽與碰撞獨立檢查。新的 snapper 不可分別量化 Master 與 PAR，否則 RGB/註冊不再一致。
5. **優先工作目標**：本階段地圖不需加入傳送或讀檔；工具採用也不應轉移到功能施工。

## 3. 建議導入：先在角色線做 A/B，不直接替換正式素材
- **A 組**：保留 A52 完整來源、12 幀動畫、Godot render 與 QA 作比較權威。
- **B 組**：以同一個核准的 Actor01 master（或有合法來源的 PMD0001 怪物）做 ASF 的 reference-guided master、45° fixed-view pose，再做 **idle loop + run loop + attack one-shot**；每個 motion 各自生成，原始 clip、帧、QA 都保留於私人 Drive。
- **C 組**：僅對 B 組拷貝使用 Pixel Snapper **固定 pixel size / 同一明確色盤** 作後製，與 ASF 原本的 `pixel_look.py`/ `pixel_motion.py` 直接輸出相比；先確認會否重複量化、丟失輪廓或增加閃爍。不要無條件「兩個工具疊加 = 更好」。
- **D 組（候選）**：於 FS Maze／Village 的**單個獨立 PAR 小物件**（例如石頭或樹幹）測試 snapper；絕不直接重新量化正式 Master、Ground、OcclusionPAR。ASF `generate2dmap` 可試驗座標、導航資料及 Godot export，但不能取代 FS 同源 RGB/semantic mask 產線。
- 每組首先採 `NOT RUN` 記錄，在真正拿到像素圖／Godot 截圖與數據前，禁止稱 `PASS`。

## 4. 建議 QA 門檻（候選值，正式標準以 FS 當期權威優先）
| 類別 | 必要檢查 | Gate |
|---|---|---|
| Provenance | 每個 frame/clip 都能追溯核准 master、生成方式、source hash、prompt、參數、license | 缺任一直接 HOLD |
| Pixel | 透明度是否只有 0/255、無 spill、固定調色盤、無不規則像素格；輸出不超過專案當期色盤限制 | HOLD 直到定量 + 肉眼皆合格 |
| Identity | 頭臉／服裝／輪廓／武器同源，無裸體幀、重複肢體、截斷、不合理身高 | 任一嚴重錯誤 FAIL |
| Geometry | 所有幀的腳底 anchor、角色尺寸、45° 構圖一致，run 有左右交替步態 | 連續性不符 FAIL |
| Timing | loop 首尾可銜接、attack 接觸幀一致、Godot 命中/Hitstop 事件保留 | 原生播放測試必要 |
| Weapon | Body/Weapon/FX 拆分與骨架連動，攻擊時武器不能飛脫 | 未驗證 HOLD |
| Map PAR | same-XY RGB、邊界無切痕、前後遮蔽正確；碰撞與地表一致 | 藝術與物理各自驗證 |
| Delivery | 原圖/程式/params/QA/Failure Log/Handoff 全部 Drive/GitHub，雲端讀回核驗 | 缺少讀回不算完成 |

**特別注意**：
- ASF Pixel Looks 的例子使用約 48 色 sprite；FS 若正式資產限定 16 色，必須顯式限制并對比可讀性，不能以 README 宣傳效果直接宣稱合規。
- 把 attack 從 image-to-video 取樣可能產生視角漂移和武器變形；這是最高風險項之一，必須逐幀人工驗收。
- Pixel Snapper 對固定色盤**每幀各自處理**可能造成 temporal flicker；需要跨幀統一色盤，先與 ASF 的 palette-lock 比較。
- 地圖結構合法、導航連通、GPU 成功都不是 **美術 PASS**。

## 5. 施工交接 / Next Action
1. 取得 A52 最終核准 Actor01 母圖和 12 幀原生 Godot QA 基準（Drive 私人檔），先核對來源與 SHA；不可從記憶或 README demo 冒充。
2. 在隔離測試路徑驗證 ASF dependencies/route、其 pixel looks / motion 對 **45° 角色**的支援，生成最小 idle/walk(or FS run)/attack 3 動作。
3. 同一輸出跑 Snapper 有/無比較（工具輸出尺寸、palette、alpha、身份變化、幀間閃爍、運行時間），呈現 A/B/C 可視化與原生 Godot 播放證據。
4. 只在上述過關後，再擴大到 PMD001 怪物和 Village/Maze PAR 小物件，不直接重寫正式資產。
5. 全部失敗分類寫 Failure Log，任何成果本輪交付時包含 Handoff 與下一步，不要求使用者自行跑命令。

**本輪宣告**：僅完成來源研究、導入試作規格、GitHub Handoff；尚未安裝兩套工具、沒有執行生成、沒有保存新 PNG、也沒有進行 Godot native QA。舊 A52／A35 等 Art HOLD 狀態不因此更改。
