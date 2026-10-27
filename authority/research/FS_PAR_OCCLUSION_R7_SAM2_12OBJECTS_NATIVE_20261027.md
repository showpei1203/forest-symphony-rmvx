# Forest Symphony｜R7 Master-First Occlusion PAR 12 Objects｜2026-10-27

**Authority Status：隔離 Native RPG Maker VX TECH PASS（2獨立Game.exe×15張截圖）｜PAR語義與完整地圖美術ART HOLD｜正式未修改505頁Boot FAIL。**

## 目標與成果
- 不再挖空或重畫 Ground：原 SCENE21 544×416 精美完整母圖始終保留。
- 使用 SAM2.1 Hiera Small CPU + 12組由AI分析畫面後*人工設定座標、物件種類、正負提示點、接地錨點*的註冊表，產生12個獨立同源透明 PAR 遮擋候選及1張合成 PAR。
- SAM2單趟 CPU 4.245 秒模型推論（整個遠端執行約15秒），12組 prompt consistency 全部達最低測試標準；**不是自主物件偵測，也不是經第三方標註驗證的語義正確率**。
- 合成前景候選 49,888 個像素，母圖寬544高416（總226,304px），所有Alpha非0的 PAR RGB 均與 Master原始像素逐點完全相符，不存在二次獨立生成導致的顏色／位置不一致。
- 十二類選定區域：house、left_deciduous、right_deciduous、mid_conifer_A、mid_conifer_B、upper_right_conifer、left_conifer、left_front_bush、left_shrine、right_marker、right_flower_bush、front_edge_bush。
- 單物件Alpha遮罩內有86px互相重疊（81px在兩棵針葉樹候選、另5px在兩個植被候選）；輸出合成PAR透過唯一Pixel Owner確定單一歸屬；這不等於語義重疊已經藝術正確。

## R7獨立角色／32px／通行候選 Gate
- R5隔離Map001第三層裁至17×13，769走、768不通。**這是測試設定，非正式原生SCENE21地圖的原始通行Authority。**
- 17×13共221格，其中218格在隔離設定中可走。使用真正FS `$001.png` 的32×32角色四方向獨立Alpha輪廓，掃描218×4＝872項。
- 如果把碰到選定前景像素的32×32格子整格不透明複製成PAR，會額外帶入47,392個「不屬於這12組前景候選」的像素。屬風險示警，並不保證其餘像素就沒有未選到的前景。
- 四方向掃描：共有290個方向/格組合存在上述整格多餘遮擋風險；固定前景相對接地點深度有13組方向/格衝突，分布4個格（3,6）（8,6）（9,6）（12,7），涉及左針葉樹、房屋與右石碑。
- 所有輸出 `R7_SEMANTIC_MASK_CANDIDATES/R7_4DIR_OCCLUSION_GRID_AUDIT.json` 與熱圖，保留所有原始數據。

## 右側大樹誤選改進（非人工真值）
- R0 原候選 mask: 11,688px，R1帶反例prompt: 7,482px，R7新正負提示候選: 6,523px。
- 在右下懷疑灌木區（x430..543,y240..310）內，R0原mask誤收2,475px；R1 / R7候選落入此矩形0px。這支持已針對特定下方灌木範圍排除誤選，但不保證其它地方完全沒有錯，也可能刪掉有用的樹根邊緣。
- `R7_RIGHT_TREE_REFINEMENT_AUDIT.json` 保存比較，原R0錯誤不得消失於紀錄。

