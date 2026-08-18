# FS Asset Validator Rules v0.1

- Project: Forest Symphony
- Scope: Master Object + D1 / D3 / D4 mask validation
- Version: v0.1
- Authority date: 2026-08-18
- Initial benchmark: `FS_Tree_Standard_Broadleaf_01`

## 1. Purpose

本文件定義第一版 Python Asset Validator 的規格。Validator 的任務不是評分美術好不好看，而是回答：

> 這份素材是否符合 Forest Symphony Asset Pipeline 的最低工程要求，能否安全交給 Compiler。

Validation severity 分成三級：

- `FAIL`：阻止 compile
- `WARN`：允許 compile，但必須在 report 中顯示
- `INFO`：記錄統計 / 診斷，不影響 compile

## 2. Required Asset Bundle

對 `FS_Tree_Standard_Broadleaf_01`，最小 bundle：

```text
FS_Tree_Standard_Broadleaf_01_Master.png
FS_Tree_Standard_Broadleaf_01_D1.png
FS_Tree_Standard_Broadleaf_01_D3.png
FS_Tree_Standard_Broadleaf_01_D4.png
FS_Tree_Standard_Broadleaf_01.meta.json
```

## 3. Naming Rules

### FAIL

- `FAIL_REQUIRED_FILE_MISSING`
- `FAIL_ASSET_ID_FILENAME_MISMATCH`
- `FAIL_INVALID_FILENAME_PATTERN`

### Pattern baseline

```text
{asset_id}_Master.png
{asset_id}_D1.png
{asset_id}_D3.png
{asset_id}_D4.png
{asset_id}.meta.json
```

## 4. File Format Rules

### FAIL

- `FAIL_IMAGE_OPEN_ERROR`
- `FAIL_NOT_PNG`
- `FAIL_MASTER_NOT_RGBA`
- `FAIL_MASK_NOT_RGBA`
- `FAIL_JSON_PARSE_ERROR`

### INFO

記錄：
- MIME / image format
- width / height
- file size
- unique RGB count
- unique alpha count

## 5. Dimension Rules

Master 是 canvas authority。

### FAIL

- `FAIL_MASK_SIZE_MISMATCH_D1`
- `FAIL_MASK_SIZE_MISMATCH_D3`
- `FAIL_MASK_SIZE_MISMATCH_D4`

所有 mask 必須與 Master 完全同尺寸。

### WARN

- `WARN_IMAGE_DIMENSION_UNUSUAL`

v0.1 只記錄異常尺寸，不先硬編固定 tree size limit，避免在尚未建立足夠 benchmark dataset 前過早限制美術。

## 6. Alpha / Transparency Rules

### Master

Master 必須支援透明背景。

#### FAIL
- `FAIL_MASTER_NO_TRANSPARENCY_CAPABILITY`

#### WARN
- `WARN_MASTER_NO_TRANSPARENT_PIXEL`
- `WARN_MASTER_HIGH_PARTIAL_ALPHA_RATIO`

Master 可以有少量半透明 anti-aliasing，但比例應記錄。

### Masks

Mask 規格固定：
- selected = opaque white (`255,255,255,255`)
- unselected = fully transparent (`0,0,0,0` 或 RGB 任意但 alpha=0，輸出前可 normalize)

#### FAIL
- `FAIL_MASK_HAS_PARTIAL_ALPHA`
- `FAIL_MASK_HAS_INVALID_VISIBLE_COLOR`

## 7. Pixel Purity Rules

### Master

### WARN
- `WARN_MASTER_BLUR_SUSPECTED`
- `WARN_MASTER_SCALE_ARTIFACT_SUSPECTED`
- `WARN_MASTER_EXCESSIVE_COLOR_COUNT`

v0.1 不因 Master color count 過高直接 FAIL；PixelLab / Aseprite 來源可能存在較高色數，需先累積 benchmark 再鎖 threshold。

### Masks

### FAIL
- `FAIL_MASK_NOT_BINARY`

Mask visible pixels 必須為單一 opaque value，不接受 anti-aliased boundary。

## 8. Non-Empty Mask Rules

### FAIL

- `FAIL_D1_EMPTY`
- `FAIL_D3_EMPTY`
- `FAIL_D4_EMPTY`

### INFO

記錄每層：
- visible pixel count
- coverage ratio against master non-transparent pixels
- bounding box
- connected component count

## 9. Coverage / Plausibility Rules

v0.1 對合理性採 WARN，不直接 FAIL，避免 Validator 越權成為美術裁判。

