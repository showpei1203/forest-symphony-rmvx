# FS T-A R26｜PixelLab 五姿勢預覽驗收工具（零費用離線階段）

**工程 STATUS：離線來源與 QA 工具 PASS；新 PixelLab 人物美術 NOT_GENERATED；ART_GATE NOT_AVAILABLE；FS Battle NOT_RUN。**

## 正確身分與目標
- A62 核准原圖：`source/A62_APPROVED_F00_64.png`，SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`，64×64、45° 東南 3/4 角，白髮、深綠／炭灰衣服、黑靴。
- 五姿勢：F00 準備、F03 蓄力、F05 出手、F07 命中、F09 收招。
- `source/R26_POSE_BLUEPRINT_NOT_PIXELLAB_PAYLOAD.json` 是從已原生測試的 R24 揮砍手部目標與轉體角度整理，**不是 PixelLab v3 API 原生 JSON**，不得直接 POST，須以實際 API schema 對齊。

## 本輪確實生成的是什麼
`previews/R26_REVIEW_CONTACT.jpg`、`R26_5POSE_NATIVE_1X.png`、`R26_5POSE_NEAREST_4X.png` 和 GIF **只顯示一張真 A62 F00 加四張骨架示意**。請勿判定為五張新畫美術，也不可用於遊戲。其用途是鎖住鏡頭／人體動作和示意真實交付的版式。

## 待 PixelLab 真正生成後如何使用
將**五張真正生成的透明原生 64x64 RGBA PNG**放於另一資料夾，命名：`F00.png`, `F03.png`, `F05.png`, `F07.png`, `F09.png`。

**嚴格要求**：F00 要完全等於 A62 原圖 RGBA，其他四張必須是新畫且不同、無填色棋盤背景、同一頭臉和衣服、不可像舊 A52 單純拿劍。完整 PixelLab 原始 job ID / API 模型與成本單另記 `PIXELLAB_JOB_RECEIPT.json`，不得把 Orca 沒執行過的空欄位偽造為成果。正式美術永遠要再過使用者 1× 視覺驗收。

```bash
python ta_r26_preview_gate.py selftest --source source/A62_APPROVED_F00_64.png --out qa
python ta_r26_preview_gate.py prepare --source source/A62_APPROVED_F00_64.png --out .
python ta_r26_preview_gate.py ingest --source source/A62_APPROVED_F00_64.png --frames <private_true_generated_5frames_dir> --out <private_review_dir>
```

`ingest` 只接受 64×64 五張真圖、F00 核准來源、非空 Alpha、不同姿勢、無裁切；輸出 `1×`、`4×`、GIF、接觸圖與 `R26_TECHNICAL_QA.json`；即使全部工程檢查 PASS，美術仍為 **PENDING_OWNER_REVIEW**。該工具目前不會呼叫模型、不會扣點、不會生成假的人體像素、不會把骨架示意圖當成人物美術。

## 經遠端實測的阻斷（2026-11-25）
- Windows 自建 GitHub Runner 正常，PC Bridge 原有安全白名單可用，三項讀取探測 #129、#130、#131 均已執行。
- Orca 有兩個執行程序與本機 CLI、九項共用 SKILL.md，但 `computer permissions`、`capabilities`、`list-apps` 均回覆 `runtime_unavailable`；不能透過 Orca 直接調用 PixelLab。
- Desktop Commander 遠端可用額度 0%。本對話無可直接呼叫的 PixelLab MCP Plugin。
- 原 T-B 有經正式驗證的私人 PC Bridge 受限 PixelLab API 工作方式，但尚未為 T-A 建立或核准新 PixelLab 付費 task。**不要用 T-B 的白名單 task 假裝生產 T-A。**
- 本輪內建影像生成服務失敗，沒有新畫面，未重試。

## 下一個完整施工單位
沿用私人 PC Bridge T-B 的固定來源 SHA、防重複扣點 job journal、固定 provider endpoint 與私有 Drive 封存，建立並審查**T-A 專用**五姿勢 PixelLab provider job。模型輸出回傳後自動丟入本 R26 `ingest`，只發佈真來源的 1×、4×、GIF，正式由使用者決定 ART PASS/FAIL。未解決工具連線與付費授權前，維持 **GENERATION HOLD**。
