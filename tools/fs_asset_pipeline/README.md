# Forest Symphony Asset Pipeline Tools

Prototype tools for the shared **Master Object -> Semantic Depth -> Render Policy -> Engine Output** pipeline.

Current implementation: **v0.2**

Initial benchmark:

`FS_Tree_Standard_Broadleaf_01`

## v0.2 Core Model

Semantic depth and engine output are separate authorities:

```text
Master Object
├─ D1 = Ground Contact / placement semantics
├─ D3 = Primary Occluder
└─ D4 = Canopy / High Foliage

Render Policy: fs_legacy_parallax_vx
├─ Ground = full Master
└─ Par    = Master masked by D3 + D4
```

This matches the observed legacy Forest Symphony parallax asset behavior where the same object may exist in both Ground and Par. D1/D3/D4 describe world meaning; they are not mutually exclusive output destinations.

## Inputs

```text
{asset_id}_Master.png
{asset_id}_D1.png
{asset_id}_D3.png
{asset_id}_D4.png
{asset_id}.meta.json
```

Preferred v0.2 metadata:

```json
{
  "render_policy": {
    "profile": "fs_legacy_parallax_vx",
    "ground": {"source": "master"},
    "par": {"source": "master", "mask_union": ["D3", "D4"]}
  }
}
```

v0.1 `export_rules` metadata remains accepted as a compatibility mode and returns a warning.

## Install

```bash
python -m pip install -r tools/fs_asset_pipeline/requirements.txt
```

## Validate

```bash
python tools/fs_asset_pipeline/validator/validate_asset.py PATH_TO_ASSET_BUNDLE
```

Optional report:

```bash
python tools/fs_asset_pipeline/validator/validate_asset.py PATH_TO_ASSET_BUNDLE \
  --report validation_report.json
```

Exit codes:

- `0`: PASS or PASS_WITH_WARNINGS
- `2`: FAIL

## Compile

```bash
python tools/fs_asset_pipeline/compiler/compile_master_object.py PATH_TO_ASSET_BUNDLE
```

Optional output directory:

```bash
python tools/fs_asset_pipeline/compiler/compile_master_object.py PATH_TO_ASSET_BUNDLE \
  --output PATH_TO_OUTPUT
```

Outputs:

```text
{asset_id}_ground.png
{asset_id}_par.png
{asset_id}_compiled.json
{asset_id}_report.json
```

The compiler refuses to run on Validator blocking FAIL.

## Regression Test

Run the deterministic v0.2 regression suite:

```bash
python tools/fs_asset_pipeline/tests/test_pipeline_v02.py
```

The suite currently locks three behaviors:

1. `fs_legacy_parallax_vx` Ground is the full Master while Par is the D3+D4 occlusion overlay.
2. v0.1 `export_rules` remain compilable but return a compatibility warning.
3. An invalid FS Par semantic union is rejected by Validator.

## Mask Rules

Visible mask pixels must be opaque white:

```text
RGBA = 255,255,255,255
```

Unselected pixels must be fully transparent. Mask anti-aliasing and partial alpha are rejected.

## Current Authority Documents

- `docs/asset_pipeline/FS_TREE_STANDARD_BROADLEAF_01_SPEC.md`
- `docs/asset_pipeline/FS_RENDER_POLICY_V0_2.md`
- `docs/asset_pipeline/FS_ASSET_VALIDATOR_RULES_V0_2.md`
- `docs/asset_pipeline/FS_MAP_COMPILER_PROTOTYPE_V0_2.md`

The v0.1 documents are retained as historical prototype records and are superseded where they conflict with v0.2.

## Prototype Boundary

v0.2 still compiles a **single Master Object**, not a whole RPG Maker VX map. It does not modify `MapXXX.rvdata`, collision, passability, or runtime scripts. Whole-map composition starts only after the real Benchmark 02 asset passes visual/runtime acceptance.
