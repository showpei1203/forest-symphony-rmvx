# Forest Symphony｜T-C D19｜FS_04_MAZE 原圖安全邊界重排及 Godot 4.7.2 雙來源驗證｜2026-11-23

**施工線：T-C Map**；**分支：`feat/fs-tc-d12-chroma-par-20261122`**；**Godot target：4.7.2**；正式 ART **0/12 HOLD**。

## 一、權威與不變的原始來源
沿用已確認 GitHub D18 `CURRENT_HANDOFF`、正式 Drive Ground-first SOP 和 FS T-C Maps Skill。先鎖 **Ground → 獨立全部非地表 PAR**，不做 Master 逆切、角色遮擋分類、地表重生或舊素材覆蓋。本輪已讀 GitHub Bridge `docs/PC_CONTROL_TOOL_ROUTING_PROTOCOL.md`、README/HANDOFF、`bridge/Invoke-BridgeTask.ps1` 和 `fs-godot-testing` Skill；目前 `switch` **沒有 FS T-C 私人美術原生渲染／私有 Drive 傳輸任務**。沒有採用 Codex、Desktop Remote、GUI 盲操作。

- D17 凍結 Ground `1280×928 RGB` SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`，**未修改**。
- D18 獨立作者 PAR 原始 `1474×1067 RGBA` SHA `a0c0f71b9db96d18ec4c8cbddee5f16366609206ec09bc474bbbe714a4dc7780`，**未修改**。
- D18 上一版 40×29 PAR SHA `8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e`，仍保存私人 Drive。

## 二、M3 新完整實作：六物件不裁切的全圖位置微調

新增 `godot_port/tc_factory/biomes/fs_tc_d19_native_layout_qa.py`，重用 `fs_tc_d18_complete_par_components.render()`；只為該函式加可選 `placements` 與 `phase`，**D18 既有預設世界座標完全不變**。D19 不是再生成新圖，而是**已鎖原始作者 6 個完整連通物件**的原比例 1× 新世界位置。鐵橋跨熔岩河的 `B_WHOLE_BRIDGE=(554,334)` **固定不動**，沒有剪物件或縮放。

新位置：
- A_FORGE_MARKET (4,4)
- B_WHOLE_BRIDGE (554,334)　**Locked**
- C_SOUTH_WORKSHOP (4,566)
- D_SOUTH_FOUNDRY (644,570)
- E_FULL_LAMP (542,743)
- F_FULL_BANNER (544,410)

實際在私有原素材進行冷建、SHA 比對，輸出 **1280×928 RGBA PAR** SHA `cee5cafadd2f57f7da577bff1d4d4b9fb950fb9c5b0be3caaad73c5bec5369e1`，與不變 Ground 的**像素級合成** SHA `c9da92ee753970cbcf528a96cefbec2b8fe7088a0bb80ddffbb528b0cef9428a`。

| QA | D18 | D19 |
|---|---:|---:|
| 外側 4px 高不透明來源像素（上/下/左/右） | 17 / 130 / 103 / 0 | **0 / 0 / 0 / 0** |
| 六個主要來源 Alpha>8 像素保留 | 641682 | **641682** |
| Polygon trim | 0 | **0** |
| 前景物件重疊 | 868 | **1596** |
| Ground SHA 變更 | 0 | **0** |
| 1× resize、插值 | 0 | **0** |
| 橋梁地圖世界落點 | (554,334) | (554,334) |

**Failure Log：**雖然解決最外四像素穿幫問題，但重疊**增加 728px**，美術優劣需人工 A/B 審核。橋梁兩岸地表、建築足點與過場動線仍屬 HUMAN ART HOLD。新座標版不能直接覆寫 D18 原稿。

另外輸出獨立的 `D19_GRID_FAMILY_QA_ONLY.png`（六物件連通 bounding boxes + 32px 格線），此檔**僅供 QA**，不是 Ground 或 PAR 層。

## 三、原生 Godot 工程加固與實際跑過的 CI

沿用現有 `godot_port/tc_factory/native_complete_par_probe.gd`，增加：
1. 可選 `--par-sha` 之 **第二份獨立來源 SHA256 驗證**，不影響既有 D14 命令。
2. Godot 4.7.2 實際讀取完整 PAR Alpha，確認同時存在**透明**和**可見非地表**像素；不允許「整張不透明 Master／全透明空白」被當成有效 PAR。
3. 輸出原生 QA JSON 的 `par_sha256_lock_verified`、`par_alpha_zero_pixels`、`par_alpha_visible_pixels`，維持 ART HOLD。

[**GitHub Actions #45133019030：SUCCESS**](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45133019030)：官方原生 Godot 4.7.2 確實在 CI 中 cold-import、雙圖 SubViewport 1× 渲染，正確拒絕**錯 PAR SHA**、**不透明 Master**、**錯 1280×928 尺寸**；該 CI 僅使用**合成測試 PNG**，**不能聲稱 D19 私人藝術 Godot 原生通過**。

[**D19 layout CI #45133395097：SUCCESS**](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45133395097)：保持 D18 舊 pipeline synthetic regression、D19 六獨立物件和橋座標、安全邊界、SHA、錯誤輸入拒收。**這是程式測試，不是實物引擎畫面**。

**M2 仍 NOT_RUN/HOLD：**D19 真私有 PNG 未透過**已批准的**安全來源通道送入 Godot 4.7.2 運行環境；目前此容器無已安裝的 Godot，官方下載 URL DNS 不通。不能使用合成 CI 當私人素材證據，不能擅自擴權 Bridge 或使用 Desktop Remote。

## 四、私人 Google Drive 完整封存及權限 READBACK

- [D19 **12 檔完整私人 ZIP 14,432,637 bytes，CRC PASS**](https://drive.google.com/file/d/1osgVoSOLtuWua-7jUnVebD_XsdlLIqNk/view)，ZIP SHA256 `80f40552bbfc38f884a09f0e1621ebe8d434f0b363a1aaf57dfc765e44165a09`。
- [D19 全非地表 PAR 1280×928](https://drive.google.com/file/d/1QvEN7_DxSB3pvlDW70TDmIeCTD44I6XL/view)
- [D19 Ground+PAR 1× **靜態**合成](https://drive.google.com/file/d/1vRH8svAtheYP_-UbB_WUjNh0sI0A0xAW/view)
- [D19 32px Grid / 六物件範圍檢查](https://drive.google.com/file/d/1k06RyynDHhcA2Ait_HUnVZSWRskahvIk/view)
- [D18 vs D19 場景 A/B](https://drive.google.com/file/d/1K59hTfpDrl-I_Fqj_n03gw0cb-qrw5eI/view)
- [完整 QA JSON](https://drive.google.com/file/d/11grlCFFQwpdaeIhtTeL_9hPubtmEA17D/view)／[來源 Manifest](https://drive.google.com/file/d/1ZPBtYfoQcrvfxvMlpZwA6L3CWS-pldnk/view)

上述 metadata 已回讀：全部 `shared=false`、`permissions=[owner]`。所有原始 PNG/ZIP 僅私人 Drive，GitHub 只放程式、工作流、Handoff 與非敏感進度表。

## 五、正式 Gate 與下一宏觀施工

| Gate | 真實結果 |
|---|---|
| M1 Source / SHA / Alpha / 原生 40×29 | PASS |
| M2 D19 私有圖 Godot 4.7.2 原生 1× | **NOT_RUN／路由 HOLD** |
| M3 畫布貼邊阻斷修正 | **TECH PASS** |
| M3 重疊風險、橋／工坊落點、人眼風格 | **HOLD** |
| M4 第二樣本 FS_04_MAZE | **完整技術候選，不是 ART PASS** |
| Game integration / ATB / 事件存讀 | NOT_RUN |
| 正式十二圖 ART PASS | **0/12** |

下一個完整施工單位：**設計、審核並通過安全測試的窄範圍 T-C 私人 PNG → 已存在的 Windows Godot 4.7.2 原生渲染環境路線**。只允許兩份固定 SHA 的私人 Ground/PAR、只寫隔離 QA 工作區，不把圖片上傳公開 GitHub；若無可核准的私人來源傳輸路由，持續 HOLD。真正跑過 D19（或保留 D18 A/B 比較）原生 1× 截圖並回存私人 Drive 後，才進 USER ART Gate。不要反覆重生 Ground，也不浪費時間重新安裝已確認工具。
