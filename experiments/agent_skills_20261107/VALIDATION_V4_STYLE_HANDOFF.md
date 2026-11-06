# Forest Symphony | A36G R6 / Agent Skills V4 | 2026-11-07

## 為何換策略
上一輪 V3 已經完成 A36F R2 conservative 的 **VX 原生 1160/1160 全格 + 3576/3576 方向通行**；繼續重跑碰撞無法解決使用者指出的主要問題：**A36G 與原 FS ground3 的美術風格嚴重偏離，完整 R5 PAR 也不能直接放入原生 HK UOM Par50**。

按 Google Drive `SHARED_GAME_ASSET_GENERATION_AUTHORITY`、`ASSET_GENERATION_PRECHECK_FS v3.2`、GitHub `MAP_DUAL_OUTPUT_AUTHORITY_V2_5` 重新檢查。來源正式權威：
- 原 FS `E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png` RGB 1280×928。
- 對齊原 FS `Overlays\par3.png` RGBA 1280×928。
- A36G R5 192 個獨立來源：`E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104\SOURCE_INDEPENDENT_RGBA`。
- 對應 Manifest `A36G_R5_SCENE_MANIFEST.json`；全部原始 SHA256 未變。
- 禁止以 `Overlays/ground3.png` 取代完整原始 Ground3，因它只是一個其他效果用 overlay。

## 本輪真實工程輸出
### R6 C1 (FAIL，完整保留)
`E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_R6_SOURCE_REGISTERED_RUNTIME_20261107`
- 從 R5 同一張 Master 複製 `R6_RUNTIME_FULL_SCENE_GROUND.png`。
- 原始 Authoring `GroundOnly`、`CompletePAR` 完整獨立保留。
- 從每個已驗證 SHA 的獨立原始物件 Alpha、footpoint 以及可走格的 32px actor body 位置推導 runtime partial PAR。
- 真輸出 `R6_RUNTIME_SOURCE_REGISTERED_PAR50.png`，與 runtime Ground 的非透明 RGB 100% 對齊，RGB 背景重合復原 0 diff。
- 產出遮擋 Alpha coverage **34.419%**，但存在明顯 **每 32px 規律方格／縱向條紋**，屬於錯誤的 actor 站位格取樣。**Art/semantic Gate FAIL，不得拿去 VX 宣稱 native pass**。
- 客觀特徵：遮罩水平 x-edge 變化中，x mod32 ∈ {4,28} 佔 **81.682%**；原版 par3 僅 4.770%。

### R6 C2 (FAIL，完整保留)
`E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_R6_C2_CONTINUOUS_OCCLUSION_20261107`
- 保留來源 Alpha，對 actor 可到達位置場作平滑只為消除 32px 假條紋（沒有模糊像素素材本身），runtime PAR 最終仍為二值 alpha 與 Master 同源 RGB。
- 規律 x-edge 指標降到 7.563%，但 Occlusion Alpha coverage 膨脹至 **52.7611%**，仍有大塊矩形森林塊與不自然邊緣。**Art/semantic Gate FAIL**。
- 產出對照 `FS_STYLE_AND_OCCLUSION_BENCHMARK_V4_20261107/ORIGINAL_VS_R6_C1_C2_OCCLUSION_WITNESS.png` 和 `FS_R6_MASK_ARTIFACT_GATE.json`。
- 重要：任何僅憑合成 RGB=0、Alpha 接受、可載入 VX 就宣稱 occlusion PASS 的行為均為假陽性。本輪遵循 FAIL-CLOSED，**沒有將 C1/C2 匯入實機**。

### 原始 Ground3/Par3 正式參照組 (REFERENCE PASS)
本輪真正產出 `E:\FS_AGENT_SKILLS_PILOT_20261106\FS_GROUND3_PAR3_REGISTERED_BENCHMARK_V4_20261107`，包含：
- 4 個 544×416 原始 RGB Ground、RGBA PAR **同源成對**參照圖。每組起點都是 32px 整數格，沒有位移、縮放、重繪或像素合成造假。
- 4 張前景選區著色 witness 圖，顯示屋頂／林冠在原版是怎麼局部遮擋。
- `ORIGINAL_FS_4_REGISTERED_VIEWS_AND_PAR_WITNESSES.png` 四組並排 1× 實際像素。
- `REFERENCE_MANIFEST.json`，含裁切起點、每對 Ground/PAR 的 SHA256、遮擋率、對位率與相對 RGB 差異。
- 完整 ZIP：`FS_CANONICAL_GROUND3_PAR3_4VIEW_REFERENCE_V4_20261107.zip`，6.30 MB，13 entries，ZIP CRC PASS。
- 四個區域：NW_COTTAGE_AND_TREES 起點 (0,0)、CENTER_MAIN_HOUSE (352,192)、EAST_HOUSES_CANOPY (736,0)、WEST_FOREST_CLIFF (0,448)。所有尺寸 544×416，像素完全來自原版，無新生成。

| 區域 | PAR alpha>0 | 高透明度區域 RGB 與 Ground 精確相同 |
| NW | 20.4292% | 97.3586% |
| CENTER | 12.5464% | 98.4244% |
| EAST | 12.5795% | 97.6716% |
| WEST | 11.9697% | 96.1642% |

## 真正失敗的美術原因
- 原版 ground3：對稱/斜面木造建築，明顯門窗/木梁，細小分明的深綠與藍綠雙色樹冠，明確草地/地形邊界。
- R5：茅草屋頂變得統一但失去原 FS 建築語彙，大片林群多次生成參照後顏色與清晰度漂移；使用者判定 ART FAIL，依然有效。
- 192 個獨立來源檔和 Manifest 具可重用性，但 R5 44 個 `forest_group` 實際是深度切片而非已標記根部/樹冠的完整個別樹。僅用 `foot` 和 actor raster 會錯，**不可以再硬算成 approved runtime mask**。

## 下階段必須先做
1. **先選擇原版 FS ground3 提取的真正屋頂與林冠證據作 mask semantic authority**。每個新 source asset 有自身 alpha、遮擋語意/foot、blocking，而非只利用全域矩形像素/高度規則。
2. 先處理單棵原版風格樹、單棟原版風格屋頂的個別來源與遮擋 witness，根據角色 32px 高度做局部 VX ON/OFF 測試，通過後再擴張到整個林群。
3. Forest group 需重新統合為來源完整的大林群而非深度切片；禁止繼續讓 R5 自行餵回自己做參照。只有真正符合原版 Style DNA 才能進行 A36G 新美術候選。
4. 每次 candidate：`AUTHORING_GROUND_ONLY` + `AUTHORING_COMPLETE_PAR`，另外獨立 `RUNTIME_FULL_SCENE_GROUND` + `RUNTIME_OCCLUSION_PAR` + `COLLISION_E_TILE`。
5. 記得先用四組原版同源 544×416 pairs 校對，再做 VH 原生 Game.exe 與 Godot 比對。上游原版，A36F/R5 完全不覆寫。

## Gate
- Reference crop Registration / Source SHA：PASS
- R6 C1 Runtime Occlusion Semantic：FAIL
- R6 C2 Runtime Occlusion Semantic：FAIL
- R6 C1/C2 VX Native：NOT RUN（Fail-closed）
- R5 Art/Style：FAIL（使用者原判）
- PMD：本輪未動，仍 PENDING
- **FORMAL SEAL：NO**