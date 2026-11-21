# Forest Symphony｜總監控台中央狀態
更新：**2026-11-21 19:07 Asia/Taipei**｜稽核版本：CONTROL_SYNC_20261121_1907
依據：`FS_CONTROL_TOWER_PROTOCOL.md`，使用者最新 Godot 4.7.2 + P0 Drive/GitHub Cloud-only + 宏觀施工優先指令。
**這是本次讀回的快照，不是背景即時監控。** 本總控只核對雲端寫入與工程證據，不替使用者簽署主觀 ART PASS。

## 一、三線真實進度與判定

| 線 | Linear | 本次 HEAD Commit | 與建立基準相比 | 真實交付物 | Godot 4.7.2 QA | 最終 Art Gate |
|---|---|---|---|---|---|---|
| T-C 地圖 | SHO-39 In Progress | `c053c1a9cfcc0687a3c89fe4e6c617f96d8c6016` | ahead 56 / behind 0 | C8 全村 1280×928 + 兩棟不同整體木屋、完整 Master／GroundOnly／CompletePAR／FullGround／OcclusionPAR 來源 + 17 occlusion owners；82,042,571 bytes Drive 私有 ZIP | CI 44874487911 completed/success；真實 1× Godot OpenGL3，7 點 collider 和右屋遮蔽 A/B（Handoff 報 204px ROI）PASS | **ART_HOLD**：整體與 ground3/par3 視覺比較未簽核；FS_01_VILLAGE/MAZE 未完成 |
| T-A 角色 | SHO-38 In Progress | `203a4561c108aba0f6b36424863abeebcc8faaff` | ahead 15 / behind 0 | ACTOR01 R7 三層 12×64×64 攻擊圖集 + 改高位舉劍／表情 + R5B RUN 候選；195-file Drive ZIP + R6/R7 60fps 影片 | 私有原圖 Godot 4.7.2 Xvfb/Mesa llvmpipe 181／181 連續擷取，Handoff 記錄 PASS；正式 FSBattle ACT/ATB 全場景 NOT_RUN | **ART_HOLD**：1× 表情可讀性、整段攻擊動作美術及 RUN F6/F7 步態尚未核准 |
| T-B 怪物 | SHO-37 In Progress | `4c9f3fc3635c1adaaf1005be4a430084d2dd8bcc` | ahead 44 / behind 0 | PMD0001/2/3 三階來源、既有真 PixelLab Idle、R6 新 **Skeleton v3** 11×96×96 攻擊／384×288 atlas；Drive 私人 72-entry ZIP | Godot 4.7.2 真私人 PixelLab PNG imported，11/11 原生 Xvfb/Mesa llvmpipe 渲染及 timing exact-once HIT，7/7 objective QA，Handoff 記錄 PASS | **ART_HOLD**：F5 咬擊張口不夠可讀、F0/F10 identity redraw、45° 視角未簽核；F6 兩個游離 pixel 非阻斷 |

- 真正新增的 PixelLab provider job：**只有 T-B R6** `animate-with-skeleton-v3`，job `3fea688e-1c8c-451c-aa3f-84941166dca2`，generation `67dd6734-d3a5-4dc7-a860-ebb797f20964`，實際 **3.0 subscription generations**；無 USD 價格。T-C C8 用舊獲批可追溯 R5 單屋源但**不是**新增 PixelLab API generation；T-A R7 是從既有 A52 來源做程序化重新動作，**不是**新增 PixelLab v3 generation。
- 這三條均為 **ACTIVE + ART_HOLD**，不是 VERIFIED_PASS／Done。技術測試通過不等於最終原生使用者硬體測試，也不等於藝術驗收。
- 三線均比新分支建立時有真實程式／素材或雲端證據；並無誤改 main/T-A/T-B 他線的比對檔案之證據。沒有進行全庫 git diff 的二進位權利驗證，不能宣稱全專案安全蓋章。

## 二、Drive Readback（總控已實際驗證 metadata）

| 交付 | Drive File ID | provider 存在/大小 | 分享權限 | Handoff 宣稱的封裝完整性 |
|---|---|---|---|---|
| T-C C8 ZIP | `1xYFx6Mmx4PeSP4zMLdiYm1ZeF0J4bVbn` | 82,042,571 bytes | shared=false | reported 49 entries, 2-layer CRC PASS, SHA256 `3acee1e1a233b68348557231946d299f36cf131973337ab0dc30718c59569a9e` |
| T-A R7 ZIP | `1RLpMnw_RwgCq3pBNbaI9CvUN8fPV82hn` | 654,378 bytes | shared=false | reported 195 files, CRC PASS, SHA256 `ea689fe622e03cb8092f43596e67a9082c3b4d82d41112fd13ef6f4f6d462569` |
| T-B R6 ZIP | `1LhXel6vpyKAGxVb0BMTIdIKoPIueBGxy` | 496,820 bytes | shared=false | reported 72 entries, CRC PASS, SHA256 `7e944f9f6b313ab8e6797849f3c2276ed5375c62abc4618fe1f820f1eb207003` |

