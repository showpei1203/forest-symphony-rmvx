# Forest Symphony Map Compiler Prototype v0.2

- Component: single Master Object compiler
- Authority date: 2026-08-18
- Status: `CURRENT PROTOTYPE AUTHORITY`
- Related Linear: `SHO-34 | FS Parallax Master Object Benchmark I`

## 1. Scope

v0.2 compiles one validated Master Object bundle into deterministic Forest Symphony Ground/Par object outputs.

It is intentionally **not yet** the whole-map compiler.

## 2. Pipeline

```text
Master + D1/D3/D4 + metadata
        |
        v
Asset Validator v0.2
        |
        v
Normalize Render Policy
        |
        +-- semantic masks remain semantic authority
        |
        v
Compile Engine Outputs
        |
        +-- *_ground.png
        +-- *_par.png
        +-- *_compiled.json
        +-- *_report.json
```

## 3. Current FS Policy

Preferred profile:

`fs_legacy_parallax_vx`

Compilation rule:

```text
Ground = full Master
Par    = Master masked by D3 + D4
```

This intentionally permits Ground/Par pixel overlap because the observed legacy FS parallax assets use a base + occlusion-overlay pattern.

## 4. Legacy v0.1 Compatibility

If metadata has no `render_policy` but contains:

```json
{
  "export_rules": {
    "ground_layers": ["D1"],
    "par_layers": ["D3", "D4"]
  }
}
```

the compiler translates those rules to masked-Master targets and records:

`render_policy_source = legacy_export_rules_v0_1`

This preserves existing prototype bundles while making v0.2 the preferred authority.

## 5. Compiler Report

The report records:

- compiler / validator versions
- validation result
- render policy profile/source
- Master/Ground/Par visible pixel counts
- Ground/Par overlap pixels
- semantic-mask overlap metrics
- unassigned Master pixels
- bounding boxes

`ground_par_overlap_pixels` is expected to be non-zero under the FS legacy profile and is not a defect.

## 6. Blocking Conditions

Compilation aborts when Validator returns `FAIL`.

The compiler does not silently repair masks or metadata.

## 7. Next Gate

v0.2 is considered structurally proven after synthetic smoke testing.

It becomes production-meaningful only after the real `FS_Tree_Standard_Broadleaf_01` Benchmark 02 PNG bundle is authored and the generated Ground/Par pair passes Forest Symphony runtime visual acceptance.

Only then should development advance to multi-object / whole-map composition.
