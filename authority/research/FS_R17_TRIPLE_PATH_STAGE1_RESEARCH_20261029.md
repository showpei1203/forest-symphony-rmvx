# Forest Symphony｜R17 三流程 Ground / PAR 雙目標受控實驗｜2026-10-29

**狀態：R17 Stage 1 已真的執行 B/C，同條544×416場景，Godot4.7.2真GPU渲染；兩法圖層座標 TECH PASS；美術 Gate / 全場 PAR Semantic Accuracy HOLD；A直接雙生成尚未執行，不作假。**

## 1. 重新定義 R17 Authority
見 `R17_GROUND_PAR_DUAL_GATE_AUTHORITY.md`：11項禁令及美術／遮擋／原生雙軌 Gate。必須同時擁有美術高品質、純PAR、原生角色前後；85分是必要非充分，硬閘任何FAIL都不得PASS。**32×32只做邏輯格與Collision，不許整格填Alpha；Ground Full包含全部物件，PAR只含真正立體遮擋源像素。**低精度tile重複或事後mask過量都不算成功。

## 2. 相同544×416場景設定與限制
取前期已建立、較高細節的`R12_NEW_ELF_VILLAGE_001/MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png`原始1280×928，SHA256 `eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80`，截取基準**[x155,y175,width544,height416]**原圖像素，絕對不縮放、不重畫、沒有新增Tileset拼貼。檔案 `R17_REFERENCE_R12_HIGH_DETAIL_CROP.png`。

注意：**這張裁剪圖沒有滿足最終R17高密度街角全部美術必備條件**（尤其3棵完整且不同的樹、完整主屋、欄杆），所以只是同源精度／渲染流程實驗，不是同題三條藝術品質競賽的Final candidate。

## 3. B：實際原圖 Master-first / Source-locked alpha
檔案：`B_MASTER_FIRST/GROUND_FULL.png`、`PAR_TRANSPARENT.png`、`PAR_SOURCE_EXACT_CANDIDATE.png`、`PAR_PINK_COVERAGE_QA.png`、各自5物件透明`PAR_OBJECT_*.png`與`OBJECT_REGISTER.json`。
5個source object候選：`TREE_LEFT_MAJOR`大樹、`LAMP_FOUNTAIN_NW`路燈（兩個R16 GrabCut接受版）、`A04_CENTER_BLUE_INN`房屋、`A12_FOUNTAIN_STATUE`與`A16_LEFT_GARDEN`（R12既有候選mask）。所有非透明RGB皆從Master相同座標拷回。
- 物件合成PAR alpha=**53,064像素**，無32px整格補Alpha。
- 樹依原32px世界格接地樹幹底格例外處理。
- 對照R12先前人工暫標為Ground-only的多邊形排除區域，本輪交集Alpha=0；但這**不是用戶認可逐像素Gold**，不可說全圖無地面誤收。
- 五物件沒有代表整場完整前景；LAMP+TREE的自動prompt校驗不代表材質邊緣正確，屋子內可能包含木板/地面。
- 美術Gate / Mask Gate F = HOLD。

## 4. C：真正嘗試 source plate 移除+物件同源重新擺放
使用**同一張R12精緻原圖裁片**、**同五個獨立RGBA物件**，在原圖上將這些object ROI以OpenCV Telea候選Inpaint（5×5 dilation + radius3）去除，製造一張連續地面原稿`C_OBJECT_FIRST_CONTINUOUS_PLATE/CONTINUOUS_PLATE_PROPOSAL.png`，再把原透明物件照世界座標合回，輸出`GROUND_FULL.png`與`PAR_TRANSPARENT.png`。
- Inpaint處理影響原圖**65,090px**，回放PAR後的最終美術仍比原裁片有**12,026px RGB差異**，另有原完整圖中未登記物件烘焙在地面裏，不能稱物件獨立。
- 因此 `C_OBJECT_FIRST_CONTINUOUS_PLATE` 是**源圖有烘焙物件的技術限制實驗**，不是「原生連續地面先生成」的真正成功版本。該手法不應成為正規生產管線。
- 雖Godot出圖沒座標問題，Art HOLD。不能因0px compositor差就把修壞的地面宣稱藝術PASS。

