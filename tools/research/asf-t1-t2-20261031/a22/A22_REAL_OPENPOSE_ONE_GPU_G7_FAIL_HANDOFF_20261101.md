# ASF A22 — ONE REAL ControlNet OpenPose GPU test (2026-11-01)

## Final decision
**LOCAL ENGINEERING PASS; REAL INFERENCE PASS; ART G7 FAIL.** There were no PixelLab API calls in this A22 experiment. The authoritative A15 source and sealed FS files remain unchanged. A22 is NOT a deployable sprite.

## Why new compared to A21
A21 wide-mask and A21B tight-mask SD1.5 inpainting both failed anatomical and weapon silhouette. A22 used an independent explicit COCO-18 pose skeleton from manually authored shoulder/elbow/wrist locations, passed to an FP16 OpenPose ControlNet. This adds spatial pose guidance rather than changing the seed/mask of the old workflow.

## Verified actual on Windows
- Source: A15 T1 attack_02 PNG 96x112 RGBA, SHA256 `88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f`.
- Existing isolated RX6700XT gfx1031, PyTorch2.10 ROCm7.14, ComfyUI v0.23.0. Service HTTP 200, built-in ControlNetLoader/ApplyAdvanced available.
- Reference ControlNet file `control_v11p_sd15_openpose_fp16.safetensors` from comfyanonymous, exact 722,601,100 bytes, SHA256 `4003c1da17b0e4ba444e02140e1c0d83bb24b79e4dcfd613c3a554d38f0f89c7`, verified after download.
- Original head preserved 1258 px. Tight allowed-edit mask=1023 px, intersect=0. Rig guide authored in 96x112 frame, then translated/padded and nearest-neighbor rendered to 512x512.
- Exactly **one** A22 ControlNet + inpaint job completed. Prompt ID `e3b588de-1e2c-4687-a4cc-614a12133f4a`. Produced model image and postprocessed native 96x112 PNG. Exactly 1015 changed pixels inside edit region, 0 head pixels changed, 0 outside-mask pixels changed; output uses 33 of source 38 RGB colors.
- **Visual FAIL:** gigantic muddy green-brown sword, poor glove/wrist/forearm connection. Although ControlNet influences coarse pose, it does not define the required short sword / articulation and source-specific palette semantics. No third generic SD1.5 retry.
- Generated PNG, raw model output, pose diagram, source, code, QA, history and visual G7 reject file are privately archived on authorized Windows:
  `E:\GameAssetToolLab_20261023\A19_COMFYUI_GPU_PILOT\A22_T1_OPENPOSE_ONE_ACTUAL_GPU_G7_FAIL_PRIVATE.zip`
  21 files, 56,318 bytes, CRC PASS, SHA256 `c57a1e9de6fc231fc91efb8b1d2e922ae80b90e463aa2692f6af22a206610130`.
- A22-started ComfyUI service stopped after inference, freeing GPU. No hidden background generation left.
- Small independent preflight archive in this chat sandbox: `A22_T1_OPENPOSE_PREFLIGHT_PLUS_G7_REVIEW_20261101.zip`, source-controlled guide and scripts; this is not the live Windows generated PNG archive.

## Stop-loss/pivot decision
A21 wide-mask, A21B tight-mask, A22 OpenPose now cover 3 substantially different generic SD1.5 conditions. **All G7 FAIL**. More inpainting/seed roulette is banned. The next materially different test must provide a hand-painted target sword/arm silhouette; train/use style+identity LoRA with genuine pixel sprite exemplars; or run ONE budgeted PixelLab Skeleton shot *only after coordination with the other conversation using the paid PixelLab account*.

Anatomical pose guidance alone does not satisfy weapon-hilt or pixel-art style consistency. Complete one artist-approved keypose before making inbetweens/ASF/Godot/VX outputs.

Sources: 
- https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/blob/main/control_v11p_sd15_openpose_fp16.safetensors
- https://github.com/90cube/Comfyui_Custom_Preprocess_for_pixelart
- https://github.com/Spit8/_ComfyUI_CharacterPose
