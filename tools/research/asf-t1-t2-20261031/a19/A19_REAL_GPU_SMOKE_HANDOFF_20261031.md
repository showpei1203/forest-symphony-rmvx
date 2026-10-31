# A19 — RX 6700 XT isolated ComfyUI AMD real-GPU smoke (2026-10-31)

## Status: PACKAGED / SANDBOX OFFLINE-TESTED. WINDOWS GPU NOT YET RUN. G7 ART NOT TESTED.

A18 user-provided actual Windows JSON: Windows 10 Home build 19045, AMD RX 6700 XT PNP VEN_1002 DEV_73DF, reported WDDM driver 32.0.21045.16010, system RAM 32 GB, E: free 380.8 GB, Python/git/ffmpeg present. Parsec Virtual Display Adapter is separate. The WMI AdapterRAM_ReportedBytes=4293918720 is not authoritative physical VRAM; normal RX6700XT is a 12 GB model. No drivers/packages were changed during A18.

Community **comfyui-rinsei** confirmed gfx1031 on Windows 10 Pro 22H2, driver 32.0.21043.12001, embedded Python 3.12.10, Torch 2.10.0+rocm7.14.0a20260603 etc. This is community evidence, NOT AMD official ROCm compatibility for Windows10+gfx1031, and user's driver differs. https://github.com/eviscerations/comfyui-rinsei

Official AMD portable v0.42.1 asset: https://github.com/Comfy-Org/ComfyUI/releases/tag/v0.42.1
AMD latest official Windows PyTorch support matrix is Windows11 for explicitly enumerated GPUs; RX6700XT/Win10 not guaranteed: https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/compatibility/compatibilityrad/windows/windows_compatibility.html

## Deliverable — real GPU compute, NOT another metadata-only preflight
A19_RX6700XT_ISOLATED_GPU_TEST_20261031.zip (15 files, 27,343 bytes, CRC PASS, SHA256 f970c9240ac569d9249f6cdf1fae87abda3c5eb2ba869d4660a491e16a8c4843).

1. User manually runs 01_START_SAFE_GPU_INSTALL.cmd; explicitly types DOWNLOAD to permit an approx 1.5 GB download of official ComfyUI AMD portable v0.42.1. GitHub releases tag metadata are fetched and digest checked when present. It extracts **only** under E:\GameAssetToolLab_20261023\A19_COMFYUI_GPU_PILOT and never touches OS driver, system PATH, global Python, FS sealed files or other E: tool projects. After extracting, it uses the embedded Python to dispatch a real HIP torch 64x64 matrix multiplication and synchronizes it. Output A19_STAGE1_RESULT.json and A19_GPU_RUNTIME_REPORT.json. Success requires actual result, not merely device enumeration.
2. 02_ONLY_IF_INSTRUCTED_ROCM_FIX.cmd is NOT to be run until Stage1 result assessed. It refuses any non-Python3.12 embedded environment, checks Stage1 failure and explicit INSTALL consent, and only then installs the exact Rinsei pinned ROCm nightly in isolated portable Python with no system driver changes. Rechecks GPU dispatch and writes A19_STAGE2_RESULT.json.
3. Includes A18 original T1 96x112 source, 128 pad and exact-mask assets and the unexecuted ComfyUI API graph. No model checkpoints downloaded / no AI generation claimed in A19.

## Offline acceptance
In the ChatGPT sandbox, the 15-file ZIP was independently extracted and validated: ZIP CRC PASS, A15 source PNG SHA256=88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f, GPU-probe script runs on a CPU-only host and writes a correctly structured JSON (exit code 7 when no CUDA/HIP GPU). This is **not** Windows GPU evidence. A full PowerShell execution is not possible in this sandbox; user-run Windows results are required.

## Gate
If GPU matrix multiplication passes in real Windows, only then download an appropriate **small SD1.5 inpainting** checkpoint, run ONE masked inpainting of T1 attack arm/sword and use A18 source-lock postprocessor. Compare G7 visual; do NOT run ASF/Godot/VX again until art acceptance. If runtime fails, freeze results and choose safe fallback, no arbitrary driver uninstall or giant video model.
