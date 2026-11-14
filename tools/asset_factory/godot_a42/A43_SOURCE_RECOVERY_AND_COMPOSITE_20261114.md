# A43 actual source recovery and first composite candidate | 2026-11-14

## Critical recovery
A42 formal handoff already named the signed 81-member ZIP in private Drive: https://drive.google.com/file/d/12MGWp8e0W6yvic3dqnUv6BNf8_YPOt6P/view. Downloaded and extracted. Confirmed actual original A42 body, weapon, FX, A41 attack, A62 idle and native Godot QA outputs present. Earlier claims of unavailable A42 PNG were wrong: failure to follow the existing Handoff.

## Actual A43 art artifacts (private Drive)
- Candidate ZIP: https://drive.google.com/file/d/1nSoHrxvY7jnAiT8fHCNgbXmicDFPfzpE/view
- A42/A43 F6 contact comparison: https://drive.google.com/file/d/11ZhgR1BjSSrO6oczk-nyKHGlAoggyF6p/view
- ZIP includes original-A42-body+weapon with A43 sword-tip-trail FX composite, 12-frame actor GIF, A42 reference GIF, contact comparison, generator script, two new 256x192 PNG atlases.
- A43 FX is visible F4-F8 and anchored to A42 rig's actual sword-tip coordinates. Original body and weapon are byte-preserved.

## QA
Local Pillow image validation PASS for 256x192, 12-frame 64x64 atlas, FX active frames 4-8 only, sword-tip pixel connected. This is NOT native Godot GPU validation.
Art HOLD: no new arm/shoulder/body motion yet; new sword arc may still need visual review. Godot runtime NOT RUN. Full FS ATB/damage NOT RUN.
A42 original signed ZIP, GitHub main, map branch and RMVX E: untouched.

## Next
Import candidate FX into recovered Godot A42 project, run native Godot render and screenshot comparison; then revise actual actor body and weapon poses, art review, complete QA and Handoff.
