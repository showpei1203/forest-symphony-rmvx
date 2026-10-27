# CURRENT_HANDOFF_R6 | FS Master Ground + source-aligned occlusion PAR | 2026-10-27
**R6 ISOLATED REAL VX NATIVE RENDERER TECH PASS（2獨立重播×15張截圖；A1/B/A2 同場）｜Full 505 unchanged Boot FAIL｜Semantic PAR / Visual Gate F HOLD**

單一原生 Game.exe 同一站位切 A1=HK STATIC（Par1.png switch203 true）→B=三獨立同源遮擋 Sprite foot-z→A2=還原 HK STATIC。可控制地 freeze Scene_Map 動畫更新，只允許Graphics繪圖＋切換；兩輪5情境*3=15張原生Native截圖，每輪從Game.exe新進程執行，pixel閾值0嚴格比對。

兩輪像素差（A1→B均限制在兩角色ROI；所有A1→A2=0；所有非角色區=0）：
- 玩家樹前NPC後：107 px
- 玩家樹後NPC前：11 px
- 兩人皆樹前：134 px
- 兩人樹後：0
- 空曠：0
R6_FINAL_GATE.json: R6_NATIVE_VX_RENDERER_ABA_REPEATABLE_TECH_PASS。早期未凍結版本A1→A2有約7.6～8.4萬非角色px差異，證明原R5照片時間效應；已留R6_UNFROZEN_BASELINE_R0。首次freeze Ruby1.8 `each_index.any?` 會LocalJumpError，已改each_with_index block，錯誤對話框截圖保留。

K4正式505 Scripts原SHA 5A728530764E61D22D8C6927367D983C14E36EE37E777508D154A04A2EE7ACAA。只有R6隔離本的480 Regression Harness 被暫停，其他504頁原始byte-exact，另加一頁專用Adapter；HK145/Animated146/ISS342原始未改，正式專案未改。尚不能正式通過全505 BOOT。因現有SAM2遮罩僅3物件且右樹灌木錯抓，完整PAR/Visual Gate F仍HOLD。

資料本地：E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027；參考 RESEARCH_REPORT_R6.md、build_r6_same_session_vx.py、capture_r6_same_session_vx.py、analyze_r6_same_session.py、r6_final_gate.py、R6_SAME_SESSION_ISOLATED/R6_FINAL_GATE.json。
Github Authority：authority/research/FS_PAR_OCCLUSION_R6_NATIVE_ABA_20261027.md
R7：改善SAM2全圖語義alpha及通行避碰，把UI/鏡頭/時序驗證帶進四方向＋動態Ground loop、大圖40×29，不能跳 Gate F。
不修改SEALED、其他對話地圖、K4、戰鬥SHO-56。