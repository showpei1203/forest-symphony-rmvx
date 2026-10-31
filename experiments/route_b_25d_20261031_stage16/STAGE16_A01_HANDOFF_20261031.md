# Forest Symphony Route B — Stage 16 A01 / Independent Original Ground PNG

Date: 2026-10-31. **Experimental candidate; NOT a Formal Seal.**

## Stage 15 preserved, with honest status
Stage 15 cold-extract 72 files / SHA256 12 of 12 consistent; six Godot native vs independent-compositor comparisons had 0 differences; source art Ground3 fidelity FAIL; RPG Maker VX native Game.exe NOT RUN; Formal Seal NO.
No Stage 15 source assets, GitHub baseline, production VX maps, or masks have been modified by Stage 16.

## New Stage 16 capability tested
Generated **actual standalone AI-native raster PNG**, not an infographic, test dashboard or re-quilted Stage 12 donor image. The native new original RGB PNG is 1474x1067. A no-resampling strict crop (448,224)-(992,800) produced 544x576; from that a 544x416 scene ROI (0,80)-(544,496) was cropped. All original pixels in derived files remain 1:1 identical to the corresponding original source coordinates.

Original source SHA256: `a6924cdfc19ec240d42217b276fd22b198638b8439dfc8df3deaf6bd5c2b3548`.
AI generation id: `c64f523b-bd97-4978-8762-3c95d857254b`, seed unavailable.
Ground3 reference size: 1280x928; SHA256: `DDC1F21E1D23DCB8258A20BAA2ACB106D1C0E56683A4DC280FAEDC23BCD47A13`.
Private PNGs and original assets are NOT committed to this public repository.

## Independent gates
| Gate | Status |
| --- | --- |
| Actual independent RGB PNG, no fake pass panel | PASS |
| New original source; does not copy Stage 12 donor | PASS |
| Genuine complete ground-only visual (grass, dirt, wildflowers) | visual check PASS |
| PNG signature / dimensions / cryptographic hash | PASS, local QA artifacts |
| Crop vs original pixel-exact comparison | PASS |
| Ground3 style match | PENDING USER VISUAL APPROVAL |
| Pixel-crisp in-game art approval | NOT YET APPROVED |
| Godot source image GPU test | NOT RUN |
| VX Game.exe native test | NOT RUN |
| PAR/collision source computation | NOT RUN by design |
| Formal Seal | NO |

## Tool research (feature verification, not actual local engine runs)
- **ComfyUI**: reproducible node workflow and real PNG SaveImage output with optional embedded workflow metadata. Official docs: https://github.com/Comfy-Org/docs/blob/main/built-in-nodes/SaveImage.mdx
- **Krita AI Diffusion**: selection, region and style-reference editing, with ComfyUI backend: https://github.com/Acly/Krita-AI-Diffusion
- **InvokeAI**: visual canvas with source edits, inpainting and file output: https://github.com/invoke-ai/InvokeAI
- **PixelLab**: best deferred to sprites; free tier currently excludes map tools: https://www.pixellab.ai/

## Machine discovery and boundaries
Authorized Windows 10 machine has Python 3.11 + Pillow; torch/diffusers/onnxruntime absent in system Python. Existing portable art tools include Pixelorama, LibreSprite, Tiled, and Laigter. GPU AMD Radeon RX 6700 XT 12GB. No operational local ComfyUI/Krita installation was verified. This is **NOT** a local diffusion engine benchmark.

## Next gate
1. User reviews standalone 544x416 candidate at exact 1:1 with original 1280x928 ground3 reference (visual DNA only, do not cut composite tall objects into ground).
2. If accepted, transfer private source PNG to authorized project input, execute native Godot GPU import and 0-difference pixel check. Do not compile PAR yet.
3. Independent in-engine RPG Maker VX Game.exe validation is required before any formal seal.
4. Maintain two disjoint scores: `SOURCE_PNG_TECHNICAL` and `ART_FIDELITY_GROUND3`.

**Current state: STAGE16_A01_SOURCE_PASS, ART_PENDING, VX_NOT_RUN, FORMAL_SEAL_NO.**
