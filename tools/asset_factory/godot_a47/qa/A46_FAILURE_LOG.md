# FS A46 Failure Log / Preventing Repeat Mistakes (2026-11-15)

- A45 known bad: F06-F08 upper-lower torso appears horizontally cut, invisible to simple alpha-connectivity QA. New gate intentionally FAILS A45 and PASSES A62; A46 must pass both sprite source and native Godot PNG.
- A46-ART01: V1 correctly eliminated horizontal waist band, but still looked too rigid in the original Godot visual comparison. Developed V2 instead: upper body/head anticipatory -1px and contact follow-through +1px with hip/feet retained at the same world position. Weapon tip and marker move with wrist.
- A46-QA01: Initial Godot native crosscheck wrapper looked for A45_NATIVE_Fxx naming and false-failed on A46_NATIVE_Fxx. Fixed version-aware filename resolution and reran; source and native A46 now both PASS.
- A46-ENV01: Godot 4.7.2 console executable on E: stalled even with --version; this is environment startup, not art. Console wrapper is 198,152 bytes and depends on 180,858,888-byte matching GUI binary in SAME directory. Copying both to temporary C: made --version exit 0 and subsequent native Godot import/GPU/contact all PASS. Temporary copies removed.
- A46-QA02: V2 QA initially pointed to the promoted A46 main body as V1 provenance and failed after promotion; corrected to stable actor01_a46_body_v1_12frames.png and reran PASS.
- A46-REPRO: Candidate generator originally read mutable main A46 art and would compound transformations on rerun. Refactored V2 generator to read immutable V1 art, A45 weapon/FX and V1 anchors. Double regeneration SHA identical on all 3 finalized layer atlases.
- A46-LIMIT01: The waist-band palette test is a calibrated Actor01 A62-specific regression detector, not general proof of natural biomechanics. Positive PASS cannot certify all motion. Current artistic human-review gate remains HOLD.
- Formal ATB and real FS battle migration NOT RUN; do not claim an isolated damage dummy constitutes full combat integration.
- No modification to original E: RMVX source, GitHub main, unrelated map or Godot migration branches. PixelLab not used.

- A46-QA03: First release ZIP cold validation passed manifest, asset regeneration, editor import, GPU, contact and waist regression checks, but the final diagnostic print mistakenly passed flush=True to json.dumps. Corrected the logging code and fully reran release ZIP cold tests: process exit 0, all checks PASS. Sidecar qa/A46_ZIP_COLD_QA_RECEIPT.json records the verified archive SHA.
