# Forest Symphony Godot Ground/PAR Art CURRENT_HANDOFF｜A36（2026-11-14）

**Godot 主開發 PR #16；事件、NPC、戰鬥在另一個對話。本分支只管美術／Ground-first／完整獨立 PAR／大地圖與六地形規劃。**

- **最新可用實作**：`res://scenes/a36_large_verdant_forest_80x58.tscn`，真正 2560×1856（80×58×32px）新的森林 Ground；**非複製鏡像 A34 Ground**，也不從完整圖分割 PAR。
- 原生成 Ground 為 1478×1064 → nearest 2560×1856，保留 original + exact source SHA。**非原生 pixel-perfect 尺度，ART HOLD**。
- **326** 個完整獨立 PAR：310 樹（四類）、2 完整房屋、6 路燈、1 井、7 岩石。獨立 SHADOW PNG / YSort / 足點及物件碰撞形狀；河流禁行 148 格只是語意**候選**，並未匯入完成的碰撞系統。
- 真實 Godot 4.7.2：原生素材 **2301 checks PASS**、2,560×1,856 native screenshot 以及原生樹前後 544×416，來源/拓撲 Python **1633 PASS**；全新乾淨移除私人圖片後的 Godot **2306 checks PASS**。獨立從 A35 冷重建 8/8 關鍵檔 SHA 一致，冷 Godot 2301 PASS。
- **已完成的是大型分層地圖技術樣板，不是美術封版。** 樹群重複與原始生圖縮放感仍要改善。六地形/12 地圖依 `data/fs_six_biomes_world_catalog.json` 長期規格，**尚未製作**。
- [詳細 A36 Failure Log / QA / 下一施工步驟](docs/A36_LARGE_FOREST_GROUNDFIRST_HANDOFF.md)。
- **最重要：** Active Master v1.3 Ground-first → 完整獨立透明 PAR → Godot → 1x 美術驗收，不回到 Master-first 切割；不寫事件、不碰 main、VX/使用者 PC。

## A36 雲端私人封包已驗證

- **Owner-only Drive 完整 212-file Godot A36 工程**：[A36 full private ZIP](https://drive.google.com/file/d/1_RuQUGpURoASJmJ6_H0tEtNESz_FjmQU/view)，**55,657,235 bytes**，SHA256 `1877cfef806b907243b9bc4714713422d484e3ae651314e09094cc385be6c760`；上傳、重新下載、ZIP CRC、211 個內部檔案 SHA256 **PASS**。
- **真正 Godot 4.7.2 原生 1x 全圖（2560×1856）**：[Drive 原生完整 PNG](https://drive.google.com/file/d/1Hq5WLRNpBj91k90B5PVxhBpLPQo2lv3i/view)，另有 [手機全圖預覽](https://drive.google.com/file/d/1ZSawHsLoC7u9GGKwFY5XQAz9ZvxhBnxJ/view)、[原生角色樹前後 A/B](https://drive.google.com/file/d/1KjCPdJZpH_ARs9Hjcqrn3g6mQx-gZc6u/view)。
- [A36 詳細 QA、Failure Log 與接續工序 Drive 鏡像](https://drive.google.com/file/d/18Wp5Io5UHfMuwwNj-KPHuNzYKDyCl9rP/view)。私人像素素材無公開到 GitHub。正式 1x 美術、溪流碰撞與水動畫仍 **HOLD/NOT_RUN**。

### A36 R2 安全修訂（取代 R1 作為正式下載）

- **正式主封包改用 [A36 R2 owner-only Drive](https://drive.google.com/file/d/1LgUCJRi8i-NDz-EC1roXHWnBjNysjtuu/view)**：**212 files, 55,658,735 bytes, SHA256 `6f7bbcccc8bff0e9389039dda0e77d534196c48382716c13fb7539bb32cff58c`**。Drive upload/download raw、整包 ZIP CRC、211 file SHA **PASS**。R1 保留為舊記錄，**請勿繼續使用 R1 的生成腳本**。
- R2 將生成器改為 **拒絕任何已存在輸出資料夾**（不會 `rmtree`、覆寫來源或使用者專案），另用全新隔離資料夾冷重建，Ground、Scene、Manifest、SHADOW **4/4 SHA byte-exact**；第二次對相同目的地執行會在寫入前拒絕，該拒絕為預期的 P0 安全測試 PASS。
