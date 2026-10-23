# V3 Open-Source Tool Validation｜Current Handoff 2026-10-24

Status: **T09–T13 EXTENDED_SMOKE**, source-first B0 technical art, **NOT FORMAL VISUAL PASS**.

## Read first (do not rediscover)
1. Map checkpoint, signed N5 B0 progress and next art goals: https://docs.google.com/document/d/1jPAJMPf3nhKUDohCuzQZho9AsPJqEG0XPCvKj8u87tE/edit
2. Asset path registry, exact 170 Drive file IDs: https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit
3. Tool matrix: https://docs.google.com/document/d/1XitoOS6llG9vlDL7vt2IoY0Wrm3gtk71ozc4RtVNEyo/edit
4. Tool operation manual: https://docs.google.com/document/d/1lx8pbTkwetZFowHWqLI9r4NtXb7WUxFswSq450Vrln4/edit
5. Original ToolValidation v2 at `E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023`, older all 11/11 PASS. Do not repeat blindly.

## Latest execution
`E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024`, `RUN_TOOL_TESTS_V3.cmd`, full machine-readable reports in `reports/`.
- T09 Sprite Fusion Rust native CLI: B0 sprite batch, 6 distinct frame animation sheet canonical visible RGBA 0 difference vs independent frame normals, plus OpenGL vs DirectX Y inversion.
- T10 Laigter: 40 material PNG output, Alpha needs repair; source Alpha put back, 40 outputs audited. Whole sheet ≠ independent frame normals, 1726 visible pixel diff, seam 100.
- T11 Pixelorama original shader PXO headless crash 0xC0000005; disabled both effects successful but does not prove shader works. Cleaned original exported 6 slots but identical cels.
- T11B Pixelorama custom actual six B0 tree frames real native .pxo, 384×96 export 6/6 byte-exact, 6 unique.
- T12 LibreSprite true six-frame .ase creation, frame durations 70,90,110,130,150,170ms, idle Tag, metadata JSON, 6/6 RGBA equal to source.
- T13 Godot B0 Native RX6700XT OpenGL visual test: tree/rock, Laigter vs SpriteNormals, normal on/off, light left/right, 12 non-headless images; tree different pixels between providers 1258, rock 231; outside-sprite background delta zero. Artistic preference requires human acceptance.
- See JSON reports T09_SPRITENORMALS_B0_ANIMATION, T10_LAIGTER_B0_BATCH, T11_PIXELORAMA_SHADER_VARIANTS, T11B_PIXELORAMA_REAL_B0_ANIMATION, T12_LIBRESPRITE_NATIVE_METADATA, T13_GODOT_B0_NORMAL_COMPARE.

## Isolated legal/source state
All current B0 sprites were procedurally authored specifically for testing; no legacy Hanzo art. Original Pixelorama shader example used only as licensed official reference inside private test. GPL binaries not stored in user ZIP. No SEALED FS scripts/maps modified.

## Next TOOL gates
P0 shader-headless alternative or explicit FAIL/BLOCKED documented; P0 per-frame Laigter robust atlas export + normal orientation tests; P1 Godot real multi-frame normal animation, comparison with LibreSprite frame JSON adapter; P1 PMD/CG/LPC weapon and monster practical sprites; P2 browser-only SpriteLab license verification. Keep each Gate's inputs, outputs, runnable script, image, hashes, and error logs. Update this Handoff, Matrix and GitHub Authority/Linear as tests change.

## Map state held constant
N5 official SEALED code 505 scripts untouched, Map900 test adapter isolated 506 scripts. B0 6/6 isolated Runtime integration smoke PASS. Rich reference scene, bridge/underpass height system, legal Approved Source Kit and user human Gate F NOT PASS.
