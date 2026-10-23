# Forest Symphony / Shared Game Art Tools v3 | 2026-10-24

STATUS: TOOL_V3_5_WORKFLOWS_EXTENDED_SMOKE_PASS, 9/9 new automated gates. Tool and format smoke only, not human visual Gate F.

Private verified ZIP (262 entries, 593980 bytes, SHA256 112904681915c41abeefc8a309c04bcadac7cc1e6123915c3664e1c3ed3652e3): https://drive.google.com/file/d/1eCfvKsZTbW1gGDCPr6K8axQz9eusjPW_/view
Current handoff: https://docs.google.com/document/d/1t145OVwzWz64o2Xyl9tfngLXBFrfptDKaFIBNLlOzSA/edit
Map B0 N5 freeze: https://docs.google.com/document/d/1jPAJMPf3nhKUDohCuzQZho9AsPJqEG0XPCvKj8u87tE/edit
170 exact Drive asset IDs: https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit
Tool matrix: https://docs.google.com/document/d/1XitoOS6llG9vlDL7vt2IoY0Wrm3gtk71ozc4RtVNEyo/edit

Local original: E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024; one-click RUN_TOOL_V3.cmd calls scripts/run_v3_all.py; machine report reports/ALL_TOOL_V3_REGRESSION.json.

New factual tool findings:
- T09 SpriteNormals CLI v0.1.0 MIT: 5 B0 props, 384x96 six-frame normal atlas matches independent frame maps at 0 visible normalized pixels; OpenGL/DirectX green inversion on 3287 visible pixels.
- T10 Laigter 1.14 GPL3: 10 real B0 sprite sources to 40 material outputs; all 40 require original source alpha repair; sheet and per-frame normals DIFFER by 1726 visible pixels. Prefer per-frame generation for animated sprites.
- T11 Pixelorama 1.2.3: Either Offset&Scale or Outline Shader Effect enabled leads to 0xC0000005 headless crash; with both disabled yet effect metadata retained 384x64 six-frame export succeeds. Crash can leave PNG; do not trust a file without exit 0. Actual shader rendering still FAIL/UNVERIFIED.
- T12 LibreSprite 1.3: six true native editable ASE cels and idle_sway tag, durations 80/95/110/125/100/70ms, exported 384x96 atlas and valid metadata JSON. All 6 PNG frames RGBA exact. A horizontal PNG sheet alone is not automatically a native timeline.
- T13 Godot 4.7.2 AMD RX6700XT OpenGL real GPU: four 224x224 source-first normals+animation captures; 2747 pixels change when moving the light, 3140 when toggling normal, 2593 between animation frames.

Never re-download known tools or rediscover known asset folders: consult registry. Neither normals tool supplies Ground/PAR semantic masks. Canonicalize alpha-zero RGB only for sprite normal comparison; full Ground/PAR RGBA must remain exact. Never put restricted raw source art or SEALED FS binary in public GitHub.

Next milestones: T14 LibreSprite JSON true timed animation and tag -> Godot AnimatedSprite2D with synced per-frame normal material. T15 Pixelorama GUI Shader Effect faithful export. T16 properly licensed PMD/LPC/SBS character/weapon animation integration. Map development remains paused at B0/N5 checkpoint with human visual Gate F outstanding.