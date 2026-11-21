# Forest Symphony | T-B R4 | Monster Attack Timeline Native + Shared Palette QA Handoff

**Date:** 2026-11-21 (Asia/Taipei)  
**Branch:** `feat/fs-pixellab-tb-monster-20261121`  
**Linear:** `SHO-37`  
**Engine:** **Godot 4.7.2 only**, not RPG Maker VX.  
**Status:** `ACTIVE` / `ENGINEERING_NATIVE_PASS_SYNTHETIC_ONLY` / `PMD0001_ATTACK_ART_HOLD`.

## 1. Today's actual engineering DELTA

1. Preserved PMD0001/0002/0003 real source-locked 64x64 static artworks and V4 attack atlas, without alteration to the originals.
2. Detected **826 opaque RGB colors** in PMD0001 STATIC_64; tested a deterministic 32-color shared-palette V4 variant based on actual 0001/0002/0003 RGB, no dithering, **alpha mask pixel-exact** to the old V4. This is an art candidate, not an authorized new master.
3. Created a Godot 4.7.2 deterministic **Attack timeline controller** implementing a single 11 frame, 28 tick animation, F2 Rush/F5 Hit/F7 Return and attack completion. Emits signal only, never damages or changes battle balance. Timeline scans crossed event boundaries to avoid skipped hit during low-FPS play. Replay/cancel resets state.
4. Created private Godot visual comparison scene: same 11-frame attack original V4 vs shared 32-color candidate side by side. Controls SPACE play, C cancel, R replay. Animation pose quality remains HOLD.
5. Added `tb_attack_regression.py` and native GDScript validator. Offline checks use **actual private PNG files**, `19/19 PASS` for geometry, source SHA, palette alpha, order, frame drop, cancel, re-attack.
6. Added a **strictly synthetic PNG generator** (no private artwork) and public GitHub Actions native QA workflow. Remote official Godot 4.7.2 actually executed and job logs were read back.

## 2. Formal native QA evidence (script only)

- [GitHub Actions run 44872832030](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44872832030), head commit `a0d39789578d14179677fe6f51d729522403585a`, job ID **136750948876**, `completed/success`.
- Exact binary logged: `4.7.2.stable.official.ed1daf0bf`.
- Actual job log line:

```
TB_TIMELINE_NATIVE_PASS 4.7.2 events=R2,H5,T7,DONE fast_forward=pass cancel=pass 60hz=pass
```

- Environment: GitHub hosted Ubuntu, synthetic 384x288 sprite marker PNG (884 B); official Godot downloaded from release archive. **This is NOT real art native testing**. **The private PMD GIF/PNG never went to public CI.**

## 3. Private deliverables and provenance

- [R4 private Godot review ZIP](https://drive.google.com/file/d/1sXZy5VfR3dUyJVl6myYmWJNmpilbrTzv/view) (22 files; ZIP CRC PASS; SHA256 `9d37acde4ec5267c40f0dad3c6a8177d93fb9ca732deebe65755b90e87d6bfa7`).
- [R4 original V4 vs shared 32-color side-by-side contact](https://drive.google.com/file/d/1ju4hXZjcz7saCtu3H4N1PZUFv0rjmvgz/view).
- [R4 shared 32-color attack sheet](https://drive.google.com/file/d/1S61nUpH9TeVhGOqLBXHBF5oPSTFQLBbM/view): 11x96x96, 384x288; SHA256 `caa814f6349f127ef1347ca9eb6504210104b2728e748aff301062fe6f9c9956`.
- [Real-file 19/19 QA JSON](https://drive.google.com/file/d/1VUwGHiLIM2HVb1_VAJJ3-15JbSM5il5F/view).
- [R4 source/output SHA manifest](https://drive.google.com/file/d/1KFSoYdAqkzQdoHkORatI-tIMA1jwEK7a/view).
- Source PMD0001 64 px SHA256: `fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c`.
- Original V4 attack atlas SHA256: `08327c031e3962c50623aeb15f11961b5c7795c8794ad359dafb54e7315686d7`.

**GitHub scripts**, not copyrighted private art:
- `godot_port/experiments/pixellab_tb/tb_attack_timeline.gd`
- `godot_port/experiments/pixellab_tb/attack_timeline_demo.gd`
- `godot_port/experiments/pixellab_tb/attack_timeline_demo.tscn`
- `godot_port/experiments/pixellab_tb/tests/tb_attack_timeline_native_validator.gd`
- `godot_port/tools/pixellab_tb/tb_palette_shared.py`
- `godot_port/tools/pixellab_tb/tb_attack_regression.py`
- `godot_port/tools/pixellab_tb/generate_synthetic_tb_atlas.py`
- `.github/workflows/fs-tb-native-timeline-472.yml`

## 4. Gates and realistic limits

| Gate | Actual result |
|---|---|
| Existing source identity/SHA | PASS |
| V4 11-frame geometry/event definition | PASS (offline) |
| Shared 32-color alpha preservation | PASS (offline); art remains candidate |
| Offline real-file regression | **19/19 PASS** |
| Native Godot 4.7.2 ATTACK SCRIPT with synthetic texture | **PASS** (logs linked above) |
| Native Godot 4.7.2 with **real PMD images** | **NOT_RUN** |
| V4/V4 32-color visual art quality | **ART HOLD** (unresolved leg stretch + jaw seams) |
| Real PixelLab skeleton / Text V3 generation this turn | **NOT_RUN: 0 API jobs, 0 generations, cost 0** |
| New complete monster family #2 | NOT_RUN |

## 5. Failure Log / non-blocking repair limit

- `ATTACK_MESH_STRETCH` (BLOCKING): RBF deformation leg/shear elongates feet. Old V1 whole-body transform never reinstated. Freeze both as rejected/held; different generation technique is needed.
- `MOUTH_CAVITY_FLOATS` (BLOCKING): mouth cavity drawn as patch; no true skull/jaw joint. Do not promote to final without genuine key poses.
- `PALETTE_INCONSISTENCY` (NON-BLOCKING for current software QA; ART HOLD): concept image contains 826 colors, tested one deterministic 32-color candidate with same alpha. This is a style experiment, not a blanket 16-color mandate.
- `GODOT_PRIVATE_ASSET_NATIVE` (BLOCKING for full closure): cloud CI cannot access user's private Google Drive without exposing materials or authorized secure runner. Tested synthetic script instead, clearly marked.
- `PIXELLAB_PROVIDER_NOT_CONNECTED` (BLOCKING for requested PixelLab source-locked animation): official PixelLab provider API/credential not accessible in this runtime; do not fabricate paid jobs. No user-PC temp library created, so no fallback to Windows local artifacts without explicit authorization.

## 6. NEXT MACRO UNIT

**Replace V4 interpolation with genuinely drawn or PixelLab-constrained four-limb and lower-jaw key frames**, maintaining 96px canvas, 11F, 28 ticks and F2/F5/F7 event mapping. Use an approved PixelLab account/API **only if securely available**; track each real job and cost. Then import real PRIVATE PNG into a Godot 4.7.2 executor, obtain screenshots/video and human ART approval. The controller is ready to accept the future approved atlas without modifying FS battle logic.

**Storage/permissions:** Only private Drive stores image/ZIP; GitHub stores text/code/CI; user's personal Windows PC untouched; no edits to T-A/T-C/main; central Control Tower status is not edited by T-B.
