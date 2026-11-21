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
