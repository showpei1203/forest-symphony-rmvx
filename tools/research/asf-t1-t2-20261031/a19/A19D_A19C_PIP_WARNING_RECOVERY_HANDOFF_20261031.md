# A19D recover A19C clone after pip WARNING abort (2026-10-31)

## Evidence directly from uploaded files
A19C_RESULT.json says status=A19C_STOPPED_ON_ERROR, install_steps=[], torch_child_exit_code=null, checkpoint=null, gpu_status=null.
The recorded `error` is exactly a pip WARNING about `torchfrtrace.exe` and `torchrun.exe` not being on PATH inside isolated clone's Python Scripts directory. This warning alone does NOT mean PyTorch is broken or GPU failed.
The user-uploaded A19C_PINNED_PIP_LOG.txt stops after `Successfully uninstalled torch-2.9.1+rocm7.2.1`, before any explicit new `Successfully installed...` line. Therefore torch 2.10 installation cannot be assumed complete. Missing A19C_GPU_CHILD_PROGRESS.json is EXPECTED; the child test was never started.
Code investigation: original a19c_clone_and_install.ps1 uses `$ErrorActionPreference='Stop'` and `& python -m pip ... 2>&1 | Tee-Object`. This piping is susceptible to treating pip's warning on stderr as a PowerShell terminating error *before* reading the real pip exit code. Root cause plausible and reproducible from script path; the exact degree of partial pip installation must be checked with importlib.metadata.

## Correction (NO reclone, no driver changes)
A19D portable user ZIP `A19D_SAFE_RESUME_NO_RECLONE_20261031.zip`: 6 files / 8361 bytes / CRC PASS / SHA256 b307fa813ad2de69b1afbe080158cae843aa812c0ced68c4fa0e58faa997494f.
1. `01_A19D_READ_ONLY_CHECK.cmd` checks the existing A19C clone's embedded Python3.12.10, version metadata for torch/torchvision/torchaudio/ROCm/aimdo, comfy_kitchen, and torch import in an isolated subprocess. Writes `A19D_INSPECTION.json`. No downloads, installs or GPU compute.
2. Optional `02_A19D_RESUME_ONLY_IF_NEEDED.cmd` requires exact user consent `RESUME_A19C`. Only changes packages in **existing A19C clone**. It uses subprocess.Popen with pip's stdout+stderr merged as text and examines the actual process exit code rather than failing on warnings, skips installed pins, finishes remaining ROCm pinned versions, removes clone comfy_kitchen if present and pins comfy-aimdo.
3. It runs a *genuine* 64×64 GPU matmul only when all packages verify, using a distinct child checkpoint file `A19D_GPU_CHILD_PROGRESS.json` and output `A19D_RESUME_RESULT.json`. No pass until both exit=0 and child status=GPU_DISPATCH_PASS with numeric result=64.
No system drivers, PATH, original AMD Portable or FS assets modified; no new clone, no initial 1.5GB redownload.

## Verification boundary
The ZIP was made/tested in ChatGPT Linux sandbox: Python py_compile for 3 scripts PASS, no-existing-clone branch refuses action, Windows-only recovery rejects Linux host, ZIP CRC PASS. Actual Windows pip recovery and AMD GPU inference NOT RUN; G7 visual art NOT TESTED. This status must not be promoted to GPU PASS.

Use 01 first and upload A19D_INSPECTION.json. If all pins installed, don't use 02. If packages missing, user may explicitly authorize 02. Retain all A19C evidence.
