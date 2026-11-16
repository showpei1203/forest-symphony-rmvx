# A15｜PixelLab Skeleton v3 正式 API 48px 轉換：來源實料與生產閘門
2026-11-08｜**技術請求資料 PASS；真正供應商生成 NOT_RUN；美術 NOT_APPROVED。**

## 1. 本輪突破：A14 的錯誤格式已修正

已使用**官方即時** `https://api.pixellab.ai/v2/openapi.json`，於授權遠端 Windows 主機經 HTTPS **唯讀**取得以下真正 schema（沒有使用 PixelLab API Token／沒有建立收費 Job）：
- Endpoint `POST /v2/animate-with-skeleton-v3`，body `AnimateWithSkeletonV3Request`；
- required: `description`、`action`、`direction`、`first_frame`、`first_frame_keypoints`、`keypoints`；optional: `view`、`template_id`、`seed`、`no_background`。
- 原版 F0 可**直接**當 48×48 `first_frame` 輸入，官方 v3 描述是參考圖最多 256×256、輸出同尺寸；不需要像舊版 Aseprite 插件 16/32/64/... 那樣強制補白到 64×64。實際上傳後是否保留精確 48px 尚需檢查，這不是目前的 provider PASS。
- 官方 SkeletonLabel 恰為 18 個**有空格**名稱：`RIGHT ARM` 代表腕、`RIGHT LEG` 代表踝；以此類推。A14 私有資料使用 `RIGHT_WRIST`／`RIGHT_ANKLE` 等內部標籤，不能直接送 API。
- 生成模型會重新畫第一張**輸出**影格（`first_frame` 是獨立參考來源，不是回傳圖像的一部分）。因此 A14 的「回傳第 1 格必須與 F0 二進位相同」錯誤閘門被更正：**原始核准 F0 永遠不變，供應商生成的三格另存並各自接受角色一致性與動作 QA**。
- 官方 `AnimateWithSkeletonV3Response` 返回 `background_job_id`，接續 `GET /v2/background-jobs/{job_id}`，不能重複 POST 以免雙重扣費。

官方頁：https://api.pixellab.ai/v2/docs ，https://www.pixellab.ai/pixellab-api ；API v3 公告中 3 幀估計成本約 USD 0.0436，**僅供估算，並非硬性 billing cap**。

## 2. 實際完成、已交付私人資產

以 A14 真實 26 件來源 ZIP 中的核准白髮 Actor01 F0：
- F0 48×48 SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，保持原圖位元一致。
- 將 RUN／WAITING 各三組原本 64px normalized、畫面原點 (8,8) 的 18 關節坐標，**還原到 48px 原始座標**，並映射至官方 18 個 label；來源／目標骨架各完整 18 點。兩組 exact request JSON 均實際通過本地 schema/來源 SHA 正反測試。
- RUN 三姿勢仍依原正式 FS playback 0→1→0→2，WAITING 0→1→2→1。預設 `direction=south-west`、`view=low top-down` 僅是與白髮 F0 相符的**待視覺驗證候選**，不能稱為已驗證 FS 45° 預設。
- 私人 ZIP 還包含 approved A62 的 144×48 **真實原始 Run Strip**、拆開的三張原始 48×48 PNG 和 GIF 作比較基準；這全部是原版重用，沒有宣稱是新生成動畫。
- 可重跑的完整來源 `a15_pixellab_v3_contract.py`、`a15_v3_single_call_executor.py`、`test_a15_contract.py` 與私人完整 JSON／SHA 清單一起交付。**本地 7/7 真實來源測試 PASS**。
- 私有交付 `FS_A15_PIXELLAB_SKELETON_V3_VERIFIED_48PX_INPUTS_20261108.zip`：**37,352 bytes／15 members／SHA256 `2864ef5c8eaf77a931e830781a359891554cc29f66977372f1565e68d9db80ce`**。owner-only Google Drive Restricted_Binaries，實際上傳再下載、CRC、SHA 同一份一致。私人圖集／inline F0 Base64 request 不發布於 GitHub。

公開方法與合成測試：
- `tools/asset_factory/a15_pixellab_skeleton_v3_adapter.py` 是無秘密、無網路、可由任意 F0 bytes / canonical pose 產生正式 v3 API 請求的核心。
- `tools/asset_factory/tests/test_a15_pixellab_skeleton_v3_adapter.py` 包含 7 個來源測試的合成對應例，拒絕錯誤標籤、坐標越界、錯誤角色 F0、超大海報、三格重複，不要求供應商首格像素與 F0 一樣；不會在 GitHub CI 發出付費請求。

## 3. 為何沒有呼叫真正 PixelLab

**實際 read-only 工具檢查**：遠端已授權 PC 的 `PIXELLAB_API_TOKEN` environment name 不存在，Python `pixellab` SDK 未安裝；本對話的已連線 ChatGPT 外部工具也沒有可呼叫的 PixelLab API action。沒有權限與收費方式之前不能提交真正推論，且不可從 Orca 設定或系統其他秘密檔案「猜」API Token。

私人執行器**預設完全 DRY_RUN**；一次付費呼叫必須在授權環境明確提供 `PIXELLAB_API_TOKEN`、`--paid-one-call`、`--acknowledge-estimated-cost` 與 `--max-estimated-cost-usd`，且有防重 POST 的工作紀錄。最大**估計**成本門檻只是本地防呆，**不是供應商硬性限額**；沒有自動重試。成功後仍把供應商 RAW 三幀、User F0、動態預覽分開存，須人工 1x Art 與真正 VX Engine 驗收。

## 4. 完成與未完成一覽

| Gate | A15 真實狀態 |
| --- | --- |
| 48px 核准 F0 二進位／骨架公式 | PASS |
| PixelLab 官方請求 JSON 的欄位與標籤一致性 | PASS（本地＋即時公開 OpenAPI） |
| 兩動作三幀的請求產物／重用 A62 Run Sheet | PASS |
| PixelLab 實際生成新 RUN／WAITING | **NOT_RUN，0 張新圖** |
| AI 動作自然度、美術保真 | **NOT_RUN** |
| 48px 預期產出在官方實測是否完美 | **NOT_RUN** |
| RPG Maker VX Game.exe / Tankentai | **NOT_RUN** |
| 新 PixelLab 使用額度／費用 | 0 |
| 原正式 main、原版 FS 素材 | 未更動；PR #15 仍 Draft |
| Formal Seal | NO |

**下一個唯一有效工作**：讓已授權 PixelLab API 在不洩漏密鑰的情況下可由本工廠提交**一次 RUN 三幀**，回收真實影格並與核准 A62 48×48 1x 動作比較。若第一個 RUN 美術仍不行，停止擴產、修改共用骨架／姿勢模板，不繼續堆疊表格或手拼腳。
