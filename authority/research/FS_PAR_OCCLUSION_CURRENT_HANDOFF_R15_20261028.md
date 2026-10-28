# FS R15 CURRENT_HANDOFF｜Master-first Art + Layer Proposal Architecture｜2026-10-28

R15 樣機已完成技術雙驗，**美術Master完整保留，模型候選遮罩還不夠好，Art F HOLD**。

根因量化：R13 PAR684860 alpha px，與R12自身定為Ground-only的九類階梯/橋面/地面排除多邊形重疊43437px（非使用者gold，仍足以顯示內規互斥）；R14地面221格卻只有2種地面tile，分層雖正確卻無法達ground3美術。

研究2026模型：Qwen-Image-Layered（CVPR2026，20B Image→multiRGBA、約640首試，不能指定每層語義，未實跑）、Meta SAM3/3.1（文字搜全場同類物件，未實跑）、LayerDiffuse（從生成開始提供透明元件，未實跑）、PixelART 2026-09 paper（輕量image-to-layer論文，權重/可用性未證）。AMD RX6700XT 12GB無法直接當Qwen full 20B標準GPU。本輪不對外上傳私人Master，不叫第三方付費API。

已實測 SAM2.1 CPU 本機 1280×928原圖ROI：
- TREE_LEFT_MAJOR 20536px、人工6負點/4正點Gate PASS，仍夾旁邊灌木，ART HOLD。
- CAFE_RED_HOUSE 27613px、prompt Gate PASS，仍包含攤位/植栽，ART HOLD。
- LAMP_FOUNTAIN_NW 1851px 1/3正點漏，Prompt FAIL。
有3張原圖／R13紅色誤收／R15青色ROI候選對照圖與JSON原始prompt完整保存。

Godot4.7.2真GPU 1280×928 `R15_MULTISCALE_MASK_RESEARCH_20261028/godot_art_first`可編輯工程，MASTER原始R12漂亮完整圖（絕無tile節點），PAR三張原圖同色crop遮罩，ACTOR FS原32角色。Godot真輸出 R15_MASTER/PAR/COMPOSITE/ACTOR_BACK/ACTOR_FRONT，原圖vsGodot MASTER 0 RGB px差異，Godot MASTER vs COMPOSITE 0差，樹後人物完全遮，前方可見；這個是真正保留整體美術與編輯圖層共存，但不代表全場PAR或其輪廓Art通過。R15_GODOT_ART_FIRST_GATE.json 全數有註記。

正式新Authority位於`R15_LAYER_DECOMPOSITION_RESEARCH_AUTHORITY.md`；施工順序：
1. FULL原生場景Master Art（ground3級）且人眼品質；
2. Qwen Layered / SAM3 提議圖層/所有類別物件，SAM2 native ROI細化，無外部模型授權不可自行上傳；
3. **只用模型Alpha，透明PAR RGB每像素嚴格來自原Master**，32x32只作語義深度/Collision，不得整格Alpha；
4. Godot Layer Composer，full unchanged Ground/independentPAR/masks z/Light Shadow/Water loop，Native VX Game.exe實測；
5. 逐物件驗證漏遮/地板誤收/樹完整/欄杆1px，全部User Art F後才正式Seal。
完整技術程式`r15_compare_r12_r13_r14.py`、`r15_highres_roi_sam2_pilot.py`、`r15_prepare_art_first_godot.py`、`r15_godot_art_first_gate.py`。不得改動其他FS branch/formal封版。