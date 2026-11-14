# A38 Failure Log and resolution

- **R1 model art FAIL:** API model generated 5 actual frames; F1/F2 had excessive arm/head motion. Do not call it a natural breathing loop. F0 exact; end vs A23 mechanical 16 px different.
- **R2 model art FAIL:** two closer endpoints did not fix the naturalness problem: middle frames still moved arms, legs and face. R2 was a separate 1-generation attempt, not a free retry.
- **Calm selection ART HOLD:** selected existing R1 G0/G3/G4 without generating or modifying pixels. 8 playback slots contain only 3 unique poses; reverse motion is intentional symmetric breathing. Do not call them eight newly generated frames.
- **GPU evidence caution:** test script hashes can differ for duplicate frames due rendering timing. Hash count is a GPU-frame diagnostic, not count of unique source poses. Source PNG exact byte comparisons are authoritative.
- **A37 RUN art HOLD unchanged:** A35 F6 stride and F7 glove defects remain. Godot runtime PASS never means aesthetic acceptance.
- **A39 priority:** pose-controlled 48px IDLE art with fixed hands/feet; consider breathing AnimationPlayer upper-body rig rather than unconstrained full-frame image prompts. Then Attack/Cast/Hurt/Death and FS battle migration.
- All binaries on private Drive, no new user PC local work files, no main overwrite.
