# Stage 16 A21 Failure and Preventative Rules
Date 2026-11-01. **Zero paid API calls. Formal Seal NO.**

- F-A21-01: A20 reference crop size 128 from a full village scene may include tree canopy, cliff edges or architecture; larger input is not automatically better input. Corrective action: verified clean direct native crops, sizes 96,128,64.
- F-A21-02: A full 128px grass-only crop was hard to source without tall-object fragments. Instead use direct 96px grass crop. PixelLab Style-v2 output size is still dictated by the largest 128px sand/style crop; mixed reference sizes allowed in public schema, but future paid payload acceptance is **not yet proven**.
- F-A21-03: Automated flower detector had false positives because pale sand and white decorations resemble flowers. Reject fully automatic semantic annotation. Manually inspect native flower patches and record possible vertical/occlusion depth ambiguity.
- F-A21-04: 'pure-ground' denotes **visual source curation**, not formal engine collision/parallax segmentation. Flowers still need depth review. Never make collision/occlusion PASS on image references alone.
- F-A21-05: Native source has 3,668-6,933 unique RGB per crop whereas A20 model outputs had 36-43 colors; no guarantee provider can preserve source texture fidelity simply by cleaner style references. Wait for a new genuine native model output to assess improvement.
- F-A21-06: No PixelLab paid POST in A21. No auto retry/ambiguous submission, no token/file-leak, no changes to sealed FS game or A20 source outputs. A22 dry-run spec is strictly NON-EXECUTED.
- F-A21-07: Cold ZIP confirms stored source/manifest/hashes; verification of original-full-Ground3 pixel equality is performed only where full private source is available. Public GitHub must NOT include FS private original crop PNGs.

**A21 reference input engineering PASS. New provider image/art NOT RUN. 544x416/Godot/VX NOT RUN. Formal Seal NO.**
