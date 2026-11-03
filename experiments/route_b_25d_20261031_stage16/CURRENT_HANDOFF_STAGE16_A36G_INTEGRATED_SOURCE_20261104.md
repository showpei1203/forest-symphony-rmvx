# FS Forest Symphony｜A36G 正式交接：完整建築與整片林群生成
日期：2026-11-04
文件性質：新施工策略權威 Handoff；**不是工程驗收通過聲明**
交接狀態：**A36F R1 是最後一個已完成原生 VX/Godot 驗證的工程候選；美術 FAIL；A36G 尚未實際產出可用 Ground/PAR，不得宣稱完成。**
Formal Seal：**NO**

## 0. 先讀這段：使用者真正的目標
目標是開發 Forest Symphony（RPG Maker VX / RGSS2）遊戲內真正可運作的 1280×928 精靈村地圖，不是生成一張單幅漂亮概念圖。
必須具有：
- Ground 與 PAR 真實可分層、像素對齊、可在 VX 中使用；32×32 每格，40×29。
- 真實角色足點、遮蔽、碰撞、道路可通行；保留實機及 Godot 驗證流程。
- 美術達到原始 FS 地圖（參照 ground3、原始 Drive 參考）之豐富度：細緻草花、非制式道路、密林包圍精靈村。
- **整體生成，不再用零件拼一棟房子或堆一棵棵樹冒充完整森林。**
- 使用者已明確批評先前只生概念圖而不改工程，對這種重複行為感到沮喪。不要再以說明、prompt 或純展示圖取代實作。

## 1. 真實工程基準與來源（先驗證，絕不覆寫）
最後已驗證工程：A36F R1，並非通過美術驗收。
- 遠端來源工作樹：E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103
- 遠端 VX 原生：E:\FS_STAGE16_A36F_ELF_FOREST_VX_NATIVE_20261103
- 遠端 Godot：E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103\GODOT_A36F_ELF_FOREST_40x29
- 前一版原樣保留：E:\FS_STAGE16_A36E_VILLAGE_ART_20261102
- A36F Scene Manifest：A36F_SCENE_MANIFEST.json
- A36F Ground：A36F_GROUND_GRASS_FLOWERS_ROAD_1280x928.png
- A36F PAR：A36F_PAR50_RGBA_1280x928.png
- A36F 真合成：A36F_TRUE_GROUND_PLUS_PAR_1280x928.png
- A36F 工程 QA：A36F_NATIVE_GPU_STAGE_GATE_QA.json、A36F_NATIVE_VX_COLD_REBUILD_QA.json
- 上述檔案 2026-11-04 已重新確認仍在遠端。
- 資料：1280×928；468 個 alpha PAR 物件（222 棵樹、240 灌木、2 棟屋、4 地標）；233 阻擋格，927/927 可通行格連通。
- 實測：VX 11 組、22 張截圖，Map050 成功，468 物件載入，無 RGSS modal；Godot 6 全圖＋6 裁切圖，RGB 最大誤差 1、超過 1 的像素 0；獨立冷重建 3,875/3,875 SHA256 一致。
- **上述 PASS 是程式工程，不是美術 PASS。**

A36F Drive：
https://drive.google.com/drive/folders/1iEJ6YMeJR5cBZabvJ_CwfQDmlnK0X_8o
完整可重建工程 ZIP：
https://drive.google.com/file/d/1LKg_Xnxl-KImk20_HnGMPKZvqVA9Wjy_/view
前後比較：
https://drive.google.com/file/d/1IdmdWI7nb1GMEf09gOEpCrxGL0h8Ddlu/view
A36F 舊交接：
https://github.com/showpei1203/forest-symphony-rmvx/blob/main/experiments/route_b_25d_20261031_stage16/CURRENT_HANDOFF_STAGE16_A36F_20261103.md

## 2. 使用者剛剛正式否決的 A36F 作法
**左屋＋側邊工坊：美術 FAIL。** 先用右屋母體，再程式描繪加上工坊側廂、屋瓦、煙囪、窗戶，結果有顯著拼貼／縫合感。A36F 舊 Handoff 若稱其已是「一棟完整變體」，只能視為工程素材描述，**不可當成美術已成功的證明**。
**森林：美術 FAIL。** 雖然有 222 棵樹與 65 新林下物件，也改良草花道路，但仍是太多獨立拼貼素材，未形成自然包圍村落的連續密林；森林應超出畫布，讓玩家看見的只是大森林中的小小村落。
**錯誤生成回應：FAIL。** A36F 以後在對話中生成的兩張精靈村「全景概念圖」只是單張彩色圖，沒有 alpha 獨立物件、Scene Manifest、碰撞、Ground/PAR、VX/Godot 證據。**它們不是 A36G 工程、未通過任何工程 Gate，嚴禁當作完成或可直接匯入遊戲。**

