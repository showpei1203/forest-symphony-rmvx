# Forest Symphony｜T-C D17｜FS_04_MAZE 原生 40×29 Ground-first + 全非地表 PAR 技術候選

**日期：2026-11-23（Asia/Taipei）**　**Engine target：Godot 4.7.2**　**Branch：`feat/fs-tc-d12-chroma-par-20261122`**　**FORMAL ART 0/12 HOLD**

## 真正新增成果

**M1：完整原生 1× Ground + PAR 候選已完成。** 新生成原始 `1474×1067 RGB` 的火山 Ground-only 連續構圖，僅以像素座標 `(90,70,1370,998)` 做一次 1× NO RESAMPLE 裁切，輸出 `1280×928 RGB` 正式世界 Ground，先記錄 `01_GROUND_LOCK.json` SHA。然後沿用 **D15 原本獨立的所有非地表物件圖**以及 D16 已測 `make_par`，不從 Master 抽取；六個物件家族以 1× 像素原比例新配置於 `1280×928 RGBA CompletePAR`。另外產生 Python 真像素靜態 `COMPOSITE_QA.png`，保留 Ground 與 PAR 兩張實際獨立圖。

D16 大量重複岩灰鋪面、羽化貼塊的地表構圖已由完整連續的 D17 新 Ground 取代；工坊搬到左側實地平台，吊車、旗幟落在中央岩台，鐵橋跨右側熔岩谷。請以 [D16/D17 整張對照](https://drive.google.com/file/d/1CG_g2voyl8sL7agIqHTSQHgm2dXHH1d-/view) 做美術比較，而非把自動測試當使用者 ART PASS。

## 來源 SHA、QA

| 實體原圖／產物 | SHA256 |
|---|---|
| D17 新 Ground-only 原始圖 1474×1067 RGB | `30f375d138cccf19e582543b52bff60e9c1f78dfee7b52a8dc93d4aca8632d34` |
| D15 已核准技術來源獨立非地表 PAR 1474×1067 RGBA（未改） | `1063c9bd0180e771da32ffffbcc5c00b6e409bffbc603524c17001010ae0c3a9` |
| D17 新 Ground 1280×928 | `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e` |
| D17 新 PAR 1280×928 | `e455aa491415b453235a11ca0eade3ef2578c937ec7d1f4a6613ccb02bf96334` |
| D17 實際合成 1280×928 | `0213f24d428d00ffa2a7cf233b33ea09e5367270bded24529c9f639edcda3144` |

- 新 PAR `alpha=0` **862,818** pixels；六個配置單位都有獨立世界座標。
- 私有原圖實際 `Ground-first SHA`、`RGBA alpha`、`native pixel identity`、`Image.alpha_composite`、`all 6 source objects` 皆在隔離環境驗證。
- [GitHub CI #45115468630](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45115468630) **SUCCESS**：synthetic test 重建 Ground/CompletePAR、逐像素裁切相等、SHA/模式/尺寸/合成一致及錯誤檔案拒收。**CI 是 synthetic 結構測試，不是 D17 私有素材 Godot native**。
- D17 專用程式沿用 D16 `make_par` 而非重造整條圖層系統：`godot_port/tc_factory/biomes/fs_tc_d17_volcano_maze_factory.py` + `test_fs_tc_d17_volcano_maze_factory.py` + workflow。

## Drive WRITE→READBACK：已確認僅 owner

- [**D17 13 檔完整私人 ZIP，17,262,967 bytes，CRC PASS**](https://drive.google.com/file/d/1mxfxme7PZbdFd7XmwwVGOclSClL1lyls/view)（SHA `192d7d476eda33f1a25a7e05786dc983b27ba57eb2bc004c170dfcd0c33e215c`）。
- [完整 Ground-only 1474×1067 私有原圖](https://drive.google.com/file/d/1yBPhFupgR5bUIIWfiTAbOzuxap-6DGWX/view)
- [Ground 1280×928](https://drive.google.com/file/d/1fHMcvGb6W3AaZvI07uN-GsSrLe0h5c2k/view)
- [全非地表 PAR 1280×928](https://drive.google.com/file/d/1syxXfi7ykoO_s8m4KoE-R6WhnYD-2xb2/view)
- [真靜態合成 1280×928](https://drive.google.com/file/d/1QU0MOktXjbYnQ3Iwf5OLXlRtiNtvQ5r0/view)
- [來源和 Anchor/Alpha QA](https://drive.google.com/file/d/1SOkyHXmW2IuBsaTpVWehw4Sya4GJ6Gci/view)

所有重要 Drive 項目實際 metadata `shared=false`、permissions 僅 user-owner。原始來源和二進位藝術不放公開 GitHub。D11/D15/D16 均保存原件。

## M1／M2／M3／M4 與 Failure Log

| Gate | D17 真實結果 |
|---|---|
| M1 來源、完整新 Ground、獨立 PAR、畫布/透明/靜態合成 | **TECH PASS** |
| M2 D17 私有圖片 Godot 4.7.2 native 1× framebuffer | **NOT_RUN / HOLD** |
| M3 D16 Ground 大範圍材質重複、工坊踩熔岩 | **宏觀修正 TECH PASS** |
| M3 D16 既有 PAR 多邊形截斷與部件接合 | **HOLD** |
| M4 第二樣本量產 | **FS_04_MAZE 技術樣本已建立，不是美術 PASS** |
| VISUAL_ART | **HOLD** |
| INTEGRATION：事件、戰鬥、讀存檔 | **NOT_RUN** |
| FORMAL_ART | **0/12** |

**明確阻斷／故障：**
1. D16 重組 Ground 有多重羽化道路與重複熔岩圖章，D17 以獨立完整 Ground-only 原生像素地表改方案，不再補一堆微小碎片。
2. D17 `make_par` 繼承 D16 Polygon 裁切：目前來源正 Alpha 像素有 **16,915** 個被 Trim；左上工坊岩石不規則裁邊、右橋欄杆連接、上側局部管件仍需更高階 CompletePAR 一次性作者化。額外 867 個不透明重疊像素（旗幟與其他物件），如實保留，不做 ART PASS。
3. 額外圖像生成嘗試返回了含 Ground+建築的完整 Master，違反獨立 PAR 來源契約，**拒收，沒有當作素材或重新反切**。
4. 本次執行容器沒有已驗證的 Godot 4.7.2 binary，官方下載不通，不能把 CI 上次的 synthetic native 合成驗證借來當私有 D17 Gate。Windows PC Bridge 並未驗證 D17 私有來源安全導入白名單，**不越權操作、未修改 Windows E:、Remote 0、Codex 0**。

**下一完整施工單位：** 在不重做 D17 Ground 的前提下，針對已鎖世界畫布作者化**整張真正不切斷橋梁/屋舍的新獨立 CompletePAR**，保持所有非地表物件及世界座標而非用 Polygon 拼片；經授權讓私人兩張 PNG 進入 Godot 4.7.2 原生 1× Renderer，核對橋頭、足點、輪廓、視覺風格及 user Art Gate。若無原生私有傳輸授權，依規 HOLD，不得假裝 native 已跑。
