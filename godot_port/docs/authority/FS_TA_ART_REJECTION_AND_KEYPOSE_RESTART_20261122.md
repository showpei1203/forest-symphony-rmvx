# Forest Symphony T-A: R16/R17 rejected and R18A/R18B rejected after art review
Date: 2026-11-22. Production rule, highest priority in T-A after user explicit rejection.

## Retrospective factual correction
- R16 source/anatomy native GPU tests passed, but **ART REJECTED** by owner.
- R17 12-frame arm/chest procedural modifications and source/native 73/73 tests passed, but **ART REJECTED** by owner; neither R16 nor R17 is acceptable character animation.
- R18A independently hand-keyed each pose at 64px (separate fists/arms/legs and A62 approved unchanged face) but initial seam assertion FAILED because a foot offset depended on frame index. This was corrected and rerun.
- R18B corrected F7 more diagonally after R18A art review, actual owner Windows Godot 4.7.2 OpenGL 73/73 64px at 60Hz, 12/12 full RGBA zero byte differences, F7 0.630 once; 92-file CRC ZIP PASS 208826 bytes SHA `f82235e2251467dda54b9e20e9831619811f2feaa904269c698bcebc2cd6120e`. Body SHA `a6ee6180b05b6e7940d1cbb294bde34be1e15deea63e229fed4ef4218a2f33d4`.
- **R18B ART REJECTED** on inspection. Simplified angular boots, static / unconvincing shoulder+torso kinetic chain, skinny segmented diagonal right arm and low-impact original 1× acting. Full Forest Symphony Battle ATB/damage NOT RUN. The isolated native render and source completeness are not aesthetic validations. There was NO paid PixelLab job.
- Private [R18B rejected artwork + evidence, 13 cloud files](https://drive.google.com/drive/folders/1OQGma8keUxoHMT7wKG-5rr-VPOyPa1tV). DO NOT use any R16-R18 as new production baseline. Original A52 and approved A62 face/identity preserved, no weapon/FX; T-B/T-C/main unaffected.

## Root cause (do not repeat)
1. A verified original LPC diagonal 8-dir WALK/ORA is valid for identity and anatomy, but is NOT source-native ATTACK. Rotation and cut/paste reposing of tiny walking arms is not believable boxing.
2. 8-connected components, SHA, unchanged boots, 73 native frames, RGBA exactness and CI pass measure software correctness only. They do not measure an acceptable clenched fist, shoulder/chest/hip power sequence, stance weight change or coherent 1x expression.
3. Premature full 12-frame procedural generation multiplies poorly designed key silhouettes and promotes optimizations around the wrong objective.

## Mandatory new production workflow
1. **ART KEYPOSE GATE BEFORE CODE/CI.** Author five genuinely redrawn artistic key poses from the same coherent 45° perspective, matching A62: F0 guard, F3/F4 compress/coil, F5 hip+shoulder loading to drive, F7 fully extended clenched fist with leg stance/hip transfer, F9/F10 recovery. Separately draw whole-body silhouette, face, near/far shoulder and elbow, compact closed fist, hips and original-style leg/boots in each. Source-repositioning/algorithmic limb bars and interpolation are not valid stand-ins for finished artwork.
2. At 1× 64px and 4× nearest-neighbor, validate recognizable fist (never flat open palm), anatomically readable elbow/wrist, far hand remains guard, leg spread/weight shift, pivot, head acting, no face occlusion. Assess **motion** on real preview at playback speed too. Owner visual approval is required; any one major blocker means REJECTED.
3. Only after these five pass, hand-author the remaining seven 64×64 frames from the approved poses; enforce F0=F11, true 12-frame timing with F7 visual impact 0.630 and separate all-transparent Weapon/FX layers.
4. THEN Godot 4.7.2 original native QA, actual FS Battle integration and final 1x ART PASS; no claim of deployment, merging, or paid PixelLab execution before it occurs.
5. Keep materials and private original binaries in Google Drive, repo contains source procedures/QA/status only. Preserve upstream LPC TheraHedwig/Redshrike license attribution and SHA-protected A62 identity. No VX return. T-B/T-C untouched.

**STATUS: ART_REJECTED, NO PRODUCTION ANIMATION.** Success = a naturally convincing attack at original pixel size, not more CI green checkmarks.