### WARN

- `WARN_D1_COVERAGE_TOO_SMALL`
- `WARN_D1_VERTICAL_POSITION_SUSPECT`
- `WARN_D3_COVERAGE_TOO_SMALL`
- `WARN_D3_FRAGMENTED`
- `WARN_D4_COVERAGE_TOO_SMALL`
- `WARN_D4_VERTICAL_POSITION_SUSPECT`

Threshold 必須可設定，不硬寫死在 validator core。

## 10. Overlap Rules

v0.1 允許少量 overlap，用來支援不規則樹幹 / 樹冠交界。

### INFO

記錄：
- D1 ∩ D3 pixels
- D1 ∩ D4 pixels
- D3 ∩ D4 pixels

### WARN

- `WARN_D1_D3_OVERLAP_HIGH`
- `WARN_D1_D4_OVERLAP_HIGH`
- `WARN_D3_D4_OVERLAP_HIGH`

### FAIL

- `FAIL_MASKS_EFFECTIVELY_IDENTICAL`

若多個 mask 幾乎完全一致，代表 depth planning 失去意義，阻止 compile。

## 11. Unassigned Master Pixel Rules

Validator 應計算：

`master_visible - (D1 ∪ D3 ∪ D4)`

### WARN

- `WARN_MASTER_VISIBLE_PIXELS_UNASSIGNED`

v0.1 不直接 FAIL，因少量 anti-aliasing / decorative fringe 可能合理。

若未分配比例超過 configurable threshold，升級為：

- `FAIL_EXCESSIVE_UNASSIGNED_VISIBLE_PIXELS`

## 12. Anchor Rules

Metadata 必須有 anchor。

### FAIL

- `FAIL_ANCHOR_MISSING`
- `FAIL_ANCHOR_MODE_UNSUPPORTED`
- `FAIL_ANCHOR_OUT_OF_BOUNDS`

v0.1 支援：

```json
{
  "mode": "normalized",
  "x": 0.50,
  "y": 0.95
}
```

Normalized x / y 必須位於 `[0.0, 1.0]`。

### WARN

- `WARN_ANCHOR_VERTICAL_POSITION_SUSPECT`
- `WARN_ANCHOR_HORIZONTAL_POSITION_SUSPECT`

## 13. Metadata Required Fields

### Required

- `asset_id`
- `family`
- `category`
- `source_master`
- `masks`
- `anchor`
- `export_rules`

### FAIL

- `FAIL_META_REQUIRED_FIELD_MISSING`
- `FAIL_META_MASTER_FILENAME_MISMATCH`
- `FAIL_META_MASK_FILENAME_MISMATCH`
- `FAIL_META_UNKNOWN_DEPTH_LAYER`

## 14. Export Compatibility Rules

Validator 在 compile 前應確認 export rule 可解析。

v0.1 authority：

```json
{
  "ground_layers": ["D1"],
  "par_layers": ["D3", "D4"]
}
```

### FAIL

- `FAIL_EXPORT_RULE_INVALID`
- `FAIL_GROUND_EXPORT_HAS_NO_SOURCE_LAYER`
- `FAIL_PAR_EXPORT_HAS_NO_SOURCE_LAYER`

## 15. Validation Result Schema v0.1

建議 Python 回傳：

```json
{
  "asset_id": "FS_Tree_Standard_Broadleaf_01",
  "status": "PASS_WITH_WARNINGS",
  "fail_count": 0,
  "warn_count": 1,
  "info_count": 8,
  "failures": [],
  "warnings": [],
  "info": [],
  "metrics": {
    "master_visible_pixels": 0,
    "d1_pixels": 0,
    "d3_pixels": 0,
    "d4_pixels": 0,
    "unassigned_pixels": 0,
    "d1_d3_overlap_pixels": 0,
    "d1_d4_overlap_pixels": 0,
    "d3_d4_overlap_pixels": 0
  }
}
```

## 16. Compile Gate

- `FAIL count > 0` → compiler MUST NOT run
- `FAIL count = 0, WARN count > 0` → compiler MAY run and report `PASS_WITH_WARNINGS`
- no FAIL / WARN → `PASS`

## 17. v0.1 Scope Boundary

Validator v0.1 不處理：
- 主觀美術品質分數
- collision polygon
- whole-map placement
- seasonal palette correctness
- animation frame timing
- sprite sheet frame validation

這些應由後續共用 Asset Validator modules 擴充，而非全部塞進第一版 tree prototype。