## 真實FS原生Game.exe Native A1/B/A2 Gate
- 在先前R6隔離版完整原生VX架構加上R7的12組source-derived PNG，靜態 HK-Par1 使用完整合成PAR，動態是12個專用R5_OC_ID.png圖片及各物件foot_y SpriteZ；同場 A1（HK靜態）→B（獨立前景按foot z）→A2（HK靜態恢復），測試位置／角色／鏡頭完全一致。
- 保留FS第145 HK-UOM、第146 Animated Parallax、第342 ISS-ParaPassa原腳本byte-exact，505正式Script中的另504頁完全相符；#480 Regression Harness事先就有無法啟動的alias NameError，在**隔離副本**暫停一頁，額外新增一頁測試Adapter。正式SOURCE本體不修改，不得聲稱完整505原樣執行PASS。
- 每輪一個Game.exe PID，5位置×A1/B/A2＝15張真實 native 544×416截圖，兩輪獨立PID總30張。
- *Threshold=0*：任何RGB channel出現不同就計為差異。兩輪完全相同：
| 位置 | A1 vs B 變化像素（僅兩人物ROI）| A1 vs B 非角色區差異| A1 vs A2完全復原 |
|---|---:|---:|---:|
| 左針葉樹前 (3,6) | 327px | 0 | 0 |
| 屋前 A (8,6) | 5px | 0 | 0 |
| 屋前 B (9,6) | 354px | 0 | 0 |
| 右石碑前 (12,7) | 269px | 0 | 0 |
| 空曠 (8,9) | 0px | 0 | 0 |
- A/B/A 變化局部化＋復原通過**技術**檢查；然而「角色到底應該被遮到什麼輪廓」、「12物件是否含草地／漏前景」仍未獨立完成人工語義標註。因此演算法提供新候選，**不是美術完成**。

## 發現與修復紀錄
1. R7_ERR_001：WSL安裝SAM2/torch，但未安裝rubymarshal，嘗試在WSL直接讀Windows Map001.rvdata失敗。正確方案是Windows原生Python先解出隔離 Map第三層 `R5_ISOLATED_MAP001_THIRD_LAYER_17x13.json`，WSL只讀JSON，不改全域環境；後續872組測試PASS。
2. R7_ERR_002：Windows Python缺NumPy，首次執行統整Gate失敗；改使用Pillow逐像素比較原Master和合成PAR，避免安裝多餘相依，後續完整Gate PASS。
3. R7_ART_HOLD：12組由分析者預先指定bbox/接地點，故SAM2自動推論不等於真正零提示全場景分割；現有front ring stone、部分灌木與各方向實際可走區可能未完整cover；物件混有地面、遮罩剪角與接地深度仍需檢查。
4. R7_BOOT_BLOCKER：原#480回歸腳本 pre-Main Alias錯誤仍存在；隔離一頁停用不是正式修復。不可在地圖支線修改K4封版。

## 下階段 R8
1. 把「由我預設12個座標」進一步自動化：比較 SAM2 Automatic Mask Generator／文字分割／多類物件候選排序，保留人工誤選QA，建立可泛化物件辨識而非SCENE21硬編碼。
2. 使用FS**真正對應該地圖**的第3層ISS通行資料及移動路徑，排除不可達站位，驗證玩家與NPC四方向實際走路，不僅站位 teleport。
3. 對12個Alpha遮罩逐物件做母圖1×美術審核（屋簷、樹幹、樹頂、石碑及地面誤遮），補足漏掉的前景，允許人工標記框與反例提示，但嚴禁另生成難對位新圖片。
4. 通過小地圖完整PAR與原生VX Gate F後，再處理40×29/ground3大型圖、ground10動畫循環、Light/Shadow層和HDR色調。
5. 全程保持正式505 scripts SHA-256封版、當前V6地圖線不動，錯誤與每版資料保存Drive／GitHub／Linear。

## 可重現產物
- 檔案根路徑 `E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027`。
- `r7_sam2_object_proposals.py`（SAM2全物件註冊表與12個source-PAR）、`r7_export_isolated_passability.py`、`r7_occlusion_grid_gate.py`（872方向/格稽核）、`r7_right_tree_refinement_audit.py`。
- `build_r7_native_scene.py`、`prepare_r7_capture_analyzer.py`、`capture_r7_native_scene.py`、`analyze_r7_native_scene.py`、`r7_final_gate.py`。
- `R7_SEMANTIC_MASK_CANDIDATES/` 提供所有 PNG/JSON/heatmap。
- `R7_NATIVE_FULL_MASTER/NATIVE_ABA` 和 `REPLAY1_NATIVE_ABA`：2輪各15張和像素比較。
- `R7_NATIVE_FULL_MASTER/R7_FINAL_GATE.json`：最終技術Gate Authority。
- `CURRENT_HANDOFF_R7.md`：跨對話接續，禁止把Prompt一致性假冒人工美術PASS。

**Final R7：source-master保持；source-color exact PAR 12候選；real native renderer PASS (30 screenshots), semantic/full PAR/Gate F still HOLD。**