# Stage16 A15 failure categories / anti-loop

2026-10-31 | original A14 AI reference preserved; Formal Seal NO.

- **F-A15-01 Source periodic grid absent:** A14 source period test for pitches 2–16 gives no strong joint peak (max ratio ~1.027); synthetic perfect 4px grid gives strong calibrated signal. A forced new output grid is **not** a recovered original artist grid. This test is a narrow diagnostic, not universal detection proof.
- **F-A15-02 Geometry vs aesthetics:** two/four-pixel integer-aligned output passes block uniformity 100% by construction. It destroys identifiable tiny flower and fern shape in 32px crop views. Do not call numerical lattice pass a Ground3 visual pass.
- **F-A15-03 Robust cell medoid & palette do not repair semantics:** full 544×416 sample still shows pseudo-pixel foliage. 2px/4px versions produce bigger simple squares; no restored source botanical structure.
- **F-A15-04 Genuine external code core manual grid contract:** cloned PixelPipeline commit 55002622 and executed its `perfect-pixel==0.1.4` source dependency on actual A14 AI PNG; requested 544×416 yielded 478×365, requested 272×208 yielded 286×219. Do not silently stretch results; return explicit FAIL contract.
- **F-A15-05 Node vs library distinction:** `get_perfect_pixel()` is an upstream library, not the ComfyUI PixelPipeline frontend node. Current Windows ComfyUI v0.3.40 venv lacks `comfy_api.latest` needed by current V3 plugin; no verified ComfyUI node end-to-end execution. No claim of full node PASS.
- **F-A15-06 Scope:** No Ground3 private reference pixel visual acceptance; no Godot/VX native runtime; no PAR/collision changes. FS production remains untouched.
- **F-A15-07 STOP repeated resample loops:** A16 should test a genuine native pixel-art generator or high quality manual pixel space reconstruction of original botanical form, not 15 more nearest/Lanczos/2x lattice variations.
