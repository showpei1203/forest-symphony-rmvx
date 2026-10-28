# FS R17 Stage 2｜全新精靈村高細節 Master + 原位11物件 PAR候選｜2026-10-29

**真實結果：新Master已產生、SAM2/GrabCut提議11個局部前景、Godot4.7.2 真GPU五類544×416輸出全部同源座標TECH PASS；ART Gate／PAR語義Gate HOLD；正式原生RPG VX尚未測／沒有Formal Seal。**

## 0. 主要進展與不允許的冒充
本輪使用生成式美術模型產生**全新精靈村展示圖**（非R12/R16 Master裁片），再從該展示圖真正的 Master 面板裁出原生**544×416 PNG**作圖像來源，檔名`MASTER_STAGE2_NEW_GENERATED.png` SHA256 `0a4d77cf98a1e4d33f3eb045c486c46da7fe71755751cc86fd7cbdd2857b2863`。此圖為真正新生成的視覺藝術，但它是**從示意展示板裁取的美術候選，並非具有可編輯原生分層的生成器輸出**。展示板中畫出的 Ground、透明 PAR、角色測試及文字數字都是生成模型畫的**示意**，不是以那些宣傳圖內的文字稱PASS。這輪所有實際測試只以裁出之新Master作權威。

相比前輪Stage1：**這次不是拿R12既有完整畫面裁圖**；精緻自然連續的草地/石路/建築/攤位/橋欄都出現在此新場景，而不是拿R14兩種草磚拼整張場景。
但新Master仍有**房頂與多棵樹受到畫布邊框截斷、細線密度／比例與ground3原始參考尚未由使用者審核**，因此不能視為完成真正全新美術Gate A。

## 1. R1真本機SAM2.1
`r17_stage2_new_master_sam2.py`在WSL本機SAM2.1 small/CPU對544×416新圖跑5物件 source-lock 原RGB遮罩：
- BLUE_ROOF_HOUSE（房屋）alpha 36,769：正負seed PASS。
- TREE_LARGE_EAST alpha 14,106：Seed PASS，樹底世界32px接地格為例外，不把整列樹幹裁掉。
- TREE_WEST_EDGE alpha 9,352：Seed PASS，但樹冠在畫框外，不能聲稱完整樹。
- LAMP_CENTRAL alpha 1,576：Seed PASS。
- BRIDGE_RAILING alpha 3,719：漏一個正向seed，FAIL。不允許把失敗遮罩封版。
- 合併候選source RGB精確、alpha 65,522；`R17_STAGE2_PAR_PINK_QA.png`顯示屋與樹都有對上位置，這不是輪廓完整證明。
- 禁止任何32px整格alpha補漏；所有不透明PAR RGB從唯一Master相同座標複製，絕不重畫素材RGB。

## 2. R2真SAM2+GrabCut擴物件與修補
`r17_stage2_sam2_rescue_v2.py`擴充6種小物件：
- TREE_MIDDLE_GARDEN alpha6,045，Seed PASS；
- LAMP_WEST alpha1,882，Seed PASS；
- MARKET_STALL alpha6,312，Seed PASS但候選罩混入中央道路Ground-only候選區域81px，**地面污染或Source-ROI衝突，HOLD**；
- FENCE_LEFT_STEPS alpha2,497，Seed PASS；
- FENCE_NORTH_EAST alpha2,164，Seed **FAIL**；
- FENCE_SOUTH_EAST alpha1,296，Seed **FAIL**。
對 R1 BRIDGE_RAILING 使用OpenCV GrabCut 5次／點前後景方式補救，原3719→新版3989像素，正反seed均不漏且受限面積，**局部候選Accept**，仍非人眼精度PASS。
合計11獨立原位RGBA物件，合併 PAR **85,530個非透明Alpha像素**；原十一件中9件目前seed檢查通過，2件FAIL；0個嚴格人體遮擋真Gold遮罩驗收。純道路負向指定區中央道路和MARKET_STALL候選交集81px，下方階梯/上方道路0。禁止為了過Gate直接把81像素打掉，可能為攤位本體，先人工檢查 ROI 是不是也需調整。
- 現有新Master部分樹/屋本身裁畫框，因此**11個候選不意味完整街角11物件、3完整樹屋全部達標**。其他欄杆/上方燈/細枝可能仍漏。

