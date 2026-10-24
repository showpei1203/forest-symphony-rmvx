# Forest Symphony／共享遊戲工具鏈｜T17B LPC 雙深度武器疊圖

2026-10-24。**T17B_LPC_DAGGER_TWO_DEPTH_24FRAME_STRUCTURAL_PASS**。僅工具隔離區測試，未修改正式 Forest Symphony 505 個 SEALED scripts，也未碰既有地圖。Human Gate F 尚未通過。

## 來源鎖定與授權
- LPC Base 身體/褲裝：LPC Base Assets（OpenGameArt），壓縮包 SHA-256 `69efec8a26ef20b26cfd7a8de370e87d0e667136eba2d00392dde13d2ac52465`。保留原始 CREDITS。
- 官方 Universal-LPC-Spritesheet-Character-Generator，pin commit `9bf06be193b053db256b2536824af426de046aa2`。
- 武器檔案：`spritesheets/weapon/sword/dagger/behind/slash/dagger.png` 與 `spritesheets/weapon/sword/dagger/slash/dagger.png`。GitHub 原始完整 CREDITS.csv 中各自對應邏輯鍵 `weapon/sword/dagger/behind/slash.png`、`weapon/sword/dagger/slash.png`。
- 原作者 bluecarrot16、Johannes Sjölund (wulax)、Matthew Krohn (makrohn)，來源各自允許 OGA-BY 3.0／CC-BY-SA 3.0／GPL 3.0。此技術測試選 OGA-BY 3.0，須遵守其原始署名條款；身體/褲裝亦須保留舊來源授權聲明。見 `inputs/SELECTED_CREDITS.json`、`inputs/lpc_base_credits.txt`、`inputs/CREDITS.csv`。
- **這批素材未經正式 Approval Gate 審查，不放入 Forest Symphony Approved Assets，也不能推定其他 LPC/PMD/SBS 權利已過關。**

## 像素驗證
- 角色 `male_slash.png`、`male_slash_pants.png`，加上可分離匕首 foreground/background，共 4 層。
- 384×256 RGBA，6 欄×4 列，64×64，24 格；方向 up/left/down/right 沿用原 LPC 座標約定。
- 前後景順序嚴格為 `dagger_behind → body → pants → dagger_front`，同位置、無縮放、無補間。
- 逐格合成再拼成 Sheet 和整表單次合成結果 RGBA 完全一致。
- 24 格中 20 格存在可見武器像素；其餘 4 格來源武器完全透明，保留原樣，不偽造幀。
- 負向測試：weapon-front 右移 1px → 978 像素差；交換左右方向列中的 left/down → 1,630 像素差；反轉 front/back z → 64 像素差；遺失 behind 層 → 159 像素差。
- 已查看 `outputs/T17B_BEFORE_AFTER.png`，整表中武器跟隨揮砍；仍需人眼逐格確認握把/手部及 SBS hit-frame、動畫時間，不可宣稱藝術 PASS。

## 如何測試
在含 `lpc_base_assets.zip`、`inputs/` 與 `run_t17b.py` 的資料夾直接雙擊 `RUN_T17B.cmd`；需 Python 3.11+、Pillow 12.3+，正常情況完全採已鎖定的本機來源，不需要網路。
- 執行 LOG：`T17B_RUN.log`。
- JSON：`T17B_LPC_WEAPON_LAYER_ALIGNMENT.json`。
- 圖檔：`outputs/dagger_slash_4dir_full.png`、`outputs/T17B_BEFORE_AFTER.png`、4 張方向 strip。
- `DELIVERY_INTEGRITY.json` 逐檔 SHA256。
- ZIP 出處 E:\GameAssetToolLab_20261023\deliveries。

## 未通過的後續工作
- **T17C** 128×128 單手劍前後景對位、裁切 anchor 及合法版權授權條件。
- **T17D** 正式 SBS 連號武器 sprite 與 vx native runtime/hit timing。
- PMD 權利與引擎視覺 QA，不能由 LPC 結果推定。
- Forest Symphony SCENE04 美術與 Human Gate F，繼續 PAUSED。
