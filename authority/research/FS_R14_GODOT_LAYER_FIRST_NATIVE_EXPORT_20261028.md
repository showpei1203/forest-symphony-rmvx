# FS R14｜Godot 4.7.2 Layer-First PAR 專案實作與比較｜2026-10-28

## 評估結論
**R14：實際 Godot 4.7.2 GPU 場景編輯／圖層匯出 TECH PASS；新全尺寸村莊美術與 FS 原生 RGSS2 遊戲整合 ART/FORMAL HOLD。**

R13 以32px整格保守補漏，卻把部分平面地板納入 PAR，造成前景遮住人物。這不是修一個SAM2 threshold就能消失的：**事後拆已完成大圖本身就是高風險工作**。R14決定改做「地面與獨立立體素材分別存在同一個Godot編輯場景，由單一世界座標導出不同圖層」，避免PAR取得Ground tile。**不能把這個試驗偷換成「Godot能自動把R12完美大圖拆對」的宣稱。**

## 實際工具與來源
- 遠端Windows電腦已安裝 Godot **4.7.2 stable**，用其真實OpenGL 3.3 Compatibility + AMD RX 6700 XT圖形渲染成功取得PNG；本次沒有操作/安裝Tiled，因在PATH／Program Files未找到Tiled可執行檔。
- Pilot素材來源：本機既有`E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023\source`的**單一透明元件**，含草地tile、道路tile、房屋96×160、tree_A/tree_B、conifer/broadleaf、post_lantern、fence_horizontal、market_stall、sign/rock等。這批是**未封版舊候選來源**，不是新AI生成的高精緻ground3級美術；正式source pack授權、品控要後續確認。
- 為了測試「真正分層」，此試驗不使用R12/R13已合成的Master，也不將整格舊地圖切成PAR。

## 可在Godot直接編輯的結構
`godot_project/LayeredPilot.tscn`是Godot原生Scene；不是只輸出PNG。
節點數：
- `GROUND` 229 個：221個32×32草/路面、7個平面tuft和1低矮石塊；完全不在PAR。
- `CONTACT` 4個：四組樹根/樹幹**只有底部接地32px tile**，同一獨立src PNG依底格拆分；其余樹冠/上段樹幹保留在PAR。每組full alpha能由base＋par無損還原，0重疊／0遺失。
- `PAR` 13個獨立Sprite2D：房屋、攤位、4棵樹冠、3路燈、3柵欄及招牌，半透明像素來源是獨立物件素材，而不是整張母圖像素/格子。
- `ACTOR` 1個：實際FS角色32×32 frame，以Y足點z_index在樹前/後繪製。
- 所有Node2D、座標、素材相對路徑寫在editable `.tscn`，可在Godot UI逐一改位置/關閉/替換材質。源佈局`SCENE_LAYER_MANIFEST.json`。

## Godot真渲染輸出
用`godot_project/export.gd`同一Scene切換分層可見狀態，真OpenGL渲染後輸出`godot_project/exported/GODOT_*.png`：
- `GODOT_BASE.png` = floor + contact root。
- `GODOT_PAR.png` = only independent raised objects, alpha transparent（不是黑底PNG，黑色只是圖片檢視器透明區底色）。
- `GODOT_FULL.png` = floor + contact + raised objects，全圖544×416，FS完整Ground概念。
- `GODOT_ACTOR_BACK.png`與`GODOT_ACTOR_FRONT.png` = Godot內人物z=185/230，物件depth以foot world Y計算，展示角色在樹木前後（**此處只驗證Godot，不是FS VX runtime**）。
- `R14_GODOT_REAL_RENDER_4PANEL.png`和`R14_REAL_ACTOR_FRONT_BACK.png`實際renderer截圖並排供檢驗。

## 數學與美術Gate
`verify_godot_layer_export.py`實際驗證：
- `Godot FULL` 與 `Pillow.alpha_composite(Godot BASE, Godot PAR)`：**RGB逐像素差異數=0**、channel最大差=0。
- 5個明確沒有立體物件的地面32px tiles：（0,0）、（8,12）、（9,12）、（16,12）、（14,0），每格 Godot PAR alpha非零像素皆 **0**。
- Scene清單的所有221個grass/path sprite都是`GROUND`，沒有任何一個在`PAR`。
- PAR alpha非透明面積 52,785像素；不是「自動提取面積越大越好」的成功標準。
- 4顆樹的CROWN＋CONTACT source Alpha嚴格守恆；整棵樹不會因過了foot y就橫向截掉。
- 不在人物背後地面混入整格Ground tile是**結構上避免**，不依賴SAM2 segmentation confidence。

