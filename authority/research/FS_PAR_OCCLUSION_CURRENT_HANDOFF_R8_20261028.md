# FS CURRENT_HANDOFF_R8 | Annotated RED/BLUE PAR Research｜2026-10-28
**R8 已完成**：8紅圈物件強制納入SAM2獨立同源透明PAR、1藍圈房前石階強制排除；原生VX 20 source occluder actor depth，2獨立Game.exe×18張=36張，所有A1/A2控制=0、非角色A/B=0，RGB threshold0結果：房側針葉樹0、最右針葉樹313、左下微物307、下方灌木463、藍階0、空地0。紅側針葉0因選站位無角色交集，不代表沒有遮擋；四方向離線實際FS $001 sprite確有樹後 261px 遮擋候選。

Baseline R7: 紅圈8個中心seed在R7 Alpha皆未達門檻；藍圈有717個Alpha誤收。R8加9,265Alpha px、刪717px藍區，R8總PAR58,436 source RGB exact. SAM2 prompt 8/8（起初R07反例位置錯誤只7/8，已修）；8/8紅seed>0，藍中心0。20動態Sprite均已排藍。

重要：用者標註圖 548×400 帶不同tone，原Master544×416；R8 box目前目視近似配準，非手標完整pixel真值／非美術Gate。R5測試專用218個假可走格，不是SCENE21正式Map通行。原#480 regression已存在Alias錯誤，在隔離副本停用；其餘504正式原始頁byte identical，HK145/Animated146/ISS342原頁不變；505正式封版完全不動。

本機：E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027；檔案 `RESEARCH_REPORT_R8.md`、`R8_USER_ANNOTATION_20261028/R8_USER_ANNOTATION_AUTHORITY.json`、`R8_SAM2_USER_ANNOTATION_RESULT.json`、`R8_NATIVE_FULL_MASTER/R8_FINAL_GATE.json`。
R8 Native兩輪 PNG／VISUAL contact、失敗紀錄與可重跑script均保留。GitHub authority研究文件和Drive私人增量ZIP另見同步結果。
**R9優先**：真使用者標註圖與master像素座標配準、全場前景物件漏項／邊界美術QA、真FS對應地圖通行與四方向移動實測、光影循環和40x29。封版 Gate F 仍 HOLD。