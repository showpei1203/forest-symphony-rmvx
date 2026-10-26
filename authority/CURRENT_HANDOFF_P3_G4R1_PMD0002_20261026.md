# CURRENT_HANDOFF — PMD 0002 G4R1 volcanic stage2, maps suspended
2026-10-26, centralized latest authority.

## User direction
STOP all work on F2/F1 maps. Only PMD sprite transformation and evolutionary chain may advance. Do not touch Ground/PAR, map QA, FS other dialogs or sealed existing baselines. F1R1 A04 remains user accepted SEALED.

## Visual baseline and evolution intent
PMD 0001 latest P3_G3R1 orange-gray lava juvenile visual DIRECTION strongly liked and accepted by user. This is not full every-frame signoff nor PMD game/VX SBS compatibility certification.
Evolutions: 0001 little dark rock crust/fine magma crack → 0002 larger split rock plates/wider hot molten fissure → 0003 big ruptured crust with exposed molten heart, rock+fire.

## Current new genuine PMD0002 source development
G4R1 candidate, actual PMDCollab/SpriteCollab `sprite/0002` upstream: 37 relevant original assets, own `AnimData.xml` 14 named motions, 12 real action images and 682 original frame cells. 0002 cannot assume 0001's 34 motions/1123 cells.
- In each 682 original cells original plant leaves + flower replaced visually with two angular charcoal basalt plates and a noticeably wider orange magma center; body warmed to ash orange/gray using 0001 family style. True new alpha silhouette present in each cell. Every frame retains original atlas slot, action dimensions/count/direction rows, frame timings and lower foot anchor. Original `AnimData.xml`, `-Offsets.png`, `-Shadow.png` are binary identical to upstream. 
- G4 initial candidate was a bit beige (self-review not consistent enough with user-approved orange/gray), archived unchanged; new G4R1 warmed body tone. An earlier incorrect assumption of at least 60 upstream files failed, archived; source actually has 37. Never force 0001 structure onto 0002.
- Native Godot 4.7.2 XMLParser/OpenGL bridge loads original PMD 0002 XML and the derivative atlases, 12 actions/682 cells, 3 distinct GPU-rendered frames, logs ZERO ERROR/WARNING. Cold-unzipped ZIP source/per-cell QA and native Godot GPU rerun PASS. This DOES NOT mean original PMD game runtime or RGSS2 Tankentai SBS passed.
- Art review by user = PENDING. Fan asset attribution/commercial release rights not yet verified.

## Actual deliverables
Latest P3 G4R1 source/derivative/Godot/LOG/CMD/Handoff ZIP: https://drive.google.com/file/d/1PfvC7pNr6dASKSmHVkCUGoYO1h5J2XmK/view?usp=drivesdk
ZIP 583034 bytes, 176 files SHA256 309a19d3be249411e7ec9e2c3d546638a00660c7e34a76bf4c8ac5b373f46818.
0002 original/derivative all direction source preview: https://drive.google.com/file/d/1IzdSZ9MBhKB-WNpqkHWnbfT54hWWX4Ht/view?usp=drivesdk
Real PMD original 0001/derivative 0002 side-by-side: https://drive.google.com/file/d/1J9v9QoZI0TfiQ1_MeWAhNNEJUJUTjRnm/view?usp=drivesdk
Idle XML-timed comparison: https://drive.google.com/file/d/1G57Vl7MK9tjf_ZPT2rg8CU5lOkmDUimM/view?usp=drivesdk
Attack XML-timed comparison: https://drive.google.com/file/d/14cVtdYNJGW4bkqrAnxzu7D8QMiOUFnv4/view?usp=drivesdk

## Status gate
PMD0001 G3R1: STYLE DIRECTION USER APPROVED, XML/Godot TECH PASS, full art frame signoff/PMD original runtime/VX SBS PENDING.
PMD0002 G4R1: ALL SOURCE FRAMES 682/682 MAPPED, original XML untouched, 12 actions source/structural QA and cold native Godot GPU PASS, USER ART PENDING; PMD original runtime and VX SBS PENDING.
PMD0003: NOT STARTED; use own source/own XML, design stage3 exposed molten core after confirming stage2 direction.

## Do not resume map work
F2 G5R3 actor-scale florals Ground/PAR STOPPED, no new map files, current failures retained. F1R1 sealed and other parallel P1G unchanged.

## Next concrete task
Request/show user stage2 original source-derived comparison if helpful, gather stage2 visual feedback, then inspect authentic PMD 0003 sprite/AnimData.xml and design structurally preserving third-stage rock/cracked molten-core morphology. If original loader support is found, test native PMD/VX with true offsets and timing separately. Every new task ZIP/CMD/LOG/Handoff + Drive/GitHub/Linear, no image generation substitute for existing source sheet.
