# A33｜PixelLab V3 四姿勢 RUN 真實生成與美術驗收（2026-11-14）

**判定：PROVIDER PASS／RAW PNG+GIF PASS／F0 SOURCE PASS／5 DISTINCT FRAMES PASS／ART HOLD（FOOT ALTERNATION FAIL & LOOP FAIL）／VX NOT_RUN／FS MAIN UNCHANGED。**

## 一、這輪實際執行，不是施工計畫
- 遠端連線真實桌機 `DESKTOP-90VT437`，使用**原本已登入的 Chrome PixelLab Creator**。由 G: 私人 Drive 複製 A30 approved RUN_START **64×64 PNG** 至 Windows TEMP，核對 SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`，透過檔案選擇器正常上傳；PixelLab 第一幀 UI 確認 `64x64px`。
- 使用 `Animate with text V3`，明確指令 F1 左腳領先、F2 交會、F3 右腳領先、F4 回 F0，嚴禁角色朝向鏡頭轉向。Frame count **4**，Generate 按鈕明確顯示 **1 generation**，實際點擊執行一次；Gallery **96→97**，確認最新工作完成。
- 直接從 PixelLab 下載原始 GIF（**64×64、5 幀、8 FPS、3,681 bytes、SHA256 `c0ec3bd44b318140c7d22fcb9c1c48cef470cf5093eccd7f8c074b72a0b3bee0`**）和原始 spritesheet PNG（**192×128、5 格、6,364 bytes、SHA256 `8cb83e348be397e7c95cb29483ed82d048d16ba641a4eaf2cc5b87ee56d3193c`**）。第 0 格是原圖，其餘四格是新生成，絕非 A62 舊幀重播／人工拉伸。
- 兩個下載檔已由 E:\Downloads 搬到 G:\私人 Drive 限制資料夾，原 E 檔不存在，TEMP 輸入已刪；沒有在桌機保存新的本機 FS 美術工程。

## 二、直接 QA 與畫面驗收
- 分割原始 PNG 出 5 張 64×64 RGBA（不重新採樣），比對 A30 核准輸入得出 **F0 差 0 個 RGBA 畫素**。
- **5/5 unique**，相鄰畫格像素差 `472, 439, 454, 442`；每格可見色數 `35,44,41,43,44`，所有 Alpha 值只有 0/255。中心點坐標分別 `(32.09,31.92),(31.78,31.37),(32.03,30.46),(32.75,31.26),(32.75,32.17)`。
- [A33 九宮格版面以五幀 7 倍最近鄰放大](https://drive.google.com/file/d/1nuz1aSvvezx1dsLjXX-bD0wqEHPlKFxU/view)，[A32 上排／A33 下排 5x 同尺度比較](https://drive.google.com/file/d/1u2OAKmWIruEkv1tVzQJWbQ3OwdgT0Ok-/view)。
- 角色白髮、暗綠服裝、大致比例、像素質感良好；但 A33 **F1/F2 腳沒有明顯前後交替**，F3/F4 雖有側向手臂擺動和腿部輪廓改變，仍不像清楚的左腳領先→右腳領先的原地跑步。
- **F4 未回到 F0**：最後格與原 F0 **477 像素不同**，F4 頭部 ROI `(16,9,49,31)` 跟 F0 有 **210 像素不同**，故**不能直接視為閉合循環**。鎖定 45° 的姿勢也不是逐格一致。此二項是美術 FAIL，不是 PNG 格式 FAIL。
- A32 的頭、身向鏡頭前進傾向在 A33 縮短序列後略減，但仍沒有取得自然 counterphase 跑步；不得宣告「RUN 美術通過」。

## 三、雲端實體證據（均 owner-only）
- [A33 原始 PixelLab GIF](https://drive.google.com/file/d/15tp55cRjp_wI5YWgcbtdm0tdup6tB_QV/view)
- [A33 原始 PixelLab Sprite Sheet PNG](https://drive.google.com/file/d/1jaPqanGTM-lYs8ad5GJ3jirgODH5EQy-/view)
- [A33 5 格預覽放大圖](https://drive.google.com/file/d/1nuz1aSvvezx1dsLjXX-bD0wqEHPlKFxU/view)
- [A32／A33 實際同尺度比較](https://drive.google.com/file/d/1u2OAKmWIruEkv1tVzQJWbQ3OwdgT0Ok-/view)
- [A33 **完整 11 檔 ZIP**](https://drive.google.com/file/d/1op7uzo0jQUjr0khC5rTQKrf0h9XtZwMb/view) 44,039 bytes、SHA256 `0d5afc7f9a9de86d645a9d2ceede03eca520ef7e7ba2453c736fa17e296991ac`、ZIP CRC PASS；包含兩原生檔、5 張逐格 RGBA PNG、QA JSON、對照預覽和 README。已驗證 Google Drive metadata `shared=false`、download readback bytes/hash/CRC。

## 四、Failure Log 與下一輪技術決策
- **A33_TEXT_PROMPT_CANNOT_ENFORCE_FOOT_LEAD**：四格 V3 說明動作轉換雖有像素差異，仍沒有達到清楚左右腳互換，故停止僅靠文字 Prompt 微調反覆花費點數。
- **A33_LOOP_CLOSURE_FAIL**：明講回 F0，模型仍回傳不同的最後影格，不可宣稱無縫循環。短期可使用**F0→生成 F1→F2→F3→F0** 封閉展示作相容性測試，但這不能證明 A33 動作美術 PASS。
- **A34 優先方案**：用 A62 已核准原始左腳領先／右腳領先幀直接做 PixelLab 兩端姿勢控制（Interpolation / Skeleton v3；先核對平台現行功能與點數），使**生成端接收真正不同的關節姿勢或兩張關鍵畫格**。不從頭重新畫角色或限制 48px。每次只做一組成本可控的 provider pilot，重新產出結果後再檢查角度、腿、身體和循環。
- 尚未進入 Tankentai／Godot／VX 真正戰鬥動畫匯入，因 ART HOLD。不覆寫 main、A18、A62。

**本輪雲端 Handoff 的目的：** 保存真實模型輸出與失敗條件，下一輪免重做已成功的登入、雲端 input、gif/pixel-format 技術。
