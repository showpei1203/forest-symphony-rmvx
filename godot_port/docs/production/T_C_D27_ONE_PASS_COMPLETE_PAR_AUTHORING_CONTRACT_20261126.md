# 2026-11-27｜OWNER TASK RESET／現行優先於下列歷史規格

2026-11-27 使用者最新決策：T-A 停止新角色與動作生成（含 Flow／PixelLab），Godot 直接沿用原 FS 素材、共用地圖／戰鬥 Sprite 及原紙娃娃規格；保留所有歷史成果。T-B 改為 PMD 像素風格與骨架／尺度／動作語法參考，製作山海經靈感的原創異獸及自創三階進化鏈，不再按 PMD 物種編號逐隻改色或照抄。T-C 必須先實際讀取 Drive 已完成地圖範本，分析位置失準原因，再以凍結 Ground 和範本建立可視化座標約束，一次生成整張透明全非地表 PAR。舊任務、NEXT、逐號規則及事後局部修補法如有衝突均降為歷史；已核准素材不得重做。成果優先，沿用已提供素材與 Skills，不為微小細節反覆開發驗收工具；同法兩次失敗即改變生成方法。原有授權、成本、私有儲存及真實驗收規則不變。

T-C 一次生成正確 PAR：先從 Drive 實際下載成品範本及可取得的同源 Ground/PAR；比較道路、橋兩岸、入口、建物底座、格線、透視、物件相對尺度、留白及可通行區，區分模型構圖漂移、畫布變換、透視或腳點誤判，不以尺寸當唯一根因。針對新地圖先凍結完整 Ground，以同世界原點及像素座標製作整張可視化佈局輸入（橋面中心線及兩岸落點、門口與道路、建築占地、禁入/留空區），結合範本風格與完整物件清單；使用可接受空間條件的既有工具／PixelLab 能力進行一次整幅透明 RGBA 生成，PAR 包含所有非 Ground 物件，不按角色遮蔽篩選。不得事後移橋、剪島、拼件、Master逆切或反覆全圖平移來冒充正確生成。原圖保留；僅允許必要的統一畫布轉換作候選預覽，不能假稱原生或正確對位。生成後直接與不變 Ground 疊合，檢視真實道路／橋接點及整體美術，達標才進 Godot 4.7.2 單次實際場景終檢；失敗修正上游視覺條件或換能控制空間的生成方式，不再重複同類自由提示或添加 gate。目標是一次命中，不保證模型每次成功。先完成一張可用地圖，再按六地形十二圖既定次序量產。

---

# Forest Symphony｜T-C D27 最高優先：ONE-PASS COMPLETE PAR ONLY｜2026-11-26

**授權來源：使用者 2026-11-26 最新指令「目標放在一次性生成完整的 par，而不是單獨部件修正」、「修正規則並繼續施工」。本規格覆蓋 D18–D26 的分群擺位／局部橋梁／單獨工坊修補型主線，但不刪除歷史實驗和可追溯證據。**

## 目標（這一張圖就是交付物，而不是零件庫）
以 FS_04_MAZE 已鎖定 D17 Ground 1280×928 RGB、SHA256 `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e` 為**世界位置及畫風參考**，在**單一次完整整圖作者化／影像生成**中輸出一張獨立的 **COMPLETE_PAR_RGBA**，整張 PAR 同時包含該場景所有非地表物件，包括橋、屋、吊車、屋棚、燈、旗、岩柱、欄杆、圍欄、其他樹/石等。凡不是 Ground 地表，全部都在 PAR；與角色是否遮擋完全無關。這個 PAR 是一張統一的畫，不是多張圖的拼貼結果。

## D27 權威流程
1. **Ground FIRST，而且凍結**。先檢查 D17 Ground、正式 32×32 網格、1280×928 的原點/道路/裂谷/光源/3⁄4 top-down 風格，不能讓生成器重畫 Ground。
2. **只做一次性整張 PAR 作者化**。每次模型呼叫/單次作者工作只提出一張完整 PAR 圖，**一次安排場景全體的非地表內容**；輸入是同一世界的 Style DNA 與 Frozen-Ground 位置規格，不輸出含 Ground 的 Master，不使用單件物件、tilesheet、spritesheet、分區圖或示意報告替代。
3. **原生正確格式**。目標整張 PNG **1280×928 RGBA**，大量真正 alpha=0 透明空間，非地表物件 alpha>0。透明棋盤格若實際被畫進 RGB 中，直接判 **SOURCE FAIL**。禁止以 white-key、灰底扣圖或從混合 Master 反切來把錯誤媒介偽裝成「原生透明」。若工具自動輸出其他尺寸，標記 SOURCE SIZE HOLD，先換能控制畫布的**整張生成方法**，不能分群重排或縮放。
4. **同世界的生成內比例約束**。只在整張生成 Brief 內告訴作者「橋與真岸相接、長約5–6格，主要工坊不超9格寬、同一透視與光向」。所有其它非地表物件也需一次畫齊；比例失敗時退回**整張 PAR 重新生成**，不得抽橋、改工坊、縮單件、搬 Alpha 連通島、拼回。
5. **整張結果整張驗收**。先檢查這張完整來源是否 RGB-A 真透明、Ground contamination、物件種類齊全、整體風格/量體/世界位置、可用地圖道路；再以不變 Ground 進行原生1× Alpha compositing 作畫面 QC；只有 SOURCE ART 可接受才做 Godot 4.7.2 Native 單次終檢。禁止轉往角色碰撞、橋欄遮擋、事件和存讀工作。
6. **FAIL-CLOSED + 累積經驗**。每次不合格來源存 FAIL log（如授權保留的 PRIVATE Drive）、明確說明來源失敗原因並調整**整張 PAR 生成方法**；不論結構 CI/Alpha/Native 是否 PASS，只有使用者確認整張美術才可更新 ART PASS，現為 **0/12**。
7. **持久化及安全**。私人 PNG、原始生成結果、整張 1× A/B、QA/FAIL/完整 Handoff 存 owner-only Google Drive；GitHub 僅存方法/文字/程式/來源 SHA。禁止覆寫任何既有 D17–D26 圖檔、T-A、T-B、主線或 Windows E:。保留 Draft PR #17 隔離。

