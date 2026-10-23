# Forest Symphony｜Open-Source Asset Toolchain CURRENT HANDOFF V3.2

日期：2026-10-24（台灣時間）
**Current track = 工具能力驗證；Map Dev PAUSED。**
**State = TOOL_V3_2_HANDOFF_AUDIT_PASS（8/8 檢查）；T09–T13 V3.1 10/10；T14+T16 5/5；PIXELORAMA SHADER ENABLED FAIL / HUMAN GATE F PENDING。**
本文件為本次工具工作流最新接手入口，優先於工具 V2 / V3 / V3.1 舊 Handoff；歷史紀錄僅保留作回溯，不回滾已通過 Gate。

## 0. 先讀固定權威與完整下載
1. Map PAUSE 及後續目標：https://docs.google.com/document/d/1jPAJMPf3nhKUDohCuzQZho9AsPJqEG0XPCvKj8u87tE/edit
2. 170筆素材 exact Drive ID / license 索引：https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit
3. 工具完整測試目標矩陣：https://docs.google.com/document/d/1XitoOS6llG9vlDL7vt2IoY0Wrm3gtk71ozc4RtVNEyo/edit
4. 工具手冊與歷次 FAIL / CLI：https://docs.google.com/document/d/1lx8pbTkwetZFowHWqLI9r4NtXb7WUxFswSq450Vrln4/edit
5. 上一輪 V3.1 驗證 ZIP（244 files, SHA256 d8a248de981d1d1c3b7f19028b38939767914a2bdf362e7cbc8c815da69c6451）：
https://drive.google.com/file/d/17c7fkGMyLZenBJrfAJz4pCajlbg4G2aJ/view
6. 本次最新 **V3.2 ZIP** 與完整 Drive Handoff 在最終交付紀錄中填入，必須以 Google Drive 實際 ID 為準，禁止猜 URL。
Remote Windows Desktop Commander：DESKTOP-90VT437；Workspace：
`E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024`

## 1. FOREST SYMPHONY MAP: PAUSED / NOT FORMAL PASS
- K4 正式舊專案 3860/3860 檔案逐內容 Hash+CRC 比對 PASS，外層 ZIP SHA 不宣稱相同。
- 正式 Phase49N5 SEALED 505 Scripts SHA256：
`3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9`
- 隔離 `N5_B0_ADAPTER_CANDIDATE` 以一個測試 Adapter + Map900 在真 N5 Runtime 通過 6/6，修復 ISS ParaPassa 額外覆寫 `Game_Player.move_passable?` 的高度通行問題。
- 使用者已確認應切回工具測試。不可修改 SEALED Scripts、正常 FS maps / events；不可將私人測試候選冒稱正式版本。
- 技術有效≠藝術完整：SCENE04 參考級美術 / ground3 豐富精靈村 / 洞窟橋上橋下 2.5D / 人工 Gate F 全部 PENDING。Hanzo素材仍 RESTRICTED_PENDING_PROVENANCE，不得放 Approved / 公開 GitHub / 商用發布。
- 完整地圖 Authority 見上面的 Map Pause Checkpoint；不要回頭「重新發現」素材。

## 2. 工具矩陣（原生測試結果，不得拔高）
| Test | 工具與已證明能力 | 剩餘限制 |
|---|---|---|
| T01–T08 | 舊 Tool V2 11/11 煙霧回歸；未重新執行 | 留存 V2 來源與錯誤記錄 |
| T09 | Sprite Fusion Sprite Normals Rust CLI；B0 真素材及不同六幀法線，逐幀 vs sheet 可見像素 canonical 0差，GL/DX Y 方向驗證 | 法線 != Ground/PAR 碰撞/遮擋 |
| T10 | Laigter 1.14；10 input ×4 map = 40 PNG，依原始 Alpha 修正後尺寸/遮罩 OK | RAW Alpha 不保證相同；全 sheet vs 各幀 Normal **1,726px** 不同 |
| T11 | Pixelorama 1.2.3 原生 PXO / 官方 Shader Effects；僅留 Offset&Scale 或 Outline 任一效果開啟都會使 headless 0xC0000005 Crash | **Shader Effects enabled FAIL**；不得因崩潰後遺留 PNG 就宣稱 PASS |
| T11B | Pixelorama 以六張真不同64×96 B0樹木源自製 PXO；無Shader匯出384×96，6/6 RGBA exact | 真效果渲染/GUI品質未過 |
| T12 | LibreSprite 1.3 原生六幀 ASE，384×96 PNG＋JSON＋idle forward Tag；durations 70,90,110,130,150,170ms；6/6 像素一致 | VX SBS 時間/動作串接尚未完成 |
| T13 | 真 Godot 4.7.2 Radeon RX6700XT OpenGL CanvasTexture／PointLight2D／NEAREST 12張160×160截圖：樹/石×Sprite Fusion/Laigter/無法線×左右光照，RGB 區域有差，背景外0差 | 人工偏好及視覺品質尚未選型 |
| T14 | **Laigter 6幀分別算 Normal 再組384×96 Atlas PASS**；Alpha per-frame exact；故意X+1px→3,283不同像素；故意互換frame2/3→2,072不同像素 | 原生整張 sheet 結果與逐幀結果不等價，應優先逐幀 |
| T15 | Pixelorama Effects headless 已重現 Crash；GUI真 Shader renderer / 版本差異分析尚未做 | **NOT RUN / BLOCKED**，不能認可Shader |
| T16A | **LibreSprite JSON 時間 × Godot 六幀 Diffuse/Normal 動畫同步 PASS**；6張非 headless 160×160真 GPU 截圖；理想時長70/90/110/130/150/170，實測65/82/100/114/148/164ms，符合±35ms受測容忍值；全部單幀Diffuse/Normal Alpha匹配 | Godot Frame time 是測量誤差下的驗證，非毫秒精確 |
| T16B | 接到真 VX SBS index和 Weapon sprite 對位 | **NOT RUN** |
| T17 | PMD/LPC/SBS 真實怪物/裝備/武器庫素材 | **NOT RUN**，先查素材索引及版權 |
| T18 | 真動畫雙光源、多物件壓力與FPS／UI人眼體驗 | **NOT RUN** |

