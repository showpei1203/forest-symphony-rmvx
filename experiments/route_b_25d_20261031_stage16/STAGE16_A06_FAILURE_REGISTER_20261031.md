# Stage16 A06 Failure Classes and anti-loop rule
2026-10-31 | Gate: Model source PASS / art FAIL / Formal Seal NO

F16A06-01: A05 mixed reference and removing reference both misgenerated sandy road as green. Actual material-specific sand-only input 48px raised sand-like RGB proxy from 30.11 to 35.66% but left 56.70% greenish road pixels. A real model reference feature cannot guarantee semantic material identity.
F16A06-02: A06 1x output contains unnatural red vein-like artifacts and green patches in exact target road corridor. Native 32px nearest-neighbor comparison is unacceptably blurred relative to fine, crisp Ground3 sand.
F16A06-03: Only reference LoadImage changed (plus output file prefix); reference native dimensions differ 128 vs 48. A/B tests effect of swapping image inputs, cannot separately attribute to sand semantics versus image scale or representation; no invented art-score claims.
F16A06-04: color ratio is proxy only. Reference selected by threshold and human review; sand-like sample fraction 89.5% does not mean 100% semantically sand nor transparent ground mask.
F16A06-05: Spatial mask fully works (road 28,818 regenerated / 0 outside changes). Do not use this engineering success as artwork acceptance. Source Ground3 composite still not recreated.
F16A06-06: ControlNet semantic seg model expects ADE20K/COCO colored category annotations; arbitrary black/white mask will not encode road vs grass semantics correctly. Must validate palette and labels before new checkpoint download.
F16A06-07: There is no Godot/VX run at A06 art gate. Formal Seal NO, old Stage15 experiment and FS production unchanged.

Recommended A07: select explicit material category + matched palette or domain-specific model; one controlled image evidence trial, separate visuals and engineering. Stop repeating existing SD1.5 IPAdapter image prompting.
