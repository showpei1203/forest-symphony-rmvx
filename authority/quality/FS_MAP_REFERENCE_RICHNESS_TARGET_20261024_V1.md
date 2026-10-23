# FS 地圖正式品質門檻｜參考圖豐富度 Authority v1
2026-10-24｜QUALITY TARGET LOCKED｜不得誤稱 VISUAL PASS

## 使用者新決議
後續開發完成的地圖，以 Drive 六張範例地圖的視覺複雜度、材質變化、建築與植被細節、地形層次、物件家族與探索豐富度為目標。比對同類地圖，不強迫所有場景使用同一類物件。
原圖資料夾：https://drive.google.com/drive/folders/1_p2Yq27CT4poSzvVp9nhVE8u3_9KfMj9
原有品質研究：https://docs.google.com/document/d/1Mv-ijuSH432yTd3ZtuK5Afj3daQYxuLTrKJYpGOAzI0/edit

## 已直接查看的六張原圖
- ground3 (1280x928)：多棟木屋／酒館、不同屋型和尺寸、林冠、分岔土路、連續斷崖及階梯、公告欄／井／木箱／花叢。這張原圖沒有展示河流及跨河橋，精靈村河橋是另外的設計需求。
- ground12_4 (1280x1280)：多帳篷、商販攤位、旗幟、柵欄、箱桶、生活與軍需陳設、連續可通行的營地道路。
- ground2_1 (1280x1600)：多高度洞窟、深淵、橋梁與支架、門、火把、晶礦及岩壁，必須處理上下高度、橋上橋下與遮擋。
- SCENE04 (544x416)：高台草地、不同高度、階梯、外圈水岸、立體崖壁、差異化植被／碎石／花叢；橢圓舞台黑幕不是遊戲 Ground。
- SCENE21 (544x416)：濃密針闊葉樹混植、苔蘚建築、花叢、石材、森林邊緣與主地標；教堂不能直接當精靈村神聖樹。
- SCENE001(1) (544x416)：木屋、井、圍籬、公告欄、木柴、桶、箱、細緻草路接縫，屬小型場景敘事密度範例。

## 雙重完成 Gate
T 技術 Gate：維持 FS v3.2 A-F，Blueprint/Manifest 同源編譯 Ground、PAR、Owner/Occlusion、Collision、Height、Events；1px 故意偏移負向驗證、VX 原生走圖、LOG、真人實機驗收。
V 視覺 Gate：同類原圖 100% 倍率對比，獨立判斷：V1 地表/路緣/水岸自然過渡；V2 主地標與前中後景層次；V3 合理高低差及功能分區；V4 真不同物件輪廓而非同圖換色；V5 大、中、小道具與環境敘事；V6 合法走道與可達入口；V7 32px、像素銳利與材質/色系一致；V8 拒絕平鋪空地、雜訊堆砌或擁擠到無法行走。
任一關鍵 V 條件失敗，即使 T 全部通過，也只能稱 TECHNICAL PASS / VISUAL CANDIDATE；直到 V 與使用者人眼審核通過才可稱正式完成地圖。

## 地圖類型對照
森林：SCENE04 + SCENE21；精靈村：ground3 + SCENE001(1) + SCENE21；營地：ground12_4；洞窟：ground2_1；城堡鎮需取得城鎮建築/街區/城牆專用參考，以同級細節與層次驗收。
精靈村沿用 B1 額外設計：至少三種真正不同建築輪廓，旅館、商店、樹屋、神聖樹、河與可走橋梁。勿錯把這些全部說成 ground3 原圖已有。
17x13 Forest Game.exe 已由使用者驗收 PASS，定位為技術回歸基準，不代表正式地圖達參考級美術。

## 交付要求
每個正式場景應附 Ground/PAR/Collision/Height/Events、Source/Manifest、來源與授權、100% 全圖/局部對照、差距報告、可執行 VX Test Build、LOG、Gate A-F、V Gate 與真人視覺驗收。
六張參考圖為 Flattened CONCEPT，不可直接當成合法透明 Ground/PAR 輸出；未核准第三方素材不能升格 Approved 或公開再散布。正式 sealed FS runtime 不得被更動。

原圖連結：
ground3 https://drive.google.com/file/d/114CDKKySuzyuuwxRonhx8ebBsgX3ZFww/view
ground12_4 https://drive.google.com/file/d/1uZeQcZpLlKRjSDtDoij0NGu6G_1_xOtI/view
ground2_1 https://drive.google.com/file/d/14bWMHEZn8YvuG4J_z5zVJ0dajE5C3c_R/view
SCENE04 https://drive.google.com/file/d/1ET02jvJH2OpGV4w743-Pn_AppCiQ4ysk/view
SCENE21 https://drive.google.com/file/d/1lhnrtZ-4e128B9hRFUZEtmjWrOX7zv89/view
SCENE001 https://drive.google.com/file/d/147o-yqYuZ_xM18iZHFLaoRtWe1y2Bmx7/view