## 3. 已實際驗證的本輪證據與一鍵流程
舊 T09–T13 原生 10/10：
`python scripts/run_tool_suite_v3.py`
`reports/V3_ALL_TOOLS_SUMMARY.json`
T14+T16 增量 5/5（2026-10-24 本對話**重新執行**，Godot GPU 是非headless）：
`python scripts/run_t14_t16.py`
`reports/T14_T16_INCREMENTAL_REGRESSION.json`
`reports/T14_LAIGTER_STITCHED_NORMALS.json`
`reports/T16_GODOT_SYNCHRONIZED_NORMAL_ANIM.json`
本輪新完整性與封版保護檢查 8/8：
`python scripts/verify_handoff_v3_2.py`
`reports/TOOL_V3_2_HANDOFF_CHECK.json`
原始圖片/光照截圖：`godot/NormalLightB0/captures/` 與 `godot/AnimatedNormalsB0/captures/`。
**曾遇到工具腳本猜錯完成版Normal圖片位置，正確供T16使用Atlas：**
`godot/AnimatedNormalsB0/normal_atlas.png`，SHA256 `ada6955cf151ab0876354e4c04217800529fb49339481f8c5bed05ff7f5d7d33`。
T14 的原生全-sheet Laigter圖與此 per-frame Atlas **不是同一份**，千萬別誤指。
之前V3.1在T13曾漏將當前法線來源準備放入獨立檔案，已補 `prepare_t13_cross_tools.py`；V3.1 10/10為當時真實回歸。

## 4. 每個新的工具測試應遵守的 Fail-Closed 契約
- 設定 Test ID、目標、精確輸入來源/License/SHA、重現CLI/GUI操作、stdout/stderr、輸出尺寸/幀時間/RGBA比較、負向注入測試、真引擎畫面、人眼待驗項目。
- 任意工具只「可啟動」不等於匯出正常。崩潰退出碼非0即 FAIL；有殘留輸出也不代表PASS。
- 優先使用本專案B0自己生成測試素材，禁止把Hanzo權利未明原始素材/衍生圖片公開。
- 原生VX/SBS高度/遮擋與Godot只作各自獨立技術驗證；不能因Godot真實GPU通過就聲稱VX也自動支持動態法線光照。
- 保留現有 SEALED FS，所有測試在獨立工作目錄，ZIP＋LOG＋README＋NEXT_CHAT_PROMPT。
- **下一步只測未通過：T15 GUI Shader vs Pixelorama 版本差異；T16B 真VX SBS Metadata對位；T17 PMD/LPC真素材；T18效能。**
- 使用者需要真人測試時，直接產出可執行測試副本與LOG，絕不把測試工作丟給使用者自行拼材料。

## 5. 新對話重啟指令
讀本 `CURRENT_HANDOFF_V3_2_20261024.md`、`NEXT_CHAT_PROMPT_V3_2_20261024.txt`、`reports/TOOL_V3_2_HANDOFF_CHECK.json`，再讀上述 Drive Map Pause 與 170項 Asset Index。確認 N5 SEALED Scripts SHA，直接執行下一個「未通過」工具Gate；不要重啟地圖、回滾本次T14/T16、或單純重跑已通過舊工具。每一步寫 LOG、更新 Handoff / Drive / GitHub / Linear SHO-39。

Latest verified ZIP (300 entries, 763852 bytes): https://drive.google.com/file/d/1WdcFKs8LvvIRwCPN1OJvEeaJRgI_88xh/view
Drive Current Handoff: https://docs.google.com/document/d/1F8urGRPbaOG-4qW57-rykyQ_yYzWEHQE6nnJo49sFN8/edit
ZIP SHA256: 4474d6d4b42b49b2c154f8f99efe7ead735d5c2f6dd4b738dda4b4cef0ef3f1c
