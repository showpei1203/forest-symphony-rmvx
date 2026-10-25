# Forest Symphony v2.5 S0 — Source-first minimal, fail-closed

Date: 2026-10-25
State: STATIC TECH PASS / COLD EXTRACT PASS / REAL WINDOWS VX BOOT SELF-TEST PASS / NATIVE SCREEN PIXEL REVIEW PENDING / USER VISUAL PENDING / RELEASE GATE BLOCKED.

**v2.4 SCENE21 remains VISUAL FAIL** and negative regression witness. Do not reuse any of its composite-gallery GrabCut assets or contaminated Ground. v2.1 well, v2.2 sacred tree, v2.3.3 isolated native baseline, v8 height work and formal FS SEALED runtime remain untouched.

## Private deliverables
- Full private candidate ZIP (92 entries, 6,024,895 bytes): https://drive.google.com/file/d/1qpGfIzWadWP-zOi0I5-aSAeQ41XqmuOC/view
- SHA256: `f762ad894fb41c880ac628095dc4ed084f9ec53a48336ba3b791c8d615d9ddc9`
- Google Drive RAW fetch confirmed file size and local SHA256/ZIP CRC after upload.
- Handoff: https://docs.google.com/document/d/1j-nhP4p1wRSFb03dIm0MImCvZyamIe6Ex3IAb9dCJ-k/edit
- Source rights PRIVATE ONLY; no game PNGs or commercial assets checked into GitHub.

## Build and source integrity
- New flat terrain Ground 544x576, synthesized only from vetted grass/earth patches of prior v2.2 terrain donor, seam-energy quilting without interpolation/blur. New scene does not flatten a complete generated Master into Ground, and does not place any bush/chapel into Ground.
- Source raw and rebuild recipes contained inside ZIP: three fully preserved standalone objects: v233 existing intact ochre cottage adjusted to subdued green roof colors, v22 complete sacred broadleaf, v233 standalone white-flower patch. All retain raw source provenance and 12px true transparent margin. No GrabCut, destructive X truncation or cropped gallery source.
- Single Scene Manifest, 3 PAR objects, Ground/PAR/Master/Occlusion/PixelOwner16/Collision/semantic masks from one deterministic compiler.
- Static RGBA compile diff=0, illegal +1px shift detected with 66,408 changed pixels, blocked=20, reachable=286, spawn=(8,13). These only prove technical consistency, not human art approval.
- Independent clean ZIP extraction and re-execution of source derivation, scene compilation, VX candidate build and static validator achieves pixel-identical Master, matching source SHA. Legacy v2.4 negative gate still rejects old build with 24 failure records.
- `release_gate_v25.py` exits code 2 by design until user visual acceptance and native pixel-vs-Master evidence both exist. **NEVER promote this candidate as FORMAL PASS** based only on engine logs.

## Real Windows native
- The exact private Drive ZIP was cold-extracted on authorized Windows Desktop Commander to E:/FS_V25_S0_NATIVE_TEST_20261025.
- True RMVX Game.exe started and its window title correctly displayed `FS_V25_SOURCE_FIRST_MINIMAL_TECH_PREVIEW`.
- Native runtime generated fresh FS_RICH_VX_LOG:
  ```
  RICH_SCRIPT_LOADED sha=2fd6182936c1c78d24d136dd68939ae74333da3cfba96b17e6d42999e7287d1e
  RICH_VX_BOOT spawn=[8, 13]
  STYLE_VX_LAYERS ground=544x576 props=3
  STYLE_VX_CAMERA offset=0,0 world=544x416
  STYLE_NATIVE_PASSABILITY move=true blocked=true camera=true src=true
  V25_MINIMAL_NATIVE_BASE_GATES_PASS
  RICH_RUNTIME_100_FRAMES player=8,11
  ```
- The native program booted and internal runtime tests report PASS; attempts to grab actual window pixels returned background Chrome after focus disappeared. **No native Game.exe screenshot comparison is claimed**, and no human art acceptance occurred. The log is included in final private ZIP.

## Next
1. Capture true unobstructed Game.exe frames, validate background Master nonplayer pixel equality and actor occlusion/wall collision/camera movement.
2. Human-inspect 100% Ground-only and all three Alpha source silhouettes and scene composition against user's SCENE21 reference. The current reuse of v233 cottage only provides a functional reference, not final SCENE21 building approval.
3. If any source fails, fix source object at provenance origin, never doctor PAR offsets or copy flattened images to Ground.
4. Only after source, tech and human visual gates pass expand to moss-stone terrain boundaries, steps, bridge Levels0/2, treehouse Level1, and eventually 864x640 forest elf village.
5. Keep per-version private ZIP + LOG + Handoff and read-back hashes.

SHO-39 modular asset / user geometry authority still applies.
