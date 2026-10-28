# Forest Symphony｜R10 來源地圖確認＋Scene21 Collision Compiler｜2026-10-28

**結果：R10 ISOLATED FS NATIVE COLLISION COMPILER TECH PASS（候選版2輪×11張），原Map050三層無Tile/實機不可走的對照已取得；角色/景深美術 Gate F 仍 HOLD；未修改505頁完整Boot既有FAIL。**

## 一、正式權威大突破：找到真正的 Map050

R10對K4封版資料夾執行完全**唯讀**檢查：
- GoogleDrive/GitHub舊研究用的 `SCENE21_GUIDED_SAM2_CANDIDATE/MASTER_RGBA.png` 與正式 `Graphics/Parallaxes/SCENE21.png`：尺寸544×416、**全部226,304個RGBA像素內容一致**，不是靠人工推測同圖。
- 正式 `Data/Map050.rvdata` 對應 `@parallax_name=SCENE21`，17×13 格。全FS掃描51張Map、88張Parallax圖檔。
- 正式Map050 SHA256 `55bed528d21644de4d840949614163b35a21b9b39fba7e85951b862b84693c26`。
- Map050原生 `@data` 的**三層所有663格全是Tile ID=0**，沒有任何768～799 ParaPassa通行標記；原Map050另有3個原生Event (原始Map事件資料仍在封版，研究副本Test Adapter會暫時清空並新增測試NPC900，不能假裝原Map050正式事件全通過)。

## 二、原封 Map050 native負對照
建立唯一隔離副本：`R10_ORIGINAL_MAP050_NATIVE/FULL505/Data/Map001.rvdata` **逐位元複製原始 `Map050.rvdata`**，只是為配合既有R5 Test Adapter使用Map ID1進行引擎實驗，沒有改動Map資料。
- Windows Game.exe `Game_Map#passable?` 對(5,6)/(9,6) = false；整張17×13原data都是0。
- 真正 `Game_Player#move_{up,down,left,right}` 橫跨樹、草地、石階、地圖邊界等9項，皆無法離開原位；真正 `Game_Event#move_down` 也無法前進。**10／10項「預期阻擋」通過**，證明原地圖尚未配置可走Tile，不是遊戲角色美術出錯。原始Map050在當前Test Adapter以正常VX TileMap通行規則測得；這不排除正式遊戲在其他事件/腳本開關另有特殊透過機制。
- 初次R10修復紀錄：新測試Adapter錯把`Game_Event`當成有`through=` setter，native報NoMethodError並中止於case1；改`instance_variable_set(:@through,false)`（僅隔離Test Adapter）重新取得10/10 blocked baseline，原正式腳本沒有修改。
- 這個10/10是**阻擋對照的正確預期**，不是原版可走地圖的PASS。

## 三、獨立 COLLISION 編譯器

以R8/R7 20組同源PAR物件的foot anchor+kind，以及使用者紅圈/藍圈規則，編譯`R10_FORMAL_MAP_AUTHORITY/Map050_SCENE21_COLLISION_CANDIDATE.rvdata`。
- 完整Ground不重畫：原 `SCENE21.png` 與R8同源透明PAR RGB對位。原Map050.data前兩層全部維持原零值，**只在隔離的候選Map的第三層**按照ISSParaPassa格式寫入：
  - ID769可走 **204格**。
  - ID768阻擋 **17格**。
  - 總計17×13=221格。
- “**有遮擋 != 一定禁止走**”：大樹/建築/石碑/大型灌木的主要接地格先列阻擋；小花或微小低植栽可保留PAR，但暫定仍能走。Object.registry有各自Collision候選policy。
- 藍圈屋前石階人物腳下格(9,6)強制維持769。注意藍圈幾何不是一整個32px tile都要剔除；Alpha遮擋像素排除與行走單格是兩個獨立系統。
- 產出原Scene21上的**綠框可走／紅框阻擋／藍框石階**風險檢查圖，並保留每個block cell對應物件ID。
- **候選不是最後的完美碰撞**：目前只用每物件foot cell，仍未涵蓋房屋完整屋體、部分雙格以上石頭/大型樹根。缺少人工Footprint格網標註與完整尋路，Collision Gate F HOLD。

## 四、真正原生 VX 動作驗證（編譯版）

