# Forest Symphony A36B R2｜大型森林樹群自然度與獨立完整 PAR｜2026-11-14

**工程：Godot 4.7.2 stable｜80×58 @32px = 2560×1856｜Ground-first + 獨立完整 PAR**

**判定：源文件／引擎／分層回歸技術 PASS；1x 美術 ART HOLD；溪流導航/動態水 HOLD；不是正式封版。** 事件、NPC、劇情及戰鬥由另一個對話負責。

## 與 A36 真正不同的地方

- **不重新製作 Ground、不做完整畫面分割。** A36 原始 Ground-only 2560×1856 SHA256 `ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911` 在 A36B 位元組不變，來源 1478×1064、最近鄰非原生目標像素繪製的限制照舊。
- 從新獨立透明 RGBA 樹木圖集（1536×1024）選出 **兩株完整、且彼此不相交的樹木**，獨立保存 **松樹（148×194）和河岸垂柳（208×190）**，不是從已合成的大地圖擷取。
- 第一輪圖集右下兩種樹有超出象限／相互重疊的 alpha，**拒絕當作完整可量產樹**，不能把裁掉的素材假裝完整。本階段真正通過的新增樹種只有 **兩種**。
- 由現有 310 棵 A36 樹中替換 **40 棵高地／林緣松樹、22 棵沿溪垂柳**，保留其他 **264 個原始場景物件 SHA、位置與腳點不變**。總物件數仍 326，完整獨立 PAR 來源家族由 9 增加至 **11**（其中樹木由 4 增加至 6）。
- 新樹改用不同完整輪廓，不只是換色。沿溪水氣與林緣坡地決定候選物種，並用明確的最小樹距減少規則性。接地陰影重新從所有物件足點單獨生成到 `a36b_contact_shadows_2560x1856.png`，沒有烤回 Ground。
- 原版 `a36_large_verdant_forest_80x58.tscn` 保留；新版 `a36b_large_forest_tree_ecology_80x58.tscn` 預設開啟；所有物件均可在 Godot 個別調整，無新事件程式。

## 實際驗證

| 來源 | 驗收 | 結果 |
|---|---|---|
| 私人圖片來源 + Godot 4.7.2 `test_a36b_real.gd` | 326 個原生物件、SHA、透明 PNG、足點、角色／相機、碰撞根部 | **2,621 checks PASS** |
| 完全不需私人圖片的 `test_a36b_public.gd` | 場景解析、兩種樹型、62 個改動和 264 個不變的 manifest/source 契約 | **1,973 checks PASS** |
| 真正 Godot 4.7.2 OpenGL llvmpipe | A36 / A36B 兩張 **2560×1856 原生 framebuffer PNG** | PASS |
| 原生畫面逐像素比較 | **910,260 個 RGB 變動像素**、僅在 62 棵新舊樹及接地陰影 ROI | **ROI 以外 0 像素差異** |
| 從 A36 R2 + 原始樹木圖集在新隔離資料夾冷重建 | 松樹、垂柳、完整場景、Manifest、SHADOW、World Script | **6/6 SHA 完全一致** |
| P0 防寫入 | 目的地已存在則直接拒絕，原始 A36/私有 Drive/使用者電腦不覆寫 | PASS |

### Failure Log

- **A36B-F01：樹種過度重複。** 先試作 40 松／30 柳，原生畫面出現過密、規則的垂柳帶；R2 改成 **40 松／22 柳**、垂柳樹距由 80 調到 **160 px**，且並未改路徑或原 Ground。兩版完整藝術回顧必須保留；R1 不當正式成品。
- **A36B-F02：素材圖集象限交疊。** 2×2 原始素材的下排樹群跨越象限切線，從四格硬切會失去完整樹冠／樹根，故只接受上排完整分離的松樹、垂柳兩株。不能冒報新增 4 種完整樹。
- **A36B-F03：測試腳本字串替換副作用。** R2 測試初稿批次取代 `==256` 誤改成 `==2640`，造成公開場景尺寸檢查 FAIL；已修正並重新跑 Godot，公開 1,973 PASS。
- **A36B-F04：風格不一致尚存。** 松樹與垂柳改善原本 4 種樹循環的觀感，但垂柳亮度偏黃、松樹偏深，和 Ground3／A34 房屋的細緻程度仍需要 1x 用戶驗收；不能用替換數、SHA 或 CI 當 Art PASS。
- **A36B-F05：地面解析度／溪流語意未完成。** A36 的 Ground 原生來源仍只有 1478×1064，放大後部分植被/岸線有重複或錯格；148 個溪流禁行格仍是候選，尚未做成可直接用的 Godot 物理水域，也沒有真正水流動畫。

