# A32｜已用 PixelLab V3 直接產生第一組 Actor01 RUN 新動作｜正式素材 QA 與 Failure Log
日期：2026-11-13。**這是實際模型生成，不是 A62 重播／程序 RBF／GIF 假展示。**

## 結果快照
- **PROVIDER_GENERATION = REAL / PASS；PIXELLAB_MODEL = Animate with text V3**，在使用者真正已登入的 Chrome Creator 頁面 `https://www.pixellab.ai/create?tool=animate_with_text` 操作。
- 依 A30 核准 A62 RUN 起始圖（48px 真藝術放在 64×64 透明 RGBA 畫布；input PNG SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`）選 V3、透明原始 PNG 第一幀、8-frame RUN 提示詞，首次按 Generate 時顯示 **1 generation**。模型生成完畢後 Gallery **95 → 96 筆**，最上方新作品有正確 RUN 文本與可播放的 9-frame 動畫。PixelLab 沒有要求額外 Credits 或信用卡付款。
- **Requested 8 → returned 9 frames (first frame + 8 generated)**。Original GIF 64×64×9、8 FPS、6,561 bytes、SHA256 `54b00c9dd3ca0940d7b64c9783beca623c6ca3b7133de740453101ecc0eb2b86`；Original PNG spritesheet **192×192 = 3×3×64×64**、11,325 bytes、SHA256 `c63e40a8321dd12bf56a53b2ddece3f7596114daa8b3105c3d4412985e2c0b76`。
- UI Gallery 卡顯示 **32×32** 是縮圖資訊，與真正下載結果不符，不應作為生成尺寸拒絕理由。
- **來源保真：** PNG 第一個 frame(0) 與 A30 64px RUN_START 逐 RGBA 像素差 **0**；所有 9 個 frame SHA256 各異，獨立畫格數=**9**，相鄰 frame 的 RGBA 差異 pixel 數 `[435,428,398,532,395,464,462,488]`，**不是 A62 舊帧的靜態重播**。
- **像素品質：** 每幀 RGB 色數 `[35,49,47,48,49,51,44,51,48]`，所有 Alpha 都只有 0／255，確實是清晰像素圖；新畫格各有約 14～20 種原色盤外顏色。GIF 與 PNG 逐幀可有調色盤量化差異，請以**原始 PNG spritesheet**為保真權威。
- **ART = HOLD**。已人工查看 6× contact preview：基本人物身份、白髮、綠衣與比例一致，優於 A27 infographic 擷取與 A29 RBF 拉絲；但 3/4 戰鬥相機角度在中後段略有漂移，動作比較像步行/踏步，雙腳輪替沒有清楚到能驗收為「自然 RUN」。F0 的原始姿態與後續動畫尾幀銜接仍需改善。**ART 不因 9 unique frames 而自動 PASS**。
- **NATIVE VX／Tankentai／PMD = NOT_RUN**；原生匯出不必硬性先縮 48px。**main/封版 A62 = UNCHANGED；正式美術替換 = NO。**

## 直接可檢視的 owner-only 雲端實體
1. [PixelLab 原始 9 幀 GIF](https://drive.google.com/file/d/1vTon--mdqLmEFURFsgh2BlAuWPk-8MPS/view)（provider-export，非程序合成）
2. [PixelLab 原始 192×192 3×3 PNG sprite sheet](https://drive.google.com/file/d/1d8DkviKeRWSvbp3NrSSO4bKeCTqxmGA1/view)（首選像素精度權威）
3. [9 幀 6 倍美術對照圖](https://drive.google.com/file/d/1TyvIDx-z3qTjBiSnlYujKFlTtfQTMo8B/view)
4. [14-file A32 完整隔離 ZIP](https://drive.google.com/file/d/16BlLBeoMgufaj8jSC8u7WfCmrSWmKBXK/view)：含原始 PNG/GIF、9 個真實 64×64 RGBA PNG crop、對照圖、橫排、QA JSON。ZIP **61,463 bytes／SHA256 `2eaea6569043b8bbe688c85620f144e094f88eacc3bc98d66fa6df7cda2098a7`**。上傳後從 Drive 下載 SHA256 與 ZIP CRC PASS。以上 Drive metadata `shared=false`。

## P0 追蹤／問題清單
- **LOGIN FALSE NEGATIVE RESOLVED**：用戶自己 Chrome 早已登入，A30 的獨立 Orca profile 無 cookies 造成錯判。A32 以 Chrome `--app=https://www.pixellab.ai/create?tool=animate_with_text` 開獨立視窗，沿用**正式 Chrome profile**，有 Sign out，不改用戶密碼/Token。
- **MCP 不再是首要阻礙**：Codex MCP 的 GET 核准仍未解，但這輪直接使用用戶已登入的 GUI 正常成功生成，沒有破解權限或讀 API 金鑰。
- **P0 LOCAL CLEANUP**：用來上傳 64px 原始 PNG 的 Windows TEMP 過渡檔在上傳成功後即已刪除；PixelLab GIF/PNG 兩原始下載檔從 `E:\Downloads` 移入 G: Google Drive owner-only restricted folder，源 E 檔案不存在；未在使用者 PC 留下 FS 工作成品／專案。
- **Provider Job ID**：網站 Creator UI 未展示，不得杜撰。模型請求 8 frames、結果 9 frames，已驗證 GIF & PNG 真實位元組。
- **Engine & Art**：不能以功能成功取代 RUN 步態驗收。雙腳領先交替及固定 45° 是下一輪要解的真問題。

## 下一輪（A33）最短可行改進
先不要重新跑 A17 骨架、尺寸、格式或 A29 RBF。用 A32 直接驗證的 Creator V3 通路進行**第二次 run motion 的差異化小型實驗**：提示詞明確分段規定畫格 1/5 是單腳著地、3/7 是換腳著地，固定頭／身／臉朝向，不許旋轉，擺臂和踢腿幅度增加但原地重心不飄移。若 V3 仍只能「走路」且相機漂移，才把 A18 核准 18 joints 輸入 Skeleton v3（只做 1 次對照），不繼續無止盡嘗試。每筆先確定 UI 的 `generation` 成本和授權，不自動連續耗點。

**A32 Seal:** provider PNG PASS / identity PARTIAL / RUN ART HOLD / VX NOT_RUN / cloud SHA+CRC PASS / main UNCHANGED.
