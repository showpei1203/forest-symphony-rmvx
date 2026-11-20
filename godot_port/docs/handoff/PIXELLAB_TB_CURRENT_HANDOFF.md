# Forest Symphony | T-B 怪物量產工廠 | CURRENT HANDOFF
更新：2026-11-21（Asia/Taipei）｜分支：`feat/fs-pixellab-tb-monster-20261121`
線別：**T-B / SHO-37**｜階段：**M1 第一條進化鏈候選已生成、M2 Godot 工程已建立但原生未執行**
狀態：**ACTIVE / ART_HOLD**；絕不標為 VERIFIED_PASS。

## 1. 本輪真實施工 DELTA
- 本輪從**私人 Google Drive 真實來源**讀出 PMD0001、PMD0002、PMD0003 三個 128×128 透明背景概念母圖；建立三階 **64×64 PNG** 靜態 Sprite，維持來源輪廓而不只是換色。三階呈現「小型熔岩蛙→增厚玄武岩殼→外露熔岩核心」。這些是用既有來源建立的候選圖，不是新一次 PixelLab 生成的三張圖片。
- 將 **歷史 PixelLab 產出** PMD0001_WAITING_3FRAME_PROVIDER_SHEET（384×128）以 source-locked 裁切及等比例縮放整理為 **Idle 3F × 64×64，192×64 atlas**。只有 3 幀，不可虛稱 12 幀或新 API 生成。
- 以 PMD0001 已鎖定來源製作 **Attack 8F × 64×64，256×128 atlas**，包含壓低身軀、抬起前衝、噴射熔岩、回復。這組是 **deterministic procedural fallback**，**非 PixelLab 生成、不冒充已核准攻擊動作**，需在真實動畫視覺驗收中確認動作語意。
- 另產 **Idle 與 Attack GIF** 與三形態對照圖。
- 建立**獨立 Godot 4.7.2 展示工程**（專案 `project.godot`、`tb_demo.tscn`、`tb_demo.gd`、`tests/tb_validate.gd`），可使用 1/2/3 切換三階，Space 播放攻擊；完整 ZIP 包含私有PNG；未更動 FS 主線場景。
- 新增重現工具 `godot_port/tools/pixellab_tb/build_tb_monster.py`，可從合法原圖重建圖集／SHA manifest／幾何 QA。

## 2. B0 真實來源與 Hash
| ID | 真正來源 Drive file ID | 2026-11-21 實際讀取 SHA256 |
|---|---|---|
| PMD0001 | `1uW0MbruUOHjKu7f_coEr1ebuUQFnucdh` | `8fc8310ce3cf08a13582d9d84e33020e8cf362ab3b03dba8b4ac624ead164b2d` |
| PMD0002 | `1xw11JS2wR1tjxi-q2tb1DZeU1bQNUdb7` | `dcc3cd009912d38007bc4afdf794b68804265c02bd8553f4e5b03b9bc0d4c8fb` |
| PMD0003 | `1p3CFtpD2lpLNQmweFL1goZwV4xF0lgYO` | `64e61fb8409d784b5b294cae5d5162fc996c4494440664315a242f2d854c93ea` |
| PMD0001 真實歷史 PixelLab Idle sheet | `1An7EAOsy32v8bPuWr6YbOZSjEIvPV7EE` | `3c5c65bb35239869d83c8eab87a663e8a8c33c191a9dacd6752bf43572b22bf6` |

原生 PMD 34動作 XML 及前次 ZIP 來源 SHA 請參照既有 [A02 INVENTORY](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-asset-factory-v1-20261107/docs/asset_factory/SOURCE_INVENTORY_A02_20261107.md)；**本輪沒有重新下載完整原生 XML ZIP，未重核它的位元組**。原圖授權歷史註記有待 final licence gate；用戶私人資料嚴禁提交公開 GitHub。
視角沿用實際來源右前 3/4，但**45° 精準角度尚未原生視覺確認**，為阻斷正式 ART PASS 的待決事項。

