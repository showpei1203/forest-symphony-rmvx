# Forest Symphony | T-C D15 | FS_04_VILLAGE 大型封閉白底穿幫修復 + 來源 QA | 2026-11-23

**來源專屬分支：** `feat/fs-tc-d12-chroma-par-20261122`，目標引擎 **Godot 4.7.2**；M1 技術美術候選完成，M2 D15 私有來源原生 Godot **NOT_RUN**，M3 關鍵白洞修復 TECH PASS，M4 第二張地圖 **NOT_RUN**，正式十二圖 **ART 0/12 HOLD**。

## 0. 最新權威與衝突
已讀 T-C CURRENT_HANDOFF D14、GitHub PixelLab 三線 Roadmap、十二圖及場景 Blueprint、Google Drive 世界規劃與 Ground-first SOP、v0.1.0 四個共用 Skills（從私人 chatgpt-pc-bridge 倉庫 approved_skill_packages 正式檔案讀取）、PC_CONTROL_TOOL_ROUTING_PROTOCOL/AGENTS.md/README/HANDOFF/Invoke-BridgeTask.ps1。舊 Roadmap 部分 C1/C2 使用 MASTER-first 四層的敘述與使用者最新直接指令和 Drive 地圖規範衝突，**以最新 Ground FIRST → 全部非地表獨立 PAR 為準**；不做角色遮擋判定、不反切 Master。T-C 主工作分支未被此 Draft 分支覆蓋；Codex/Desktop Remote 均未使用（0 次）。

## 1. 真素材直接修正，不重生 Ground
D14 真 RGB 白底來源是獨立生成的整座火山工坊城**非地表**圖，並非 Ground+屋舍 Master。原作者層 Ground（1280×928）維持：
- Ground SHA256：`ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d`
- D14 白底來源 `1474×1067 RGB` SHA256：`26aed5dc5bb03004961ac54f13cfb41f9d825396808d6eb12517e04b50171adb`
- D14 原始透明技術 PAR `1474×1067 RGBA` SHA256：`85b8f750e584d74492bea4c409a76e0b26bbe41edfca303241b26db40a9a0760`
- **D15 新獨立修正 PAR 原尺寸仍為 1474×1067 RGBA** SHA256：`1063c9bd0180e771da32ffffbcc5c00b6e409bffbc603524c17001010ae0c3a9`；沒有放大或縮小原作者圖，D14 原圖未被覆寫。

D14 白底摳圖的已知缺陷：只有**連通圖像外邊界**的白色背景會清成 alpha=0；被鐵橋、燈架與欄杆**包在裡面**的大片空白留下完全不透明白色，最後浮在火山 Ground 上。這是整張地圖美術穿幫，而不是角色遮蔽問題。

### D15 工程修改
沿用同一 `fs_tc_white_plate_to_complete_par.py`，新增可選參數 `--repair-large-enclosed-background`：把真正白底來源的候選像素中「不與邊界白底相通、面積至少 800px、平均 RGB 最暗通道亮度至少 247」的大型封閉背景島另行轉透明；其周圍三像素只處理接近白色的抗鋸齒邊緣，原非白色物件不動。**不是白色像素一律移除**；小型封閉白色花紋仍保留，且保留原始來源供還原。

原圖片實際找到 **5 塊**大型背景島，大小 **4400、1529、5212、27707、2324** pixels。源輸出原本的 `alpha=0 734965` → D15 `776139`（增加 **41174** 個真透明像素）。在 1280×928 **僅技術合成預覽**的右橋 ROI `[960,440,1260,675]`，近白色像素 **20781 → 336**（減少約 98.38%），原始道路/熔岩立即可見。

**不聲稱**白色的語意百分之百能由 threshold 識別。風格審核要確認沒有誤清橋面金屬亮點、屋窗或煙霧；輸出 D15 只是下一張完整技術美術候選，ART HOLD。

