# Forest Symphony A34｜Ground-first 完整獨立房屋 PAR｜原生驗收與 Handoff
日期：2026-11-14 | Godot 4.7.2 stable | Art：**HOLD** | Engineering：**PASS** | 正式封版：**NO**

## 1. 保留的使用者正式製作規則
- Active Master **v1.3**：先繪製高品質 **Ground-only**，再**獨立製作完整透明 RGBA 房屋／樹／燈／橋等 PAR 物件**，最後交由 Godot YSort、腳點和獨立碰撞合成。最終 1x 豐富度必須達到完整一次生圖參考。
- **本輪沒有使用任何完整場景分割來生成房屋。** 新房屋來自兩張各自獨立完整的透明 RGBA 原創生成圖片；各自只裁透明邊界、等比例降至適合 32px 場景尺度，整個屋頂、牆體、附屋、花台、台階一併保留。
- 舊 A32 Ground-only `private_assets/ground_only.png` SHA256 **`3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`** 完全沒動。A33 路燈、A32 圖資及原封版 VX 沒有覆蓋。過去 Master crop 只是歷史測試，不能代替此產線。

## 2. 兩棟獨立房屋資產

| 對象 | 舊來源尺寸 | 新獨立 RGBA | 新檔 SHA256 | Godot 足點 |
|---|---|---|---|---|
| 左側工坊合併主屋 | 254×252 | **288×282**（完整主屋＋附屋、石板屋頂、門廊、窗、燈、花草） | `2a4e50666bbd3acb89147b3ab844d5c998ad796bf98a8687a4a9428f33e2a741` | (285,406) |
| 右側住屋／工作室 | 214×252 | **252×252**（單家族苔蘚石板屋頂、主門、側屋、台階、花窗） | `9936140695863a679f62e4a295373a706a7a92f6308965903adc3b64e1139da6` | (1046,419) |

- 新檔：`private_assets/independent_par/a34_elf_workshop_house_complete_288x282.png` 與 `.../a34_elf_residence_atelier_complete_252x252.png`。
- 真正完整生成圖片原始檔私有保存為 `private_assets/a34_source_left_workshop_complete.png`、`private_assets/a34_source_right_residence_atelier.png`。來源原始圖片與衍生的 1x 完整 PNG 均 SHA256 鎖定於 `data/a34_groundfirst_full_houses_manifest.json`。
- 146 個 Godot 編輯器可選的 PAR 實例、27 種獨立物件家族、四盞 A33 路燈及 **140 個既有足點碰撞**保持不變。只替換兩個房屋 Sprite2D 來源與尺寸，原房屋、A33 場景和來源留存，允許視覺回退。

## 3. 已確實執行的 Godot 測試
- `--headless --editor` Godot 4.7.2 原生匯入 Scene 成功、無 Script Error/Parse Error、無遺失節點警告。
- **真實私有原圖 QA：** `res://tests/test_a34_full_houses_real.gd` **1,036/1,036 PASS**，包括 Ground SHA、兩張完整新 RGBA、146 個來源／尺寸／座標、既有 CollisionShape、A33 Scene 保留、每個其他資產來源不變。
- **原生老工程回歸：** `res://tests/test_a33_lantern_real.gd` **760/760 PASS**；`res://tests/test_a32_groundfirst_real.gd` **734/734 PASS**，沒有因獨立換屋破壞舊版本。
- **沒有私有素材的乾淨公開工程：** `res://tests/test_a34_public_contract.gd` **744/744 PASS**；來源代號、完整房屋節點、所有腳點、A33 路燈都能解析，但這不是 Art PASS。
- **真實 Godot 4.7.2 / Mesa llvmpipe OpenGL Framebuffer：** 4 張 1280×928 截圖：A33 舊屋、A34 新屋、左右門口角色；另有以兩張原生畫面 1x 裁切的 A/B 比較圖。**A33 vs A34 全圖變更 80,256 個 RGB 像素、房屋兩個真實 ROI 以外差異 0**。代表 Ground 和其他區域沒有被重畫，不代表新房美術已通過。
- 真實 QA JSON：`qa_a34/A34_NATIVE_DIFF_QA.json`，場景名稱 `scenes/a34_groundfirst_full_houses_scene.tscn`。

