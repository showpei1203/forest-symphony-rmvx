# A19｜PixelLab Skeleton v3 單次提交保護與真實來源檢核（2026-11-09）

**定位**：接續 A18 私人真正 48×48 Actor01 RUN JSON。不重新生成角色、不修改 main。唯一現行規則仍是 [ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。

## 本輪實際工作
- Owner-only Google Drive A18 ZIP：19,706 bytes / 10 files，SHA256 f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c。已下載、讀取實際 JSON 和再次驗證 ZIP CRC，公開文件不含私人素材。
- A18 private v3 request SHA256：e392291d626ff37bb6038d40e0b63d17a7be0fc54df0835d848e50fba546fbfe。核准 F0 SHA256 a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba。含 3 組 18-joint keypoints。
- 經授權遠端 PC 唯讀 GET PixelLab 官方 /v2/openapi.json，確認 AnimateWithSkeletonV3Request 必填欄位、18 labels、回應 background_job_id 以及 GET /v2/background-jobs/{id}。沒有讀取、洩漏或更動私有 token。
- 遠端 codex mcp get pixellab 今日仍 enabled=true、approval_mode=prompt，但 enabled_tools 只有六個唯讀 get_balance/list_jobs/list_characters/list_objects/list_images/search_help；缺少付費動畫工具。
- 官方網頁三幀估價 US$0.0436，這不是供應商會強制遵守的硬性扣費上限。

## GitHub 實際工程
- [A19 one-shot provider gate](../../tools/asset_factory/a19_one_shot_provider_gate.py)：限定 A18 private JSON 精確 SHA + F0 真 SHA、A18 骨架 PASS，確認明確單次授權且有金額上限和雲端 runner/私人帳本後才接受一次 POST。預設只可執行離線驗證，沒有任何 live call。
- 受限執行者必須在 POST 前留下 POST_MAY_HAVE_OCCURRED 記錄；若可能提交成功但網路回覆遺失，停止一切自動 POST 重試，先由 job history 人工對帳。錄下 job ID 之後只允許 GET 輪詢。單一工作空間私有 ledger 不是跨執行者分散式鎖，需由雲端協調和私有 Drive 保存交接。
- 真 provider 完成後只接收 RAW 三張 48×48 PNG、檢查三幀不同及透明輪廓，保留 user ART 和 VX 原生關卡。
- [A19 synthetic tests](../../tools/asset_factory/tests/test_a19_one_shot_provider_gate.py)：新增 11 項授權、重複提交、逾時拒重試、壞圖片、未完成 job、非雲端執行、費用等測試。
- GitHub Actions [Run 42543921836](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42543921836) completed/success，137 tests OK。這是程式／synthetic 測試，不代表真 PixelLab 生成成功。
- GitHub 寫入過程借用了 owner-only Drive 的 2 個暫存 text/plain，GitHub 程式碼讀回後，這 2 個暫存檔已刪除；正式資料仍只在 Drive/GitHub。

## Gate 狀態
| Gate | 實況 |
| --- | --- |
| A18 真實來源及 F0 SHA | VERIFIED |
| PixelLab 官方 API 契約 | READ_ONLY_VERIFIED |
| A19 11 synthetic 新測試及全部 CI | 137 / 137 PASS |
| 真正 PixelLab 付費 POST | 0，NOT_RUN |
| 新供應商 RUN PNG | 0 |
| ART 1x / VX Game.exe | NOT_RUN / NOT_RUN |
| PR #15 / main | Draft / UNCHANGED |
| 正式封版 | NO |

**下一步**：取得使用者對本次指定 SHA 的明確單筆付費批准、金額上限及受限動畫工具存取，才允許提交一次。使用者僅說『繼續』不是花錢或擅自更改 MCP allowlist 的批准。