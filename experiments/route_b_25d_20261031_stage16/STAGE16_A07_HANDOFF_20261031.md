# Forest Symphony — Stage16 A07 ControlNet semantic ground material: Formal Experimental Handoff
Date 2026-10-31 | **Model-level semantic control PASS / Ground3 ART FAIL / Godot NOT RUN / VX NOT RUN / Formal Seal NO.**

## Objective and preserved source authority
Stage15 remains engineering PASS, Ground3 ART FAIL, native VX Game.exe NOT RUN, Formal Seal NO. A04 CPU original reference-conditioned PNG and A05 source-zone inpainting engineering baselines remain untouched. A06 sand-only IPAdapter comparison improved sand-like road from 30.11% to 35.66% but had visual artifacts. Stage A07 adds **ControlNet model-level semantic conditioning**, not just an external binary mask or copied source pixels. All sources and previous-stage outputs unchanged.

## Real reference and model evidence
Original source ground3.png RGB 1280x928 SHA256 ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13. Private 48x48 ground3 sand sample SHA256 ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb, reference/comparison only (not produced image).
ComfyUI v0.3.40 CPU FP32 isolated Python3.11 torch2.4.1; Stable Diffusion 1.5 checkpoint SHA e9476a13728cd75d8279f6ec8bad753a66a1957ca375a1464dc63b37db6e3916. Authored ControlNet v1.1 segmentation model obtained from comfyanonymous SAFE FP16 safetensors, size 722,601,100 bytes; SHA256 acd4dd3df2da2f1f2b9dd00f4504cc0d98b20afb608e25f1789a95c0ccdba14a. Official version-pinned source: https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/blob/main/control_v11p_sd15_seg_fp16.safetensors . Complete weight retained on private Windows machine and excluded from transport ZIP.

## Formal annotated segmentation input
ADE20K/OpenMMLab mmseg class/palette source: https://raw.githubusercontent.com/open-mmlab/mmsegmentation/main/mmseg/utils/class_names.py . Downloaded source SHA256 1b82dbe1be95efeec23c5a39a5109cef3bce80da9c982f377e8b4df487f50188. Class 9 grass RGB(4,250,7), class 46 sand RGB(160,150,20), class 52 path RGB(255,31,0), class 91 dirt track RGB(0,10,255). Source original A05 384×384 road mask exactly 28,818 pixels (19.5435%). Generated three two-class palette variants with identical geometry; **only dirt track91/grass9 actually tested by model**. The mmseg ADE palette mapping is empirically accepted as a preparatory hypothesis, not a universal guarantee all annotators/ControlNets use identical colors.
Class-91 control input `A07_ADE20K_GRASS9_DIRT_TRACK91_CONTROL.png` SHA256 7a08a09434bc56f82e0898bbe8bbc4e3a340260a8878e424af17b05c39ba17cf. Image 384x384, exact palette-only two RGB values.

## Actual matched baseline vs ControlNet experiment
Control baseline A05 R3 SD1.5 text-only inpainting: same 384×384 first-pass grass source, road-only VAEEncodeForInpaint 14 Euler normal sampling steps, seed160406, CFG6.0 and denoise1.0; ComfyUI ImageCompositeMasked restores road-outside pixels. A07 added **ControlNetLoader**, **ControlNetApplyAdvanced** and semantic RGB LoadImage; strength0.85 from 0% to 100% of sampling. Same R3 seed/sampler/steps/prompt/negative/input/mask/SD15 checkpoint. API `ControlNetLoader` registered actual safetensors filename and full graph succeeded.
Actual 14-step CPU FP32 model sampling plus decode/SaveImage total 71.83 seconds, not simulated. Native raw output SHA256 a8ae71c9e4db70c52a04aa9885da7a818bef7964f7540bca90b8e4021cb8910d; native composite output SHA256 e873fe849124bccbbce6f0ef4b4883103fd589948f0a22a323048cfe5bf69bc6. Both actual original PNGs archived privately.
Pixel-isolation gate: ALL 28,818 specified road pixels changed, 0 outside changes. Independent Python pass verifies. Real model-level ControlNet segmentation inference PASS. This is NOT new 544x416 gameplay ground.

## Distinct color results and visual acceptance
A05 R2 mixed IPAdapter-only inpaint road: sand-like RGB proxy 0.301131, green-like 0.638212.
A05 R3 no IPAdapter/ControlNet: sand-like 0.193074, green-like 0.774655.
A06 sand-only IPAdapter: sand-like 0.356583, green-like 0.566972.
A07 semantic ControlNet dirt track: sand-like 0.962905, green-like 0.00583, mean RGB of road (190.52,120.95,58.60).
Simple color heuristic definition sand: R>1.04G and G>1.12B; green: G>1.08R and G>1.08B. Values are descriptive only, NEVER art matching scores or trained semantic classifier accuracy.
Human visual review reveals the A07 path is now a consistent solid deep-brown road, but includes TWO giant white stone objects, lacks the light sandy multitone pixel density of ground3, and has sharp/unnatural road edges. In native 32px nearest-neighbor view, path is mostly flat brown. **Art fails**, regardless of color proxy improvement. User art signoff NOT OBTAINED.

## Gate matrix
MODEL_AUTHENTIC_DOWNLOAD_SHA256 PASS. ADE_COLOR_INPUT_GEOMETRY PASS. ACTUAL_CPU_CONTROLNET_MODEL_GENERATION PASS. ROAD_MASK_OUTSIDE_PRESERVATION PASS. MATERIAL_COLOR_CLASS_DISCRIMINATION IMPROVED (not quality). GROUND3_ART_FIDELITY FAIL. PURE_GROUND_ONLY (no stones) FAIL. GODOT_NATIVE_GPU NOT_RUN. RPG_MAKER_VX_GAME_EXE NOT_RUN. PAR/COLLISION NOT_RUN. FORMAL_SEAL NO.

## A08 next falsifiable experiment
Stop treating correct material category as acceptable texture. A08 should isolate appearance from geometry: keep same ADE20K dirt-track map and ControlNet, but use explicit original grass/sand texture conditioning (e.g., add independently validated IPAdapter sand-only reference to the image-conditioning model) OR ground-sample VAE img2img low-denoise for texture retention, only one new controlled A/B. Retain source/prompt/mask/seed and log exact method. ControlNet may encourage stones and stereotyped dirt roads, so enforce no standing objects and exact native 32px ground3 soft texture. Do not run full Village ground or any PAR/VX gate until artwork is visually approved.

## Private delivery
All PNGs, weight hashes, model workflow API JSON, controls, real output and QA reports packaged in private A07 ZIP, without model weights or full copyrighted ground3 source. Separate source and cold-unzip hash list. Public GitHub contains text, workflow and verification code only. Formal Seal NO.