## 2. 本輪真實可重複測試與先前失敗
- GitHub 原工程新增 opt-in `repair_large_enclosed_background`，保留舊 D14 預設功能、所有既有 RGB/Alpha 契約，沒有重寫整套。
- 擴充 `test_fs_tc_white_plate_to_complete_par.py`：一張含黑色建築/大白洞/小白色裝飾的同源合成圖，檢驗大型空白轉真透明、小細節保留、Ground SHA 不變、不縮放誤冒稱原生、Master/空白/錯角/錯 SHA 拒收。
- 初次 [GitHub Actions #45100966246](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45100966246) **FAIL**：測試資料的「小白色裝飾」直徑 46px，面積超過 800px 門檻，並非真正的小型裝飾；修正測試 fixture 直徑為 20px 後，[**#45101082116 SUCCESS**](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45101082116)。此修正只是校準測試假設，並未證明所有真實白色裝飾安全，保留人眼 ART Gate。
- 修正程式 commit `cad165d40349868d34ad03abb6e4b44deb814f2e`，測試資料修正 commit `f602ba263c141f84473a9b4ab14a8de4eef846d6`；已從 Actions 讀回實際成功 job steps，不借用其他的 PASS。
- 本地實際私人 D14 PNG 來源再測，原 Ground SHA 鎖檢查、白洞遮罩、原非白色像素不變、完整 Alpha histogram、靜態 `PIL Image.alpha_composite`、橋樑 ROI、中間檔案 SHA、8 檔 ZIP CRC 皆完成。**原生 Godot4.7.2 D15 私有素材 NOT_RUN**；先前 #44997754667 成功的是 synthetic 測試，不可充數。

## 3. Google Drive 私人封存（已完成 WRITE→READBACK，shared=false、owner-only）
- [D15 8 檔來源 / 新 PAR / 靜態合成 / 前後圖 / QA / Failure Log ZIP](https://drive.google.com/file/d/1E8bf_o8UquJQYP3UoayzibCks6f4phKW/view)：**13,580,705 bytes，8 entries，ZIP CRC PASS**，SHA256 `76523e688a050abb956ad8dda9e71bcb47d4171bd474c1e810bc385f18220571`。
- [真 D15 PAR RGBA 原尺寸](https://drive.google.com/file/d/1aOF1RIUpHjyJdXnB30bxD3XxEtZZ3kEV/view)
- [1280×928 Ground+PAR 合成（**RESAMPLED TECH ONLY，不是原生 1×**）](https://drive.google.com/file/d/1O4CiQ_K5PHKyFDht_BfSJTz25Wi2GcRt/view)
- [D14 vs D15 實際白洞修復前後](https://drive.google.com/file/d/1b2Y7bfikStctKgZR6geR0VcOoenZHmeD/view)
- [完整尺寸、SHA/Alpha/ROI QA JSON](https://drive.google.com/file/d/1C3HD6mAfqt-V2rv7fxhypFybO4vMiGoO/view)

所有私有原圖/ZIP只在 Drive，GitHub 僅程式／測試／文檔。沒有操作 E: 使用者電腦或修改其它分支。

## 4. 驗收狀態與下一宏觀單位
| Gate | D15 |
|---|---|
| SOURCE 原檔、保留 Ground、PNG SHA | PASS |
| STRUCTURE 全非地表獨立圖、真 Alpha、白洞修復、靜態合成 | TECH PASS |
| 原作者層官方原生 1280×928（40×29） | **FAIL：1474×1067** |
| Godot 4.7.2 原生實際 D15 私有素材 | **NOT_RUN** |
| VISUAL ART | **HOLD**：須確認大面積 Alpha 誤刪風險、原生尺寸/落點 |
| INTEGRATION / 角色走位、劇情、遮蔽 | **NOT_RUN，不在本工廠這輪範圍** |
| PERSISTENCE 私有 Drive／GitHub | PASS（需以 Drive metadata READBACK 完成） |
| 官方 12 圖 ART PASS | **0/12** |

**下一個完整單位：**在不重做 D11 Ground 的前提下，取得**原作者 1280×928、完全不裁建築、真正與道路/橋接對齊**的 CompletePAR 完整美術。**既有 1474×1067 不能靠強裁或 LANCZOS 縮小充數**；必要時使用可控 1x 重佈局／整張重新輸出，同樣保留完整家族與來源。接著使用已驗證的 Godot native probe 做真 D15/新圖 1× 截圖，以及人工美術 Gate；Native 私有讀檔若無核准路由仍 HOLD。之後才做 FS_04_MAZE 的 Ground-first 第二樣本。
