# Forest Symphony｜T-C D6 冰脊迷谷｜真正 Ground-first ＋ CompletePAR｜2026-11-22

**本階段新成果：D5 獨立 Ground + D6 全新 RGBA PAR 已真正合成，同一原始畫布，同一座標，形成 46×33（1472×1056）雪谷美術雙圖候選。技術合成 PASS，原始透明度與正式 80×58 規格 ART HOLD，Godot 4.7.2 真原生測試 NOT_RUN。**

## 一、正確產線，沒有再從 Master 逆切

1. Ground：D5 image generation 原始 **1473×1068 RGB**，SHA256 `140dfdc865a7ed299e5bbc8ec8045b2c865ff16ccdc1b7125aa9f0ef6d27071c`，來源保持凍結不變。場景是雪路、冰裂、凍湖與迴路，沒有村屋。
2. PAR：D6 **單獨全新生成**之真透明 RGBA，原始 **1473×1068**，SHA256 `7273b56dc7343d7ad5bd8318e1149e2a4ba2cf4603dcd16b2bfb60f81c62b041`。包含完整雪松樹幹/樹冠、直立冰柱、雪石巨岩、圍籬、木橋、標誌與冰雪遺跡。不是帶虛假 PASS 的展示圖，**也不以是否遮人物排除物件**。
3. 僅為 32px 世界格與 D5 source 一致，Ground 和 PAR 同時採用 `(0,6,1472,1062)` 原像素裁切，得到 `1472×1056`、**46×33 tiles**，沒有對任何圖插值、放大、旋轉。
4. Photoshop/Pillow `Image.alpha_composite` 以真 Ground RGB + 原始/Alpha 技術清理 PAR RGBA 製作 **兩份獨立 1× 合成 PNG**。逐像素重新計算完全相同（RAW / CLEAN 都 PASS）。預覽從不取代來源兩圖。

## 二、可核對實際檔案與 SHA

| 檔案 | SHA256 |
|---|---|
| Ground 46×33 PNG | `3b5dd011b38213ff5d6f2fe82c2d2d5dcae26204f0f64d2a98ebc05772188b4c` |
| D6 新獨立 PAR 原始 RGBA（1473×1068） | `7273b56dc7343d7ad5bd8318e1149e2a4ba2cf4603dcd16b2bfb60f81c62b041` |
| Complete PAR 46×33 原始 | `aa3f537ecd2a7b5172886d89922c8bc5127d43c2b6fd1b56f6c937a708da562f` |
| Complete PAR 46×33 透明度技術清理候選 | `497a7bedf36ef3f2d0ac7771b9326cb5422eb0c78315d3dd7e4b2bbae35ea5fb` |
| 合成畫面 RAW | `8f6a850cdce4f8c40f5fad90cabc6de6641f1d0c057d478b3af19fd4b69b5d30` |
| 合成畫面 CLEAN | `87ff1af3e395b79bbebd8464beb31dee4bad365e88800f6a8e21eacce0b1b9e3` |

## 三、QA 與 Failure Log

- 真 RGBA Alpha Histogram（46×33）：`alpha=0: 329,048`；`1..8: 633,931`；`9..239: 169,227`；`240..254: 422,111`；`255: 115`。
- 原始資料**顯著透明雜色污染**，不是乾淨 PNG。清理候選為 `alpha≤8 → 0`、`alpha≥240 → 255`，只改 alpha 不改 RGB，原始檔永久保存、不得把技術清理版冒稱 AI 原圖完美。
- Source crop 裁邊接觸高 Alpha 像素（≥225）：top 711、bottom 101、left 587、right 595。森林可以自然延伸到邊，但是否切斷完整樹或橋的視覺與可走性，**尚需人工 Art Gate**。
- 雪路、凍湖、屋橋、樹林在整張合成圖**宏觀視覺協調**；並不等於所有橋樑精確對上地面路徑、樹的根部有 source manifest、正式可通行。
- **最重要 Hold：正式 FS_02_MAZE 需 80×58 / 2560×1856 @32px**。本輪是 46×33 完整成對美術原型，禁止 nearest 放大稱原生 80×58。正式 ART PASS 仍 0/12。
- 之前兩次 imagegen 產出的資訊圖已拒收，本輪新 PAR 由真正 RGBA source 建立，**不是從 fake infographic 裁物件**。
- **Godot 4.7.2 真 Native 1×**：NOT_RUN（沒有在這輪拿到可執行的原生引擎與私人圖源 CI），不可拿 D1/C8 歷史 CI pass 填寫 D6。

## 四、私人 Google Drive WRITE → READBACK → VERIFY

**[D6 全部 10 檔 Ground／RAW PAR／CLEAN PAR／RAW & CLEAN 合成／原來源／QA ZIP](https://drive.google.com/file/d/1p6idITcOncKfiGxfUZYINM6nbtq4q99J/view)**，**21,989,010 bytes**，**10 entries**，ZIP CRC PASS，SHA256 `c985c746b67f8d565e29df34ffbbcff8b327cebb7288ada0a9353880d3899dae`。

獨立圖片可直接檢視：
- [Ground 46×33](https://drive.google.com/file/d/1HUH0EBXxkoPMjE8hteTgVxf600cQ7j_s/view)
- [D6 PAR 原始透明 RGBA](https://drive.google.com/file/d/15Tf49Fkntu9Jlc2VT1Ns696bW_MsogoC/view)
- [D6 PAR Alpha 技術清理候選](https://drive.google.com/file/d/138rGgGh7Xv3_yiWRMsVOqYE2CP6ul7lC/view)
- [D6 Ground+PAR 合成圖](https://drive.google.com/file/d/1sIBHnqNnNgKRmHlW7oMK14k0yypYEonU/view)

Google Drive provider 五檔均 readback `shared=false`、僅 user owner；沒有將新生成私有美術圖提交公開 GitHub，也未在使用者 PC 存放任何素材。

## 五、下一整圖單位

保持「Ground first → ALL non-ground PAR」，以這次真正成功的雪谷雙圖作**Style DNA**，另在 **80×58 / 2560×1856 原生世界畫布**一次生成完整 Ground，再另生成同 Blueprint 對位的透明 PAR，兩者都須通過源圖和美術畫布正式 gate。另一方案是將 46×33 當作新的獨立場景尺寸，不能偷改 FS_02_MAZE 正式世界規格。

完成雪原兩張場景的 Art Gate 後按 [FS 世界設定](https://docs.google.com/document/d/1SjVPK3J5exwp0fC3bRMHjoWo2vne_pck/edit) 續做 03 風蝕金砂、04 赤焰火山、05 幽霧水澤、06 星晶浮島，每種村莊＋迷宮。

> 核心：地表 Ground 先獨立完成，所有非地表物件 PAR 後生成。**不要為角色遮蔽重做 PAR；也不要用工程 QA 綠燈冒充玩家看得見的美術 PASS。**
