# FS Godot A33｜完整獨立路燈 PAR 修復｜Native QA、Failure Log、Handoff
Date: 2026-11-14 (Asia/Taipei). Main engine Godot 4.7.2. **ART HOLD**, Formal Seal NO.

## Authority / 目的
- 尊重使用者已核准 **Ground-first → 單獨完整 PAR → Godot/YSort/Collision → 1x 合成美術達完整生圖豐富度**。Master §0c v1.3 不得改回完整場景裁切。
- 修正使用者 A32-F05「路燈只剩半截」；**不是 Godot 把圖片裁掉，而是舊來源 16×41 px（A32 加透明邊界變 32×57 px）柱身本就短**。
- A32 舊場景/來源是不可變回歸候選；新成果寫在新 A33 scene、manifest、PNG、QA，A32 Ground、房屋、樹木像素一律不變。

## A33 具體新產物
- 全新原創完整、非 Master 裁切的 **透明燈具 RGB+A**：燈頂尖、苔蘚瓦頂、琥珀光燈罩、金屬裝飾、完整燈柱、石座；AI 生成完整物件原始 PNG 887×1774 RGBA、SHA256 **f051f4cf6f59d0f9555faf021c4affcf4e75123aae2220f7003b06ccf1e8a9d3**，記錄來源，保存在私人封包。獨立 downsample+色盤 84 colors 工具 `tools/a33_build_complete_lantern.py` 已驗證可重建產物 SHA。
- 可用透明 RGBA PAR **52×124 px**，完整 alpha bbox (5, 4, 47, 116)，SHA256 **6e0bed07a735cba3c908a5da4c81863222363cab01325aeeaaf1f821d63a6991**，單個 source 被四個 Godot editable objects 重用。舊 32×57 與其 SHA 原封不動。
- **A33 scene:** `scenes/a33_groundfirst_lantern_scene.tscn` 由 A32 146 物件不破壞 fork。四個路燈參照新的獨立 PNG；只有四個燈的 source, foot collision 更新。**140** 足點小碰撞（A32 136），路燈底座 **12×8**，不以整張 sprite 阻路。146 物件總數與 27 個使用中 source 家族不變。
- 本輪 Ground 完全不重生成、不刪除任何物件：原 Ground **1280×928**，SHA256 **3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000**。
- **實際 native framebuffer 發現 A33-F02**：第一盞新燈位於原腳點 (496,473) 遮住井口；改到 **(438,473)** 的路旁，完全獨立改單個 YSort node + manifest；另三盞足點不變。井口與路旁效果在 1x Native 重新比較。

## 真正 Godot 原生執行驗證
- Godot 4.7.2 official `--editor --headless` 匯入 A33 場景 **PASS、0 Godot error**；Mesa llvmpipe/Xvfb OpenGL native framebuffer (不是 Pillow 合成)。
- A33 原始私人素材實際 GDScript `tests/test_a33_lantern_real.gd` **760 / 760 PASS**；來源 Ground、全 146 PAR 個別 SHA、腳點、燈具 alpha 完整、原 A32 scene 存在、新燈 12×8 真正 collision、Godot 角色實際接觸測試 PASS。
- A32 原始私人素材 `tests/test_a32_groundfirst_real.gd` 重新執行 **734 / 734 PASS**。A33 獨立 `tests/test_a33_public_contract.gd` source-only **PASS**。
- 全圖四張 1280×928 真正 OpenGL frame：原 A32、A33、燈後人物與燈前人物。A32/A33 native RGB 不同 **7964 pixels**，**四燈舊/新 bbox 之外 RGB 差 0**；證明除四盞的源和位置外，整張實際合成畫面相同。真正神經網路藝術圖也記錄 raw source hash；不是美術 pixel-perfect seal。
- 1x native A/B 和四燈放大比較 `qa_a33/A33_GODOT_NATIVE_LAMP_4WAY_COMPARISON.png`，no synthetic screenshot substitution。

## Failure Log / 禁止重演
- **A33-F00:** 原 public contract 使用 GDScript `assert()` 遇到 JSON array 型別比較失敗，CLI 不能自行 quit 造成 timeout。已改 fail-closed `verify()` + `quit(21)`，並逐 scalar 比較。
- **A33-F01:** 真實 QA 首次 GDScript 語法誤把 `Vector2` 與 `Vector2i` 直接比較，原生 parse FAIL；修復明確 `Vector2` 檢查後實際 PASS。不將 parser error 誤報通過。
- **A33-F02:** 高燈罩與井口重疊，在第一張原生 framebuffer 發現；**只移動一盞燈 x -58**，Ground SHA 與另外三燈位置不動；重新原生渲染驗收。
- **A33-F03:** A33 新燈較精緻，和兩棟 A36F 苔蘚屋、混源樹木的材質/光影/像素密度仍未完全統一；**ART HOLD**，不是整張村落美術完成。
- **A33-F04:** 光只有 source 內部琥珀發光感，尚未實際做分離 `LIGHT` 層/動態 Godot Light2D。不可稱動態照明完成。
- **A33-F05:** 先前 180-cell A30 water collision 只在舊 A30/A31 測試場景，不是此新 A32/A33 40×29 地圖的完整通行。A33 只有 140 根部碰撞；水岸/門口/NPC/戰鬥/存檔未完成。

## 下一步 A34 優先
1. 兩棟真完整美術房屋 PAR（現有素材 254×252 和 214×252，屋頂像素粗糙，請以風格統一及完整立體造型為先）；取代單一物件，**Ground 不變**。不要生成整張場景後再切屋頂。
2. 檢查 27 個 PAR 家族的色調與像素密度、前後林群形態，保留原始獨立 PNG 且可逆調整；用實際 1x Godot 幀比較美術。
3. 接建築入口與區域碰撞/連通、真正四方向角色走路及事件編輯器。每項都有 source/QA/ART Gate，別把 CI 當美術。

## 雲端與安全
- 全部原創 PNG、既有私人 Ground、完整 Godot source/QA/Native screenshots 只在 owner-only Drive，不上傳 GitHub。公開 GitHub 僅放 `scenes` `.tscn`、GDScript、manifest、再製工具、Handoff、文字 CI。
- 不修改正式 main、原封版 VX、原 A32 scene；不寫使用者 PC。使用過一次 image-generation 產出原始獨立燈具參照，沒有聲稱使用者已 Art PASS。

## A33 owner-only cloud readback (2026-11-14)
- [Complete A33 155-file Godot ZIP (owner-only)](https://drive.google.com/file/d/1mIJVMUsdHJu0oVUqBbVqvGhhJ582o7zl/view): **61,517,282 bytes**, SHA256 **50729302db83d920d55f131c69f1f671001664af86fad1099dab1b09c1d4b224**, uploaded and downloaded, SHA256/ZIP CRC PASS. Independent cold-extraction member-hashes 154/154 PASS, native Godot script 760/760 PASS.
- [Native Godot full A33 screenshot](https://drive.google.com/file/d/1_nPLKPYRVPAoO24azAnLtQbOPYH80gvO/view), [four-lamp original engine before/after comparison](https://drive.google.com/file/d/1lrB7aoIgCFSbfeGMnk5hP5P3HT8Qix8Q/view), [Drive Handoff mirror](https://drive.google.com/file/d/1XnptWlq3H88Oy4GDo9C7ScyKNDH6G-05/view).
- ZIP stores the immutable pre-cloud-link Handoff. GitHub doc/Drive Handoff mirrors append these cloud receipts after ZIP creation. The newer doc links do not imply ZIP payload changed.
