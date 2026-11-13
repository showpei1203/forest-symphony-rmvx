# A33｜Actor01 RUN 步態對位改善：實際 A32 檢查、V3 4-pose 生成設定、遠端 GUI 失焦紀錄

日期：2026-11-14。**本輪未完成 PixelLab A33 新生成；不將輸入檔或舊畫格冒稱成模型成果。**

## 一、已實際查證的 A32 影格問題
- 讀取 PixelLab **原始 192×192 3×3 PNG**，9 格各為 64×64。起始格與 A30 核准 RUN source **RGBA 0 畫素差**；9 格各異，這部分已在 A32 實際驗證。
- 第一格人物不透明輪廓 bbox = `(21,15,44,50)`，至中後段擴張到 F6 `(19,15,46,50)`；因此角色不僅變換腿部動作，**整個像素輪廓的重心與寬度也出現變化**。
- 真正的美術缺陷不是畫格數或 64px 的限制，而是 F4–F8 臉與身體漸漸面向鏡頭，雙腳的領先交換不明確、近似往前踏步。**A32 ART=HOLD**，不改封版 A62，不假稱角色已跑得自然。
- 參照 [A32 原始 GIF](https://drive.google.com/file/d/1vTon--mdqLmEFURFsgh2BlAuWPk-8MPS/view) 與 [原始 PNG](https://drive.google.com/file/d/1d8DkviKeRWSvbp3NrSSO4bKeCTqxmGA1/view)。

## 二、A33 這次制定的**單次**修正實驗
- 承襲 A32 成功的 Creator GUI `https://www.pixellab.ai/create?tool=animate_with_text`、模型 **V3**，A30 approved RUN_START 64×64 RGBA；來源 SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`。
- **改成 4 個生成姿勢，總計預期 5 格（包含 source F0）**：F0 原樣，F1 左腳前、F2 交會、F3 右腳前、F4 回原中立。固定東南向 45 度、整個臉與鎧甲始終同角度，動作幅度集中手肘、髖關節、膝蓋與腳掌，不准往鏡頭走。
- 唯一可執行設定及完整 prompt 已提交 [A33 JSON 生產設定檔](../../tools/asset_factory/configs/a33_actor01_v3_run_counterphase.json)。未生成前不允許預先標 Motion PASS。
- 原則仍為 **最多 1 次月度 generation**，不購買額外 Credits，不重做過去 A17/A18 骨架與 A29 RBF。若模型輸出第一幀＋4，應驗收 5 格，而不是因格式不同誤判。

## 三、真實遠端操作與 Failure Log
1. 使用者 PC `DESKTOP-90VT437` Desktop Commander 仍在線，**Chrome PixelLab 登入此前已驗證有效**。可開獨立 Chrome app 窗口並看到 User Gallery 96（A32 後），但操作過程中獨立 Creator 視窗多次失去可定位狀態，原本的 Chrome 分頁亦在遠端操作時切換到其他網頁。
2. 曾改從原 Chrome 新分頁開 Creator，成功讀到已登入 Animate with text 表單，**但準備點擊 upload 時該分頁不再前景**，工具回報 `stale element frame` 或 `UPLOAD_NOT_IN_ACTIVE_WINDOW`。為避免對其他網頁誤輸入，未強行點擊、未繞過驗證。
3. **A33_PIXEL_LAB_GENERATE=NOT_RUN；A33_NEW_AI_POSES=0；PROVIDER_COST=0；ART=NOT_RUN；VX=NOT_RUN**。沒有任何基於 A33 的新 GIF/PNG 成品，也不宣稱已送出背景 job。
4. 從 owner-only Google Drive 複製 A30 approved input 到 Windows TEMP 時核對 SHA256 PASS；操作中途停止後，`FS_A33_TRANSIENT_APPROVED_RUN.png` **已刪除，實際回覆 `A33_TRANSIENT_REMOVED=True`**，不留使用者本地暫存。
5. 這是 **REMOTE_UI_FOCUS_LOSS**（Chrome 視窗前景/可定位性不足），**不是** A30 畫格、PixelLab 額度或模型生產功能失敗。不要因此重新要求使用者登入／購買。

## 四、下一個有意義的可執行步驟
在 Chrome Creator 有穩定互動窗口時直接：
1. 從 owner-only [A30 核准 PNG](https://drive.google.com/file/d/1MgbYNn-Y1y28Tbltzh6G7JVVo63xlajE/view) 上傳第一幀，核對顯示 64×64。
2. 套用 A33 JSON `prompt`，Frame count 改 4，預覽 UI 當次 `Generate · N generation`；確定使用本月額度且不買 Credits 後才送一筆。
3. 從 PixelLab 下載原始 PNG spritesheet + GIF，依實際幀數擷取分格，先審查 **左右腳前後交換**與 **完全不轉臉/身體**，再看衣服與 loop；若失敗，紀錄真實 provider FAIL，不補上程序生成替代。
4. 私有原始檔保存 owner-only Drive，更新 GitHub QA/Handoff，避免侵入 main 與已核准 A62。

**本輪封版狀態：** QA of A32 source PASS, A33 input/profile READY, A33 provider NOT_RUN, art NOT_RUN, PC temporary cleaned, Drive original authoritative, main unchanged.