## 3. A36G 新製作方法（必須改變的核心）
### 3A. 左屋：完整建築一次生成
- 先分析 A36E 右屋原始風格、使用者建築素材和正確地圖位置、比例、角色足點。
- 以 **同一個完整主屋＋側工坊** 為單一生成主體，整體設計屋頂交會、木石材、入口、窗、透視、光照；不是先生成房子再貼上工坊。
- 生成結果必須成為 **整棟可用的獨立透明 RGBA 像素素材**，包含完整外輪廓及無瑕邊緣。可以先做統一外觀生成再進行真正的原件分離／重建底部缺失區域，但不能用概念圖裁切貼在舊草地上就自稱完成。
- 主屋與工坊須是同棟建築，風格統一；右屋仍是同一精靈村母體風格的簡化款。不要只是複製右屋變色。
- 按實際佔地更新足點、屋頂遮擋、門口通行、碰撞。不能先沿用舊 238×236/舊格網就宣稱契合。
- **驗收 Gate HOUSE：** 個別來源 RGBA、透明邊界、合成前後圖、房門正面與背後 VX 演員截圖、入口走動測試；美術不自然則 FAIL。

### 3B. 森林：先設計林群面積，再完整生成每一大片
- 第一件事是依現有道路／村屋可通行區域建立 **Scene Blueprint + Forest Region Polygons**，定義連續北方、左方、右方、南方林群及清出來的村中心、道路、房前空間。
- **按林群的計畫面積與形狀生成「整片」高精度森林 RGBA**，包含彼此連貫的樹冠、陰影、樹幹、灌叢、林下環境；不再逐株散放。森林區塊可在畫布外生成、允許負 X/Y，並延伸超過右／下邊界，實際編譯時裁切到 1280×928。
- 多個完整林群的交界要有自然連接與連續遮蔽，不得露出矩形拼貼線、重複樹型、直線裁切。可有前後景群層，但每片必須真正美術完整。
- 地面路徑繼續通往畫面邊緣，但樹林與樹冠要延伸出畫布，營造「村在密林」而非「樹木擺在草地上」。
- 設計主要林區時保留道路與角色可通行清廊。碰撞鎖定林群的樹幹／根部占地，不可把整片樹冠或整張群圖都當阻擋。
- **驗收 Gate FOREST：** 每片大林群獨立 RGBA、Polygon/位置/尺寸、接縫 QA、可裁切超畫布、根部碰撞與遮蔽；通行區聯通、角色走到林冠後正確遮擋。

### 3C. Ground／PAR 不是任意兩張漂亮圖
- 目標延續 FS 原始設計：完整可見場景先確立，Ground 維持自然可行走底圖；PAR 只取需要顯示在角色上方的部分，與 Ground 精準對位。不可把「整張成品圖」冒充 Ground+PAR。
- 優先保留可分離之生成來源（房屋整體、林群整體、地表）；若從完整合成圖切 PAR，必須修補 Ground 被遮住的位置，讓人物行走在後面時沒有洞、邊界、雙影或錯位。
- 每個 PAR 大群至少記錄 source PNG、alpha、scene position、bbox、foot/collision、遮擋範圍、來源 hash，逐格以 32×32 規則核對。
- Ground 地表必須有較多自然草、花、小裸土、碎石與不同密度植被群落；道路維持連通，寬窄不一、草侵入邊緣，不能只是平滑曲線或機械碎邊。
- **新的生圖工具只用在「能變成真正可編譯來源素材」的階段**。若工具只輸出一張不可分層全景，這是外觀方向參考，不可當交付物。

