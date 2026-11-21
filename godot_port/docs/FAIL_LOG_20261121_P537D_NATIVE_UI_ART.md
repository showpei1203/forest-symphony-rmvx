# P537D BATTLE original UI Native GPU Failure Log｜2026-11-21

## R0：明確 false-positive（已修）
原 P537C 真 source capture 初次輸出 544/1088 各3張，檔案合法、node visible、A52 atlas SHA 正確，當時 script 印「GPU 3/3 PASS」，但實際看 544 截圖：敵方原圖和 ACTOR01 都不在 viewport。原因：Window 根 FSScreen Control 未設 PRESET_FULL_RECT，原生 Control.size=(0,0)，所有錨定右側的角色/敵人舞台使用負 x 座標，完全不在物理畫面中。**這批 PNG 不認列 source art GPU PASS**。R0 截圖留存在 owner-only 最終 ZIP FAILURE_BEFORE。

## R1：人物回到畫面、開發提示遮擋（已修）
新增全視窗錨點後，源 Actor01 和 Battler 都真的出現，但遊戲 migration debug 文字跨過原版敵人標籤，UI 造成遮擋。修：battle source HP/MP/ATB 照常顯示；完整 debug status 仍在 text model 但不顯示遮擋；取消冗餘巨大提示列；原敵方 source canvas top=91→60。R1 影像留在最終 ZIP 作 before/after。

## R2：雙解析度本機真 GPU source pixel gate（已 PASS）
Godot 官方 v4.7.2.stable.official.ed1daf0bf、使用者 RX 6700 XT、OpenGL 3.3 Core / Compatibility driver 26.11.2.261112。原 UI202 + Battlers167 + A52 3 真 PNG staged 372 張，Godot Editor Import 372/372 steps exit0。
- 544×416：原敵人 PNG 必須出現，GPU ROI **2,506 pixels** changed；角色原 Body/Weapon/FX F7 **618 pixels** changed。
- 1088×832：Enemy **10,050 pixels** changed，A52 **2,472 pixels** changed。
- 原 54×48 4個 Battle01-04 ACT 按鈕 2×2 必須都在實際 viewport 內； F7 0.63sec contact 只視覺不改 HP/MP。截圖來源 actor、原 enemy 都已人工檢視確認畫面可見。
- 新 tests/capture_fs_p537c_private.gd 真正先隱藏原敵人再顯示，比對物理 framebuffer 的 Source ROI；再比對 A52 attack F7 與 idle baseline。**R0 zero-width screen 與 Invisible source 將 FAIL，不會再被 PNG existence 假陽性誤判**。
- 正式 evidence 6 PNG + 3 real logs + 2 false-positive comparison images + SHA manifest，12 files CRC PASS，owner-only Drive https://drive.google.com/file/d/1vS5pbWqWcyU7ZlXETv2C-SXAMfTcMsFT/view，514477 bytes，SHA256 b6f47468fbca6185f558196f2c0216ce765b02233a132c82ca534c49e4fb374e，shared=false。
- 公開 GitHub Godot regression #44872922592 88/88 steps SUCCESS，原圖只有 Google Drive，GitHub 無原版 PNG。

## 明確剩餘阻斷
BattleScape 真源背景未接；來源 11 post-Apply/505 last-wins Enemy/Troop DB 未正式驗證（本輪 source $001 由 synthetic fixture 指定）；A52 t=.630 與 source ACT damage hit timing／70ms hitstop 尚未精確同步；原 VX 同畫面 pixel parity 尚未驗證。全 BATTLE ART HOLD，Phase1 SEAL NO。原 VX E: 只讀，所有 binary artifacts 只在 Google Drive。
