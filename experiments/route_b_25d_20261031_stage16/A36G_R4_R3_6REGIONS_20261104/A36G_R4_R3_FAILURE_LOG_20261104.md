# A36G R4 R3 | Failure log | 2026-11-04

1. R4 first full-scene composite included a sharp SOUTH-WEST upper boundary and EAST source start boundary. ART FAIL. Fixed only compiled source alpha at internal image edges using irregular transition in r4_fix_region_seams_r2.py, preserving each native PixelLab RGBA. Before/after PNG retained.
2. Full-region source-first generation was performed with 6 ONE-SHOT PixelLab calls with separate submission locks. Native dimensions respect maximum 464×576. No duplicate charge/retry. All six succeeded with real independent transparent RGBA.
3. Replacing 267 earlier independent sprites by whole-forest alpha groups left 137 old root-block anchor positions to verify. Root coverage script found 3 near missing generated alpha; R4 R3 restored original native tree sprite sources at those exact anchors. Avoid invisible blockers in future.
4. Root positions and actual new tree trunk placement are not necessarily aligned even if alpha coverage is high. Must audit 137 root anchors in native engine, not assert collision semantic perfection from the 919/919 path connectivity test.
5. Independent Godot / VX tests only count as ENGINE_SMOKE_PASS. Art still awaiting user review and cold package archive is separately recorded, formal seal NO.
6. House and West base art intentionally reused from successful R3B rather than re-generating. Original A36F R1 and R3B never overwritten.
