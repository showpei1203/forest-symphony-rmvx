# Forest Symphony Stage 16 A06 — Material-specific reference controlled test
Date: 2026-10-31. **CPU IMAGE-CONDITIONED PNG PASS; road mask pixel isolation PASS; Ground3 ART FAIL; Godot/VX NOT RUN; Formal Seal NO.**

## Preserved baseline
Stage15 remains engineering PASS / ART FAIL / VX not run / Formal Seal NO; A04 proved genuine original Ground3 reference-conditioned SD1.5+IPAdapter CPU inference; A05 proved exact two-pass road/grass zone isolation, but native game visual fidelity FAIL. A06 does not modify any formally sealed Forest Symphony project assets or A04/A05 experiment sources.

## New experiment hypothesis and reference
A05 R2 mixed grass/sand reference sometimes biased sand road green; A05 R3 removing reference made it worse. A06 tests a grass-free, sand-dominant reference to determine whether reference content alone can improve road material within same spatial workflow.
Ground3 source composite SHA256 ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13, RGB 1280x928. Searched and visually audited 12 original 64x64 samples and 48/64/80-pixel crop candidates. Selected (1032,321)-(1080,369), RGB 48x48, sand-like pixel fraction 0.894965 using R>1.04G and G>1.12B. Reference-only PNG SHA256 ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb. Reference is original user-authored pixels, NOT generated Ground. Includes a small non-sand color fraction, not perfectly 'pure' in semantic sense.

## Real controlled image generation (one new treatment)
ComfyUI v0.3.40 CPU FP32 on isolated Windows10 computer, Stable Diffusion 1.5 original checkpoint and source-verified CLIP Vision ViT-H + IPAdapter Plus SD1.5. Loaded A05 R2 road-image-inpainting Comfy workflow. Changed ONLY model node 8 LoadImage from original mixed 128x128 Ground3 style reference to new sand-dominant 48x48 source. Other two JSON changes were filename prefixes for separate output files. Input A05 first-pass grass result unchanged; original road mask unchanged; same SD1.5 model, positive/negative prompt, seed 160406, 14 steps Euler/normal, CFG6.0, denoise1.0, IPAdapterAdvanced weight 0.65 style transfer.
Expected 384x384; one real ComfyUI queue completed. Raw generated file A06_SAND_REF_ROAD_RAW_00001_.png SHA256 cc637772a5cb356f6fa3c3c4ba18f9223ac0a4d48570b91181d999faf6cf0a7a. Native composited model output A06_SAND_REF_ROAD_FINAL_00001_.png SHA256 e41d90071cf508c8d06dd7e430d62fd3d7d43b97720aa35ec6f37fe0d52f53c1. Exact pixel-identical decoded/re-encoded RGB copy for portable visual QA A06_SAND_SPECIFIC_REFERENCE_FINAL_384.png SHA256 422cb8a3675be3233358697560b07bba5762ad3525aa94a4e61266719b70e6b7. The original model PNG, not solely the copy, is included in private archive.

## Objective zone isolation
Road mask source SHA256 eed1ce659987b37ef074483fad3dd7fdfa17107e49b609ecce6afd83ca2b973e; 28,818 of 147,456 pixels = 19.5435%. R6 from first-pass base: all 28,818 road pixels regenerated; **zero pixels outside road changed** (118,638 preserved). This is a valid engineering PASS, NOT material or visual PASS.

## Comparison under same color heuristic, NOT an artwork-quality score
A05 R2 mixed Ground3 reference: road sand-like fraction 0.301131; green-like 0.638212; mean road RGB (155.70, 200.99, 26.09).
A05 R3 NO IPAdapter reference: sand-like 0.193074; green-like 0.774655; mean road RGB (138.24, 184.16, 33.46).
A06 sand-dominant Ground3 48px input: sand-like 0.356583; green-like 0.566972; mean road RGB (163.13, 188.69, 34.29).
Improvement A06 over R2 in sand-like proxy +0.055452 (5.55 percentage points), green-like -0.07124. BUT the independent native 1x and zoomed 32px visual output shows crooked reddish vein artifacts, green splashes and painterly smudged patches. Source Ground3 reference is small, dense, multicolor sand detail. New art remains visually below target; **ART FAIL**, not a valid Ground output. Reference content AND crop dimensions changed (128px to 48px), so do not overclaim isolated causal explanation of improvement.

## Technical decision
Exact road mask generation and selective inpainting are mature. Style/mixed/source reference cannot force semantic sand identity with generic SD1.5; do not repeat the same IPAdapter-weight / prompt random-search experiments, and do not switch to Stage12 donor patch quilting. A07 direction: semantic-conditioned generation and checkpoint fitness testing. Official ControlNet 1.1 seg is trained on COCO/ADE20K semantic category colors; an arbitrary black/white road mask is NOT compatible semantic annotation. Audit ADE20K/COCO palette and actual material class support BEFORE downloading 1.45GB ControlNet segmentation weights (official optional checkpoint SHA256 bad6d753886c0edc978e79dfb06083737ab1bd9702e5b7c0f81b1e16a5ed12cc). If no suitable grass/sand classes, test qualified inpaint model or learned domain adaptation rather than claiming controlnet success.
Official source documentation: https://github.com/lllyasviel/ControlNet-v1-1-nightly and model https://huggingface.co/lllyasviel/ControlNet-v1-1/blob/main/control_v11p_sd15_seg.pth

## Exit gates
Authentic original source and hashes PASS; actual reference-swapped SD1.5 CLIP IPAdapter output PNG PASS; pixel-exact masked isolation PASS; A05/R2 vs A06 controlled comparison PASS; Ground3 artistic fidelity FAIL; target native 544x416 original ground map NOT RUN; Godot native GPU NOT RUN; RPG Maker VX real Game.exe NOT RUN; PAR/collision NOT RUN; Formal Seal NO.

## Private file security
Keep full Ground3 composite and 4.76GB model checkpoints on authorized local computer, never commit them to public GitHub. Private A06 ZIP includes only extracted 48px sand reference and limited 128px A04 input, real new PNGs, masks, test code, workflows, originals' SHA evidence and QA reports. Original production files untouched.
