# FS Open-Source Game Art Tool Validation V3.1 | 2026-10-24

Status: **T09–T13 EXTENDED ISOLATED SMOKE PASS**, not human visual acceptance or map production FORMAL PASS.

## Canonical handoffs and evidence
- Current map checkpoint: https://docs.google.com/document/d/1jPAJMPf3nhKUDohCuzQZho9AsPJqEG0XPCvKj8u87tE/edit
- 170 exact asset file IDs, anti-rediscovery registry: https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit
- Tool V3 handoff: https://docs.google.com/document/d/1ADZXSADZA80uD25j6pyKqIeUpSLdUJYQMRoIENL_McQ/edit
- Verified V3.1 ZIP (244 entries, 586,144 bytes, per-member SHA + CRC): https://drive.google.com/file/d/17c7fkGMyLZenBJrfAJz4pCajlbg4G2aJ/view
- ZIP sha256: `d8a248de981d1d1c3b7f19028b38939767914a2bdf362e7cbc8c815da69c6451`
- Full script/asset/log workspace on user-authorized Windows: `E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024`
- Re-run: `RUN_TOOL_TESTS_V3.cmd`; machine report: `reports/V3_ALL_TOOLS_SUMMARY.json`.
- Prior T01–T08 v2 11/11 smoke baseline was deliberately **not rerun**. V3 independent 9 stages + final report cross-check = **10/10 pass**.

## Tool results
| Gate | Native output and validation | Limits |
|---|---|---|
| T09 Sprite Fusion Sprite Normals CLI | Real B0 tree/rock/sign/cliff/stair and six unique animation sprites. Sheet normals vs separately generated frames 0 visible pixels after transparent RGB canonicalization, OpenGL vs DirectX Y inversion negative check | Normals are lighting, not Ground/PAR/collision geometry |
| T10 Laigter | 10 B0 source sprites × normal/specular/occlusion/parallax = 40 PNG, every output size matched | Native alpha differs from source and requires explicit repair; sheet-derived normals differ from per-frame generation by 1726 visible pixels, 100 near seams, no atlas parity claim |
| T11 Pixelorama 1.2.3 shader effects | Shader-enabled PXO native headless crashes with Windows 0xC0000005; both effects disabled or removed can export | **EFFECTS HEADLESS FAIL** despite occasional orphan PNG after process crash; clean official frames can be pixel-identical |
| T11B Pixelorama B0 real six-frame PXO | Native 64x96 each ×6, export 384x96, six distinct frames, all 6 original RGBA exact | Does not validate headless shaders |
| T12 LibreSprite 1.3 | Authored genuine animated ASE with six distinct frames, PNG 384x96, JSON durations 70/90/110/130/150/170 ms, idle tag forward 0–5, all six RGBA exact | PNG contact sheet alone cannot store animation timing/tag |
| T13 Godot 4.7.2 GPU | Native RX6700XT OpenGL, CanvasTexture & PointLight2D, tree/rock × SpriteFusion/Laigter/no normal × left/right light = 12 actual 160x160 captures. Tree two normals differ in 1258 visible pixels, rock 231, all background diffs zero | Art quality and intended style remain human-unverified |

## Safety and reproducibility
V3 images are owned test-only B0 sprite primitives, not licensing-uncertain Hanzo art. Pixelorama original example is licensed/preserved for private effect reproduction; large external tool executables and restricted art are never committed. Results can be recreated from local scripts on the authorized device. Forest Symphony sealed Phase49N5 original 505 scripts remain unchanged, Map900 isolated adapter source-first B0 6/6 native compatibility PASS. Actual SCENE04 visual fidelity, human Gate F and rich village are still pending.

## Next tool gate order
T14 per-frame Laigter repaired-alpha atlas + seam negative → T15 Pixelorama headless effects version isolation → T16 LibreSprite animation JSON to Godot SpriteFrames/VX SBS adapter → T17 PMD/LPC/SBS practical sprite variants with rights checks → T18 animated lighting and performance on real GPU. Pause map modifications until explicitly resumed.
