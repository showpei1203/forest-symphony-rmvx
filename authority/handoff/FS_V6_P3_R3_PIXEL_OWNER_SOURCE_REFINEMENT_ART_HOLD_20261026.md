# Forest Symphony V6｜P3 R3 房屋/屋後植被 Pixel Owner 精修（2026-10-26）

**結果：12/12 新增 Tech QA PASS；正式 ART / Human PENDING；原生 VX Game.exe NOT RUN。**

## 真實施工
Windows Remote Desktop Commander 已於隔離工作目錄 `E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261026\P3_R3_PIXEL_OWNER_REFINEMENT_20261026` 完成：針對上一版 261×183 木屋 R2，找出左緣 **9個面積1～4px之完全脫離主體的小色塊，共21px**。保守版 R3A 僅清除這21個 Alpha像素，其他來源 RGBA 均原樣保留。

R3B 測試另清掉屋頂左後方 **367px** 綠色植物，結果在屋頂旁留下肉眼可見的破洞，故 **R3B ART REJECTED**，保留作失敗對照，禁止推進。

正式 R3改為將367個原始像素**移入獨立 `ROOF_BACK_FOLIAGE_FRAGMENT` 語義圖層**，並維持 `HOUSE_ARCH` 和 `HOUSE_FLOWERS` 的互斥所有權。三層來源 Alpha/保留 RGBA 精確重新組合 R3A；**該片段不是可獨立重用的完整植物Source**，不能因此冒稱整棵灌木已處理好。

原花叢57×57的外緣共211px，其中52px偏暗，但分析顯示**這52px都是不透明深色陰影，不屬半透明污染**。本輪花叢圖像維持原樣，避免誤刪葉片造成新的破邊；專項 Alpha 完整度仍待人工。

## 全圖與碰撞 Gate
- B Ground 原始 SHA維持不變，R3世界相對上一版R2恰好**只變動21px**；三層房屋 Pixel Owner 無重複／無遺漏，RGBA重組零差異。
- `544×416／17×13格` Ground、房屋、樹、花叢世界仍由唯一 Scene Manifest 輸出來源及 PixelOwner mask、四種真 VX Actor1前後站位，2×nearest預覽。
- 15／221格實體 Footprint 阻擋，屋門前一格可走，從spawn可到門前，soft花叢仍可走；樹木強制偏移1px負測檢出**28,973px**差異。
- **12/12 Tech regression PASS**。封包冷解壓核對**57檔 SHA256**，在獨立目錄重編譯同一世界圖，PNG SHA再次一致。
- ZIP `FS_V6_P3_R3_PIXEL_OWNER_SOURCES_TECH_CANDIDATE_20261026.zip`，**10,687,796 bytes**，SHA256 `cdf9b46bac2a1e1fafa39e52344396708e8583b368f61da4d285b317e478e5ce`；世界合成圖SHA256 `6c3d52b51124e557ecc9f08273a5b08012dd66ddaad13a82530797e3411b9da8`。
- Google Drive 私人 ZIP：https://drive.google.com/file/d/1Y86zghGBQikt3etJbv7kiup2fDjqsDNj/view （遠端 G: Desktop copy＋Drive connector下載回來 SHA256完全一致）。
- 可重跑編譯器：https://github.com/showpei1203/forest-symphony-rmvx/blob/main/tools/fs_map_v6/compile_r3_pixel_owner_sources.py （私有圖像/角色素材只存在私人 ZIP，不上傳公開 GitHub）。

## 失敗與未完成
- **FS-ART-108｜OVER-SEGMENTATION**：R3B 移除367px屋後植被留下破洞，技術本身可算 ownership，但藝術明顯失敗；正式R3保留367px並改成獨立 Fragment source。
- **FS-ART-105｜FLORA DARK EDGE**：52個暗外緣像素不透明，不能假定髒邊、粗暴刪除；需來源高精度Alpha Art人工判定。
- **FS-ART-107｜GROUND CONTACT**：屋腳花圃根部仍可能混著舊地面質感；R3沒有取得「接地完整漂亮」之 Human PASS。
- 本版無 RGSS2 `Game.exe`、VX events、camera scroll、實機透明度／foot traversal 測試，**Native=NOT RUN**。F1R1 A04和其他SEALED及平行施工檔皆保持不動。

## 下一個實際步驟
P3 R4 應驗證 house flowerbed 物件與 Ground B 的 1× 真遊玩比例以及 Source Root Transition；接著才使用隔離 Native VX `Game.exe` 測門前走格、樹冠前後、花叢 soft passability 與事件／鏡頭。未取得使用者人眼美術接受前，不能宣稱 P3 ART PASS 或完整精靈村達標。

總規格：https://docs.google.com/document/d/1aypbyssZaYh1SG8cae0iK98JW5ufU__xcXA-q3gLZu8/edit。
