# FS Tree Standard Broadleaf 01 — Asset / Semantic Depth Spec v0.2

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
2. Aseprite final cleanup / semantic-mask authoring
3. D1 / D3 / D4 semantic depth planning
4. Python Asset Validator
5. Render Policy
6. FS single-object Compiler Prototype
7. 後續 standard broadleaf variants 的風格與工程基準

本規格遵循 **Master Object First**：完整 Master Object 是唯一美術主體；D1 / D3 / D4 描述物件的世界語意；Ground / Par 則由 Render Policy 派生。禁止把 Ground 與 Par 當成兩張彼此獨立生成、獨立維護的美術圖。

## 2. Reference Direction

Primary family direction:
- FS 原始 `tree variation.png` 類型：輪廓清楚、樹冠集中、主幹與樹根明確，適合量產與重複排列。

Secondary reference:
- FS 原始 `Trees1.png`：提供葉叢層次、樹幹質感與大型闊葉樹語言參考。

Excluded as primary direction:
- `Hanzo-VSTrees03.png` 類針葉林輪廓，不屬於本 asset family。

## 3. Master Object Authority

正式美術 Authority 永遠是：

`FS_Tree_Standard_Broadleaf_01_Master.png`

D1 / D3 / D4 為工程 semantic masks，不是三份獨立美術資產。

任何美術修正應優先修改 Master，再重新產生 / 修正 masks 與 compiler outputs，避免 Ground / Par 發生版本漂移。

## 4. Semantic Depth Definitions

### D1 — Ground Contact / Placement Semantics

用途：
- 定義根部、接地關係與 placement 語意
- 支援 anchor、未來 collision/passability 與 map compiler reasoning

應包含：
- 最低位樹根
- 接地陰影
- 根部貼地小草 / 苔蘚 / 低位裝飾
- 必要的低位外擴根鬚

不應包含：
- 大片樹冠
- 與接地無關的高位枝葉

判定原則：以「是否屬於接地與放置關係」判定，不以固定高度水平切割。

**v0.2 注意：D1 不再等同 Ground 輸出範圍。**

### D3 — Primary Occluder

用途：定義角色位於樹後方時，主要應顯示於角色前方的實體遮擋區。

應包含：
- 主幹
- 中下段粗枝
- 與主幹連續並具遮擋意義的枝體
- 必要的少量中位葉叢

判定原則：問「角色位於此物件後方時，這個區域是否應顯示在角色前面？」

### D4 — Canopy / High Foliage

用途：定義高位枝葉與樹冠的遮擋語意。

應包含：
- 大部分樹冠
- 高位葉叢
- 上方 / 外側延伸枝葉
- 垂落但仍屬高位覆蓋的葉片

不應包含：
- 接地陰影
- 樹根

## 5. Semantic Relationship Rules

1. 禁止以水平高度硬切 D1 / D3 / D4。
2. Depth assignment 以 gameplay / occlusion / placement function 為優先。
3. D3 與 D4 邊界允許不規則輪廓。
4. Semantic masks 不是 Ground / Par 的互斥 destination map。
5. Mask overlap 可存在，Validator 會量測，但不因 overlap 本身判 FAIL。
6. v0.2 不導入 D2、runtime dynamic sorting 或多 Par layer。

## 6. Forest Symphony Render Policy Authority

實際檢查既有 FS `groundXX / parXX` reference 後，確認舊 FS 使用 **Base + Occlusion Overlay** 類型行為：完整物件可存在 Ground，同一物件的遮擋區再重複存在 Par。

因此目前 FS profile：

`fs_legacy_parallax_vx`

正式規則：

```text
Ground = full Master Object
Par    = Master Object masked by D3 + D4
```

Ground / Par pixel overlap 是預期結果，不是錯誤。

完整定義見：

`docs/asset_pipeline/FS_RENDER_POLICY_V0_2.md`

## 7. Aseprite Authoring Layout

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

## 8. File Naming

```text
FS_Tree_Standard_Broadleaf_01_Master.png
FS_Tree_Standard_Broadleaf_01_D1.png
FS_Tree_Standard_Broadleaf_01_D3.png
FS_Tree_Standard_Broadleaf_01_D4.png
FS_Tree_Standard_Broadleaf_01.meta.json
```

所有 masks 必須與 Master 完全同尺寸、同 canvas origin，不得另行 trim / crop。

## 9. Anchor Authority

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

## 10. Metadata Baseline v0.2

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
  "render_policy": {
    "profile": "fs_legacy_parallax_vx",
    "ground": {
      "source": "master"
    },
    "par": {
      "source": "master",
      "mask_union": ["D3", "D4"]
    }
  }
}
```

## 11. Acceptance Criteria

本資產只有在以下條件成立時才能從 `PROVISIONAL PASS` 升為正式 production reference：

- Master 視覺符合 FS standard broadleaf family
- D1 / D3 / D4 可由人工合理理解並穩定重製
- Validator v0.2 無 blocking FAIL
- Compiler v0.2 可依 `fs_legacy_parallax_vx` 產生非空 Ground / Par
- Ground 為完整 Master，Par 為 D3+D4 occlusion overlay
- 實際 FS map/runtime 測試維持正確接地與角色遮擋感
- 後續至少 2 個同 family variant 能沿用同一 semantic + render policy，不必重新發明 depth rules

## 12. Scope Boundary

尚未納入：

- conifer family
- landmark / ancient tree family
- dead tree family
- seasonal variants
- collision authority
- whole-map compiler
- dynamic runtime occlusion

這些功能必須在真實 Benchmark 02 完成並通過 runtime acceptance 後再擴張。
