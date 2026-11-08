# A18｜Actor01 RUN 真實骨架反證與防拉長修正（2026-11-09）

**範圍：只修 Actor01 的 48×48、south-west、3 key poses。不是新的 Sprite，也不是新版 Master。**

唯一施工規則：`authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md`。私人 F0/base64/Pixellab token 不得進入公開 GitHub。

## A17 真實私人來源回讀
- Drive 原始 ZIP：FS_A17_TRUE_F0_RUN_POSE_PREFLIGHT_CORRECTED_20261108.zip（私人 owner-only；不在本公開文件重貼私人連結）。
- 實際下載、解 ZIP 清單 14 檔、CRC、SHA256：`6598d46e0840c5cfb1c9570f28d38848d43e3f97498fc8cba647fd24f09bee65`。
- 對 `A17_PIXELLAB_V3_RUN_CORRECTED_PRIVATE.json` 的**實際** 18 點關節，依左/右髖、膝、足與肩、肘、腕進行數值計算；並非用 synthetic fixture 假裝評估真人。
- 來源 F0 SHA 維持 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，A62 真圖不變。

## 新發現：交替換腳但「骨頭伸長」與手臂錯相
A17 腿領先投影差為 `[13,20,-18]` px，確實換腳。但靜態腳位不是唯一判斷：
- A17 **右髖→膝** F0 約 3.61 px，F2 約 8.06 px，伸長 **2.24 倍**。
- A17 **左髖→膝** F0 4.12 px，F2 6.71 px，伸長 **1.63 倍**。
- **左/右髖相對的前進投影差**為 `[+7,+14,-24]` px，F2 幅度遠大於 F1，且 F0 不是完全的幾何中立姿勢。
- **肩相對的左/右手臂前進差** F1 約 `+1` px、F2 約 `+7` px：雖宣稱相反擺臂，F1 其實未呈現明確的右臂領先。

這表示 A17 的 `PASS_POSE_GEOMETRY_ONLY` 不是足以付費生產的「全身骨架」驗收。A17 歷史證據不可覆寫。

## A18 修正候選（僅 48px Actor01）
使用公開、無秘密的 `tools/asset_factory/a18_run_anatomy_preflight.py` 中 `prepare_actor01_a18_candidate()`，只對**已通過 F0 SHA + A17 位置版本前置條件**的私人 A17 JSON 在 RAM 內產生修正副本。

調整：
- F1：LEFT ELBOW=(17,33)、LEFT ARM=(19,36)，使左腳領先時右臂相對領先。
- F2：LEFT KNEE=(24,38)、LEFT LEG=(28,39)、RIGHT KNEE=(26,38)、RIGHT LEG=(23,41)，避免腿骨伸長與過度交叉。
- F2：RIGHT ELBOW=(33,32)、RIGHT ARM=(34,36)，縮回被拉長的右臂骨。
- 其餘 18 點標籤、來源圖片、F0、F0 keypoints、View、Direction、Seed、3-pose 數量不變。

獨立對 **A17 私人真實座標**套入上述候選並計算的預估值：
- 髖相對左/右足前進差 `[+7,+14,-13]` px，雙腳換領先、兩個 stride 量級較接近。
- 肩相對左/右手臂前進差 `[+2,-4,+7]` px，第二、三姿勢形成反相擺臂。
- F1 / F2 所有 8 條指定上下肢骨段相對 F0 長度比約 **0.90～1.34**（容許窗口 0.60～1.40）。
- FS Actor 播放語意為 **3 儲存姿勢 / loop 0→1→0→2→0**；不能把本測試誤當成 PixelLab 已提供 4 張 frame。
- F0 +7 px 非完全中立，A18 尚未解決對藝術感的影響；大幅擺動的 1x 真實 PixelLab 渲染仍可能失敗。

## CI 與公開程式
- 新增 `tools/asset_factory/a18_run_anatomy_preflight.py`：18 label、48px、finite x/y、髖相對腳步、肩相對擺臂、上下肢骨段比例、嚴格 F0 SHA、A17 版本鎖、一次記憶體修正。
- 新增 `tools/asset_factory/tests/test_a18_run_anatomy_preflight.py`：7 項純 synthetic 正反向測試；防止同腳領先、骨段拉長、手臂未反相、NaN、布林座標、首幀不一致、錯誤影格數。
- GitHub PR #15 專用 branch 的 Actions run `42529509257` 已 completed/success，日誌確證 **126 tests, OK**（其中 7 項為新增 A18 synthetic）。
- **限定聲明**：雲端 CI 並未下載私人 F0 或運行 `prepare_actor01_a18_candidate()` 對真圖做端到端測試。真實 A17 的上列數值是本輪在隔離環境解包計算，不可混作 CI PASS。

## Gate 與後續
| Gate | 狀態 |
| --- | --- |
| A17 私人 ZIP / 真實 18-joint 再計算 | VERIFIED |
| A17 全身骨段/手臂相位 | **FAIL** |
| A18 修正配方 / 真實座標理論預檢 | CANDIDATE_GEOMETRY_ONLY |
| 新增 GitHub synthetic 測試 | **126/126 PASS** |
| A18 私人 JSON 原件新檔已雲端保存 | **NO**，由雲端公開程式 + 原 A17 私有 ZIP 重建；不宣稱已 upload |
| PixelLab 動畫生成與扣額 | NOT_RUN / 0 |
| 新 48×48 Sprite / 1x ART / Native VX | 0 / NOT_RUN / NOT_RUN |
| main / A62 / F0 | UNCHANGED |

**Provider HOLD**：缺一次明確的 PixelLab 付費測試授權與 `animate-with-skeleton-v3` 可用權限。拿真正私人 A17 JSON 經 A18 守衛修正後，依使用者批准、控制單次提交，再保留 RAW 影格並進行 1x ART/VX 驗收。禁止未經授權打開 MCP write allowlist、修改密鑰、重送扣費，禁止假報成功。
