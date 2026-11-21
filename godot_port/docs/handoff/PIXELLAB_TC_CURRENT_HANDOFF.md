# T-C CURRENT｜D3 六地形×迷宮／村莊十二圖生產啟動｜2026-11-21（Asia/Taipei）

**本輪已實際上傳 SOP + 六地形追蹤檔 + 新雪原 Ground 候選；02_VILLAGE PAR 尚未成功，正式所有地圖仍 ART HOLD。** 最高規則不變：**先生完整 Ground，再生同世界座標 CompletePAR；PAR 收納所有非 Ground 物件，與是否遮擋角色無關。** 不從 Master 逆向裁層、不在本工廠處理 NPC/事件/戰鬥或角色遮擋細節。

## 本輪確實完成

1. **SOP 已在兩處正式保存**：GitHub [FS_TC_GROUND_FIRST_COMPLETE_PAR_12_MAP_SOP_20261121.md](FS_TC_GROUND_FIRST_COMPLETE_PAR_12_MAP_SOP_20261121.md)；Drive [可編輯正式文件](https://docs.google.com/document/d/1zWXO6Z8SHobSK2jfI-M6-p6JDb81BniIH_4UCLiJhIw/edit)，Google Docs API 寫入後已讀回 46 段、標題與章節及 GitHub 來源連結。包含 D2 46×33 真透明 PAR 與 Ground 實際配對方法、Alpha 色彩污染、40×29 裁切失敗、完整新圖輸出限制、正式 Handoff 及雲端 SHA 原則。
2. **已重新讀 Drive 2026-11-14 正式世界設定** [FS_SIX_BIOMES_WORLD_ART_PLAN_20261114](https://docs.google.com/document/d/1SjVPK3J5exwp0fC3bRMHjoWo2vne_pck/edit)，及 [2026-11-16 12-map Active Master](https://docs.google.com/document/d/11SzPGsNakKL7U0Gzo0LFN806gJU_82sP/edit)，原名／場景 ID 固定不換：蒼翠精靈林 FS_01_MAZE 幽葉迴廊／FS_01_VILLAGE 苔光村；凜霜雪原 FS_02_MAZE 冰脊迷谷／FS_02_VILLAGE 霜燈聚落；風蝕金砂 FS_03_MAZE 風沙裂谷／FS_03_VILLAGE 星井綠洲；赤焰火山 FS_04_MAZE 熔脈裂橋／FS_04_VILLAGE 灰鑄工坊城；幽霧水澤 FS_05_MAZE 泥潭迷水／FS_05_VILLAGE 蘆燈水上村；星晶浮島 FS_06_MAZE 星盤斷空／FS_06_VILLAGE 虹晶臺地村。
3. T-C GitHub 新文字台帳 [TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json](../../tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json)，是六大地形十二圖的施工追蹤檔，**不是另一套可覆蓋舊正式設定的 canonical Scene Manifest**。已明確保留森林兩圖既有技術候選／ART HOLD、雪原第一張 Ground 候選、其餘十張未造；**正式 ART SEALED = 0/12**。
4. 新獨立雪原圖片：FS_02_VILLAGE「霜燈聚落」**GROUND-FIRST 候選**，原始新生成 RGB 圖 1470×1070 SHA256 `bb2bdbc0a50fab85689180669b36b59b858a98863d44d9a127aa26e628dbc9b3`；用 `(95,71,1375,999)` 原像素裁切出 1280×928／40×29 32px 格，**無縮放**，Ground 候選 SHA256 `475f7883c1fe23245198198029da3ac37dc479176e3dc8ddc8a81aba4054f5ea`。保存 40×29 32px 格線 QA，5 檔 source/ground/grid/QA/blueprint ZIP CRC PASS，source+PNG READBACK。
5. 私人 Drive 檔： [Ground 1280×928](https://drive.google.com/file/d/1YQt0dkI2AR9VFYMMrFYP3h4KUPJ_ka9T/view)（2,075,805 bytes）、[未裁原始圖 1470×1070](https://drive.google.com/file/d/11TWOaksX413DsIMCN5Nmm1TfCCQRlYyK/view)（2,912,203 bytes）、[32px 格線 QA](https://drive.google.com/file/d/174ytM0lTie-i1YINZVg364_A62dYlbql/view)（2,024,066 bytes）、[完整 Source QA ZIP](https://drive.google.com/file/d/1d4LoyX3FSYRA9iy9aCU5WJ_N0RYz8XOY/view)（6,982,939 bytes，SHA256 `d21c285a8915dd51e5db7ff53a9f3a8cae3409a6523e091df3bd3590c0e1b154`，CRC PASS）。Google Drive API 四項 readback 全部 `shared=false`／user owner-only。圖片不放公共 GitHub，也未碰使用者 PC。
6. 專屬雪原藝術規格在 [FS_02_VILLAGE_GROUND_FIRST_BLUEPRINT_20261121.json](../../tc_factory/biomes/FS_02_VILLAGE_GROUND_FIRST_BLUEPRINT_20261121.json)：世界 ID／材質／非地表物件規定／Ground 初稿 SHA／PAR 預期完整物件家族、來源座標、驗收狀態。依 2026-11-14 世界美術設定，Ground=積雪、凍土、碎冰、冷色岩地面、雪路；PAR=全部冷杉、冰柱、覆雪房、暖爐煙囪、岩塊、燈柱、欄杆、橋梁、裝飾，不因 blocking/occlusion 移除。

## Failure Log 及誠實 Gate

- **D3 PAR 仍 NOT_GENERATED**：嘗試生成完整雪村透明 PAR 時，圖像工具錯誤輸出「進度海報／資訊圖」，不是 RGBA 遊戲素材，已拒收，不能為圖面內容背書或當地圖 QA。下一輪需使用可可靠輸出原生同尺寸透明圖層的工具／製程；不把海報冒稱 source。
- **D3 Ground SOURCE CANDIDATE，不是 Ground ART PASS**：圖中若干小型立體岩塊／立體灌木疑似不該留 Ground，需要以成圖規則確認、必要時重生 Ground，不可在整張圖做 Master 逆切。新圖片只有 RGB、尺寸、裁切、SHA、存儲 PASS，**沒有**完成嚴格 Ground purity 人工藝術驗收。
- **新雪原尚無完整 PAR / 新雪原 Godot 4.7.2 native NOT_RUN**。先前 D1 全物件 192／192 CI 不是 D3 的 native 結果；不得互相移花接木。雪原 1/2 圖層只是 Ground 候選，不宣稱完整場景通過。
- 過去 FS_01_VILLAGE D2 46×33 Ground + CompletePAR 同圖合成 TECH PASS，美術/真正原 40×29 裁切 ART HOLD；FS_01_MAZE 技術場景 ART HOLD，不覆蓋。
- 六地形正式完成地圖數 **0/12**，新 D3 雪原 source 候選 **1張**；不要把工程追蹤、SOP、進度海報算作美術完成。

## 下一個宏觀單位（保持六地形12圖，不糾結單棵樹）

先把已封存雪原 **FS_02_VILLAGE** Ground 語義純淨度審核並以**同一張已產生 Ground**生成真正獨立、透明、完整非地表 PAR（所有屋舍、完整冷杉、冰柱、路燈等），一次美術驗收；若上游工具只出海報，停止假輸出，改來源/模型/流程，不再微調遮蔽。配對完成後，直接開始同地形 **FS_02_MAZE 冰脊迷谷** 的完整 80×58 Ground-first，繼續地形 03 風蝕金砂、04 赤焰火山、05 幽霧水澤、06 星晶浮島。所有階段只有圖片實出、SHA、Drive WRITE→READBACK、Art/Engine 各自 QA 才能升級狀態。

---
# T-C CURRENT｜D2 真正新生成 Ground＋透明完整 PAR 之合成與 QA｜2026-11-21

**新 Ground／PAR 真實合成成功，宏觀美術評估方向正面；46×33 source pair TECH COMPOSITE PASS，但透明 Alpha 原圖有污染、1280×928 裁切物件，正式 ART HOLD。Godot 4.7.2 原生 NOT_RUN。** 使用者最新唯一規則：Ground 獨立先生成，完整 PAR 後生成，收納除 Ground 之外的所有非地表物件，絕不篩選角色遮蔽物。

- 完整紀錄：[`TC_D2_GROUND_PAR_NEW_GENERATION_PAIR_QA_20261121.md`](../handoff/TC_D2_GROUND_PAR_NEW_GENERATION_PAIR_QA_20261121.md)；包括原圖 SHA、兩個 PAR 版本、Alpha 分佈、像素同尺寸原點、32×32 全圖、失敗紀錄和 Gate。GitHub 只保存 code＋QA＋Handoff，素材在私人 Drive，無使用者 PC 寫入。
- **原始兩張生成畫布各 1473×1068**，同一 XY、不混入 Master；為保留全部房屋樹木、不縮放，作為 46×33（1472×1056）完整地圖候選，僅從 Ground 及 PAR 同時裁右 1 px、下 12 px。Ground.png 46×33 SHA `226a0733dc92cd0023ddcd4a86afff9d8a469cc658b0a5e884c5667bcce36af1`；原生 PAR SHA `0a52c590e85086b29af37754bdbc9206d2aab96ec9d98e0c82f5d4d4dbd2f574`。
- 技術 Alpha 清理試驗：原 PAR 大量 alpha 1..8 的紅黃綠雜色；新增候選修正 alpha≤8→0、alpha≥240→255，不改可見 RGB，原 PAR 原封不動保留。清理後 SHA `80b6aee06908c3e8160881af28a3faa9cf0d3d09c85bac3f0b538de45e9e406c`，完整合成 SHA `09137573db960dead52bc599e859a7f5134b65366f13e371df39a1cd3f91e7a8`。Pillow 真逐像素 alpha composite PASS；原生 Godot 4.7.2 NOT_RUN，不能誤寫 PASS。
- Google Drive READBACK owner-only：**[Ground](https://drive.google.com/file/d/1zop1sxdXiTfee_rpiSQCJXu5Uotikt4y/view)**、**[原始完整 PAR](https://drive.google.com/file/d/17lUUXnCCNk4pQGWUGiRciSJW9qAVGbrl/view)**、**[Alpha 技術清理 PAR](https://drive.google.com/file/d/1nywEe4sG-KTtWFTpPC7VCoQjD_ANa6Lv/view)**、**[完整合成圖](https://drive.google.com/file/d/1cASgC0jbjiXbFOf_HSJPTanjgBHUfUrU/view)**。四個檔案均 verified shared=false/user owner。
- **1280×928（40×29）只算裁切展示，非正式藝術過關**：來源同座標中央裁切會讓原 PAR 上緣 872、左 544、右 654 個近全不透明像素撞到邊界，切斷完整森林／房屋物件。故正常新完整地圖保留 46×33，既有 FS_01_VILLAGE 若必須 40×29，應在產圖最開始建立 1280×928 World Blueprint 再一起生 Ground→PAR，不要硬裁合格的完整場景。
- 視覺檢查：原新 Ground 地表、兩棟獨立精靈屋、中央水晶噴泉與森林色調協調，符合「一次生成同風格」的大方向。但未逐個源物件驗 alpha 完整、原 FS ground3 風格匹配、Game native，保留 ART HOLD。
- **下一完整單位**：直接沿用這套整圖 Ground-first→CompletePAR 兩階段製程，針對原生 1280×928 世界格一次生成同座標新 Ground＋乾淨透明 PAR；或確認 46×33 作為真正新地圖。不要做個別屋簷、樹冠選擇性遮蔽，不重開 C4～C8 微修。必要才安排 Godot 4.7.2 原生導入，不能讓碰撞設定反客為主。

---

# T-C NOW｜D1 使用者糾正後的唯一 Ground → CompletePAR 路線｜2026-11-21

**路線權威：使用者 2026-11-21 當次糾正高於全部歷史實驗。先獨立生成 GROUND.png，鎖 SHA，後以同一場景與風格生成包含所有非 Ground 物件的完整 PAR.png。不能先合成 Master 再逆向切圖，不能把 PAR 限縮為角色遮蔽區，也不應以分辨 actor-occlusion/collision 阻礙產圖。**

Drive 已直接重讀：SHARED_GAME_ASSET_GENERATION_AUTHORITY 文內 7 Map authoring split model 清楚規定 PAR / All Non-Ground Objects，包含 houses / trees / shrubs / rocks / lanterns / bridges / fences 等，不問是否遮人；Actor-Occlusion Mask optional, NOT required complete PAR。另已讀 FS_GROUND_ONLY_PIPELINE_V2_執行規格_20261030 及 R17_DIRECT_GROUND_PAR_AUTHORITY，以及現行 A11 (其中舊 Master-first 過程依這次使用者最新修正覆寫 T-C 產線方式)。

## 已實做 D1 整張 40×29 / 1280×928 兩階段產線 TEST PASS
- 新程式 godot_port/tc_factory/fs_ground_first_all_par_factory.py。獨立 CLI `ground --out ...` 僅從早已獨立的 FS A36G R4 Ground-only 源圖產出 RGB GROUND.png 並寫入 01_GROUND_LOCK.json（當時 PAR 尚不存在）；第二個 CLI `par --out ...` 必先驗 GROUND Lock SHA，才從完整 A36G R4 scene manifest 的每個非地表 source RGBA 產出透明全圖 PAR.png。禁止從混合 Master 當 Ground；完整 PNG 合成 COMPOSITE_PREVIEW.png 僅供畫面 QA。
- 原 A36G R4 192／192 件原始獨立來源全部加入 PAR（森林群 44、樹 59、灌木 83、路標等 4、房屋 2）。逐一驗 id、filename、size、source SHA；包含非阻擋岩石與灌木，**零件因角色遮擋語意被排除**。這是直接全物件 PAR 而非原 C4～C8 selective occlusion。
- 新 Godot 場景 godot_port/tc_factory/DirectGroundParPair.tscn、direct_ground_par_pair.gd、capture_direct_ground_par_native.gd，只載入兩張 PNG 全尺寸、同 [0,0]、Nearest，沒有 actor occlusion list/collider。真正 Godot 4.7.2 OpenGL3 Native 1× GPU framebuffer PASS。
- 新 .github/workflows/fs-tc-ground-first-full-par.yml 將 Ground 與 PAR 分成**兩個單獨 GitHub Actions STEP**。第一步檢查 PAR/Composite 都不存在；第二步只接受原鎖定 Ground 並驗 192/192 PAR 全物件，接著正式 Godot 4.7.2 1× 顯示。
- 最終 GitHub Actions https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44915862594 ，status=completed/conclusion=success，實測 code commit a6746663bd456776a5866ada20b457ce21c66141。
- 正式 QA D1 原 Ground 與 PAR 都 1280×928 同座標；GROUND RGB、PAR RGBA alpha extrema(0,255)。完整二階段源物件 ledger、逐項 SHA、source manifest、1× Native 截圖均在 Drive。這是**現有來源的整張產線驗證**，不是新的 AI 地圖生成／PixelLab API job。
- **私人 Google Drive D1 ZIP** https://drive.google.com/file/d/1Nh8oHQ5H2amZTe_eHBav_f_ePe-hIz2d/view ：Google provider metadata readback 8,959,782 bytes、shared=false、owner only；外層 1 ZIP + 內層 8 entries，雙層 CRC PASS；內層 ZIP SHA256 1d742d2e03d7a0a900d8aba9618fa90f237a8ae8fc081d39980079164d4733ee。長期保存於私人 Drive，Github artifact 14712270367 只暫存一天，使用者 PC 不被操作。

## 新 AI Ground 嘗試（與真正 D1 正式技術驗證嚴格分開）
- 已利用 in-chat image generation NEW 生成一張**獨立純地表 Ground**（無樹／房屋／路標），來源尺寸 1473×1068 RGB；在工作容器中只做同像素中心裁切 [96,70,1376,998] 得 1280×928 RGB Ground Art Candidate，無 resize、無反向挖物件。
- 已實際儲存僅供這次對話審查之 Ground/原來源/QA ZIP，狀態 ART_PENDING；由於圖像工具接連將後續 PAR 指令誤生成**兩張美術流程 infographic**，並非透明可編輯 PAR，已嚴格拒收。**該新 Ground 的 PAR = NOT_GENERATED，新地圖可交付雙圖 = HOLD，不能把 infographic 的假 checkmark 當成正式生成成功或假稱上傳 Drive。** 由於該 imagegen Ground candidate 是本對話生成的容器檔案、目前此工具集未提供直接從容器 bytes 上傳 owner-only Drive 的路由，尚未獲長期雲端保存 readback；它不能冒充已完整交接的 D1 Drive 包。

## 下一個大單位 D2：不是修樹／碰撞
- 直接研究/串接能按**兩次獨立原生圖像生成**輸出可編輯 PNG 的 PixelLab Ground-only → PAR-all workflow，使用同一 World Blueprint / Style Lock；如果 Pixellab paid API connector/額度未接入，保持 NOT_RUN，不猜 job ID、不扣款。
- 目標先成功交付單張獨立新 Ground + 真透明全物件 PAR，兩圖同一 32px 世界座標、相同風格／門口／樹位；User visual approval 才升級 FS_01_VILLAGE；然後 FS_01_MAZE 80×58 全圖按相同兩階段輸出。只驗 Ground/Par 源純度、對位、全物件包含、1× 全圖，不再在產圖階段逐棵樹選遮擋範圍。
- 正式 ART HOLD 未解除；任何舊 C8 的 2 house / 17 occlusion owners 等視為歷史實驗，不是現在的產線方法。務必先讀更新過的 T_C_MAP_LAUNCH_PROMPT.md。每輪 Handoff、Failure Log、Linear SHO-39、Drive WRITE→READBACK→VERIFY。

---
# T-C CURRENT | C8 兩棟真正不同的完整木造精靈屋 | 2026-11-21 TPE

**C8 實際施工與 Godot 4.7.2 1× 原生 GPU／碰撞／遮蔽 PASS；正式 FS_01_VILLAGE + FS_01_MAZE 仍 ART HOLD。** 專屬 feat/fs-pixellab-tc-map-20261121。以本段為當輪最新權威，C7/C6/C5 留在下方不刪除。

## C8 真施工內容與原始完整美術
- 新檔：godot_port/tc_factory/build_tc_village_house_c8.py、TCVillageIndependentHouseC8.tscn、capture_tc_house_c8_native.gd、.github/workflows/fs-pixellab-tc-c8.yml。保留 C7 全村 1280×928 的真 FS 樹、路燈、草地、道路、左屋，不回 VX，不更動已封版 A35／MAZE／Phase1／NAV／存讀檔。
- 重要發現：歷史 A36G R5 R2（2026-11-04）有原始獨立完整 PixelLab SINGLE GABLE 右屋來源：experiments/route_b_25d_20261031_stage16/A36G_R5_R2_HOUSE_STYLE_20261104/SOURCE_INDEPENDENT_RGBA/A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png，**SHA256 4794a89cb06029112e6581c85a47bdcf6a84b7f636e05755825a989793585206**，尺寸 256×272，完整 alpha bbox [21,23,188,220]，真獨立完整單屋頂設計，並非左屋翻轉。
- 並未重新啟動/重複付費生成 PixelLab，新 API job NOT RUN。特別警戒：R5 過去 TRUE FS GROUND/PAR 與整體原版美術 STYLE FAIL，不可把 R5 失敗的整套 Ground/PAR 拿來當成功來源。本輪只取該原始 PNG 與舊 R5 documented author-footprint，重新從 C7 已驗證的正確 Master-first 同源產線重建。
- 移除 C5 右側鏡像整棟 owner 及對應遮蔽，加入真正來源 R5 單棟完整源 PNG，在 C8 新位置 (791,371)，author foot (917,591)、屋基碰撞 [826,530,969,583]。保留左屋原始完整 source 與 2 棟真 StaticBody2D；原 C7 17 owners 數維持，因為以一棟真右屋取代原鏡像屋，而不是把兩棟疊在一起。C7 兩新樹的根部 collider 完整保留。
- 正式五圖仍 1280×928：MASTER／Authoring_GroundOnly／Authoring_CompletePAR／Runtime_FullGround／Runtime_OcclusionPAR；GroundOnly 不變，僅換完整第二屋 PAR 與 RGB Master 同源 occlusion；相對 C7 changed RGB = **26,655 pixels**，bbox 僅 [805,394,1014,591]，原森林/道路與第一棟屋保持。來源 SHA 與靜態重組 all PASS。

## 真 Godot 4.7.2 原生及私人雲端封存
- **正式 CI 成功** https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44874487911 ，GitHub status=completed/conclusion=success，tested original code commit **c08c55ae50e0cf659b71c2229877d7ebf2f6a132**。真正 Godot 4.7.2-stable official/OpenGL3 1280×928 native framebuffer：TC_C8_GODOT472_NATIVE_FULL_1X.png，以及同位置 actor uncovered 原生對照、右屋原比例 crop。
- TC_C8_GODOT_NATIVE_QA.json：原獨立屋舍2真 body、C7 原始樹根2 body、總17 source occlusion owners；七項 point-query：左屋1、全新獨立右屋1、兩樹根1/1、路燈0、道路0、屋前空地0，all PASS。真正右屋 roof 遮蔽及 uncovered A/B 同足點 ROI 差 **204px**；人物移至屋前遮蔽正確消失。這不是只拿 HTML 截圖或靜態 PNG 檢查。
- **私人正式 Drive C8 ZIP** https://drive.google.com/file/d/1xYFx6Mmx4PeSP4zMLdiYm1ZeF0J4bVbn/view ，Google provider metadata readback **82,042,571 bytes、shared=false、owner-only**。外層 GitHub artifact ZIP 1 entry、內層 **49 entries**，兩層 ZIP CRC PASS；內層 SHA256 **3acee1e1a233b68348557231946d299f36cf131973337ab0dc30718c59569a9e**。GitHub artifact id 14695765704 僅 1 日傳輸，長期只有私人 Drive；只往 GitHub 寫程式、Scene、Handoff，無操作使用者 PC。
- 全場主觀 1× 現場目測：相較 C7 左右同一棟屋鏡像，C8 兩間現在具有真正不同結構（左屋帶側邊工坊、右屋單棟），屋頂與材質同風格更自然。仍不能宣稱正式 FS 兩圖美術通過。

## Failure Log、持續 HOLD 與下個大單位
- 歷史 R5 失敗風格不能因新 C8 engine success 就洗白：R5 原版完全不同的 Ground/PAR Layer scheme 曾被使用者拒絕。C8 只復用原始 R5 完整 RGBA 物件，明確保留 ART HOLD，尚未和原始 FS Graphics/Parallaxes/ground3.png SHA ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13 做直接美術批准；True FS Ground/Par 遮蔽契約仍是正式最終 Gate。
- 原始193棵樹根部全域移動/NAV 非本次測試；MAZE 原始 1478×1064 nearest 放大到 2560×1856 的原生32px美術欠缺也尚未處理。不冒充完整 Art PASS。
- 新 PixelLab Object Creator/Create Tiles Pro/Map Workshop/Style References 本輪均 NOT RUN：僅使用歷史真來源且有 SHA，無虛構新支出／job id。
- 下一完整 C9：**正式 FS_01_VILLAGE 與原 approved ground3/par3 全圖 style-source 及語意對齊 Gate**，以已保存 Ground3/Par3 hash 及最新原生 Godot 1× 視覺核對，維持真正 original fullground copy only required occlusion，而非將 76.5% 的失敗 R5 CompletePAR 當 runtime occlusion。對重要阻斷直接換一整個來源單位，無需修葉片。之後進入 MAZE 80×58 真 native 32px Ground，而非繼續拉伸源圖；每段都 QA、Failure Log、Handoff、Drive、Linear。正式 Godot 4.7.2，絕不回 VX。

---
# T-C CURRENT | C7 真正 FS 獨立源美術整組替換 | 2026-11-21 TPE

**C7 施工/Godot 4.7.2 真實 GPU 1×、遮蔽及 source-semantic collision PASS。正式 FS_01_VILLAGE、FS_01_MAZE 仍 ART HOLD。** 專屬分支 feat/fs-pixellab-tc-map-20261121；這一節比下方歷史 C6/C5 紀錄新。

## 實際新檔與來源核對
- 程式：godot_port/tc_factory/build_tc_village_source_c7.py、TCVillageSourceC7.gd/.tscn、capture_tc_source_c7_native.gd、.github/workflows/fs-pixellab-tc-c7.yml；沒有變動原 A35、MAZE R12/R14、VX、NAV、傳送/存讀檔或 Phase1 主工程。
- 舊 C6 手工卡通樹石全部替換為五件原 FS A36G R4 完整獨立 RGBA：A36F_west_waymarker_ORIGINAL_RGBA.png、A36F_DENSE_TREE_143_RGBA.png、A36F_DENSE_TREE_071_RGBA.png、A36F_north_rock_ORIGINAL_RGBA.png、A36F_UNDERSTORY_028_RGBA.png。
- 正式原始文件在 public GitHub experiments/route_b_25d_20261031_stage16/A36G_R4_R3_6REGIONS_20261104/SOURCE_INDEPENDENT_RGBA；真 A36G_R4_SCENE_MANIFEST.json SHA256 4334c82e263fc2917ed640eb7ef433016523690a13e3104ce3bc745ee5f438dd。逐一核對 source id、filename、sha256、原尺寸、footpoint、blocking。
- 完整村落 1280×928 (40×29 tiles)，替換單位仍 8×8／256×256 [640,160,896,416]。保留 C6 Ground 及 C5 CompletePAR，重新構造 MASTER/Authoring_GroundOnly/Authoring_CompletePAR/Runtime_FullGround/Runtime_OcclusionPAR；C6 手繪藝術 0 remaining，區域外 bit-exact，C6→C7 改變 7317 RGB pixels；source registration STATIC PASS。
- 原 14 個 C5 owner + 3 個真正 C7 原始 source occluder = 17。2 棵樹 source.blocking true，窄 10×10 腳跟 root collider；路標/石塊/灌木 source.blocking false 不會被誤當成牆。原兩屋舍 body 保留。此測試並非 193 原樹完整 collision/NAV。

## Verified Godot 4.7.2 原生測試與私人存檔
- 最終 GitHub Actions run 44873943982 : https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44873943982  status=completed, conclusion=success, tested commit 38c0d3e238a2e9c6e11f496bc3beab02cacc6038。
- 真原生 GPU 1× framebuffer [1280,928]、Godot 4.7.2-stable official/opengl3。原屋碰撞 hit=(1,1)、新來源兩樹根 hit=(1,1)、路標/石/既有道路空點 hit=(0,0,0)，全部 7 項 point-query PASS。原燈柱同位置 actor 遮蔽/未遮蔽 A/B 真 GPU 改變 229 px；actor 移到前方不被擋。整村圖 TC_C7_GODOT472_NATIVE_FULL_1X.png；區域裁切與 3× nearest 預覽另附，預覽不是原生 3×。
- 正式私人 Drive C7 ZIP：https://drive.google.com/file/d/19ez90LzcrGfJGV-ezh2xmUkf-djQ4dh0/view ；Drive id 19ez90LzcrGfJGV-ezh2xmUkf-djQ4dh0，provider metadata READBACK size=78698410 bytes、shared=false、user owner only。外層 GH transfer ZIP + 內層 44 entries 兩層 CRC PASS；內層 SHA256 1d8722c6349db7b5ec98ac16b55135fa01c82733e1acd1ec8336e7b852849ca2。GitHub artifact 14694707796 僅 1 日轉送；正式圖片/QA 在私人 Drive，無操作 user's PC。

## Failure Log、ART HOLD 與下一個整體單位
- 首輪 CI run 44873757489 的 Godot 原生 7 項結果已 PASS，但之後 Python check 誤以為 Godot JSON Dictionary values 保留固定排序，使報表 assertion false-negative；改按 key 逐欄比對後 CI run 44873943982 全成功。
- C7 真原生 1× 人工審查：源自 FS 的葉片/松形/路燈/石塊遠比 C6 簡化卡通物件融入原森林，屬有效整組來源替換。然而不代表村落全圖已 ART PASS。
- Village ART HOLD：右側 C5 屋舍仍是左屋完整 source 的 mirror+nearest 變體，缺乏真正不同完整建築；歷史 193 原 tree 並未全部做完整 root/NAV。Maze ART HOLD：R12 原 1478×1064 Ground 放大到 2560×1856 的 native 32px 著色/紋理仍未重建。
- PixelLab new Map Workshop / Object Creator / Create Tiles Pro / Style References jobs 本次皆 NOT RUN。原始舊 FS 美術來源可核實，不可誤稱新 API 生成/收費。
- 下一個 C8 宏觀施工：右側一整棟真正獨立且同風格 FS 屋舍與工坊，使用已驗私人 R12 完整 A34 source 或確實接通的 PixelLab 新生成。保留 C7 全圖與兩屋碰撞骨架，完成後 full Godot 4.7.2 1× native A/B、遮蔽/碰撞、私人 Drive、Github QA+Handoff、Linear。村落主要藝術解鎖後，再完成 Maze native 32×32 Ground。小瑕疵最多兩修，重大問題換來源。

---
# T-C C6 CURRENT｜8×8 林間道路過渡區｜2026-11-21（Asia/Taipei）

**C6 已真正施工／Godot 4.7.2 1× GPU + 物件根部碰撞／條件遮蔽 PASS；最終 ART 仍 HOLD。**  
工作分支 feat/fs-pixellab-tc-map-20261121。這節為最新權威，後方 C5 內容保留歷史證據。原正式 A35 R2/R3、A35 R8 R3、MAZE R12/R14，以及事件、戰鬥、傳送、NAV、存讀檔均不修改；只用 Godot。

## 已完成工程
- 實作：godot_port/tc_factory/build_tc_village_region_c6.py、TCVillageRegionC6.gd、TCVillageRegionC6.tscn、capture_tc_region_c6_native.gd、.github/workflows/fs-pixellab-tc-c6.yml。僅 GH generator/scene/test/Handoff，真正 PNG 只存私人 Drive。
- **完整 8×8 tile／256×256 pixel 區段** [640,160,896,416]，tile origin [20,5]，保留完整 1280×928（40×29）村落和全部既有屋舍／主要森林來源。
- MASTER / Authoring_GroundOnly / Authoring_CompletePAR / Runtime_FullGround / Runtime_OcclusionPAR 在相同 XY、RGB 來源重組；C5 其餘區域 bit-exact；C6 5,823 RGB changed pixels。新增林間微地形、47 road-edge tufts、41 flowers、踏腳石。保留 C5 14 原有 owners，新增 C6 3 source independent masks，17 owners。
- 五個可重建 1× 獨立 RGBA 物件：一個森林石碑、兩種不同尺寸幼樹、兩個低石塊。其中 3 個真根部碰撞由 TC_C6_ROOT_FOOTPRINTS.json source 來；C5 2 屋舍 collider 原樣保留。**這些 1× 物件是程式手繪，不是新的 PixelLab API 正式生成。**
- ART review 的 C6 8×8 區段不是全村正式 ART PASS：新手繪幼樹/石碑 **風格過度簡化且與既有細緻森林不一致**。屬重大風格阻斷，禁止宣稱美術完成。

## WRITE → READBACK → VERIFY 已完成
- Godot Actions **[run 44872886638](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872886638)**：GitHub provider status=completed, conclusion=success；實測程式 commit **f68bfe8d216a59adc31e8191d87638ccf396bb4c**。
- 真 Godot 4.7.2 official GPU 1280×928 全村 native framebuffer：TC_C6_GODOT472_NATIVE_FULL_1X.png；依 native framebuffer 精確裁切的 TC_C6_GODOT472_NATIVE_REGION_1X.png；TC_C6_GODOT472_NATIVE_REGION_3X_REVIEW.png 是最近鄰放大的人工審查圖，不是原生 3× 截圖。
- 原生 QA TC_C6_GODOT_NATIVE_QA.json：engine=4.7.2-stable (official)，region 256×256，17 semantic owners、2 C5 house StaticBody2D、3 C6 sprite-root StaticBody2D；waystone hit=1、alder hit=1、rowan hit=1、原道路 hit=0、兩原房屋仍 hit=1。**同一足點石碑擋角與不擋角的真原生畫面差 204 pixels**；角色到石碑前方遮蔽關閉 PASS。並未驗證原 193 棵樹逐棵根部/NAV。
- **[私人 Drive C6 美術＋Godot QA ZIP](https://drive.google.com/file/d/1Hx77deDCUJe3JstjnOKJ4mm-2Uj1jXLu/view)**。Drive id 1Hx77deDCUJe3JstjnOKJ4mm-2Uj1jXLu；Google metadata readback size=69,755,419 bytes、shared=false、user owner only。外層 GH transfer ZIP 與內層 **40 files** 已雙層 ZIP CRC PASS；內層 SHA256 **425bc8bdf4c8bd156daa05a903d6b9748d91fca844e0bb69757c8aaf6729b08d**；artifact id 14694881670 保留一天，只作傳送。不使用 owner's PC。

## FAILURE LOG：含修復與真 ART 阻斷
1. 首次 native test GitHub [run 44872615732](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872615732) 失敗：腳本將 Texture2D.get_size() 的 Vector2 與 Vector2i 比較，拋錯並超時 124。已將比較改為 Vector2(1280,928)，新 CI run 44872886638 完整成功。非藝術問題。
2. **重大美術 HOLD：** C6 程式繪製的幼樹、石碑是平面像素色塊，與原本精緻 A36G/FS 森林在深度、光源、葉片有明顯不協調。這不是小細節，禁止以 5,823 px 修改或原生 QA 綠燈冒稱 Art PASS。**下一輪替換「整組」新物件源材，不在卡通葉片上打轉。**
3. 歷史 193 tree 真獨立 alpha 資產仍多在私人來源，不將 flattened PAR 裁出來假冒真 tree owner。新 3 個 1× 原生 root passed 不等於全森林 collision PASS。
4. C5 右屋依舊是原完整木屋 mirror+resize，ART HOLD。幽葉迴廊原 1478×1064 Ground nearest 拉伸至 2560×1856 舊問題仍 ART HOLD，本輪未動它。

## 下一完整 C7 施工單位
**整套 8×8 林間道路物件的同風格來源替換**。以核准的 FS 32×32、3/4 Style References 與真正獨立大樹／石物件，進行 PixelLab Object Creator / Map Workshop 真實生成或從已核准私人獨立來源直接整組替換。沒有可用 PixelLab API 時如實標示 NOT RUN，不偽造 job ID。保留這次已 PASS 的同源五圖與原生遮蔽/碰撞管線，換整組素材再跑全村真正 Godot 4.7.2 1× 與視覺 ART review。未核准前不合併 A35。

---

# T-C CURRENT｜C5 全村建築風格統一候選｜2026-11-21（Asia/Taipei）

**狀態：真正施工＋Godot 4.7.2 原生 GPU/屋舍碰撞/條件遮蔽 PASS；正式兩張地圖仍 ART HOLD。**  
**只使用指定分支：** `feat/fs-pixellab-tc-map-20261121`。不覆寫 A35 R2/R3、A35 R8 R3、Maze R12/R14 原始場景及素材；Godot，不回 VX。GitHub 只提交程式與紀錄，Drive 保存 PNG / 原始 QA ZIP，不存使用者 PC。

## C5｜當輪已交付的可觀察成果

- **新全圖 1280×928／40×29 格**：`godot_port/tc_factory/build_tc_village_style_c5.py`。從 A36G 歷史真正 PixelLab 來源 `A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png` SHA256 `964fe9bf9fe4048bc4b96fab573285cc9a2042faeefe38f1fde9501a23ccb699`，對**完整單棟** 284×259 source 作水平鏡像、Nearest resize 至 229×209 以及節制色調變化（不拼屋頂），生成一個真正獨立、可驗來源的右側木造精靈屋 candidate：`TC_C5_INDEPENDENT_WHOLE_HOUSE_RGBA.png` SHA256 `d9e970f9ce794861cd12a6a317856339e0e3e114093f64721cd9436aea0cf1c1`。
- 右側舊異風格建築 `A36F_ELF_COTTAGE_B` 的原有 PAR 位置在**獨立 C5 分支**以人工定義清除 mask 取代，新屋整棟位於 `origin=(795,390)`；保持原 C4 Ground／自然道路不變。C4 與 Production 底圖 source 並未覆寫。幾何相容完整 1280×928。
- 同源輸出 `MASTER.png`、`Authoring_GroundOnly.png`、`Authoring_CompletePAR.png`、`Runtime_FullGround.png`、`Runtime_OcclusionPAR.png`；新屋獨立 `occlusion_owners/owner_c5_whole_cottage.png`，所有舊 owner 的 RGB 依新 MASTER 重取樣，未拿錯舊 MASTER 做新屋遮蔽。STATIC compositor RGB 完全一致；修正 C4 `world_grid` metadata 誤植為 **[40,29]**。
- 右側木屋正式形狀使用整體來源之 `blocking_footprint_px` 作**幾何縮放+鏡像**得到新碰撞 `[810,535,1003,588]`，Godot Native 兩個真 `StaticBody2D` footprint；源段不偷用早已不含獨立 PNG 的舊右側屋舍。新屋周遭 PAR 以清除舊房屋及保留原始 Ground 手段過渡，消除原本嚴重的圓形青綠色屋頂與左側木造房屋錯配。
- 工程：`godot_port/tc_factory/TCVillageStyleC5.tscn`、`capture_tc_style_c5_native.gd`、`build_tc_village_style_c5.py`；CI `.github/workflows/fs-pixellab-tc-map.yml` 完全獨立於 Phase1，仍跑 C1/C4 regression，新增 C5 真 Godot 1× scene、碰撞及角色遮蔽、C4/C5 原生 A/B 比較。
- GitHub 本輪實測 commit **`d6f2ec817bd76c2fc36f395587fd3fe41d6f80a6`**（僅更動 artifact packaging，C5 工程來源與 `e5e50c447fd0b02885761133667a7a78522f5b72` 測試相同）。正式成功 [Godot Actions run 44835522347](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44835522347)，`completed/success`，包含 **Godot 4.7.2** 原生 1280×928 full framebuffer、兩棟屋舍及 path point-query。
- 原生 QA `TC_C5_GODOT_NATIVE_QA.json`：`engine=4.7.2-stable (official)`; renderer `opengl3`; `real_framebuffer=[1280,928]`; `occlusion_owners=14`; `independent_house_static_bodies=2`; `original_cottage_hit=1`; `new_harmonized_house_hit=1`; `road_open_hit=0`; `roof_behind_actor_roi_changed_pixels=204`; `front_footpoint_clear=true`; `native_C4_C5_roi_changed_px=37699`. 不將點查詢稱為完整角色導航測試。
- 真 Godot 原生 `TC_C5_VILLAGE_GODOT472_NATIVE_BEHIND_1X.png` 與 `TC_C5_VILLAGE_GODOT472_NATIVE_UNCOVERED_1X.png`；`TC_C4_C5_TWO_NATIVE_FRAMES_AB.png` 只是兩張真 Godot 1× 圖的衍生左右比較，不是單張原生 framebuffer。
- 原始 C1 / C4 已在歷史獨立私有 Drive 保存。本輪不修改舊 A35 R2/R3、Godot Phase1 系統、事件、戰鬥、傳送、存讀檔、迷宮 NAV。

## C5 私人 Drive 上傳及雙重驗證（雲端權威）

**[FS_TC_C5_WHOLE_BUILDING_HARMONIZED_VILLAGE_GODOT472_QA_PRIVATE_20261121.zip](https://drive.google.com/file/d/1rTW2Qm8qnphSlFfJ80TyTEUhEMCjp6PL/view)**。  
Drive id `1rTW2Qm8qnphSlFfJ80TyTEUhEMCjp6PL`，provider metadata readback **62,982,114 bytes、shared=false、user owner only**。外層 Github artifact ZIP CRC PASS；內層 `FS_TC_C5_PRIVATE_DRIVE_TRANSFER.zip` **47 entries，ZIP CRC PASS，SHA256 `a2294bddaf378a24cf501ee4542357ef53c536b9f566f2d0ea51275457824180`**。GitHub artifact `14677734959` 僅保留 1 天，是傳送渠道，不是最後留存位置；因 Drive 單次傳輸限制 100MB，僅封存 C5 full candidate + 全部 QA，舊 C4 封包另外留存，不重複囤積。

## C5 美術驗收及 Failure Log｜絕不假 PASS

1. **TECH PASS**：1280×928 尺寸與五圖來源、47文件寫入、兩棟屋舍原生碰撞、同位置角色屋頂遮蔽與未遮蔽的 native 1× 計算皆完成；C4→C5 真原生 37,699 changed ROI pixels。
2. **ART HOLD（重大）**：C5 已解除「圓形青綠屋頂 VS 木造屋頂」的明顯風格衝突，但兩棟木屋仍來自同一 PixelLab 歷史屋舍影像的全棟鏡像／縮放。建築獨立性與同源風格的多樣化 **尚未**符合正式封版標準。視角 3/4、光照方向與屋舍重複性需整體審美核准；不能僅因綠燈 CI 宣稱正式 FS_01_VILLAGE ART PASS。
3. **ART HOLD（森林）**：歷史 193 樹 owner 的獨立 PNG 多數只在私人 A35/R12 完整來源，公開 A36G branch 只有 3 個 SOURCE_INDEPENDENT_RGBA。現階段已在場的連續森林深度 12 strips 都是受控真來源，卻未逐樹驗證 physics/occlusion。**禁止從 flatten map 切出假樹**，只記錄限制並轉到下一個完整施工單位。
4. **ART HOLD（迷宮）**：FS_01_MAZE R12 真私人 2560×1856 工程依舊未本輪改動；其 Ground 曾由 1478×1064 NEAREST 放大，有比例及森林重複紋理問題。新 32×32 原生正規 Master 必須另開不可覆寫候選再 native QA；不能拿這次 1280×928 村落成績冒充迷宮 PASS。
5. **PIXELLAB_NEW_JOB_NOT_RUN**：本輪沒有新的 PixelLab Map Workshop / Create Tiles Pro / Object Creator / Style References API 實際生成或扣款；C5 只使用已封存的真 PixelLab 歷史來源，沒有新 job ID、seed、費用。獨立設計的完整右側房子最終應由一致 Style References 生成，而非依靠第一棟屋子的鏡像永久封版。
6. **非阻斷：老屋清除區少量剩餘植被 alpha**，影像觀察需下一輪 1× ROI 人體遮蔽評估。清除的是舊建築源區域，其餘地面完整。遵守小瑕疵最多兩修，不要在葉子上消耗整個路線。

## 下一個完整施工單位（不是重新研究）

**C6：森林／村落真正多樣化一整塊 8×8（256×256）相接區域**。鎖定 FS 核准色盤與 32×32，使用已保留 source anchors 完成原生地表、自然道路邊緣、完整不同樹型、通透前後遮蔽。優先換**整塊**自然過渡而非糾結樹葉尖角，固定同源 MASTER→四圖→真 Godot 1×+物理 QA。若 PixelLab 付費工具仍無已接入操作，不能冒稱生成；先利用原已封存且可核實的獨立素材，並把 PixelLab 真新設計列為 blocker。與 C5 同時保留完整村落候選，C6 通過後才推進 FS_01_MAZE 原生 32×32 Ground 整區段替換。所有正式 Art Seal 暫 HOLD。

---

## C4 VERIFIED｜2026-11-21 06:55 TPE｜新於以上 M1 紀錄，以下結果優先

**C4 COMMIT (HEAD AS TESTED):** `0de4ef85e1555622edeee3a078f2acbd8f18f7f9`
**C4 GODOT 4.7.2 CI:** https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44832598287 ，GitHub provider `status=completed`, `conclusion=success`，包含原生真實 GPU 全圖與遮蔽/碰撞測試。不覆寫現有正式 A35/R12/R14。
**C4 PRIVATE ART + QA ZIP:** https://drive.google.com/file/d/1O9ooTnyg-sVeWSW514u2fgQ2JRbdK1uD/view
- Drive id: `1O9ooTnyg-sVeWSW514u2fgQ2JRbdK1uD`; 實際 Google Drive readback `size=60349840`, `shared=false`，`user owner only`，私人 My Drive/root。
- 上述檔案含外層 GitHub artifact ZIP 和內層完整 art/QA ZIP；已在雲端 container 做雙層 ZIP CRC 驗證，內層 **81 項**（含 Godot 原生 screenshot）。
- GitHub Actions 暫存 transfer artifact `14677561436`（1 日保留），並非正式存檔。正式私人資產為上述 Drive。

### 本輪完整產物：Village C1 小樣 + C3/C4 全村候選

| 施工單位 | Source Master | GroundOnly | CompletePAR | Runtime FullGround | Runtime OcclusionPAR | 原生 QA |
|---|---:|---:|---:|---:|---:|---|
| C1/C2 test pilot | 544×416 | PASS 靜態 | PASS 靜態 | PASS 靜態 | PASS 靜態 | Godot **4.7.2 PASS** |
| C3/C4 `FS_01_VILLAGE` **全圖候選** | **1280×928** | PASS 靜態 | PASS 靜態 | PASS 靜態 | PASS 靜態 | Godot **4.7.2 GPU 1× PASS** |
| FS_01_MAZE 原生 R12 基準（未改動） | 2560×1856 | 舊基準 | 舊基準 | 舊基準 | 舊基準 | 既有 R12 舊測 PASS，**本輪未重測** |

- `generated/TC_GODOT_NATIVE_QA.json`: `engine=4.7.2-stable (official)`, `framebuffer_px=[544,416]`, `owners_loaded=12`, `behind_visible=1`, `front_visible=0`, `actor_roi_changed=true`。同座標 1× 真原生 A/B 實圖變化 **204px**，來源於 Godot GPU 原生 screenshot，非合成插畫。
- `generated/TC_PILOT_SOURCE_QA.json`: `world_grid=[17,13]`、`STATIC_PASS_RECOMPOSE_RGB_IDENTICAL`，房屋 1 + 真 PixelLab 連續森林 11 depth strips，沒有偽造獨立樹木 source masks。
- `generated_full/TC_PILOT_SOURCE_QA.json`: `canvas=[1280,928]`，`STATIC_PASS_RECOMPOSE_RGB_IDENTICAL`，房屋 1 + 真森林 12 depth strips，完整 Master／Ground／PAR 五圖供美術驗收。注意此 JSON 的 `world_grid=[17,13]` 目前是第一版未同步的 metadata 殘值，**全圖實際 40×29 tiles**（1280／32=40、928／32=29），列入非阻斷資料缺陷，待下一宏觀區段一併改正。
- `generated_full/TC_FULL_VILLAGE_NATIVE_QA.json`: `real_framebuffer=[1280,928]`, `gate=FULL_SCENE_GPU_1X_PASS_NOT_ART_PASS`，`owners_loaded=13`，獨立場景真正運行；`house_collision_hits=1`, `open_road_collision_hits=0`。
- 兩種解析度均使用**既有真來源**屋舍 `blocking_footprint_px=[379,389,618,454]` 創建 `StaticBody2D` + `CollisionShape2D`，Godot 原生 physics-space point-query PASS；**森林樹幹、水域和全區 path collision 未在新 T-C 證明**，不能拿房屋 PASS 冒充全圖 collision PASS。
- 程式擴展實績：`build_tc_village_full.py`, `TCVillageFullCandidate.tscn`, `capture_tc_full_village_native.gd`、`TC_PILOT_COLLISION.json`，新 CI 同時跑 C1 小樣與 C3 full 1× GPU；沒有碰傳送、存讀檔或既有 Godot Phase1 遊戲主線。
- **PixelLab 新工作：NOT RUN，沒有 API job、seed、模型、新料金。** 現成 A36G 的房屋與森林是歷史上真 PixelLab 成品；本輪新建的是組圖、美術來源遮罩、背景植被、引擎分層及驗證，而非假冒 Create Tiles Pro/Map Workshop 新模型生成。

### Visual Art Review（有讀取真 Godot 圖，非虛構 QA）

- **G2 靜態像素來源 / 1× 完圖：已 PASS TECH**，可復現。
- **G3 條件屋頂遮蔽：sample PASS TECH**，full scene GPU 載入與 footprint physical check PASS。未將森林每棵樹 alpha 冒名聲稱通過（193 tree records 的獨立素材絕大多數只在私人來源，未輸入本 GitHub T-C builder）。
- **G1/G6 美術：ART HOLD**。原生 full screenshot 視覺檢查指出右側圓形的青綠巨屋頂與左側木造屋舍材質、視角、建築語法不一致，屬**重大風格錯誤**；亦有樹冠重複/過密拼貼，不因 CI success 升 Art PASS。
- **舊 A35 R8 R3、迷宮 R12/R14 的正式美術狀態一律 ART HOLD。** T-C 全圖是獨立候選，不可自動替換正式 Godot map。
- Maze 既存真工程已成功從私人 Drive 複查來源：`FS_01_MAZE_R12_LIVE_ROAD_NAV_FULL_GODOT_PRIVATE_20261116.zip`，113,804,051 bytes、241 entries、ZIP CRC GOOD，原生 1× 圖 2560×1856；沒有覆寫或編輯，R14 較新的候選也尚未 native GPU PASS。

### 追加根因：FS_01_MAZE 原生來源 Ground 規格（已實讀私人 R12 工程）

私人 R12 ZIP `data/fs_01_maze_a36c_r7_reconciled_manifest.json` 明列：`source_ground.size=[1478,1064]`、`runtime_ground.size=[2560,1856]`、轉換為 `PIL.Image.resize NEAREST`，且 **非等比例縮放約 0.7%**，原紀錄已標註 `ART HOLD`。所有 326 個場景 PAR 由 `res://private_assets/independent_par/*.png` 裝配，保有原生腳點、資產 SHA、310 棵樹、2 屋、6 燈、1 井、7 石，原始 Godot 角色/水碰撞/導航既有通過證據不宜重做。這是讀取真 ZIP Manifest 和 scene/script 所得，不是猜測。

**施工決策**：迷宮 GROUND_ART_ROOT 必須使用 PixelLab Map Workshop/Create Tiles Pro 的連續同源 32×32 native tile 素材方案重做大區段，禁止把 1478×1064 再拉大當成合格 pixel-perfect 2560×1856；PAR 326 個真獨立源保留並先校準到新 Ground，不從整張合成圖去切假 sprites。所有全域 NAV 與原生碰撞證據保留，改動只針對美術。

### FAILURE LOG 決策與下一個「完整施工單位」

1. `TC_MAJOR_ARCHITECTURE_STYLE_CONFLICT`：**BLOCKER**。停止局部拼房；用一致的 FS 核准參考調用 PixelLab Object Creator + Style References，輸出**整棟**右側屋/工坊、獨立源 alpha 和精確 pivot，整體替換右側風格錯誤建築；禁止拼不同屋頂塊。沒有 PixelLab 工具/API 連線時不得偽稱已完成生成。
2. `TC_FOREST_ECOLOGY_CLONE`：**BLOCKER**。改用 PixelLab Create Tiles Pro 的自然草/路 32×32 與 Map Workshop 語意地形，跨區使用連續森林場景來源，避免 193 棵重複複製樹。重製整個樹林過渡區，而非反覆微調單個像素。
3. `TC_TREE_PRIVATE_ALPHA_MISSING`：森林全區的源 alpha/物理 root tree 來源不完整，獨立真文件 only 3 in public GitHub；不可由 flattened PAR 估計冒充真正 mask。下一輪改用已下載私人 FS 原生 Maze、A35 scene 的獨立 alpha，先校驗 source hashes，並在 Drive 保存。
4. `TC_FULL_WORLD_GRID_METADATA`：**non-blocking**，全圖 QA `world_grid` 舊值誤報 17×13，真尺寸 40×29；下一輪一起修正，不消耗專門美術迭代。
5. **最高下一完整單位**：完成「**整個右側屋舍與周圍 8×8 格地表／森林過渡**」同一構圖、同一來源、四圖契約＋原生角色遮蔽＋collision；接著延伸至迷宮完整森林區段，保留所有 2560×1856 既存導航工程。每項非阻斷小瑕疵最多兩修，大面積視覺錯誤換方法，不封 Art PASS。

### SHO-39 / storage

- Linear SHO-39 已實際寫入第一個 T-C 施工同步 comment，id `b87e0242-2b50-41ca-8e70-ceaebfd10825`。C4 完整成果需再更新 comment。
- GitHub code `0de4ef85...` 與此 handoff；資產在 owner-only 私人 Drive `1O9ooTny...`，GitHub temporary one-day CI artifacts 僅供傳送；**未存至使用者 PC**。

---

# Forest Symphony｜T-C 地圖美術工廠｜CURRENT HANDOFF

- Date: 2026-11-21 Asia/Taipei
- TARGET: T-C / FS_01_VILLAGE 苔光村 → FS_01_MAZE 幽葉迴廊
- STAGE: M1 完整可檢查樣本 + M2 Godot 4.7.2 原生驗證啟動
- STATUS: ACTIVE / ART_HOLD
- BRANCH: `feat/fs-pixellab-tc-map-20261121`
- PREVIOUS BRANCH HEAD: `4a2a50e3aacb3115dbb3418b6e229b8a34c430d0`
- SOURCE CODE COMMITS: `d7f2ade886fd180a3617cc40aae4a6bf62e1c359` → `ad6e8e1d2892b28875577206385cd6b550287b1c`
- ACTIVE RUN: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44830675005
- FORMAL ART SEAL: **NO**. 此工作未改變原 A35 R2/R3、FS_01_MAZE R12/R14 或任何 VX 正式來源。

## Baseline 權威、Drive Handoff

1. 正式 [T-C launch prompt](../research/launch/T_C_MAP_LAUNCH_PROMPT.md) 與 [3 experiments roadmap](../research/FS_PIXELLAB_THREE_EXPERIMENTS_ROADMAP_20261121.md)。
2. 原始 Ground3 正式身份：`Graphics/Parallaxes/ground3.png`，SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`，不是 `Overlays/ground3.png`。
3. 苔光村 A35 R8 R3 已有 187 PAR / 175 canopies，Godot 4.7.2 native + nav 舊測 PASS、藝術 HOLD。完整私人 Drive: https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view。
4. 幽葉迴廊 R12，80×58 tiles，326 complete PAR / 310 trees，來源原生 + 231 foot sweeps 舊測 PASS，藝術 HOLD。私人 Drive: https://drive.google.com/file/d/1VikZtZc0YWhHFNMjylNGXFEbN2_oW6qR/view。
5. Nov18 R14 對迷宮 PAR 樹型及 Ground 做候選修改，但 native GPU 未驗證；ART HOLD。私人 Drive Handoff: https://docs.google.com/document/d/1iibkZ2MSgwEoWZUpUKTpNUTuaDRXgpcs/edit。
6. 本輪 SOURCE：公開既有 A36G PixelLab 村落整圖來源 `experiments/route_b_25d_20261031_stage16/a36g_pixellab_r3b_20261104/` 的 `A36G_GROUND_1280x928.png`, `A36G_PAR50_RGBA_1280x928.png`, `A36G_SCENE_MANIFEST.json`，而非原 A35 私人編輯工作圖。這些來源屬歷史 PixelLab 成果，不是本輪新生成。裁切起點 (256,115)，尺寸 544×416 = 17×13 格。

## DELTA：已真正提交的程式與工作單位

- [build_tc_village_pilot.py](../../tc_factory/build_tc_village_pilot.py)：用真實 A36G Ground+PAR+Manifest 生成獨立 544×416 T-C 候選及小範圍原生像素花草變化；嚴格來源驗證，缺檔直接失敗，不生成合成偽原圖。輸出單一 MASTER、同源四層：
  - `MASTER.png`
  - `Authoring_GroundOnly.png`
  - `Authoring_CompletePAR.png`
  - `Runtime_FullGround.png`
  - `Runtime_OcclusionPAR.png`
  - `occlusion_owners/owner_*.png`、兩項 JSON QA/owner manifests
- [TCVillagePilot.tscn](../../tc_factory/TCVillagePilot.tscn) + [TCVillagePilot.gd](../../tc_factory/TCVillagePilot.gd)：專屬非正式地圖場景，544×416，Nearest，Ground 與精靈屋/樹冠分離，依測試角色足點條件顯示局部遮蔽物。測試角色為佔位畫像，**不是**已認可的 FS 正式角色。
- [test_tc_village_native.gd](../../tc_factory/test_tc_village_native.gd)：使用 Godot 4.7.2，啟動場景並採集真正 SubViewport 1× 幀，移動測試角色驗證 roof/canopy 的前後遮蔽，原始 framebuffer PNG 和執行 JSON。
- [.github/workflows/fs-pixellab-tc-map.yml](../../../.github/workflows/fs-pixellab-tc-map.yml)：在獨立 T-C 分支由 GitHub Linux runner 完成 Pillow source/layer 產出、Godot 4.7.2 原生匯入、xvfb GPU screenshot QA、生成 ZIP 供私人 Drive 轉存。原專案正式 main/Phase1 CI 不變。

## QA 最新、不得提前升版

| Gate | Status | 實際證據 |
|---|---|---|
| T-C source generator | **PASS，GitHub runner** | run 44830675005 build step completed success，實際圖像保存在 runner 暫存空間 |
| Godot 4.7.2 editor import | **PASS，GitHub runner** | 同 run，editor import step completed success |
| Godot 原生畫面、測試角色遮蔽 | **NOT YET VERIFIED** | CI 正在執行時記錄；需取得獨立 framebuffer PNG 及 JSON，驗證才可 PASS |
| collision/footpoint source-independent semantic QA | **HOLD** | 目前測試中 actor 不是完整 CharacterBody2D 碰撞驗證，且 owner masks 暫採 combined PAR crop |
| overall FS art / house / forest ecological diversity | **ART HOLD** | 完整小樣尚待原生 1× 整圖 review，不能把可輸出等於藝術可接受 |
| FS_01_VILLAGE/MAZE full-map artist approval | **NOT RUN** | 這是 17×13 pilot，不是兩張全圖交付 |
| PixelLab Create Tiles Pro / Map Workshop / Object Creator new job | **NOT RUN** | 本輪重用 A36G 已有 PixelLab image，沒有呼叫新的 API、無 job ID / seed / actual charge |
| Drive new candidate / native QA | **PENDING VERIFIED UPLOAD** | CI 原始 art 和 QA 必須轉存 owner-only Drive，並讀回 size/shared |

## FAILURE LOG（不得假 PASS）

- `TC_SOURCE_OWNER_MASK_OVERLAP` **BLOCKER**：第一版為各獨立 source owner bbox 在已合成的 CompletePAR 取 alpha，可能含其它樹/屋物件的重疊像素。改善方法：下一版使用同名 `SOURCE_INDEPENDENT_RGBA` 的每個 owner 真正獨立 alpha/mask，再依 frozen MASTER 取 RGB，不從整張 CompletePAR 估計個體。
- `TC_OLD_ART_STILL_HOLD` **BLOCKER**：歷史 A36G 的森林與建築先前未取得 ART PASS；此 pilot **不能**消除既有視覺缺陷。換方法需重新生成具有統一材質的完整屋舍和自然森林 Master。
- `TC_PIXELLAB_NEW_JOB_UNAVAILABLE` **DEPENDENCY**：目前可用 connector 未曝露 PixelLab 直接生圖/Map Workshop 操作，本輪只可合法重用 A36G 現成來源。若日後接通，記錄精確 job/model/seed/cost 並封存私人 Drive。
- `TC_DRIVE_TRANSFER` **PENDING**：GitHub Actions 1 天暫存 artifact 僅為轉送用，必須轉私人 Drive 並驗證，不當正式雲端來源。

## NEXT MACRO UNIT

**先完成 1 個真的可審核「完整視覺場景」**：通過 Native QA 後，使用每個獨立屋頂/樹冠 alpha 重建遮蔽所有權；在私人 Drive 保存全部五圖＋兩張 1× 原生幀與 Source Manifest；做第一輪 1× 視覺評分，若整體樣式不合格換完整樹型/屋舍素材，不對像素尖角連改超過兩次。接著擴大至苔光村真實 1280×928 完整區段，再依同源四層及風格規則延伸至幽葉迴廊的 2560×1856 完整森林區段。**禁止碰傳送、存讀檔或 NAV 重構。**

## P0 Storage/Sync

- GitHub 只保存公開程式、QA 計畫、Manifest/Handoff 文本；二進位生成圖片及真正 source QA 必須在私人 Google Drive 保存。
- 不在使用者 PC 建立工程/素材庫。GitHub CI runner 是暫時工作空間。
- 本輪 GitHub first write OK，CI build+editor import readback OK。Drive WRITE/READBACK 與 Linear SHO-39 本輪操作須另行驗證後填寫。
