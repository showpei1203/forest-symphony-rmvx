# Forest Symphony｜正式修正 Authority：直接產生 GROUND + PAR 雙圖層
日期：2026-10-29｜版本：R17-DIRECT-LAYERS-v1.0｜Priority: HIGH｜原 FS/K4 SEALED 不變

## 0. 使用者最終決定（優先於歷來R8～R17任何衝突段落）
**「妳的 PAR 跟 Ground 可以正確生成就不必再去裁切 PAR；我最後會把 PAR+Ground 合併成新的 Ground，然後用上 PAR，再用腳本由我自己設置通行度。」**
本 Authority 直接取代「先產完整 Master、事後 SAM2／GrabCut 逆切 PAR、再編譯 Collision」作為**正式生產程序**。前述R12-R17的分割測試保留為研究及負例，禁止作為今後默認流程。

## 1. 唯二必要正式輸出（相同世界座標、寬高、起點）
### A. `GROUND.png`
- **地面直接生成**，不是由有房屋、樹與立體物件的成品畫面抹除/inpaint後冒充的「乾淨地面」。
- 連續高密度豐富美術，地表、草地、土路/石板路、花與小草等**貼地素材**，小石子、平面階梯/橋面、接地/環境陰影。
- 依使用者先前規則：每顆樹**最底部接地樹幹的1格32×32**歸Ground；其他完整樹冠、樹枝、非接地樹幹歸PAR。接地一格應在場景作者階段自行置入地面來源，不能把生成完成的PAR事後裁掉來補救。需對同一棵樹使用明確世界座標及Contact Foot。
- 不能已經有房屋、完整樹冠、立體欄杆/路燈烘焙在地面，否則再疊PAR等於Ground污染。
- 純圖層原生設計；不得用少量（例如兩種）32px Tile拼滿冒充精緻美術。符合ground3級細節、3/4 topdown透視、1× pixel crisp。
### B. `PAR.png`
- **從一開始即獨立透明生成、可編輯的立體物件層**，整幅畫布與Ground同尺寸、同座標，真正PNG RGBA／透明Alpha。
- 包含完整的房屋、非接地樹幹、樹枝/樹冠、燈柱、路燈、欄杆/柵欄/橋側扶手、招牌、立體雕飾、夠高會遮擋角色的小植物。用相同風格/透視/尺寸/光向。
- 不包含草地、路面、平面花草、貼地陰影、橋面/平面台階或任何整格地板。
- 1px細輪廓與細樹枝、欄杆不可省略；透明背景真Alpha=0，不接受生成圖片畫出的棋盤格作為透明。
- 物件的**底部與Ground現有陰影/接地格直接接合**。不用事後把PAR原圖大規模裁切、外接矩形crop、從已完成整圖抽遮罩；若生成原件不合格，退回**重新生成該層/物件**，而不是靠反向切像素補救。
- Ground和PAR可以各自由同一場景 Blueprint / Style Lock 的分層輸出生成；不須人為用已完成Master逆推。

## 2. 使用者自己的最終執行流程（不由助手搶做）
```text
GROUND.png（單獨自然地面） + PAR.png（單獨立體透明前景）
                  ↓ [使用者自行合成]
             NEW_GROUND.png（含全部物件之完整視覺場景）
                  ↓ [使用者遊戲內套入 PAR.png 作遮擋]
                FS RPG Maker VX
                  ↓ [使用者本人操作現有腳本]
              設定地圖通行度 / Collision
```
本專案不再以「我幫你生成Collision／設定Passability」為必要交付/前置條件。除非日後使用者另行指定，禁止自動更改`Map.rvdata`、`Scripts.rvdata`、formal VX collision和通行度。
`COMPOSITE_PREVIEW.png`僅作QA的臨時合成驗證圖，不應替代兩個必要輸出，也不是要使用者下載來覆蓋Ground。

## 3. 只驗證使用者要的兩張圖（不偷加工作）
### G-GROUND 內容Gate
1. Ground必須是**原生獨立創作/分層**，未事先包含PAR的完整物件。
2. 草路/地表高精度連續自然，無平鋪痕/細白線/模糊/重影，整體美術比對精靈村參考。
3. 樹底接地1格及地面陰影已合理接合，不把整棵樹都畫進Ground。
### G-PAR 內容Gate
1. PNG真正有透明Alpha 0，且有實際非透明前景；像素邊界無棋盤格/泥土或草地污染。
2. 房屋、樹冠、路燈、欄杆等**完整、不被裁斷**，尤其1px細線連續。
3. 物件位置與地表、接地陰影、樹幹底部、路口/水邊自然吻合；層內不帶貼地平面和Ground大面積。
### G-PAIR 配對Gate
1. **嚴格同尺寸同座標，1×像素不縮放**；暫用544×416 benchmark，最終依任務為ground3大尺寸1280×928。
2. 可在測試器內算`Preview = alpha_composite(Ground, PAR)`，檢查接地、物件比例與真透明度；原圖Source Provenance必須獨立，不能「Ground就是完整Master」導致遮擋無論對錯合成都相同。
3. 遮罩完整度仍需目視；純數字pixel diff=0不能宣稱美術/分層正確。
4. 沒有獨立原生兩圖時=>`DIRECT_DUAL_LAYER_NOT_PRODUCED`，**不可拿Master+事後切PAR充數**。
5. 若某物件錯誤：回到分層素材生成/同場景共同美術調整，而不是嘗試繼續切割已獨立生成的PAR。
### 非必要
不再以Godot actor前後景、VX Game.exe、地圖通行度、Collision編譯、遮罩SAM2/GrabCut完整度作每次必備Gate；只有使用者明確另要求時可做後續驗證。
Godot/Tiled可當獨立圖層作者、輸出與QA工具；不代表它們必須承擔遊戲通行度或原生VX整合。

## 4. R14/R17重新判定（不能否認舊實驗）
- R14 `GODOT_BASE + GODOT_PAR`：確實從獨立GROUND／PAR源節點導出，是真分層**技術參照**，但使用221個只有2種地面來源tile，**美術嚴重不足，ART FAIL**。
- R17 Stage2 `MASTER_STAGE2_NEW_GENERATED + 11 source masks`：完整美術更漂亮，但Master已包含房屋/立體物件，PAR是後切的；**DIRECT_PAIR_PROVENANCE FAIL**。之前Godot RGB=0與前後景測試仍為真實技術證據，但不能被認定符合這次的交付規格。
- A Pair Generation圖解展示板是RGB、無透明Alpha，**不是PAR**；確實需要另外生成真的`GROUND.png`和`PAR.png`才能進Pair Gate。
- **當前尚未有符合雙圖層生成＋高品質美術的合格樣本，誠實標 HOLD。**

## 5. 後續施工唯一目標
在同一份自然完整場景設計下，**從創作階段直接產出獨立Ground地面與PAR立體透明源**，先小型544×416完整高密度街角、獨立兩圖Art F後放大到1280×928。若先畫成完整Master再倒推PAR，屬於R17之前負例，不接受為正式交付。

驗收結果必須明列：`GROUND_LAYER_PASS`／`PAR_LAYER_PASS`／`PAIR_ALIGNMENT_PASS`；每項分開回報，只有三項同時PASS才可交付，未有人眼確認不得Formal Seal。

本 Authority 由使用者明確更正生效：**Ground和PAR直接分別生成；使用者自行合成完整Ground並自行設定通行度。**