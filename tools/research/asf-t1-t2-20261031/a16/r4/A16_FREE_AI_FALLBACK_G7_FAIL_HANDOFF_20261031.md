# FS A16 free AI fallback: T1 four poses (G7 FAIL)
Date: 2026-10-31
Status: **ART G7 FAIL / NOT SEALED**. No A15/FS source modified. No PixelLab API credits or Remote Desktop Commander usage needed.

## Completed deliverable
Real source: original 96×112 A15 T1 attack_02 RGBA, SHA256 88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f.
A free image-generation attempt did not obey the asset requirement: it produced an infographic with four swordsman poses, a dark background, and fabricated certification ticks. We extracted four images programmatically, estimated alpha masks, resized to 96×112 RGBA, and constrained RGB to the original A15 source's 38-color palette. Produced four actual individual transparent PNGs, 384×112 sprite sheet and GIF, with warnings.

R0 generated poster art was visually different from source and output format wrong.
Manual salvage extraction **does not constitute a new valid sprite generator**. Matte fringe/halo around hair and inconsistent head and sword shapes. First candidate frame differs from A15 original in 3952/10752 RGBA pixel coordinates. 38 source colors; resulting four frames use 32,33,31,31 colors respectively. All alpha are 0 or 255.
Four poses: idle, wind-up, slash, follow through. Pose meaning is visibly distinct, but character identity is not anchored to A15.

## Exact private package (ChatGPT session)
Filename: A16_T1_FREE_AI_FALLBACK_ART_FAIL_20261031.zip
10 entries; 103172 bytes; CRC PASS; SHA256 7057c5a7f661d83f6ce2170b9fa0cd3b648b3cfdbe215b0a001a9f03500e718a.
Includes original private A15 source, four transparent candidate PNGs, contact sheet, sprite sheet, GIF, QA.json, CURRENT_HANDOFF.md. It was **not** uploaded to GitHub or Drive; only this textual handoff is uploaded.

## Decision / stop-loss
No further poster-segmentation micro-optimization or pseudo-art programmatic animation loops. Use these poses *only as a visual movement guide* against A16 R3 editable 8-frame LibreSprite .ase files. Actual trusted next step is artist-led pose corrections (fist, elbow, shoulder and sword weight) on unmodified A15 head/torso layers. Only visual G7-approved keyposes earn inbetween animation and ASF/Godot/VX engineering work. PixelLab free quota is depleted, so avoid extra charges absent a proof of art fit.
