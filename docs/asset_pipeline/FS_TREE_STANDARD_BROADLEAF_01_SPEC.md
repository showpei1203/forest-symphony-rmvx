# FS Tree Standard Broadleaf 01 — Asset / Depth Mask Spec v0.1

- Project: Forest Symphony
- Asset ID: `FS_Tree_Standard_Broadleaf_01`
- Family: `standard_broadleaf`
- Category: `tree`
- Status: `PROVISIONAL PASS / PIPELINE BENCHMARK`
- Authority date: 2026-08-18
- Related Linear: `SHO-34 | FS Parallax Master Object Benchmark I`

## 1. Purpose

本資產是 Forest Symphony 第一個正式「標準森林闊葉樹」量產原型，同時作為以下流程的基準樣本：

1. PixelLab Master Object generation
2. Aseprite final cleanup / mask authoring
3. D1 / D3 / D4 depth planning
4. Python Asset Validator
5. FS Map Compiler Prototype
6. 後續 standard broadleaf variants 的風格與工程基準

本規格遵循 **Master Object First**：先保留一張完整 Master Object，再由 mask / metadata 派生 Ground / Par。禁止把 Ground 與 Par 當成兩張彼此獨立生成、獨立維護的美術圖。

## 2. Reference Direction

Primary family direction:
- FS 原始 `tree variation.png` 類型：輪廓清楚、樹冠集中、主幹與樹根明確，適合量產與重複排列。

Secondary reference:
- FS 原始 `Trees1.png`：提供葉叢層次、樹幹質感與大型闊葉樹語言參考。

Excluded as primary direction:
- `Hanzo-VSTrees03.png` 類針葉林輪廓，不屬於本 asset family。

## 3. Master Object Authority

正式 Authority 永遠是：

`FS_Tree_Standard_Broadleaf_01_Master.png`

D1 / D3 / D4 為工程 mask，不是三份獨立美術資產。

任何美術修正應優先修改 Master，再重新產生 / 修正 mask 與 compiler outputs，避免 Ground / Par 發生版本漂移。

## 4. Depth Definitions

### D1 — Ground Contact / Below Character

用途：地面接觸與低位視覺，輸出至 Ground。

應包含：
- 最低位樹根
- 接地陰影
- 根部貼地小草 / 苔蘚 / 低位裝飾
- 必要的低位外擴根鬚

不應包含：
- 主幹中段
- 明確遮擋角色的實體區
- 大片樹冠

判定原則：以「是否屬於接地視覺」判定，不以固定高度水平切割。

### D3 — Primary Occluder

用途：角色走到樹後方時應遮住角色的主要實體，輸出至 Par。

應包含：
- 主幹
- 中下段粗枝
- 與主幹連續並具遮擋意義的枝體
- 必要的少量中位葉叢

不應包含：
- 純接地根部
- 純高位樹冠
- 無遮擋意義的外圍細葉尖

判定原則：問「角色位於此物件後方時，這個區域是否應顯示在角色前面？」若是，優先屬於 D3。

### D4 — Canopy / High Foliage

用途：高位枝葉與樹冠覆蓋，輸出至 Par。

應包含：
- 大部分樹冠
- 高位葉叢
- 上方 / 外側延伸枝葉
- 垂落但仍屬高位覆蓋的葉片

不應包含：
- 接地陰影
- 樹根
- 主幹核心

## 5. Layer Relationship Rules

1. 禁止以水平高度把物件硬切成 D1 / D3 / D4。
2. Depth assignment 以 gameplay / occlusion function 為優先。
3. D3 與 D4 邊界允許不規則輪廓，例如主幹穿入樹冠、粗枝被葉叢包覆。
4. v0.1 export authority：
   - `Ground = D1`
   - `Par = D3 + D4`
5. v0.1 不導入 D2、runtime dynamic sorting 或多 Par layer。

## 6. Aseprite Authoring Layout

建議 layer：

- `MASTER`
- `MASK_D1`
- `MASK_D3`
- `MASK_D4`
- `GUIDE_ANCHOR`
- `GUIDE_NOTES`

Mask 規則：
- selected pixels: opaque white `#FFFFFF`
- unselected pixels: fully transparent
- 不允許 anti-aliasing
- 不允許模糊
- 不允許非必要半透明

## 7. File Naming

```text
FS_Tree_Standard_Broadleaf_01_Master.png
FS_Tree_Standard_Broadleaf_01_D1.png
FS_Tree_Standard_Broadleaf_01_D3.png
FS_Tree_Standard_Broadleaf_01_D4.png
FS_Tree_Standard_Broadleaf_01.meta.json
```

所有 mask 必須與 Master 完全同尺寸、同 canvas origin，不得另行 trim / crop。

## 8. Anchor Authority v0.1

Anchor 語義：樹木實際放置到地圖時的接地基準點。

建議：
- X = trunk center
- Y = root bottom contact

Normalized baseline：

```json
{
  "mode": "normalized",
  "x": 0.50,
  "y": 0.95
}
```

實際量產時允許依樹型調整，不要求所有 tree variants 固定使用 0.50 / 0.95。

## 9. Metadata Baseline

```json
{
  "asset_id": "FS_Tree_Standard_Broadleaf_01",
  "family": "standard_broadleaf",
  "category": "tree",
  "variant": "base",
  "status": "provisional_pass",
  "source_master": "FS_Tree_Standard_Broadleaf_01_Master.png",
  "masks": {
    "D1": "FS_Tree_Standard_Broadleaf_01_D1.png",
    "D3": "FS_Tree_Standard_Broadleaf_01_D3.png",
    "D4": "FS_Tree_Standard_Broadleaf_01_D4.png"
  },
  "anchor": {
    "mode": "normalized",
    "x": 0.50,
    "y": 0.95
  },
  "export_rules": {
    "ground_layers": ["D1"],
    "par_layers": ["D3", "D4"]
  }
}
```

## 10. Acceptance Criteria

本資產只有在以下條件成立時才能從 `PROVISIONAL PASS` 升為正式 production reference：

- Master 視覺符合 FS standard broadleaf family
- D1 / D3 / D4 可由人工合理理解並穩定重製
- Validator 無 blocking FAIL
- Compiler 可成功產生非空 Ground / Par
- Ground + Par 在實際 FS map 測試中能維持正確接地與遮擋感
- 後續至少 2 個同 family variant 能沿用同一規格，而不需要重新發明 depth rules

## 11. Scope Boundary

本規格只定義 standard broadleaf tree family 的第一個 benchmark。

尚未納入：
- conifer family
- landmark / ancient tree family
- dead tree family
- seasonal variants
- collision authority
- whole-map compiler
- dynamic runtime occlusion

這些功能必須在本 prototype 穩定後再擴張。