## 4. Failure Log／藝術待辦
- **A34-F01：** 舊 A33 兩棟苔蘚屋屋頂與牆面塊狀、細節嚴重低於原 Ground，已替換兩張完整獨立房屋，不再從完整場景硬切。改善從 1x native A/B 可見，但**使用者尚未 Art PASS**。
- **A34-F02：** 新房增加更多立面、側屋與台階，尺寸和視覺比例已可用，然而現有根部矩形碰撞仍是 A33 舊建築足點，**不能宣稱新門口可走**。要從新房門的實際 XY 重新設計 doorway/contact/door-trigger，而不是繼續沿用原矩形。
- **A34-F03：** 新房像素細節比既有部分樹木密很多，整體美術未完全協調。後續應批次修正**獨立完整樹木家族的比例、色調、簇集**，不得以整張 Master 或模糊 Ground 來掩蓋風格不一。
- **A34-F04：** 原始 A32 Ground 沒有建築專用入口小徑、接地陰影及前庭的完整視覺連結。可以獨立生成低矮庭院物件／獨立接地 SHADOW 和局部 Ground 裝飾，但不得重畫既有 Ground 來假裝成功，也不允許在 PAR 內烘焙環境光。
- **A34-F05：** 生成的完整場景圖片（若有）只能當**美術豐富度參照**，不得當作兩張獨立 PAR 的來源。本輪在 Godot 實際匯入的只有兩張原創**完整房屋**來源。
- 尚未驗證：新門洞與角色行走、四方向城鎮走路、NPC／事件、完整水岸路網、Windows 遊戲輸出、正式 Ground3 美術封版。均 HOLD/NOT_RUN。

## 5. 實際可延續的程序
1. 保留 A33 主場景不動，使用新場景 `a34_groundfirst_full_houses_scene.tscn`。
2. 每張新完整房屋先存 owner-only 原始透明 RGBA，記錄 SHA、實際 bbox；用 `tools/a34_build_from_independent_house_sources.py` 的獨立物件程序，鎖定 1x 素材。
3. Godot 實際執行 `test_a34_full_houses_real.gd`、原生 framebuffer 捕捉以及 `validate_a34_native_diff.py`；舊 A32/A33 回歸 PASS。
4. 優先完成**新房正門的可走足點、碰撞邊界、DoorArea2D/進門事件**，其次研究完整獨立樹木族的美術一致性。
5. 每階段 Drive owner-only ZIP 交付／SHA+CRC readback、GitHub Draft PR 程式＋CI＋Handoff；正式 `main` 和舊 VX 保留不動。

## 6. 雲端狀態
- **GitHub PR #16**：Godot-first 專用 Draft，不合併 main。A34 public source commit/CI 驗證待本輪實際完成後補記。
- **Google Drive owner-only**：私人完整 ZIP、原生圖與 Handoff 請看本輪上傳憑證。不能用工具上傳「成功」代替下載 SHA/CRC 驗證。
- 沒有在使用者電腦寫新檔、也沒有付費 PixelLab API 呼叫。**Formal Seal NO**。

### A34 owner-only cloud verified (2026-11-14)
- [完整 184-file A34 私有工程 ZIP](https://drive.google.com/file/d/1VskVH2ghTgv7HYAaanLBYikjLLQhKw6A/view)：**79,844,278 bytes**、SHA256 **`ed15669314d59bee9d3fa16c9ced09855c153be090ac6795b8568f0455a550bc`**，Drive 上傳→原檔重新下載後 SHA256、ZIP CRC、184/184 entry 和 183 筆 member manifest **PASS**。
- [真實 Godot 4.7.2 全圖 1x](https://drive.google.com/file/d/1ReUpQHR6Y8PC0i2H27Hh6gDMlDCl3ErV/view)；[兩棟房屋真實 Godot A/B 1x 對照](https://drive.google.com/file/d/1vd5Yk5ft5_kAD_UEnTYenmVSq_HvBG7b/view)。
- 可重建：`tools/a34_build_from_independent_house_sources.py --a33 <previous-owner-project-dir> --output <fresh-dir> --workshop-png <private-whole-workshop.png> --residence-png <private-whole-residence.png>`。已在不同隔離目錄重建，兩房 PNG／場景／manifest／a34_world.gd **5/5 SHA 完全一致**，Godot 4.7.2 再執行 1036 PASS。
- 來源完整 PNG／生成高解析 PNG／Godot 原生 QA 私人持有，**未在公開 GitHub 上傳原圖**。Source-only GitHub CI 實際結果待最後提交後回填 Handoff；美術與門口仍 HOLD。
