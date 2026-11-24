# Forest Symphony｜T-C D16｜FS_04_MAZE「熔脈裂橋」Ground-first + CompletePAR 技術完整候選與 Failure Log

**日期：2026-11-23 Asia/Taipei**　**引擎：Godot 4.7.2**　**分支：`feat/fs-tc-d12-chroma-par-20261122`（Draft PR #17）**　**正式 ART：0/12 HOLD**

## 1. 最新權威與操作路由

本輪讀取 T-C D15 CURRENT_HANDOFF、D15 Failure Log、十二圖 scene ledger、三線 Roadmap、T-C Launch Prompt、Ground-first Google Drive SOP、私人 Bridge 的 AI PC Routing Protocol 與已正式存檔的 `fs-map-ground-par`／`fs-godot-testing` SKILL.md。以使用者最新「Ground 先獨立生成 → 所有非地表獨立 CompletePAR」為最高美術來源權威，覆寫舊 Roadmap 中 Master-first 分層方案。不按玩家遮蔽選取 PAR，不從 Ground+物件混合 Master 逆切。工具路由：直接 GitHub / 私人 Drive + 本輪隔離 Python 技術出圖；未使用 Windows Bridge、Orca GUI、Codex 或 Desktop Remote（0 次）。

## 2. D15 原火山村落 1280px 無損容納試驗：HOLD

在真正 D15 `1474×1067 RGBA` 上試做 **只移除 alpha=0 像素的自適應 1× seam reflow**，不允許損失任何非透明像素：

- 要到 `1280×928` 需從寬度刪除 `194px`、高度刪除 `139px`。
- 計算得到縱向連續透明 seam 僅能移除 **71px**，橫向連續透明 seam **0px**，之後會被建築／欄杆／橋梁的實體物件阻擋；不得以這種做法宣告 1× 無損完成。
- 另一張 D16 透明 AI 輸出仍是 `1473×1068`，半透明背景嚴重；另一輪模型輸出整張有建築的 Master，不是純 Ground；全部拒收。
- 此阻斷不能靠重複中心裁切／縮圖解決，需重新創作原生畫布物件構圖。

## 3. 已實際完成的第二場景全雙圖「技術候選」

新增 `FS_04_MAZE`（赤焰火山「熔脈裂橋」），不是 D11 的 FS_04_VILLAGE 重新封版：

- **Step 1 Ground FIRST：** 重用 D11 私人獨立 Ground-only 的玄武岩、岩灰、熔岩及鋪面像素，重新作者式配置路面和火山區塊；輸出 **1280×928 RGB**，先產 `01_GROUND_LOCK.json` 鎖來源及新 Ground SHA。
- **Step 2 CompletePAR SECOND：** 重用 D15 已獨立生成的全非地表素材，明確 1× 不縮放重新放置六組非地表物件（鐵橋、工坊屋、熔爐、吊車、路燈、紅旗）。在**另外一張** `1280×928 RGBA` 內加入全部此場景已配置的立體物件。這次是再佈局技術評估，非新 AI 在原生畫布一次完整創作的 Art PASS。
- **Step 3 靜態合成 QA：** 真正執行 `Image.alpha_composite(GROUND,PAR)`，無第三張替代 Ground/PAR 來源。
- 實際 PAR alpha=0 **865,221** 像素；六群物件高不透明互相覆蓋像素 **2,224**，會影響美術檢查。Ground 和 PAR 真 40×29 格，**圖片本身原生輸出 1280×928**，雖然其美術來源是 D11/D15 的受控重組，不宣稱從生成模型原生一次完成。

