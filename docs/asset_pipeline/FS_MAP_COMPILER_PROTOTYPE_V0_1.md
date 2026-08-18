# FS Map Compiler Prototype v0.1

- Project: Forest Symphony
- Scope: Single Master Object compile
- Version: v0.1
- Authority date: 2026-08-18
- Initial benchmark: `FS_Tree_Standard_Broadleaf_01`
- Related Linear: `SHO-34 | FS Parallax Master Object Benchmark I`

## 1. Purpose

本 prototype 的目標是證明 Forest Symphony 的新 Parallax Pipeline 可以從一張完整 Master Object，配合 depth masks 與 metadata，自動產生 RPG Maker VX 可進一步使用的 Ground / Par object outputs。

本版本只處理單一物件，不處理整張 map。

核心流程：

```text
Master Object
  + D1 / D3 / D4 masks
  + metadata
        |
        v
Asset Validator
        |
        v
Pixel Membership / Depth Resolve
        |
        +--> Ground = D1
        |
        +--> Par = D3 + D4
        |
        v
Compiled outputs + report
```

## 2. Input Bundle

最小輸入：

```text
FS_Tree_Standard_Broadleaf_01_Master.png
FS_Tree_Standard_Broadleaf_01_D1.png
FS_Tree_Standard_Broadleaf_01_D3.png
FS_Tree_Standard_Broadleaf_01_D4.png
FS_Tree_Standard_Broadleaf_01.meta.json
```

## 3. Compile Preconditions

Compiler 不自行猜測素材是否可用。

必須先執行 Asset Validator：

- 有任何 `FAIL` → 中止 compile
- 無 FAIL，但有 WARN → 允許 compile，report 標記 `PASS_WITH_WARNINGS`
- 無 FAIL / WARN → `PASS`

## 4. Processing Stages

### Stage 1 — Load

讀入：
- Master RGBA image
- D1 binary mask
- D3 binary mask
- D4 binary mask
- metadata JSON

內部 bundle：

```text
asset_bundle
  master
  masks[D1,D3,D4]
  metadata
```

### Stage 2 — Validate

呼叫 validator，確認：
- required files
- naming
- image readability
- RGBA
- dimensions
- binary masks
- anchor
- export rules

### Stage 3 — Normalize Masks

Mask visible region 一律正規化為 boolean membership：

```text
true  = selected
false = unselected
```

Compiler 不依賴 mask RGB 色彩，只依賴 alpha / validated binary selection。

### Stage 4 — Resolve Pixel Membership

對每一個 Master 非透明 pixel 建立 membership：

```text
in_D1
in_D3
in_D4
```

同時統計：
- assigned pixels
- unassigned pixels
- overlap pixels

v0.1 不自動修正 depth mistakes，只記錄並依 Validator gate 決定是否允許 compile。

### Stage 5 — Compose Ground

Authority：

```text
Ground = Master pixels where D1 == true
```

輸出 canvas 預設保持與 Master 同尺寸與同 origin，不在 v0.1 自動 trim。

### Stage 6 — Compose Par

Authority：

```text
Par = Master pixels where D3 == true OR D4 == true
```

輸出 canvas 預設保持與 Master 同尺寸與同 origin。

### Stage 7 — Preserve Anchor

Compiled output 必須保留原 Master anchor 語義。

v0.1 不因 output transparent margins 不同而改寫 anchor。

### Stage 8 — Export

建議輸出：

```text
FS_Tree_Standard_Broadleaf_01_ground.png
FS_Tree_Standard_Broadleaf_01_par.png
FS_Tree_Standard_Broadleaf_01_compiled.json
FS_Tree_Standard_Broadleaf_01_report.json
```

## 5. Compiled Metadata v0.1

```json
{
  "asset_id": "FS_Tree_Standard_Broadleaf_01",
  "compiler_version": "0.1",
  "compiled_from": "FS_Tree_Standard_Broadleaf_01_Master.png",
  "outputs": {
    "ground": "FS_Tree_Standard_Broadleaf_01_ground.png",
    "par": "FS_Tree_Standard_Broadleaf_01_par.png"
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

## 6. Compile Report v0.1

```json
{
  "asset_id": "FS_Tree_Standard_Broadleaf_01",
  "compiler_version": "0.1",
  "status": "PASS",
  "validation": {
    "fail_count": 0,
    "warn_count": 0
  },
  "metrics": {
    "master_visible_pixels": 0,
    "ground_visible_pixels": 0,
    "par_visible_pixels": 0,
    "unassigned_master_pixels": 0,
    "d1_d3_overlap_pixels": 0,
    "d1_d4_overlap_pixels": 0,
    "d3_d4_overlap_pixels": 0
  },
  "bounding_boxes": {
    "master": null,
    "ground": null,
    "par": null
  }
}
```

## 7. Suggested Python Module Layout

```text
tools/
  fs_asset_pipeline/
    validator/
      validate_asset.py
    compiler/
      compile_master_object.py
    schemas/
      fs_tree_meta.schema.json
      fs_compile_report.schema.json
    samples/
      FS_Tree_Standard_Broadleaf_01.meta.json
```

v0.1 可以先維持單一 script，再於測試穩定後拆 module；文件中的結構是 target layout，不要求在第一個 commit 一次建立所有空架構。

## 8. Suggested Compiler Functions

```text
load_asset_bundle(path)
validate_asset_bundle(bundle)
normalize_mask(mask)
resolve_membership(bundle)
compose_ground(master, d1)
compose_par(master, d3, d4)
compute_metrics(...)
write_compiled_metadata(...)
write_compile_report(...)
compile_asset(path)
```

## 9. Prototype Acceptance Criteria

Prototype v0.1 PASS 必須同時滿足：

1. 可以讀取完整 benchmark bundle。
2. Validator blocking FAIL 能阻止 compile。
3. Ground output 非空。
4. Par output 非空。
5. Output 保持與 Master 同 canvas size / origin。
6. Output alpha 正確。
7. Ground 僅含 D1 選中 Master pixels。
8. Par 僅含 D3 / D4 選中 Master pixels。
9. Anchor metadata 被完整保留。
10. 產生 compiled metadata 與 validation / compile report。
11. 同一輸入重跑得到 deterministic output。

## 10. FS Runtime / Map Integration Boundary

v0.1 不直接寫入 RPG Maker VX map data，也不修改現有正式 map。

Prototype PASS 後，下一階段才規劃：

```text
Compiled Object
   -> placement metadata
   -> map-level scene/master composition
   -> Ground / Par full-map export
   -> FS runtime acceptance
```

這可避免在單一物件拆層尚未證明正確前，就把整張 Parallax map compiler 一起拖進除錯。

## 11. Non-Goals v0.1

本版本不做：
- Ground / Par 各自 AI 生圖
- whole-map compile
- collision generation
- event generation
- dynamic runtime depth sorting
- D2
- 多張 Par depth layer
- automated artistic judgment
- seasonal variant generation
- PixelLab API orchestration

## 12. Next Engineering Step

規格鎖定後，下一個實作單位為：

1. 建立 sample metadata JSON
2. 建立 validator Python skeleton
3. 建立 compiler Python skeleton
4. 用 `FS_Tree_Standard_Broadleaf_01` 第一個真實 Master / masks 跑通 end-to-end compile
5. 根據實測結果決定是否建立 Benchmark 02.5（更簡化、工程化的量產樹）

只有在單物件 end-to-end PASS 後，才升級到 full FS Map Compiler。