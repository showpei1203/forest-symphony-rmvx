# Forest Symphony / Agent Sprite Forge A14: source-pixel paw check and occlusion fail-closed

**2026-10-31 | TECH PASS, ART FAIL/PENDING.** Formal game assets, Tankentai/VX scripts, R17 maps and all K4/N5 baselines remain unchanged.

## Main objective

Generate a character or monster **once** as an AI Master, create new identity-preserving *credible* actions, assemble transparent sprite sheets with ASF and preview in Godot, then approve by visual art Gate F. A14 intentionally prioritizes art-source correctness, not merely celebrating another zero-error exporter.

## Actual results on the authorized Windows machine

Source: private A10 Forest Scout Master (64×80), A10 Moss Antler Master (64×64) and A13-R3 isolated clips. New test root:
`E:\GameAssetToolLab_20261023\ASF_Test_20261031\A14_OCCLUSION_RIG`.

**1. Pixel evidence for foot locking (more rigorous than the previous JSON coordinates).**

From actual A13 R3 transparent attack PNG renders, read the *original cropped hoof patches* from the A10 source and compare the bottom four rows of the near-side hoof textures against the corresponding opaque output pixels, at their independently recorded source-relative positions.

- `front_near`: 6 planted pose samples × 24 opaque hoof pixels = **144/144 exact**.
- `back_near`: 5 planted pose samples × 17 opaque hoof pixels = **85/85 exact**.
- Total **229/229 exact RGBA pixel comparisons**. This confirms these near-leg patches are visible at the compositor's intended source positions. It does not test every paw, interframe root-space velocity, anatomy, or overall believability. The comparison deliberately uses prior A13 R3 output as baseline; do not misrepresent it as an independent full A14 post-edit animation-quality test.
- `scripts/audit_rendered_hooves.py` + `data/A14_A13_RENDERED_HOOF_AUDIT.json` preserve exact sampling and counts.

**2. T2 R4 real source-art rest/return repair.**

The previous A13 moving-legs renderer produced visible patch seams even in static start/end poses. A14 changes *only* `T2_moss_antler/frames/attack_00.png` and `attack_07.png`: each is now the exact original single A10 64×64 RGBA Master composited at (16,15) in a 96×96 transparent frame. Verified byte-for-byte source-pixel equality. All other 36 T2 frames and **all 46 T1 frames** remain identical to A13; there is no speculative global repaint. The moving poses still contain seams, so **G7 NOT PASSED**.

**3. T1 scabbard backfill negative result, fail-closed.**

An initial hypothesis about which master pixels to remove at the hip did **not** match any pixels in the actual overlaid attack frames: **0 source-identical pixels safely replaced**. Rather than erase unknown equipment/hand layers, we explicitly left **100% of T1 frames untouched**, and recorded `T1_SCABBARD_MASK_NOT_GROUNDED`. We do NOT claim the sword-drawing/scabbard state or hand grip fixed. Next stage requires manual semantic mask identification and hidden-region source reconstruction.

## Real ASF and Godot engine regression

- ASF `build_animation_clips.py --strict`: **T1 6 clips / 46 frames; T2 5 clips / 38 source frames; both zero warnings**.
- ASF `export_engine.py --target all`: Aseprite JSON, Godot SpriteFrames, Godot Sprite3D all succeeded; T2 exported 37 animation frames due to existing duplicate faint-frame handling.
- Godot 4.7.2 stable / Radeon RX6700XT / OpenGL3.3 loaded both ASF exported scenes and played all 11 clips. Two real GPU captures; **22/22 matching source-frame RGB ROIs exact**, no discrepancies.
- Visual Gate F remains FAILED/PENDING; source pixel parity is not a rating of believable combat.
- Source sprites and true image captures are PRIVATE, not committed to public GitHub.

## Numeric QA and archive

`data/A14_R4_FORMAL_QA.json` proves only two changed attack files, original other clips identical, recorded 229 hoof comparisons, actual ASF and Godot pass; `data/A14_R4_ARCHIVE_INVENTORY.json` contains private archive details.

The private Windows-only full package: `A14_R4_PRIVATE_20261031.zip`, 635 files / 2,812,406 bytes / ZIP CRC PASS / SHA256 `03586be3347374552496185e5651f2b80160aa8457fcfe5dd3324fe8ba053e51`. It has **NOT been uploaded as a binary to Drive or GitHub**.

GitHub contains original *scripts, structured QA and lessons*, excluding copyrighted or privately sourced character art.

## A15 decisions

1. **No more T1 blind pixel deletions**. Produce a semantically reviewed overlay of the A10 64×80 Master with exact scabbard, hilt, hand, arm and waist polygons. First show before/after at 1× and 3×, only then produce a candidate. If any region is ambiguous, mark that part PENDING.
2. Extract T2 near/far leg with actual explicit occlusion masks and fill only newly exposed torso/body gaps using approved color/edge guidance. Verify *rendered hoof displacement* in actual GPU captures and a coherent 4-beat / charge timeline.
3. Fix actual pose readability (anticipation / contact / followthrough) before recompiling ASF again; the exporter is already proven, and extra zero-error checks do not compensate for poor art.
4. Only human-reviewed frames can advance to VX/Tankentai, then original FS.
5. No image-to-video model route was installed or validated; no claims of I2V success.

**A14 outcome: conservative rest-state repair + stronger actual pixel evidence; single-master natural action and formal art approval still incomplete.**
