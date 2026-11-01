# CURRENT_HANDOFF — Forest Symphony Stage16 A33, 2026-11-01

**Latest active: A32B foliage ART USER APPROVED. A33 REAL Ground3 reference-source Ground R5 candidate built and verified in native VX/Godot. A33 engineering PASS; A33 ART REVIEW PENDING; Formal Seal NO.**

## Read in order
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md`
3. `authority/FS_NATIVE_VX_DYNAMIC_PAR_OCCLUSION_PASSAGE_V1_20261101.md`
4. `authority/FS_PAR_LEAF_STRUCTURE_VISUAL_QA_V1_20261101.md`
5. NEW `authority/FS_GROUND3_TRUE_REFERENCE_AND_MATERIAL_EDGE_RULES_V1_20261101.md`
6. NEW `experiments/route_b_25d_20261031_stage16/STAGE16_A33_GROUND3_SOURCE_FIRST_REAL_VX_GODOT_HANDOFF_20261101.md`
7. NEW `experiments/route_b_25d_20261031_stage16/STAGE16_A33_GROUND_RETEXTURE_FAILURE_REGISTER_20261101.md`
8. `experiments/route_b_25d_20261031_stage16/CURRENT_HANDOFF_STAGE16_A32B_20261101.md`; Drive verified A32B original sprites and materials.

## Critical correction
True art source `Graphics/Parallaxes/ground3.png` SHA256 ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13, 1280×928; **not** `Overlays/ground3.png`, which is a dark shadow/light resource. Preserve this lesson permanently.

## Current sources and files
- Original PixelLab A27 544×416 Ground SHA `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce` locked in A32B baseline.
- Accepted A32B `Par50.png` SHA `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb` and 12 independent approved PAR objects, Map050 RGSS scripts collision E-layer unchanged.
- A33 R5 new Ground 544×416 SHA `ec06a5c01d292beba7dbb042be844dc95b59e5e127f293767d7ea86c11d287c0`. Uses real Ground3 grass64px and sand48px native pixel materials in mirrored seamless arrangement, road RGB semantic+ModeFilter 1,568 pixels repaired, 1,885 original bright flora coordinates and nearby small dark plant strokes preserved. NOT another AI PixelLab regeneration.
- Local analysis `E:\FS_STAGE16_A33_GROUND_VISUAL_REWORK_20261101`; VX isolate `E:\FS_STAGE16_A33_GROUND_R5_NATIVE_VX_20261101`; cold copy `E:\FS_STAGE16_A33_GROUND_R5_VX_COLD_20261101`; Godot actual 8-frame project under analysis/GODOT_A33_GROUND_R5_ISOLATED.

## Actual QA
- RPG Maker VX Game.exe: 12 placement cases, 24 native HWND screenshot frames, 0 modal; full cover 0/627, west partial 351/627, east partial 357/627, front visible 627/627; real blocked(2,4)->(2,4) and road(8,6)->(9,6).
- Independent VX cold SHA 3395/3395 PASS, actual cold runtime frame and Map50 PASS, 0 modal.
- Godot 4.7.2 actual OpenGL GPU 8/8 cases output PASS; no-actor reference composite differs 2,971 coordinates by max RGB single-channel1, no pixel >1. **Not exact 0; RGB tolerance 1.**
- Rejected R1-R3 initial quilt checkerboard grid; R4/R6 alternatives not chosen. Further material/detail fidelity art test required.

## Next actions
Review native A33 vs A32B and real Ground3 style at 1x/2x (candidate still ART PENDING). Address texture periodicity, meadow vegetation sparseness and sand-grass border if rejected. Keep approved A32B PAR immutable. Full 1280×928 village Ground3-equivalent and true SHADOW/LIGHT engine integration are later work only after A33 benchmark is accepted. Formal Seal NO.


## Verified A33 private Drive delivery (2026-11-01, Drive metadata readback)
- **Native VX before/after A32B vs A33 R5**, with four material closeup pairs, 544px wide: https://drive.google.com/file/d/1xwPnopLWYSnNL8V-rounh-AHCuQWPpzc/view
- **Actual new Ground R5**, opaque 544×416 native PNG (new source SHA `ec06a5c01d292beba7dbb042be844dc95b59e5e127f293767d7ea86c11d287c0`): https://drive.google.com/file/d/1z7jfhzecS_UvVCuRnDDj5ANzNI7g9a5b/view
- **Original Ground vs seamless R4/R5/R6**, composited over exact A32B approved PAR: https://drive.google.com/file/d/1l_5hXmkKKop6S38sIyH7sVgiQSpvWeAO/view
- **Material road/grass pixel edge zooms**: https://drive.google.com/file/d/1egH9YusS0lTlBx5fLiXFE_4QKBv3RwtQ/view
- **Rejected R1/R2/R3 grid-error comparison**, do not promote: https://drive.google.com/file/d/1WLleb9Ae5CVVv8LEVhua7L-gDdRRnMjs/view
- **Full A33 private ZIP**, 105 members, 20,551,494 bytes; local ZIP CRC, each SHA256 and independent re-extraction PASS; Drive metadata title/size readback, not remote download SHA validation: https://drive.google.com/file/d/1MhJQfl7AIaevSwhRyxonpSYrppElPWWI/view
- A33 real VX/Godot QA: https://drive.google.com/file/d/1yI5_5mPgG695P7sPJiPZ2bz7a_UOXBwf/view
- Godot RX6700XT native pixel round-off QA: https://drive.google.com/file/d/17PNYpDOrUrrAAnAI5uy62A55xNVJa_bJ/view
- VX fresh 3395-file cold QA: https://drive.google.com/file/d/1xpuiy5EvE_56Jkom77_kKLI4n2aV9dZK/view
- New permanent true Ground3 source rules: https://drive.google.com/file/d/1yapdD2Tsi9TIIx45QF73CXu-VIkmvDhb/view
- A33 failure register: https://drive.google.com/file/d/1vjsgnxqcTUDHyC4StONAtQYK-k2dhQ_u/view
- Detailed A33 Handoff: https://drive.google.com/file/d/11PXNXpkAUASzJI4X1S7-rz2XMP8XYmu0/view
- Latest A33 CURRENT_HANDOFF: https://drive.google.com/file/d/1TlZO05p4N5rKHaZ3eOExu7EfnadYCtCD/view
- A33 folder: https://drive.google.com/drive/folders/15ev-Hx6yxtgSeVCuZo8NgLI5IU2Kufap

**A33 native engineering PASS / Ground art review pending / Formal Seal NO.** Do not promote the isolated Map50 test app to sealed production.
