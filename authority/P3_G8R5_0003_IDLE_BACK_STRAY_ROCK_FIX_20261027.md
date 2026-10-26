# P3_G8R5 — PMD 0003 Idle Back Stray Rock Source Fix (2026-10-27)

## User-approved scope
User likes G8R4 lava-frog overall. One precise defect: PMD 0003 `Idle` back-facing idle sprite has stray detached stones at upper right and left exterior. User requests this correction only. Do not restyle it or generate a concept contact sheet. Freeze 0001 orange-gray accepted juvenile, 0002, all map work and all unrelated motions.

## Root-cause proof
Forensic inspection of the real PMD 0003 original 32x32 frames and all 12 OpenRaster layers identified:
- Direction 4 `Idle`, frame1 right upper `x25..26,y8..11`: original `Recolored_Original_Body` ornament outline leaked outside the body, including two pixels misclassified by old blue-body protection. Original `Protected_Original_Frog_Body` layer retained these, then prior G8R4 `G8R4_Visible_Crater_And_Connected_Outline_Repair` added a bridge/spur. Result: visible detached rock at upper right.
- Direction 4 `Idle` frame1 left exterior `x4..6,y13..17`: extraneous old floral underpainting from original body layer, not a valid rock from `Round_Basalt_5`.
- Back frame0 checked at actual 32x32 and did **not** have the diagnosed extraneous pieces. It remains byte-for-byte frame-pixel identical. This avoids unnecessary edits.

## Actual surgical modification
Built `P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX` in an isolated branch of project toolchain:
- Authentic 0003 `Idle-Anim.png`, 128x256 original 32x32 frame grid; **direction4 frame1 ONLY** changed, **18 RGBA pixel positions**. Every other original 31 Idle cell, all Walk and 10 other motion atlas files, original `AnimData.xml`, `-Offsets.png`, `-Shadow.png` are unchanged. 0001 and 0002 unchanged.
- In the genuine editable OpenRaster, cleared tiny stale non-anatomical original and assistant-added repair pixels from `Recolored_Original_Body`, `Protected_Original_Frog_Body`, `Clean_Floral_Border_Mineral_Retone`, and `G8R4_Visible_Crater_And_Connected_Outline_Repair`, in frame1 source-verified left/right region only.
- **All five `Round_Basalt_*` rocks**, `Visible_Magma_Rim_Flame`, `Magma_Crater`, `Mount_Saddle` original art layers are byte-for-byte visually/pixel unchanged. Main frog torso `x8..23,y>=15` and original foot bottom 4 pixel rows unchanged. Frame0 recomposited exact equal.
- `Idle_back_F0.ora` and `Idle_back_F1.ora` remain fully editable, internal `mergedimage.png` exactly equals 32x32 new source-sheet crops. Comparing before/after at actual x6 nearest-neighbor reveals removed right upper and left stray rocks.

## Gates and honest limitations
- Independently rebuilt QA script checks exact **18** modified actual source-cell pixels and no changes to any other part; XML, offsets, shadows and 10 other motion atlases unchanged. Fixed right-upper region empty, leftover underlayers removed from left; source frog core and feet exact.
- Godot v4.7.2 original PMD XMLParser/OpenGL GPU native bridge reimport/render **PASS, zero engine errors/warnings**. Release ZIP extracted cold to new folder; all file SHA, independent source/ORA QA and cold native GPU replay **PASS**. This does not certify the original PMD game runtime or RPG Maker VX Tankentai SBS, both **NOT TESTED**.
- Human Art visual approval for this exact local repair **PENDING**; user previously liked G8R4 generally, do not retroactively assume approval of G8R5. Fan-source licensing/commercial usage unresolved.
- F2 maps PAUSED, do not restart.

## Verified delivery
- [Actual PMD source ZIP with original/G8R4/G8R5 action sheets, original XML and shadow/offsets, corrected ORA and 32x32 PNG, GIF, QA, cold log, Godot native bridge and Handoff](https://drive.google.com/file/d/1y8SHCSJ3drPgLlFXsbw41VRvdly7QQ9D/view?usp=drivesdk)
- ZIP: **1,380,100 bytes / 305 files / SHA256 `850f3e9def34ba509a77b6e17728d173c6f032e1d741848806031263dcabd79e`**, local/cloud mounted SHA exact match.
- [G8R4 vs G8R5 exact native sprite F0/F1 before-after x6](https://drive.google.com/file/d/1tijXMPOVR-ZkYRSlwN_yHqqSM5j2MuHB/view?usp=drivesdk)
- [Corrected actual Idle Back F0/F1 GIF](https://drive.google.com/file/d/1QPbyfyNBfcgvxEgEJ9KRBRZ3uVClTg0l/view?usp=drivesdk)
- [QA report](https://drive.google.com/file/d/1IwRzovgdyNeCo-DJpdhOH9MqU4osk8jW/view?usp=drivesdk), [Drive current handoff](https://drive.google.com/file/d/18Q3uUwUx6KSEBDtjfmKfibiG8xYYu39L/view?usp=drivesdk).

## Next
Only consider further per-frame corrections upon real human visual feedback; do not expand to full 698 frame or change other motions without express permission. All iterations include source, quick QA, LOG, latest Handoff, Drive/GitHub/Linear sync.