## 仍有問題不能假裝解決
1. **素材本身可能污染**：部分舊sprite PNG樹冠周圍含褐色泥土／貼地背景像素，雖Ground tile完全不在PAR，舊src assets若本身含地面仍可能使角色被泥土邊緣遮住。正式入庫需要從生成開始要求**透明物件，只保留立體物**，並採取Alpha/contour局部審核。
2. R14是**544×416 (17×13) 小型分層架構樣機**，尚未做到ground3的40×29大地圖尺寸、美術精緻度、豐富度與AI生成自有同風格素材的穩定性。
3. 在Godot內的actor back/front只是Godot z order，不代表RGSS2/Tankentai/HK正式腳本已驗收；若要FS直接匯入，需確認 VX `OverlayMap` 靜態Par永遠上蓋和 `Dynamic PAR` 按腳底分深度不同的系統是否可正確串接，還要做Game.exe原生測試。
4. 只有Ground/CONTACT/PAR/ACTOR四類；Light、Shadow、Loop Ground（水/雲）未進行本輪實驗。不能宣稱使用者正式scene完成。
5. R13不能以粗暴整格填Alpha補漏：32px只能決定人所在的occlusion語義，真正PAR應從獨立的前景物件透明asset產生；若某條路燈素材本身夾地板，**退件重製該asset**，不能塞回整格。

## 解決方案建議（正式Authority候選）
**先生成獨立而乾淨的透明物件元件**（房屋、樹冠+接地幹、燈柱、欄杆、橋扶手、裝飾），全部都與底圖同風格、同透視、同像素密度。交由Godot/Tiled所代表的**場景作者工具**擺放並賦予語義：Layer=GROUND, CONTACT, PAR, LIGHT, SHADOW, WATER_LOOP，從**同一場景**匯出：
- `GROUND_full.png`包含所有物件，不移除任何內容，符合使用者舊parallax mapping。
- `PAR_RGBA.png`僅取 raised object sprite（No Ground tiles）；必要時依角色腳底世界Y分物件z。
- `Collision Grid`獨立對每個footprint設定，地面默認可走。
- 需要明確Gate = layer source PNG alpha, source provenance, no floor tile nodes in PAR, alpha zero on selected floor-only test cells, complete composite difference=0px, clean actor front/back, original FS VX smoke.
**Godot/Tiled本身不會生出高品質原始素材；繪圖引擎生成乾淨獨立資產才是正式美術成敗點。**

## 步驟和重現
1. `python prepare_layer_sources.py`：獨立透明素材、4棵樹嚴格CONTACT/PAR Alpha拆分、角色原始來源。
2. `python make_editable_scene.py`：生成原生Editable Godot 4 `LayeredPilot.tscn`、221 地面tile與所有物件 Sprite2D節點。
3. 打開已安裝`E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`，`Import` Godot project資料夾。
4. 指令：`Godot_v4.7.2-stable_win64_console.exe --editor --headless --path <project> --quit`匯入素材；`Godot_v4.7.2-stable_win64_console.exe --path <project> --script res://export.gd`真GPU匯出。注意**不要用 --headless** 當真GPU匯出，R14曾因等待`RenderingServer.frame_post_draw`在Headless時卡住，後改成有視窗GPU模式與固定process frames後正常。
5. `python verify_godot_layer_export.py`，Fail Closed Composite0px+floor alpha0+tree root conservation。
6. 只在Art Gate通過後拿到原生FS VX進行runtime smoke和大地圖Loop/Light/Shadow。

## 已驗證輸出
`R14_GODOT_EXPORT_GATE.json`狀態`technical_export_Pass=true`，Godot 5張實際GPU匯出PNG，4格Review、前後遮擋比對和可編輯原生Godot工程全部可使用。

**正式FS K4 SEALED與並行地圖工作未修改，R12/R13候選仍保留對照。**