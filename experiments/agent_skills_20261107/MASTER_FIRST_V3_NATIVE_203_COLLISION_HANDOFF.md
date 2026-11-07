# FS Master-first V3 | 真正 RPG Maker VX 原生 Ground／PAR／碰撞實測
日期：2026-11-07。來源：**上一輪凍結的同一張 1280×928 母圖**，沒有重新生成美術或覆寫 A36F／A36G／A36H 原工程。

## 實際施工
- 直接沿用 V2 C2 的兩屋屋頂與兩處樹冠分割建議。Runtime **FullGround=完整母圖**，Runtime **PartialPAR=四個語意候選遮罩的同源 RGB（原座標）**，Alpha 非零 118,425px。疊回 Master RGB = **0 像素差異（同源建構式 PASS）**。
- V2 的 40×29 碰撞草案（333 blocked／827 free）把**37 格屋頂**誤判可走。V3 依兩棟房屋原始 RGB 遮罩的覆蓋範圍進行局部更正，草案變成 **370 blocked／790 free**。注意這是局部合理化，**還沒有完成全部地形/橋/樓梯/樹幹/河岸的視覺可走性逐格簽核**。
- 實際建立獨立的 RPG Maker VX `Game.exe` 複本，修改真實的 `Data/Map050.rvdata` binary `RPG::Map @data Table` layer z=2（768=blocked, 769=free），**不是覆寫 `passable?` 函數**。逐格 Ruby native `$game_player.passable?` 和所有界內相鄰 `move_passable?` 實際測試，對 V3 碰撞草案 **1160/1160 tile 與 4502/4502 有向相鄰邊 PASS，零差異**。
- 真實 `Game.exe` RGSS2 HK UOM `$game_switches[203]` false→true，外部抓取 RGSS Player 544×416 實拍，角色真走路（不只傳送）：
  - `LEFT_TREE_EXIT` (10,16)→(10,17) **PASS**：開關203關／開的實拍人物像素差 **627→161**（真移動 `move_down`）。
  - `LOWER_RIGHT_TREE_EXIT` (33,24)→(32,24) **PASS**：**627→8**（真移動 `move_left`）。
  - `CLEAR_NEGATIVE` (20,15)→(20,16) **PASS**：**0→0**（真移動、無不當前景覆蓋）。
  - `LEFT_HOUSE_ROOF_GEOMETRY_ONLY` 及 `RIGHT_HOUSE_ROOF_GEOMETRY_ONLY`：203 確實切換（各 627px），但演示格 (6,5)/(27,5) 是 **blocked**, **僅 ENGINE_ONLY**；不准把人物傳送到屋頂裡面冒充遊戲可走的屋簷遮擋 PASS。
- 原始 FS VX 複本的 `Data/Scripts.rvdata`、`Data/Map050.rvdata`、`Overlays/ground50.png`、`Overlays/Par50.png` SHA256 全未變；全部修改只在隔離的新複本。測試修改 scripts 只服務本輪 QA。

## 失敗記錄與防重工
- 第一輪遠端 Python 原生測試腳本出現 `NameError: name 'w' is not defined`（Windows ctypes alias）。保留初版失敗，修成 `ctypes.wintypes as wint` 的 R1，重新建立**新的**獨立複本並完成全部測試。絕不覆寫已發生失敗的測試路徑。
- G4 `Runtime FullGround+Par` 顯示原版 RGB 完全相同是**建構式**，不得當 G3 source mask 正確之證明。
- 屋頂**無合法可走的原生正面 actor 樣本**，表示目前需要處理的是靠近玩家的屋簷突出部分或純 Authoring object，而不是反覆把角色塞進樓頂。
- 40×29 Native Engine 逐格 PASS 僅證明「草案可被原生 VX 正確載入與執行」，**不能**替代美術語意碰撞審查。
- 兩個 canopy 樣本 Native PASS 也不代表完整樹冠/橋欄/其他所有屋頂、樹林的遮擋語意驗收。

## 可重跑交付
- [Drive V3 私人工程資料夾](https://drive.google.com/drive/folders/1XD7sRcUJnVu_MIb5SLk0MTDY6ICnpKNf)
- [完整 ZIP（41 檔、32,908,856 bytes）](https://drive.google.com/file/d/1_FWGlHNsZteQxXqzu84vuqj_wspwg0TV/view)
- [三組合法移動實際 Game.exe OFF/ON 截圖](https://drive.google.com/file/d/1Ml6zP_5O8Ovgp6vGJ0j-TRiH1L6VfSK-/view)
- [原生 5 案例完整對照](https://drive.google.com/file/d/14YxXunuZ9lF-LAgM0evD-o7ZOV5Epa0R/view)
- [Native QA JSON](https://drive.google.com/file/d/1fTDmaR7OhxNa2aoACfc49sxVt93n8bBe/view)
- [正式 V3 Handoff](https://drive.google.com/file/d/1fPNmup2-mCjfoRDq2H02PGkPQ-ppZjx5/view)
- [原生 Map050 實際 bytes](https://drive.google.com/file/d/1-H4mReCJPgIMdwujG__YAdlwcPgWKLWQ/view)
- ZIP 已用 Python `ZipFile.testzip() is None` 驗證，Drive 同步副本 SHA256 一致。原始 4 source-masks、FullGround、RuntimePAR、Authoring GroundOnly／CompletePAR、native scripts、Script.rvddata／Map050.rvdata 隔離測試 patch、20 張原生截圖、QA/Handoff/SHA 都完整保存。私人美術沒有寫入公眾 GitHub。

## Gating / Formal Seal
| Gate | 判定 |
| --- | --- |
| Master SHA / 1280×928 單源 | PASS |
| Runtime RGB pixels registration | PASS（同源建構式） |
| 370/790 collision draft load in native Map050 | PASS: 1160/1160, 4502/4502 |
| Two canopy actor dynamic transitions + clear negative | **3/3 PASS** |
| Roofs actual **walkable** edge occlusion | **FAIL/NOT VALIDATED** (ENGINE_ONLY blocked roof probes) |
| Full authoring Ground hiding/completePAR semantics | **UNVERIFIED** |
| Full map real-world collision semantics | **UNVERIFIED** |
| User visual style/FS Ground3 approval | **PENDING** |
| Full scene all occluders and Godot test | NOT RUN |
| Formal Seal | **NO** |

## 下一步
繼續對 **橋欄、中央亭/石碑、兩屋廊簷**進行真正同源 RGB masks；每件要分「地面基底 vs 完整地上物件 vs 人物遮擋」，尋找至少一組相鄰合法可走 actor footpoints；為整張 40×29 逐格訂定可通行語意的獨立視覺 Gate。不要再拿 RGB 0 差重複報告成美術進步。
