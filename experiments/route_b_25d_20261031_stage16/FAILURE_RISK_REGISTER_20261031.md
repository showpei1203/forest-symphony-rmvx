# Stage 16 A01 - Failure/Risk Register
**Status:** A01 SOURCE PASS, ART PENDING, VX NOT RUN, Formal Seal = NO.

| Risk / previous regression | Gate / preventive action |
| --- | --- |
| Stage 15: AI generated images were **infographics with fabricated PASS scores and URLs**, not source art. | Require 8-byte PNG magic, source dimensions/mode, SHA256, standalone grass/path/flowers image with no graphic legend, cards, text, or fake links. |
| Stage 11-15: endless donor patch quilting was mistaken for new artwork. | Record independent image-generation provenance. Raw Stage16 source is new; no Stage12 donor pixels. Preserve raw image file unchanged. |
| Stage 15: near-perfect Godot technical tests did not prove ground3 fidelity. | Score independent ART_GROUND3_FIDELITY by manual visual signoff; no numeric fabricated similarity claims. |
| ground3.png is composite art with trees, buildings and cliffs. | Copy visual characteristics, **not** foreground objects to pure Ground. Stage16 ground-only content: grass/ground flowers/paths. |
| Source generated at 1474x1067 instead of native 544x576. | Only coordinate hard crop, with no resizing; prove pixel exactness using ImageChops. Preserve full untouched source for provenance. |
| Generated detailed texture may look blurry, too photo-like, or illegible at true 1x and 32px unit. | Manual full-size crop review BEFORE any PAR/Collision integration. Fail if repeated zoom/smoothing needed. |
| Local AMD RX 6700 XT diffusion setup unverified. | Do not claim ComfyUI/Krita/InvokeAI installed or tested. Source PNG came from model generation tool, not user's GPU. |
| Model seed and editable design layers unavailable. | Record generation ID, original bytes, SHA. Do not claim perfect regeneration from seed or layer-editable output. |
| Actual VX runtime untested. | Stage 16 A01 NOT SEALED. Real native RPG Maker VX Game.exe required in later gate. |
| Raw private images may carry undeclared reuse terms. | Keep all raw assets out of public GitHub. Cloud Drive report and public GitHub file contain only text/sha. |

**Next:** compare original and user-reviewed candidate at 1:1; run conditional image generation/inpainting tests if art fails. Do NOT rerun more Stage15 patch quilting without a new hypothesis.
