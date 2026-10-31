# Stage16 A04 — Authentic Ground3 Image Conditioning: CPU PASS, ART FAIL
Date 2026-10-31. Route B experimental work only. Stage15 sealed baseline unmodified. Formal Seal NO.

## Actual capability achieved
Executed verified independent reference-image-conditioned diffusion on authorized Windows PC. ComfyUI v0.3.40 (commit 866f6cdab4bd5de95ee6296d1b418c455f67f929) with IPAdapter Plus (commit a0f451a5113cf9becb0847b92884cb10cbdec0ef), CPU FP32 PyTorch 2.4.1. The original source input was a ground-only crop from private ground3.png, 128x128 SHA256 943c7c7aa16f12f15e0f298f5963b91283f4c8bb19fb234c2e48825059fb1928. This is not prompt-only and the reference crop was never counted as generated output.

## Model authenticity and engine evidence
Three downloaded source model files validated SHA256: SD15 fp16 SHA e9476a13728cd75d8279f6ec8bad753a66a1957ca375a1464dc63b37db6e3916 (2,132,696,762 bytes); CLIPVision ViT-H SHA 6ca9667da1ca9e0b0f75e46bb030f7e011f44f86cbfb8d5a36590fcd7507b030 (2,528,373,448); IPAdapter plus SD15 SHA a1c250be40455cc61a43da1201ec3f1edaea71214865fb47f57927e06cbe4996 (98,183,288). Private weights retained on authorized local Windows device, excluded from public GitHub and transport ZIP.
Native ComfyUI HTTP API /system_stats and /object_info confirmed service and 441 nodes including LoadImage/SaveImage/IPAdapterAdvanced. Actual reference LoadImage->SaveImage 128x128 pixel-exact roundtrip succeeded. CPU CLIPVision extracted image_embeds [1,1024], last_hidden_state [1,257,1280] from original reference.

## Controlled CPU A/B test (same seed and exact conditions)
Both CPU FP32, SD1.5 fp16 checkpoint, seed160403, 384x384 RGB, 12 Euler normal steps, CFG 5.5, same positive and negative prompts. B adds the actual reference through CLIPVisionLoader, IPAdapterModelLoader and IPAdapterAdvanced with weight=0.7 and style transfer weighting.
A: text only, new PNG 384x384, 47.0 s, SHA256 99c3080ff9bf6a2562549540183d95206adbae3998123d2c4c1eb5ed5f920d72.
B: real Ground3 image-conditioned, new PNG 384x384, 52.6 s, SHA256 8194bd60e8e88998baadf6b0e8011a90e49f6273bd878086c5a08f8361429857.
RGB byte difference fraction 0.945697, a DIFFERENCE METRIC only, not an image quality/similarity score. Visual inspection: B closer to grass/sandy earth versus A border artifacts, but B still has excessive sandy area and repeated grass patterns; ART NOT APPROVED, specifically Ground3 fidelity FAIL.

## AMD acceleration and failure isolation
Windows10 19045 AMD RX6700XT 12GB isolated DirectML torch-directml0.2.5.dev240914, torch2.4.1. Basic GPU tensor arithmetic and matrix product PASS. Actual GPU SD15 text-to-image 256px three steps 7.4sec PASS; GPU text-only 512px 20 steps about 21.7sec PASS image produced, but art FAIL (static wall and border artifacts).
GPU DirectML + IPAdapter image reference graph failed with native Python.exe torch_cpu.dll access violation c0000005, Windows Application Error EventID1000 2026-10-31 12:24:49. Precise causal library operation not established. No GPU IPAdapter output. CPU FP32 full image-conditioned model on same device/weights succeeded, including smoke 128px 2 steps and matched AB 384px 12 steps. Therefore IMAGE CONDITIONED GENERATION technical PASS only via CPU.
Current latest ComfyUI checkout 6ea48ffc21d2a0c9be0df79f08d72b4ecf2d678f failed to import comfy-kitchen0.2.40 with torch2.4.1 due unsupported custom op annotation list[int]; older pin used. Optional spandrel/torchaudio/workflow templates components reported missing, not needed for these validated nodes.

## Integrity & privacy
Private A04 ZIP contains 31 files, source plus pixel images and workflow scripts; 30/30 SHA256 file cold checks PASS, ZIP CRC PASS; ZIP SHA256 7050de0c525a1d41611febd9889791021b47499541efdb042795818800437642; size 2,181,359 bytes. Contains no pretrained weight files, or full composite ground3 original. Raw source art and original generated PNGs PRIVATE ONLY.
Private Google Drive folder: https://drive.google.com/drive/folders/1NOzdUfKVjFOI4qrVPWIZM578PYP98F9E . This file is the GitHub public text authority. Do not invent public asset paths.

## Final gates and next hypothesis
CPU native image-conditioned generated PNG = PASS. GPU text-only inference = PASS. GPU reference-conditioned inference = FAIL_NATIVE_CRASH. Art Ground3 fidelity = FAIL. Godot new Ground test NOT RUN. Native RPG Maker VX actual Game.exe movement NOT RUN. Formal Seal = NO.
A05 shall refine art: independent road geometry occupancy masks and ground-only semantic control, 1x 32px visual comparison, alternative source patches/reference weights, not returning to Stage15 source quilting. Do not integrate into PAR/VX until art approved. Investigate DirectML crash separately. Human art approval required.