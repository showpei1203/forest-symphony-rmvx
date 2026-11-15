# Forest Symphony A47 | Smooth Full-Body Sword Attack
Godot 4.7.2 battle actor animation prototype. Press F5 (practice-target demo), A to attack, R to reset.

## Actual work
Uses FS A57 full-body 18-joint research, A62 approved natural gait, A65 scanline-failure negative example, and FS active Godot-first Master. Smooth coordinate-space 2D body warping blends head/neck/shoulders/chest/waist while wrist, hips, knees and feet remain constrained. Independent Weapon and FX layers preserved from A46. No paid PixelLab generation.
Three separate 12-frame 256x192 Body atlases created: R1 and R2 FAILED independent connected-body QA (10 detached pixels each). R3 selected, 12 frames single connected Body; wrist distance 0 or <=1.5px; original foot pixels locked. Verified source A62 waist PASS, bad A45 FAIL, chosen A47 PASS.
12x native Godot AMD RX6700XT framebuffer screenshots with zero pixel differences, F6 x30,y9 at 0.55s, hitstop 70ms and real practice target contact HP 100->75->50, cancel and miss tests PASS.

## QA and Reproduction
- python qa/a47_joint_warp_generation.py
- python qa/a47_independent_variant_qa.py
- python qa/a47_promote_winner.py
- python qa/a47_cold_native.py (transient C: Godot copy used for native import and GPU rendering, removed after)
- True Godot animation: A47_GODOT_NATIVE_ATTACK_12FRAMES_4X.gif
- True Godot A46-vs-A47 side-by-side GIF and 1x/3x comparison contact sheets.
- qa/A47_FINAL_QA_SUMMARY.json, qa/A47_FAILURE_LOG.md, qa/A47_NATIVE_COLD_QA_RESULT.json, qa/A47_18JOINT_DESIGN_NOT_PROVIDER.json.

Gates: ENGINE/GPU/isolated target PASS; known A45 body disconnection regression PASS; overall USER ART HOLD; fully migrated Forest Symphony ATB/skill/enemy battle NOT RUN.
P0: private Drive art and source of truth, GitHub feature branch; no overwriting E: VX/main/map/migration branches.
