# Forest Symphony｜P537D 真原圖雙角色戰鬥 GPU 視覺 Handoff
日期：2026-11-21（Asia/Taipei）。Godot 4.7.2 only。**SOURCE + GPU PIXEL VISIBILITY PASS；ART HOLD，Phase1 SEAL NO。**

## 1. 真正完成的施工
- 從 GitHub 固定代碼 1e0e3c6284417b2ede3a1ac1bb2cb441dd9790ab 取 Godot 工程，工作工程及所有輸出僅寫入授權 PC 上的 G: Google Drive 雲端硬碟 FS_PRIVATE_P537D_GODOT_NATIVE_QA_20261121。E: 原始 VX 專案唯讀，不使用 PC C: 保存施工成果。
- 使用已有的官方 Godot 4.7.2.stable.official.ed1daf0bf executable。私有 source SHA/CRC staging 導入真正原版 UI 202 PNG + Battlers 167 PNG + A52 Body、Weapon、FX 3 PNG，共 372 張 PNG；Godot Editor Import **372 steps, exit 0**。
- 真正以 AMD Radeon RX 6700 XT（OpenGL 3.3 Core Profile Context / Compatibility, driver 26.11.2.261112）執行 Godot 原生 Win64 viewport GPU rendering。544×416、1088×832 分別擷取 original_enemy、atb_ready、a52_f7_contact 共 **6 張真正私有原圖 GPU PNG**。
- 第一次拿到 6/6 PNG 時，人工實際看圖發現 **R0 重大 false-positive：右側原 Battler/Actor01 全部在畫面外**！因為 FSScreen 直接作 Window 子 Control 但 size=0。取得截圖不代表來源圖可見。第二輪 R1 加 PRESET_FULL_RECT 後人物出現，仍有開發除錯文字壓到原版敵人標籤；R2 移除重複開發提示、隱藏長 debug 狀態（HP/MP/ATB 真 source HUD 仍在）、將 enemy stage y=91→60，讓 original stage 和 2×2 ACT 54×48 原版按鍵都在 544 畫面完整顯示。
- 正式 tests/capture_fs_p537c_private.gd 補上嚴格 **真 GPU 像素變化判定**，不接受「PNG 存在」「node visible」「原始 Texture load 成功」等弱證據。隱藏 enemy 原圖／重新顯示後實際 ROI 像素差，以及 Actor01 ATB ready vs source F7 actual Body/Weapon/FX 組成畫面的差異，加上四 ACT 指令必須在真正 viewport 內。
  - **544×416：enemy source 2506 changed pixels；A52 F7 618 changed pixels**
  - **1088×832：enemy source 10050 changed pixels；A52 F7 2472 changed pixels**
  - 兩解析度嚴格 pixel gate 和 native screenshot **6/6 PASS**，不是合成 placeholder。
- 來源角色白髮 ACTOR01 A52 3 分層來源 SHA、64×64 12 幀 F7 0.630sec 源視覺接觸保留，仍由真正 FSBattle FSActionQueue 排程後才觸發，不因視覺 F7 隨意改傷害；敵人本輪 Source PNG name $001 取自合法 167 original Battlers manifest，來源 enemy ID 指向 $001 由**明示合成 DB fixture** 指定，沒有假稱已完成原作完整 postApply DB。

## 2. 真實來源／私人 QA 封存
- Original UI source owner-only 202 PNG Drive：https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view，ZIP SHA256 c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6。
- Original Battlers source owner-only 167 PNG：https://drive.google.com/file/d/1xd1ZIxLt-xPQ4NKqx3MoRpysdHYBJ1So/view，ZIP SHA256 4d2f629ea643187d2b96999798214c1fdf75a1ec969df1c29561bf7bfa1ee9e3。
- A52 Body/Weapon/FX 原圖各 256×192、12×64×64，SHA256：
  Body a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f
  Weapon 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b
  FX 46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c。
