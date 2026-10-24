# Forest Symphony｜T17C 128×128 單手劍雙深度動畫座標契約

版本 2026-10-24｜**T17C_128_CELL_WEAPON_24_FRAME_STRUCTURAL_PASS_HUMAN_PENDING**

## 實測
- 來源：Universal LPC Generator GitHub PIN `9bf06be193b053db256b2536824af426de046aa2`，兩個 arming/attack_slash 素材、男 body/slash。
- Source licensing：官方 `CREDITS.csv` 的 `body/bodies/male/slash.png` 及 `weapon/sword/arming/attack_slash/bg/slash_128.png`, `fg/slash_128.png` 均有 OGA-BY 3.0 授權選項；武器作者 ElizaWy、walk/down JaidynReiman；男 Body 多位作者，詳 `inputs/ASSET_CREDITS_SELECTED.json`。實際出版須將完整 attribution 合併進遊戲，不可稱全套為 CC0。
- Body 原生尺寸384×256（6×4，64×64）；武器 behind/foreground 各768×512（6×4，128×128）。
- 無任何縮放／補間。將每一個 64×64 body 填入對應128×128格子的局部座標 `(32,32)`。每格 sprite origin 候選 64,96，**尚未 VX／Godot 實機或人眼確立**。
- 全表圖層合成順序：weapon behind → body → weapon foreground。24個逐格拼合後 RGBA 與整表直接 alpha-composite 一模一樣。可從嵌入圖片精確抽回 64×64 original 24格，0像素差。
- 武器 visible frames 24/24；128×128 cell 邊界0個武器非透明像素，沒有 cut-off。
- 負測：人物 x+1px、前景 x+1px、前後景 Z 反轉、移除後景；各測均能檢出非零像素錯誤，數量詳 `T17C_128_ARMING_WEAPON_VALIDATION.json`。
- 已檢視 `outputs/T17C_128_FOUR_DIRECTIONS_HUMAN_PREVIEW.png`，沒有明顯跨格切割。注意模組化 LPC 男 body 本身沒頭，需要合法 Head/Hair 另行組裝並跑手部／握把 Human Visual QA。
- 不碰 Forest Symphony 地圖與 505 個 SEALED Scripts，不能宣稱 VX/SBS hit timing、Godot runtime、Human Gate F PASS。

## 檔案與再現
- `RUN_T17C.cmd`：讀 `inputs/` 本地原圖跑 `run_t17c.py` 並 fail-closed 檢查；不依賴網路。
- `research_t17c.py`：最初比對6組64↔128 嵌入位置用，已有快取圖片，為研究步驟，執行可能產生候選 `outputs/candidate_*`。正式回歸不要求跑此支。
- `T17C_RUN.log`：正式實機的執行原始 LOG。
- `T17C_ANCHOR_RESEARCH.json`：六種偏移比對重疊數；不能以重疊最多的那組自動認定美術正確。
- `T17C_128_ARMING_WEAPON_VALIDATION.json`：pixel-exact Gate及來源授權、負測記錄。
- `DELIVERY_INTEGRITY.json`：交付逐檔 SHA256。
- `outputs/T17C_ARMING_STEEL_128_MASTER.png`、`outputs/T17C_128_FOUR_DIRECTIONS_HUMAN_PREVIEW.png`、4方向 strip、嵌入 body mask。

## 下一階段
T17D：head/hair合法組裝 + grip/foot anchor 現場逐格視覺測試 + VX/SBS Weapon Frame 連號與 hit timing。請勿在地圖 Gate F 未通過前動正式地圖。