## 5. A：真配對生成
本輪無可核對的真正AI`GROUND_FULL+PAR_TRANSPARENT`雙生成模型實測，`A_PAIR_GENERATION/PAIR_GENERATION_CONTRACT.json`固定場景規格、預期檔案與禁止拿相同master偽裝獨立生成的原則。
**狀態明確NOT RUN**。需要真正生成服務/輸出透明物件控制和前景座標可驗後才能做A；不把Qwen/SAM3未執行推論冒充A已完成。

## 6. Windows Godot4.7.2真GPU雙路比較
兩份都已建立可編輯原生`StreetCorner.tscn`：
`B_MASTER_FIRST/godot_project`、
`C_OBJECT_FIRST_CONTINUOUS_PLATE/godot_project`。
五個個別`Sprite2D`加z=foot-Y、`PLATE`完整地面、`PAR`獨立透明、`ACTOR`使用FS原32px角色。Godot在AMD RX6700 XT OpenGL實際匯出每法`PLATE.png/PAR.png/FULL.png/ACTOR_BACK.png/ACTOR_FRONT.png`共**10張**544×416真正GPU圖片。腳本`r17_create_godot_compare_projects.py`與`r17_validate_dual_gate.py`有全數Gate。
- 兩個Project真Godot FULL 與各自設計Ground Full **0px RGB差**；
- 兩個Project Godot PAR vs真正作者RGBA圖 **完全相同**；
- 兩者角色放在32px窗口內有**1024px樹遮罩覆蓋**，Godot渲染人物在樹後與FULL差0px（角色完全在樹後），在同位置調整角色Z到樹前後有**271像素差**，真動態遮擋成立。
- 但 B 相較R12藝術參考完整零變；C仍然差12026px。這是證明「座標保真≠美術保真」的核心實驗。
- `R17_B_C_TRUE_GODOT_6_PANEL.png`可直接看6格對照；`R17_NATIVE_GODOT_AND_ART_GATE.json`有原機檢查紀錄。
- **此輪沒有跑RGSS2原生VX Game.exe**，因Art Gate未通過，避免對不合格畫面反覆跑無意義技術回歸。原K4源封版不動。

## 7. 狀態與接下來的能否解題判斷
- 今次**不能按85分宣布任何勝出**：A沒有真的生成、B和C的美術項目尚不全，故雙硬Gate HOLD。
- B目前最能原汁原味保留高品質美術，仍須把SAM2/GrabCut候選提升到逐件真Alpha與完整物件找齊；這不能靠32px整格大補。
- C正確道路是**從一開始先有高美術的無立體物件連續地面Plate**，再用同風格獨立透明物件作者合成；R17 C使用「已烘焙物件的Master事後Inpaint」產生藝術缺失，證明不能繼續這種偷懶路。
- A應在有真正能保有構圖同源性的RGBA生成器時再做，為保持實驗誠信不能冒稱已測。
- 下一輪高價值施工：在544×416真正完成屋+3樹+細燈+柵欄+彎路的高細節藝術，然後針對每一物件交付**人工確認的Gold Alpha**，產出PAR地板污染/物件缺漏的混淆矩陣。可先由提供的圖逐格標註正負點、SAM2/GrabCut以及Godot編輯修正，再進VX。優先驗證A/C有無真正原生分層生成的圖像工具；無工具不得瞎編結果。

## 8. 歸檔與Fail-Closed
新Authority、實際腳本、B/C原生Godot工程、透明PNG與對照圖、A未跑的狀態JSON，全部屬**候選研究**，不可覆蓋原R12–R16或正式K4 Scripts/Map。每輪要更新 Drive/GitHub Authority、SHO-34與`CURRENT_HANDOFF_R17.md`，正式 Seal=NO。