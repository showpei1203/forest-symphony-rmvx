# Forest Symphony A46 -> A47 | Formal Engineering Handoff | 2026-11-15

Current engine: Godot 4.7.2, main battle-art asset factory, Actor01 45-degree facing, 12 frames 64x64. A47 here is NOT the unrelated historical 2026-11-01 running test also called A47.

Verified baseline private A46 ZIP SHA256 7134ccaeb719cc198abd589fae67fbfe86e15cfd07fd61f66ceff397801f14c9. Source remains protected. No overwrite of older A42-A46, VX E: original, Github main/map/migration branches. P0 cloud-only owner-restricted Drive and GitHub feature branch.

Specialized references reviewed BEFORE starting: .agents/skills/fs-rmvx-router/SKILL.md and FS_ASSET_FACTORY_ACTIVE_MASTER v1.3; A57 18-joint PixelLab prompt/rig guidelines; A62 accepted natural small-step body coordination; A65 rejected scanline-motion method. New reusable English+joint source prompt: PROMPT_A47_REUSABLE_FULLBODY_SLASH.md. A47 design skeleton JSON is manually approximated (NOT provider result), and zero PixelLab paid calls occurred.

Actual A47 engineering: no one-off cropped body pasting, A47 generator takes immutable A46 V1 canonical connected body and runs smooth two-dimensional inverse sampling (spatial head-neck/shoulder/chest/pelvis weighted coupling; wrist, boot and pelvis locks) separately per one of 12 poses. A46 original weapon and FX layers remain separate. R1, R2, R3 variations were produced (not conceptual drawings). Visual/alpha test rejected R1 F04 detached 10px, R2 F02 detached 10px. R3 passes 12/12 connected Body, grounded boots, no frame crop, known A45 waistband failures absent.

R3 was promoted to res://assets/actor01_a47_{body,weapon,fx}_12frames.png, 256x192 atlas; single Godot AnimationPlayer retains 12 Body/Weapon/FX+HitMarker frames. F6 contact (30,9), 0.55s, 70ms hitstop remain correct.
Native Godot 4.7.2 AMD RX6700XT C: transient cold test: editor import exit0, GPU renderer 12 exact source images diff0 and no border crops, 11 distinct poses, hitstop and idle recovery PASS. Isolated practice-target HP100->75->50, outside miss/no double damage/cancel/double-speed PASS. Waist regression A62 PASS, A45 FAIL expected, A47 R3 PASS in real native PNGs.
Actual Godot GPU 12-frame animated GIF A47_GODOT_NATIVE_ATTACK_12FRAMES_4X.gif; side-by-side GIF A47_GODOT_SIDE_BY_SIDE_A46_A47_4X.gif. Independent 1x and 3x R1/R2/R3 sheet, raw native screenshot PNG, QA, failure log preserved.

Quality gates: ENGINE PASS; knowable Body structural defects PASS; ART HOLD (visually stronger loading and recovery but not user-approved, still limited sprite art pose detail); formal complete FS migration ATB + enemy skill combat NOT RUN.
Next priority: if artistically still stiff, use true whole-body 18-joint authored pixel redraw/PixelLab only if authorized. Do not return to horizontal scanline shifts or repeated QA without new art.