- **正式 owner-only GPU ZIP**：https://drive.google.com/file/d/1vS5pbWqWcyU7ZlXETv2C-SXAMfTcMsFT/view
  - Google Drive id 1vS5pbWqWcyU7ZlXETv2C-SXAMfTcMsFT，**514,477 bytes，SHA256 b6f47468fbca6185f558196f2c0216ce765b02233a132c82ca534c49e4fb374e**。Google Drive readback shared=false，只有 owner。ZIP CRC PASS。
  - 12 entries：FINAL_GPU 6 PNG、LOGS Editor Import + 544/1088 GPU pixel logs 共 3、FAILURE_BEFORE R0 / R1 原始失敗截圖共 2、逐檔 SHA256_PROVENANCE_MANIFEST.json 1。
  - 544 final F7 image：https://drive.google.com/file/d/1Se_6CuT8p7-9YDIL1emO-L_OQRdUpn5Q/view
  - 1088 final F7 image：https://drive.google.com/file/d/1nQc9NkJ89CxVT072m6iqAvWD7aVK5rAH/view
  - 私有 staging 工作目錄（G: cloud）：https://drive.google.com/drive/folders/1RPGfye30_ow-3uhphqpj-FAuCxMTrTAi（shared=false）。

## 3. 真正提交到 GitHub 的程式
- Code access + Windows G: cloud-only private output gate: commit d208a9bda59747e6689fe4a799f69fd9693f9e1a。
- Corrected source canvas / original sprite display + physical GPU pixel proof: commit dc51665928d0c3a84de31cc8c3b6f227a74abe1b。
- scripts/FSScreen.gd：根 Control.PRESET_FULL_RECT、battle true HUD + 2×2 commands、debug 狀態不遮戰鬥舞台（仍保留 source state text）、MENU 恢復正常文字。
- scripts/ui/FSBattleOriginalEnemyStage.gd：敵人真 source images / names 內嵌界限，位置上移並保留死亡隱藏。
- tests/capture_fs_p537c_private.gd：owner-only G: Drive 或 Linux /tmp 守門 + original SHA source + physical pixels ROI 同步差分 + 544/1088 stage 和 4 commands 界限判斷。
- tests/test_fs_battle_enemy_stage_537c.gd：public native viewport full-size/compact debug regression。原 P535/P536/P537 menus/ATB/ACT/可玩事件切片測試仍保留。
- 最終 full GitHub **Godot 4.7.2 CI #44872922592 SUCCESS 88／88 steps failed=0**：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872922592 。GitHub CI 是無私圖的合成/native regression，真來源 GPU 證據在 owner-only Google Drive，不能把 public synthetic test 冒充來源美術證據。

## 4. 明確未解 ART HOLD
- 真正 original BattleScape 背景、光照、battle stage 原版位置與遮擋仍待來源驗證；目前 source actor+enemy 在深色底可見，非完整場景美術。
- Enemy ID1 synthetic record 人工 source name $001，只驗證 167 original sprite source display，並非正式 Enemy.rvdata 原 11 post-Apply tables + 505 RGSS2 last-wins DB；原 VX 和 Godot 相同戰鬥狀態 1:1 pixel parity 尚未比較。
- A52 視覺 0.630s 與真正 Tankentai ACT damage/time/70ms Hitstop 還沒有來源同步，絕不依動畫接觸改實際傷害；T-A RUN12 F6/F7 仍 ART HOLD。
- 正式打包 CJK font、BattleScape 天氣/武器/FX 原版深度、T-B 演化線都未因這次 Stage QA 自動封版。
- **結論：source-proven 角色/敵人 GPU visibility PASS，BATTLE 整體 ART HOLD，Phase1 SEAL NO。**

## 5. 下一個完整施工單位 P537E
優先讀取原始 VX 的 BattleScape/戰鬥背景 Ruby script 與真 PNG 來源，建立有原版 SHA/明確場景映射的 Godot BattleScape 分層，不准用隨機背景替代。其次擴張同源多敵人／來源正確的 Troop/Enemy DB snapshot QA、追正 A52 source ACT 接觸時間與 Hitstop；然後 P538 正式 MENU window skins 與六主角。A35 map ART HOLD 繼續排後；只 Godot 4.7.2，不回 VX，每輪 Handoff＋FailureLog＋私有 Drive GPU 證據。
