# FS Master-First Semantic Layer Split | R0 實驗紀錄 | 2026-10-27

狀態：**RESEARCH CANDIDATE / TECH PARTIAL PASS / ART HOLD / VX NOT RUN**
施工目錄：E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027
本測試全程使用隔離資料夾；正式 FS K4/N5、SEALED Scripts.rvdata、其他地圖工程均唯讀，絕不視為已封版成果。

## 目標與實際方式
以原始精美整圖先行（Master），借助語義分割切出屋、樹等 PAR pixel ownership。
未被 PAR 包含者暫時保留在 Ground Known；PAR 後面看不到的地面另外補繪為 Ground Complete。最後從 Ground + PAR 同原點重組。
在 544×416 原像素尺寸，不重採樣不糊邊，保留人工美術優先、source-exclusive Ground 規則。

## 來源
- E:/GameAssetToolLab_20261023/FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE/Graphics/Parallaxes/SCENE21.png
- SHA256 4414db2f8d0be840a336679b44e5a549c0ad693d1e165250cc0d2f660e730
- 僅私人驗證，授權未確認不公開圖像/完整素材。
- WSL /home/user/sam2, SAM2.1 Hiera Small, 176MB checkpoint；CPU 本輪可運行。
- FS runtime 實際 scripts: 145 HK - Ultimate Overlay Mapping; 146 Animated Parallax v2.1; 342 ISS ParaPassa; 470 FS LegacyScripts SafetyPatch v1.0.14。
- 影像工具：Python3.14, PyTorch2.13, OpenCV5.0, Pillow12.3, sam2。

## R0 實測結果
- 三個 guided box：house, left_tree, right_tree，總 PAR union 30,770 px / 全圖 13.59675%，非完整 PAR！
- 初輪三個模型分數：約 0.929 / 0.817 / 0.934；分數不能等同藝術或語義正確。
- 原始像素回貼，RECOMPOSE 與 MASTER 全 RGBA 0 差異，僅代表數學重組；不是分割正確證據。
- 1px mask 位移破壞負向測試，發現 1,444 px 差異；可作對位 Gate。
- OpenCV Telea 補出整片嚴重模糊、塗抹狀 Ground，ART FAIL，絕不能拿來當最終 Ground。
- 分割右樹時誤收下方一大塊灌木，且物件可能相連，連通區 QA 未檢出：是語義 gate 必須人工獨立查驗的證據。
- Ground Telea fill 邊緣內梯度標準差/外側來源環帶約 0.0948，紋理流失嚴重，僅診斷性數值。
- PAR 仍有大量未切出的物件，如其他樹、岩塊、花草、外圍石階；不能宣稱完整率達標。
- 碰撞、角色前後景排序、光/影輸出、動態地表、正式 VX 均未測試。

## R1 右樹精修
- 正例：(465,155) 樹冠、(468,204) 樹幹；反例：(480,263) 非本樹的下方灌木；縮小 box=(419,101,526,252)。
- Variant 1 模型分數 0.914；mask 7482 pixels；相對原始 mask 移除 4428 像素、新增 222。
- 視覺上誤選面積減少，但仍有局部花灌木被收入；不得將其稱為已驗收正確遮罩。
- 三種 mask 變體與疊合圖儲存本地研究資料夾，供不同 prompt 策略比對。

## 重要發現與下階段研究次序
1. 嚴守原像素：對母圖做 non-destructive mask extraction，原始可見屋/樹 alpha，不以重繪改壞本體。分割要結合 point negative、box、semantic footprint 與人眼確認。
2. Ground 唯一所有權：垂直物件 PAR 不准夾帶原草土草皮；附著苔藤例外要獨立列證，連通不等於語義正確。
3. 補圖要分成 **Protected Visible Ground**（原始畫面每像素不動）與 **Unknown Underpaint**（由 AI/LaMa/PatchMatch 補繪）。後者不應改寫可見地表。
4. 下階段對同一 Ground-hole Mask 比較 A LaMa(大遮擋)、B PatchMatch(可重用紋理)、C AI 局部 Inpaint(場景語義、需 pixel-crisp Gate)。OpenCV Telea 只當 FAIL baseline。
5. 取得乾淨 Mask 與 Underpaint 之後再試不同角色腳點的 PAR 深度 mask 或 Actor-aware z-sort。既有 FS_MapDepthPar_20261024 有 Godot GPU 測試可重用。
6. 引擎輸出需照原生檔名契約：Graphics/Parallaxes/groundX(_1...N).png + Overlays/ParX.png + LightX.jpg + ShadowX.jpg；ISS ParaPassa 用第三圖層 tile id 設通行，Ground 預設可走但水/洞等例外。
7. 需要測試：遮罩語義完整率、地表接縫藝術品質（1x/2x）、腳點、角色前後景、scroll/loop、原生 VX、原始開關 201-205，另檢查 source license。
8. 本輪 fail-closed：即使 reconstruction 0 diff，semantic ART=HOLD，Ground fill=FAIL，VX=NOT RUN，禁止標正式成功。

## 可重跑
- master_split_pilot.py 從 SCENE21 拆出 3 個候選遮罩、Ground/PAR、定量 metrics 與 1px 負向測試。
- audit_mask_semantics.py 記錄每個遮罩的分離 component 及填補區紋理損失；此工具**不能**取代獨立語義判斷。
- refine_right_tree.py 使用 point+box positive/negative prompts 精修誤切的樹。
- probe_env.py 只讀確認獨立模型環境。
- 第一輪輸出在 SCENE21_GUIDED_SAM2_CANDIDATE/。
- 任何驗收結論務必以 PILOT_METRICS.json、MASK_SEMANTIC_QA.json、right_tree_refinement_v2.json 和 1x 原圖 A/B 視覺為準。