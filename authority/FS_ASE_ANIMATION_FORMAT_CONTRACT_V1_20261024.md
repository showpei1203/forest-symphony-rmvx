# Forest Symphony | ASE Animation Format Contract V1 (2026-10-24)

STATUS: `STATIC_NATIVE_ASE_METADATA_AUDIT_PASS`; independent tool workstream only. NO map, N5 adapter, or SEALED FS Script modifications. Human Gate F still PENDING.

## Data authority
- Editable master: `.ase` / `.aseprite` (same little-endian format, 128-byte header, magic 0xA5E0).
- Frames: 16-byte frame headers, magic 0xF1FA, **per-frame duration** (do not trust deprecated file-wide speed). 
- Chunks: 0x2004 Layer, 0x2005 Cel, 0x2018 Tags. Native frame times and tag ranges are the source of truth.
- Export: PNG texture plus matching JSON metadata (`json-array` preferred for indexed playback; `json-hash` also valid). The PNG alone does not preserve time/tags/layers.
- Pixelorama `.pxo` is a separate native project format and is not interchangeable with ASE.

## Verified actual fixtures (remote DESKTOP-90VT437, read-only)
| Fixture | ASE source | JSON type | durations ms | Tag | sheet | Native hash |
|---|---|---|---|---|---|---|
| T12 latest | inputs/libresprite/tree_6frame_native.ase | json-hash | 70,90,110,130,150,170 | idle 0..5 forward | 384x96 | 13368ad505bbb16d2c26cbc1a132048298d23ad24c1f001f5b0888617aef53a2 |
| T12 older | inputs/B0_TREE_6FRAME_EDITABLE.ase | json-array | 80,95,110,125,100,70 | idle_sway 0..5 forward | 384x96 | 745bf92a4007c6ac33238ed0973a9760f5a8af2b26a1f9e022fdf496fa5cfc1a |

Both actual ASE binary files parsed independently (6 native frames, 6 cels, 1 layer each), durations matched exported JSON, tags and frame rectangles matched, real PNG RGBA 384x96 dimensions matched: **2/2 STATIC FORMAT PASS**. The latest diffuse/Laigter per-frame normal atlas also matched size 384x96 and alpha exactly.

**Critical regression guard:** never replace the latest 70/90/110/130/150/170 `idle` dataset with the separate older 80/95/110/125/100/70 `idle_sway` fixture. Bound every export and Godot/VX adapter to one source SHA + its own JSON.

## Approved command shape (LibreSprite 1.3)
```bat
libresprite.exe -b --list-tags --sheet-type horizontal --format json-array --sheet "output.png" --data "output.json" "input.ase"
```

## Data Gate (fail closed)
1. ASE header/file size, frame/chunk bounds, native times/tags valid.
2. JSON frame count/times/tags exactly equal to that ASE.
3. Six untrimmed, unrotated, horizontal 64x96 frames at x=0,64,128,192,256,320.
4. Sheet + Normal dimensions and diffuse/normal alpha identical.
5. Negative mutation tests reject altered duration, tag, 1px displacement or alpha.
6. Tool PASS **does not imply** Godot native artistic acceptance, original Forest Symphony Gate F, or VX RGSS2 native Normal Map support.

## Art/engine boundary
Normal generator `parallax` materials are not FS Ground/PAR layers. Real map Ground/ParBase/Occlusion/Collision/HeightRegions remain compiled deterministically from one Scene Manifest. No separate background generation and no unlicensed asset promotion.

## Locations, evidence and references
- Remote independent audit: `E:\GameAssetToolLab_20261023\ASE_Format_Audit_20261024\audit_native_ase.py` and `NATIVE_ASE_FORMAT_AUDIT.json`.
- Existing T12 logs: `E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024\reports\T12_LIBRESPRITE_NATIVE_METADATA.json` and `T12_LIBRESPRITE_NATIVE_ANIMATION.json`.
- T14 normals: `outputs/t14_per_frame/tree_6frame_normal_perframe.png`.
- Latest V3.1 tool pack: https://drive.google.com/file/d/17c7fkGMyLZenBJrfAJz4pCajlbg4G2aJ/view
- Native ASE spec: https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md
- CLI: https://aseprite.com/docs/cli/
- Map checkpoint: https://docs.google.com/document/d/1jPAJMPf3nhKUDohCuzQZho9AsPJqEG0XPCvKj8u87tE/edit

Next distinct work: resolve Pixelorama Shader Effects render failure (GUI/native rendering as separate Gate); legal PMD/LPC/SBS real-source alignment; continue Godot motion/normal visual QA when needed.