另建`R10_COLLISION_NATIVE_CANDIDATE/FULL505`，只將上述**候選Map050**用作隔離Test Map001，Script原本505頁中504頁byte-exact（含HK#145、Animated#146、ISS#342），原頁#480因舊有regression NameError只在隔離本禁用，加一頁Test Adapter。
每次Windows `Game.exe` 新進程，直接對`Game_Player`與自動生成的測試 `Game_Event` 呼叫真實RGSS2`move_*`，等待穩定後截取544×416PNG：
- 屋旁針葉樹後可前進、樹foot候選格阻擋。
- 一般草地／左下空地可走、立體小物Foot候選格阻擋。
- 屋前藍圈石階可走。
- 原始map全不能走的普通地面現在恢復可行走。
- 畫面邊界仍被阻擋。
- **測試Game_Event NPC**朝候選石碑阻擋格移動時止步；移往無障礙格時成功移動。
- **每輪11／11 PASS，兩個獨立Game.exe PID共22張Native Screenshots。**
- Fail Closed `r10_final_gate.py`同時核對Map050原封SHA、正式505 Source SHA、RGBA source一致、原兩層保留、第三層204/17、藍圈石階、兩輪照片／NPC動作。結果 `R10_FORMAL_MAP050_IDENTIFIED_AND_ISOLATED_COLLISION_COMPILER_NATIVE_TECH_PASS_ART_HOLD`。

## 五、正式來源封版與可重播證據
- 原始K4 FS 505腳本 `Data/Scripts.rvdata` SHA256：
  `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`；R10完全未改。
- 原始Map050 SHA256 `55bed528d21644de4d840949614163b35a21b9b39fba7e85951b862b84693c26` 未改。
- 原始RGBA資產像素完全吻合研究Master，未重新生成地圖。R8同源RGB透明前景保持。
- Formal 505 fullBoot依然未通過，R5始發現第480頁 `FS_BattleRegression_AIEdgeI` preMain NameError；只在隔離副本停用；並沒有拿stub冒充正式。
- 原始正式Map050有3 Event，但此輪R5既有Test Adapter清除正式事件後才建立NPC900。**這一輪通過的是原始Map50 Tile data + FS核心腳本通行 + 測試NPC**，不是完整原事件設計/全正式地圖遊戲流程。
- 其他對話的正式V6地圖／SEALED檔案不更動。

## 六、延續R9美術問題 / R11方向

已封存R9 8紅色前景mask的獨立OpenCV source-edge QA，6組需人工複核：RED_R01、R02、R05、R06、R07、R08。這是Review Flag不是6組確定失敗。使用者548×400帶色圈標註圖與544×416Master的精確圖像配準仍**未在同一執行環境完成**，不能聲稱逐像素美術真值校正。

R11優先：
1. 房屋／樹／石碑完整足底占地Polygon與collision cells，分開設定畫面Alpha遮擋/實體通行；不允許用一格Foot anchor代表整棟屋。
2. 將正式Map050自身三個原始Event納入獨立native Boot，不再以Event900替代正式事件，先查有無自動事件與天候觸發。
3. 依實際玩家四方向連續步行／NPC相對位置製作視覺高度正確的遮擋與碰撞QA。
4. user-red/blue screenshot的精確幾何對應及R9 6組高風險Alpha輪廓逐物件檢查，不能宣稱已ART PASS。
5. 再接Light、Shadow、ground10系列循環圖與 ground3-scale村落及野外地圖，仍依 Gate A~F fail-closed。

## 本輪重現檔案
- `r10_formal_map_match_audit.py`：正式51 Map／88 Parallax唯讀索引，Master identity檢查。
- `r10_formal_map050_tile_audit.py`：原始Map050三層663個Tile=0權威調查。
- `build_r10_actual_formal_map050.py` + `capture_r10_actual_map050.py`：原始Map050二進位一致的隔離native負對照。
- `r10_compile_scene21_collision_candidate.py`：20物件+User Blue從原Map050 source 編譯第三層768/769及獨立條件清單+視覺圖。
- `build_r10_collision_candidate_native.py` + `capture_r10_collision_candidate.py`：新候選原生VX測試（NPC包含）。
- `r10_make_native_comparison.py`：原始全部阻擋 vs candidate實機畫面 nearest neighbour比較。
- `r10_final_gate.py`：雙native重播、資料SHA與封版fail-closed。
- 原始對照：`R10_ORIGINAL_MAP050_NATIVE/NATIVE_MAP050`、正式候選原生2輪：`R10_COLLISION_NATIVE_CANDIDATE/NATIVE_REPLAY1`與`NATIVE_CANDIDATE`。
- `R10_COLLISION_NATIVE_CANDIDATE/R10_FINAL_GATE.json` 最終權威。
- 工區：`E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027`。