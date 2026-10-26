# P3_G8R1 — Free Toolchain B: Layered Shaded Basalt Keyframes (2026-10-26)

## Authority & scope
User rejected G7R1 because one boulder stayed the same flat color and composition looked unnatural. G7R1 is **ART FAIL**; do not re-use it as approved final art. Earlier G6R4R2 similarly FAIL for damaged body / petrified flower. The user's current active PMD work is 0002 and 0003 only; **PMD 0001 previously liked orange-gray G3R1 unchanged.** All F2 / Ground / PAR maps **PAUSED** by user.

## ACTUAL NEW SOURCE-DERIVED G8R1 RESULTS
- Built from the actual original `PMDCollab/SpriteCollab sprite/0002` and `sprite/0003` `Idle-Anim.png` / `Walk-Anim.png` in **the original 32×32 sheet cells**.
- Per species ONLY: original facing rows D0 front, D2 side, D4 back × source frames F0,F1 × original Idle and Walk = **12 modified cells**. 24 modified original cells overall, no full atlas / other action mass edit. Every other Idle / Walk cell untouched, other 10 original motion sheets byte-identical.
- 0002: 3 uneven pixel-round gray basalt boulders on back saddle with small dark-orange caldera; 0003: 5 boulders with fuller crater and controlled lava glow.
- **Five genuine color/lighting bands per boulder**: dark outline, shadow, middle tone, lit face and hot/neutral glint. Pixel and per-rock QA found >=3 pixel color shades per stone including measurable mid / lit pixels; all original selected poses, every direction, two frames. Front, side and back change directional lighting and frame changes small facets. No single 1-color boulder permitted.
- Every edited pose derives one dorsal root from its original **blue body pixel silhouette median** and body/pose bob, never the flower/leaf centroid. All stones follow this root between frames; no independently frozen part. Individual stone shade and position metadata verified per frame in `G8_QA.json`.
- **Original blue body-source opaque pixels erased = 0** in all 24 selected cells. Original bottom three foot alpha rows preserved and no newly opaque pixels on atlas cell borders. This measured result DOES NOT guarantee all human anatomy visually perfect; human art review remains pending.
- Underlayer original flower-material removal is constrained to upper head/back, protecting source cyan-body and adjacent outline; initial G8 candidate left isolated black petal flecks, archived as visual fail. G8R1 uses 8-connected component cleanup on only tiny detached underlayer debris outside body to eliminate them. Structural QA reports no isolated top fragments.
- **Original `AnimData.xml`, every `-Offsets.png`, `-Shadow.png` unchanged.** 14 XML motion names (12 actual atlases + 2 CopyOf) original grid retained. Full other action sheets untouched.

## Free editor tool work, with honest verification scope
Windows machine already has **Pixelorama v1.2.3** and **LibreSprite**, no paid Aseprite needed. Each G8R1 sample exported as a true **layered OpenRaster (.ora)** with separate editable layers: Source Body, Back Saddle, Lava Crater, EACH individual Stone and Protected Body Overlay. There are 12 editable ORA files per species (=24). Their PNG merged layer rendered contents independently validated pixel-equal to the actual altered source keyframes. OpenRaster file ZIP and layer XML QC PASS.
- **LibreSprite** imported a sample original-source edited PNG and saved a native `.ase` file, then roundtrip PNG first frame had **ZERO pixel changes**. CLI emitted a second PNG on export unexpectedly; do not claim multi-frame native LibreSprite playback passed.
- **Pixelorama v1.2.3** documents OpenRaster import (see https://pixelorama.org/user_manual/Import/), but its **Windows --headless CLI export failed** in this setup with Godot RendererDummy errors, no output. Thus Pixelorama native automated roundtrip **FAIL/PENDING**, though OpenRaster layer projects were built and structurally validated. The ORA files can be opened manually in Pixelorama for further onion-skin pixel editing. Do not lie about native Pixelorama PASS.
- Python Pillow+NumPy+SciPy QA is the reliable generator/alpha and shading constraint tool; dynamic physical light per facing. No requirement to buy subscriptions and no AI-generated mockups passed off as PMD assets.

## Native / cold gates
- Actual native Godot v4.7.2 original XMLParser / OpenGL GPU integration for **both** PMD source sets: animation frames vary, `P3_NATIVE_GODOT_XML_GPU_PASS`, zero ERROR/WARNING, source/original atlas cells preserved outside 24 samples. **Godot bridge TECH PASS only, original PMD game and VX Tankentai SBS NOT TESTED**.
- ZIP cold extracted in a clean directory. Every file SHA-256 rechecked; independent source alpha/color/sway/ORA parity test re-run PASS; both species freshly imported and GPU-rendered in Godot again PASS.
- Human Visual Art **PENDING** for G8R1 sample. Commercial fan source licensing/credit not verified. DO NOT expand full 682/698 frames until sample human review.

## Verified private Drive
- Full ZIP: https://drive.google.com/file/d/1euwOv5v6eNLmcR88uGlbG5DjOomwEURT/view?usp=drivesdk ; **2,028,000 bytes / 541 ZIP entries / SHA256 `52c6c219967c5d877a57198cde0e171c4fed1061db275d906a69255beff2cee3`**. Contains BOTH original complete sources, 24 edited keyframes within proper original Idle/Walk atlases, 24 OpenRaster editable multilayer project files, Godot source projects, preview GIF/PNGs, QA/CMD/Handoff, source code and logs. Drive SHA matches local.
- [0002 Idle original vs shaded](https://drive.google.com/file/d/19dc8fTNcXGmq3_0ONurFKbAcyIYDDuPz/view?usp=drivesdk) ; [0003 Idle original vs shaded](https://drive.google.com/file/d/1ZeckJbrRXkcrQgYMTMyRGx0EjK6FEJSU/view?usp=drivesdk)
- [0002 motion GIF](https://drive.google.com/file/d/1OfAvGMYnZ9kv2l2qunfSQzx9XIw1N03h/view?usp=drivesdk) ; [0003 motion GIF](https://drive.google.com/file/d/1-CT1dVwd-3aejclmGDT7CN-y2BmBKmue/view?usp=drivesdk)
- [Native, cold and color/ORA reports](https://drive.google.com/file/d/1Z4Jh_njRv0HF96GvzuvfxR-N0zmkrd1m/view?usp=drivesdk)
- [Current Handoff](https://drive.google.com/file/d/1Y--lPpKoPsOvADr_qeIX3LXqC4uVZAKc/view?usp=drivesdk)

## Next strictly gated milestone
- User human visual review: body, 3 vs 5 rock shapes, directional light, rocks visibly moving with frog, tiny stray petals. In Pixelorama manually open one of the included 24 `.ora` samples and use onion-skin editing if necessary. OpenRaster docs support import but batch headless failure must not be swept under rug.
- Only after art acceptance extend to the original remaining action cells with real native PMD/VX target proof separately. Continue ZIP, QA, Handoff Drive/GitHub/Linear sync; map work remains paused.
