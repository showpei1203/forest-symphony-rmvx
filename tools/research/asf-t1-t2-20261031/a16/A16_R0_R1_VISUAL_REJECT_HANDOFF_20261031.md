# A16 keypose art experiment R0/R1, 2026-10-31
STATUS: ART FAIL / G7 NOT SEALED. DO NOT use A16 images as final Forest Symphony sprites.

Source: A15_FINAL_PRIVATE_20261031.zip (636 files; 2,943,655 bytes; SHA256 ebe074d87cc242bbeab5d4e3061a5db0333a6db2bff2abac6c60f870aa5956b5).
Original local A15 sources untouched. A15 ASF/Godot pass (22/22 GPU pixel parity) does NOT pass new A16 art.

Workspace Windows: E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_KEYPOSE_REDRAW
R0 ZIP SHA256 e73c377358bda818e71e58a82b31700ecfc2db8589535d8f42c411884
R1 ZIP SHA256 068f4ac709a338215084ada4715d2926c08add7032b0f1f2320c1fe399c4449c
R1 contains 4 genuine new RGBA PNG edits, Python generator, 1x/3x/6x side-by-side images, QA JSON, handoff.

T1 human: attack_02 draw and attack_05 strike: artist-authored elbow bend, cuff, fingers and sword outline. R1 diff vs A15: 382 / 1675 pixels. T1 attack_05 protected face ROI differs in 551 pixels due fallback to a different reference frame; this is a source identity failure. R1 NOT PASS.
T2 moss-antler: attack_03 flight and attack_05 landing: pixel-level four bent leg contours and smaller hoof silhouettes. R1 diff vs A15: 125 / 240 pixels. Protected head/antler upper ROI unchanged in both. Visual: kneecaps too narrow, ankle/torso seam disconnected, hooves and original body palette mismatched, R1 NOT PASS.
R0 failure: sword shaft weak and quadruped feet excessively large; R1 reduces proportions but still leaves stiff/broken anatomy.

The core bottleneck is frame-specific art direction, not more movement of copied masks. Do not optimize line-drawing algorithms or report an ASF technical success as an aesthetic improvement. Next experiment should use direct raster-paint/AI-inpainting/art editing of joint-specific poses, manually audit at 1x and 3x, only then expand 8-frame animations and run ASF.

Acceptance gate for FOUR keyposes: distinct believable silhouette and weight transfer, clear shoulder/elbow/wrist or hip/knee/ankle chain, hands holding sword without duplicate hilt, no eye/hair/antler pixel identity drift, no false torso duplicates, no pixel blurs, user visual signoff. G5/G6/G8 for A16 NOT RUN. No complete private binary ZIP uploaded to GitHub or Drive.
