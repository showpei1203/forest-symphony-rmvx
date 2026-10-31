# A19D inspection diagnosis and A19D2 targeted ROCm recovery (2026-10-31)

Actual user-provided A19D_INSPECTION.json shows Python 3.12.10. Installed torch 2.10.0+rocm7.14.0a20260603 and torchaudio 2.11.0+rocm7.14.0a20260603 both match the exact RX6700XT community pins. **Do not reinstall them merely because torch import failed.** Torch import fails at `ModuleNotFoundError: Unknown rocm library 'hipdnn'` because ROCm SDK 7.2.1 is mixed with Torch 7.14, and dedicated gfx103X library package is absent.

Other mismatches: torchvision 0.24.1+rocm7.2.1 (wanted 0.25.0+rocm7.14.0a20260603); rocm 7.2.1 (wanted 7.14 nightly); rocm-sdk-core 7.2.1; rocm-sdk-devel missing; rocm-sdk-libraries-gfx103X-all missing; comfy-aimdo 0.5.6 (wanted 0.4.8). comfy-kitchen 0.2.39 must be removed in the isolated clone, per community procedure.

Official community reference: https://github.com/eviscerations/comfyui-rinsei

**New A19D2**: targeted patch to A19D avoids unnecessary forced reinstall of already matching Torch+Torchaudio. It retains explicit consent `RESUME_A19C`, pinned gfx103X ROCm package checks, original Windows GPU smoke and strict success criteria. Changes only existing isolated A19C clone, no driver, global Python, original AMD Portable, project changes. Downloads missing packages only after consent.

ChatGPT-local ZIP `A19D2_TARGETED_ROCM_REPAIR_20261031.zip`, 4 entries, 6339 bytes, CRC PASS, SHA256 639a5397c97287353ff25f9c38d9b256e96917ca44a5de26a099885708a4fccb. Python syntax passed; isolated mock verified existing Torch and Audio are skipped. **Windows patch execution and GPU computation NOT RUN.** After user runs, require A19D2_RESUME_RESULT.json and A19D2_GPU_CHILD_PROGRESS.json (if created). If it fails, do not blindly reinstall or change AMD drivers.

G7 art still NOT TESTED. No model downloaded.
