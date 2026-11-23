# GitHub canonical D18 evidence and readback

**Private D18 owner-only Drive ZIP**: https://drive.google.com/file/d/1pHr699q2mqtI8TPrtb3trX2z0h5cYLUH/view
10 files, 10,478,887 bytes, ZIP CRC PASS, ZIP SHA256 `4dfb324678263d154778f3fdadfb59d41bc051e795d93f554c61db0cf18828bf`; Drive readback shared=false owner-only.

**Real art sources:** [Independent RGBA source](https://drive.google.com/file/d/1Rdo7WObmlwx4zicWRdS3wpO8T6SAMayO/view), [1280×928 PAR](https://drive.google.com/file/d/1HbMxtnvKQMif4V_r7jOX7UyLRUpznCbd/view), [true static composite](https://drive.google.com/file/d/14Ws84SnxYSLjOsPVTahT7B86UTCy0Ael/view), [D17/D18 A/B](https://drive.google.com/file/d/1fyGgF2GuQpmHR9iOhPExTNvBUPJr25Xa/view), [full QA JSON](https://drive.google.com/file/d/1-0zc1cKXvpzRCmycV7uaOjHVKbgcgQCB/view).

**Native source/code:** `godot_port/tc_factory/biomes/fs_tc_d18_complete_par_components.py` and matching unit test.
**GitHub synthetic regression test:** [CI #45129375477 SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45129375477). This is a CI of source contract only and **NOT real D18 private art native Godot 4.7.2**, which remains **NOT_RUN/HOLD**. Latest Bridge allowlist has no approved T-C private-art Drive-to-Godot task; do not assume Windows arbitrary command or GUI permission.

---

# FS T-C D18｜FS_04_MAZE 完整非地表 PAR｜2026-11-23

## 正式目標與來源權威
以 D17 鎖定 1280×928 RGB Ground 為固定世界座標，建立另一張真正獨立的 RGBA CompletePAR，包含該場景所有非地表物件。遵循 Ground FIRST → PAR SECOND；不從完整 Master 逆切、不依角色遮擋拆素材、不修改 D17 Ground。

## 本次實際來源
- D17 Ground 1280×928 RGB：SHA256 `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`。
- D18 全新生成的獨立前景 RGBA 原始來源 1474×1067：SHA256 `a0c0f71b9db96d18ec4c8cbddee5f16366609206ec09bc474bbbe714a4dc7780`。
- 來源具有真透明背景（Alpha=0 為 846049 像素）；主要內容形成四個大型連通物件群和兩個獨立小型物件群。

## M1｜完整候選實作
- **不是**將 D15/D17 原圖拆出一段橋修補。使用本輪獨立生成的新全非地表圖，從其連通 Alpha 輪廓選取六個完整物件群，原始比例 1× 重新安排在 D17 Ground 的世界座標上。
- 每組先透過來源連通 Alpha 获得完整 Bounding Box，**不做多邊形裁剪**，不裁掉來源 alpha>8 的任何一個屬於六個主要物件群的像素；每組在原生 1280×928 世界畫布內完整容納。
- 原圖輸出的 alpha1..8 邊緣雜訊予以清為 0，alpha>=240 設成255；這屬於邊緣透明度校正，不是全像素不變，因此只聲稱保留六組來源 **alpha>8** 的有意義 641682 個像素。來源其餘 138 個分離的小亮點／雜點沒有裝入新地圖，完整來源仍保存在原始 PNG 中。
- 六個完整物件群透過 1× alpha compositing 合為一張新 `1280×928 RGBA PAR`，與 D17 Ground 合成新的視覺 QA，不反向寫入 Ground。

## 實測 QA
- 新 D18 PAR SHA256 `8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e`
- Ground＋D18 PAR 靜態 Composite SHA256 `2e618991676241471271640c7641679857a23b857a7b0048b8338ea991dff620`
- 1280×928 PNG，Ground RGB + PAR RGBA；PAR Alpha=0 **547026**，六組來源 alpha>8 有意義像素 **641682**；**polygon trimmed=0**，各組全像素無尺寸插值／無超畫布截斷。
- 重排時兩個前景來源互相遮住的像素：**868**（不等於被剪掉，已留下計數，可能需要人眼判定）。
- 來源獨立六組之外的 138 個 alpha>8 小雜點未編入正式候選；並且低於/等於8的原圖邊緣透明雜訊被清理。不要把這說成「所有來源像素100%保留」。
- 原生冷建後，PAR 和 Composite 與先前技術候選逐像素完全一致，Ground SHA 不變。
- 畫布接觸檢查：上邊 4px 高 alpha 17、下邊130、左邊103、右邊0。來源上方煙霧貼邊、兩處建物下緣緊貼畫布，屬 ART HOLD。

## M2 / M3 / M4 Gate
- M1 完整獨立非地表原圖、實際 PAR 1× 配置、Alpha、真靜態合成：**TECH PASS**。
- M2 **D18 真私有 PNG 的 Godot 4.7.2 原生執行：NOT_RUN／HOLD**。此執行容器並無已確認 Godot 4.7.2 執行檔，Windows Bridge 未核准可將 Google Drive 私人 PNG 傳進原生測試，不能借 D14 synthetic native PASS 作為本輪證據。
- M3 D17 polygon crop（源非透明像素裁掉16915）被**來源全物件連通群佈局**所取代，新選定6組皆0裁除；但煙霧貼邊、橋樑物件與地面世界語義的踏點、前景的868重疊及畫面密度需用1×人眼核對。美術仍 **ART HOLD**。
- M4 第二樣本 FS_04_MAZE 進一步完成 D18 來源替代，未達使用者 ART Gate；官方 ART count **0/12**。
- 其他 T-A/T-B、事件、戰鬥、存讀檔：**NOT_RUN，沒有修改其他分支**。

## Failure Log 與下一完整單位
1. **D17 失敗原因改方法：** 既有 D15 畫布物件與圍欄相連，使用 Polygon 裁切造成 16915 個來源非透明像素被切掉。D18 改用全新獨立非地表美術，六個完整來源連通區域以 1× 重新安置，這個 blocker 技術上已解掉，原始檔均另存。
2. **D18 完整來源 1474×1067 ≠ 原作者 1280×928：** 來源本身並非 native 40×29，但**最後 PAR 由六組完整 1× 物件排入原生畫布**；這是技術再佈局，不要宣稱模型第一次就產出原生 1280×928。
3. **美術非致命問題：** 一些頂部煙霧及下緣物件與世界畫布相碰（不是重排 cut-out，但視覺邊界需人工核對）；868 個物件交疊需檢視；地表腳點須具體原生渲染確認。記 ART HOLD，不以微調陷入無限循環。
4. **Private source Godot 4.7.2：** 沒有核准的私人 Drive → Windows 原生安全路由，本輪沒有使用 Desktop Remote/Codex，不能冒稱真圖片 native PASS。
5. **下一完整單位：** 以已建 D18 原生一整張 PAR 配對 D17 Ground，使用已核准安全私有來源測試路由跑 Godot 4.7.2 GPU 原生1×畫面，做整體視覺 ART Gate；若私有來源路由未核准，研究最小只讀隔離導入橋接器、寫負例測試及嚴格白名單，不執行任何未授權的 Windows 讀寫。再繼續後續六地形另一張完整地圖，而非再無限修單個旗幟。
