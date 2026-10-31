# ASF A17 — single-keypose source-locked redraw / inpaint readiness (2026-10-31)

**STATE: ONE REAL REDRAW POSE / G7 ART FAIL / NO FOUR-FRAME ANIMATION / NO GAME IMPORT.**

## Why this experiment differs
A10-A16 repeatedly passed ASF/Godot pixel-parity but failed on believable redraw of shoulder/elbow/wrist/weapon. This round tested one genuine isolated redrawn fighting pose instead of another rig, assembly or infographic extraction. The generative output was a standalone high-resolution transparent PNG (1161×1355); a second attempt to obtain an image editing tool result returned an infographic and was rejected.

## True source & measured result
- A15 T1 original 96×112 RGBA, 38 opaque RGB palette colors. SHA256 of raw source PNG: 88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f.
- AI isolated pose was cropped to alpha>=128, reduced without stretching to 76×87 artwork, anchored on the original 96×112 canvas at foot y=94; opaque colors mapped to source 38-color palette in Lab space; alpha forced to 0 or 255.
- New pose uses 34 of the source colors. Against A15 input there are 3137 different RGBA pixels and 1050 changed pixels within the manually protected head/identity region. These are QA deltas, not an objective beauty score.
- **G7 FAIL**: visible hairstyle/face/body and outfit consistency drift from the A15 master. Do not call this a formally acceptable original-character sprite.

## Real new preflight for controlled editing
- Original input padded with pixel-exact crop from 96×112 to **128×128** (unmodified x16,y8 placement), suitable for square-canvas tools.
- Two separate masks: protected head (no editing), and editable sword/arm/shoulder ROI.
- First cut of masks overlapped by 287 pixels: REJECTED. Subtracting the protection region yields **0 mask overlap** with source-pixel identity preserved. The masks are guides; no real inpainting call has yet been executed.
- Package has 12 local files including raw generated image, clean native candidate, A15 source, source-pad and masks, visual comparison, source code, QA and handoff.
- **Exact private/local download ZIP:** A16_T1_CONTROLLED_ART_METHOD_TEST_20261031.zip (12 files, 657209 bytes, CRC PASS, SHA256 668740650885628612dd9435b316297cd143ee9bb1f559d0667e062398289618). NOT uploaded to Google Drive/GitHub, because it contains private sprite images.

## Compared routes (claims versus execution)
1. **ComfyUI-Rinsei**: Community repo claims Windows **RX 6700 XT gfx1031 12GB** workable with ROCm custom nightly/SD1.5/SDXL and Wan2.2. Directly relevant to target GPU; not installed or verified in this project. Do not change drivers or large model stack without compatibility and isolated environment test. https://github.com/eviscerations/comfyui-rinsei
2. **PixelLab Animate with Skeleton**: identity controls (fixed head, freeze/inpaint), but official documentation says Tier 1 is needed. Free Trial quota is exhausted. https://www.pixellab.ai/docs/tools/animate-with-skeleton
3. **AI-Sprite-Animation Unity**: pixel-exact source rig, explicitly weak for attack movements; same high-level bottleneck as A10-15, so not a priority for T1 keypose anatomy. https://github.com/JatCool/AI-Sprite-Animation
4. **Gemini sprite-animator**: requires another API and uses a sprite-sheet generation prompt; no demonstrated identity lock. https://github.com/Olafs-World/sprite-animator

## Next and stop-loss
- Test *only* inpainting with the 128x128 source, protected face and editable arm/weapon mask, if a suitable local engine is available; aim for a single truly redrawn keypose.
- G7 eye review first. If no identity-preserving results after **two materially different** draws, stop, use skilled pixel-art hand painting or reconsider target art complexity. Do not spend credits or retest ASF/Godot 22/22 pixel-parity.
- A15 baseline, A16 R3 editable asset, FS SEALED stay unchanged.

Artifacts were generated in ChatGPT local runtime, not on authorized Windows host (Remote Desktop access quota unavailable). No ComfyUI runtime tests or native Windows GPU actions were performed here.

Portable reproducibility: the bundled Python script references only sibling PNGs; extracted-to-temporary-folder offline replay exited 0, and independently reproduced 38-source-color palette and zero head/redraw mask overlap. No Windows GPU/art-generator call occurred.
