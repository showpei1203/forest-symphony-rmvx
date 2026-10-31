# A18 / RX 6700 XT local inpainting read-only and source-locked QA (2026-10-31)
Formal status: **OFFLINE ART SAFETY / PRECHECK PASS**, Windows GPU driver compatibility **NOT RUN**, ComfyUI inference **NOT RUN**, G7 ART **NOT TESTED**. Do not replace sealed FS.

## Why this is a different experiment
A10–A16 succeeded in ASF and Godot, but not in original artistic arm/hand/keypose drawing. A17 showed that uncontrolled image generation changes the T1 face, even if it creates one recognizable attack pose. A18 separates artistic generation from *source-pixel write permission*.

## What was REALLY executed in ChatGPT sandbox
- A15 T1 source 96x112 RGBA PNG bytes and SHA256 `88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f` verified.
- Original source embedded unscaled in 128x128 with offset (16,8); exact RGBA crop equals source.
- Head protected mask 1258 active pixels, arm/sword edit mask 2507 pixels, masks overlap 0.
- Solid-magenta keyed RGB input and binary edit mask upscaled by nearest-neighbor to 512x512 for *potential* SD1.5 inpainting.
- A 9-node ComfyUI API-style prompt graph prepared using built-in LoadImage / LoadImageMask / CheckpointLoaderSimple / CLIPTextEncode / VAEEncodeForInpaint / KSampler / VAEDecode / SaveImage, with purposely invalid placeholder checkpoint name.
- Pure Python postprocessor only changes pixels inside edit mask, and copies entire protected head and all other pixels verbatim from A15. A deliberate wrong-color synthetic input was used to assert zero outside-ROI and zero head changes. Test images were never misrepresented as generated sprite assets.
- Complete package was unpacked into a fresh temporary directory and tests exited 0.
- No Windows device driver, ROCm installation, model checkpoint, ComfyUI startup or inference was executed.
- Local-only complete ZIP `A18_T1_COMFYUI_INPAINT_PREFLIGHT_20261031.zip`: 17 entries, 39,408 bytes, CRC PASS, SHA256 `423e8e5475692045ad9359b6e1919854b6d3b73ac45194f3ffb1f714fa6d28fc`. ZIP not uploaded to GitHub/Drive; it is downloadable from current ChatGPT conversation.

## Next safety gate
Read-only Windows `DOUBLE_CLICK_GPU_PREFLIGHT.cmd` checks graphics adapter, driver, RAM, disk and executables without changing anything. Inspect result BEFORE installing isolated ROCm nightly. The community eviscerations/comfyui-rinsei repository claims working RX 6700 XT/gfx1031 on Windows with pinned package stack; this is independent community evidence, NOT official GPU compatibility or our actual test.

Only then: isolated ComfyUI SD1.5 inpaint setup -> exactly ONE true art inference -> postprocess via same mask -> G7 human visual review. If unsuccessful after two materially distinct art candidates, stop. No multi-frame/video model investment beforehand.

Sources:
https://github.com/eviscerations/comfyui-rinsei
https://github.com/Comfy-Org/workflow_templates/blob/main/site/knowledge/examples/tutorial-basic-inpainting.md
https://blog.comfy.org/p/official-amd-rocm-support-arrives
