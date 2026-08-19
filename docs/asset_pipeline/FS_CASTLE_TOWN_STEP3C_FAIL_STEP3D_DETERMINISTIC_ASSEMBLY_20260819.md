# FS Castle Town — Step 3C FAIL / Step 3D Deterministic Assembly

Date: 2026-08-19
Branch workflow: SHO-39

## Step 3C-R1
Result: **FAIL_STOP_BEFORE_ANCHOR_QA**

- Ground canvas: `1448x1086`
- Generated NORTH PAR canvas: `1491x1055`
- Canvas gate: FAIL
- Alpha transparent: `1,029,635`
- Alpha partial: `542,882`
- Alpha opaque: `488`
- Unique alpha values: `256`
- Partial-alpha ratio: `34.5124%`
- Alpha-integrity gate: FAIL
- South transparency gate: not eligible because canvas mismatch

The failed whole-North generation must not be resized/cropped/force-registered into acceptance.

## Step 3D execution change
Whole-region generative layout is no longer trusted for exact runtime registration. Use **per-anchor/object-group generation + deterministic assembly**.

Each North anchor has:
- fixed target bbox;
- Master reference crop;
- Ground reference crop;
- deterministic integer placement coordinates.

The generation model may create the local object/group appearance but may not choose its global map position.

Prepared anchors: `N0A, N0B, N1A, N1B, N2A, N3A, N3B, N4A, N4B, N4C, NP0, NP1, NP2, NP3`.

## Next legal step
Generate **only N0A Main Castle Compound** as an isolated transparent asset. Validate alpha, silhouette, scale, and deterministic placement into target bbox `[600,30,820,305]` before generating N0B or any other anchor.
