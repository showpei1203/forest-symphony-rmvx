# Forest Symphony A21 — first REAL local AI inpainting and G7 visual stop-loss
Date 2026-10-31 / AUTHORITY: T1 pixel art, local pilot, no official FS assets replaced.

## Formal acceptance
- Windows AMD Radeon RX 6700 XT ROCm 7.14 with Torch 2.10: **real GPU 64x64 matrix PASS in A19D2; first actual SD1.5 AI inpainting inference PASS in A21**.
- **Art G7 FAIL on BOTH generated keyposes**. 0 formally accepted sprites. This is not a sealed FS asset. No A21 ASF/Godot/VX visual gate run.
- **PixelLab account consumption in this A21 local experiment = 0.** Another ChatGPT chat owns paid PixelLab map testing and its generation budget.
- Source A15 96x112 PNG SHA256 88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f, identical original, remains unmodified.

## Actual Windows execution
1. Existing A19C isolated Python can do HIP GPU math; original official AMD Portable has ComfyUI v0.42.1 code and incompatible fixed Rinsei aimdo 0.4.8. v0.42.1 failed twice: `init(simple_vram_headroom)` unsupported and missing `comfy_aimdo.storage` / mandatory `comfy_kitchen`. This is SOFTWARE VERSION MIXING, not GPU failure. An exploratory aimdo 0.5.6 install produced a deeper missing `comfy_kitchen` import; do NOT continue blindly patching current ComfyUI.
2. Downloaded separate ComfyUI **v0.23.0** code into `E:\GameAssetToolLab_20261023\A19_COMFYUI_GPU_PILOT\A21_COMPAT_COMFY_023` (GitHub v0.23.0 commit a88e02b18576283b1ff25a4b564548c5dc42cbf6); pinned comfy-aimdo back to 0.4.8 within A19C clone only. A custom bootstrap forced old code path ahead of old embedded-Python path. Real HTTP **200** from `http://127.0.0.1:8197/system_stats` gave `comfyui_version=0.23.0`. Standard built-in Inpainting nodes verified present. Nonessential template media warnings remained, server worked.
3. Chose 2.13GB SD 1.5 Inpainting FP16 original `sd-v1-5-inpainting.fp16.safetensors` from Hugging Face; SHA256 verified `1a33284f5a9be288d1d97c4b1d66d186b1eda8d3703506318e3358bf05914cee`. First ComfyUI request failed in CheckpointLoaderSimple: model file used 1145 key names prefixed `state_dict.`. Inspection found complete UNet 686, CLIP 197, VAE 248, 9-channel input weight shape 320x9x3x3. No model inference happened in this first rejected request.
4. Repacked the original model locally by stripping `state_dict.` from 1145 weight names, preserving original checkpoint. New `A21_SD15_INPAINT_FLAT_FP16.safetensors` SHA256 `d00a24a2a74a07d5894924d84c8c1d07dfc1a53ac6f5e20eaa3288af90858c49`; size 2,132,679,532 bytes. Model was then accepted by ComfyUI and **real inpainting GPU inference completed**.
5. A21 experiment: 96x112 source centered unscaled in 128x128, inpaint at 512x512 using nearest-neighbor + magenta chroma background, A15 original 38-color palette output quantization and 0/255 alpha, head protected 1258 px; wide arm+weapon edit mask 2507 px; masks have 0 overlap. **Final edit 2492 pixels, head 0 changes, outside ROI 0 changes. Visual FAIL:** huge green cloth-like block instead of articulated hand/sword.
6. A21B experiment: materially different mask geometry (only **1023** editable pixels, 0 head overlap), denoise 0.63 vs 0.83, more precise sword prompt. Real GPU generation completed. **Final edit 1003 pixels, head 0 changes, outside ROI 0 changes, source palette 38 colors max**. Visual FAIL: huge sword blade; unnatural glove, elbow, shoulder connection and anatomy, despite meaningful improvement over the wide mask.
7. Explicit **STOP after TWO materially different local AI-generated candidates**. No third trial or uncontrolled tuning of CFG/seeds.

## Verified private Windows deliverable
`E:\GameAssetToolLab_20261023\A19_COMFYUI_GPU_PILOT\A21_T1_LOCAL_INPAINT_TWO_CANDIDATES_G7_FAIL_PRIVATE.zip`
35 files, 440,819 bytes; duplicate member count=0; CRC PASS; SHA256 **d3af92acc9e477e76a13905c5765787a93abdb1fc111f68d308e51ba57841162**.
Contains original A15 authority image, both 96x112 test candidates, x5 review images, raw ComfyUI GPU outputs, source/edited masks, procedural scripts, safe generated jobs and detailed QA. **Model weights are not included; no private image ZIP uploaded to GitHub/Drive.**
A21's exclusive local ComfyUI server process PID 24736 was stopped after packaging to free GPU resources; base A19C PyTorch ROCm and original A19 Portable remain as before; no Windows driver modifications.

## Engineering lesson and future decision
Keeping a stable source identity is a solvable write-permission and mask QA problem; believable pixel-art pose/keyframe anatomy is an *art conditioning* problem. SD1.5 base inpainting did not master original T1 shoulder/forearm/sword, despite controlled masks and two real inferences. Do not run more variations of the same generic model. Next justified experiment requires an independent artistic signal: a hand-drawn pose target/reference, a game-sprite-specialized model with LoRA/ControlNet, or a **small** PixelLab Skeleton trial coordinated with the separate chat managing the paid PixelLab budget. One excellent approved pose before any eight-frame animation. G7 must be visual, never inferred from RGBA accuracy.

Sources:
https://github.com/eviscerations/comfyui-rinsei
https://github.com/Comfy-Org/ComfyUI/tree/v0.23.0
https://huggingface.co/ghunkins/stable-diffusion-v1-5-inpainting
