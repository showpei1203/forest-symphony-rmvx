# FS AI Asset Factory CURRENT_HANDOFF｜A15（2026-11-08）

**現行唯一規則**：[ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。本檔僅記錄實際工程進度，不是新政策。先前 A14 全文已[完整 SHA 不變封存](history/A14_CURRENT_HANDOFF_ARCHIVED_BEFORE_A15_20261108.md)，A13、A11 和 A10 失敗／驗收紀錄也在各自 QA 文件，不應混成現行待辦。

## 本輪真正完成：官方 Skeleton v3 48px 輸入轉換

- 用授權遠端 Windows PC 的**唯讀公開 HTTPS**，實際取得 PixelLab 官方 `/v2/openapi.json` 中的 `AnimateWithSkeletonV3Request`、`Keypoint-Input` 和 `SkeletonLabel`。完全沒有讀取 API token 或提交推論。
- **修正 A14 規格誤區**：v3 不需要為 48px F0 強制補白至 64px；參考圖上限 256px，生成張數 3～15，回傳預期同來源尺寸，但**尚未經真正付費輸出驗證**。直接保留核准原圖 48×48 bytes。
- 真正批准的白髮 Actor01 F0 SHA256：`a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`。其 A62 原始三姿勢 Run 144×48 也重新拆成三張真 48×48 PNG + GIF；**這是核准原版來源重用，不是新動作**。
- 將 A14 RUN／WAITING 各三組 18-joint 64px 正規化座標，依真實來源偏移 (8,8) 精確逆映射至 48px，再將 `LEFT_WRIST` → `LEFT ARM`、`RIGHT_ANKLE` → `RIGHT LEG` 等**完整 18 個官方帶空格標籤**。輸出含原始 F0 base64 的 RUN／WAITING 實際 provider JSON。完整 keypoint 結構／來源 SHA／張數本地驗證 **7/7 PASS**。
- 重要 v3 差異：`first_frame` 是獨立參考圖，不是三張輸出之一；供應商重新繪製影格一，不會被要求與 F0 位元相同。程式保存核准 F0、供應商原始三格與預覽，**人工 QA 合格才轉為正式 Actor `_1/_2/_3`**。
- 真正供應商輸出影格**0 張**；無法因本地 JSON PASS 或 GH CI PASS 就宣稱美術成功。設定 `direction=south-west` 與 `view=low top-down` 為候選，尚需真 1x 對比 FS 45° 方向。所有 48px 輸出、透明背景、外觀／動作均是待驗。

## 真正私人交付與方法程式

- Private owner-only Restricted_Binaries ZIP：`FS_A15_PIXELLAB_SKELETON_V3_VERIFIED_48PX_INPUTS_20261108.zip`。
- 已上傳 Google Drive、再下載回讀：**37,352 bytes／15 files／CRC PASS／SHA256 `2864ef5c8eaf77a931e830781a359891554cc29f66977372f1565e68d9db80ce`**，shared=false／only owner。
- 私人 ZIP 包含 base64 實際請求、F0 PNG、A62 真 PNG/GIF、完整 2 個 Python 執行/驗證腳本、7 個實料單元測試、SHA manifest、A15 詳細 Handoff。**不可將私人 ZIP、base64 原圖、用戶私有 Drive file ID 放公開 GitHub**。
- 公開 GitHub 無圖片/無密鑰實作：`tools/asset_factory/a15_pixellab_skeleton_v3_adapter.py`、`tools/asset_factory/tests/test_a15_pixellab_skeleton_v3_adapter.py`、[A15 QA 報告](A15_PIXELLAB_V3_REAL_SCHEMA_NATIVE_48PX_SOURCE_PILOT_QA_20261108.md)。
- 真正官網 API：https://api.pixellab.ai/v2/docs；估計成本三幀約 US$0.0436，但只是公開價格示例，不是可自動確保的 billing cap。

## 真正阻礙：PixelLab API 認證／費用授權

- 目前此 ChatGPT 沒有可直接呼叫的 PixelLab 已連線工具。
- 授權遠端 Windows PC 用唯讀查詢得到：`PIXELLAB_API_TOKEN` 環境變數名稱不存在、`pixellab` Python SDK 未安裝；**沒有讀取 PC 儲存密鑰／使用 Orca 本地秘密**。
- A15 私有一次性 API runner 預設 DRY RUN，只在**明確 token、一次付費授權及估計費用確認**時提交一次 RUN 並記錄 job ID，禁止隱藏重試。沒有使用 PixelLab 點數。

## Gate 狀態與 A16 唯一下一步

| Gate | 狀態 |
| --- | --- |
| 真實白髮 F0 原檔與 A62 Run 對照 | PASS（核准舊素材重用） |
| 真正官方 v3 schema／18 點 mapping／三幀 JSON | PASS（本地/API contract） |
| PixelLab 連線 + 一次付費生成 | **NOT_RUN** |
| 新 RUN／WAITING 美術影格 | **0 張，NOT_GENERATED** |
| 角色視角與自然動作 ART | PENDING |
| 真正 RPG Maker VX／Tankentai | NOT_RUN |
| 新 PixelLab 額度使用 | 0 |
| Orca 新 Agent | NOT_LAUNCHED |
| 正式 FS main/封版 | UNCHANGED，PR #15 Draft |
| 正式封版 | NO |

**A16 實際唯一有價值的工作：** 在授權 PixelLab 已連線且確認一筆生成預算後，直接拿私有 RUN 精準 JSON **一次** 生成 3 格真 48px 角色，立即執行 native PNG/Alpha/外觀/步態 QA，保留完整 RAW 供人看。若美術不達標，改骨架家族或方向，不再做 F0 位移／貼腿 V4-V9；RUN 通過後才生成 WAITING 或第二位角色。沒有授權也不要轉去亂生成海報。

**目前 GitHub PR HEAD CI**：在此 Handoff 提交後重新核對最新 Actions Run。前一階段 A14 107/107 靜態測試 PASS，A15 新增 7 個合成測試；CI PASS 不能算新藝術通過。
