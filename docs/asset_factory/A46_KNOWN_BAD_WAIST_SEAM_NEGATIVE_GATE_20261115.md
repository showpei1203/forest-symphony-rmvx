# Forest Symphony A46｜腰部接合缺陷：獨立負例驗證與修復規範
日期：2026-11-15

## 使用者回報與工程結論
使用者指出 A45 攻擊動畫的上下半身像分開來動。**回報成立，不是主觀想像。**
先前採用 8-neighbor RGBA alpha 連通性、腳掌位置與 native Godot 0 pixel diff 的測試，全部可能 PASS；但這些只代表圖層可渲染及像素接觸，**無法保證人體關節或衣服腰部銜接自然**。

## 實際量測（A62 為已核准 64x64 角色）
- 先前 A45 12 幀 Body 全都只有一個 alpha connected component，錯誤 PASS。
- 新獨立檢查：腰部 ROI x29..42、y42..47，統計每列最大同 RGBA 色塊密度，對照 A62 核准美術相同位置，允許 +3px 容差；超過則 **SEAM FAIL**。
- A62 原始圖：PASS。
- A44 Body：F01–F10 FAIL。
- **A45 Body：F06／F07／F08 FAIL**。
- **A45 真 Godot 4.7.2 RX6700XT 渲染截圖：同樣 F06／F07／F08 FAIL**。
- A45 F06 row44：同色 8px，A62 3px；row46：同色 9px，A62 4px。差異均 +5，超過容差。
- 根因：先前 A44/A45 generator 在固定水平區間清掉原有腿部，之後分別重畫衣擺和雙腿；風格上的水平剪接痕跡不會被單純 alpha 連通性發現。
- 證據：私人 Drive `FS_A45_ATTACK_POSE_REWORK_20261115/A46_A45_REAL_GODOT_WAIST_SEAM_EVIDENCE.png` 與 `qa/A46_SEAM_CROSS_FRAME_INDEPENDENT_QA.json`。
- 參數只適用本 Actor01/A62 尺寸和色盤，**不是普世的動畫好壞判斷器**。QA 用於捕捉已知迴歸，不能取代對動作的觀察。

## 立刻升級驗收規範
A45 判定由 ART HOLD 修正為 **ART FAIL（waist seam）**。原 ENGINE/GPU/獨立命中 QA PASS 不受影響。

後續每個 A46 以上候選版必須：
1. 以同一個**腰／骨盆／胸腔的連續骨架**生成整個身體姿勢，禁止先清除 y46～55 範圍後把雙腿直接拼回。
2. 至少標記頸、雙肩、胸腔、腰、骨盆、膝與腳掌錨點，每幀由骨盆位置決定腿部起點，肩膀和骨盆的相對距離必須在合理容差內。
3. 同時跑 alpha connectivity、腰部 ROI 色帶負例檢查、腳底滑動、原生 Godot 錄製 12 幀和 1×／3×連續動態視覺檢查。
4. **驗收程式必須先對已知缺陷 A45 FAIL、A62 基準 PASS**，否則沒有辨識能力，不可報告檢查通過。
5. 新 A46 必須在來源 Sprite Body 和 Godot GPU 截圖兩者同時 PASS；沒有改用整體骨架設計前，勿只靠填補幾個像素消除紅色標記。

## 禁止混淆
- ENGINE PASS／ATB formal migration NOT RUN 依舊。
- **ART FAIL 是目前具體狀態**，不能再稱作「自動美術 PASS 就是基本可用」。
- 本次不變更原 A42–A45 圖集、Godot main、地圖、Godot migration、RMVX E: 原件。
