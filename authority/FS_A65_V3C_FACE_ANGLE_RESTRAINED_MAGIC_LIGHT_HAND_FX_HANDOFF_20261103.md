# FS A65-V3C | FACE ANGLE + RESTRAINED MAGIC LIGHT + HAND-ALIGNED FX (2026-11-03)

## Authority and non-destructive status
- Source: A65-V3B **actual PixelLab** three-frame transparent 48x48 actor, job a0046fcd-01f9-4222-9694-710db3e6ac99.
- A62 approved frame, A63, A64, A65-V3B, and all 3 original PixelLab PNG files remain **unchanged**. V3C is an **offline retouched derivative**; **NO new PixelLab/API request** and no paid credits.
- Frame sequence: 0/1/2/1; 200/205/195/205 ms; distinct actor body motion from V3B retained.
- STATUS: **format and layer TECHNICAL PASS; ART PENDING; NATIVE VX NOT TESTED**. Never report user art PASS or native integration PASS based on these metrics.

## Exact implementation
1. F2 camera-angle repair: copy ONLY F0 right face/hair silhouette pixels in x=28..38, y=19..24 into the F2 derivative, mitigating the side-profile black hair/eye smear. 19 body pixels differ after face and boot correction together. Face not newly generated.
2. Fixed F2 boots at x=10..38, y=38..42 against F0 anchors. F0 and F1 PixelLab body pixels unchanged. Upper-body original V3B casting changes retained.
3. Recalculate quantized lighting as separate editable lightmaps with lower warm additive contribution near screen-left casting hand (source x=15,y=30), and independent softer far-side F1 shadow. V3B lit counts 221/510/1, V3C updated lighting/shadow altered pixels 117/364/16. These counts measure pixel changes, not quality.
4. Moved original V3B fire pixels in F0/F1 by (-2,+4), from F0 bbox [16,25,19,28] to [14,29,17,32] and F1 bbox [14,21,22,30] to [12,25,20,34]. F2 FX remains empty, source rule respected.
5. Preserved source PNGs, derived body PNG, per-frame light maps, FX PNG, composited sheets, synchronized 8x GIF, source-reconstruction Python, QA JSON and SHA256 manifest.

## Delivered and verified
- Drive package: https://drive.google.com/file/d/1YW_CIcauD-OARjJ-Y3utwvpguK6g6Jos/view
- ZIP name: FS_A65_V3C_FACE_LIGHT_FX_RETOUCH_20261103.zip
- ZIP SHA256: 648c7574a69fa603f3c3d1e05ed03b1a59a51f6e8f61b8b737fe83c47483ebef
- ZIP size: 140446 bytes; 31 files (30 in internal SHA manifest + the manifest), 0 ZIP errors, 0 manifest digest mismatches.
- Important preview paths in archive:
  - A65_V3C_MAGIC_SKILL_USE_8X.gif
  - A65_V3C_OLD_VS_RETOUCHED_VS_FINAL_SYNC.gif
  - A65_V3C_3FRAME_X_4LAYER_QA_CONTACT.png
  - A65_V3C_COMPOSITE_144x48.png
  - A65_V3C_SEPARATE_LIGHTMAP_144x48.png
  - A65_V3C_SEPARATE_HAND_FX_144x48.png
  - A65_V3C_SOURCE_V3B_RAW_PRESERVED_144x48.png
  - A65_V3C_RETOUCHED_BODY_144x48.png
  - A65_V3C_QA.json
  - build_a65_v3c.py
- V3B input Handoff: authority/FS_A65_V3B_REAL_PIXEL_LAB_FULLBODY_DYNAMIC_MAGIC_LIGHT_HANDOFF_20261103.md

## Open visual QA and next stage
- Review at native 1x and 8x: F2 face 45-degree southeast coherence, left arm joint readability, FX visibly rooted in the casting hand, warm exposure without gold-white hair.
- V3C is **not** a new full-body animation generation. A65-V4 if needed must work from A57 original 18-bone rig and keep three real body poses, fixed boots, no camera drift.
- Do not call face patch a full motion/anatomy correction. Do not use a decorative concept illustration as a game sprite source.
- Only after user approves visual art: import into native RMVX Tankentai battle system, then measure frame transitions/occlusion and take in-engine screenshots. Failing gates must stay FAIL/PENDING.

## Failure prevention
- Strong yellow hair = lighting power too high; stay source-material additive and keep source raw.
- F2 profile drift = face orientation inconsistency; compare head landmarks against approved F0 before generation/render.
- FX hovering at shoulder = wrong emission anchor; derive active hand coordinates each frame, avoid blindly reusing shoulder center.
- Foot slide = non-anchored boots; test y38..42 anchor region bytewise.
