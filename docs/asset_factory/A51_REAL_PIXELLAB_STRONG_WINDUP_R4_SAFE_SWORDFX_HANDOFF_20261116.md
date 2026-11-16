# Forest Symphony | A51 Formal Handoff (2026-11-16)

## Scope, outcomes and authoritative files
Godot 4.7.2 is the exclusive FS new development engine; attack sprites 45-degree southeast, 64x64, independent Body/Weapon/FX and non-looping 12-frame attack. A51 does not touch any RPG Maker VX original, forest map branch, unrelated migration branches or GitHub main. Owner-only Google Drive houses all actual provider PNGs, private source and QA, GitHub feature branch receives technical sources and detailed handoff only.

A51 REAL MODEL PROVIDER: single new paid PixelLab Animate with Skeleton V3 job b997be06-c1fa-4741-8fb9-bcedf6fc9a39, 10 genuine fullbody 64x64 RGBA images, 3.0 generations, no duplicate paid retry, persistent pre-POST job lock. Original approved A62 F0/F11 complete 12 frames. Authoring basis: A50 R4 original 18-point skeleton with exact fixed head (nose/eyes/ears/neck six) and planted feet, stronger 18-joint anticipation coil F2-F5 and shoulder/elbow/hip move; no printed sword in Body. Full original provider PNG, request JSON, raw job output and SHA in private Drive folder. Body pixels NEVER deformed, sliced or patched.

Actual new-model changes in 10 generated frames: R4 vs A51 shoulder/chest cumulative difference from approved source 401 -> 617 pixels; pelvis/legs 218 -> 272; head identity residual after +/-4px position registration 141 -> 273 (worse). Automated head identity guard FAILED. 0 large disconnected 8-connected pixel islands and 11 distinct frame poses in each. So new A51 fullbody is ART HOLD and MUST NOT replace official R4 until user actually approves visual appearance.

R5 NEW BODY / REAL SWORD: godot_a51/ uses actual true PixelLab Body plus R2 genuine PixelLab independent model sword (from A50 R4), rigid Weapon/FX translation ONLY in F1-F5: (-1,0),(-1,-1),(-2,-1),(-2,-1),(-1,-1). Other moving frames weapon original position; no Body pixel edits; F7 contact (29,7).
A51 new attack frame-key seconds [0,.100,.190,.275,.350,.455,.560,.620,.735,.830,.910,.980] with actual 60ms acceleration between F6 and F7; F7 contact at 0.63s; 70ms hitstop and delayed follow-through hold.

FX: godot_a51_swordtrail/ adds entirely separate 5-color low-res crisp pixel sword streak, sourced from TRUE provider sword tip F6 (50,26) -> F7 (61,39) -> F8 (56,48). FX-visible pixels F5 2, F6 4, F7 38, F8 14, F9 1, not painted on Body; avoids face and spritesheet edge. Initial VFX F7 crossed rightmost x63; native GPU no-crop QA FAILED; error preserved in qa/A51_SWORDTRAIL_INITIAL_EDGE_CROP_FAIL_LOG.txt, fixed all FX output to x,y 1..62, native GPU and damage PASS. No other hidden failure.

BEST ENGINEERING CANDIDATE: godot_a51_r4_stable_fx/ keeps original A50 R4 true PixelLab Body byte-for-byte (SHA256 0c5a6a8314528bb9708c837bbf5d139aba1f383d756178b57bb1356e3cbe9605) and its original independent PixelLab model sword unchanged; ONLY adds A51 improved arc FX and same variable frame key timing. Thus retains R4 more stable face and gains sword animation drama without more paid model requests. Keep visual ART HOLD pending human gameplay-scale acceptance.

THREE distinct native Godot 4.7.2 Radeon RX6700XT projects:
- godot_a51: new PixelLab Body + original sword, frame time curve, editor import/GPU/actual contact PASS.
- godot_a51_swordtrail: same plus new 5-color FX, editor/GPU/actual contact PASS.
- godot_a51_r4_stable_fx: old genuine R4 Body + new FX + frame curve, editor/GPU/actual contact PASS.
Real 12/12 GPU screenshots per project have zero RGBA premultiplication differences vs correct source composite, no cropped edges, 11 different frames. Native runtime checks actual Animation keyframe times, old 0.55s hit NOT prematurely fired, F7 0.63s and Hitstop 70ms, return to idle; standalone practice target HP100 ->75 ->50, range misses, duplicate serial prevention, cancel before/during and 2x playback PASS. Full migrated FS ATB, skill system and enemies NOT RUN, do not claim it.

Actual native preview for review: final_acceptance_previews/A51_THREE_WAY_REAL_GODOT_5X.gif (R4 base, preferred stable+new FX, new-model+new FX); final_acceptance_previews/A51_STABLE_R4_SWORDTRAIL_NATIVE_GODOT_5X.gif; 12-frame 3x PNG and actual native damage screenshot. Failure log and input/provider provenance included. Technique reuses FS A57 real 18 joints, A50 R4 10 original model PNG, create-game-assets/raster-pipeline and Godot headless testing skills.

Total PixelLab expense for this phase 3.0 generations (prior A49+A50 9.1, cumulative 12.1). No nontransparent background, no unauthorized model retries, no secret API token on disk. Temporary Windows native C: directories cleaned after tests. All durable files stay private Google Drive, technical docs/code GitHub.

## 已核實私人 Drive 證據（owner-only）
[完整 ZIP](https://drive.google.com/file/d/169hk3NlwU9NmB34qYjU4DerRLU0E3xpd/view) ｜ [三組真 Godot GIF](https://drive.google.com/file/d/1Dn71jP_khV2_hGYdjaBeT9MQP9CZsCON/view) ｜ [R4+新劍氣 GIF](https://drive.google.com/file/d/1h-jViXC-IskRh6uBT2lCstX5Q6F7oO4F/view) ｜ [三列12幀對比](https://drive.google.com/file/d/1B0hYbqgHKrsLHEz2x3XSf9nOlPh0PHno/view) ｜ [私人資料夾](https://drive.google.com/drive/folders/1D-Krbw-gdo6c0TaTuGuzbF5pHuiprAZp)