另外已回讀 Drive metadata：T-A R7 BODY `1CjCqaUJqowbHrCiG-A7IlyGbKgAsczbr`、WEAPON `1_g-NYxe2aJqzZMx5JAGh6pC5c9KF0TZo`、比較影片 `1MJfB_3d2sRLr9kN8te_aM86EOxg8iBkj`；T-B PixelLab 新圖集 `1ylrrncc6pPf58NpM9NSZhcWXvnTQ6XUl`、Godot 11F contact `1LD7eFRdglOx2JoU1TIAFOUWBWHbQ1dkS`、慢速 GIF `1ljDFksnS-cyVNWcNZ4CefGATrpb3QQth`，均存在且 shared=false。**本次僅 metadata 與 Handoff/文字/CI 查核，沒有重新下載每個 ZIP 逐位元重算 CRC/SHA，也沒有親自檢視私人圖像 1× 審美**；以上 CRC/SHA 數值為施工線自報的可追溯證據，不能冒稱本總控獨立位元組驗證。

## 三、阻斷、失敗策略、下一個宏觀施工單位

### T-C｜先完成 C9 村莊的正式視覺 Gate，再轉幽葉迴廊
- **阻斷**：現有 C8 雖已真正有不同木屋與原生遮蔽，仍未以原批准 `ground3/par3` 對照整張 FS 風格；MAZE 真 32px Ground 還未製作，舊 1478×1064 直接放大 2560×1856 不合美術標準。
- **下一完整單位 C9**：選出 `FS_01_VILLAGE` **1280×928 整張 1× 全村及兩棟不同屋對照**，與 approved ground3/par3 調性、透視、森林密度和 source-semantic occlusion 全面比較，集中替換整個失格物件家族或地景區段，交付新版全景／五圖／Godot A/B；得到人工 Art Gate 後，轉 `FS_01_MAZE` 80×58 真正的原生 32px 森林 Ground 區段。
- **防細節停滯**：非阻斷葉片與單個草點最多連修兩輪；若視覺不符，直接換一整套房屋/林群來源，不再做鏡像拚貼或局部葉尖修圖。

### T-A｜R7 動作全段藝術可讀性與完整戰鬥整合
- **阻斷**：R7 雖真正提高劍高度，源動作 1× 表情仍不清楚；R5B RUN 真左右腳流暢與接縫未人工通過；`FSBattle` 真 ACT/ATB 全場景 NOT_RUN。新 Text/Skeleton v3 job 0。
- **下一完整單位**：以 Godot 1× 完整 **RUN→蓄力→高位舉劍→F7 命中→收招**作為同一段表演對照，人工判定表情／全身／腿部語意；若未過，換成真正逐姿勢骨架/模組重繪的完整動作方法，不再只靠幾個頭部表情像素差異。合格後接入正式 FSBattle ACT 場景、驗證 hit timing，再做第二樣本。
- **防細節停滯**：不花一整輪處理單個嘴角或手部 alpha 小點；先修「攻擊仍不自然／RUN仍缺陷」之整體動作問題。

### T-B｜真正完成第一次 PixelLab V7 咬擊動畫
- **阻斷**：現有 R6 是**真實** Skeleton v3 完整11幀、原生可播，但 F5 咬合判讀錯、F0/F10 與來源 identity 不完全一致、戰鬥 45° 視覺待核；F6 游離兩像素屬 NONBLOCKER，不應優先。
- **下一完整單位**：保留 R6 的 11 幀身體／四肢，重新製作 **F4／F5／F6 三幀清楚張嘴上下顎姿勢**（獨立顎部遮罩或局部 inpaint），連續播放完整 11 幀，跑 Godot 4.7.2 native、真 1× ART Gate；通過後才進第二不同怪物家族樣本。
- **防細節停滯**：不得重複 2 輪以上相同全身 warp；F6 兩像素小島排在後面，不得比「真咬擊」先處理。

## 四、其他專案風險／必查
- **Handoff 與分支隔離**：三個 CURRENT_HANDOFF 都存在於各自分支，未見同路徑的跨線衝突。新成果未合併 main；不得因 CI/腳本 QA 把 ART HOLD 改為 Approved。
- **PixelLab 成本**：T-B R6 3 generations 已記錄；T-A/T-C 未新增付費調用，避免把歷史使用記為本次新花費。
- **Renderer**：T-A/T-B 原生 capture 使用 Mesa llvmpipe SOFTWARE OpenGL；T-C GitHub Actions 標註原生 OpenGL3。三者均非使用者 RX 6700 XT 本地 GPU 的可比測試。
- **P0 風險**：T-B R6 詳細 Handoff 曾提 Windows `%TEMP%` 瞬時請求／回應暫存並寫「After syncing, remove transient PC files」，目前未見獨立「檔案已清除」證據。須交代是否使用 owner PC、是否取得事前授權、當前是否尚有暫存與清理完成憑據；不能因沒有永久資料庫就假定已清理。
- **Scope**：不新增傳送、存檔、NAV 大改或 VX 新工程。本輪完全只做資料稽核與總控狀態更新，沒有修改任何原美術、角色、怪物或發動新的付費 PixelLab Job。

## 五、證據入口
- T-C current: https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tc-map-20261121/godot_port/docs/handoff/PIXELLAB_TC_CURRENT_HANDOFF.md
- T-C native CI: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44874487911
- T-A current: https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-ta-actor-20261121/godot_port/docs/handoff/PIXELLAB_TA_CURRENT_HANDOFF.md
- T-B current: https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/handoff/PIXELLAB_TB_CURRENT_HANDOFF.md
- T-B R6 provider job manifest: https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/research/pixellab_tb/TB_ATTACK_V6_PROVIDER_JOB.json
- 3-line Roadmap: ../FS_PIXELLAB_THREE_EXPERIMENTS_ROADMAP_20261121.md

**本次總控結論：三線 TRUE ACTIVE / technical progress verified by source, files, metadata and CI (C8), all ART HOLD / no merge / keep macro-first.**
