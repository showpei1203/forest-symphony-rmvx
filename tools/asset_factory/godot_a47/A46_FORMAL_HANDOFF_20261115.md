# Forest Symphony | A46 V2 Formal Handoff | 2026-11-15

## Original source authority
A45 final private Drive ZIP: FS_A45_ACTOR01_MOTION_SELF_AUDIT_GPU_PASS_ART_HOLD_20261115.zip
SHA256 5913dc77ed3bbb0942585c8f491a4dbd3e6fa1b56464dcb72e478eaf264dddbc.
Engine Godot 4.7.2, 45-degree 64x64 battle frame; 32x32 map baseline is unchanged.
GitHub branch feat/fs-asset-factory-v1-20261107; A42-A45 preserved.

## User-reported failure, independently confirmed before editing
A45 F6-F8 waist was visually detached after the old process removed y46-55 and separately repainted legs. Existing alpha-component and native pixel QA were misleading false passes.
Correct blocking gate: baseline A62 PASS / bad A45 F06-F08 FAIL / fixed A46 V2 12/12 PASS.
This was checked against actual A46 Godot native captures, not just the PNG generator source.

## Delivered A46 V2, not merely documentation
- Rebuilt whole waist/pelvis span from original approved A62 pixels with 16-row anatomical irregular core masking, preserving existing hand/sword animation and dynamic foot placements.
- Applied coherent spine anticipation/recovery -1px F2-4, +1px F6-8, normal F0/1/5/9/10/11. Hip and boots remain grounded. Armor/face contents preserved under translation.
- Separate Body/Weapon/FX texture atlases: assets/actor01_a46_{body,weapon,fx}_12frames.png (256x192).
- F6 wrist/blade contact re-anchored: (29,9) -> (30,9) in assets/actor01_a46_attack_anchors.json; Godot single AnimationPlayer fifth HitMarker track remains synchronized.
- Preserved original V1, A45 and A62 art and deterministic two-stage generators.
- Native Godot 12 frame screenshots, GIF, true practice-target contact screenshot and logs.
- README_A46.md gives test commands and caveats.

## Verified in real native engine
- Godot 4.7.2 editor cold import exit 0.
- Native Windows OpenGL AMD Radeon RX 6700 XT: 12/12 frames, zero mismatched RGBA after premultiplied Alpha correctness, no boundary crop, 11 distinct poses.
- 0.55s F6 hit, 70ms hitstop, A39 breathing idle recovery PASS.
- Independent practice target HP 100->75->50, miss out of range, no duplicate serial, no ghost damage on cancellation, accelerated playback PASS; F6 local (30,9).
- Source A62 waist gate exit0, known bad A45 gate exit1, new A46 gate exit0. Godot GPU 12-frame crosscheck: no failures.
- V2 waist/shoulder row41-42 alpha overlap 11px for all 12 frames; Body one connected alpha component/frame; hand and sword/marker distances zero; under-34 head pixel content exact under lean translation.
- Deterministic regeneration: all three final Body/Weapon/FX SHA256 exactly reproducible.
- New project source and test evidence in private Drive FS_A46_INTEGRATED_TORSO_ATTACK_20261115 and GitHub future path tools/asset_factory/godot_a46/.

## Quality decisions
A45 ART FAIL for known seam. A46 V2 known-waist-geometry/regression PASS; engine & isolated contact PASS.
**A46 full art still HOLD** pending final human 1x review: shoulder/chest rotation is subtle and full dynamic weight may need stronger, authored poses beyond 1px.
Formal migrated FS combat ATB/system/skill/enemy damage **NOT RUN**.
No new development in RMVX. Do not overwrite main, map or migration branches.

## Next actual creative milestone
Build one coherent anatomically coupled 45-degree character pose chain (idle/loading/accelerate/hit/recover) with more substantial shoulder rotation and arm-bone articulation. Preserve A46 V2 as technical baseline and keep the bad A45 regression in QA. Do not label all art PASS on mere image geometry tests.
