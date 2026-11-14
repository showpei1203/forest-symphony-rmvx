# A38｜Godot-first Actor01 IDLE / WAITING + RUN 共用狀態控制器

日期：2026-11-14。**執行判定：PixelLab 真實模型 R1/R2 PASS（格式與端點）／自然待機美術未通過 ART HOLD／Godot GPU runtime PASS／FS 全遊戲戰鬥整合 NOT_RUN／FS E: 和 GitHub main 未動。**

## 1. 任務策略
使用者已明確指定從 RMVX 向 Godot 長期轉型，**不再受 3 幀戰鬥動畫限制**，以自然、連貫、可量產的動畫元件為主。A37 已有 64px × 8 幀 RUN 的原生 Godot actor；A38 以相同規格新增 IDLE/WAITING，將 actor runtime 升級為多 motion、多 sprite sheet、多 profile、明確拒絕尚不存在的狀態。

## 2. 真正執行的兩次 PixelLab IDLE 生成
- 使用者授權 Windows `DESKTOP-90VT437`，已登入 Chrome PixelLab Creator `https://www.pixellab.ai/create?tool=interpolate`，模型 **Interpolate V3**，Frame count **4**，每筆 UI 顯示 **1 generation**，**共實際消耗 2 次訂閱內 generation**，沒有額外信用卡 Credits。
- **R1 第一筆：** First frame = A62 approved RUN1 48px 不縮放放入 64×64 alpha 畫布（來源原始 SHA `6b25abb1dd702701716844a2ad36dfb8bfb8e3eccaf87fe7b15b2b85a41d101d`、64px SHA `d43b6f816c57d32de2e222cf5d5f3895f7a794008abc6a1be819e6ae7374b6b5`），Last = A23 mechanical inhale (64px SHA `8dc2bd9eb3b826ac27f546e53da598698015294592bb232b2694bade35b0deec`)。UI Gallery **100→101**，真實原始 GIF **64×64 5 幀／3717 bytes／SHA `95e76d457f940364af7f5678249a5ea39faae2480309ffa5f1b62e36a56ce87d`**，原始 PNG **192×128／5821 bytes／SHA `c38c6cfd6f1690c73136c67cf4e106b3f75a427fecacdc06332cf4611dd37022`**。
- **R2 第二筆控制對照：** 用 R1 相對穩定的 G3 當新的 Last，首幀保持 exact A62 approved PNG，提示詞嚴禁 stepping/waving；UI Gallery **101→102**。真實原始 GIF **64×64 5 幀／3733 bytes／SHA `15dcc32fd27d0a2defd958ccd64e009804fe32e81addd3938d921d79af5bfe30`**；原始 PNG **192×128／5996 bytes／SHA `18642325ee867b481ef9d450219aab4a21c545bcb3b43d2fabb09dd73f054be5`**。
- 兩組 provider PNG 均經機器原始像素檢查：**第一格與 A62 完全一致 0 RGBA 像素差；5/5 互異；Alpha 只有 0/255**；R1 尾端與 A23 inhale 差16 RGBA像素；R2 尾端與所提供 R1 G3 差17。**模型回傳總共 5 幀（包含原始第一幀）**。
- 真正 loop 用吸氣的順序 **`[0,1,2,3,4,3,2,1]`** 回放吐氣，這對對稱的呼吸相位合理，但仍是**8 個播放相位／5 個模型來源不同姿勢**，不是八張獨立 AI 新畫格。此計數規範要寫入量產工法。