## 3. Cloud deliverables
- 私人來源／素材／Evidence folder：[T-B 私人 Drive](https://drive.google.com/drive/folders/10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3)
- 三階真正可見對照：[Preview PNG](https://drive.google.com/file/d/14VqV8v5-jVR2IzCA6VQykOsKLglj7PLc/view)
- 母體 Idle 真實歷史 PixelLab GIF：[Idle GIF](https://drive.google.com/file/d/1-9mBZffp3RK5GwIDDKgzeOY4z7ErAVG4/view)
- 母體 Attack 程序化候選 GIF：[Attack GIF](https://drive.google.com/file/d/11DvfuJ2luTPVf5H4ocsJQoVBn4u64M0m/view)
- Godot 可載入獨立工程完整 ZIP：[Godot Candidate](https://drive.google.com/file/d/1iH3rdqN7KdACcFfxCI3CpHaqQ-BKHS4b/view)
- [FAMILY_MANIFEST.json](https://drive.google.com/file/d/1wR9gJye1CoflBqskEv5QRE6AzPPus9OZ/view) | [QA_SUMMARY.json](https://drive.google.com/file/d/1Kw5sAckxse1D1kQ5_CZpIEBM3gvkRlyj/view)
- ZIP：16 entries, CRC OK; SHA256 `e85f111c7b61390a818d526f873e348d0680887b36de3472b76e1bfb746f9a36`.
- GitHub 程式：`godot_port/tools/pixellab_tb/build_tb_monster.py`、`godot_port/experiments/pixellab_tb/*` （僅程式及說明，不提交私有PNG）。

## 4. QA 與人工 Gate
| Gate | 本輪實際結果 |
|---|---|
| 來源四張圖 SHA／來源 Drive id | PASS（僅這四張） |
| 三形態 64×64、alpha 無裁切、足點 y=59、色盤／剪影非單純換色 | 尺寸／透明幾何 QA PASS；肉眼家族風格為 CANDIDATE |
| Idle 三幀來源／差異／透明邊界 | SCRIPT PASS（歷史 provider；美術未過） |
| Attack 八幀圖集／差異／透明邊界 | SCRIPT PASS（程序化；攻擊可讀性 ART HOLD） |
| Godot 4.7.2 專案與可載入資源結構 | PROJECT BUILT；**NATIVE NOT_RUN** |
| 原生 Godot 截圖／動畫動態測試 | **NOT_RUN**（此 ChatGPT 隔離環境無 4.7.2 binary） |
| PixelLab 新角色生成／Skeleton／新 API credits | **NOT_RUN，job id null，當次 0 generations** |
| 第二樣本可重複量產 | NOT_RUN |
| 最終用戶 ART Gate | HOLD，未申請 PASS |

當次可核實 API 花費：**0 PixelLab generations**。本輪歷史來源可能含已付費舊結果，不應算當次新費用。ChatGPT 隔離環境轉換成本未測計；不杜撰金額。

## 5. FAILURE LOG / blockers
1. **PIXELLAB_API_UNAVAILABLE / BLOCKING for formal B2**：本輪沒有可授權的 PixelLab 生成呼叫工具；改用已保存歷史真實 PixelLab Idle，攻擊採可追溯程序候選並明確標示 HOLD；沒有假造 job ID。
2. **NATIVE_GODOT_BINARY_MISSING / BLOCKING for M2**：僅能產製工程 ZIP、幾何 QA；無 4.7.2 執行檔，無法提供本輪原生測試截圖。不能沿用舊工程截圖冒充。
3. **VIEW_45_ART_GATE / BLOCKING**：現有來源偏右前方 3/4，但 45° 精度需在戰鬥相機內確認；錯視角不得升版。
4. **ATTACK_SEMANTICS / BLOCKING**：八幀程序化壓縮／前衝／噴火有動勢，但尚不能替代 PixelLab 真正骨架或分段攻擊生成；不可宣稱 B2 ART PASS。
5. **SOURCE_LICENSE_AUDIT / BLOCKING for public reuse**：私有原圖已有可追溯來源與歷史記錄，本輪未查到全面可公開重用授權；PNG 限私人 Drive。
6. **PIXEL_FINISH / NON_BLOCKING**：少量局部 pixel/alpha 與視覺細節待人工審查；0 次修正。最多連修兩輪後記錄，禁止拖延完整成果。

## 6. 下一個完整成果單位
**M2+B2 可實測且 ART 可審的完整版**：在合法、隔離、可存回私人 Drive 的 Godot 4.7.2 測試執行器匯入此 ZIP、取得 native 截圖/動畫證據；如 Attack 動作語意不合格，改走「真實已核准 PMD0001 來源 + PixelLab Skeleton/Animate-with-text / key pose」重生完整攻擊，保留本次候選作對照。完成原生與美術 Gate 後，才做**第二個真正不同樣本**的模板驗證。不可先宣稱可量產 500 隻。

## 7. P0 storage / handoff
- 本次隔離環境工作檔在 ChatGPT sandbox，**未建立使用者 Windows PC 資料庫**。
- 實際成果持久化於上述私人 Drive + T-B 專屬 GitHub 分支；保留所有原始 PMD 舊工程不變；T-A、T-C、main 不動。
- WRITE→READBACK：GitHub 程式碼與 Drive folder/manifest 已回讀；完整 Godot native **未驗證**。
