> **A21 CI VERIFIED (2026-11-10)**：GitHub Actions [Run 42804806871](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42804806871) completed/success；日誌確證 **148/148 synthetic tests PASS**（包含新增 A21 的 11 個單元測試）。它只驗證程式邏輯，不代表 PixelLab 新圖、Art 或 VX 通過。

# FS AI Asset Factory CURRENT_HANDOFF | A21 REAL MASTER PILOT | 2026-11-10

**唯一方法權威**：[`FS_ASSET_FACTORY_ACTIVE_MASTER.md`](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。A19 A18 原生 PixelLab 結果仍是 0；此輪只新增**真實 A11 Master → 有條件同源 PAR 的静態施工**，不是 PixelLab 圖像生成或 VX 封版。

- 真實私人 A11 ZIP 和 A18 ZIP 重新從 owner-only Drive 下載，SHA 回讀吻合。核准 A18 Actor01 F0 SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`。
- GitHub 新增 [A21 同源 Ground/PAR runtime prototype](../../tools/asset_factory/a21_runtime_occlusion.py) 與 [11 個 synthetic 測試](../../tools/asset_factory/tests/test_a21_runtime_occlusion.py)。**本地 11/11 PASS；請查最新 CI，不能把本地測試當 GitHub Actions**。
- 真實 A11 1280×928 Master SHA `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530`，Ground 保留原始 bytes 不變；三張 A11 舊候選遮罩的 Runtime_PAR 由 Master 原 XY 像素複製，合計 90,076 α 像素、RGB mismatch 0。
- A21 真實四站位樹前後、橋前後：腳點 `(232,556),(232,596),(735,621),(735,670)`，動態 PAR Alpha 分別 `33600,0,1421,0`。Pillow 預覽 **NOT VX**，樹下角色仍有過度遮蔽，ART **HOLD**。
- 真實 PNG + 四情境預覽 + QA 已存 owner-only Drive `FS_A21_MASTER_OCCLUSION_REAL_INPUT_PILOT_PRIVATE_20261110.zip`，**16,615,073 bytes／12 files／SHA `35a4268baf874c94ac8bd903f362410a8081933fa2d91a324f086908f2008981`**。Drive 上傳、下載、CRC、SHA 回讀 PASS；公開 GitHub 不放私人來源。
- [A21 完整 QA 與失敗紀錄](A21_REAL_MASTER_GROUND_PAR_PILOT_20261110.md)。現況：MASTER SOURCE / same-XY pixel **PASS**；new SAM segmentation **NOT_RUN**；New PixelLab RUN PNG **0**；Visual ART **HOLD**；Native VX / Switch203 **NOT_RUN**；main **UNCHANGED**；Formal seal **NO**。
- 下一步：角色 A18 真 PixelLab v3 一次付費生成須有明確單筆額度與安全工具授權；地圖先改良來源物件 Mask，再於合法真人腳點和原生 Game.exe 遮擋驗證。**不要回頭連續改 A17/A18 骨架來替代新 PNG**。

---

# FS AI Asset Factory CURRENT_HANDOFF | A19 | 2026-11-09

**唯一現行方法**：[ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。本節只描述 A19 真實工程狀況，A18/A17/A15 歷史下方保留。**PixelLab 真實新生成影格仍為 0**。

## A19 本輪真實進度
- A18 owner-only ZIP 19,706 bytes / 10 files，SHA256 f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c 重新下載回讀 CRC / SHA PASS；真正 A18 私人請求 SHA256 e392291d626ff37bb6038d40e0b63d17a7be0fc54df0835d848e50fba546fbfe，原 F0 SHA a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba。
- 以授權 PC 唯讀 GET 官方 PixelLab /v2/openapi.json，查證 Skeleton v3 確有 18-joint / 3～15 frames / background_job_id / GET background-jobs 契約，A18 private JSON 的所有欄位與必填欄位吻合；不讀 token。
- 2026-11-09 在 DESKTOP-90VT437 唯讀 codex mcp get pixellab 再驗：enabled=true，但 enabled_tools 仍然只是 get_balance、list_jobs、list_characters、list_objects、list_images、search_help 六個唯讀。沒有 paid animate_with_skeleton_v3 工具，不自行改 allowlist。
- GitHub 新增 [A19 單次提交防重扣程式](../../tools/asset_factory/a19_one_shot_provider_gate.py) 與 [11 項回歸測試](../../tools/asset_factory/tests/test_a19_one_shot_provider_gate.py)。真正原圖/base64/密鑰不入公開 GH。設計在正式付費 POST 前核對唯一 SHA、明確一次授權與費用門檻、雲端隔離 runner、私有 intent ledger；收到不明確結果即阻擋重送；provider 完成也僅能判定 PNG format，不能替代 user ART 或 VX。
- [A19 QA / 官方 API 實查 / 失敗限制](A19_ONESHOT_PROVIDER_GATE_AND_API_RECHECK_20261109.md)。GitHub Actions [Run 42543921836](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42543921836) 137/137 PASS（新增 11 個 A19 synthetic）；正式 main 未修改、PR #15 仍 Draft。
- 本輪短暫在 owner-only Drive 存放 2 個文字 staging，以完成 GitHub code upload；GH readback 後這兩個 staging 已經 DELETE VERIFIED，沒有使用者 PC 長期存檔。

## A19 Gate
| 項目 | 狀態 |
| --- | --- |
| 真實 A18 輸入與 F0 來源 | PASS |
| 官方 V3 OpenAPI schema | READ_ONLY VERIFIED |
| GitHub 靜態合成測試 | 137/137 PASS |
| 真正付費 PixelLab POST | **0** |
| 新 48×48 RUN 三幀 | **0 / NOT_GENERATED** |
| 真人 1x ART 與 VX Game.exe | **NOT_RUN** |
| main / PR#15 | UNCHANGED / Draft |
| FORMAL SEAL | NO |

**下一步：** 需要使用者明確核准對 A18 指定 SHA 的一次 paid generation 與可接受最高花費；MCP 需在 approval/read-only 安全控制下提供 Skeleton v3 生成能力。未確認上述兩項，不執行任何付費生成；不要再為了填進度亂改骨架或造假動畫。單一 runner ledger 不能保證跨設備排他，正式上線時仍需雲端協調與實際成本回讀。

---
# FS AI Asset Factory CURRENT_HANDOFF | A18 PRIVATE PACKAGE VERIFIED | 2026-11-09

**ACTIVE MASTER 為唯一規範**。最新 A18 私人真正 v3 RUN 請求已完成，仍然 **沒有新 PixelLab 生成影格**。以下修正之前「A18 ZIP 尚未上傳」的舊記載。

- 從 A17 真實私有 ZIP 的 approved 48×48 F0 SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba` 解出 A17 原始官方 v3 JSON，經版本鎖、18 點座標、三姿勢與 F0 base64 精確核對後套 A18 全身骨段 Patch，**真正輸出新候選 JSON**。其 SHA256：`e392291d626ff37bb6038d40e0b63d17a7be0fc54df0835d848e50fba546fbfe`。
- 8 個骨段相對 F0 長度均在門檻 `0.60–1.40` 內；雙腳髖相對前進差 `[+7,+14,-13]px`；雙臂肩相對差 `[+2,-4,+7]px`；F0 與 A62 舊素材及 F0 frame 0 不變。
- 真正私有 ZIP **10 files／19,706 bytes**：`FS_A18_ACTOR01_RUN_PROVIDER_READY_PRIVATE_20261109.zip`，Drive **owner-only / shared=false**；透過 Google Drive 上傳、下載回讀 SHA256 `f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c`，ZIP CRC、檔案 SHA manifest 全 PASS。公開 GitHub **不含 F0、base64 或私人 Drive ID**。
- 真實來源 A18 QA 全文：[A18 RUN RIG ANATOMY](A18_RUN_RIG_ANATOMY_COUNTERPHASE_QA_20261109.md)。公開 GitHub 原來 7 個新 synthetic tests 與 A18 rig gate 保留；最新 CI 成績須依 PR HEAD 重新確認。
- Gate：SOURCE PASS；A18 PRE-PROVIDER SKELETON REAL_INPUT PASS_GEOMETRY_ONLY；PIXELLAB POST 0；新 RUN PNG 0；ART NOT_RUN；VX NOT_RUN；FORMAL SEAL NO；`main` 不覆寫，PR #15 維持 Draft。
- 下一步 **不要無限調骨架**：一旦使用者對一次 PixelLab 付費測試及工具權限給明確批准，取私人 A18 JSON 提交一次，保存 job ID + provider RAW 3x48px PNG；格式／角色 F0 身分／左右腳、反擺臂／ART 1x／原生 VX 分開驗證。未授權維持 PROVIDER_BLOCKED，不另走祕密 REST token 或修改 Orca YOLO 權限。

---

# FS AI Asset Factory CURRENT_HANDOFF | A18 2026-11-09

**唯一施工規則：** [ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。本段只是最新施工實況，不覆寫規則。**最新 A18 仍無新的 PixelLab Sprite**。

## A18 本輪已實作
- 直接下載並核驗 A17 私有 Drive ZIP，14 檔、55,740 bytes、SHA256 `6598d46e0840c5cfb1c9570f28d38848d43e3f97498fc8cba647fd24f09bee65`。未變更 F0/A62/歷史 A17。
- 從真實 A17 18-joint JSON 發現 A17「雙腳交替」不能代表「腿長合理」：F2 RIGHT HIP→KNEE 約 8.06px、基準 3.61px（約 2.24 倍）；F1 雙臂並無真正反向前領。
- 公開新程式 [A18 rig gate](../../tools/asset_factory/a18_run_anatomy_preflight.py)：足點**相對髖部**的投影、手臂**相對肩部**的反向相位、上下肢 8 段長度、finite 坐標、18 官方 label、F0 SHA 與舊版位置守衛。已有一組 A18 原始畫布座標候選，補救 F1 手臂與 F2 腿/右臂；並提供只在 RAM 內修補 A17 私有 JSON 的函式，不會上傳原始 base64。
- 本輪 7 個新 synthetic regression case 已執行，與舊測試一起 [GitHub Actions 42529509257](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42529509257) **126/126 PASS**。這是公開 CI 結果，不是 PixelLab ART。
- 真實 A17 以及 A18 提案的原始數值比對詳見 [A18 QA](A18_RUN_RIG_ANATOMY_COUNTERPHASE_QA_20261109.md)。A18 F1/F2 骨段對 F0 比例約 0.90～1.34、髖相對左右腳投影候選 `[+7,+14,-13]`、肩相對雙臂 `[+2,-4,+7]`；A17 F0 不完全中立，1x ART 仍可能 FAIL。
- **狀態誠實區分**：A17 ZIP VERIFIED；A17 anatomy **FAIL**；A18 **CANDIDATE_ONLY**；真實 A18 經供應商輸出 **0**，PRIVATE_A18_ZIP **UPLOADED_OWNER_ONLY_AND_SHA_READBACK_PASS**，PixelLab 額度消耗 **0**，VX **NOT_RUN**；PR #15 仍 Draft、main 不動。
- **下一件實際工作：** 只有在明確核准一次付費、允許受限 MCP `animate-with-skeleton-v3` 工具，並取得可靠的 read-only/approval 狀態後，以 A17 私有請求在記憶體套 A18 修正並提交**一次**，保存 provider 原始三幀及 job ID，做 48×48/Alpha/角色/F0/左右腳/反擺臂/1x ART/VX 分開驗收。禁止暗自改 allowlist、存取密鑰或重複付費。未解鎖即 **PROVIDER_BLOCKED**。

---

# FS AI Asset Factory CURRENT_HANDOFF | A17 2026-11-08

**唯一現行施工規則**：[ACTIVE_MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。這是交接進度，不是另外一套新規則。A15/A16 的原始 evidence 以下保留。**A17 只修好了骨架意圖，沒有生成 1 張新 Sprite。**

## A17 真正更新
- 重新讀取 A15 的 owner-only 真實 ZIP，校對原始白髮／深綠 Actor F0（SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`）及核准 A62 三姿勢，來源位元保持不變。
- 找到 A15 v3 RUN 的運動語意失敗：前進方向 SW 的「左腳－右腳領先距離」`[13,15,13]`px，兩個 stride 同一隻腳領先；原 F0 右肘／右腕關節偏離可見輪廓約 2／3.16px。
- 新私人 A17 v3 RUN 請求修正為 `[13,20,-18]`px（明確交換領先腳），關節定位 0px 偏離來源 Alpha，官方 A15 `validate_payload` **PASS_LOCAL**。這是新骨架候選，*不是*取得 provider 的新 PNG；交叉腿是否自然尚需真實美術驗收。
- Google Drive owner-only 新私有檔案 `FS_A17_TRUE_F0_RUN_POSE_PREFLIGHT_CORRECTED_20261108.zip`：**55,740 bytes／14 files／SHA256 `6598d46e0840c5cfb1c9570f28d38848d43e3f97498fc8cba647fd24f09bee65`**，已上傳＋下載回讀 SHA/CRC，原 A15 RUN/WAITING 和原始角色不覆寫。
- 公開 [A17 真實 QA](A17_REAL_F0_RUN_SKELETON_GAIT_PREFLIGHT_20261108.md) 和 `tools/asset_factory/a17_run_gait_preflight.py`、`tests/test_a17_run_gait_preflight.py`，不含私有 F0 或 token。
- Remote Desktop Commander 只讀 `codex mcp get pixellab` 2026-11-08 再驗：PixelLab enabled，但 `enabled_tools` 仍只准 `get_balance,list_jobs,list_characters,list_objects,list_images,search_help`。**沒有可用的付費動畫生成 action**；未修改 allowlist、未偷讀 token、未提交請求、扣額 0。
- **下一件真正工作**：使用者核准一筆明確的 3-frame 付費測試與安全工具權限後，提交私有修正 RUN JSON 一次；保存 provider 原始三幀，核對白髮角色身份、48px Alpha、左/右腳步態與 VX 動作，不合格只處理骨架家族問題，不重複騙過 ART gate。若權限未開，保持 `BLOCKED_PROVIDER`，不能再拿骨架示意圖當新美術。
- Gates：SOURCE PASS；POSE_GEOMETRY_PASS_LOCAL；NEW_ANIMATION 0；USER_ART NOT_RUN；NATIVE_VX NOT_RUN；PIXELLAB_CALLS 0；MAIN UNCHANGED；FORMAL_SEAL NO。

---

# FS AI Asset Factory CURRENT_HANDOFF｜A15（2026-11-08）

**現行唯一規則**：[ACTIVE MASTER](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。本檔僅記錄實際工程進度，不是新政策。先前 A14 全文已[完整 SHA 不變封存](history/A14_CURRENT_HANDOFF_ARCHIVED_BEFORE_A15_20261108.md)，A13、A11 和 A10 失敗／驗收紀錄也在各自 QA 文件，不應混成現行待辦。

## A16｜Orca 接續施工與真正阻礙（2026-11-08）

**正式新動畫產物：0 幀，ART NOT_RUN。** 維持 A15 F0 48px 官方 Skeleton v3 Payload 與 SHA；不因新流程海報宣稱成功。

- Remote Desktop Commander 現場再驗：Orca.exe 多個程序正常執行；Codex CLI 登入狀態為 ChatGPT，`codex mcp get pixellab` 列出 `enabled=true`、`https://api.pixellab.ai/mcp`、Bearer token env var 名稱與**僅六個唯讀 enabled_tools**：`get_balance, list_jobs, list_characters, list_objects, list_images, search_help`。這裡**沒有動畫生成工具**；看到 MCP enabled 不代表能生成。
- 從普通 PowerShell 執行 Codex `exec --ephemeral --sandbox read-only`，甚至無工具的簡短回覆測試未成功回傳，已主動結束本輪測試 session；沒有向 PixelLab 提交付費請求。Orca 應用程式內的 Codex 帳號／工作樹可能不同於獨立終端，不能據此宣稱 Orca 內 Agent 不可用。
- 依 [Orca 官方 CLI 文件](https://www.onorca.dev/docs/cli/overview)，其 CLI 要由桌面 Settings → General／Experimental → CLI 註冊；已於 `%LOCALAPPDATA%\Orca\bin` 預期位置和 PATH 只讀檢查，**尚未找到可呼叫的 Orca CLI**。不得憑空寫 `orca terminal send` 或聲稱 Orca Agent 已受命。
- 本輪重新讀入真正 `APPROVED_F0_EXACT_48_PRIVATE.png` 作唯一美術來源，內建 ImageGen 嘗試卻產出**與白髮 Actor01 不符的美術流程資訊圖**，其聲稱「生成成功、扣 6 credits、PASS」全部為**圖片中虛構內容**。已判 `REJECTED_WRONG_MEDIUM_AND_FALSE_CLAIMS`，**不加入 FS、Drive 成品或計費紀錄**，不得重試同一提示無限制生成。
- 真正的 A15 私有 `PIXELLAB_V3_RUN_EXACT_REQUEST_PRIVATE.json` 和 F0／官方 18-joint 輸入依舊可使用；任何影格生成都必須由真正可授權的 PixelLab MCP/REST 工具完成，再依 48px、Alpha、F0 外觀、左右腳自然度、人類 ART、VX 原生分別驗證。
- **實際解鎖條件**：Orca 桌面註冊 CLI，從*已啟動的 Orca Agent 工作樹*核對與 PixelLab MCP 的讀取工具可回應，再在 approval／非 YOLO 模式下授予僅一次 `animate-with-skeleton-v3` 權限及明確費用額度。若沒有這些，不得偷讀 token、另開收費通道或把工作流驗證誤稱新作品。
- 本輪未新增 PixelLab 點數／費用；未修改原版 F0、A15 私人 ZIP 或 FS main；沒有啟動新 Orca 工作樹／Agent 實際生成。**唯一工程進度為查明並固定既有 Orca 通道與工具權限阻礙。**

## Orca／Codex 工具連線勘誤（2026-11-08，A15 後立即確認）

**不得再說「沒有 `PIXELLAB_API_TOKEN` 系統環境變數＝PixelLab 未連線」**。已再次在使用者授權桌機 DESKTOP-90VT437（Remote Desktop Commander 只讀）確認：
- `Orca.exe` 多個程序正在執行，`codex` CLI 已安裝，並非未配置 Orca。
- `codex mcp list` 顯示 **pixellab enabled / Bearer token / URL `https://api.pixellab.ai/mcp`**。
- `codex mcp get pixellab` 進一步確認目前 `enabled_tools` **僅六個唯讀能力**：`get_balance`、`list_jobs`、`list_characters`、`list_objects`、`list_images`、`search_help`。**Skeleton v3 動畫生成不在允許清單內**；不應誤稱「已能呼叫付費生成」。
- 歷史 Orca／Codex 工作流：FS 已使用 Orca Agent 1 Sprite QA、Agent 2 Map QA 等角色；PixelLab MCP 先前曾經從 Orca／Codex 成功讀取餘額（歷史 1414.80 credits，**不是目前餘額**），所以不能只查外部 PowerShell 的環境變數判斷可用性。
- 本輪試以暫時、唯讀 `codex exec --ephemeral --sandbox read-only` 呼叫 `get_balance`，該工作長時間沒有可讀回覆，**已主動中止本輪啟動的 session 19500**。目前「新一次餘額 API 認證成功」**未確認**；舊 get_balance 歷史成功不能當現在的有效連線。
- 先前 Orca Agent 曾使用寬鬆 YOLO 權限，使用者要求以人工核准／唯讀方式保護原工程；**新 Orca Agent 及付費 PixelLab 生成均未啟動**。禁止在未驗證 approval 模式前交給 Orca 自動寫正式工程。
- 分工仍是：ChatGPT＝FS Master/F0 美術與權威、官方規格核對、Drive 私有素材與 GitHub Draft PR/Handoff；Orca／Codex＝受限任務分派、Sprite/Map 獨立 QA、對來源與運動提出反證；PixelLab＝需要授權與明確點數上限時才做真正新動畫；原生 Game.exe＝另行授權的隔離測試。
- **下一步先在 Orca／Codex 現有環境確認 PixelLab MCP 是否可完成新 read-only `get_balance`，然後才評估是否安全增加一次 `animate-with-skeleton-v3` 工具權限**。當前 A15 F0＋18-joint JSON 可以用作一筆 RUN 3 幀的批准測試；未取得使用者明確付費授權及安全核對前不得送出。

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


## A16 補充：一次真正的錯誤排除與動作 Pose Guide（2026-11-08）
- 本輪再次使用真正白髮、深綠裝備的核准 Actor01 F0。ImageGen 仍回傳**另一個人物的圖解海報**，已拒絕；六部位旋轉程序產生大塊手臂／不自然連接也 **ART FAIL**，沒有可納入 FS 的新動作影格。
- 將未被採用的方案做成**一份受限 Drive 失敗紀錄／動作姿勢控制包**：13 檔，29,920 bytes，SHA256 `d9ab8177a90b2be2cca5f7dc6e8a6a95537b59e4553276912d245d36642874b7`，上傳後回讀 ZIP CRC/SHA 與 owner-only 存取 PASS。內含核准原 F0、核准 Run、A63 W2 候選、三個不同的 unarmed strike 48px 骨架姿勢**控制圖**與拒收測試影格。它**不是**正式 Sprite、不是新的 PixelLab 成品，更不是官方 v3 request 的替代品。
- 具有實際新動畫產物：**0 幀**；ART FAIL（錯人像／手臂變形），native VX NOT_RUN，PixelLab 0 付費呼叫。
- A15 官方 18-joint Skeleton v3 48px provider input 仍是權威，這次 14-point 示意骨架不准覆蓋；唯一下步仍是已授權、設限的真實 PixelLab provider 動畫生成及人眼 ART 驗收。
- [完整補充 QA](A16_AUX_REJECTED_ART_AND_POSE_GUIDE_20261108.md)。不公開私人 ZIP 直接連結。
