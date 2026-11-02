# FS A58-A60 real PixelLab full-body run pilot, 2026-11-02

User requested dynamic iteration and GIF-based visual QA, not native VX integration.

A58 original corrected 40x40 source with A57 real estimated 18-joint motion, one locked paid v3 generation. F0-to-F1 visible head difference 64 pixels, shoulder+arms 146; upper body is no longer frozen. FAIL: F1/F2 had 5 opaque bottom-edge pixels each.

A59 same full-body poses on 48x48 transparent canvas with 4px margin, one locked paid v3 generation. PASS all edge checks; FAIL full-body head motion (visible F0-F1 only 6 pixels). Do not confuse format PASS with art PASS.

A60 same A59 padded source and all unchanged arm/hip/leg joint poses, but head/face shifted cohesively -1.39px left/+1.39px right, neck and shoulders counter-follow. Third single locked paid v3 generation. Edge-clear = True; head motion gate = True; arms gate = True; legs gate = True; technical gate = PASS.

Native FS original _1/_2/_3 assets untouched. 48x48 is only animation-art review, not VX 32x32 release. 45 degree facing, natural movement, original FS identity are ART PENDING human GIF review. Do not automatically generate further paid variations until bone-level failure causes are identified.

Source action semantics: F0 neutral F1 left step F2 right step, playback 0 -> 1 -> 0 -> 2. Original 32px FS action strip and all A57 source 18-joint data remain authorities. Every stage retains actual PixelLab PNG frames, generated GIFs, exact request JSON, source SHA, job lock and QA.

GIF comparisons: A60_ORIGINAL_A58_A59_A60_FOUR_ROW_VISUAL_COMPARE.png. Primary candidate: A60_FULLBODY_RUNNING_0_1_0_2_8X.gif.