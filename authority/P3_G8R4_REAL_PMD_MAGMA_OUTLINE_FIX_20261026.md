# P3 G8R4 — Genuine PMD 0002/0003 Sprite-Atlas Repair (2026-10-26)

## Scope and explicit incident
The user repeatedly instructed assistant to edit *actual* PMD SpriteCollab derivative atlases, not generate illustrated pseudo-contact sheets. Prior responses wrongly sent ImageGen 10-row glossy pictures without original PMD XML compatibility. Those images are **invalid as game deliverables** and must never be used as baseline, exported to native PMD or claimed as production. G8R3 original source revision was user-liked direction; G8R4 carries on the real 32x32 source.

## WHAT WAS ACTUALLY DONE
- Source: immutable original `PMDCollab/SpriteCollab/sprite/0002` and `sprite/0003` each with their own `AnimData.xml`, offsets, shadows, 14 XML named motions (12 real animation atlases). No source import of fabricated image generated sheets.
- Candidate: `outputs/P3_G8R4_AUTHENTIC_FRAME_OUTLINE_MAGMA_20261026` in isolated Windows project. Only actual `Idle/Walk` D0 front, D2 side, D4 back, F0/F1 per species, **12 modified source cells each, 24 overall**; original 32x32 rects, timing and all unselected cell positions preserved; 0001 user-liked orange-gray juvenile left untouched. All F2 map work PAUSED per user.
- Diagnosed previously unresolved G8R3 flaw: PMD 0003's original back D4 frame F1 had a 6-pixel detached fragment at x25–26,y8–11 in both Idle/Walk, 2 pixels part of original blue-body protected region. Blind removal would damage source frog. G8R4 changes four black pixels to basalt mineral shades and adds precisely one basalt connection pixel at x25,y12. Connected-components QA finds **zero loose alpha fragments size<=8 in the upper half across 24 new frames**, and no original body alpha deletion.
- Repaired the prior lava-obscured-by-rock issue by adding editable topmost `G8R4_Visible_Crater_And_Connected_Outline_Repair` layer to each of **24 genuine OpenRaster `.ora`** samples. Orange-red lip and yellow molten highlights physically attach to the existing crater, small magma streaks on rock surface and body-mount-synchronized flame. 0002 has aggregate **136** revised layer opaque pixels across twelve sample frames; 0003 has **280**. These numbers refer to overlaid pixels, not uniquely created outline pixels.
- Merged ORA layers recompiled into original PMD 128x256 Idle/Walk image slots. Bit-identical originals for every other 10 action atlas images, XML/Offsets/Shadows, no touched atlas frame borders, preserved lower 3 foot alpha rows and all blue body silhouette alpha.

## QA performed
- Both species real original XML loaded through native Godot v4.7.2 XMLParser and OpenGL GPU bridge; 3 distinct rendered frames each, no ERROR/WARNING, both TECH PASS.
- ZIP isolated cold-unzip CRC and all file SHA parity, 24 source frame QA, bit-level XML offsets/shadows, OpenRaster composite parity, upper-alpha disconnected component and visible lava threshold tests all PASS; cold extracted both native Godot projects import/GPU replay PASS.
- **THIS DOES NOT certify original PMD game runtime or RPG Maker VX Tankentai SBS**, both NOT TESTED. **USER HUMAN ART GATE=PENDING**. In particular, 32x32 flame can still be too small in the user's desired actual-game scale. Do not claim a sealed visual PASS. Copyright/fan resource licensing/commercial attribution unresolved.

## Released official private artifacts
Full native real-source ZIP: https://drive.google.com/file/d/1hGKJsDAou5accNXC8P28zde7QvWYvta5/view?usp=drivesdk
2,006,776 bytes, 525 files, SHA256 `8fc5bb6073957093797b886bbbf169eb71aaf4f2b7b6db3f67d7d0a610093452`. Local/Drive SHA match.
0002 original/G8R3/G8R4 actual comparison: https://drive.google.com/file/d/1JKHff9pwJLyDZFQBaDWVbwmm914Hwp8u/view?usp=drivesdk
0003 original/G8R3/G8R4 actual comparison: https://drive.google.com/file/d/16c50CyKSnXc1XR3t2ECLZyD_sHXtodUG/view?usp=drivesdk
0002 Idle actual original-grid animated GIF: https://drive.google.com/file/d/119Cq_lQ4eOLVtqUHHB_78S2ebaVcVuB-/view?usp=drivesdk
0003 Idle: https://drive.google.com/file/d/1yd3Jqv4ibOaCshvL91MgSa7pEcmH6QAk/view?usp=drivesdk
Latest Handoff: https://drive.google.com/file/d/1leKM5CAye1hGRfkE8o0nmKk8vGPc452S/view?usp=drivesdk

## NEXT
Get human visual acceptance of authentic x4 preview and GIF. If failure, edit only identified native 32x32 pixels/layers and re-run fail-closed source/ORA/Godot/cold tests. Do not mass-expand original 682+698 cells or resume paused maps without explicit direction. Every iter ZIP+source+CMD+LOG+handoff Drive/GitHub/Linear.