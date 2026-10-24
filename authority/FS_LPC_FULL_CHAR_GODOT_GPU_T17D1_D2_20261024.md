# FS LPC T17D-1 + T17D-2｜完整角色與 Godot GPU 24幀實測 Authority (2026-10-24)

**狀態：`T17D1_T17D2_REAL_GPU_5_OF_5_PASS`。僅圖層像素驗證與 Godot 真實 GPU 畫面擷取，Tankentai SBS 和 RMVX 動作 HIT 時序未測。**

## 第一：正式規格與來源不得回滾
- Forest Symphony N5 B0 isolated runtime adapter 6/6 技術 PASS / N5 map PAUSED、505個已SEALED Scripts不改、Human Gate F **仍未通過**。
- 遠端實機 Windows `DESKTOP-90VT437`、Godot 4.7.2 stable OpenGL 3.3，AMD RX 6700 XT。
- 官方 LPC Universal Generator commit `9bf06be193b053db256b2536824af426de046aa2`，`CREDITS.csv` 經 key 查詢授權：`body/bodies/male/slash.png`、`head/heads/human/male/slash.png`、`hair/buzzcut/adult/slash.png`、`weapon/sword/arming/attack_slash/bg/slash_128.png`、`fg/slash_128.png` 均含 OGA-BY 3.0；各原作者必須署名。Body/Head 多位作者，Hair ElizaWy，Arming Sword ElizaWy（walk/down JaidynReiman）。不得以「LPC免費」取代授權與 Attribution 稽核，PMD不在此授權下。
- 角色 body/head/hair 各 384×256、格 64×64×6×4；武器 behind/front 各768×512、格128×128×6×4。角色各幀以原生 pixel 插在武器影格 `(32,32)`，組合順序 behind → body → head → hair → front；無濾波與放大。

## T17D-1：24幀原生圖層+錯誤注入
- 24/24 body,head,hair,weapon 皆有非透明像素。
- 全表 alpha composite 和24個 cell逐格合成，**RGBA byte exact**。
- 可從大格還原原生64px含頭髮角色，**RGBA byte exact**。
- 5種負測：head +1px → 2233像素異常；左右方向髮型行互換 → 2138；遺漏hair → 4356；顛倒Weapon z → 655；64px角色嵌入x+1px → 12454。**5/5 檢出**。
- 人物 native 64px每幀最底部 y=61~62。轉入128 cell以 (32,32) 嵌入後最低可見點y=93~94。Sword pivot `(64,96)` 為保留2~3px下邊距的**候選**，不是已驗證VX hitbox或引擎足點。
- 人眼檢查 `outputs/T17D1_HUMAN_CONTACT_SHEET.png` 頭部與髮型有正常視覺，正式美術品質、握把是否貼合仍待 Human Acceptance。

## T17D-2：Godot RX6700XT 真實 GPU 逐幀渲染
- 新建與正式FS完全分離的 `godot/LPC128_24frame`，Godot4.7.2 OpenGL Compatible renderer，Sprite2D CanvasItem.TEXTURE_FILTER_NEAREST，AtlasTexture 每次 region=128×128，sprite畫在160×160 viewport 位置(16,16)。
- 真GPU畫面`captures/T17D2_direction_frame.png` 共24張，24個不同SHA（全部獨立），每張都與原生 PNG 來源 Alpha-over-Godot viewport bg **RGB逐像素完全一致**，**Max channel error=0、Total mismatched RGB pixels=0**。
- 128×128合法繪製區域外每張RGB **0異常像素**。其余 Godot GL 背景在 viewport內正常保留。
- `T17D2_NATIVE_GODOT_GPU_24_CAPTURE_PASS`。僅能證明 GPU渲染、方向/影格切換與原始RGBA視覺一致。尚未驗收播放間隔、SBS hit frame、武器聲音/動態命中。

## 確定性回歸與封版防線
- Windows 已實跑 `RUN_T17D.cmd`：`T17D1_build` / `T17D2_prepare` / `T17D2_import` / `T17D2_real_gpu` / `T17D2_audit`，**5/5 exit=0，完整6秒重跑**。
- 前後確定性確認 FS N5 `clone_project/N5_RUNTIME_CLONE/Data/Scripts.rvdata` SHA256 `3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9` 不變，正式Scripts sealed。
- `T17D_INCREMENTAL_REGRESSION.json`、`T17D1_MODULAR_CHAR_WEAPON_RESULT.json`、`T17D2_GODOT_GPU_RENDER_AUDIT.json` 與GPU日誌全入包。
- 完整遠端ZIP：`E:\GameAssetToolLab_20261023\deliveries\FS_LPC_FULLCHAR_WEAPON_GODOT_T17D_20261024.zip`，**61 files, 264584 bytes, SHA256 `252af87f01cd0d63ecbf57366cb439826146f5e917aa4e9d760a1f0e7dcc4de4`**，ZIP CRC/每檔SHA PASS。不可假稱已上傳Drive完整ZIP。
- **SBS將來階段**：另讀 Tankentai SBS v0.6 sealed authority、確認actor+weapon連號動畫和 hit callback，不得以本次 Godot 渲染PASS推定 VX/SBS正式整合PASS，也不能改動sealed D32A3a或v0.5/v0.6。

保持地圖Human Gate F不變。下一輪定位為**T17D-3 SBS Authority Compatibility Research**（只讀）或 T18 正式二進位中未封版的獨立測試接口，待來源確認後才執行。