## 4. A36G 最短有效施工順序（不是再寫施工清單就停止）
1. 從完整 A36F Source、Scene Manifest、遮蔽與碰撞資料做冷讀取，原版不修改。
2. 新建獨立 A36G 工作樹，建立實際林群 polygons、區塊尺寸、超畫布坐標，以及左屋完整尺寸與入口位置。
3. **先完成完整左屋工坊 RGBA，實際在 A36F Ground+PAR 中替換並輸出 before/after；自己檢查是否仍有拼貼感，不過則重做。**
4. **再完成 1 片面積計算後的大林群原生 RGBA，超出畫布邊界、原生合成、檢查接縫／林冠／樹根／通行。** 首片 PASS 才批量擴到全村，不要急著生成整張圖騙自己。
5. 按「一片成功林群」的實際手法完整生出北／西／東／南各林群，維持道路與入口可讀性。
6. 重新編譯 **真 Ground、alpha PAR、真合成、Collision/Foot Scene Manifest**；絕不可只交一張全景圖。
7. 真正 VX Game.exe 角色/遮蔽/通行測試，Godot 真 GPU 像素對照，獨立冷重建，逐檔 SHA。
8. 每階段 before/after、來源 RGBA、失敗與修正、原生截圖、Handoff 同步到 Drive/GitHub。**沒有原生 Gate PASS 就不可寫 PASS；美術未經使用者確認就 Formal Seal NO。**

## 5. 交付物／QA Fail-Closed
必須包含：
- 原始/生成來源素材（完整房屋獨立 RGBA、每片完整林群獨立 RGBA）與 SHA256。
- Ground、PAR、完整真合成三張 1280×928 PNG。
- Forest Region Blueprint（含完整群多邊形與可超畫布 bounding boxes）、Scene Manifest、Collision/Foot／Occlusion Masks。
- native VX 可開啟測試工程、原生 544×416 截圖、角色前後遮蔽與通行驗證。
- Godot 工程、native GPU 截圖及 Ground+PAR pixel QA。
- Failure Log、before/after、ZIP、完整 SHA／解壓 QA、CURRENT_HANDOFF。
- **藝術驗收和引擎驗收必須分開**；「畫面好看」與「碰撞可用」是兩道不同 Gate。

## 6. 不要再犯
- 不得直接重複生成全景圖、把圖貼給使用者就說下一輪會開始工程。
- 不得將完整場景截圖、靜態概念圖稱為 Ground/PAR source。
- 不得用拼貼小零件冒充完整工坊；不得以增加個別樹的數量冒充連續林群。
- 不得清除 A36F／A36E 或原始 FS 正式封版資料。
- 不要反覆請使用者上傳遠端已有的素材或重複要求施工批准；使用者已經授權直接依此施工。
- 用繁體中文回報 **真實做過的事項、可點開的產物、QA 是否通過**，不要重複套話。

## 7. 下一個對話的直接續接指令
「依 A36G 完整建築／整片林群 Handoff，直接從已驗證 A36F R1 來源開始實際施工。先在獨立 A36G 工作樹生出一棟整體生成、非拼貼的左屋＋工坊透明 RGBA，與 A36F Ground/PAR 真合成並檢查美術；接著按 Region Blueprint 完整生成第一片超出畫布的連續大林群 RGBA，真分層且保持通行與遮擋。每項先交付原始 PNG＋before/after＋QA，再推進全場；A36F 不覆寫，不要再只生概念圖或口頭說明。」 

## 8. 權威資料鏈
- A36F GitHub Handoff：https://github.com/showpei1203/forest-symphony-rmvx/blob/main/experiments/route_b_25d_20261031_stage16/CURRENT_HANDOFF_STAGE16_A36F_20261103.md
- A36F Drive ZIP：https://drive.google.com/file/d/1LKg_Xnxl-KImk20_HnGMPKZvqVA9Wjy_/view
- A36F Ground：https://drive.google.com/file/d/14F0yLL1B2BnC3uD1nL6KD4uK43j10LO-/view
- A36F PAR：https://drive.google.com/file/d/1U9jsvaGF9N6tW5bQjTc0NvcL65sQG1Bz/view
- A36F 實際合成：https://drive.google.com/file/d/1Ch8W_TAS2M2KHk4dIPOG8ZsipwFo-oYU/view
- A36F Failure Log：https://github.com/showpei1203/forest-symphony-rmvx/blob/main/experiments/route_b_25d_20261031_stage16/STAGE16_A36F_FAILURE_LOG_20261103.md
- FS Canonical Art Authority：https://github.com/showpei1203/forest-symphony-rmvx/blob/main/authority/FS_CANONICAL_DRIVE_ART_REFERENCES_A36C_20261102.md

**結論：A36F 工程 PASS，但 A36F 美術 FAIL；A36G 尚無可用工程輸出。下一步不是再生整張圖，而是先做「真正完整的整棟建築 RGBA」和「真正完整的整片林群 RGBA」，落到 Ground/PAR 工程並驗證。**
