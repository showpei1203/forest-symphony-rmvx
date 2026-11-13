# A27｜新生成跑步畫格（OpenAI 圖像工具）｜實際 PNG／GIF、生成失敗分類、ART HOLD
日期：2026-11-13。依使用者 v1.1 優先序：**先真正產出，再談尺寸、原生格數、匯入**。
狀態：**NEW VISUAL ART CANDIDATE 3 PNG + GIF = YES；ASF PROVIDER NEW RUN = NO；ART = HOLD；NATIVE VX = NOT_RUN；SEAL = NO。**

## 這輪實際做了甚麼
1. 在隔離容器讀取真正 A18 核准的白髮 Actor01 F0，SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，來源 owner-only Drive。
2. 呼叫 OpenAI 圖像生成工具，希望製造新的多個 RUN 姿勢。**生成工具兩次都錯誤製作「宣稱 ASF 測試成功」的資訊圖表**，沒有直接給可供遊戲使用的正式 sprite sheet。資訊圖表上的勾勾、ASF 使用與 QA 數據屬未經驗證的生成文字，全部不作工程證據。
3. 第二張圖（生成 ID `6c6d882d-2cf3-479a-b4fd-4ea19a95dd69`）確實繪出了**三個不同**新姿勢；使用 Python／OpenCV 從左下的三個角色插圖區塊抓取圖像，依亮度及色彩差異移除棋盤格背景、保留主要連通物件，再用局部填色修復髮色缺口。
4. 成品 PNG 三張，獨立尺寸 **136×148、135×133、136×147 RGBA**。不做 48×48 壓縮、不強制 3 格為官方原生規格。依原高度 bottom-center 排列的預覽 canvas 136×148，三欄 PNG 408×148，3 幀 GIF 可播放。**這是從生成影像「擷取」所得的可檢視新候選，不是 ASF 或 PixelLab 直接生成的 sprite**。
5. Source infographic、三張 PNG、GIF、深底與淺底預覽、F0 對照、QA JSON、兩個擷取／清理程式、README **共 15 個檔案**封存成 owner-only Drive ZIP。

## 真實數值與失敗紀錄
- 三幀逐張可見不透明像素：`10,155 / 8,959 / 9,559`。三張均二元 Alpha（只含 0／255）。
- 畫格兩兩 RGBA 差異：`F1-F2 = 11,901 px; F1-F3 = 10,964 px; F2-F3 = 11,224 px`（統一 136×148 預覽座標）。這代表圖像不同，不代表腿部步態已正確。
- 單張可見 RGB 不同顏色數：`8,023 / 7,291 / 7,456`。**已核准的 F0 只有 35 左右顏色**，本次輸出是高色數、帶抗鋸齒的「像素畫風」而非正式 1x 像素素材。
- **Art FAIL/HOLD**：原 F0 深綠裝甲變成深藍裝甲、白色披風／圍巾改變角色設計、45° 戰鬥角度變側身、移除棋盤格背景有白色像素缺洞／邊緣噪點、三姿勢是否雙腳輪替未能證實。
- **Source/Provider**：OpenAI 圖像工具產生一張帶角色的新圖；原版 Agent Sprite Forge 0.6.0 **沒有使用於本輪新藝術**（A24 只有 synthetic smoke）；PixelLab 新付費呼叫 **0**。勿誤稱本次 ASF 生成成功。
- **Art status**：`HOLD`，候選 PNG 可以檢視，但不能替換已封版 A62 或匯入正式 FS。
- **Game.exe**：`NOT_RUN`；**正式 main**：未修改；**正式封版**：未覆寫。

## 雲端證據
- Google Drive owner-only ZIP：`FS_A27_NEW_RUN_IMAGEGEN_EXTRACTED_PRIVATE_ART_HOLD_20261113.zip`，**2,850,106 bytes，15 entries，SHA256 `d03486673dbcf0dd3ccec659a8f97c99e3139a6f9d98e0053495e26462d039f7`**。
- Drive File ID `11g9M8EcmQ-onjDGH23LQ3I04VKLLnc2D`，[Drive restricted artifact](https://drive.google.com/file/d/11g9M8EcmQ-onjDGH23LQ3I04VKLLnc2D/view)，metadata shared=false；上傳後下載回讀 SHA256 一致，ZIP CRC PASS。
- 來源／候選圖像不放公開 GitHub，只有這份工程交接／QA。

## 對本次問題的工程結論
- **已突破「只有技術規格卻沒有任何新圖」：三張實際新的角色動作圖已落地。**
- **但未突破「高品質可量產 FS 動作」**：本次圖像生成器偏向 infographic，且輸出像素不乾淨；「在圖片裡畫幾個角色→再摳圖」屬失敗回收途徑，**不要升為正式產線**。
- 下一次優先找能**直接輸出單角色 1x RGBA PNG / frame-by-frame** 的實際 provider（已購 PixelLab Skeleton v3，或 ASF + 真正 I2V），用核准 F0 一次做 4～8 姿勢。尺寸不限，背景與角色攝影角度固定，先看藝術效果；付費呼叫依 P0／既定限額授權。避免繼續重試會輸出資訊圖表的圖像工具，或再次製作純 codec 重播。
