# Forest Symphony R15｜美術品質 × 正確 PAR 的根因研究及新流程 Authority｜2026-10-28

## 00 判定
**R15 已驗證：從完整高品質美術母圖出發，在不重拼Tileset、不重繪Ground、不縮小畫布的前提下，Godot可以保留原1280×928全圖100% RGB原樣，並以獨立前景Mask做有深度的角色遮擋；但「全場PAR語義邊界完美自動擷取」尚未解決，User Art Gate F HOLD。**

此Authority取代R13 whole-tile-alpha救援和R14只有2種地板tile重複拼裝作為*正式量產候選*。R12/13/14保存作比較實驗，不修改其SHA和正式K4封版。

## 01 兩條失敗路線有量化證據
1. R12從高品質完整Master直接SAM2分物件，原PAR Alpha 233,875px（19.7% canvas），但漏樹枝／燈柱／欄杆等，模型「prompt點通過」仍可能將旁邊小灌木、攤位、地板連帶選進，不能等於藝術通過。
2. R13以32x32格整格補Alpha擴到684,860px（57.65% canvas），其中 **43,437px 與R12自身登記為Ground-only的樓梯／橋面／地面排除區域重疊**。這不是使用者逐像素gold mask，卻是工程內規互相矛盾的可重現數字。
3. R14真正Godot場景分層可做到完整圖=BASE+PAR 0px diff、floor-only sample 5格 PAR=0，但底圖221個地面tile只用**2種地板素材**，畫面重複、接縫及細細殘留線，舊候選Sprite部分自身含泥土/草邊。顯示「工具能分層」不等於「整體美術達ground3等級」。
4. 「圖層精確」不能由單一技術門檻宣稱：SHA/同源RGB/提示點/四角camera都可能PASS而人的畫面觀察失敗。

## 02 已研究可用2026年技術與限制
### Qwen-Image-Layered (CVPR 2026)
官方：https://github.com/QwenLM/Qwen-Image-Layered
權重：https://huggingface.co/Qwen/Qwen-Image-Layered
模型直接分解一張完整圖為N層RGBA，並可匯出PSD。強項是真正 Image-to-layers（非只有抠背景）。模型20B，官方建議先以約640px測試，也明確**不能以文字指定單獨圖層語義**；輸出較低解析度RGBA及可能重新繪製的RGB不得直接當FS 1280x928最後美術，**只能產生候選α與物件分組**，需同原畫像素校正/上色。使用者AMD RX6700XT 12GB不適合直接標準本機跑20B模型；fal雲端2026網頁標示約US$0.05/張（可能變動、需帳號金鑰/外部傳輸）。**本輪尚未真正執行Qwen，不宣稱適合像素遊戲已實證。**

### Meta SAM 3 / 3.1 (2025～2026)
官網：https://github.com/facebookresearch/sam3
SAM 3可用短文字/示例發現所有同類物件，如tree、lantern、railing等；比R12純手動box更適合全場**漏件檢查**，但它不理解FS玩家遮擋/深度規則；對樹根/地板接觸處仍要本地精修。官方環境主要NVIDIA CUDA及PyTorch；R15 WSL CPU目前仍只有已裝的SAM2.1，沒有把SAM3當實測完成。

### LayerDiffuse 與 PixelART
LayerDiffuse：https://github.com/lllyasviel/LayerDiffuse
能從生成階段產透明立體素材，適合「針對精緻完整地圖的局部新增物件／區塊」，不等於憑空維持整張高品質一致性。
PixelART論文：https://arxiv.org/abs/2609.22789 （2026年9月），像素空間直接做Image-to-layer，作者稱相對Qwen模型低記憶體與延遲，對我們值得關注，但本次**未找到可確認本機可用的官方發布checkpoint**，不可列成已可操作/已經驗證。

