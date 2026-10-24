# Forest Symphony | Ground/PAR Dynamic Actor Depth Regression V1 (2026-10-24)

**TECHNICAL PASS for private RichPilot V2.1 regression. Not a new map, not formal FS/VX seal, not a replacement for existing B1 V8 source-owner engine.**

## Authority and baseline
The team now has **B1 dual-river bridge V8** as the latest *playable native VX isolated technical candidate*, with 49 props, 43 ground flora and 25 native bridge/treehouse height interaction gates. Official V8 handoff:
https://docs.google.com/document/d/18XZqneH0Wwt0TRDmn5XadbtgML7KUgvSLEt-1E5CJXM/edit

Before V8, RichPilot V2.1 had 48 sprites and fixed Ground+Par_BASE+Occlusion. Its static full-scene Master always recomposed identically, which proves nothing about moving actors. This regression test *independently probes the failure mode*. Note **V3/V8 already implemented Pixel Owner ID plus actor-aware native VX Y-sort and had 239 legal-depth oracles passing**, so the present V1 is additive research evidence and a dense continuous-coordinate counterexample, NOT a claim of inventing the first fix.

## Measured results
- World 864x640, 48 objects, 19 ground flora, 5 interaction features.
- Source clean image SHAs match all 48 original instance manifest declarations.
- Dense **8px** sample of legal walkable positions: **450** actor positions where the old static `Ground + Par_BASE + Actor + Occlusion` differs from actual source-object Y-sort; max **193** incorrect visible pixels for a 20x28 test actor.
- Four highest/worst z-index witnesses (x,y): (800,432),(496,256),(448,256),(712,504). Rebuilding the scene from *one manifest* as source objects ordered before or after the actor produced **0** mismatch for each of the four.
- Native Godot 4.7.2 genuine RX6700XT OpenGL 3.3 visible GPU rendered **four independent 864x640 screenshots**. All four are **RGB exact (max difference 0)** relative to the independently generated Pillow source-first painter frame.
- False-positive regression: old fixed front mask fails even though master image with no actor matches exactly.
- Full self-contained Windows `RUN_DEPTH_GATE.cmd` uses shipped Godot.exe, Python/Pillow; actual Windows re-run **exit0 PASS**.

## Reproducible artifact and provenance
Complete zipped test fixture contains original 48 object/private sprites, one manifest, original Ground/PAR/Owner materials, four comparison panels, four real GPU captures, independent source-first code, runnable CMD, LOG/JSON and portable Godot 4.7.2 binary. ZIP private only because source asset licensing is unresolved.

Drive private link: https://drive.google.com/file/d/1574O23MRbG5U3UsQbqqFWI_1IepZFoBf/view
ZIP bytes: **92,696,839**; 94 files; SHA256 `9875676e103602ca02250bd5b8f1c3d2901bc6d643d19c23aa58c8206ab83bb8`, CRC / all file SHA pass; sync disk copy SHA equal.

Source scripts under `tools/fs_map_dynamic_depth_v1/` in `feature/fs-map-dynamic-par-depth-v1-20261024`.

## Correct interpretation
1. Flat image agreement does not demonstrate actor depth correctness.
2. Runtime must preserve Instance ID/Anchor/foot-order and the actor-relative occlusion decisions for all legal positions. Immutable ParBase/Occ is insufficient in general.
3. The **currently newest B1 V8** already handles ground sprites via Pixel Owner and separate Level1/Level2 masks on isolated native VX. Reuse and extend those data structures. Do not fork an obsolete second gameplay depth engine.
4. **Formal FS Phase49N5 and 505 sealed scripts are untouched**; no N5 integration claimed.
5. Rich visual aesthetic quality vs the six concept images, legal asset license signoff and Human Gate F remain **NOT PASS**.

Next: prioritize B1 source-first artistic fidelity (sacred central tree, unique buildings, riverbanks) and actual V8 Level1/Level2 + N5 isolated adapter integration, not repeat the same V2 static test.
