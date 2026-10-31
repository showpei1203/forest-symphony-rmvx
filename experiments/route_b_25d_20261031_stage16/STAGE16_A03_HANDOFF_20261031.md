# Forest Symphony - Stage 16 A03: Ground3 style reference audit
Date 2026-10-31. Source PNG/Python SHA cold QA PASS. ART pending. No actual reference-conditioned model run, no Godot/VX game run, Formal Seal NO.

## Corrected Ground3 authority
Original ground3.png on authorized computer is RGB 1280x928, SHA256 ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13. Original whole composite has 186,413 unique RGB colors and contains houses, trees and cliffs; local 64px ground texture should be evaluated separately. The former low-color/hard-edge 16-bit pixel criterion is NOT accurate for this soft dense original art. Do not compare global color statistics across a composite Ground3 and ground-only candidate as an art score.

## Original-source style sample, not output art
Extracted nine exploratory 160x160 samples on authorized Windows device, rejected contaminated roof/fence/tree/cliff samples. Ground-only sample crop coordinates (930,260,1058,388) into RGB 128x128 PNG, SHA256 943c7c7aa16f12f15e0f298f5963b91283f4c8bb19fb234c2e48825059fb1928. Private on desktop at E:\FS_ROUTE_B_STAGE16_A03_REFERENCE_CONDITIONING_20261031\REF_GROUND3_ACCEPTED_GROUND_ONLY_128.png. Input for eventual IPAdapter style conditioning only; NEVER count this extracted sample as generated Ground. The extraction code and hash are provided separately.

## New A03 prompt-only PNG experimental baseline
Actual new text-to-image RGB 1473x1068 source, generation ID 0ca3d697-1f6b-4404-9789-baa00da1445c; SHA256 f62755a3d9545ca03136fb780bf8f257cae6fa9b7ae37cfc9432d3e6426b4d43. Crops: (448,224,992,800) -> RGB 544x576, then (0,80,544,496) -> RGB 544x416. No interpolating, recoloring or Stage12 donor pixels. Pixel-exact native crops PASS. Shift crop by 1px NEGATIVE detected PASS. Source PNG cryptographic integrity PASS.
A01/A02/A03 544x416 at 1x and three 32x32 crops nearest-neighbor 8x prepared for review. A03 has 174507 distinct RGB colors in ROI; descriptive count only, NOT a style fidelity score. ZIP CRC PASS, cold extract verifier PASS and 12/12 file SHA256 consistent.

## Method provenance: critical
This A03 output is prompt-guided independent text-to-image. NO verified model-side image-reference input was used; therefore do NOT call this a successful IPAdapter, ControlNet, Krita or ComfyUI image-conditioned generation experiment. Original generation seed unavailable. Ground3 visual ART gate not approved. No Godot GPU render, no native RPG Maker VX Game.exe test, no PAR/collision integration by design.

## Gate matrix
REAL_ORIGINAL_PNG = PASS
INTEGRITY_AND_NO_RESAMPLE_CROP = PASS
COLD_ZIP_12_OF_12 = PASS
ORIGINAL_GROUND3_REFERENCE_INPUT_CROP = PASS
MODEL_IMAGE_CONDITIONING = NOT_RUN
ART_MATCH_GROUND3 = PENDING_NOT_APPROVED
GODOT_REAL_GPU = NOT_RUN
VX_NATIVE_RUNTIME = NOT_RUN
FORMAL_SEAL = NO

## Next work: A04
Load the original verified 128x128 reference image into a real model image-conditioning workflow. Preferred ComfyUI + IPAdapter or Krita AI Diffusion with proper documented image-input node. Keep checkpoint/hash, input hash, seed, reference strength, output PNG, workflow JSON. Run matched seed prompt-only versus genuine ref-conditioned trials. Device is Windows10, AMD RX6700XT gfx1031 12GB; ROCm compatibility uncertain, do not alter drivers or sealed Forest Symphony source. Repo IPAdapter Plus maintenance-only since April 2025: https://github.com/cubiq/ComfyUI_IPAdapter_plus.

Private Stage16 ZIP and handoff: https://drive.google.com/drive/folders/1NOzdUfKVjFOI4qrVPWIZM578PYP98F9E
Private A03 ZIP: https://drive.google.com/file/d/1znieK5DOGDhjz1f8bkf4EswRSRHg2-qe/view
Source reference PNG remains private on authorized Windows desktop; not in public repo.