## 03 R15第一輪真比較（新實驗）
以現成較精緻`R12_NEW_ELF_VILLAGE_001/MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png`原生1280x928為唯一Ground Master，SHA256 `eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80`。Windows WSL/SAM2.1 CPU局部原生解析度ROI預測，保留source RGBA而非複製生成RGB：
- 大樹TREE_LEFT_MAJOR：Alpha 20,536px；原R13相關 mask 26,286px；4正例、6反例Prompt Gate PASS，放大仍有側面灌木/花紋混入，**Art HOLD**。
- 房屋CAFE_RED_HOUSE：Alpha 27,613px；原R13 16,979px；Prompt Gate PASS，但左側攤位/底部地面或花盆局部被包含，**Art HOLD**。
- 狹長路燈LAMP_FOUNTAIN_NW：Alpha 1,851px；原R13 3,856px；正例3點中有1點漏，**Prompt FAIL**，不當正式PAR。
- 這三組各有精緻Master/粉紅R13舊過遮/青色R15新SAM2示意三聯圖。模型快但不能光靠提示PASS宣稱輪廓精確，工程輸出需記錄個別ROI、點、缺點、污染告警和藝術HOLD。
- R15 圖層無使用R13 tileSnap，每張原圖SourceRGB pixel exact。先不試圖全景召回，避免再發生只因面積多就冒充完整。

## 04 R15第二輪真Godot全尺寸融合測試
可編輯Godot Project：`R15_MULTISCALE_MASK_RESEARCH_20261028/godot_art_first/ArtFirstVillage.tscn`
- `MASTER` = R12原始精緻全圖，1280x928，**不使用任何草地Tileset拼貼**。
- `PAR` = 上面3個局部原生RGBA候選、以自身Alpha bounding box裁切後各自成為Godot Sprite2D，保留世界座標及各物件腳底Y深度。
- `ACTOR` = FS原32px角色Sprite，在大樹後方與前方兩站位（Godot z依位置）。
- Godot 4.7.2 OpenGL真GPU生成5張1280x928：R15_MASTER、R15_PAR、R15_COMPOSITE、R15_ACTOR_BACK、R15_ACTOR_FRONT。
- 逐像素核對：R12原 Master vs Godot `R15_MASTER.png` **0像素差異**；Godot原Master vs `COMPOSITE`（加三張原圖SourceRGBA前景、無人物）**0像素差異**。原完整美術保留，地面在Stage1不必重畫。PAR3 Alpha合計50,000像素、都是原圖RGB；沒有草/路 tile nodes。
- 原生Godot人物站樹後的測試角色全被樹遮住（沒有對原圖新增可見像素），站樹前角色局部出現在畫面。
- 這解決的是「不必因分層犧牲畫面整體風格」和「源圖+局部分層同一世界座標」，**尚未解決「3個MASK是否完美、全村所有物件是否完整」**。尤其路燈點檢FAIL和大樹邊界雜物，絕不可Seal。

## 05 新Authority｜Source-Locked Master-First Layer Proposal + Native Mask QA
從這輪開始，所有完整地圖主製作改採：

**A. 全場Master Art First**：先做原生尺寸高豐富度整體美術（村莊40x29=1280x928），畫面有自然流動的道路、完整且協調的建築、植被、材質、光影，對照ground3，先ART Gate A人眼候選。**禁用以少量32px草磚拼滿全畫布**冒充完整美術。原Master單一權威RGB不變、不縮放、不模糊。

**B. Semantic Discovery**：先建立完整 Object Register：屋、樹、枝/根、燈柱、欄杆、扶手、獨立雕像、圍籬、石壁上緣、小物，給世界足點與 z/footprint；Qwen-Image-Layered作RGB圖層候選、SAM3作全場文字/範例物件發現、SAM2處理細部ROI。模型只是提案，不是最終透明圖。工具沒用過就標未測。

**C. Pixel-exact alpha refinement**：在1280x928原Master解析度對每個物件ROI多輪正反點和閉合輪廓校正，只輸出**Alpha mask**，再用Master同座標填回每個前景Sprite的RGB。32px格只負責foot/occlusion排程，不直接把tile全部Alpha=255；不能「寧多不寧少」使地面覆蓋角色。每個物件做輪廓小圖，尤其所有綠樹細枝與欄杆1px細線要對齊、不能有地板棕色拖尾。原Ground仍是完整Master，樹接地最下方的32格例外。陰影貼地部分屬地面／影層，不能隨整棵樹上PAR。

