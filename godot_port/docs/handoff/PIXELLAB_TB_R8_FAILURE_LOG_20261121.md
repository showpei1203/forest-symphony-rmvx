# T-B R8 Failure Log / gate history

2026-11-21 Taipei

1. **R7 TB02 Attack user rejected**: "像身體突然長出一隻手". This is a genuine ART FAIL and overwrites R7's vague ART_REVIEW_PENDING for ATTACK only. R7 frame F5 purple forearm extrudes from chest, old prompt said `claw and bite`, keypoint rig extends two talons. The previous automated clipping/technical native PASS did NOT validate action semantics. Old unaltered atlas preserved as `TB02_BAT_ATTACK_11F_PAD128.png`. It is not an approved production sprite.
2. **Wrong attack-contact offset inherited from old frog**: old parametric `CONTACT Vector2(29,12)` is based on 96px PMD Frog, not 128px TB02 Bat. Isolated T-B R8 copy fixes this to mouth-relative `(14,0)`, native regression checks the emitted local coordinate; main FS battle runtime untouched.
3. **R8 image generation reference tool failed** before making any reference image. User was explicitly informed; no generated asset from that tool was used. Subsequent result is genuinely PixelLab Skeleton v3 using official source, not falsely labeled image-generation output.
4. **R8 success**: provider job `ef8135ef-2a6e-4992-8125-6c4ca2fb631a`, 3 generations; `11/11` independent QA, old protrusion F5 `30→0`, F6 `22→0`, F5 mouth dark `21→101`, visible fang `0→5`, border zero all frames. Godot native 19 captures/19, hit exact once, PMD first-family regression PASS.
5. **Nonblocking/unverified**: PixelLab first/last frames are re-rendered (not guaranteed pixel exact to approved source), provider's dark mouth cavity shape merits user artistic review; Godot native renderer is Mesa llvmpipe on isolated cloud, NOT Radeon GPU nor FS production 45° battle scene. Do not claim ART PASS until user reviews animation.

Rule: Never resubmit `claw and bite` prompt or animate talons horizontally for a bat mouth attack. Create separate named actions for `bite`, `claw_swipe`, and `cast` when applicable. Do not let rigid rig templates invent body parts. Nonblocking pixel polish max 2 rounds, prioritize complete monster pipeline.
