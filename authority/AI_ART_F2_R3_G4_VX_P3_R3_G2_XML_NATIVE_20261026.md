# F2_R3 G4 native VX and P3_R3 G2 native Godot/XML — Authority, 2026-10-26

## Version gates
**F1R1 A04:** accepted reference, user visual PASS, SHA256 `0a407d9dce66183703fe957193a396cc59648d3b4502cd0c83e4f83e3035272b`. Unmodified, no sealed mainline touched.

**F2_R3 G4:** actual isolated RPG Maker VX `Game.exe` on user Windows, TECH PASS for 1440×1088 map scrolling and 45×34 1,530-grid collision, **GROUND ART FAIL** due to obvious clone-patch seams. 9 independently owned sprites; 711 blocked and 819 free, all free reachable.
- A real regression discovered in G3: door (26,14) was blocked, but immediately adjacent front (26,15) was ALSO blocked. Prior report falsely called (26,17) the doorfront.
- G4 fixes exact front (26,15) to WALK and closed door (26,14) stays BLOCKED, stairs (26,16),(26,17) walkable. Actual native step-from-(26,16)-to-(26,15) success, second move into door denied.
- Real VX execution signed `F2G4_VX_NATIVE_1530_1530_PASS`, all 1,530 passability cells 0 wrong, 9 loaded props, long map pan PASS.
- Fresh ZIP extraction and second actual native `Game.exe` replay PASS.
- Private [F2 G4 complete SOURCE + Game.exe + autottest ZIP](https://drive.google.com/file/d/1yexm1LP0g_GeBLrBNnO69TNEdUHrkV6z/view?usp=drivesdk): **17,355,566 bytes**, SHA256 `a174ee9404a2ab8381c7618f87a89fed8e2770538ec1f07752cb99e958f55dcc`, 83 files, CRC/cold hashes and native tests PASS.
- This ZIP is engineering QA only. Underpaint remains obviously artificial. **HUMAN ART Gate not passed** and commercial licensing unverified. Prior G3R1 file and original references preserved.

**P3_R3 G2:** actual Godot v4.7.2 native XMLParser and RX6700XT OpenGL 3 GPU bridge, TECH PASS. Directly parsed unmodified PMDCollab/SpriteCollab sprite/0001 `AnimData.xml`, 36 named motions including 2 CopyOf, **34 real action spritesheets, 1,123 original cells**, original XML/Offsets/Shadows bytewise equal.
- Three action frames rendered through actual GPU; screenshots differ; XML/texture metadata correct. Cold ZIP extracted and re-executed native Godot, ZERO errors/warnings, signed `P3_NATIVE_GODOT_XML_GPU_PASS`.
- Early native XMLParser attempted `get_node_name()` on `NODE_TEXT`, triggering hundreds of engine errors: FIXED conditional name getter, and preserved first FAIL. `Image.load_from_file()` caused Godot warnings about export; FIXED via `FileAccess.get_file_as_bytes` + `Image.load_png_from_buffer`. Action cell size now comes from each XML record rather than image-size heuristics.
- Private [P3 native Godot XML playable/source/QA ZIP](https://drive.google.com/file/d/1Ds611w37VxgXsSUJFNHVHuYfm9s3Z8tE/view?usp=drivesdk): **623,374 bytes**, SHA256 `23309b50c0a07a7321950407f0417bc501985ba5efe4f3b45472ad457582832f`, 432 files. CRC/hash + actual cold native Godot PASS.
- This is an **independently implemented Godot XML bridge**; actual PMD original engine or RPG Maker VX Tankentai SBS importing still **NOT TESTED**. User monster art still HUMAN VISUAL PENDING.

## Stronger fail-closed rules, mandatory for subsequent development
1. Doorfront is the **immediately adjacent 32px tile**, not a distant approach marker. Revalidate a two-step sequence in actual VX: player stands on front tile, cannot enter closed door.
2. Exact RGB 0-pixel recomposition and native collision TECH PASS do not imply Ground art suitability. Current F2 donor patch Ground explicitly remains ART FAIL.
3. A native XMLParser pass requires explicit source metadata dimensions, actual GPU frames changing and native log with zero errors and warnings; never call this official PMD runtime compatibility.
4. Do not regenerate standalone concepts when the user says 繼續. Advance remaining gated real source work, archive failure reasons and always provide ZIP+LOG+CURRENT_HANDOFF+Drive+GitHub+Linear.

## Next
- **F2_R3 G5**: produce truly continuous, high-detail source-authored Ground texture in the same supplied elf-village style, with no ghost areas, repeated donor squares, or roof cutouts; preserve independently sourced 9 PAR assets and exact origin, validate 1× art BEFORE formal release.
- **P3_R3 G3**: actual PMD-runtime player or isolated Tankentai SBS on original VX, verify each XML facing/timing/anchor with rock species visual review.
- Frozen F1R1 A04 unchanged.

## Central Handoff
`AI_ART_TOOLCHAIN_PILOT_20261025/CURRENT_HANDOFF_F2G4_P3G2_NATIVE_20261026.md` on connected Drive; both ZIPs include their own SOURCE, run CMD, QA and Handoff. All private derivative sprite files stay in private Drive, not public GitHub.
