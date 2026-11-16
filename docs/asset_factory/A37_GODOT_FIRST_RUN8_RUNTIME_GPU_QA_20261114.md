# A37｜Godot-first Actor01 八幀 RUN 動畫元件與真 GPU 循環驗證
日期：2026-11-14。**此任務接收使用者新規則：FS 日後轉到 Godot，動畫不必限制 VX 3 幀，動作完整與流暢優先。**

## 實際交付與權威位置
- [A37 可直接由 Godot 4.7.2 開啟的完整私人專案](https://drive.google.com/drive/folders/1AMm022mnoZ7Mg6TvJ1WjCBuPPCJBXFTt)（含 `project.godot`、`scenes/actor01.tscn`、`scenes/battle_run_preview.tscn`、`FSBattleActorAnimator`、SpriteFrames、manifest、source sheet、QA scripts、GPU 截圖）。
- [A37 私有可重跑 ZIP 26 檔](https://drive.google.com/file/d/15NGwKU1pL-VGCoSt-z7W0M1A9Evc_Rcx/view)，**147,870 bytes，SHA256 `e75e07dc4e29e7a6888d44100448dd7f1cb97624f86e2f976f31301396715f92`，Drive 下載回讀 SHA256/ZIP CRC PASS，shared=false**。
- [Godot GPU 實際八幀畫面](https://drive.google.com/file/d/1NSaNk-z6Qa1gc1Y6P-G4waxcwMDs0Sif/view)、[Godot GPU 戰鬥場景截圖](https://drive.google.com/file/d/1PuI2PyyecTcqjchQ7-5AR8grgKyKdznF/view)、[Godot GPU 八幀節奏版 GIF](https://drive.google.com/file/d/1G2hTE7rwzfEXpJFtr_ahB8CYT_x9DpBy/view)、[原速 8fps GIF](https://drive.google.com/file/d/1E6zlfBZ3pDU_3-iQNvP9eCAntnyJI-Fi/view)。
- 對應的 **GitHub 文字程式碼而非私人美術二進位** 位於 [`tools/asset_factory/godot_a37/`](../../tools/asset_factory/godot_a37/README.md)，當中有完整 GDScript、Godot scenes、import manifest、測試與 QA / failure log；本分支 `feat/fs-asset-factory-v1-20261107`，不動 `main`。

## A35 來源與 Godot-first art policy
- 真實模型素材來自 A35 owner-only 的 `A35_APPROVED_KEYFRAME_FULL_8FRAME_RUN_SHEET.png`：**256×128、4×2、8 個 64×64 RGBA 格子**，本體約 48px；其中索引 0 與 4 為 approved A62 keyframes、其他 6 格為真 PixelLab V3 雙向插幀。
- A37 保留**完全相同的來源 PNG bytes**：SHA256 `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`；不縮小、不改色、不修畫格。8 格可見色數 `[33,39,36,48,34,40,40,42]`，透明 Alpha 僅 0/255。
- **不再強制三幀，也不把新 48px 戰鬥角色壓成舊 VX 32px 圖集**。Godot 可直接讀取 64px canvas、nearest-neighbor、帧数自由擴充。
- 只提供真正存在的 `run_raw` 和 `run_tuned`；`idle/attack/cast/hurt/death` 未產出，不做假動畫替代。用 `play_motion` API 回報 unsupported。

## 動畫架構實際完成
- `scenes/actor01.tscn` 為獨立可重用 battle actor；`scripts/fs_actor_animator.gd` 依 JSON manifest，自動用 `AtlasTexture` + `SpriteFrames` 建立完整 **8-frame AnimatedSprite2D**，包含不可用動作拒絕、播放速度與狀態事件。
- `scenes/battle_run_preview.tscn` 與 `scripts/battle_run_preview.gd` 為可啟動的戰鬥展示場景，鍵盤 `1` 原速、`2` 節奏版、`Space` 暫停、`+/-` 調整速度。
- `run_raw`：**8fps / 每幀125ms / 1,000ms loop**。
- `run_tuned`：**10fps**，每幀權重 `[0.9,1,1,1,0.9,1,0.7,0.8]`（實際毫秒 `[90,100,100,100,90,100,70,80]`），**730ms loop**。F6/F7 停留縮短以免變形畫格佔據太久；**只是播放節奏補救，不是美術修復**。

## 真正遠端 Godot GPU QA
- 使用者正式授權桌機 `DESKTOP-90VT437`、Godot `4.7.2.stable.official.ed1daf0bf`、AMD RX6700XT、OpenGL 3.3 Compatibility。
- `--headless --editor --import --quit` **EXIT=0**：原生 PNG 匯入、場景與腳本類別登記完成。
- 使用 GPU（非 Godot headless dummy renderer）啟動 `qa/qa_run_animation.gd` **EXIT=0**。真實 `AnimatedSprite2D.frame_changed` 捕捉到 **27 次影格切換、至少2次完整循環回0、序列逐次按1→2→3→4→5→6→7→0**；`run_raw` / `run_tuned` 互切 PASS；未提供的 `attack`、`idle` 明確拒絕 PASS；GPU 戰鬥場景截圖確實存入私人 G:。
- 第二個真 GPU `qa/qa_capture_all_8_gpu.gd` **EXIT=0**：把同個 battle scene 的 8 個不同 AnimatedSprite2D frame 逐一上 GPU 播放/截圖，輸出**8張320×320真 GPU frame PNG**與一張 4×2 接觸圖；畫面內容 hash **8/8 各異**，不是用 PIL 把 Sprite Sheet 直接裁切冒充引擎截圖。
- 以這 8 張**GPU 原始截圖**製作 8fps 與 10fps 節奏預覽 GIF，再用 `qa/a37_finalize.py` 確認來源 SHA、8/8 frame 異、Alpha 和 ZIP CRC。
- 修正實際遇到的兩個 QA 開發錯誤：Godot 4.7 `PackedByteArray.md5_text/md5_buffer` API 不存在，最後改採 `hash(PackedByteArray)` 和 8-frame uniqueness 驗證；封裝腳本最初從 `qa/` 誤判根目錄，改成 `Path(__file__).resolve().parent.parent`；成功結果與修訂版來源已保存。

## 美術與其他 Gate
| Gate | 實際判定 |
|---|---|
| 8格來源校驗、無縮放、透明像素 | PASS |
| Godot editor 匯入 | PASS |
| AnimatedSprite2D 真正連續循環 | PASS |
| 同一角色兩種節奏與 runtime 切換 | PASS |
| Godot GPU 八格畫面／私有原始證據 | PASS |
| 角色 RUN 自然度（F6/F7） | **ART HOLD** |
| 正式 FS Godot battle migration 整合 | **NOT RUN** |
| VX 原生 Battle 實機 | **NOT RUN、不再當成主要方向** |

F6 跨步偏大與 F7 手套/手部的像素瑕疵仍存於原圖；`run_tuned` 只縮短其曝光，不能當成修補過關。也尚未真的整合進 FS Godot 正式戰鬥與物品技能狀態系統，因此此專案是**可獨立啟動的 Godot-ready prototype**，不冒稱 FS 本體已移植。

## A38 接續
- 用完全相同的 `FSBattleActorAnimator`、manifest、64px grid 與 48px 角色保持一致性，建立真正 **6–8 幀 `idle / waiting` loop**。候選來源先參照 private A23 breath pilot，但 A23 僅 mechanical 2-phase/ART HOLD，不能冒充本輪有新 PixelLab IDLE 動作。
- 待 RUN 與 IDLE 同一套美術通過，再導入 Attack、Cast、Hurt、Death；可變幀數與事件 timing 依 Godot runtime 定義。
- 逐動作 QAs、Failure Log、Drive private ZIP、GitHub Handoff，不重做 A32–A36 的登入、骨架與 3幀 VX 格式。

**A37 Seal：真实 Godot Engine PASS／8Frame Runtime PASS／Art HOLD／Migration integration NOT_RUN／A35 artwork unchanged／GitHub main + FS user PC original untouched。**