## 來源與新場景

- 檔案：`private_assets/a36b_tree_full_family_source_sheet_1536x1024.png`（原生生成圖；保留 alpha）、`private_assets/independent_par/a36b_moss_pine_148x194.png`、`private_assets/independent_par/a36b_river_willow_208x190.png`。
- 場景／Manifest：`scenes/a36b_large_forest_tree_ecology_80x58.tscn`、`data/a36b_ecological_tree_manifest.json`。
- 原始 A36 圖像與全部 326 個舊物件來源仍保留在封包及 A36 R2；新資產可個別替換不需重建 Ground。
- 量產器：`tools/a36b/build_a36b_tree_ecology.py`，須提供環境變數 `FS_A36B_BASE`（已確認的完整 A36 R2 Godot 工程）、`FS_A36B_OUTPUT`（全新不存在的隔離路徑）、`FS_A36B_SHEET`（原始透明樹木圖集路徑）。若輸出路徑存在直接拒絕並不寫檔。
- 公開 GitHub 僅保存 GDScript、Scene／Manifest／編譯器／QA／Handoff；真實有版權來源的 PNG、私有 QA PNG 和 ZIP 僅在 user owner-only Drive。

## 下一步 A36C

1. 真正改善 **A36 Ground 原生尺寸與像素密度**，優先林地道路/溪流岸線的 1x 閱讀性，保留 A36B 真實來源作 A/B；不可只用濾鏡宣稱原生畫質已達標。
2. 林群從現有 **6 種真正獨立完整樹型**增至 8～12 種，兼顧樹冠大小、枝條輪廓、樹根與生態分區，而非單純換色或大量植樹。
3. 河水動畫必須以**獨立 WATER 層**加上原生 Godot 渲染及原始 Ground 相容性的真實測試；148 格水域仍保持候選直到可實走。
4. 先以森林 2560×1856 達到 1x 美術和物件完整 QA，再開始六種地形各自的迷宮與村莊；不能拿 12 張概念圖冒充可分層 Godot 地圖。

**任何雲端 Drive ID、GitHub CI 及 Handoff 連結需在上傳並真正回讀後才能標為完成。**


## A36B R2 owner-only Drive and real GitHub delivery
- Full private 173-member A36B portable Godot ZIP: https://drive.google.com/file/d/15t5Yn6zdTC8vG1dOYrLmMEHGVYqjEjwO/view , **54,150,993 bytes SHA256 `7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b`**. Drive upload→download original bytes, ZIP CRC PASS, 172 member SHA PASS; owner-only, `shared=false`.
- True independent A36/A36B Godot OpenGL 1x framebuffer A/B: https://drive.google.com/file/d/1XvFNe8auahjunwSm1x_Rz3ot8IznhjR5/view ; new 2560×1856 true Godot frame: https://drive.google.com/file/d/1fVCS0ut1RBnfVz_sv2X9ToyBP4xYUq8V/view .
- Private Drive Handoff/Failure Log mirror: https://drive.google.com/file/d/1Q6FjCjlnOgIGRQauFmkhz3kHr4CvotRb/view .
- Public Draft GitHub Godot PR #16 branch `feat/fs-godot-first-a29-20261113` for only source, editor scene references, tests, art source manifests. GitHub Actions latest-head status must be independently checked after commit; no pre-claim of CI success.
