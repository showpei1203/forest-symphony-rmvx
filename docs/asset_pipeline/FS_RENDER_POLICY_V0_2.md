# Forest Symphony Render Policy v0.2

- Project: Forest Symphony
- Authority date: 2026-08-18
- Related Linear: `SHO-34 | FS Parallax Master Object Benchmark I`
- Status: `CURRENT PROTOTYPE AUTHORITY`

## 1. Why v0.2 Exists

Inspection of real Forest Symphony `groundXX` / `parXX` references showed that a complete scenery object can remain in Ground while an overlapping copy of its occluding region also exists in Par.

Therefore the v0.1 assumption:

```text
Ground = D1
Par = D3 + D4
```

is not the correct general model for Forest Symphony legacy parallax rendering.

v0.2 separates two concepts:

1. **Semantic Depth**: what each part of an object means in the world.
2. **Render Policy**: how those semantics are converted into engine-specific output images.

## 2. Semantic Depth Authority

For the standard broadleaf benchmark:

- `D1`: ground contact, roots, anchor/placement semantics.
- `D3`: primary physical occluder such as trunk and major branches.
- `D4`: canopy/high foliage occluder.

D1/D3/D4 are semantic masks. They do not mean that a pixel may appear in only one engine output.

## 3. Forest Symphony Legacy Render Profile

Profile name:

`fs_legacy_parallax_vx`

Authority:

```text
Ground = full Master Object
Par    = Master Object masked by union(D3, D4)
```

Equivalent metadata:

```json
{
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

The Ground/Par overlap is intentional. It is not treated as duplicate-data corruption.

## 4. Why D1 Still Matters

Even though the FS legacy Ground output contains the complete Master, D1 remains authoritative for:

- ground contact understanding
- anchor validation
- placement
- future collision/passability derivation
- whole-map compiler reasoning
- asset-family consistency checks

D1 is semantic infrastructure, not merely a bitmap export switch.

## 5. Backward Compatibility

v0.2 Validator/Compiler still accepts v0.1 metadata:

```json
{
  "export_rules": {
    "ground_layers": ["D1"],
    "par_layers": ["D3", "D4"]
  }
}
```

This runs in compatibility mode and emits `WARN_LEGACY_EXPORT_RULES_V0_1`.

Compatibility mode preserves old behavior; it does **not** redefine current FS Authority.

## 6. Shared Pipeline Principle

Semantic Depth should remain reusable across projects.

A future PMD AutoChess or CG Pet Battle render policy may consume the same semantic concepts differently without changing the Master Object or depth definitions.

**Depth describes the world. Render Policy describes the engine.**