## 被撤銷的舊「正式產線」做法
- D18～D26 的「Connected Component 島切分／單件製作／Alpha 島移位／個別改橋／物件替換／程序式畫橋」僅保留**歷史試驗及診斷**，**不可稱作符合 D27 交付的 CompletePAR**。
- D13–D24 的 white-key fallback、棋盤去背、Alpha 補洞等只能作**歷史比較**，不能用來認領本輪「真正原生完整 PAR」。
- D20/D21 的 Godot native / bridge physics 是另外的技術驗證證據，對 T-C 第一張 ART PASS 並無權威取代。
- D25 橋 160–192px、工坊 <=288px 是**完整整張生成內的語義約束**，不得成為單件素材產線或任務目標。

## D27 唯一成功定義
一份**單次作者化、同世界原點和尺寸、真正透明、整張完整非地表 PAR 原圖**，配 D17 Ground 在 1× 原生畫布直接合成而不需要分件拼貼；若藝術仍不合格，標 **SOURCE/ART HOLD**，而不是更多修橋建議。最後須人工核准才記「一張正式 ART PASS」。**合成不等於畫好；分件修到能合成也不等於一次生成**。

## 2026-11-27 D29 生成能力修正（官方自訂原生畫布整張 PAR 產線）

**最新工程結論：** D27～D29 聊天內圖片生成出現固定約 `1473×1068` 的來源，D29 四張一次生成真透明完整 PAR 的 native `1280×928` 4/4 FAIL（超畫布有效像素 `76661/97510/77181/86778`）。不再用同型文字提示、剪件修橋、整圖縮放或 master reverse-extract 冒充 native 產物。

**一條官方規格上可行而未實際付費調用的上游路由：** OpenAI GPT Image **2.5 Sunburst/Flare** [Images edit API](https://developers.openai.com/api/reference/resources/images/methods/edit) 支援 `size=1280x928`（兩邊都是16倍數）、`background=transparent` + `output_format=png`，可將 D17 鎖定 Ground 作整幅世界參考，**一次 image edit n=1** 產生整個非地表 PAR；這不是由目前 ChatGPT 圖像工具已實測成功的輸出，也不能保證模型理解世界錨點。不要拿舊 `gpt-image-2` 的透明支援當成已驗證。官方 [Image Generation guide](https://developers.openai.com/api/docs/guides/image-generation) 是規格依據。

**實際有產出的工程**：[`fs_tc_d29_exact_canvas_image_api.py`](../../tc_factory/biomes/fs_tc_d29_exact_canvas_image_api.py)、[11項 offline QA/安全測試](../../tc_factory/biomes/test_fs_tc_d29_exact_canvas_image_api.py)、[GitHub Actions #45883233641 SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45883233641)。已用真 D17 Ground 執行 zero-paid dryrun，SHA/原生長寬/模型/背景/單次輸出合約 PASS，但 **paid image API=NOT_RUN / 真 PAR=NOT_GENERATED / Godot=NOT_RUN / ART 0/12**。

**未來真實 provider 執行的防護**：使用者另行明確授權單次 API 付費 + `--execute --owner-approved-paid` + `FS_TC_D29_PAID_RUN=EXPLICIT_D29_ONE_PASS_SINGLE_REQUEST` + 合法 `OPENAI_API_KEY`，缺一無法啟動；不可將 ChatGPT 訂閱權益視為 OpenAI API 額度；無自動重試、無循環付費，永遠保留回傳原始 PNG。拒收全幅 Ground 污染、單件拆解、無透明度、尺寸錯誤；來源畫布技術 Gate 成功仍須與 Ground 景物/橋腳的人工審核，**正式 ART 必須使用者核准**。

[**D29 原圖4件＋整張QA、source/paid安全 dryrun、完整程式和 FailureLog：私人13件10,435,871 bytes ZIP**](https://drive.google.com/file/d/1YFaSByD1GXjdpl07K4o9Z0cHagxuZ18n/view)（owner-only 已回讀）；[D29 完整 Handoff](../handoff/TC_D29_EXACT_CANVAS_IMAGE_API_DRYRUN_AND_SOURCE_FAILURE_20261127.md)。不得覆寫 D17-D28、T-A/T-B、E槽，不得將私人原圖提交公有 repo。

