# CURRENT_HANDOFF_R10 | FS SCENE21 TRUE Map050 + Collision Compiler | 2026-10-28

STATUS：**R10 Map050真正來源鑑定PASS、隔離VX Collision Compiler 2獨立Game.exe各11/11動作TECH PASS；正式原505完整Boot既有FAIL；PAR美術/房屋占地Collision/User Gate F仍HOLD**。

正式K4原檔與另一個對話地圖工程皆未修改：
- K4 `Data/Scripts.rvdata` 505頁 SHA256=5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa。
- K4 `Data/Map050.rvdata` SHA256=55bed528d21644de4d840949614163b35a21b9b39fba7e85951b862b84693c26。
- Map050 `parallax_name=SCENE21`、17x13，原3層663個Tile ID全=0，正式Graphics/Parallaxes/SCENE21.png與研究Master 544x416全部RGBA像素吻合。原Map050對比隔離原生VX的Game_Map#passable?(5,6)/(9,6)為false，玩家/NPC全部無法動；已取得10/10阻擋negative控制Native。
- 新`r10_compile_scene21_collision_candidate.py`以R7/R8 20組同源前景的類別和foot anchors編譯**候選**Map050第三層768阻擋17格/769可行204格，前兩層不動，藍圈石階(9,6)強制走。PAR Alpha獨立決定；微型低矮植被可有PAR而不一定阻擋；房屋目前只一個foot格，仍需人眼審核完整碰撞占地。
- 候選在另一隔離VX：11步真`move_up/down/left/right` + 測試Game_Event NPC (前進／擋住) + 石階＋邊界。**2獨立Game.exe，每輪11/11，共22Native PNG**；Native Gate R10_FINAL_GATE.json正式驗證通過。
- 通用技術負對照：原始Map050 0值無通行；候選加第三層才可走。**未修改正式Map050**。
- R10原始Event數據3個存在Map050，但R5沿用Test Adapter會清除它們，新增NPC900。所以並非原Map050三事件原生完整正式驗收。正式505頁在隔離副本仍僅504個原頁byte-exact，#480 Harness舊NameError停用，新增一頁TEST Adapter，故完整505源Boot FAIL/HOLD。
- R9六個遮罩外觀風險仍在 RED_R01/R02/R05/R06/R07/R08，使用者截圖548x400與Master544x416精確pixel標註配準尚未完成，ART F HOLD。

詳細RESEARCH_REPORT_R10.md；重跑`RUN_R10_MAP050_SOURCE_AND_COLLISION.cmd`。下一R11：房屋/樹完整實體足底polygon、原Map050正式3事件、真連續角色/NPC、遮罩逐px配準與Light/Shadow/Ground loop，再大尺寸。