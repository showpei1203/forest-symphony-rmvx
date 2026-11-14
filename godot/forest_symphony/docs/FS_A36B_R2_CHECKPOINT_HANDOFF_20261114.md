# Forest Symphony | Godot Ground/PAR 美術主線交接檢查點

日期：2026-11-14（Asia/Taipei）  
狀態：**A36B R2 / 工程與原生渲染 PASS / ART HOLD / COLLISION HOLD / FORMAL SEAL NO**  
交接目的：使用者指示「先做 handoff」，因此**不繼續生成 A34 房屋，也不新增 A36C 美術候選**。本文件以實際 GitHub PR #16 HEAD 與原有 A36B R2 Handoff 為準。

## 1. 權威來源與安全邊界

- Repo: `showpei1203/forest-symphony-rmvx`
- 開發分支：`feat/fs-godot-first-a29-20261113`，GitHub [Draft PR #16](https://github.com/showpei1203/forest-symphony-rmvx/pull/16)。
- 本檢查點**寫入前**查核的原始 HEAD：`dde7c901268bfdaac9dd06ad9806aac6d9d9e205`（須以新檔提交後新 SHA 為準）。
- 施工規範：[Active Master v1.3](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-asset-factory-v1-20261107/authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。**Ground-only 先獨立製作 → 完整透明 PAR 獨立製作 → Godot 原生合成及腳點遮擋/碰撞 → 1x 最終美術豐富度驗收**。不使用完成 Master 切割物件作正式新圖產線。
- 此對話所負責的工項：Ground、獨立完整 PAR、SHADOW/LIGHT/WATER、美術、地圖大小、地形家族和生態分布。**事件/NPC/劇情/戰鬥是另外對話／工項**，不要任意覆寫。
- Godot **4.7.2 stable**；`main`、VX 封版檔、私人美術來源不得覆寫；私人圖片及可遊玩封包只存 owner-only Drive，GitHub 只保留程式、Scene、Manifest、測試與文件。使用者 PC 零永久新檔。

## 2. 最新實際工程：A36B R2

- 最新可載入場景：`res://scenes/a36b_large_forest_tree_ecology_80x58.tscn`，**80×58 格、32 px/grid、2560×1856**，場景樹 **326 個**可個別選取的完整 PAR 物件。上一版 `a36_large_verdant_forest_80x58.tscn` 保留。
- A36 新 Ground-only 原檔 SHA256 **`ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911`**，A36B **未修改任何 Ground 位元組**。原生生成來源 **1478×1064** 再 nearest 放大成 **2560×1856**，因此美術與像素尺度仍待驗收，**不得宣稱原生 32px 設計**。
- A36 初期 310 株樹；A36B 更換 **40 株 148×194 松樹 + 22 株 208×190 垂柳**，其餘 **264** 個物件來源／位置／腳點不變。**326 個 PAR 實例、11 種獨立來源家族（其中 6 種樹）**，不是從完成大地圖切出的遮罩。
- 新樹用完整透明 RGBA、保留原始來源 sheet；原圖集底部兩株彼此交疊／被裁到的候選**明確淘汰**，只接受上排兩棵完整樹。
- 新獨立接地 SHADOW SHA256 **`752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa`**，沒有烘焙回 Ground。
- 角色現階段仍使用來源參考 F0／45° 戰鬥角度；非四方向城鎮行走動畫。

## 3. 已驗證與證據

- **Godot 4.7.2 私人真實素材 QA：2,621 checks PASS**；**公開 source-only 版本：1,973 checks PASS**。
- Godot 4.7.2 原生 OpenGL **兩張 2560×1856** A36/A36B framebuffer 產出。新舊畫面 **910,260 RGB 像素差異**，在 62 棵替換樹及其 SHADOW 覆蓋 ROI 外 **0 差異**。此為變更隔離證據，**非 Art PASS**。
- 冷重建 **6/6 SHA 完全一致**；不會覆寫已存在的目的地資料夾。
- GitHub 原始 HEAD `dde7c901...` 的七項 CI 全部 `completed/success`：A30、A32、A33、A34、A35、A36、A36B。其中特定 [A36B CI run #43556680217](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43556680217) 成功。注意新增本文件後可能有新的 CI，必須按新 HEAD 獨立重新查核，不得沿用前一個 SHA 的綠燈當新結果。
- [A36B R2 原始工程 QA / Failure Log](A36B_TREE_ECOLOGY_HANDOFF_20261114.md) 是本檢查點細節權威。

## 4. owner-only Drive 已存在的交付（已查證）

- [A36B R2 完整私人 Godot ZIP](https://drive.google.com/file/d/15t5Yn6zdTC8vG1dOYrLmMEHGVYqjEjwO/view)：**173 members，54,150,993 bytes，SHA256 `7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b`**。原有 A36B 文件記載 upload→download SHA256、ZIP CRC、172 member SHA 全 PASS。**本輪讀到 Google Drive metadata：shared=false、size=54,150,993**，沒有重新執行每個原生測試。
- [Godot A36 與 A36B 原生 1x A/B](https://drive.google.com/file/d/1XvFNe8auahjunwSm1x_Rz3ot8IznhjR5/view)
- [Godot A36B 2560×1856 原生畫面](https://drive.google.com/file/d/1fVCS0ut1RBnfVz_sv2X9ToyBP4xYUq8V/view)
- [A36B Drive Failure Log mirror](https://drive.google.com/file/d/1Q6FjCjlnOgIGRQauFmkhz3kHr4CvotRb/view)
- 另存 A34 獨立完整房屋於原先版本及 [A34 Handoff](A34_INDEPENDENT_COMPLETE_HOUSES_HANDOFF.md)：左工坊 288×282、右工作室 252×252；**A34 已有獨立正式程式與 CI success，不是 UI 'Too many requests' 導致整個 GitHub 工程消失**。現行 A36B 大地圖有使用 A34 房屋家族；請勿將小地圖 A34 與大地圖 A36B 混作同一個場景。

## 5. 失敗、未完成與不能宣稱的事

- **ART HOLD**：A36B 垂柳顏色偏亮黃、松樹偏暗；不同樹材質／Ground 像素密度不一致；6 種樹對大型森林仍易重複；1478×1064 Ground 放大而非原生精修。使用者尚未核准 1x 美術。
- **COLLISION HOLD**：148 個溪流水域阻擋格只是候選，尚未成為完成的可測實體水域；整張 80×58 地圖真正可走性、建築門口及路網仍未實走驗收。
- **WATER ANIMATION NOT_IMPLEMENTED**：溪流仍為 Ground 靜態。不能宣稱水循環、風擺、光影或六個地形系列已經成品化。
- **人物與遊戲功能**：四方向行走、NPC、任務、場景轉換、正式 Windows export、戰鬥/ATB 尚未在本美術主線驗收。另對話可能有獨立成果，不能從本分支推論已完成或失敗。
- **正式封版 NO**：所有 CI 綠燈只代表特定 contract/原生測試通過，不代表 Ground3 最高美術等級或完整遊戲達標。
- **過去實際錯誤**：A36B R1 垂柳太密太規律；下排 sheet 樹相互交疊裁切；測試批次取代 `==256` 誤成 `==2640`；另有 1x 風格失衡與 Ground 像素尺度問題。R2 修了前述前三項，後兩項仍 HOLD。

## 6. 下個對話直接施工：A36C（美術，非事件）

1. 從這份 A36B R2 的私人 Godot ZIP 和 PR #16 讀取實際 scene/manifest/source SHA，禁止憑概念圖覆蓋 A36B。
2. 先比較 **1x 真實 framebuffer** 的溪流岸線與 Ground 植被像素密度，提出真正不失真的**Ground-only 原生尺度美術修正候選**，保留 A36B Ground unchanged control。
3. 逐棵新增 2～6 株真正完整、不同輪廓的樹，建立 **8～12 種樹型**的可重用家族；綁生態分區與林群組合，保留獨立完整透明 PAR。先小區塊 1x 美術比較，不要只修改 RGB/添加重複樹。
4. WATER 保持獨立層，與原 Ground 碰撞語意分開，實際 Godot 渲染測試；148 格候選在實走前仍 HOLD。
5. 每次產出前後都驗證原源 SHA、來源合法性、角色腳點、碰撞、YSort，保存 1x Godot 畫面、Failure Log、Handoff。私人 PNG/ZIP owner-only Drive，GitHub Draft PR #16 不含私人圖片。

## 7. 接續指令（可直接貼新對話）

> 接續 Forest Symphony Godot Ground/PAR 美術工程，請以 Active Master v1.3 與 PR #16 最新 `godot/forest_symphony/CURRENT_HANDOFF.md`／本 A36B R2 checkpoint 為唯一現行依據，先查 HEAD 與 CI，下載 Drive 私人 A36B R2 ZIP 及核實 SHA。Ground-first → 獨立完整 PAR → Godot 合成 → 1x 美術驗收。接著直接進行 A36C：原生 Ground 河岸像素精度、樹型增至 8–12、獨立 WATER 候選／真實 Godot 截圖；ART、碰撞、水動畫未驗收者維持 HOLD。禁止重新從 Master 裁切、不可覆蓋 main／VX 封版或混入 NPC/劇情/戰鬥；每輪 Drive/GitHub 雙重 Handoff。

**此檢查點只固定目前已存在的工程證據，沒有新增或宣稱 A36C 美術完成。**
