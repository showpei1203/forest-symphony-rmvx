> **A21 CI VERIFIED (2026-11-10)**：GitHub Actions [Run 42804806871](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42804806871) completed/success；日誌確證 **148/148 synthetic tests PASS**（包含新增 A21 的 11 個單元測試）。它只驗證程式邏輯，不代表 PixelLab 新圖、Art 或 VX 通過。

# A21｜真實 Master Ground/PAR 原像素遮擋 Pilot（2026-11-10）

**狀態：SOURCE REAL / SAME-XY PIXEL PASS / CONDITIONAL SIM PASS / ART PENDING / VX NOT_RUN / PixelLab NEW FRAMES 0**。
唯一方法權威仍為 authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md，main、A11/A18 舊封包未動。

## 真實輸入與私人雲端封存
- A11 原始私人 ZIP 19,807,540 bytes SHA256 3131fc99ba5d19f5d6328cfd43068ebea2ddda2d50486576b430df71fe7bc910；內含真正 1280×928 Master，PNG SHA256 091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530。
- A18 原始私人 ZIP 19,706 bytes SHA256 f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c；核准 F0 48x48 PNG SHA256 a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba。
- A21 真正輸出 FS_A21_MASTER_OCCLUSION_REAL_INPUT_PILOT_PRIVATE_20261110.zip 16,615,073 bytes / 12 files / SHA256 35a4268baf874c94ac8bd903f362410a8081933fa2d91a324f086908f2008981。上傳 owner-only Restricted_Binaries，重新下載，大小、SHA、ZIP CRC PASS。私人 Drive ID 與 PNG 沒有進公開 GitHub。
- 使用 A11 既有的左、右樹冠候選 Mask 和橋近欄候選 Mask；它們沒有得到使用者 ART 核准，也不是本輪新 SAM 產物。

## A21 真正新增程式
- tools/asset_factory/a21_runtime_occlusion.py：輸入原 Master bytes + 物件語意 + binary mask + SHA + X span + footpoint y threshold，輸出原 Master 位元組和源於同一 XY 的 Runtime PAR。
- 只有 tree_canopy / roof_front_eave / bridge_near_rail / cliff_top 可選前景；grass、flower、path、bridge_deck、water、low vegetation、shadow、ground 不可混入。
- 驗證來源 SHA、全畫布 32px grid、原圖不透明、Mask 0/255、來源 ID 無重覆、Mask 無重疊歸屬、橋面負例、同 XY 完全相同 RGB。
- 腳點條件依真世界 XY 決定 foreground 是否啟用；這是視覺 proof-of-concept，**不是 RPG Maker VX 原生 Switch203 兼容認證**。
- tools/asset_factory/tests/test_a21_runtime_occlusion.py：11 個 synthetic regression cases；本地 Pillow 單測 11/11 PASS，雲端 CI 成績另核查。

## 真實 A11 Master + A18 F0 的四個位置試跑
| 測例 | Actor 腳點 | 啟用 Mask | PAR Alpha pixels | 來源 RGB mismatch |
|---|---:|---|---:|---:|
| TREE_BEHIND | (232, 556) | left_tree_canopy | 33,600 | 0 |
| TREE_FRONT | (232, 596) | NONE | 0 | 0 |
| BRIDGE_BEHIND | (735, 621) | bridge_near_rail | 1,421 | 0 |
| BRIDGE_FRONT | (735, 670) | NONE | 0 | 0 |
| ALL_ON TECHNICAL CANDIDATE | N/A | 3 masks | 90,076 | 0 |

## 不能忽略的缺陷
1. A11 Master 與 A18 48px 像素人物風格不同，此結果不能當 Ground3 同風格美術驗收。
2. TREE_BEHIND 模擬中人物部分被過度遮蔽，表示只用單一物件 y 門檻仍不夠；要做更細緻源 Mask 與合法腳點語意，不能當 ART PASS。
3. SAM / PixelLab 地圖新生成 / 真實 VX Game.exe / Switch203 / RGSS2 native 都沒有執行；不要以這次 Pillow 圖宣稱地圖已完成。
4. PixelLab Codex MCP 仍是六項唯讀，A18 provider POST 未執行，生成新三幀為 0。不得未授權改安全設定或花費。

## 下一個真正施工門檻
1. 角色：在正式限額及受限操作可用後只跑一次 A18 Skeleton v3，保存 RAW 三幀/Job ID，再做 ART 與 VX。
2. 地圖：從真正 ART Master 用 SAM 或來源物件 Alpha 提出可審核遮罩；以 A21 engine 检查同 XY 與 footpoint，再取得 ARTPASS。
3. VX：在授權隔離原生 Game.exe 確認 real_x/real_y、depth 及 Switch203，至少樹前後、屋簷前後、橋兩側、草路負例。
4. PR #15 Draft 與 main 不混淆，正式檔繼續私有 Drive、程式與 Handoff 保留公開 GitHub。

此處為工程測試驗證，不是美術封版。
