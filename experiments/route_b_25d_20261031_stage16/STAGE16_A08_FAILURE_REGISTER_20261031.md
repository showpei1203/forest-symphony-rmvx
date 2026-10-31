# Stage16 A08 Failure Taxonomy and Anti-Loop Rules (2026-10-31)
**F-A08-01** A07 semantic ControlNet successfully enforces road vs grass color separation but outputs uniform brown and two hallucinated boulders.
**F-A08-02** Activating IPAdapter sand reference inside the SAME A07 ControlNet pipeline moves mean RGB closer to source but produces a road of dense orange/white cobblestones. RGB means and 96.47% sand-like pixels are not art fidelity scores.
**F-A08-03** Textures are not spatially faithful: 48px ground3 fine-grain sand sample becomes large, diffuse, clustered rock elements. This is a material-scale failure, not a mask placement failure.
**F-A08-04** Two source variations between A07 and A08: IPAdapter becomes active and its reference is switched to 48px source; do not claim separate causal evidence for IPAdapter activation vs source-image selection. No factorial run performed.
**F-A08-05** Mask isolation again perfectly preserves all outside-road pixels (0 changes), but this cannot resolve wrong source visual language or unnatural road edges.
**F-A08-06** Mixed source baseline grass still neon/repeated texture; road-only local improvement cannot certify whole pure-Ground candidate.
**F-A08-07** A08 uses CPU FP32 because DirectML + IPAdapter previously caused native crash. Do not call RX6700XT combined IPAdapter GPU PASS.
**F-A08-08** No 544×416 accepted ground, no native Godot/VX engine validation, no PAR/Collision; Formal Seal NO. Avoid 11 more rounds of parameter random-search.
Next independent hypothesis: model/representation change with texture-specific training or low-denoise source material guidance, one fixed test with hard artifact rejection. Preserve Stage15 to A08 baselines.
