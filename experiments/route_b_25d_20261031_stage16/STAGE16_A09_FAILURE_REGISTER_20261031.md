# Stage16 A09 — Diagnosed Failures, Preventive Rules and Next Exit Conditions
2026-10-31 — FORMAL SEAL NO
F-A09-01: RGB similarity != source pixel fidelity. Ground3 48px VAE roundtrip shifts mean RGB from (208.49,184.52,102.70) to (230.91,205.02,103.53) and PSNR is only 19.27dB. Increased gradient is not proof of correct texture.
F-A09-02: Using original VAEEncodeForInpaint with denoise .28 to 'keep' road source detail is an invalid experimental design; masked pixels are modified/erased by this node and minimal model result becomes gray road. Corrected test must use VAEEncode+SetLatentNoiseMask.
F-A09-03: Corrected VAEEncode+SetLatentNoiseMask graph plus BOTH ControlNet and IPAdapter still native-crashes in torch_cpu.dll. Error is low-level access violation 0xc0000005; not a Python exception; exact problematic operator not identified. DO NOT call this model inference PASS.
F-A09-04: Isolated same 384x384 VAE masked encode/decode passes, and basic SD1.5 KSampler at .28 without added conditioning passes. This narrows fault to interaction/stack/condition at this configuration, but not conclusive about specific component.
F-A09-05: A09 synthetic prior samples Ground3 material RGB statistics via stochastic covariance, not copied donor pixels. This is only a controlled input, not a finished AI-generated map or a sealed source asset.
F-A09-06: A08 and A09 differ in initial latent image and denoise; cannot attribute pixel effects to denoise alone. Full A09 output doesn't exist anyway.
F-A09-07: Actual 544x416, Godot, VX, PAR and collision tests not performed under art-first rule; preserve all previous baselines.
A10: isolate conditioning compatibility and inspect pixel-space/material-domain texture method; no repetitive blind sample/weight tuning.
