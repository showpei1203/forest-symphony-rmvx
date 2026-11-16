# A17 | 真實 F0 + 官方 Skeleton v3 的跑步步態預檢修正
日期：2026-11-08。依 [唯一現行 Master 規範](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)；不覆蓋 A15 原始請求，不宣稱新動畫生成。

## 真正核對的來源
- 私有 A15 完整原生輸入 ZIP：`FS_A15_PIXELLAB_SKELETON_V3_VERIFIED_48PX_INPUTS_20261108.zip`。此輪從 owner-only Drive 重新取得原檔，不依交接文字猜測。
- 白髮、深綠服裝的 approved 48×48 F0 SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，本輪完全不變。
- 原 A15 RUN 私有官方 v3 請求 SHA256 `b6110e2f00b8f358f07a1139c0529aa60ea679cc3a405b02a59e2f2a7bf63ae6`，18 個官方關節×3 姿勢。
- 核准 A62 RUN 原圖三幀與 A15 F0 對照。只有既有 A62 是美術核准動作；此次 A17 沒有新生成動作。

## 發現舊版格式 PASS 沒抓到的運動語意缺陷
A15 原始 RUN 的「LEFT LEG 前進投影－RIGHT LEG 前進投影」在 SW（畫面前方為 (-X,+Y)）連續三姿勢為 `[+13, +15, +13] px`，後兩姿勢始終同一隻腳領先，而不是跑步的左右腿輪替。A15 schema 驗證允許三組不同的 18 點坐標，**但沒有驗證真正的左右腳交換**。這正是長期重工所欠缺的 motion-level 檢查。

此外，A15 原 F0 的 RIGHT ELBOW / RIGHT ARM 點距最近非透明像素約 2／3.16px，作為附著於角色本體的初始關節定位不可靠。

## A17 修正內容
- F0 圖像未修改、18 個官方 label 未修改、仍 `direction=south-west, view=low top-down, 48×48, 3 output poses`。
- 僅修改 **私人** A17 RUN request 的初始右肘/右腕位置，令其對原始 F0 的 alpha 距離為 0px。
- 第二、第三姿勢改成真正交換左右腳領先，前進投影差 `[+13, +20, -18] px`，並調整相反擺臂。
- 以 A15 原版 `validate_payload` 針對實際 48×48 F0 原檔再次跑官方請求 shape/關節檢查 **PASS_LOCAL**。
- 狀態僅 `RUN_POSE_GEOMETRY_CANDIDATE`；骨架交叉效果可能過度，真實 v3 模型仍可能生成不自然的腳或錯視角，**ART 和原生 FS 都未驗證**。

## 私有影像和資料保存
- 私有 Drive ZIP：`FS_A17_TRUE_F0_RUN_POSE_PREFLIGHT_CORRECTED_20261108.zip`，`55,740` bytes／`14` files，SHA256 `6598d46e0840c5cfb1c9570f28d38848d43e3f97498fc8cba647fd24f09bee65`，上傳、重新下載 SHA/CRC PASS，owner-only。
- 原始 A15 RUN/WAITING 私人請求 + F0 + A62 核准動作保留，新增修正 RUN 私人請求與真實圖／骨架對照、QA JSON、可重跑程式、SHA manifest。公用 GH 不含原始 F0、base64 圖或付費密鑰。
- 公開可重用門檻程式 `tools/asset_factory/a17_run_gait_preflight.py` 只判定**SW RUN 特定試點的腳步相位**、原圖關節定位。當沒有真的 F0 來源位元組時標 `HOLD_SOURCE_NOT_PROVIDED`，也不替新美術宣稱通過。

## PixelLab MCP 現場重新核對
2026-11-08 `codex mcp get pixellab` 在使用者既有授權 PC 以唯讀執行，確認 PixelLab 仍 `enabled=true`、`https://api.pixellab.ai/mcp`、`default_tools_approval_mode=prompt`，但 `enabled_tools` 只有 **get_balance、list_jobs、list_characters、list_objects、list_images、search_help** 六個唯讀能力。沒有 `animate-with-skeleton-v3`，不等於具備付費動畫呼叫權。
官方公開 PixelLab v2 文件確認動畫需用 `POST /v2/animate-with-skeleton-v3`（3～15 幀）並以 `GET /v2/background-jobs/{id}` 取得結果。現階段**不以遠端查密鑰、偷偷改 allowlist、用公開 GH Actions 上傳私人 F0、或擅自花點數**取代明確的付費授權。
PixelLab 本輪新增呼叫 0、生成幀數 0、Orca 新 Agent 0、FS Game.exe NOT_RUN。

## 真正 Gate 與下一步
| Gate | A17 |
| --- | --- |
| 真實核准 F0/原版 A62/來源 SHA | PASS |
| 舊骨架左右腳交替 | FAIL（同腳領先） |
| A17 修正骨架交替/來源初始關節 | PASS_LOCAL_GEOMETRY_ONLY |
| 官方 v3 準備請求合約 | PASS_LOCAL（仍未提交） |
| PixelLab Provider 新動畫 3 幀 | NOT_RUN |
| 1x 美術保真／自然步態 | PENDING |
| 真正 VX／Tankentai | NOT_RUN |
| 額度消耗 | 0 |
| FS main / 封版 / 原始 F0 | UNCHANGED |

**解鎖條件**：已有 F0 + 私有修正 RUN JSON，現在缺的是經使用者核准的唯一一次費用上限，以及在受限通道讓 `animate-with-skeleton-v3` 可用。首個真實 provider 結果不管成功或失敗，先保留 RAW 回應與原圖對照，不能套用海報做假的 Sprite Sheet，不能未經確認反覆重試。
