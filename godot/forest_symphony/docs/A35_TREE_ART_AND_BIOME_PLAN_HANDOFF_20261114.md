# FS Godot A35｜完整獨立樹木素材家族＋六地形世界美術規劃 Handoff

日期：2026-11-14（Asia/Taipei）
狀態：**Ground-first v1.3／獨立完整樹素材／真實 Godot 4.7.2 原生測試 PASS／用戶 Art HOLD／大型新地圖未生成／事件開發 OUT OF SCOPE**。

## A35 真正施工
- A34 原樣保留：1280×928 `private_assets/ground_only.png` SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`；兩張完整工坊/住屋透明 PAR，四盞完整 A33 路燈，與其余 138 個物件來源保持不變。
- 用 ImageGen 獨立生成 **兩張透明樹家族來源頁**（每頁兩棵互不相接的完整樹木），單獨取出**四棵完整個體**，不是從完整地圖畫面切割；保留來源和 SHA，處理圍繞完整 alpha bbox 的透明邊、去除孤立不自然紅色熱點、等比縮小為完整 RGBA PNG：
  - `a35_oak_summer_176x174.png`
  - `a35_birch_blush_122x170.png`
  - `a35_oak_golden_176x174.png`
  - `a35_birch_cream_122x170.png`
- 只替換舊 A34 場景中 **8/134** 棵樹的來源圖；其腳點、位址和**候選**足點碰撞維持，其他 **138/146** 個物件來源不變。新場景為 `scenes/a35_independent_tree_family_scene.tscn`，舊 `A34` 場景保留不覆寫。
- `tools/a35_build_independent_tree_family.py` 的四個 CLI 參數（base/dest/pair1/pair2）可**冷重建**。在獨立 A34 基準重建，四張完整樹 PNG、Scene、Manifest SHA 逐檔一致。公開庫保留程式及 JSON；高品質來源 PNG 僅保存 owner-only Drive。

## 實際品質證據
- Godot 4.7.2 真正載入私人原始 Ground／新獨立樹 RGBA；實際 `YSort`、146 個物件與 140 個根部/房屋/路燈碰撞源都存在：**1063/1063 native checks PASS**。
- 真正 Godot OpenGL llvmpipe native framebuffer：1280×928 的 A34 舊圖、A35 新圖各一張，另取得人物站在新樹前／後的兩張 1280×928 真 Godot frame（僅渲染站位候選，不可誤認碰撞通行 PASS）。差異 **65,992 RGB pixels，全部位於被更換 8 張樹的舊/新物件矩形內；其外 0 pixels**。SHA-byte original Ground completely identical。
- 公開不含藝術的 Godot 4.7.2 結構測試 **788/788 PASS**（不是私人美術檢查）；六系世界 JSON Python 驗證 PASS：6 biome × 2 場景 = 12。
- 新樹有較高色彩與細節，但與少數未替換的舊樹仍可見繪製密度差異、部分林緣樹冠出畫面。**用户美術 ART HOLD；不是已完成整個森林的改造。**

## Failure Log
- **A35-F01 公開測試偽綠燈**：第一次 GDScript 測試用 JSON 裡 Array 與 GDScript array literal 直接 `==` 比對，誤判 80x58 和 2560x1856；更糟是測試只 `push_error` 卻最後 `quit(0)`，產生假 PASS。已改成逐數字明確比對、`failures` 累加與 `quit(25)` fail-closed，重新實機跑 788 checks 且沒有 error。不得只認綠燈 log。
- **A35-F02**：兩個獨立樹來源頁並非天然逐棵 source file，確實先分隔透明空白處、再包住完整樹輪廓裁取；這不是從場景 Master 分層，但**仍屬家族 sheet extraction**。完整原頁+來源 SHA 保留，不能假稱 AI 一開始就直接生成四張個別 PNG。
- **A35-F03 ART HOLD**：只替換 8 棵，不能宣稱森林全局風格一致；新增樹比較亮、陰影可能與老樹不同，需在 1x 看畫面，不以像素變動數作美術 PASS。
- **A35-F04 SCALE 未完成**：A36 2560×1856 僅確立可測的地圖尺寸/材質/Layer 規格，未有真正大型連續美術。不能重複四張舊 Ground 來冒充完成。

## 六地形迷宮＋村莊，禁止搶其他對話的事件開發
見 `docs/FS_SIX_BIOMES_WORLD_ART_PLAN_20261114.md`、`data/fs_six_biomes_world_catalog.json`。六類：精靈森林、雪原、沙漠、火山、濕地、星晶浮島；每類包含一張迷宮一張村莊，總 12 張長期目標。每類有獨立 Ground 材質、完整 PAR 家族、迷宮視覺辨識符號；Godot 技術架構統一。**NPC、任務、劇情、事件編輯器完全交由另一個對話。**

## 下輪真實施工
- **A36 優先 2560×1856 80x58 真正連續 Ground-only 美術**，不能用四個相同 A34 舊 Ground 拼接。完成真正地面後，再用現有獨立樹、路燈、房屋及新增 PAR 以世界座標建場景；保留完整原藝術，驗證原生相機四角／遮擋／可走路線、全圖 1x 美術。
- 先挑一組不協調的 tree/ground ROI 做色彩調整候選（只變動獨立物件 RGB，不變 Ground），保持 original controls 供 ART 比較。先補森林密度與場景邊界，不增加無意義 synthetic 計數。

## Cloud storage / protected baseline
- 只在 GitHub **Draft PR #16** 開發 Godot source-only scene/script/tests/docs；私人完整 RGBA 和 original Ground 在 owner-only Drive；P0 不寫使用者 PC，不改正式 `main` 或原 VX 封版；每輪上傳後下載 SHA/ZIP CRC 驗證。`CURRENT_HANDOFF.md` 需指向最新來源與畫面證據。此文件在 Cloud 回讀後補雲端連結與最終 CI 結果。

## Cloud verified delivery (2026-11-14)
- [Owner-only A35 complete reproducible Godot project](https://drive.google.com/file/d/1gNjkqvo_I8KbT4siEolsAWflyIRBPVim/view): **158 files, 40,467,666 bytes, SHA256 `f1de2a44f89e580620b86e154904907e484fea5610d10da83d895b54c20f4c98`**, upload→download SHA and ZIP CRC PASS; original private source art stays unshared.
- [True native Godot 1x art side-by-side](https://drive.google.com/file/d/19K82PK8_F5W_riClWDdF302UZ6TKzYRR/view); [true native actor/tree depth A/B](https://drive.google.com/file/d/1mTgJ8EgrdoJZ4q0l1sPKjtOQhmI1jAO0/view).
- [Six biome and twelve scene art specification Drive copy](https://drive.google.com/file/d/1hQEUuEGcuFunJVkQfREjdfLWSaMvU4Fz/view). Godot source-only GitHub CI should run separate A35 public contract; no user ART PASS inferred.
