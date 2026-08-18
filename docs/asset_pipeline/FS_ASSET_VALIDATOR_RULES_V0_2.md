# Forest Symphony Asset Validator Rules v0.2

- Authority date: 2026-08-18
- Status: `CURRENT PROTOTYPE AUTHORITY`
- Related: `FS_RENDER_POLICY_V0_2.md`

## 1. Required Bundle

```text
{asset_id}_Master.png
{asset_id}_D1.png
{asset_id}_D3.png
{asset_id}_D4.png
{asset_id}.meta.json
```

All PNG files must share the same canvas dimensions and origin.

## 2. Metadata

Required common fields:

- `asset_id`
- `family`
- `category`
- `source_master`
- `masks`
- `anchor`

The bundle must also contain either:

- preferred v0.2 `render_policy`, or
- legacy v0.1 `export_rules`

## 3. Mask Rules

D1/D3/D4 visible pixels must be exactly opaque white `255,255,255,255`.

Unselected pixels must be fully transparent.

Blocking failures include:

- missing files
- non-PNG input
- non-RGBA source/masks
- mask size mismatch
- partial-alpha mask pixels
- colored visible mask pixels
- empty required D1/D3/D4 masks
- effectively identical depth masks
- more than 10% visible Master pixels unassigned to all semantic masks

Depth-mask overlap is measured but is not automatically a failure.

## 4. Anchor

v0.2 supports normalized anchors only:

```json
{
  "mode": "normalized",
  "x": 0.5,
  "y": 0.95
}
```

Coordinates must be within `[0,1]`.

Tree anchors unusually high on the canvas generate a warning.

## 5. Render Policy Validation

Supported profiles:

- `fs_legacy_parallax_vx`
- `custom_v0_2`

For v0.2 render targets:

- `source` must currently be `master`
- `mask_union`, when present, must be a non-empty list containing only `D1`, `D3`, `D4`

For `fs_legacy_parallax_vx`, Validator additionally requires:

```text
Ground = full Master, no mask_union
Par mask_union = exactly D3 + D4
```

## 6. Legacy Metadata

`export_rules` is accepted to keep v0.1 bundles runnable.

Validator returns:

`WARN_LEGACY_EXPORT_RULES_V0_1`

When both `render_policy` and `export_rules` exist, v0.2 `render_policy` wins and Validator returns:

`WARN_LEGACY_EXPORT_RULES_IGNORED`

## 7. Result

- `PASS`
- `PASS_WITH_WARNINGS`
- `FAIL`

CLI exit code:

- `0`: PASS / PASS_WITH_WARNINGS
- `2`: FAIL