## 3. 全新Godot Native GPU測試
使用Windows已裝 **Godot 4.7.2 stable + AMD RX6700XT OpenGL Compatibility**；建原生可編輯 `R17_STAGE2_NEW_ART_20261029/godot_project/Stage2Village.tscn`，不是假原生工程。Scene：
- `MASTER`一份544×416新圖Source；
- `PAR`十一件同原圖原座標Alpha的Sprite2D，均Alpha bbox裁切以減少32位元VX移植成本，世界foot-y作Z；
- `ACTOR`FS既有32×32角色做前後depth比較。
- `export.gd`真GPU五類：`R17_STAGE2_MASTER.png`、`PAR.png`、`FULL.png`、`ACTOR_BACK.png`、`ACTOR_FRONT.png`，全部**544×416**，非同時宣稱FS原生Game.exe。
- `r17_stage2_godot_final_gate.py`真比對：新Master vs Godot MASTER RGB差**0px**；vs Godot FULL RGB差**0px**；Godot PAR vs本機源RGD候選全部RGBA差**0px**。真人物站在樹冠完全遮擋處：BACK相對FULL差0px（角色全被遮），FRONT相對FULL+271可見像素，Godot視覺深度可運作。
- **這只是技術正確性。**原圖本身Ground已烘焙全部元素，因此可疊PAR無人時自然Source RGB差0，而不能推出11件語義正確。R17仍嚴守Art/Mask雙硬Gate，未跑VX並非退步而是避免把不通過的成品編入正式FS。

## 4. 真正查出的問題（不要對數字視而不見）
- Image generator輸出的**圖解面板不能當真實位圖分層**。當作完整美術來源可以，但其展示板上的Ground-only/PAR各自圖與原Master非同一RGBA序列，不得按圖上標籤直接封版。
- Master取圖裁切使屋與樹冠在地圖邊緣不完整；必須將整個高密度街角構圖與32px演員比例做重新相機框景，不可拿這版講「3完整樹的最終美術」。
- SAM2對細線欄杆仍有2個提示點Gate FAIL，GrabCut只修復1段橋欄杆。
- MARKET_STALL多罩81px已知Ground-only道路負向候選；可能是真正攤位底部/候選測試ROI畫太近，必須單件與環境驗收而不能無腦去除。
- 1× pixel crispness/地面接觸融合/局部長細線需要人眼；`R17_STAGE2_DETAIL_2X_4_PANEL.png`與11物件粉紅罩供審核。
- 用戶指定的完整獨立Ground plate+原生獨立物件直接生成仍未實作完整成功；目前是**新Master-first、SAM2事後分割**，不是宣稱AI Pair Generator已能直接兩張精準生成。

## 5. 正式下一階段施工（R17 Stage3）
1. 以新候選證明美術方向，但**不切到屋樹**：新Master生成時指定完整屋和三顆各異樹、欄杆/路燈、彎路全在畫框，No text/no board/only exact art scene。參考User ground3自然度與像素密度，經人眼Gate A。
2. 真正AI A 配對生成：嘗試給生圖模型做**同一構圖的獨立透明元件**。若只產出拼貼展示板、不含Alpha則明確FAIL，而不是以白底/棋盤格示意自稱Alpha。
3. 具體全場漏件表：每張房屋/樹木/燈/欄杆物件一件一個sourceRgba+Alpha，Seed負例與完整輪廓Gold補審。讓Market Stall 81px及兩段Fence失敗修掉，全部不能用Alpha整格填。
4. 以Godot同源場景導出Master完整Ground、PAR、SHADOW/LIGHT、Collision並到VX Game.exe檢驗Actor前後景；未人眼Art F不能Seal。
5. 任何失敗保持原件與更新規則、Drive/GitHub、Linear SHO34、CURRENT_HANDOFF，不碰K4封版。

**R17 Stage2候選技術結果 PASS，但Art Gate F / PAR Gate F HOLD，正式FS原生VX NOT_RUN。**