## 3. 反直覺美術失敗：限制端點也擋不住全身漂移
- **R1 ART FAIL**：頭部 ROI 相對來源 G0~G4 改變 `[0,309,327,54,234]` pixels；G1/G2 的手臂擺動與頭轉過大，不是寧靜呼吸。這是 pixel art 的真美術缺陷，不能拿「5 格都有變化」掩蓋。
- **R2 ART FAIL**：雖把兩個端點縮短為近似姿勢，模型中段 ROI 仍變 `[0,243,329,281,56]` pixels，還出現不符合 IDLE 的踏步與方向偏移。**受兩端控制仍不能保證中段合格**，因此停止繼續浪費 generation。
- **Curated IDLE（ART HOLD）**：從 R1 原始 `G0/G3/G4` 完整無損裁格，選成 `[0,0,3,3,4,4,3,0]` 的 4×2 sheet、8 個播放槽，真正只有 **3 種不同原始 RGBA 姿勢**。無 PixelLab 新生成、無程序轉骨架、無反鋸齒、無隱藏補畫；緩解擺手但尚未美術封版。其 SHA256 `25859b73282ea2f928b7fbca7ed60a3e46e5996a75f979525e5b6b51ff6eae31`。R1 原版8-phase SHA `ba8d0db8bc78017ecb465788665325a058d613e92044024e33a68ded19293502`，R2 SHA `b986b4b8aa7a0d20c5812fc8fe14d3c5cb551523c6b0d01002bf4c4db6a1f4e2`。
- 可視對照：[R1 八相位真圖](https://drive.google.com/file/d/1CDyaewvF6JaEFDwjQbHZTataO4Q_4V9s/view)、[R2 八相位真圖](https://drive.google.com/file/d/1kgYFVJb1HIZT_SZqCHqmJcy_2ObvP7KQ/view)。

## 4. Godot-first 完整可重跑的 RUN／IDLE 工程
- 私人原始 [**A38 Godot 完整專案資料夾**](https://drive.google.com/drive/folders/1pFzOQ3g8O-HFg6bDQQrdIRMfytF1k0Nb)，包括 `project.godot`、`scenes/actor01.tscn`、`scenes/battle_animation_preview.tscn`、`scripts/fs_actor_animator.gd`、`scripts/battle_animation_preview.gd`、`assets/actor01_animation_manifest.json`、四張 private art sheet、兩支 Godot QA 與實際 GPU 輸出。
- 可在 Godot 4.7.2 直接啟動雙角色展示場景，左側 unchanged A35 RUN、右側 IDLE；鍵盤 `1` R1 原版、`2` 平靜篩選、`3` R2、`4` RUN 8fps、`5` RUN 10fps、空白鍵暫停、`+/-` 播放倍率。
- `FSBattleActorAnimator` 由 JSON profile 建構 **5 種 SpriteFrames 動畫設定** `run_raw` (8fps), `run_tuned` (10fps), `idle_raw` (5fps), `idle_r2` (5fps), `idle_calm` (4fps＋每格權重)，支援多 sheet、任意幀數、動作切換與事件；**attack/cast/hurt/death** 尚不存在、明確回報 unsupported，不以 RUN 代替。
- 保留 A35 RUN 8幀原始 RGBA sheet **256×128 bytes byte-identical，SHA `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`**；不做 32px 縮小或拆回 VX 三幀。

## 5. 本輪真正 Godot 4.7.2 GPU 驗證
- 使用授權桌機 **AMD RX 6700 XT / OpenGL 3.3 Compatibility**。Godot `--headless --editor --import --quit`：**EXIT=0**，四張 sprite sheet 均成功 import，GDScript 類別登記 PASS。
- 真正 Godot `qa/qa_animation_runtime.gd`：**EXIT=0**，5 profiles 存在，IDLE `AnimatedSprite2D.frame_changed` 實際捕獲 **21 次影格切換、2 次回0 wrap**；RUN/IDLE 各 profile 切換 PASS，未實作 ATTACK 拒絕 PASS，真 GPU 雙角色截圖已儲存：[A38 Godot RUN／IDLE 實機畫面](https://drive.google.com/file/d/1xWvSDV_Ulqi7xSljP7cpaxEX9cwFYhBD/view)。
- 真正 GPU `qa/qa_idle_gpu_capture.gd`：**EXIT=0**，R1、R2、curated 三套各截取 **8 張**實際 framebuffer 並輸出 contact；可見 [低幅度版真 GPU 八相位截圖](https://drive.google.com/file/d/1C70ZDOqI6AxzWo08UXwBSouUZqVD8_Rl/view)。
- **GPU hash 重要限制**：curated 原始 atlas 僅3種 RGBA，不可用 framebuffer 圖像的7個不同 hash 誤導成7個新原始動作畫格；GPU capture 可能受 frame 時序影響。**原始 PNG RGBA/sha/hash 及 Godot 播放事件為獨立權威**。
- 此為**隔離 Godot 演示工程**，不是既有 FS Godot 全遊戲戰鬥狀態、技能裝備物品的整合測試；正式 FS migration integration **NOT_RUN**。所有圖與程式未改使用者 E: 工程、Github main。

## 6. 私人交付／可復現證據
- [A38 PixelLab 原始 R1+R2、源圖、QA ZIP](https://drive.google.com/file/d/1McKi05SAtZdvGoWOzo0oMFRY0u1i-WPt/view)：**27 檔、92,232 bytes，SHA256 `8c99b1dd133716b83f1b78730db53feddb03309870e10ddc25a5c12acdc20d87`**。
- [A38 Godot 原生專案／GPU／QA ZIP](https://drive.google.com/file/d/1kwgx8EcGhcqOAIgKkbV9kcAhfilmJt9N/view)：**30 檔、104,698 bytes，SHA256 `1bb7abd0b9526f9fb56e6ca2f6e6d4d3aa689f9f407cdf62ac176dd780f4d3cb`**。
- **兩個 ZIP 皆已從 Google Drive 下載回讀**，其 bytes／SHA256 與上傳前完全一致、ZIP `testzip()=None`、metadata `shared=false`。Windows E:\Downloads 原生 PixelLab 輸出已搬入 owner-only Drive；Windows TEMP 上傳原圖已刪，Godot 僅寫 G: Drive。
- GitHub [**A38 Godot 程式碼／manifest／QA 原始碼**](../../tools/asset_factory/godot_a38/README.md) 與 [**A38 PixelLab 可重做 source preparation／image QA／curation**](../../tools/asset_factory/a38_pixellab_idle/a38_prepare.py) 均在隔離分支 `feat/fs-asset-factory-v1-20261107`；不提交私有 Sprite binary 及 source artwork 至公開 GitHub。

## 7. 下一步 A39，避免繞回舊錯誤
現在**動畫運行架構已通過，IDLE 美術仍未通過**。A39 不應再單用 `Interpolate` 輸入兩張全身圖要求它「自然呼吸」：R1/R2 的完整證據證明模型沒有遵守固定肢體指令。優先驗證 Godot 腰部以上的 **local pose / joints / AnimationPlayer / Skeleton2D 輕量呼吸變形**、固定腳掌和頭部，必要時使用 PixelLab 提供明確 skeleton key poses，再實際 GPU 播放美術驗收。等 IDLE 定版後擴展 Attack / Cast / Hurt / Death，並另行將可靠元件接入 FS Godot 主戰鬥工程。

**A38 SEAL: PROVIDER ACTUAL R1+R2 PASS / ENDPOINT FORMAT PASS / IDLE ART HOLD / GODOT SOURCE/IMPORT/GPU/RUNTIME PASS / REAL GAME INTEGRATION NOT_RUN / E: ORIGINAL + MAIN UNCHANGED.**
