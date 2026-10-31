# Stage16 A03 DirectML isolated GPU proof, dated 2026-10-31
Status: DirectML elementary GPU operator PASS, current ComfyUI source clone PASS, dependency resolution DRYRUN PASS. ComfyUI actual runtime, SD image, real IPAdapter reference control = NOT RUN. Formal Seal = NO.

## Environment
Windows 10 19045 on DESKTOP-90VT437. AMD Radeon RX6700XT 12GB. System Python3.11 unaffected. Independent venv E:\FS_ROUTE_B_STAGE16_A03_REFERENCE_CONDITIONING_20261031\dml_probe_venv contains torch-directml 0.2.5.dev240914, torch 2.4.1+cpu, torchvision0.19.1. No GPU driver or production Forest Symphony modifications.
Note: torch-directml is preview-only. Plain pip index versions torch-directml initially returned no available versions; pip index versions torch-directml --pre displayed 0.2.5.dev240914. DirectML installed successfully.

## Actual GPU test R1 and R2
R1 detected one DML device named AMD Radeon RX6700XT; addition 1+2 gave 3. Test using torch.eye on DML emitted CPU fallback warning and matmul/eye assertion failed. This is logged, and R1 is NOT used as PASS.
R2 used torch.ones(16,16).to(torch_directml.device()) and torch.full((16,16),2.0).to(same). The result (a+b).mean().cpu().item() was 3.0, while all entries of GPU matmul (a@b).cpu() were 32.0. Device was privateuseone:0; both basic arithmetic and matrix multiply PASS, without observed R2 fallback warnings. Actual image diffusion operator support is UNKNOWN.

## ComfyUI preflight
Official ComfyUI repository cloned at E:\FS_ROUTE_B_STAGE16_A03_REFERENCE_CONDITIONING_20261031\ComfyUI. A pinned torch2.4.1 and torchvision0.19.1 pip --dry-run requirements resolution returned 0, without installation. Latest ComfyUI includes large frontend and video/audio workflow templates. NO full requirements install; NO model checkpoint; NO ComfyUI server, API or image run. No IPAdapter invocation.

## Independent gates
TORCH_DIRECTML_INSTALL: PASS
GPU_DETECTED_RX6700XT: PASS
GPU_TENSOR_ADD: PASS
GPU_MATMUL: PASS
R1_EYE_CPU_FALLBACK: FAILED / LOGGED
COMFYUI_REPO_CLONE: PASS
COMFYUI_REQUIREMENTS_DRY_RUN_WITH_PIN: PASS
COMFYUI_RUNTIME: NOT_RUN
SD_IMAGE_MODEL_GENERATION: NOT_RUN
IPADAPTER_GROUND3_REFERENCE_IMAGE_INPUT: NOT_RUN
VISUAL_ART_GROUND3_APPROVAL: NO
RPGMAKER_VX_ACTUAL: NOT_RUN
FORMAL_SEAL: NO

## Next
Build compatible lean isolated ComfyUI runtime, do local no-model smoke test, then source legal checkpoint and IPAdapter weights, set actual 128x128 Ground3 reference image as input node. Record checkpoint hash, model revision, seed, workflow JSON, reference strength and raw PNG outputs. Compare controlled no-reference versus reference-conditioned results at 1x and 32px. Do NOT declare pixel crop or DML tensor PASS to be model generation success.

Private audit backup: https://drive.google.com/file/d/14bjf_1-ktEyFpm2BM14ruTs8hlMSMi2j/view
Private addendum text: https://drive.google.com/file/d/1F8P1z_j71lQjYe5X12fcVWofTtJb-KHS/view