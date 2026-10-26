# FS V6-2 / P2 Three Independent Ground-only Candidates R1 — 2026-10-26

## Deliverable status
**ACTUAL ART GENERATED, SOURCE AND QA EXECUTED; NOT FINAL HUMAN ART APPROVAL.** Three independent high-detail forest Ground-only candidates have been generated and converted to 544x416 (17x13 RPG Maker VX cells). No buildings, trees, cliff faces, waterfalls, large upright rocks, ponds or stair surfaces embedded in these three crops. Each uses a single pixel-exact crop from a distinct image-generation source (not a palette recolor, not a donor-patch quilt).

- A: botanical detail and branching paths, more visually busy.
- **B: INTERNAL WORKING CANDIDATE** for next controlled scene pilot: reasonably readable paths and balanced grass/flower densities. **USER ART PENDING.**
- C: a more open layout in parts, but route branching is less clearly legible and texture concentration uneven.

## Evidence: actual files and remote verification
Private Drive ZIP: https://drive.google.com/file/d/1fUhagQ3S8HwgznE9Cc8iVqbKNRREUOoy/view

Drive visual document with actual 3 embedded comparisons: https://docs.google.com/document/d/1vMIbcUPapq5D7gg2oe5l5FRO_WTNULDQ17UdLm_3a6Q/edit

SHA256: `4aa2e39c291630cb13bcfff4c257d3ad0d9d27157ead85d69f043bd2d9551051`. ZIP size 29,361,624 bytes, 37 entries. Contains 3 original new source PNGs, 3 544x416 Ground-only rasters, 3 2× nearest previews, individual 32px grids, all-walkable blocker masks, actual 1× RPG Maker VX Actor1 overlays in six placements, true Actor1 RTP frame SHA, SCENE21 reference/side-by-side, source provenance JSON, 1px negative test, `RUN_QA.py` & `RUN_QA.cmd`, `QA_RUN.json`, per-file SHA index and independent Handoff.

Local authored QA pass: 28/28.
Cold independent unzip in artifact container: 36 indexed files SHA256 checked; 28/28 QA pass.
**Remote Desktop Commander Windows download + SHA validation + unzip + rerun: 28/28 PASS** in:
`E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261026\G_P2_R1_3CANDIDATES\expanded`.
No modifications to sealed FS runtime, original F1R1 A04 assets, or another conversation's active map.

### Actual sprite verification
Authorized remote image `VX_ACTOR1_FACING_DOWN_CANDIDATE_FRAME.png` SHA256 `45e043a796cea88e3ff20cc24b916f8c4b5be7926c1afdf4e4ac514662480bd9` was extracted for 1× previews (32×32 frame; nontransparent bbox [2,0,30,32], visible 28×32). Source sprite is included only in **private Drive ZIP**, not pushed to public GitHub.

## Stage status
- P0 Source identity/canvas/provenance: TECH PASS.
- P1 Actual actor 1× scale: TECH PASS.
- P2 Ground-only: THREE INDEPENDENT ART CANDIDATES; internal visual screen PASS. **FORMAL USER ART GATE PENDING**. Source raster may be finer/softer in places than SCENE21 hand-pixel art; 2× nearest reproduces native pixels but does not prove identical art style.
- P3 Standalone complete PAR sources: NOT STARTED.
- P4 Contact/occlusion/object collision: NOT STARTED. Ground is walkable by default and blocker masks contain zero obstruction.
- P5 One canonical manifest to Tiled/Godot/RGSS2 compiled output: NOT STARTED.
- P6 Real RGSS2 Game.exe traversal/scroll: NOT RUN.
- P7 USER APPROVAL: PENDING.

## Next concrete development gate
Use B candidate as isolated technical test only. Compare its ground pixel density vs SCENE21 in real 1×, keeping pathways legible. If user considers B insufficiently pixel crisp/fidelity, re-author Ground source, do not blur/donor-quilt. After P2 user art acceptance, author one complete house/tree/soft-flora independently, capture true alpha/foot/occlusion, compile through FS source-first Manifest, verify native VX. Later expand accepted asset family to 1280×928 ground3 world; do not repeat-stamp these finite 544×416 crops across a 40×29 world.

Authority: https://docs.google.com/document/d/1aypbyssZaYh1SG8cae0iK98JW5ufU__xcXA-q3gLZu8/edit
Issue: SHO-39. 

Never conflate **28/28 technical QA** with artwork/user acceptance or engine validation.
