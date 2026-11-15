# Forest Symphony A44 | Delivery Receipt | 2026-11-15

This release follows A43 without modifying GitHub main, map development, or the separate formal FS migration branch.

## Verified durable locations
- GitHub working branch: feat/fs-asset-factory-v1-20261107
- A44 standalone runnable tree: tools/asset_factory/godot_a44/
- A44 engineering commit: d7f3c1c62937ef821c4687388d5b62bd7ec6a89b
- GitHub handoff: docs/asset_factory/A44_FORMAL_GODOT_COMBAT_CONTACT_NATIVE_GPU_COLD_PASS_20261115.md
- GitHub CURRENT_HANDOFF.md now leads with A44.
- Private Drive (owner-only) complete release filename: FS_A44_GODOT_DYNAMIC_SWORD_CONTACT_GPU_PASS_ART_HOLD_20261115.zip
- ZIP file count: 186; ZIP bytes: 558325; ZIP SHA256: a1433c135d6963082259c8573e6004a4ef35d263fe956eb379e34d60f7288443
- Cloud provider metadata readback: file name, byte size and owner-only permissions verified.

## Native and cold QA
Godot 4.7.2 AMD RX6700XT, true OpenGL native renderer.
12/12 sprite GPU images matched at 0 pixel divergence, no border crops. Moving hit marker keyframe path included in single attack AnimationPlayer. 100 to 75 to 50 HP on in-range contacts. Miss/duplicate/cancel/double-speed/re-entrant cancel all checked in native runtime.
Cold ZIP extraction: 185 SHA-validated project files mismatch count 0, fresh editor import exit0, fresh GPU QA exit0, fresh contact QA exit0; temporary local cold-run directory deleted.

## Gates
ENGINE and isolated practice fight PASS. Human aesthetic ART HOLD. Formal FS migrated battle ATB/enemy status/damage integration NOT RUN.
Prior A42/A43 sources retained and not overwritten. Original RPG Maker VX E: unchanged. PixelLab not charged.
