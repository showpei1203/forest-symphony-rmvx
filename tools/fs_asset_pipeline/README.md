# Forest Symphony Asset Pipeline Tools

Prototype tools for the Master Object -> Depth Masks -> Ground / Par pipeline.

## v0.1 Scope

Initial benchmark:

`FS_Tree_Standard_Broadleaf_01`

Inputs:

```text
{asset_id}_Master.png
{asset_id}_D1.png
{asset_id}_D3.png
{asset_id}_D4.png
{asset_id}.meta.json
```

Authority export rule:

```text
Ground = D1
Par    = D3 + D4
```

## Install

```bash
python -m pip install -r tools/fs_asset_pipeline/requirements.txt
```

## Validate an asset bundle

```bash
python tools/fs_asset_pipeline/validator/validate_asset.py PATH_TO_ASSET_BUNDLE
```

Optional JSON report:

```bash
python tools/fs_asset_pipeline/validator/validate_asset.py PATH_TO_ASSET_BUNDLE \
  --report validation_report.json
```

Exit codes:

- `0`: PASS or PASS_WITH_WARNINGS
- `2`: FAIL

## Compile a Master Object

```bash
python tools/fs_asset_pipeline/compiler/compile_master_object.py PATH_TO_ASSET_BUNDLE
```

Optional output directory:

```bash
python tools/fs_asset_pipeline/compiler/compile_master_object.py PATH_TO_ASSET_BUNDLE \
  --output PATH_TO_OUTPUT
```

Expected outputs:

```text
{asset_id}_ground.png
{asset_id}_par.png
{asset_id}_compiled.json
{asset_id}_report.json
```

The compiler refuses to run when Validator returns blocking FAIL.

## Mask Rules v0.1

Visible mask pixels:

```text
RGBA = 255,255,255,255
```

Unselected pixels must be fully transparent.

Mask anti-aliasing and partial alpha are rejected.

## Reference Documents

- `docs/asset_pipeline/FS_TREE_STANDARD_BROADLEAF_01_SPEC.md`
- `docs/asset_pipeline/FS_ASSET_VALIDATOR_RULES_V0_1.md`
- `docs/asset_pipeline/FS_MAP_COMPILER_PROTOTYPE_V0_1.md`

## Prototype Boundary

v0.1 does not modify RPG Maker VX map data and does not compile a whole map. It only proves deterministic single-object Ground / Par export before the project expands to map-level composition.