**D. Scene Composer**：Godot/Tiled只管理圖層，不生成原始Master。輸出FULL Ground（完整Master原樣）、PAR RGBA透明局部物件、Light/Shadow、water animation frames和Collision。動態PAR各物件用世界foot depth；Ground default pass except水/洞/實體Footprint。全圖唯一公共xy來源，不能R12像舊圖資源Key`ground3`偷換素材。

**E. Strict Dual Gate**：
- VISUAL：完整美術比ground3；32px角色比例；屋/路完整；材質細線不得浮起或違反透視。
- MASK：所有候選物件有正面／背面對照；Ground-only手工負區PAR Alpha=0；樹冠完整；燈/欄每個可遮擋元素抽取完整；任何物件局部把別的攤位、灌木、地面帶進來→FAIL。人工目視/使用者驗收後才過Art F。
- SOURCE：Master原RGB SHA exact，所有PAR不透明RGB源圖逐像素exact。
- ENGINE：Godot FULL vs MASTER pixel diff0；static/dynamic per-object mask z actors front/back native GoDot；VX原生Game.exe走動、NPC、camera多區、光影/動水、collision和角色景深。
- MEMORY：只裁Alpha bbox并保留世界座標，避免52張1280x928全幅透明素材造成32bit VX崩潰。
- Archive：每個FAIL保留前後對比與規則更新，同步Drive/GitHub/Linear，正式FS其他分支不動。

**Fail-closed 關鍵定義：**RGBA source pixel correctness + Godot compositor 0px diff只通過Layer Pipeline TECH，絕不代表Semantic Completeness或人眼Art PASS。

## 06 需要的下一個關鍵試驗
- 不在未授權的情況把私人FS原圖上傳外部模型，或付費叫fal Qwen-Image-Layered。確認帳戶與來源資料處理規範後，先對R12**局部高密度區塊**做Qwen多層拆分，測試Mask提案，以SAM2 native 1px ROI補邊；比較SAM2 baseline/tree+lamp+railing+stairs所需的負例修正工作量，才決定採哪種工具。
- Qwen 640輸出只能用作layer proposals，永遠不得縮回1280後當正式源圖Alpha而不精修。
- 測每個Mask對人工定義Ground-only polygon的false positive=0，並對完整已標記目標做漏件檢查；整張大地圖如總有一處明顯漏物/誤收地面→ART HOLD。
- 若一張圖的物件多，拆成重疊ROI batches做物件registry和形狀修正，不是直接拆成少數4層然後宣稱全村完整。
- 最終以USER的精靈村參考高精度藝術和遮擋前後原生VX畫面做唯一正式Gate F。

## 07 已有輸出與研究檔
`R15_MULTISCALE_MASK_RESEARCH_20261028/R15_R12_R13_R14_FAILURE_DIAGNOSTICS.json`
`R15_MULTISCALE_MASK_RESEARCH_20261028/R15_R13_PAR_OVER_FLOOR_EXCLUSION_AUDIT.png`
`R15_MULTISCALE_MASK_RESEARCH_20261028/R15_ROI_SAM2_PILOT_GATE.json`
`R15_MULTISCALE_MASK_RESEARCH_20261028/*_SOURCE_R13_VS_R15.png`
`R15_MULTISCALE_MASK_RESEARCH_20261028/godot_art_first/project.godot`
`R15_MULTISCALE_MASK_RESEARCH_20261028/godot_art_first/ArtFirstVillage.tscn`
`R15_MULTISCALE_MASK_RESEARCH_20261028/godot_art_first/exported/R15_*.png`
`R15_MULTISCALE_MASK_RESEARCH_20261028/R15_GODOT_ART_FIRST_GATE.json`
`R15_MULTISCALE_MASK_RESEARCH_20261028/R15_ART_FIRST_GODOT_4PANEL.png`

**本次真正解決的範圍 = 把美術完整母圖與可編輯前景層共存，不再因圖層而切割繪畫／退回低豐富度tile。全自動精準PAR仍然不可稱已解決。**