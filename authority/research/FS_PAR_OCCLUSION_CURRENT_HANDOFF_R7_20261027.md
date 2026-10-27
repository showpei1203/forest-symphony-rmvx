# CURRENT_HANDOFF_R7 | Forest Symphony 完整Master+同源Occlusion PAR｜2026-10-27
狀態：**R7 12物件 SAM2同源PAR＋隔離真正Game.exe兩輪×15張技術PASS；完整PAR語義/美術 ART HOLD；未修改505頁Boot FAIL。**
根目錄：E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027

- Ground始終是完整SCENE21 544×416美術圖，遮擋PAR都從該Master原RGB逐像素擷取，**不重生成PAR**。
- SAM2.1 CPU使用12組事先由分析者指定的bbox/正負提示/接地點（不是免提示完全自動辨識）；產生12個source-aligned透明物件候選，同源PAR union 49,888px，原色逐點一致；86px候選物件重疊以Pixel Owner合成解決；仍缺full-scene獨立語義真值與人眼Gate。
- R5隔離Map001第三層截到17×13，不是正式SCENE21完整通行權威；218假定可走，4方向真FS $001 pose共872掃描；32px整格覆蓋比原候選多帶47,392px、290個方向/格具有非物件遮擋風險；固定PAR深度衝突13個方向/格、4個格：(3,6)(8,6)(9,6)(12,7)。
- 原生 R7 Game.exe：基於R6原505中的504頁位元相同，原第480頁 Regression Harness在隔離副本停用、新增1頁Adapter（HK145/Animated146/ISS342原樣）；測試5站位（左針葉樹/屋前X8/屋前X9/右石碑/空地），每輪A1/B/A2共15張、兩獨立PID 30真截圖，Threshold0均沒有非角色背景差異及A1!=A2；兩輪A1→B角色像素相同：327/5/354/269/0。R7_FINAL_GATE.json TECH PASS。
- 右大樹R0 raw mask11688px/下方灌木嫌疑區誤收2475px；R7新mask6523px/嫌疑區0px，非人工真值。
- 失敗與修復：WSL無rubymarshal→Windows Python匯第三層JSON；Windows Python無numpy→Pillow計算Gate；都已留錄。
- 尚未通過：真正全圖前景完整性、逐樹逐屋獨立遮擋語義檢查、正式源通行版、四方向真正走路、光影動畫、40x29大型美術、使用者Gate F；第480頁alias錯誤不得藉停用宣稱正式505源成功啟動。
- R8建議：Automatic Mask Generator/文義多物件自動提案 + 同源mask，獨立物件驗收，真通行路徑原生走動，再擴大型地圖與動態Ground。
- 來源K4正式Script SHA256 5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa **未改**。其它對話V6與FS SEALED不動。
- 詳細研究 RESEARCH_REPORT_R7.md。私人圖像與實測PNG留Drive；GitHub只上傳非私有程式與描述，不上傳素材。