# A39｜Godot 原生局部胸甲／肩甲呼吸動畫，RUN／IDLE 狀態合併（2026-11-14）

**本階段已實際施工並封包。Engine/GPU QA PASS，IDLE art HOLD，正式 Forest Symphony Godot 全遊戲戰鬥整合 NOT_RUN。GitHub main、E: VX 原工程、A35/A62 原始素材均未改動。**

## 採用不同於 A38 的原生 Godot 路線
- A38 PixelLab IDLE R1/R2 中間幀有大幅轉頭、擺手。A39 **沒有再使用 PixelLab**，沒有購買或消耗任何新 generation，沒有讓 AI 重新繪製白髮綠甲角色。
- 直接擷取 **A62 approved 完全相同**的 64×64 RGBA F0。SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`，GPU 零相位與原來源 **RGBA 0 pixel diff**。
- 新增 Godot `CanvasItem` shader `shaders/chest_breath.gdshader`、`FSActorBreathRig` 類別、`AnimationPlayer` 真正 value track 控制 `material:shader_parameter/breath_phase`。局部 Shader 直接採樣核准原圖色票，**只改 native pixel 的胸甲 x32–39/y36–41，以及左肩 x25–30/y34–36、右肩 x39–42/y34–36**。只有原圖與採樣目標都不透明才換色，遮罩以外、透明輪廓、頭髮臉部 y≤33、鞋／腿 y≥43 原樣不動。
- 吸氣／吐氣有 8 個約 0.4秒播放相位，**3.2秒 loop**，實際 GPU 只有 **4 種不同像素姿勢**（非 8 張 AI 新生成圖）；這是刻意溫和的「局部呼吸」，不是攻擊也不是整體上下彈跳。
- 真實反向時段回到來源原像素，而非使用 A38 的臉部漂移畫格。美術仍 ART HOLD，沒有承諾一定比大型骨架動作自然。

## A38 正式 Godot runtime 無破壞性升級
- 以 A38 owner-only 可執行專案為基準，新 A39 owner-only `FS_A39_GODOT_CONTROLLED_BREATH_RIG_20261114` 完全隔離；現有 5 個 profile **`run_raw/run_tuned/idle_raw/idle_r2/idle_calm` 全部保留**，新增由 `AnimationPlayer` 驅動的 `idle_rig`。
- `FSBattleActorAnimator.play_motion` 現在可在 RUN atlas、AI atlas IDLE、**Shader+AnimationPlayer 原生 IDLE** 間切換並保持 signal/API；暫停、速度倍率也支援新的 rig。不存在的 Attack/Cast/Hurt/Death 仍拒絕，**沒有偽裝 placeholder**。
- A35 真實 RUN 8格 256×128 RGBA **原件 byte-identical SHA `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`**。不用改回 VX 三幀，不壓縮 48px 角色本體。
- 新展示場景 `scenes/battle_animation_preview.tscn` 預設左 RUN 右原生 rig IDLE；按鍵 `1` R1、`2` Calm、`3` R2、`4` RUN 8fps、`5` RUN 10fps、`6` 局部 rig，`Space` 暫停，`+/-` 播放速度；已修正兩名演示人物站位 **y383→y416**，腳掌與地線對齊，原始來源未動。
- 另有 `scenes/a39_rig_preview.tscn` 同畫面比較 approved static／A38 calm／A39 rig。

## 真正桌機 Godot GPU 數據與可複核
- 授權桌機 `DESKTOP-90VT437`、**Godot 4.7.2.stable.official**、**AMD RX6700XT OpenGL 3.3 Compatibility**。
- Godot `--headless --editor --import --quit` **EXIT=0**（不代表使用 headless renderer 做 GPU QA）。隨後 `qa/a39_rig_gpu_qa.gd` 用真正有 GPU 的 64×64 transparent `SubViewport` 截取 8 相位 `A39_GPU_BREATH_F00..F07.png`：**EXIT=0，RGBA每格對 F0 變化 `[0,14,45,37,37,45,14,0]`、遮罩外改變 `[0,0,0,0,0,0,0,0]`、Alpha改變 `[0,0,0,0,0,0,0,0]`、4 種不同 GPU 姿勢**。第一幀 GPU vs approved 原圖 0 像素差。Godot AnimationPlayer 動作測得有實際推進（約 0.4–0.48 呼吸參數，而非動畫凍結）。
- `qa/a39_integrated_runtime_qa.gd` 用真正 Godot GPU **EXIT=0**，證明 5 舊 profile 不消失、`RUN→AI IDLE→rig IDLE→RUN` 可互切、`AnimationPlayer` 可以調速、缺少的 ATTACK 拒絕；GPU 真正截圖 [A39 RUN+rig IDLE 雙角色對照](https://drive.google.com/file/d/1pDtzHPnR1UP0gF5LbARLmt120PQI4sCf/view)。
- 真的由 Godot GPU 原生輸出八張截圖，非拿 Python 合成圖冒充引擎。可看 [GPU 8相位 7x放大圖](https://drive.google.com/file/d/1EfLERc7Kod68htjqpl7EY0oxz7rk03BF/view)、[GPU 8相位真正來源製成的循環 GIF](https://drive.google.com/file/d/1m18LSs3rXD4taqzYPnBar-wMDpZVaNPv/view)。
- **獨立全新解壓驗收**：把最終 ZIP 解壓到另一個 G: 私有雲端路徑，Godot 重新 import EXIT0、上述兩個 real GPU GDScript QA 皆 EXIT0，再刪除新建的冷測資料夾；沒有借用原專案快取。QA logs、cold report 與 failure log 在交付中。
- **Failure Log**：製作期間有兩個工程 bug（QA 檢視腳本根路徑寫成 `qa/qa`、整合 patch 的 Godot 專案標題常數不符）均已依實際訊息修正及重跑，另有展示人物腳底浮空位置已調整；詳見 [GitHub QA Failure Log](../../tools/asset_factory/godot_a39/qa/A39_FAILURE_LOG.md)，沒有把初次失敗冒稱測試 PASS。

## 真實封包、版本鎖與隱私
- 私人 [Google Drive **A39 完整 Godot 工程資料夾**](https://drive.google.com/drive/folders/1v3nnRvG3KUq8A1TRg-l2HA8u_k-dLtNT)，所有原始素材、Shader、AnimationPlayer、場景、8張 GPU frame、GIF、PNG contact、QA log 與失敗紀錄均在內。
- **[owner-only A39 最終完整 Godot ZIP](https://drive.google.com/file/d/1uMvDEPMltAqjYaJOwysQL1sOXviF1jJ5/view)**：42檔／**111,138 bytes**／**SHA256 `366e6c0ce8a0b6be4a31a628c7e9fd4baff9d311f273c7fdd33a013e325f1ae7`**，Drive回讀 SHA、ZIP CRC testzip=None 通過，metadata shared=false。
- [**GitHub A39 代碼與可重跑測試**](../../tools/asset_factory/godot_a39/README.md)，仍在隔離 branch `feat/fs-asset-factory-v1-20261107`，沒有上傳 private art 到 public GitHub、沒有改 `main` 或另外一個地圖分支。
- **完整輸出與程式都在 G: 掛載私人 Drive / GitHub；Windows E: FS 工程未被改寫。**

## 必須誠實保留的 Gate
| Gate | 結果 |
|---|---|
| Approved source 64px / Palette / Alpha / Head & feet lock | PASS |
| Godot 4.7 真實 AnimationPlayer 局部呼吸及 8 phase GPU | PASS |
| A38→A39 RUN/IDLE 多狀態整合且保留原 RUN 8frame | PASS |
| 最終 ZIP 自己重下驗 SHA CRC / 全新解壓 GPU 冷測 | PASS |
| IDLE 美術自然度與正式授權角色核准 | **ART HOLD：動作雖精細但目前仍稍微像胸甲像素移動** |
| FS 真正移植後的 ATB/Battle/Skills 系統整合 | **NOT_RUN** |

**A40 接續方向**：以同一固定視角與像素角色，開始真正 Attack 起手→接觸→收招的多 keyframe 動作，允許多於3幀；改用 approved silhouette/keyframe 控制，連動 Godot `AnimationPlayer` timing 和事件命中點，而非再花 PixelLab 額度自由生成整個角色。若要將 A39 rig 併入 FS Godot 主工程，必須另在 Godot migration branch 處理正式 battle runtime integration 並保留對照 QA。
