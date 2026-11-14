# A39 Failure Log and design constraints — 2026-11-14

**B01 RESOLVED: global PixelLab V3 IDLE re-renders the entire face and arms.** A38 R1/R2 affected 243–329 head-ROI pixels. A39 skips new providers and instead uses one unmodified A62-approved idle source. The upper-body-only 64px Godot shader is constrained to three rectangles in native pixel coordinates, with alpha-lock. Shader proof on actual RX6700XT GPU: head/feet/outside allowed region delta = 0 pixels across all 8 frames; alpha delta = 0; 4 real unique poses.

**B02 CONTROLLED: Source layout and visual fidelity.** Original source is a 48px Actor01 embedded without scaling in a 64×64 RGBA canvas, nearest neighbor. Explicit SHA256 guard and on-GPU F0 vs source difference = 0. Original A35 RUN eight-frame sheet bytes unchanged. No further VX 3-frame conversion.

**B03 RESOLVED: isolated scene actor feet floated above ground line.** Actor transform raised? Corrected both battle actor Y coordinate from 383 to 416 (the apparent feet are now on y≈477, ground line y479). This is a presentation-only scene fix; source art and movement curves unchanged. Re-ran integrated real Godot GPU validation EXIT=0 and captured a new screenshot.

**B04 RESOLVED: test preview contact builder accidentally targeted `qa/qa/output` instead of `qa/output`.** Fixed `root = Path(__file__).resolve().parent.parent` and regenerated actual GPU contact/GIF; no first attempt result was accepted.

**B05 RESOLVED: integration patch expected wrong project title.** Read exact project.godot and corrected literal target from `FS A39 ...` to `Forest Symphony | A39 ...`, re-ran deterministic source-copy patch with byte-identity checks. Editor import and real GPU runtime tests exit 0.

**B06 OPEN — ART HOLD:** Small shader-region motion produces pixel armor breathing, but does not yet move major body joints. This is **not** a complete 8 AI-generated-frame IDLE animation. Eight time phases contain 4 distinct original-palette GPU appearances. For stronger artistic movement, refine rig zones with approved manual art overlays or add independently controlled torso/shoulder meshes, keeping the head/feet lock. Do not silently reinterpret TECH PASS as artistic acceptance.

**B07 OPEN — integration NOT_RUN:** Isolated Godot battle animation prototype only; full FS port's battle state machine, ATB, skill triggers, attack/hurt/death and equipment visuals are not tested here.

**A40 handoff:** Treat A39 local shader rig as reusable, approved-source-preserving technical foundation. Incorporate into the FS Godot battle-state integration branch only after syncing with the existing migration branch and verifying state changes; then proceed to first action animation (ATTACK) with keyframed silhouettes, mandatory pose QA and real GPU playback.
