# Forest Symphony A54｜Failure Log｜2026-11-17

## FL-A54-001｜刪除 weapon/FX 雙佔位圖後原 GPU QA 還在載入

- **症狀**：A53 clean 版檔案列表不再提供 `actor01_a53_empty_weapon_and_fx_12frames.png`，原 `qa/a53_barehand_icon_native_gpu_qa.gd` 仍兩次以此路徑讀取 Weapon/FX。
- **定位證據**：owner-only Drive A53 clean assets folder `1IRIy7err19LcTawIMX-nhY28RZf4O_BI` 列表、原 GDScript `1QPaeZ4WY3Dxqz17cQJoLBeWfQPucMUY1`。
- **修復**：移除已無用途的兩個路徑和 Image 載入，要求 A53 Body 與真正 Body reference 存在；新增缺圖時 quit(1)。
- **靜態測試**：以實際 12 個 clean/assets 名稱核對，原版指向已刪圖，修正候選 zero missing references。
- **結果**：STATIC PASS；尚未重做 Godot GPU cold run。
- **防再發**：`a54_asset_contract_gate.py` + GitHub Actions workflow + filename-only Drive inventory，每次精簡軌道需跑資源引用 Gate。

## FL-A54-002｜A53 clean GPU 原生冷測 95 秒逾時

- **原始狀態**：A53 clean `A53_GODOT_NATIVE_RESULT.json`（Drive `1Wb-vCi_9-Z4RWVboY6oGtYx7yu4YkXQi`）報告匯入成功但 GPU 原生測試 timeout / FAIL。
- **獨立性**：目前沒有足夠證據把 timeout 直接歸因於 FL-A54-001。原 log 未形成清楚的 first-frame/GPU 截圖進度。
- **修復候選**：於 `_run`、第一幀 ready、`_snap` 和 frame_post_draw 新增 `A54_GPU_STAGE` marker。
- **結果**：Godot native **NOT RUN**。下次授權必要隔離 native run 後，依 marker 定位 hang；不能寫成 PASS。
- **防再發**：原生啟動與 GUI/GPU 截圖階段各自設 fail-closed 狀態和最短可辨識診斷訊息。

## FL-A54-003｜驗收狀態誤混風險

- A52 12-frame、A53 歷史 5-裝備 GPU/Contact PASS，是歷史已成立證據；**不自動證明 A53 clean 版通過**。
- A54 GitHub cloud static CI PASS，不等於本地 GPU/native PASS。
- A51/R4 原始來源、Godot FS 主系統、私人付費 PixelLab 素材未更動。
- ART HOLD，FS 正式 ATB/技能/敵傷整合 NOT RUN。

## 執行政策

依 2026-11-07 GLOBAL HARD RULES / FS P0：所有正式新成果只存 GitHub/Google Drive，沒有寫使用者 PC。若 Godot 原生測試必須暫時在 PC 建檔，應先明示範圍與清除方式並取得授權；不能自行推測已同意。

## 可查核測試

- Cloud action: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43994167893 ，conclusion **success**。
- Current working branch: `fix/fs-a54-a53-clean-gpu-regression-20261117`。
