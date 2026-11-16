# A28｜A27 新動作三幀之 Actor01 F0 色盤回復實作 + PixelLab 權限診斷（2026-11-13）

**結論：新增可檢視 PNG/GIF 已真正製作及私有雲端回讀 PASS；新 AI pose = 0；PixelLab model generation = NOT_RUN（權限限制）；A28 美術 = HOLD。不是 ASF / PixelLab 新生成動畫。**

## 真正完成的藝術處理
- 從已核准原始 A18 owner-only ZIP 解出真正 48×48 Actor01 F0，核對 SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`。
- 以 A27 **已生成**（但從資訊圖表中擷取）的三張 RUN 候選 PNG 為輸入，使用本輪 `a28_palette_salvage_probe.py` 以 OpenCV CIELAB 正確 int32 最近色彩映射到 F0 **35 色**集合、約 0.60 nearest-neighbour resampling、維持二元 Alpha/透明區 RGB 清零。尺寸完全**不是**正式 48px：三張為 **82×89、81×80、82×88**。
- 色彩統計：從原 A27 每張 ~7,000–8,000 種可見 RGB，變成 **30／27／28** 個符合原 F0 色盤的顏色。三張互相不同，輸出獨立 RGBA PNG、3 幀展示 strip、循環 GIF、前後比較與可重跑源碼。**生成姿勢數=0**，不是重新畫新的動作。
- 第一版 `int16` Lab 色差平方曾整數溢位，白髮變綠黑。**此失敗已定位並將運算改為 int32，重新生成。** 禁止帶著錯誤版宣稱 PASS。
- 美術仍 HOLD：A27 角色方向是側視而非原 45°，服飾／白色披風／頭身比例與 F0 不同，A27 原始透明去背有邊界細屑。色盤技術 PASS 不代表角色一致性或 FS 可用。

## PixelLab 真正連線／權限檢查
1. 核對官方 [PixelLab v2 API](https://api.pixellab.ai/v2/docs) 及 [官方工具費率](https://www.pixellab.ai/pixellab-api)：`animate-with-text-v3` 可由原始第一幀＋文字動作生成最多 16 幀，`animate-with-skeleton-v3` 可由原圖和 18-joint skeleton 生成 3–15 幀。原生輸出先以角色品質驗收，尺寸不限；不能用 48px 擋新藝術。
2. 現有已連結的 Codex PixelLab MCP 仍存在，且實際暴露 `get_balance`、`list_jobs` 唯讀入口。以 remote Codex CLI `--ephemeral --sandbox read-only`，並設成 **approval=never**，嘗試只有上述兩個 GET；**實際回覆 MCP requires approval**，因此兩個 GET 均未執行，餘額與 job list 未取得。
3. **沒有繞過 MCP 核准；沒有讀取 API token；沒有呼叫 PixelLab POST，PixelLab 扣點 0。** 新開的 Orca 瀏覽器公用頁面沒有 PixelLab 登入狀態，不能冒稱具備會員網站操作權限；使用者 PC 未留下新 FS 美術檔案。
4. 為避免違背 FS P0 已核准的付費預算／權限規則，**不自動使用付費供應商**。明確的單次 USD 上限與允許的工具寫入權限尚未確認；此 blocker 需在正式 provider pilot 前解除，不用重做 A18 的同一份 JSON。

## 證據及同步
- 所有新二進位（9 件：3 PNG、strip PNG、GIF、比較圖、QA、README、python 重現程式）放進 owner-only Google Drive：
  - [FS_A28_A27_F0_PALETTE_SALVAGE_ART_HOLD_PRIVATE_20261113.zip](https://drive.google.com/file/d/1Z-Mnoc1lAJFOZYEDd24sVwxrNKmj5Xu7/view)
  - 大小 **240,717 bytes**，SHA256 **`998a1547e9e0b9e5fb7ba2a8610a6aa2be1512578d2ec08c7afc2a510d7bdc91`**，9 entries；Drive metadata shared=false；上傳→下載 SHA／CRC PASS。
  - [A28 GIF 單獨預覽](https://drive.google.com/file/d/1RVVyTeKPmEyYiu9KVpbiYevSgNY9WgAJ/view)。
- GitHub 僅公開這個文字報告與 Current Handoff；原始 F0 / private art 不上公開 repo，正式 main & A62 不改。

## Handoff：下一次真正突破應該是什麼
1. 不要把 A28 調色盤 remap 當成 FS Style PASS，它**無法替換真正參考原圖控制的 PixelLab 新生成**。
2. **優先使用 A18 真正 F0 一次供應商動畫生成**：先一組 `animate-with-text-v3` 4–8 幀 RUN，動作描述確保低俯視 3/4 45°、原灰白髮、深綠鎧甲、雙腳交替，嚴格人物外觀一致；不必先輸出 48px；模型費率官方約 US$0.02–0.05／次，實際請看帳戶的消耗標準。
3. POST 前先取得外部 MCP 的必要核准和明確的單次支付／點數上限。A18 skeleton v3 request 已備妥；若 text-v3 仍變型，改 skeleton v3 以 A17/A18 原骨架來源為參考。不再生成資訊圖表，不再以舊 A62 來源重播冒充成功。
4. 每輪分開給出 `NEW_FRAME`、`ART_STYLE`、`MOTION_COUNTERPHASE`、`SOURCE_LOCK`、`ENGINE_VX`、`CLOUD_SHA`。只要不實際有 provider 動作，標 `PROVIDER_NOT_RUN`，不加裝飾性「PASS」。

**本輪 QA：** `F0_SOURCE=PASS`; `A27_PALETTE_SUBSET=PASS`; `ALPHA=PASS`; `3_STILLS_DISTINCT=PASS`; `DRIVE_SHA_CRC=PASS`; `PIXELLAB_AUTH=BLOCKED`; `PIXELLAB_NEW_FRAMES=0`; `ART=HOLD`; `VX=NOT_RUN`; `MAIN=UNCHANGED`; `SEAL=NO`.
