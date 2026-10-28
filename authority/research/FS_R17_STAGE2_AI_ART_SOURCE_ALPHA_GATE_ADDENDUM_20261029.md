# R17 Stage 2 Authority Addendum｜AI 美術來源與透明圖層驗收｜2026-10-29

**這是對 `R17_GROUND_PAR_DUAL_GATE_AUTHORITY.md` 的強制補充；不取代 Stage 1 雙 Gate。**

## 新增禁止事項 R17-ARTSOURCE-01
**圖片生成器畫出「有標籤的 Ground/PAR/Godot 繪製測試」的展示板，不等於交付了那些真正遊戲使用的圖層。**
- 必須從其生成影像擷取出實際像素 Master，並以檔案尺寸、SHA、RGB、Alpha及原生 Godot 實測證明，不能用生成圖內自帶的 `PASS/0 pixels` 文字當證據。
- 棋盤格圖案只是「畫出來的白灰棋盤」，**不等於 PNG 有真正 Alpha 0**；真透明必須實際檢查 `mode=RGBA`、Alpha=0、無地面 RGB 污染。
- Master即使取出544×416仍可能截斷屋頂與樹；完整屋/3完整樹是Art硬條件，缺失即HOLD，不得以「精緻」抵銷。
- 原圖是生成展示板的一部分，必須如實記錄來源，不能說是以分層生成器原生輸出的MASTER與PAR。
- 分開生成所有Alpha元件目前尚未被證實穩定，禁止拿B的事後SAM2分割替代A/C的原生生成實測。

## 新增 Gate R17-ALPHA-02｜各物件分離及污染測試
1. `Master.png`與`Godot MASTER/FULL.png`同一像素RGB差0，只是**座標技術門檻**。
2. `PAR.png`對每個opaque pixel的RGB必與Master原點相同；不能用棋盤格畫出的「PAR」直接當真透明。
3. 每個物件獨立Alpha及足點；清點所有立體前景小物件，保留未切的陰影／立體元素名單。
4. 針對三種地面負例：石板路中心、樓梯面、橋面，記所有PAR Alpha交集並列出來源物件；任何大於0須呈報語義衝突，**不能為了報表PASS直接把可疑像素抹掉**。
5. 窄欄杆/燈柱正反提示任一失敗：保留FAIL和候選圖，重做ROI或局部GrabCut，不得強行PASS。
6. 人物樹前後是Godot與FS native的分開測試。Godot技術證據**不可**宣稱原生RPG Maker VX已通過。
7. 完整美術與完整PAR任何一項未人眼通過，維持 `ART HOLD + PAR HOLD + FINAL SEAL NO`。

## R17 Stage2 重現負例
- 新Master `544×416`、SHA256 `0a4d77cf98a1e4d33f3eb045c486c46da7fe71755751cc86fd7cbdd2857b2863`，來自生成展示板的Master面板裁切，並不是原生多層生成。
- 11前景候選，SAM2/GrabCut正反seed 9／11（2段圍欄FAIL）。
- MARKET_STALL與中央道路暫標Ground-only區域**81像素衝突**，尚未排除是ROI過大還是攤位本體，維持HOLD。
- Godot4.7.2 Master vs original 0 RGB pixel、FULL vs original 0 RGB pixel、PAR vs candidate 0 RGBA pixel，Actor後方0可見差／前方271可見像素，只是 TECH PASS。
- 來源精緻度提升，不代表屋頂、三棵完整樹、全部欄杆/光影已達標。

**與 FS 原K4封版隔離，正式Gate F仍不通過。**
