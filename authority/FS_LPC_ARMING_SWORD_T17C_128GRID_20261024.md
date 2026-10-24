# Forest Symphony｜LPC T17C 128×128 Arming Sword 與64×64角色無損對位 Authority

日期：2026-10-24。**TECHNICAL STRUCTURAL PASS：`T17C_128_CELL_WEAPON_24_FRAME_STRUCTURAL_PASS_HUMAN_PENDING`。**

## 不得更動已封版系統
FS map N5/B0 technical gates 6/6 PASS 為既有暫停基準；505個正式封版 RMVX scripts、Ground/PAR、Human Visual Gate F **未動，Human Gate F 仍待驗收**。本工作只在 Windows `E:\GameAssetToolLab_20261023\ToolValidation_T17C_20261024` 測試。

## 原生素材及可追溯授權
- 官方 `LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator`，確定 commit `9bf06be193b053db256b2536824af426de046aa2`。授權來源不能混同 CC0。
- Native male body `spritesheets/body/bodies/male/slash.png` 384×256、64×64×6×4，SHA256 `662e208502b0f060041cd3e8c65b6445117f174e9435b68e619b874e36b0069d`；原生 Body **不含頭部/頭髮**，須另組裝。
- `spritesheets/weapon/sword/arming/attack_slash/bg/steel.png` 768×512、128×128×6×4，SHA `51ceabbb583527f2c3b310ff34d4abc0db35c9cf75a34b8c9855be0890386f22`；
- `spritesheets/weapon/sword/arming/attack_slash/fg/steel.png` 同尺寸，SHA `7f9dc95ee8c48284384510e191c51a02fe6325f7c9d37c2933aa0ff22d40bec2`。
- `CREDITS.csv` SHA256 `9bc3c6fc660946a8f36cefe8df8196884ac0309869cdcf3a8741f40577eb8c50`；對應 logical credits `weapon/sword/arming/attack_slash/bg/slash_128.png`, `fg/slash_128.png`，作者 **ElizaWy**（walk/down also **JaidynReiman**），均列 **OGA-BY 3.0**。Male body source 列多位作者，OGA-BY 3.0/CC-BY-SA 3.0/GPL 3.0，作者及來源 URL 見私有驗證 ZIP 的 `inputs/ASSET_CREDITS_SELECTED.json`。正式發行必須正確署名且完成 asset license review。
- 所有來源為 tool validation，尚未納入 03_Approved_Assets。

## Coordinate/Rendering Contract
**絕不能把 64×64 人物硬放大到 128×128。** 每行方向 up/left/down/right，各有6幀；Body 原生每格 64×64，武器 front/back 各每格128×128。每個 body 64格使用整數座標放入相應 128格的局部 `(32,32)`，不縮放、不補間、不重新繪圖。

合成順序：**Sword behind → Body(64嵌入128) → Sword foreground**。共24格，整表 768×512；像素精確 gate：
1. 24格逐格合成並重拼，與3層直接合成全表的 RGBA byte-exact 0差。
2. 由嵌入的大表逐格還原原 Body 384×256，RGBA byte-exact 0差。
3. 武器可見24/24格。各武器128格邊界**0個非透明像素**，沒有跨格切斷的風險。
4. Mutation Gate：Body 的嵌入位置 x+1px → **7865** 像素差，Sword foreground x+1px → **1822**，倒轉前後層 → **644**，移除 weapon behind → **645**，全部應被抓到。

`(32,32)` 是幾何與人眼預覽所選定的 **當前技術候選**，並非官方或商用角色最終 Artistic Anchor。已測其餘 `(0,0)`、`(32,0)`、`(32,16)`、`(32,48)`、`(32,64)`；像素重疊指標不能單獨代表握持正確。

## 尚未通過（嚴禁宣告 FULL PASS）
- Modular body lacks head/hair；正式角色需另配頭部並核對作者/授權。
- 大劍斬擊的 blade arc 可能跨出 64px character rendering region：**VX 不能把整張128px weapon直接裁成64px**，必須保留 128x128 attack frame 或自訂 combat sprite adapter。
- VX/Hero foot pivot 位置候選 `(64,96)` 是未經引擎驗證的值；Godot/VX runtime、SBS Attack Hit frame、人物握手與武器關係、human visual Gate F 尚待實機驗收。
- T17B dagger 64px 系列與 T17C 128px 系列應明確分開規格，不能以 resize 作相容手段。

## 實機證據與交付
- `RUN_T17C.cmd` 已在 Windows GUI/本機 Python 重新執行 **PASS**。
- `T17C_128_ARMING_WEAPON_VALIDATION.json`；`T17C_RUN.log`；
- 藝術預覽：`outputs/T17C_128_FOUR_DIRECTIONS_HUMAN_PREVIEW.png`，亦有 `outputs/candidate_x*_y*.png` 六組位置。
- 完整可回歸私人 ZIP: `E:\GameAssetToolLab_20261023\deliveries\FS_LPC_ARMING_SWORD_128_T17C_20261024.zip`，**33 files / 358,872 bytes / SHA256 `1b86214c74f5c01cc7b91f2028a96229d5fdbb05b77eb2b7916f97061c3716b1`**，完整 testzip+per-file SHA verified。此包在 Windows E 槽，尚未確認完整二進位有上傳 Drive。
- Drive Handoff：https://docs.google.com/document/d/1ADZXSADZA80uD25j6pyKqIeUpSLdUJYQMRoIENL_McQ/edit 。

下一步：T17D head/hair source license + character origin/pivot + VX/SBS weapon action sheet，保留 FS 正式封版限制。
