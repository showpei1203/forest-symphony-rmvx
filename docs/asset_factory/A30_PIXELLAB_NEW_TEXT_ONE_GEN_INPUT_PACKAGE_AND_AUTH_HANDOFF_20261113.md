# A30｜真正核准 F0 → PixelLab「Animate with text (New)」單次 generation 輸入封包
日期 2026-11-13｜分類：**已實作生成輸入與驗證、尚未呼叫影格生成**
判定：`SOURCE_VERIFIED PASS | 64PNG_PREP PASS | DRIVE_PRIVATE_READBACK PASS | PIXELLAB_AUTH BLOCKED | PIXELLAB_GENERATION NOT_RUN | NEW_ANIMATION_FRAMES 0 | ART NOT_RUN | VX NOT_RUN | MAIN UNCHANGED | SEAL NO`

## 本輪真正完成
- 從 owner-only A18 供應商準備封包取得實際核准 `APPROVED_F0_EXACT_48_PRIVATE.png`（SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`）與 A62 已核准 RUN 第一幀（SHA256 `6b25abb1dd70270171...`）。兩者均為 48×48 角色。
- 已在 ChatGPT 隔離環境真正輸出兩張 **64×64 原圖輸入 PNG**，在透明 RGBA 背景偏移 (8,8) 貼入原 48px 角色，沒有重新上色／重畫／插值／縮放；對原 48×48 crop 比對 **RGBA bytes 完全一致**。兩張均已對照原始 SHA、二元 Alpha 與角色 bbox (13,7,36,42)。靜態對照圖 2×7 倍圖可檢視。
- 兩種起點：
  1. `A30_RUN_START_CANON_PAD64.png`，優先測 RUN 連貫，來源是已核准 A62 RUN_1；注意本身是舊核准幀，不得算新生成。
  2. `A30_F0_CANON_PAD64.png`，備選測角色識別，來源是真正核准 F0；如果第一張成功，不要未經檢查就再消耗第二次。
- 新增文字動作 Prompt（高保真白髮／深綠裝甲／南東向 3/4 視角／雙腿交替／無額外白披風／原像素美術／透明背景）、pre-generation QA JSON、README、可重跑 packager Python。
- **私人 Drive ZIP**：[FS_A30_PIXELLAB_NEW_TEXT_RUN_64PX_ONE_GEN_INPUT_ONLY_PRIVATE_20261113.zip](https://drive.google.com/file/d/1ZvZ5q8oMSIDAjaoH8ZMzTxQ0Mf_-9P4q/view)，**10,375 bytes／7 files／SHA256 `0a026717a03b1952de61d8487a2fe62e7371355eb037b92090bff83834a1f548`**。Drive metadata shared=false，雲端上傳→下載後 sha256 與 ZIP CRC PASS。
- 第一選 `A30_RUN_START_CANON_PAD64.png` 也獨立儲存私人 Drive：[直接原圖輸入 PNG](https://drive.google.com/file/d/1MgbYNn-Y1y28Tbltzh6G7JVVo63xlajE/view)。以上素材皆未放在使用者 PC 或公開 GitHub。

## 為什麼切換這條路線
[PixelLab 官方文件](https://www.pixellab.ai/docs/tools/animate-with-text-new) 的「Animate with text (New)」：輸入單張 reference image、動作提示、偶數 4–16 幀；官方保證第一幀等於輸入；64×64 無論 4/8/16 幀 **示例費用 1 generation**，但以真正登入帳戶 UI 的預覽金額/額度為準。這不是舊的 Pro 文本生成，也不是 Skeleton v3、重做 ASF 或重新分析 18 關節。
推薦唯一第一輪：**以已核准 RUN_START_64 為參考，要求 8 幀 RUN、transparent ON、單次最多一個工作**；取得結果後才檢查其餘 7 幀是否新生成且自然、45° 固定、臉髮裝甲不漂移、左右腳交替。不要把原第一幀當「新生成成果」。

## 連線與授權真相
- 遠端桌機 `DESKTOP-90VT437` 可連；`codex mcp list` 顯示 `pixellab https://api.pixellab.ai/mcp enabled Bearer token`。**工具已設定，但這不代表本輪有權呼叫。**
- Codex read-only 下 `get_balance`／`list_jobs` 需要核准，被 `approval:never` 拒絕（A28/A29）。
- A30 試官方 `codex exec --approve-for-me`，開始時 `approval:on-request`，但工具在該工作階段沒有露出 `get_balance`，沒有進行呼叫。互動式 `codex --ask-for-approval on-request` 在遠端非 TTY 執行環境回 `stdin is not a terminal`。
- Orca browser `https://www.pixellab.ai/account` 確認呈現 `Sign in`，目前不是登入工作階段，不能在該瀏覽器使用帳戶操作。沒有嘗試移出用戶金鑰、繞過 MCP 安全核准，也沒有發出付費 POST。帳戶餘額**未知**，本輪 PixelLab 扣點**0**。
- 要讓真人授權路徑開通，需使用者在可互動的 PixelLab 會話登入並按正常生成流程，或讓既有 Codex 的 MCP 能透過官方核准機制獲允許，不能用硬抓 token 取代。user 的單句「繼續」不被誤解成允許無上限付費。

## 交接策略
1. **停止重做假美術/純技術 smoke**。這次已備好真正原圖，下一次只需要選取生成 PNG。任何後續輸出必須是 PixelLab 實際生成的新幀；實際投入前核對 UI 顯示 `1 gen` 或 USD 不超過用戶核准上限。
2. 儲存 PixelLab 新影格原始 RGBA PNG／GIF 至 owner-only Google Drive，保留 request/job ID 與實際 usage，不得只存漂亮示意圖。
3. 新動畫先做 1x Art Gate 和腿部輪流，再量產 WAIT、ATTACK、PMD；尺寸不受 48×48 束縛，原生 RMVX 匯出最後才做。
4. 若所有核准通道尚未解決：狀態仍 `NEW_FRAMES 0`，**不要再當作 PixelLab 已測試成功**。

## 未動的東西
主 FS main、封版 A62、A18 F0、使用者 PC 本地專案、PixelLab 訂閱及設定皆未改變。
