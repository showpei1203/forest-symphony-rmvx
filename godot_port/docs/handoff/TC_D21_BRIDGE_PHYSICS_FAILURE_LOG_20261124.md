# FS T-C D21｜Failure Log｜FS_04_MAZE｜2026-11-24

## D21-F01：碰撞測試 PASS 但角色站在前欄杆（REJECTED）
- 原因：第一次人工暫定橋面中心線設為 y=530，實際 Godot native 1× 細圖顯示玩家代理站在橋前側欄杆上。
- 處理：依 D19 真原生視覺把中心線改成 y=500；上、下暫定 StaticBody2D 欄杆矩形分別 (788,461,363,21)、(788,518,363,25)，實際兩版重新執行。
- 驗證：D18、D19 各雙向 74 物理步，東端(1106,500)、西端(812,500)、零碰撞；上下越欄兩例均回報對應 `QA_UPPER_BRIDGE_RAIL` / `QA_LOWER_BRIDGE_RAIL`。
- Gate：**provisional QA PASS**，真實遊戲碰撞尚無正式作者資料，仍 **HOLD**。

## D21-F02：完整 CompletePAR 下方角色徹底消失（CONFIRMED BLOCKER）
- 原因：該橋面完全位於單張全非地表 PAR 中，真正源圖 Alpha 在橋面中央為不透明。
- Godot 本機截圖：角色 `z=1` 完全 PAR `z=2` 下方，與 actor hidden 的 base PNG **完全相同 SHA**、**0 像素不同**。
- 暫定修復：使用橋面特定區域動態 `z=3`；真 Godot 畫面中測試代理顯示 **225 像素**，D18、D19 一致，無需變更 Ground/PAR 原始圖。
- 阻斷：此暫定規則會把角色也畫在前側欄杆上，仍需正式 runtime 深度設計／actor 融合／人眼 ART 審核；**不等同正式角色渲染 PASS**。

## D21-F03：來源版本錯配與污染（NEGATIVE PASS）
- 真 Godot 引擎將 D19 PAR 假冒 D18 來源：`exit=2`，`Wrong or altered independently authored D18 PAR`。
- 真 Godot 引擎將 PAR 假冒 Ground：`exit=2`，`Wrong or altered locked D17 Ground`。
- 均不產生可冒充成功的 QA JSON/渲染輸出。

## D21-F04：缺乏正式整張地圖碰撞和玩家走位（KNOWN HOLD）
- 本輪只建兩條**人工暫定**欄杆矩形，並未建立火山熔岩、峭壁、屋舍、NPC、正式橋頭、ACTOR01 移動邏輯、事件、戰鬥或存讀整合。
- 真實引擎測試結果僅證明受限測試 Corridor 的 2D 物理與順序功能，非全 FS 主程式運作。
- **ART PASS 0/12**；正式圖不可直接交付。

私有完整 QA ZIP：[32 檔、CRC PASS](https://drive.google.com/file/d/1ojoEcCcZ2lndkR8JOEl4G18qys-HC4vW/view)；[四圖 native QA](https://drive.google.com/file/d/1AnnshQIzgvl1XeyVHV7eCqnCQLvvPgjl/view)；[完整數據](https://drive.google.com/file/d/1ka5u3-sTD3y5s9NMjOi7HOlJbtXpZ7I3/view)。正式下一宏觀施工：整合既有 Godot 地圖角色控制與明確作者化道路／橋頭／熔岩碰撞，針對一張可遊玩 FS_04_MAZE 打通真正進出橋梁＋NPC／讀存 smoke，**不重生 Ground，不把暫定碰撞自動算正式**。
