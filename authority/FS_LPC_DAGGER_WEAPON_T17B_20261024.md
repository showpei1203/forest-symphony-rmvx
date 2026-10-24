# Forest Symphony｜T17B LPC 雙深度匕首 × 揮砍 24 幀疊圖驗證（2026-10-24）

## Authority Boundary
**T17B_LPC_DAGGER_TWO_DEPTH_24FRAME_STRUCTURAL_PASS**。此為獨立工具鏈的像素和原始資產結構 Gate。FS 地圖仍 PAUSED: N5 isolated runtime adapter 6/6 TECHNICAL PASS, original 505 SEALED Scripts unchanged, **Human Visual Gate F PENDING**。**不**涉及 Tankentai SBS 正式 runtime、戰鬥 hit frame、PMD 權利或完整武器量產。

## Source, license and hash
- 原始 LPC Base Assets: `lpc_base_assets.zip`，SHA256 `69efec8a26ef20b26cfd7a8de370e87d0e667136eba2d00392dde13d2ac52465`，`male_slash.png` 與 `male_slash_pants.png`，按既有原始 `CREDITS.TXT` 署名 Stephen Challener (Redshrike)。該包提供 CC BY-SA 3.0 / GPL 3.0，舊 CREDITS 註明作者部分可採 OGA-BY 3.0。商用需逐項選擇相容的實際授權。
- 武器由官方 `LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator`；**pin commit `9bf06be193b053db256b2536824af426de046aa2`**，不以浮動 master 作正式同源再現。
- `spritesheets/weapon/sword/dagger/behind/slash/dagger.png` SHA256 `328b5818b9d379e77b6ec51edbf0de49dc987e41db252841c16a7dfcc978fbc0`。
- `spritesheets/weapon/sword/dagger/slash/dagger.png` SHA256 `238792746ed9d90148ac9a85c88d224f1ea81ea2376fcb85228b26fdf1159cd1`。
- 官方 `CREDITS.csv` SHA256 `9bc3c6fc660946a8f36cefe8df8196884ac0309869cdcf3a8741f40577eb8c50`；對應 logical keys 是 `weapon/sword/dagger/behind/slash.png` 與 `weapon/sword/dagger/slash.png`；作者 **bluecarrot16, Johannes Sjölund (wulax), Matthew Krohn (makrohn)**，所列授權 **OGA-BY 3.0 / CC-BY-SA 3.0 / GPL 3.0**。本 private test 使用 OGA-BY 3.0 授權選項並保留署名，不表示整套 generator 或 PMD 素材均屬 OGA-BY。
- 官方：https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator ；LPC Base：https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles 。

## Actual test & negative mutation
- Body 384×256 RGBA，Pants 384×256 RGBA，Weapon behind/foreground 各 384×256；每幀 64×64，**6×4 = 24 幀**，方向列 up/left/down/right（沿用 LPC 格位約定）。
- Z 明確：`weapon_behind -> body -> pants -> weapon_front`。逐幀 Alpha-composite 然後重新拼合，與相同圖層直接全表 Alpha-composite **0 pixel RGBA difference**。
- 24 格中 20 格擁有非透明武器像素；Up frame0..3 原始武器透明，保留原樣。不能憑空生成補幀。
- 防呆故意破壞：weapon front +1px `978 px`、對調 left/down `1630 px`、反轉武器 z 堆疊 `64 px`、刪除 behind layer `159 px`，全部能檢出。
- `T17B_BEFORE_AFTER.png` 經初步視覺檢查無切幀/整列偏移，但手部握持和時間上的自然度 **HUMAN VISUAL PENDING**。
- 重跑 `RUN_T17B.cmd`：來源使用本機 cache、pin GitHub source commit/已核 SHA，不需要重新下載已知檔；退回英文錯誤提示也應當 FAIL-CLOSED。

## Deliverables
Windows: `E:\GameAssetToolLab_20261023\ToolValidation_T17B_20261024`；
- `run_t17b.py`, `RUN_T17B.cmd`, `README_繁體中文.md`；
- `T17B_LPC_WEAPON_LAYER_ALIGNMENT.json`, `T17B_RUN.log`, `outputs/*.png`, `inputs/SELECTED_CREDITS.json`, `inputs/CREDITS.csv`；
- `DELIVERY_INTEGRITY.json` SHA per file;
- **Complete private test package** `E:\GameAssetToolLab_20261023\deliveries\FS_LPC_DAGGER_WEAPON_T17B_20261024.zip`，**22 files, 859,727 bytes, SHA256 `b09678d4f1523d14e240fbd304e62ac3ff2f7433b910c4327802c55d3a5dcc83`**；用 ZIP testzip +逐檔 SHA 驗證。

**Publishing Gate：** 不將此測試 ZIP 原樣升為 FS `03_Approved_Assets`，不在公開 GitHub 放入第三方 PNG／二進位源；正式對外釋出需確認雙方授權相容性、完整 credits 和衍生品要求。

## Next: T17C
新 LPC arming sword slash FX 128×128 是 front/back 各層兩倍 cell 的 sheet 768×512，需要明確 anchor、crop、人物 64×64 插入偏移及逐幀 human grip QA。絕不能強行把 128x128 當作既有 64×64 格，亦不能只靠工具跑完就稱 SBS full-formal PASS。
