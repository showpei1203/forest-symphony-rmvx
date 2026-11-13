# A29｜真實 F0 骨架像素變形測試：失敗證據與 PixelLab MCP 權限門檻
2026-11-13 ｜狀態：**F0 SOURCE PASS / 8 offline motion frames generated / ART FAIL / PIXELLAB NOT_RUN / VX NOT_RUN / SEAL NO**

## 真正執行的內容
- 取 owner-only A18 ZIP 內核准 Actor01 原圖 **48×48**，來源 SHA256 `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`，結合 A18 真實 18 關節、3 pose 跑步骨架。
- 在 ChatGPT 隔離容器實跑 Python scipy `RBFInterpolator(thin_plate_spline)` 位移場，nearest-neighbor 逐格取樣、1px 垂直 bob，產出 **8 PNG + 8-frame GIF + sprite sheet + QA + script**；7 組獨立 RGBA PNG，F0 兩次作為呼吸/循環中立節點，全部透明背景、二元 Alpha、非透明像素只用原 F0 顏色。這些為**程序變形幀**，**不是 PixelLab/ASF 新生成的動畫**，亦不是舊 A62 幀直接重播。
- 在 6x 接觸圖可見極端姿勢中手臂／腿部橫向拉長、變成扁平條帶。**美術 ART FAIL**；沒有以「多幀、正確色盤」冒充自然動作成功。No new model frames.
- 本輪再次以遠端 Codex `--sandbox read-only` 嘗試 PixelLab 唯讀 `get_balance`：被 `MCP tool call requires approval, but approval policy is never` 拒絕；針對此任務指定 `approval_policy=on-request` 仍被宿主固定顯示 `approval:never` 而拒絕。**未取得餘額，不代表沒有點數；未讀取金鑰、未繞過核准、未付費呼叫。**
- 官方 [PixelLab v2 API](https://api.pixellab.ai/v2/docs) 有 `animate-with-text-v3` / `animate-with-skeleton-v3`，但**帳戶生成權限未驗證**。先保持 user policy：尺寸不設硬門檻，先有真正的新姿勢，再測身份一致性、45°、左右腳交替與畫格自然度。

## 私有實體證據
[FS_A29_RBF_WARP_REAL_F0_ART_FAIL_PRIVATE_20261113.zip](https://drive.google.com/file/d/1dry3E2-qB3TMz0AGEuGJ2JsVskst1NZt/view)，owner-only Google Drive，**32,540 bytes / 15 files / SHA256 `bad8c3e6e30142404af8a13f956e81990db81c3062c92dfe83f707f6a5223ed6`**。上傳→下載回讀 SHA256 / CRC PASS。ZIP 含 8 幀 PNG、GIF、384×48 sheet、6x 接觸圖、10x 失敗圖、完整腳本、QA JSON、Failure Log/Handoff。來源私有原 PNG 未提交公開 GitHub。

## 失敗類別與後續 Handoff
1. **GATE_APPROVAL_BLOCKED**：Codex 此模式對 PixelLab MCP 要求人為核准但 UI 不支援；不能自行讀本機儲存的 API token 迴避限制。生成前須有正式用戶核准與一次費用上限許可。
2. **ART_RBF_GLOBAL_WARP_FAIL**：全身 TPS/RBF 對小像素人形有手腳拉絲；停止這個演算法，不要再為了湊 8 幀連環修改。此測試只作負面案例。
3. **PIXELLAB NEW FRAMES = 0**：解除門檻之後使用已核准 A18 F0 做**一次受控** text-v3 或 skeleton-v3 RUN，完整下載獨立 PNG/GIF、先美術審查、後匯入 VX。沒有 provider 實績不可標生成 PASS。

`MAIN=UNCHANGED; PIXELLAB_COST=0; USER_PC_ARTIFACTS=0; ENGINE_VX=NOT_RUN; ART=FAIL; SEAL=NO`.
