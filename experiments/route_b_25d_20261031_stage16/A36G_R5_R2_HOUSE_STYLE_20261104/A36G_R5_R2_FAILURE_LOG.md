# A36G R5 R2 | Art failure prevention log

## Mistake identified
R4 had left house PixelLab detailed olive/moss-gold thatched angled roof, warm wooden framework and slate/stone plinth, but old right house used a symmetric flat bright-green triangle roof, weak texture, different camera/palette.

## Failed R5 R1
- First attempted to generate with complete LEFT house as style reference and 198x236 tiny new canvas.
- Model copied the left's attached side workshop as well as the materials; building was clipped at left/right image boundaries.
- Explicit ART FAIL. Stored as rejected source only, never imported into actual R5 ground/par engine. Avoid using whole reference building for style transfer when architecture must differ.

## R5 R2 improvement
- Crop a 135x190 *material-focused* style sample of left artwork. Pair with old right source *layout-only* reference and strong one-gable/single-volume constraint.
- Generate on 256x272 canvas with transparent margins; resulting native RGBA bbox (21,23,188,220), no crop.
- Keep original right house door foot world (869,596), adjust object origin (743,376) and physical blocked footprint [778,535,921,588]. No fake concept composite.
- PixelLab R1 and R2 original output locks guarantee no paid request replays.
- Actual independent 1280x928 Ground and PAR, Map050 VX engine and Godot GPU all rebuilt and smoke-tested.
- A36F, R3B, R4 files have not been modified.
- Actor behind new smaller right roof at old fixed case 06 partly visible outside roof silhouette (348 changed pixels); not necessarily error, needs deliberate occlusion signoff.
- Art seal pending user visual review. Formal Seal NO.