| 來源與產物 | SHA256 |
|---|---|
| D11 鎖定 Ground（未修改） | `ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d` |
| D15 獨立透明 PAR（未修改） | `1063c9bd0180e771da32ffffbcc5c00b6e409bffbc603524c17001010ae0c3a9` |
| D16 新 FS_04_MAZE Ground | `6c5f9d8bfbeeb96ec8da2c43cd19cc74159208853ace4963affe1f31e03136a9` |
| D16 新 FS_04_MAZE PAR | `fc3333e32f80fb980fbeaabcae02bf6fa942a5079b13eca2fa906a06b1715e6a` |
| D16 Ground + PAR 靜態 QA 合成 | `83f7a3275a4f02bd111dae99020f1d5df1ed8fdc7ea667f9f34831bbd46ee78c` |

## 4. 真實測試、失敗分類與正式 Gate

- [D16 GitHub CI #45112426928](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45112426928)：**SUCCESS**。SYNTHETIC 測試：Ground source SHA／Ground-first 冷建序／原生同尺寸獨立雙圖／真 alpha／合成逐像素一致／錯 SHA／錯圖尺寸／既有輸出拒收。**這不是私有 D16 原圖的 Godot native 證據**。
- **M1 原圖來源／像素級雙圖技術：PASS**，可重建，真實兩張不同 PNG。
- **M2 實際 D16 私人藝術 Godot 4.7.2 native：NOT_RUN**。僅靜態 Python 圖片檢查；沒有以另一張合成測試圖代替。
- **M3 視覺 ART：HOLD**：ground 拼接區殘留材質重疊、路面交界有淡化痕；部分非地表來源多邊形裁去相鄰岩柱／工坊結構；鐵橋跨熔岩接點未對準；此圖未經使用者人工 ART Gate，不能當正式量產模板。早先程式化 Ground 出現明顯重複熔岩圖章，另有過火、過於工整的鋪面圖樣，全部拒收。
- **M4 第二樣本：TECH CANDIDATE EXISTS**，但尚未通過 M2/M3，**量產能力未證明**。
- 遊戲對話／事件／戰鬥／存讀：NOT_RUN，本線不修改。
- 整體正式 **ART 0/12**。

## 5. 真正封存至私人 Google Drive 並可讀回

- [D16 十檔完整私人 ZIP（11,296,467 bytes；10 條 ZIP CRC PASS）](https://drive.google.com/file/d/14Tk-mbngKeENcFfdF3vdIE9OMVifchfm/view)：包含兩個鎖定原始輸入、Ground、PAR、靜態合成、Ground 首先鎖定 JSON、完整物件台帳 QA、Failure Log、可重建 Python 源碼與 synthetic tests。封包 SHA256 `81f4ad4169d5a67c975ccc76080187908d83513a307b0d1155d4417c9a7b8dd4`。
- [新 Ground 私有原圖](https://drive.google.com/file/d/1lyl6X9dDOeeNL0xToShRX1NzgYUd-DGN/view)、[新完整 PAR 私有原圖](https://drive.google.com/file/d/1_CjVpdp4aXUxGGzqnULrk_P-OgRGwXpg/view)、[合成 QA 私有預覽](https://drive.google.com/file/d/1eB0mGISovFixesr18xspquONdjCaD9GX/view)、[原始 QA JSON](https://drive.google.com/file/d/1XKXTuyQnYewh1hhIJS2_kb2tAouj2QnD/view)。
- 以上私人檔案已用 Drive metadata READBACK：`shared=false`、permissions 僅 `owner`。私人二進位 PNG/ZIP 不入公開 GitHub。

## 6. 下一完整施工單位

以 `FS_04_MAZE` D16 為 **技術流程樣本**，取得一整張在 1280×928 構圖裡真正自然連續的原生 Ground-only 並重新作者完整獨立 PAR，不要從舊來源靠多邊形裁切拼出有斷面的建築。逐張冷建對位、視覺檢查與真實 Godot 4.7.2 私有素材 native 1× 擷取後才可進 USER ART Gate。若私人圖片無批准的遠端讀檔路由，原生 Gate 維持 HOLD；不要擴權 PC Bridge 或動用 Desktop Remote。所有失敗先入 Failure Log，避免反覆用同一 AI prompt 試到失控。
