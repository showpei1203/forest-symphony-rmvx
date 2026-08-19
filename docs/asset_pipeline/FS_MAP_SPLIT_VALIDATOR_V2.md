# FS Whole-Map Binary Ground / Complete PAR Validator v2

Status: SHO-39 implementation candidate, 2026-08-19.

## Authority

For current Forest Symphony whole-map work:

- `GROUND` = true ground/terrain surfaces + floor/terrain tiles + flowers + grass.
- `PAR` = everything else.
- Actor occlusion is not a PAR classification criterion.
- Completeness authority is `MASTER ≈ GROUND + COMPLETE PAR`.

This whole-map validator is separate from `validator/validate_asset.py` v0.2. The v0.2 tool remains the historical single-Master-Object D1/D3/D4 pipeline and is not rewritten by SHO-39.

## Formal gates

1. **Canvas / registration**: Master, Ground, and PAR must share exact dimensions; the Castle witness authority declares 1448×1086.
2. **Recomposition**: alpha-composite Ground + PAR and compare it to Master. Outputs include recomposition and diff evidence.
3. **PAR source fidelity**: visible PAR pixels must remain registered to Master rather than being shifted or from the wrong source.
4. **Witness-point completeness**: every required, visually confirmed non-Ground core point must have PAR alpha within its local tolerance radius.
5. **Alpha / residue QA**: PAR must contain real transparency; exact magenta/green chroma residue is blocking; partial-alpha edges are reported for visual inspection.
6. **SAM2 evidence**: optional Guided SAM2 overlap metrics are recorded as QA evidence only.

### Explicitly forbidden gate

There is **no** rule requiring 80% (or any fixed percentage) of an entire SAM2 object mask to exist in PAR. A fountain SAM2 mask can legally include water, flowers, grass, or floor, which belong to Ground under the Binary Authority. The deterministic regression suite contains a case with whole-mask PAR overlap below 80% that must still PASS when recomposition and witnesses are correct.

## Witness authority

`FS_CastleCity_Witnesses_v2.json` contains K01-K16 from Guided SAM2 v5.1. Candidate coordinates are seeded from the corrected v5.1 bboxes, but they are intentionally `visual_confirmed=false` until checked on the actual 1448×1086 Castle Master.

The validator treats any required unconfirmed witness as **FAIL**. This prevents bbox guesses from silently becoming Formal Authority.

A witness should be placed on a structure pixel that is guaranteed non-Ground under the Binary rule, for example masonry, roof, tower body, statue body/pedestal, fountain stone rim, gatehouse wall, or windmill structure. Do not place the witness on fountain water, flowers, grass, or floor.

Use `render_witness_preview.py` to render the candidate boxes and points over the Master before marking them confirmed.

## Usage

From a Python environment with Pillow installed:

```bash
python tools/fs_asset_pipeline/validator/render_witness_preview.py \
  --master castle.png \
  --witnesses tools/fs_asset_pipeline/samples/FS_CastleCity_Witnesses_v2.json \
  --out qa/witness_preview.png
```

After visual confirmation and after real `castle_ground.png` + `castle_par.png` exist:

```bash
python tools/fs_asset_pipeline/validator/validate_map_split_v2.py \
  --master castle.png \
  --ground castle_ground.png \
  --par castle_par.png \
  --witnesses tools/fs_asset_pipeline/samples/FS_CastleCity_Witnesses_v2.json \
  --sam2-audit guided_audit.json \
  --sam2-mask-dir object_masks \
  --out qa/castle_v2
```

SAM2 arguments are optional and never affect Formal PASS/FAIL through a whole-mask percentage threshold.

## Outputs

- `validation_report.json`
- `recomposed.png`
- `diff_rgb.png`
- `diff_heatmap.png`

The JSON report includes recomposition metrics, source-registration metrics, every witness result, alpha/chroma QA, and optional per-object SAM2 overlap evidence.

## Promotion boundary

A validator PASS is necessary but not by itself enough for Runtime approval. Ground must still visually read as coherent terrain without baked non-Ground objects, PAR must be exhaustive and clean, and the recomposed scene must visually match Master. Only after **Layer Visual PASS** does SHO-39 proceed to Collision / Exit / RMVX actor-scale testing.
