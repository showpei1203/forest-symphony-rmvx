# FS A32 Ground-first ＋ 獨立完整 PAR｜施工、實機 QA、Failure Log、Handoff

日期：2026-11-14。狀態：**A32 ART CANDIDATE / GODOT NATIVE REAL TESTED / ART HOLD / COLLISION HOLD / FORMAL SEAL NO**。

## 先讀規則

- **唯一正式現行產線**：`authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md` v1.3；作者已明確決定 Ground-first → 獨立完整 PAR 物件 → Godot 原生組合 → 1x 最終美術豐富度對照完整生成圖。此前 A11/A21 → 同源像素切割僅是歷史遮擋技術研究，不可再充當新地圖量產的生產順序。
- Godot Draft PR #16 中既有 A29–A31 原生相機/遮擋/碰撞程式、資產與測試均保留且可回退；A32 是**新增** `scenes/a32_groundfirst_scene.tscn`，非修改封版 VX 或覆蓋舊 A31 地圖。

## 這次實際建立了什麼

1. **純 Ground 新生成**：Ground-only 圖以影像生成產出 1536×1024 RGB **無房屋無樹木**草地/小花/道路/石子，直接擷取其中 1280×928 個原像素，**不縮放、不從有前景的 Master 把樹/房子修掉**。Ground SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`，`private_assets/ground_only.png`。注意 1280×928 canvas 與 32px 格對齊，不等於地面所有繪圖細節都原生按 32px 畫好；地面像素精度與 FS 16 色盤尚待人工逐區評價。
2. **全部 PAR 由獨立原始 RGBA 物件建立，無 flattened-Master 切割**：從使用者已有 A36F 私有 `INDEPENDENT_PAR_ALPHA_468/` 與 FS v2.3.3 私有 `Graphics/Pictures/FSOBJ_*` 中選 27 種完整來源，並在場景中獨立放置 146 個（134 tree、2 house、10 props）物件。每個素材個別保留 `private_assets/independent_par/*.png`、原始 SHA 與加工 SHA，發現來源邊緣不透明時**只補外側 8px 透明 padding，不裁切、不重畫**。
3. **真實 Godot 可編輯場景**：146 個獨立 `Node2D` 在 `YSort` 中依 footpoint 分前後。每物件有選得到的 `Sprite2D` 和 `StaticBody2D/CollisionShape2D`，物件 Inspector 可檢視原檔 SHA、語意、root footprint；136 個樹根／建築落腳面具備原生碰撞，不能誤以樹冠整張 alpha 為阻擋。`FullGround` 原圖 Sprite2D 不動。主場景可直接按 Godot 4.7.2 執行，544×416 viewport，原版 F0 48×48 角色可用方向鍵移動，Camera2D 跟隨，G 顯示 32px 格。**沒有把 45° 戰鬥 A62 當四方向城鎮步行**。
4. 影像檢查輸出 Ground-only、透明 PAR、3-way 對照、Godot 1280×928 native framebuffer、Godot 544×416 樹前後兩站位。PAR 全畫面的平面 `a32_par_preview_only.png` **僅供 QA，不是正式角色前景渲染來源**；Godot 運行時直接使用每個獨立 PAR 物件。
5. Public GitHub 僅有 `project.godot`、GDScript、TS CN 場景節點、source IDs/manifest、測試與 CI；不含新 Ground、完整獨立 PAR、Actor F0 或作者資料庫原圖。所有私人藝術仍然 owner-only Drive。

## 實測與結果

- **Godot 4.7.2 Linux 官方引擎**，Xvfb + Mesa llvmpipe OpenGL 真正讀取私人 PNG：`--headless --editor` PASS；`res://tests/test_a32_groundfirst_real.gd` **734 項原生檢查 PASS**：來源 SHA、146 場景物件節點、146 實際 RGBA 圖載入及尺寸、136 原生物理碰撞、F0 actor/camera、樹根實體碰撞接觸。
- `res://tests/capture_a32_native.gd` 真實 Godot 1280×928 framebuffer PASS；`res://tests/capture_a32_tree_depth.gd` 544×416 樹前、樹後原生 framebuffer PASS。`qa/` 內真實 PNG 與預覽圖分開命名，避免概念圖冒充引擎截圖。
- 1280×928 native framebuffer 對 Python 單純 flat composite 比較：**10,965 個 RGB 非零差分像素**、720 個差分 >1、最大 channel diff 16，整體平均每 RGB code value 的誤差 0.005118。來自 alpha 混合/重疊順序，**不宣稱 0 RGB mismatch**；Godot YSort 分層的動態遮擋比靜態合成更重要。
- 32px collision **已接上 136 根／建物落腳面候選**，但沒有建立完整每格 water/door/forest 遊戲地形通行表。Godot 場景還不是正式可遊玩村落。

## 美術 1x 評價與待解決項目

- **Ground 獨立豐富度有進展**：自然流動的碎石路、多色花草、叢生葉片與草地材質不用切圖；即使關閉 PAR，背景畫面仍完整。
- **PAR 未達最終成品**：A36F 苔蘚屋立面/屋頂沒有達到 Ground3 等級細節，兩棟房風格同族但變化小；混用 A36F 與 v2.3.3 樹種的像素密度、光源與色彩仍可能不一致。大部分樹群沿地圖邊界密集，中央村落需更立體的獨立燈具、圍籬、花壇、小棚。
- **美術評級：HOLD**。沒有用「146 個物件」或「734 個檢查」冒充藝術合格；要等使用者直接看 1x Godot 合成圖，並與 Ground3 及完整生成式地圖參考評價。
- **Ground 後製限制**：本輪只是 center crop，不聲稱每個地面紋理在 32px grid 上天然成立；新路線下 Ground+獨立 PAR 能達到高品質仍須繼續打磨。
- **人物前後**：Godot 原生前後截圖均成功，樹後人物可能被濃密樹葉幾乎完全蓋住，是正確深度排序的候選，但仍需要美術語意與可玩性驗收。

## Failure Log

- **A32-F01**：前一產線把完整 Master 直接切成條件式樹冠遮罩，讓「相同像素」誤被視為「可量產的美術分層」。在 master v1.3 禁止此推論，這次 Ground 與 PAR 原始來源完全不同。
- **A32-F02**：原 A36F 的苔蘚房屋雖完整透明、可重複使用，但與本輪新 Ground 的質感相比仍太簡化。沒有臆測 Art PASS，保留為待替換完整房屋家族。
- **A32-F03**：Godot vs Pillow 的半透明 alpha 覆蓋有實際 720 pixels RGB 差>1，不得把差異四捨五入宣稱零差分。
- **A32-F04**：本輪新地面純原創像素影像未按 VX 的 32px tile 原生分區繪製，碰撞依物件腳點單獨設定；不允許誤稱已做完 40×29 通行地圖。
- **A32-F05**：一張 ImageGen 地圖流程說明插畫不是工程素材，也不可冒充已完成之 Godot 場景。正式成果只採 Ground-only PNG + 獨立來源物件 + 真實 Godot framebuffer。

## 下一輪施工

1. **真正改善 PAR 美術品質**：為兩個苔蘚屋建立統一房屋 family 的完整獨立透明美術改版，不要再拼接側屋；加強完整樹木的物種與色彩一致，特別是森林與建物接觸處的完整背景細節。保留 Ground 不動，測試替換物件不影響地面 SHA。
2. **完整城鎮動線**：32px 門口、樹根、道路、橋/水按場景真實幾何建 Collision/Nav，至少進出兩棟房門、一位 NPC 與場景切換。未完成不可封版。
3. **美術與玩法雙驗收**：1x Godot viewport 原生畫面，角色樹前/後、走路、進門、NPC 對話。正式評估是否有完整生成圖片等級，而不是再刷測試次數。
4. 雲端：所有私人原圖、源 ZIP、生成 Ground 與完整可開 Godot ZIP 只上傳 owner-only Drive；GitHub PR#16 只更新 scripts/scene/manifest/docs；原封版 VX/main 不動。每輪按 SHA/CRC 下載回讀，Handoff + Failure Log。

## Owner-only cloud upload verification / delivery

- Full R4 source-owned project ZIP: [Drive file](https://drive.google.com/file/d/10oUrfTbgohCHuCq0GO36vyQ3kCABIlBc/view), 228 files, **47,995,335 bytes**, SHA256 **`28a52f2a901f8ea4ca2bcffe53646dcafe619a3d6ef365b6152efcc77b36b544`**. Downloaded back with Drive raw file API; exact SHA256, ZIP CRC and source Ground byte comparison **PASS**.
- True Godot 1280×928 1x native framebuffer [Drive file](https://drive.google.com/file/d/1YVEJozXA_4GyLO1T1647CvJFJAi9YXyg/view); [Ground / PAR transparent / composite 3-way](https://drive.google.com/file/d/1mV1P1M0gn8CHFvuVrFEdDdbGtUQjACop/view). Private art not in GitHub PR.
- **Caveat:** This final cloud copy is the exact pre-cloud-link Handoff inside the immutable R4 ZIP; the more recent GitHub `docs/A32_GROUND_FIRST_HANDOFF.md` and Drive Handoff mirror track owner-only links after upload. No files added to local user PC.


## A32-F05｜使用者 2026-11-14 1x 美術回饋：路燈像只剩半截（ART HOLD）
- 真正參考來源：V233 私有原生 `Graphics/Pictures/FSOBJ_post_lantern.png` 大小 **16×41 RGBA**；A32 `private_assets/independent_par/fsobj_post_lantern.png` 只是四周補 8 px 透明邊界，尺寸 **32×57**，不透明範圍 bbox **(8,8)→(24,49)**；`manifest` asset `fsobj_post_lantern` 以四個獨立物件引用，並未在合成中對圖片做垂直裁切。舊燈柱本身短、末端呈平直截斷；在新的高細節草地比例下呈現「半截」視感。
- **不可誤報為已修復**：目前已完成來源定位，無任何新燈具美術、神奇補全或新實機演算；現有私有 R4 原始封包仍保存完全相同。不要以伸長相同像素的比例拉伸假裝藝術過關。
- **下一個獨立 PAR 實作 gate**：生成/製作一個完整自洽 3/4 俯視長柄立燈透明 RGBA，含燈罩、光源、立柱、完整底座與接地陰影（燈光層分離）；與 Ground 的像素密度、受光方向和尺寸匹配。另建新資產 ID、SHA、物件家族版本，替換四個燈實例；Ground PNG SHA 完全不變；1x 原生 Godot 前後比較與角色通行檢查。使用者尚未 ART PASS。
- **使用者正面確認方向**：Ground-first 加完整獨立 PAR 是值得沿用的方向；此確認**不代表**路燈/房屋/全圖美術已通過。
