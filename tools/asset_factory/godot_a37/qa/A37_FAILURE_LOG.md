# A37 Failure Log / Art Hold

- **No reused VX 3-frame limit.** Source sheet is 8×64px, layout 4 columns × 2 rows. No 32px downsample.
- **RUNTIME PASS:** Godot 4.7.2 RX6700 XT (OpenGL) imported, played and captured unique frames, 27 frame_changed events, 2 loops.
- **ART HOLD:** F6 extreme leg stance and F7 dangling/unstable glove remain in source. Tempo variant only SHORTENS dwell on these two frames, does not fix pixel art.
- **NO FALSE STATES:** WAITING/IDLE/ATTACK/CAST/HURT/DEATH are intentionally unavailable, never aliased to RUN.
- **NO INTEGRATION CLAIM:** This is an isolated Godot battle actor scene, not yet merged with the FS combat system, balance, equipment or state machine.
- **SOURCE LOCK:** source PixelLab A35 PNG has known SHA256 and copied without any editing. Original FS VX project and GitHub main unchanged.

Next: introduce an approved fixed-pose identity source for idle, test one dedicated 6–8-frame breathing generation, then connect the animation state API to the separately progressing FS Godot combat migration. Consider F6/F7 pose-constrained local artwork revision only after signoff.
