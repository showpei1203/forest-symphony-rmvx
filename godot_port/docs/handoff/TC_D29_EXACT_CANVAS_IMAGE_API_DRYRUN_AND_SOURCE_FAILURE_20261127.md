# D29 正式私有封存與真 CI 指引｜2026-11-27

- [**13檔完整私有封包：四張原始完整生成圖、D17 Ground、全圖 QA、11項測試、dryrun、原始碼及 Failure Log**](https://drive.google.com/file/d/1YFaSByD1GXjdpl07K4o9Z0cHagxuZ18n/view)：**10,435,871 bytes，ZIP CRC PASS，SHA256 `2a8323a550dd1725e60ca071851052dc1f1ecd9fe0c6211d47e11d2bfb58b49e`**；Google Drive READBACK shared=false owner-only，未上 public GitHub。
- [4版整張 PAR 源圖並列，只供 QA](https://drive.google.com/file/d/1j6uGjGxlVKscMJSfnjrhq-fseggpT4-L/view)、[真原圖尺寸/Alpha/超界 SHA JSON](https://drive.google.com/file/d/1Mr_MEsM_Hk_Vm3jTMH45xtqXi3mONAOQ/view)、[真 D17 Ground 只讀 dry-run 證據](https://drive.google.com/file/d/1wV_UbsyF0XdCvkqSVhSaCyuE5h-fpEu-/view)。
- [D29 零付費 CI 工作流程](https://github.com/showpei1203/forest-symphony-rmvx/actions/workflows/fs-tc-d29-exact-canvas-api-dryrun.yml) 真實 Action 結論須與離線 11/11 分開回讀；不是已成功產生 ART。
- 最高成果 Gate：**D29 1x 合格 PAR 仍無，實際 provider API Paid NOT_RUN，真正 Godot Native NOT_RUN，Human ART HOLD 0/12**。

---

# Forest Symphony｜T-C D29｜一次性完整 PAR：固定原生畫布的 API 工程與離線驗收｜2026-11-27

## 本輪真正實作，與仍未完成的事項

以 D17 已凍結 Ground `1280×928 RGB` SHA256 `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e` 為唯一世界基準，不再製作、修補或重排任何單獨橋／工坊／燈／旗等部件。 D29 維持「**一個模型請求、一張全非地表、一次性完整透明 PAR**」的最高優先規格。

**真實阻斷：本輪 ChatGPT 內建的四次完整來源出圖仍不服從 native 1280×928。** 四張保留原始 SHA 的 `RGBA` 圖皆為 `1473×1068`，有效物件在正式畫布外，分別 `76,661 / 97,510 / 77,181 / 86,778` 像素。直接裁切會破壞完整美術，整張縮放也不符合現行原生 1× 禁止製程。因此這四張全都 `SOURCE_NATIVE_SIZE_FAIL`，只有整圖視覺 QA，無任何正式 D29 PAR。

## 根因不同，施工方法已切換

2026-11-27 核查 OpenAI 官方文件：
- Image Generation API: https://developers.openai.com/api/docs/guides/image-generation
- Images edits/generate: https://developers.openai.com/api/reference/resources/images/methods/edit
- 依最新官方 `gpt-image-2.5-sunburst` 或 `gpt-image-2.5-flare` 能接受任意符合條件的 `WIDTHxHEIGHT`（寬高皆須是 16 的倍數），並支援 `background=transparent` 和輸出 PNG。**1280=80×16、928=58×16**，所以尺寸契約符合官方參數限制。
- 請勿將 `gpt-image-2` 和 `gpt-image-2.5` 混淆。不同模型對透明背景的支援不同。不要只使用通用尺寸文件而忽略確切模型。
- 這僅證明官方參數能力，**沒有證明本使用者 API 帳戶的付費資格、實際模型可用性、真實圖片世界坐標或最終美術品質**。GPT 的訂閱費不是 API credit。

本輪新增真正可執行的獨立 Python 產線 `fs_tc_d29_exact_canvas_image_api.py`：
1. 載入並嚴格驗證實際 Ground 1280×928、`RGB/RGBA`、不透明、正確 SHA。
2. 使用官方 `/v1/images/edits`，將 Ground 僅作**畫風與世界錨點參考**，指定一次呼叫 `model=gpt-image-2.5-sunburst`, `size=1280x928`, `background=transparent`, `output_format=png`, `quality=high`, `n=1`。整幅 PAR 一次輸出。從不使用 component extraction、resize、crop、white-key、master reverse extraction 或拼件。
3. 真正輸出必須由 PNG 原始位元組檢查 exact尺寸、RGBA、透明比例及可見物件。Ground 污染、世界錨點、建築比例和人眼 ART 必須另外審核，**絕不自動 APPROVE**。如果 fail，保留原生 bytes 並記錄 FAIL；不自動重生、無付費重試。
4. **預設零費用 dry-run**；外部付費模型必須 `--execute --owner-approved-paid`，並另設 `FS_TC_D29_PAID_RUN=EXPLICIT_D29_ONE_PASS_SINGLE_REQUEST` 和已合法授權的 `OPENAI_API_KEY`；缺任一條件都 fail-closed。沒有自行讀取／暴露 Windows 私有金鑰、沒有兌換 ChatGPT Plus 代替 API。

**實際施工驗收：** 已用真正已鎖 D17 Ground 在隔離雲端環境執行 `--dry-run`，顯示 `DRY_RUN_OFFLINE_VALIDATED`、`paid_api_calls=0`。使用**11 個離線自測**驗 source exact尺寸、真透明、最小 25% Alpha0、空 PAR、Ground 誤混、憑證與付費雙重保護、正確請求參數、禁止分件修圖；11/11 PASS。GitHub 公開工作分支 CI 只允許離線測試，無 API 金鑰與付費 image call。

## 持久化與 Gate

**私人圖片／QA 封包：**存既有 Forest Symphony 私人 Google Drive owner-only T-C 目錄；公開 Github 僅程序、測試、工作流程、文字 Handoff、SHA。所有雲端 WRITE 後必須 READBACK 再分享；本地 `/mnt/data` 只是此對話隔離暫存，不是使用者 Windows E:，不覆蓋已有正式藝術。

| Gate | 實際結果 |
|---|---|
| 四次內建出圖，一次性整幅非地表 RGBA source | SOURCE IMAGE EXISTS、真透明，但 4/4 NATIVE SIZE FAIL |
| API 自訂 `1280×928` 與透明 PNG 官方參數 | OFFICIAL SPEC CONFIRMED |
| API 發送前安全／合法付費雙重 Gate | OFFLINE PASS |
| Python 11 positive/negative tests | 11/11 PASS |
| Python 真 D17 Ground 零費 dry-run | PASS |
| GitHub CI | 需以 Actions 的真實結果獨立記錄 |
| 付費 provider／生成實際 native 1280×928 | **NOT_RUN／0 paid calls** |
| 本輪真 Godot4.7.2 私人圖 native | **NOT_RUN** |
| 人工整張美術 ART | **HOLD，正式 0/12** |

## 下一個完整施工單位 D30（限一張完整圖）

保留 D29 生成程式、原圖、Ground 安全位置與世界參照，先在已授權 API 帳戶且明確核准**單次付費**情況下執行**一個** GPT Image 2.5 全幅透明 image edit（不是零件生成，不能連續多次扣費）。將返回原圖在私人 Drive 封存，跑原生尺寸／Alpha／Ground 內容污染／腳點／整張風格 Gate；合格才進 Godot 4.7.2 原生像素預覽與使用者 ART 門檻。若帳戶沒有授權或 Paid gate 未滿足，**D30 付費施工 HOLD，不假裝完成，也不得回頭改個別橋／工坊**。

**本輪絕不宣稱**：真正模型已扣費執行、現有 API token 可用、API 已成功生成精準 PAR、Godot 真圖渲染 PASS 或任何 ART PASS。所有 D17～D28 原圖完整保留，T-A/T-B、Windows E: 未改，PR#17 保留 Draft 未合併。
